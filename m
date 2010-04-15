From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: using smp_processor_id() in preemptible [00000000] code:
 avahi-daemon: caller is netif_rx
Date: Thu, 15 Apr 2010 10:49:18 +0200
Message-ID: <1271321358.16881.2240.camel@edumazet-laptop>
References: <1271142857.16881.193.camel@edumazet-laptop>
	 <20100415.001446.244372815.davem@davemloft.net>
	 <l2p412e6f7f1004150030o8a406133s91d6614cbb106796@mail.gmail.com>
	 <20100415.003711.159334670.davem@davemloft.net>
	 <u2o412e6f7f1004150047nc9250ffuaef68be066a7575c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	eparis@redhat.com, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:49491 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757449Ab0DOIt2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 04:49:28 -0400
Received: by bwz25 with SMTP id 25so1206190bwz.28
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 01:49:26 -0700 (PDT)
In-Reply-To: <u2o412e6f7f1004150047nc9250ffuaef68be066a7575c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 15 avril 2010 =C3=A0 15:47 +0800, Changli Gao a =C3=A9crit :
> On Thu, Apr 15, 2010 at 3:37 PM, David Miller <davem@davemloft.net> w=
rote:
> > From: Changli Gao <xiaosuo@gmail.com>
> > Date: Thu, 15 Apr 2010 15:30:44 +0800
> >
> >> Should netif_rx() be used only when preemption is disabled? If not=
,
> >> netif_rx_ni() should be used instead.?
> >
> > netif_rx() must be invoked from a hardware or software interrupt,
> > which implies preemption disabled.
> >
> > In netif_rx_ni(), the "ni" means "not interrupt".
> >
>=20
> yea, I know netif_rx_ni()'s meaning. It means that the following
> changes aren't necessary.
>=20
>  #else
> -       cpu =3D smp_processor_id();
> +       ret =3D enqueue_to_backlog(skb, get_cpu());
> +       put_cpu();
>=20
> ret =3D enqueue_to_backlog(skb, smp_processor_id()); should be OK.
>=20
>  #endif
> -
> -       return enqueue_to_backlog(skb, cpu);
> +       return ret;
>  }

netif_rx is meant to be called from interrupts because it doesn't wake
up ksoftirqd.  For calling from outside interrupts, netif_rx_ni exists,
to make _sure_ do_softirq() is called.

However, netif_rx() _could_ be called from process context, it was safe=
,
but sofirq was a bit delayed.

Now, after RPS changes this can trigger this :

[   14.203970] BUG: using smp_processor_id() in preemptible [00000000]
code: avahi-daemon/2093
[   14.204025] caller is netif_rx+0xfa/0x110
[   14.204032] Pid: 2093, comm: avahi-daemon Tainted: G        W
2.6.34-rc3-next-20100412+ #65
[   14.204035] Call Trace:
[   14.204064]  [<ffffffff81278fe5>] debug_smp_processor_id+0x105/0x110
[   14.204070]  [<ffffffff8142163a>] netif_rx+0xfa/0x110
[   14.204090]  [<ffffffff8145b631>] ip_dev_loopback_xmit+0x71/0xa0
[   14.204095]  [<ffffffff8145b892>] ip_mc_output+0x192/0x2c0
[   14.204099]  [<ffffffff8145d610>] ip_local_out+0x20/0x30
[   14.204105]  [<ffffffff8145d8ad>] ip_push_pending_frames+0x28d/0x3d0
[   14.204119]  [<ffffffff8147f1cc>] udp_push_pending_frames+0x14c/0x40=
0
[   14.204125]  [<ffffffff814803fc>] udp_sendmsg+0x39c/0x790
[   14.204137]  [<ffffffff814891d5>] inet_sendmsg+0x45/0x80
[   14.204149]  [<ffffffff8140af91>] sock_sendmsg+0xf1/0x110
[   14.204177]  [<ffffffff810e3a89>] ? might_fault+0xb9/0xd0
[   14.204184]  [<ffffffff810e3a3e>] ? might_fault+0x6e/0xd0
[   14.204189]  [<ffffffff8140dc6c>] sys_sendmsg+0x20c/0x380
[   14.204205]  [<ffffffff811107f1>] ? do_sync_write+0xd1/0x110
[   14.204211]  [<ffffffff810e3a3e>] ? might_fault+0x6e/0xd0
[   14.204233]  [<ffffffff8100ad82>] system_call_fastpath+0x16/0x1b


