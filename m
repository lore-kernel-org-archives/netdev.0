From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 04/16] batman-adv: Use only queued fragments when merging
Date: Fri, 29 May 2015 11:05:16 +0200
Message-ID: <1432890328-8247-5-git-send-email-antonio@meshcoding.com>
References: <1432890328-8247-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:21942 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755656AbbE2JaK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2015 05:30:10 -0400
In-Reply-To: <1432890328-8247-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sven Eckelmann <sven@narfation.org>

The fragment queueing code now validates the total_size of each fragmen=
t,
checks when enough fragments are queued to allow to merge them into a
single packet and if the fragments have the correct size. Therefore, it=
 is
not required to have any other parameter for the merging function than =
a
list of queued fragments.

This change should avoid problems like in the past when the different s=
kb
from the list and the function parameter were mixed incorrectly.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Acked-by: Martin Hundeb=C3=B8ll <martin@hundeboll.net>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/fragmentation.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentat=
ion.c
index a9fc653..6ce3c84 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -231,19 +231,13 @@ err:
  * Returns the merged skb or NULL on error.
  */
 static struct sk_buff *
-batadv_frag_merge_packets(struct hlist_head *chain, struct sk_buff *sk=
b)
+batadv_frag_merge_packets(struct hlist_head *chain)
 {
 	struct batadv_frag_packet *packet;
 	struct batadv_frag_list_entry *entry;
 	struct sk_buff *skb_out =3D NULL;
 	int size, hdr_size =3D sizeof(struct batadv_frag_packet);
=20
-	/* Make sure incoming skb has non-bogus data. */
-	packet =3D (struct batadv_frag_packet *)skb->data;
-	size =3D ntohs(packet->total_size);
-	if (size > batadv_frag_size_limit())
-		goto free;
-
 	/* Remove first entry, as this is the destination for the rest of the
 	 * fragments.
 	 */
@@ -252,6 +246,9 @@ batadv_frag_merge_packets(struct hlist_head *chain,=
 struct sk_buff *skb)
 	skb_out =3D entry->skb;
 	kfree(entry);
=20
+	packet =3D (struct batadv_frag_packet *)skb_out->data;
+	size =3D ntohs(packet->total_size);
+
 	/* Make room for the rest of the fragments. */
 	if (pskb_expand_head(skb_out, 0, size - skb_out->len, GFP_ATOMIC) < 0=
) {
 		kfree_skb(skb_out);
@@ -307,7 +304,7 @@ bool batadv_frag_skb_buffer(struct sk_buff **skb,
 	if (hlist_empty(&head))
 		goto out;
=20
-	skb_out =3D batadv_frag_merge_packets(&head, *skb);
+	skb_out =3D batadv_frag_merge_packets(&head);
 	if (!skb_out)
 		goto out_err;
=20
--=20
2.4.2
