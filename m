From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] flow_dissector: use a 64bit load/store
Date: Tue, 29 Nov 2011 07:30:35 +0100
Message-ID: <1322548235.2970.57.camel@edumazet-laptop>
References: <1322493738.2292.69.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4ED3B603.4010702@chelsio.com>
	 <20111128.190604.1713178066845491526.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:50035 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809Ab1K2Gak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 01:30:40 -0500
Received: by mail-ey0-f174.google.com with SMTP id k14so2646161eaa.19
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 22:30:39 -0800 (PST)
In-Reply-To: <20111128.190604.1713178066845491526.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 novembre 2011 =C3=A0 19:06 -0500, David Miller a =C3=A9crit=
 :
> From: Dimitris Michailidis <dm@chelsio.com>
> Date: Mon, 28 Nov 2011 08:25:39 -0800
>=20
> >> +bool skb_flow_dissect(const struct sk_buff *skb, struct flow_keys
> >> *flow)
> >> +{
> >> +	int poff, nhoff =3D skb_network_offset(skb);
> >> +	u8 ip_proto;
> >> +	u16 proto =3D skb->protocol;
> >=20
> > __be16 instead of u16 for proto?
>=20
> I'll take care of this when I apply these patches.

( CC trimmed )

Thanks David !

Here is a small patch to use one 64bit load/store on x86_64 instead of
two 32bit load/stores.

[PATCH net-next] flow_dissector: use a 64bit load/store

gcc compiler is smart enough to use a single load/store if we
memcpy(dptr, sptr, 8) on x86_64, regardless of
CONFIG_CC_OPTIMIZE_FOR_SIZE

In IP header, daddr immediately follows saddr, this wont change in the
future. We only need to make sure our flow_keys (src,dst) fields wont
break the rule.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/flow_keys.h   |    1 +
 net/core/flow_dissector.c |   13 +++++++++++--
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/include/net/flow_keys.h b/include/net/flow_keys.h
index e4cb285..80461c1 100644
--- a/include/net/flow_keys.h
+++ b/include/net/flow_keys.h
@@ -2,6 +2,7 @@
 #define _NET_FLOW_KEYS_H
=20
 struct flow_keys {
+	/* (src,dst) must be grouped, in the same way than in IP header */
 	__be32 src;
 	__be32 dst;
 	union {
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index f0516d9..87bb35c 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -8,6 +8,16 @@
 #include <linux/ppp_defs.h>
 #include <net/flow_keys.h>
=20
+/* copy saddr & daddr, possibly using 64bit load/store
+ * Equivalent to :	flow->src =3D iph->saddr;
+ *			flow->dst =3D iph->daddr;
+ */
+static void iph_to_flow_copy_addrs(struct flow_keys *flow, const struc=
t iphdr *iph)
+{
+	BUILD_BUG_ON(offsetof(typeof(*flow), dst) !=3D
+		     offsetof(typeof(*flow), src) + sizeof(flow->src));
+	memcpy(&flow->src, &iph->saddr, sizeof(flow->src) + sizeof(flow->dst)=
);
+}
=20
 bool skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flo=
w)
 {
@@ -31,8 +41,7 @@ ip:
 			ip_proto =3D 0;
 		else
 			ip_proto =3D iph->protocol;
-		flow->src =3D iph->saddr;
-		flow->dst =3D iph->daddr;
+		iph_to_flow_copy_addrs(flow, iph);
 		nhoff +=3D iph->ihl * 4;
 		break;
 	}