We have two possibilities :

1) Make sure no netif_rx() caller is in process context, preemption
enabled.

2) Change netif_rx() to meet its initial behavior : It _can_ be called
from process context, preemption enabled. Frame might be delayed a bit
as before.

We chose 2), but David, I am not sure this is OK given git history, som=
e
calling points were changed to avoid "'NOHZ: local_softirq_pending 08' =
"
messages...

-----------------------------------------------------------------------=
-----------------

commit 481a8199142c050b72bff8a1956a49fd0a75bbe0
Author: Oliver Hartkopp <oliver@hartkopp.net>
Date:   Tue Sep 15 01:31:34 2009 -0700

    can: fix NOHZ local_softirq_pending 08 warning
   =20
    When using nanosleep() in an userspace application we get a
ratelimit warning
   =20
    NOHZ: local_softirq_pending 08
   =20
    for 10 times.
   =20
    The echo of CAN frames is done from process context and softirq
context only.
    Therefore the usage of netif_rx() was wrong (for years).
   =20
    This patch replaces netif_rx() with netif_rx_ni() which has to be
used from
    process/softirq context. It also adds a missing comment that
can_send() must
    no be used from hardirq context.
   =20
    Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>
    Signed-off-by: Urs Thuermann <urs@isnogud.escape.de>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/can/vcan.c b/drivers/net/can/vcan.c
index 6971f6c..80ac563 100644
--- a/drivers/net/can/vcan.c
+++ b/drivers/net/can/vcan.c
@@ -80,7 +80,7 @@ static void vcan_rx(struct sk_buff *skb, struct
net_device *dev)
        skb->dev       =3D dev;
        skb->ip_summed =3D CHECKSUM_UNNECESSARY;
=20
-       netif_rx(skb);
+       netif_rx_ni(skb);
 }
=20
 static netdev_tx_t vcan_tx(struct sk_buff *skb, struct net_device *dev=
)
diff --git a/net/can/af_can.c b/net/can/af_can.c
index ef1c43a..6068321 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -199,6 +199,8 @@ static int can_create(struct net *net, struct socke=
t
*sock, int protocol)
  * @skb: pointer to socket buffer with CAN frame in data section
  * @loop: loopback for listeners on local CAN sockets (recommended
default!)
  *
+ * Due to the loopback this routine must not be called from hardirq
context.
+ *
  * Return:
  *  0 on success
  *  -ENETDOWN when the selected interface is down
@@ -278,7 +280,7 @@ int can_send(struct sk_buff *skb, int loop)
        }
=20
        if (newskb)
-               netif_rx(newskb);
+               netif_rx_ni(newskb);
=20
        /* update statistics */
        can_stats.tx_frames++;


commit ae3e0fcf901e4b7df87aef7ab39093e142a8de8b
Author: Holger Schurig <hs4233@mail.mn-solutions.de>
Date:   Wed Jan 16 15:48:44 2008 +0100

    libertas cs/sdio: fix 'NOHZ: local_softirq_pending 08' message
   =20
    netif_rx should be called only from interrupt context. if_cs and
if_sdio receive
    packets from other contexts, and thus should call netif_rx_ni.
   =20
    Signed-off-by: Marc Pignat <marc.pignat@hevs.ch>
    Acked-by: Holger Schurig <hs4233@mail.mn-solutions.de>
    Signed-off-by: John W. Linville <linville@tuxdriver.com>

diff --git a/drivers/net/wireless/libertas/rx.c
b/drivers/net/wireless/libertas/rx.c
index 6332fd4..149557a 100644
--- a/drivers/net/wireless/libertas/rx.c
+++ b/drivers/net/wireless/libertas/rx.c
@@ -247,7 +247,10 @@ int lbs_process_rxed_packet(struct lbs_private
*priv, struct sk_buff *skb)
        priv->stats.rx_packets++;
=20
        skb->protocol =3D eth_type_trans(skb, dev);
-       netif_rx(skb);
+       if (in_interrupt())
+               netif_rx(skb);
+       else
+               netif_rx_ni(skb);
=20
        ret =3D 0;
 done:

-----------------------------------------------------------------------=
------------------
Maybe we should add a new function after all...

int netif_rx_any(struct sk_buff *skb)=20
{
       if (in_interrupt())
               return netif_rx(skb);

	return netif_rx_ni(skb);
}



