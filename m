From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: timestamp cloned packet in
 dev_queue_xmit_nit
Date: Tue, 21 Dec 2010 08:22:51 +0100
Message-ID: <1292916171.2627.184.camel@edumazet-laptop>
References: <1292428252.3427.342.camel@edumazet-laptop>
	 <20101216211744.GA2191@del.dom.local>
	 <1292535039.2655.13.camel@edumazet-laptop>
	 <20101216220838.GB2191@del.dom.local>
	 <1292538363.2655.20.camel@edumazet-laptop>
	 <20101216224237.GC2191@del.dom.local>
	 <1292542305.2655.25.camel@edumazet-laptop>
	 <20101217073015.GA6907@ff.dom.local>
	 <1292573297.2655.42.camel@edumazet-laptop>
	 <20101217083413.GB6907@ff.dom.local>  <20101217085937.GC6907@ff.dom.local>
	 <1292577988.2906.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>, netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Jarek Poplawski <jarkao2@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40747 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752481Ab0LUHW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 02:22:56 -0500
Received: by wwa36 with SMTP id 36so3834032wwa.1
        for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 23:22:55 -0800 (PST)
In-Reply-To: <1292577988.2906.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 17 d=C3=A9cembre 2010 =C3=A0 10:26 +0100, Eric Dumazet a =C3=
=A9crit :

>=20
> I think we can add this after latest Changli patch :
>=20
> He does one skb_clone() before calling the sniffers.
> We could set timestamp on this clone, instead of original skb.
>=20
> Problem solved.
>=20

[PATCH net-next-2.6] net: timestamp cloned packet in dev_queue_xmit_nit

Now we do one clone of skb if at least one sniffer might take packet,
we also can do the skb timestamping on the clone and let original packe=
t
unchanged.

This is a generalization of commit 8caf153974f2 (net: sch_netem: Fix an
inconsistency in ingress netem timestamps.)

This way, we can have a good idea when packets are delivered to our
stack (tcpdump -i ifb0), while a tcpdump on original device gives
timestamps right before ingressing.

This also speedup our stack, avoiding taking timestamps if not needed.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Changli Gao <xiaosuo@gmail.com>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Jarek Poplawski <jarkao2@gmail.com>
---
 net/core/dev.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 5987729..a215269 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1547,13 +1547,6 @@ static void dev_queue_xmit_nit(struct sk_buff *s=
kb, struct net_device *dev)
 	struct sk_buff *skb2 =3D NULL;
 	struct packet_type *pt_prev =3D NULL;
=20
-#ifdef CONFIG_NET_CLS_ACT
-	if (!(skb->tstamp.tv64 && (G_TC_FROM(skb->tc_verd) & AT_INGRESS)))
-		net_timestamp_set(skb);
-#else
-	net_timestamp_set(skb);
-#endif
-
 	rcu_read_lock();
 	list_for_each_entry_rcu(ptype, &ptype_all, list) {
 		/* Never send packets back to the socket
@@ -1572,6 +1565,8 @@ static void dev_queue_xmit_nit(struct sk_buff *sk=
b, struct net_device *dev)
 			if (!skb2)
 				break;
=20
+			net_timestamp_set(skb2);
+
 			/* skb->nh should be correctly
 			   set by sender, so that the second statement is
 			   just protection against buggy protocols.


