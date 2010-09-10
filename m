From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: pskb_expand_head() optimization
Date: Fri, 10 Sep 2010 12:54:49 -0700 (PDT)
Message-ID: <20100910.125449.235704956.davem@davemloft.net>
References: <20100907091614.GA8245@ff.dom.local>
	<1283852248.2338.160.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58437
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753835Ab0IJTyb convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Sep 2010 15:54:31 -0400
In-Reply-To: <1283852248.2338.160.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 07 Sep 2010 11:37:28 +0200

> Le mardi 07 septembre 2010 =E0 09:16 +0000, Jarek Poplawski a =E9crit=
 :
>> On 2010-09-07 07:02, Eric Dumazet wrote:
>=20
>> >=20
>> > I understand what you want to do, but problem is we need to perfor=
m a
>> > CAS2 operation : atomically changes two values (dataref and frag_l=
ist)
>>=20
>> Alas I can't understand why do you think these clone and atomic test=
s
>> in skb_release_data() don't protect skb_shinfo(skb)->frag_list enoug=
h.
>>=20
>=20
> It was early in the morning, before a cup of tea.
>=20
> David only had to set frag_list in the new shinfo, not the old.

Ok, how does this look?

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 752c197..aaa9750 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -327,6 +327,32 @@ static void skb_clone_fraglist(struct sk_buff *skb=
)
 		skb_get(list);
 }
=20
+static struct sk_buff *skb_copy_fraglist(struct sk_buff *parent,
+					 gfp_t gfp_mask)
+{
+	struct sk_buff *first_skb =3D NULL;
+	struct sk_buff *prev_skb =3D NULL;
+	struct sk_buff *skb;
+
+	skb_walk_frags(parent, skb) {
+		struct sk_buff *nskb =3D pskb_copy(skb, gfp_mask);
+
+		if (!nskb)
+			goto fail;
+		if (!first_skb)
+			first_skb =3D skb;
+		else
+			prev_skb->next =3D skb;
+		prev_skb =3D skb;
+	}
+
+	return first_skb;
+
+fail:
+	skb_drop_list(&first_skb);
+	return NULL;
+}
+
 static void skb_release_data(struct sk_buff *skb)
 {
 	if (!skb->cloned ||
@@ -775,11 +801,12 @@ EXPORT_SYMBOL(pskb_copy);
 int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 		     gfp_t gfp_mask)
 {
-	int i;
-	u8 *data;
 	int size =3D nhead + (skb_end_pointer(skb) - skb->head) + ntail;
-	long off;
+	struct skb_shared_info *new_shinfo;
 	bool fastpath;
+	u8 *data;
+	long off;
+	int i;
=20
 	BUG_ON(nhead < 0);
=20
@@ -797,8 +824,8 @@ int pskb_expand_head(struct sk_buff *skb, int nhead=
, int ntail,
 	 */
 	memcpy(data + nhead, skb->head, skb_tail_pointer(skb) - skb->head);
=20
-	memcpy((struct skb_shared_info *)(data + size),
-	       skb_shinfo(skb),
+	new_shinfo =3D (struct skb_shared_info *)(data + size);
+	memcpy(new_shinfo, skb_shinfo(skb),
 	       offsetof(struct skb_shared_info, frags[skb_shinfo(skb)->nr_fra=
gs]));
=20
 	/* Check if we can avoid taking references on fragments if we own
@@ -815,14 +842,20 @@ int pskb_expand_head(struct sk_buff *skb, int nhe=
ad, int ntail,
 	if (fastpath) {
 		kfree(skb->head);
 	} else {
+		if (skb_has_frag_list(skb)) {
+			struct sk_buff *new_list;
+
+			new_list =3D skb_copy_fraglist(skb, gfp_mask);
+			if (!new_list)
+				goto free_data;
+			new_shinfo->frag_list =3D new_list;
+		}
 		for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++)
 			get_page(skb_shinfo(skb)->frags[i].page);
=20
-		if (skb_has_frag_list(skb))
-			skb_clone_fraglist(skb);
-
 		skb_release_data(skb);
 	}
+
 	off =3D (data + nhead) - skb->head;
=20
 	skb->head     =3D data;
@@ -848,6 +881,8 @@ int pskb_expand_head(struct sk_buff *skb, int nhead=
, int ntail,
 	atomic_set(&skb_shinfo(skb)->dataref, 1);
 	return 0;
=20
+free_data:
+	kfree(data);
 nodata:
 	return -ENOMEM;
 }
