From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel panic when using netns+bridges+tc(netem)
Date: Thu, 06 May 2010 08:59:47 +0200
Message-ID: <1273129187.2304.14.camel@edumazet-laptop>
References: <o2wb9800b71005051801uc575c6abp5bad3bd50d54ef96@mail.gmail.com>
	 <1273128002.2304.4.camel@edumazet-laptop>
	 <1273128429.2304.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Mathieu Lacage <mathieu.lacage@sophia.inria.fr>,
	David Miller <davem@davemloft.net>
To: =?ISO-8859-1?Q?Mart=EDn?= Ferrari <martin.ferrari@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:61382 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082Ab0EFG7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 02:59:54 -0400
Received: by bwz19 with SMTP id 19so302337bwz.21
        for <netdev@vger.kernel.org>; Wed, 05 May 2010 23:59:52 -0700 (PDT)
In-Reply-To: <1273128429.2304.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 06 mai 2010 =C3=A0 08:47 +0200, Eric Dumazet a =C3=A9crit :
> Le jeudi 06 mai 2010 =C3=A0 08:40 +0200, Eric Dumazet a =C3=A9crit :
> > Le jeudi 06 mai 2010 =C3=A0 03:01 +0200, Mart=C3=ADn Ferrari a =C3=A9=
crit :
> > > Hi there,
> > >=20
> > > While working on my project that uses netns, I found another bug.=
 This
> > > one causes a "Kernel panic - not syncing: Fatal exception in
> > > interrupt", and I can reproduce it in 2.6.33 and 2.6.34-rc5, but =
not
> > > in 2.6.32. It dies during a call to __free_skb.
> > > I tested this on my x86_64 laptop (2 cores) and on qemu. In qemu =
it
> > > was not triggered until I asked it to emulate 2 cpus instead of o=
ne,
> > > so it is probably a SMP-only issue.
> > >=20
> > > Scenario:
> > >=20
> > > I set up a number of network namespaces, each with two veths to n=
etns
> > > 1. In the main namespace I take those veths and bridge them in pa=
irs,
> > > to configure a linear topology; also I configure the netem qdisc =
to
> > > simulate link delay.
> > >=20
> > > Once the network is set up, I run a client/server program to send=
 UDP
> > > packets from one end of the topology to the other. After a few se=
conds
> > > of sending packets (not really deterministic) it panics.
> > >=20
> > > Note that I didn't experience this problem when using only 2
> > > namespaces (so, no routing)
> > >=20
> > > below the dumps. These all come from the qemu, as I couldn't use
> > > netconsole in the network at work, but I checked and the backtrac=
es
> > > were essentially the same
> > >=20
=2E..
> > Could you please try following patch ?
> >=20
> > Thanks
> >=20
> > [PATCH] veth: Dont kfree_skb() after dev_forward_skb()
> >=20
> > In case of congestion, dev_forward_skb() already free the skb
> >=20
> > Reported-by: Mart=C3=ADn Ferrari <martin.ferrari@gmail.com>
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > ---
> > diff --git a/drivers/net/veth.c b/drivers/net/veth.c
> > index f9f0730..5ec542d 100644
> > --- a/drivers/net/veth.c
> > +++ b/drivers/net/veth.c
> > @@ -187,7 +187,6 @@ tx_drop:
> >  	return NETDEV_TX_OK;
> > =20
> >  rx_drop:
> > -	kfree_skb(skb);
> >  	rcv_stats->rx_dropped++;
> >  	return NETDEV_TX_OK;
> >  }
> >=20
>=20
> Hmm, scratch that one, I'll resubmit a proper fix in few minutes
>=20
> (We must change dev_forward_skb() too)
>=20

David, this is a stable candidate, once tested and acked, thanks !

[PATCH] veth: Dont kfree_skb() after dev_forward_skb()

In case of congestion, netif_rx() frees the skb, so we must assume
dev_forward_skb() also consume skb.

Bug introduced by commit 445409602c092
(veth: move loopback logic to common location)

We must change dev_forward_skb() to always consume skb, and veth to not
double free it.

Bug report : http://marc.info/?l=3Dlinux-netdev&m=3D127310770900442&w=3D=
3

Reported-by: Mart=C3=ADn Ferrari <martin.ferrari@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/veth.c |    1 -
 net/core/dev.c     |   11 +++++------
 2 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index f9f0730..5ec542d 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -187,7 +187,6 @@ tx_drop:
 	return NETDEV_TX_OK;
=20
 rx_drop:
-	kfree_skb(skb);
 	rcv_stats->rx_dropped++;
 	return NETDEV_TX_OK;
 }
diff --git a/net/core/dev.c b/net/core/dev.c
index f769098..264137f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1451,7 +1451,7 @@ static inline void net_timestamp(struct sk_buff *=
skb)
  *
  * return values:
  *	NET_RX_SUCCESS	(no congestion)
- *	NET_RX_DROP     (packet was dropped)
+ *	NET_RX_DROP     (packet was dropped, but freed)
  *
  * dev_forward_skb can be used for injecting an skb from the
  * start_xmit function of one device into the receive queue
@@ -1465,12 +1465,11 @@ int dev_forward_skb(struct net_device *dev, str=
uct sk_buff *skb)
 {
 	skb_orphan(skb);
=20
-	if (!(dev->flags & IFF_UP))
-		return NET_RX_DROP;
-
-	if (skb->len > (dev->mtu + dev->hard_header_len))
+	if (!(dev->flags & IFF_UP) ||
+	    (skb->len > (dev->mtu + dev->hard_header_len))) {
+		kfree_skb(skb);
 		return NET_RX_DROP;
-
+	}
 	skb_set_dev(skb, dev);
 	skb->tstamp.tv64 =3D 0;
 	skb->pkt_type =3D PACKET_HOST;


