From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: VLAN packets silently dropped in promiscuous mode
Date: Thu, 30 Sep 2010 14:16:44 +0200
Message-ID: <1285849004.2615.394.camel@edumazet-laptop>
References: <20100929113757.GA23755@core.hellgate.ch>
	 <AANLkTi=QAoVH9KU8FAH6iscWt_mKnZpU3P9QqgFRLqXM@mail.gmail.com>
	 <20100930080703.GA10827@core.hellgate.ch>
	 <1285838215.2615.126.camel@edumazet-laptop>
	 <1285840532.2615.196.camel@edumazet-laptop>
	 <1285843234.2615.278.camel@edumazet-laptop>  <4CA46B72.2090100@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roger Luethi <rl@hellgate.ch>, David Miller <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:49250 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751857Ab0I3MQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 08:16:53 -0400
Received: by fxm4 with SMTP id 4so602532fxm.19
        for <netdev@vger.kernel.org>; Thu, 30 Sep 2010 05:16:51 -0700 (PDT)
In-Reply-To: <4CA46B72.2090100@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 30 septembre 2010 =C3=A0 12:50 +0200, Patrick McHardy a =C3=A9=
crit :

> This should be fine as long as the packets are properly marked
> with PACKET_OTHERHOST.

Ah thanks Patrick for the tip !

I tested following patch on tg3 and it is doing the right thing this
time.


[PATCH] vlan: dont drop packets from unknown vlans in promiscuous mode

Roger Luethi noticed packets for unknown VLANs getting silently dropped
even in promiscuous mode.

Check for promiscuous mode in __vlan_hwaccel_rx() and vlan_gro_common()
before drops.

As suggested by Patrick, mark such packets to have skb->pkt_type set to
PACKET_OTHERHOST to make sure they are dropped by IP stack.

Reported-by: Roger Luethi <rl@hellgate.ch>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Patrick McHardy <kaber@trash.net>
---
 net/8021q/vlan_core.c |   14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 01ddb04..0eb96f7 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -24,8 +24,11 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct vl=
an_group *grp,
=20
 	if (vlan_dev)
 		skb->dev =3D vlan_dev;
-	else if (vlan_id)
-		goto drop;
+	else if (vlan_id) {
+		if (!(skb->dev->flags & IFF_PROMISC))
+			goto drop;
+		skb->pkt_type =3D PACKET_OTHERHOST;
+	}
=20
 	return (polling ? netif_receive_skb(skb) : netif_rx(skb));
=20
@@ -102,8 +105,11 @@ vlan_gro_common(struct napi_struct *napi, struct v=
lan_group *grp,
=20
 	if (vlan_dev)
 		skb->dev =3D vlan_dev;
-	else if (vlan_id)
-		goto drop;
+	else if (vlan_id) {
+		if (!(skb->dev->flags & IFF_PROMISC))
+			goto drop;
+		skb->pkt_type =3D PACKET_OTHERHOST;
+	}
=20
 	for (p =3D napi->gro_list; p; p =3D p->next) {
 		NAPI_GRO_CB(p)->same_flow =3D


