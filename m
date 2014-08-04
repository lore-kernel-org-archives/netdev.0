From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH] batman-adv: Fix out-of-order fragmentation support
Date: Mon,  4 Aug 2014 17:47:01 +0200
Message-ID: <1407167221-10575-2-git-send-email-antonio@meshcoding.com>
References: <1407167221-10575-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:46915 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750908AbaHDPsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2014 11:48:05 -0400
In-Reply-To: <1407167221-10575-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

batadv_frag_insert_packet was unable to handle out-of-order packets because it
dropped them directly. This is caused by the way the fragmentation lists is
checked for the correct place to insert a fragmentation entry.

The fragmentation code keeps the fragments in lists. The fragmentation entries
are kept in descending order of sequence number. The list is traversed and each
entry is compared with the new fragment. If the current entry has a smaller
sequence number than the new fragment then the new one has to be inserted
before the current entry. This ensures that the list is still in descending
order.

An out-of-order packet with a smaller sequence number than all entries in the
list still has to be added to the end of the list. The used hlist has no
information about the last entry in the list inside hlist_head and thus the
last entry has to be calculated differently. Currently the code assumes that
the iterator variable of hlist_for_each_entry can be used for this purpose
after the hlist_for_each_entry finished. This is obviously wrong because the
iterator variable is always NULL when the list was completely traversed.

Instead the information about the last entry has to be stored in a different
variable.

This problem was introduced in 9b3eab61754d74a93c9840c296013fe3b4a1b606
("batman-adv: Receive fragmented packets and merge").

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/fragmentation.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentation.c
index f14e54a..022d18a 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -128,6 +128,7 @@ static bool batadv_frag_insert_packet(struct batadv_orig_node *orig_node,
 {
 	struct batadv_frag_table_entry *chain;
 	struct batadv_frag_list_entry *frag_entry_new = NULL, *frag_entry_curr;
+	struct batadv_frag_list_entry *frag_entry_last = NULL;
 	struct batadv_frag_packet *frag_packet;
 	uint8_t bucket;
 	uint16_t seqno, hdr_size = sizeof(struct batadv_frag_packet);
@@ -180,11 +181,14 @@ static bool batadv_frag_insert_packet(struct batadv_orig_node *orig_node,
 			ret = true;
 			goto out;
 		}
+
+		/* store current entry because it could be the last in list */
+		frag_entry_last = frag_entry_curr;
 	}
 
-	/* Reached the end of the list, so insert after 'frag_entry_curr'. */
-	if (likely(frag_entry_curr)) {
-		hlist_add_after(&frag_entry_curr->list, &frag_entry_new->list);
+	/* Reached the end of the list, so insert after 'frag_entry_last'. */
+	if (likely(frag_entry_last)) {
+		hlist_add_after(&frag_entry_last->list, &frag_entry_new->list);
 		chain->size += skb->len - hdr_size;
 		chain->timestamp = jiffies;
 		ret = true;
-- 
1.8.5.5
