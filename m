From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: pskb_expand_head() optimization
Date: Fri, 03 Sep 2010 11:09:32 +0200
Message-ID: <1283504972.2453.257.camel@edumazet-laptop>
References: <20100902.204332.02275687.davem@davemloft.net>
	 <1283492880.3699.1437.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41330 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751593Ab0ICJKb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 05:10:31 -0400
Received: by wyb35 with SMTP id 35so18430wyb.19
        for <netdev@vger.kernel.org>; Fri, 03 Sep 2010 02:09:50 -0700 (PDT)
In-Reply-To: <1283492880.3699.1437.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 03 septembre 2010 =C3=A0 07:48 +0200, Eric Dumazet a =C3=A9=
crit :

> David, I had this same idea some days ago when reviewing this code,
> but when I came to conclusion we could not avoid the get_page /
> put_page() on skb_shinfo(skb)->frags[i].page. I thought it was not wo=
rth
> trying to avoid the frag_list grab/release operation.
>=20

Here is the patch I cooked, for net-next-2.6

[PATCH net-next-2.6] net: pskb_expand_head() optimization

pskb_expand_head() blindly takes references on fragments before calling
skb_release_data(), potentially releasing these references.

We can add a fast path, avoiding these atomic operations, if we own the
last reference on skb->head.

Based on a previous patch from David

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/skbuff.c |   25 ++++++++++++++++++++-----
 1 file changed, 20 insertions(+), 5 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 231dff0..59b96fe 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -781,6 +781,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead=
, int ntail,
 	u8 *data;
 	int size =3D nhead + (skb_end_pointer(skb) - skb->head) + ntail;
 	long off;
+	bool fastpath;
=20
 	BUG_ON(nhead < 0);
=20
@@ -802,14 +803,28 @@ int pskb_expand_head(struct sk_buff *skb, int nhe=
ad, int ntail,
 	       skb_shinfo(skb),
 	       offsetof(struct skb_shared_info, frags[skb_shinfo(skb)->nr_fra=
gs]));
=20
-	for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++)
-		get_page(skb_shinfo(skb)->frags[i].page);
+	/* Check if we can avoid taking references on fragments if we own
+	 * the last reference on skb->head. (see skb_release_data())
+	 */
+	if (!skb->cloned)
+		fastpath =3D true;
+	else {
+		int delta =3D skb->nohdr ? (1 << SKB_DATAREF_SHIFT) + 1 : 1;
=20
-	if (skb_has_frag_list(skb))
-		skb_clone_fraglist(skb);
+		fastpath =3D atomic_read(&skb_shinfo(skb)->dataref) =3D=3D delta;
+	}
=20
-	skb_release_data(skb);
+	if (fastpath) {
+		kfree(skb->head);
+	} else {
+		for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++)
+			get_page(skb_shinfo(skb)->frags[i].page);
=20
+		if (skb_has_frag_list(skb))
+			skb_clone_fraglist(skb);
+
+		skb_release_data(skb);
+	}
 	off =3D (data + nhead) - skb->head;
=20
 	skb->head     =3D data;


