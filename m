From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] gro: __napi_gro_receive() optimizations
Date: Wed, 25 Aug 2010 23:15:11 +0200
Message-ID: <1282770911.2681.205.camel@edumazet-laptop>
References: <1282768431.2681.144.camel@edumazet-laptop>
	 <20100825.135726.189708768.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:43462 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754502Ab0HYVX2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 17:23:28 -0400
Received: by bwz11 with SMTP id 11so785966bwz.19
        for <netdev@vger.kernel.org>; Wed, 25 Aug 2010 14:23:27 -0700 (PDT)
In-Reply-To: <20100825.135726.189708768.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 25 ao=C3=BBt 2010 =C3=A0 13:57 -0700, David Miller a =C3=A9=
crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 25 Aug 2010 22:33:51 +0200
>=20
> > @@ -102,19 +102,9 @@ vlan_gro_common(struct napi_struct *napi, stru=
ct vlan_group *grp,
> >  	if (vlan_dev)
> >  		skb->dev =3D vlan_dev;
> >  	else if (vlan_id)
> > -		goto drop;
> > -
> > -	for (p =3D napi->gro_list; p; p =3D p->next) {
> > -		NAPI_GRO_CB(p)->same_flow =3D
> > -			p->dev =3D=3D skb->dev && !compare_ether_header(
> > -				skb_mac_header(p), skb_gro_mac_header(skb));
> > -		NAPI_GRO_CB(p)->flush =3D 0;
> > -	}
> > -
> > -	return dev_gro_receive(napi, skb);
> > +		return GRO_DROP;
> > =20
> > -drop:
> > -	return GRO_DROP;
> > +	return __napi_gro_receive(napi, skb);
>=20
> I was looking at this the other day and considering something
> similar but I didn't do it because this now makes the call chain
> deeper.
>=20
> And that can make a performance difference.
>=20
> I don't want to add this hunk unless some GRO perf regression tests
> are done.
>=20

Yes, we can inline it, this will speedup the non vlan case as well :)

Thanks !

[PATCH net-next-2.6 v2] gro: __napi_gro_receive() optimizations

compare_ether_header() can have a special implementation on 64 bit
arches if CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is defined

__napi_gro_receive() can avoid a conditional branch to perform device
match.

__napi_gro_receive() can be used from vlan_gro_common() instead of bein=
g
duplicated.

As David requested, make it an inline function so that no extra level i=
s
added in call chain.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/etherdevice.h |   27 ++++++++++++++++++++++++++-
 net/8021q/vlan_core.c       |   15 ++-------------
 net/core/dev.c              |   16 ----------------
 3 files changed, 28 insertions(+), 30 deletions(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 2308fbb..9c58d68 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -237,13 +237,38 @@ static inline bool is_etherdev_addr(const struct =
net_device *dev,
  * entry points.
  */
=20
-static inline int compare_ether_header(const void *a, const void *b)
+static inline unsigned long compare_ether_header(const void *a, const =
void *b)
 {
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG =3D=
=3D 64
+	unsigned long fold;
+
+	fold =3D *(unsigned long *)a ^ *(unsigned long *)b;
+	fold |=3D *(unsigned long *)(a + 6) ^ *(unsigned long *)(b + 6);
+	return fold;
+#else
 	u32 *a32 =3D (u32 *)((u8 *)a + 2);
 	u32 *b32 =3D (u32 *)((u8 *)b + 2);
=20
 	return (*(u16 *)a ^ *(u16 *)b) | (a32[0] ^ b32[0]) |
 	       (a32[1] ^ b32[1]) | (a32[2] ^ b32[2]);
+#endif
+}
+
+static inline gro_result_t __napi_gro_receive(struct napi_struct *napi=
, struct sk_buff *skb)
+{
+	struct sk_buff *p;
+
+	for (p =3D napi->gro_list; p; p =3D p->next) {
+		unsigned long diffs;
+
+		diffs =3D (unsigned long)p->dev ^ (unsigned long)skb->dev;
+		diffs |=3D compare_ether_header(skb_mac_header(p),
+					      skb_gro_mac_header(skb));
+		NAPI_GRO_CB(p)->same_flow =3D !diffs;
+		NAPI_GRO_CB(p)->flush =3D 0;
+	}
+
+	return dev_gro_receive(napi, skb);
 }
=20
 #endif	/* _LINUX_ETHERDEVICE_H */
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 07eeb5b..ce7b4b1 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -87,7 +87,6 @@ static gro_result_t
 vlan_gro_common(struct napi_struct *napi, struct vlan_group *grp,
 		unsigned int vlan_tci, struct sk_buff *skb)
 {
-	struct sk_buff *p;
 	struct net_device *vlan_dev;
 	u16 vlan_id;
=20
@@ -102,19 +101,9 @@ vlan_gro_common(struct napi_struct *napi, struct v=
lan_group *grp,
 	if (vlan_dev)
 		skb->dev =3D vlan_dev;
 	else if (vlan_id)
-		goto drop;
-
-	for (p =3D napi->gro_list; p; p =3D p->next) {
-		NAPI_GRO_CB(p)->same_flow =3D
-			p->dev =3D=3D skb->dev && !compare_ether_header(
-				skb_mac_header(p), skb_gro_mac_header(skb));
-		NAPI_GRO_CB(p)->flush =3D 0;
-	}
-
-	return dev_gro_receive(napi, skb);
+		return GRO_DROP;
=20
-drop:
-	return GRO_DROP;
+	return __napi_gro_receive(napi, skb);
 }
=20
 gro_result_t vlan_gro_receive(struct napi_struct *napi, struct vlan_gr=
oup *grp,
diff --git a/net/core/dev.c b/net/core/dev.c
index 859e30f..195f9c7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3169,22 +3169,6 @@ normal:
 }
 EXPORT_SYMBOL(dev_gro_receive);
=20
-static gro_result_t
-__napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
-{
-	struct sk_buff *p;
-
-	for (p =3D napi->gro_list; p; p =3D p->next) {
-		NAPI_GRO_CB(p)->same_flow =3D
-			(p->dev =3D=3D skb->dev) &&
-			!compare_ether_header(skb_mac_header(p),
-					      skb_gro_mac_header(skb));
-		NAPI_GRO_CB(p)->flush =3D 0;
-	}
-
-	return dev_gro_receive(napi, skb);
-}
-
 gro_result_t napi_skb_finish(gro_result_t ret, struct sk_buff *skb)
 {
 	switch (ret) {


