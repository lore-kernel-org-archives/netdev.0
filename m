From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] pktgen: Avoid dirtying skb->users when txq is full
Date: Thu, 01 Oct 2009 01:03:33 +0200
Message-ID: <4AC3E3C5.1090108@gmail.com>
References: <20090922224902.17ed6cc4@nehalam> <20090923174141.1d350103@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <jdb@comx.dk>,
	Robert Olsson <robert@herjulf.net>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35604 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752293AbZI3XDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 19:03:34 -0400
In-Reply-To: <20090923174141.1d350103@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> On Tue, 22 Sep 2009 22:49:02 -0700
> Stephen Hemminger <shemminger@vyatta.com> wrote:
>=20
>> I thought others want to know how to get maximum speed of pktgen.
>>
>> 1. Run nothing else (even X11), just a command line
>> 2. Make sure ethernet flow control is disabled
>>    ethtool -A eth0 autoneg off rx off tx off
>> 3. Make sure clocksource is TSC.  On my old SMP Opteron's
>>    needed to get patch since in 2.6.30 or later, the clock guru's
>>    decided to remove it on all non Intel machines.  Look for patch
>>    than enables "tsc=3Dreliable"
>> 4. Compile Ethernet drivers in, the overhead of the indirect
>>    function call required for modules (or cache footprint),
>>    slows things down.
>> 5. Increase transmit ring size to 1000
>>    ethtool -G eth0 tx 1000
>>

Thanks a lot Stephen.

I did some pktgen session tonight and found one contention on skb->user=
s field
that following patch avoids.


Before patch :
-----------------------------------------------------------------------=
-------
   PerfTop:    5187 irqs/sec  kernel:100.0% [100000 cycles],  (all, cpu=
: 0)
-----------------------------------------------------------------------=
-------

             samples    pcnt   kernel function
             _______   _____   _______________

            16688.00 - 50.9% : consume_skb
             6541.00 - 20.0% : skb_dma_unmap
             3277.00 - 10.0% : tg3_poll
             1968.00 -  6.0% : mwait_idle
              651.00 -  2.0% : irq_entries_start
              466.00 -  1.4% : _spin_lock
              442.00 -  1.3% : mix_pool_bytes_extract
              373.00 -  1.1% : tg3_msi
              353.00 -  1.1% : read_tsc
              177.00 -  0.5% : sched_clock_local
              176.00 -  0.5% : sched_clock
              137.00 -  0.4% : tick_nohz_stop_sched_tick

After patch:
-----------------------------------------------------------------------=
-------
   PerfTop:    3530 irqs/sec  kernel:99.9% [100000 cycles],  (all, cpu:=
 0)
-----------------------------------------------------------------------=
-------

             samples    pcnt   kernel function
             _______   _____   _______________

            17127.00 - 34.0% : tg3_poll
            12691.00 - 25.2% : consume_skb
             5299.00 - 10.5% : skb_dma_unmap
             4179.00 -  8.3% : mwait_idle
             1583.00 -  3.1% : irq_entries_start
             1288.00 -  2.6% : mix_pool_bytes_extract
             1239.00 -  2.5% : tg3_msi
             1062.00 -  2.1% : read_tsc
              583.00 -  1.2% : _spin_lock
              432.00 -  0.9% : sched_clock
              416.00 -  0.8% : sched_clock_local
              360.00 -  0.7% : tick_nohz_stop_sched_tick
              329.00 -  0.7% : ktime_get
              263.00 -  0.5% : _spin_lock_irqsave

I believe we could go further, batching the atomic_inc(&skb->users) we =
do all the
time, competing with the atomic_dec() done by tx completion handler (po=
ssibly run
on other cpu): Reserve XXXXXXX units to the skb->users, and decrement a=
 pktgen
local variable and refill the reserve if necessary, once in a while...


[PATCH] pktgen: Avoid dirtying skb->users when txq is full

We can avoid two atomic ops on skb->users if packet is not going to be
sent to the device (because hardware txqueue is full)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 4d11c28..6a9ab28 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3439,12 +3439,14 @@ static void pktgen_xmit(struct pktgen_dev *pkt_=
dev)
 	txq =3D netdev_get_tx_queue(odev, queue_map);
=20
 	__netif_tx_lock_bh(txq);
-	atomic_inc(&(pkt_dev->skb->users));
=20
-	if (unlikely(netif_tx_queue_stopped(txq) || netif_tx_queue_frozen(txq=
)))
+	if (unlikely(netif_tx_queue_stopped(txq) || netif_tx_queue_frozen(txq=
))) {
 		ret =3D NETDEV_TX_BUSY;
-	else
-		ret =3D (*xmit)(pkt_dev->skb, odev);
+		pkt_dev->last_ok =3D 0;
+		goto unlock;
+	}
+	atomic_inc(&(pkt_dev->skb->users));
+	ret =3D (*xmit)(pkt_dev->skb, odev);
=20
 	switch (ret) {
 	case NETDEV_TX_OK:
@@ -3466,6 +3468,7 @@ static void pktgen_xmit(struct pktgen_dev *pkt_de=
v)
 		atomic_dec(&(pkt_dev->skb->users));
 		pkt_dev->last_ok =3D 0;
 	}
+unlock:
 	__netif_tx_unlock_bh(txq);
=20
 	/* If pkt_dev->count is zero, then run forever */
