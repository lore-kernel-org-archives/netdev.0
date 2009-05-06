From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: bond + tc regression ?
Date: Wed, 06 May 2009 05:36:08 +0200
Message-ID: <4A0105A8.3060707@cosmosbay.com>
References: <1241538358.27647.9.camel@hazard2.francoudi.com> <4A0069F3.5030607@cosmosbay.com> <20090505174135.GA29716@francoudi.com> <4A008A72.6030607@cosmosbay.com> <20090505235008.GA17690@francoudi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Vladimir Ivashchenko <hazard@francoudi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44772 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023AbZEFDgQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 23:36:16 -0400
In-Reply-To: <20090505235008.GA17690@francoudi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vladimir Ivashchenko a =E9crit :
> On Tue, May 05, 2009 at 08:50:26PM +0200, Eric Dumazet wrote:
>=20
>>> I have tried with IRQs bound to one CPU per NIC. Same result.
>> Did you check "grep eth /proc/interrupts" that your affinities setup=
=20
>> were indeed taken into account ?
>>
>> You should use same CPU for eth0 and eth2 (bond0),
>>
>> and another CPU for eth1 and eth3 (bond1)
>=20
> Ok, the best result is when assign all IRQs to the same CPU. Zero dro=
ps.
>=20
> When I bind slaves of bond interfaces to the same CPU, I start to get=
=20
> some drops, but much less than before. I didn't play with combination=
s.
>=20
> My problem is, after applying your accounting patch below, one of my=20
> HTB servers reports only 30-40% CPU idle on one of the cores. That wo=
n't=20
> take me for very long, load balancing across cores is needed.
>=20
> Is there any way at least to balance individual NICs on per core basi=
s?
>=20

Problem of this setup is you have four NICS, but two logical devices (b=
ond0
& bond1) and a central HTB thing. This essentialy makes flows go throug=
h the same
locks (some rwlocks guarding bonding driver, and others guarding HTB st=
ructures).

Also when a cpu receives a frame on ethX, it has to forward it on ethY,=
 and
another lock guards access to TX queue of ethY device. If another cpus =
receives
a frame on ethZ and want to forward it to ethY device, this other cpu w=
ill
need same locks and everything slowdown.

I am pretty sure you could get good results choosing two cpus sharing s=
ame L2
cache. L2 on your cpu is 6MB. Another point would be to carefuly choose=
 size
of RX rings on ethX devices. You could try to *reduce* them so that num=
ber
of inflight skb is small enough that everything fits in this 6MB cache.

Problem is not really CPU power, but RAM bandwidth. Having two cores in=
stead of one
attached to one central memory bank wont increase ram bandwidth, but re=
duce it.

And making several cores compete for locks on this ram only slows down =
processing.

Only choice we have is to change bonding so that this driver uses RCU i=
nstead
of rwlocks, but it is probably a complex task. Multiple cpus accessing
bonding structures could share memory structures without dirtying them
and ping-pong cache lines.

Ah, I forgot about one patch that could help your setup too (if using m=
ore than one
cpu on NIC irqs of course), queued for 2.6.31

(commit 6a321cb370ad3db4ba6e405e638b3a42c41089b0)

You could post oprofile results to help us finding other hot spots.


[PATCH] net: netif_tx_queue_stopped too expensive

netif_tx_queue_stopped(txq) is most of the time false.

Yet its cost is very expensive on SMP.

static inline int netif_tx_queue_stopped(const struct netdev_queue *dev=
_queue)
{
	return test_bit(__QUEUE_STATE_XOFF, &dev_queue->state);
}

I saw this on oprofile hunting and bnx2 driver bnx2_tx_int().

We probably should split "struct netdev_queue" in two parts, one
being read mostly.

__netif_tx_lock() touches _xmit_lock & xmit_lock_owner, these
deserve a separate cache line.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2e7783f..1caaebb 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -447,12 +447,18 @@ enum netdev_queue_state_t
 };
=20
 struct netdev_queue {
+/*
+ * read mostly part
+ */
 	struct net_device	*dev;
 	struct Qdisc		*qdisc;
 	unsigned long		state;
-	spinlock_t		_xmit_lock;
-	int			xmit_lock_owner;
 	struct Qdisc		*qdisc_sleeping;
+/*
+ * write mostly part
+ */
+	spinlock_t		_xmit_lock ____cacheline_aligned_in_smp;
+	int			xmit_lock_owner;
 } ____cacheline_aligned_in_smp;
=20
=20

