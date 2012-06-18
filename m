From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 15/19] batman-adv: fix visualization output without neighbors on the primary interface
Date: Mon, 18 Jun 2012 22:39:19 +0200
Message-ID: <1340051963-14836-16-git-send-email-ordex@autistici.org>
References: <1340051963-14836-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Matthias Schiffer <mschiffer@universe-factory.net>,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:41512 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753304Ab2FRUjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 16:39:16 -0400
In-Reply-To: <1340051963-14836-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthias Schiffer <mschiffer@universe-factory.net>

The primary entry and the corresponding secondary entries are missing when there
are no neighbors on the primary interface. This also causes the TT entries to
miss and makes nodes with multiply secondary interface fall apart since there
is no way to see they are related without a primary entry.

Fix this by always emitting a primary entry.

Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/vis.c |   21 ++++++++++++++-------
 1 file changed, 14 insertions(+), 7 deletions(-)

diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index 411c0e1..01d5da5 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -207,7 +207,6 @@ int vis_seq_print_text(struct seq_file *seq, void *offset)
 	int vis_server = atomic_read(&bat_priv->vis_mode);
 	size_t buff_pos, buf_size;
 	char *buff;
-	int compare;
 
 	primary_if = primary_if_get_selected(bat_priv);
 	if (!primary_if)
@@ -228,14 +227,18 @@ int vis_seq_print_text(struct seq_file *seq, void *offset)
 			entries = (struct vis_info_entry *)
 				((char *)packet + sizeof(*packet));
 
+			vis_data_insert_interface(packet->vis_orig,
+						  &vis_if_list, true);
+
 			for (j = 0; j < packet->entries; j++) {
 				if (entries[j].quality == 0)
 					continue;
-				compare =
-				 compare_eth(entries[j].src, packet->vis_orig);
+				if (compare_eth(entries[j].src,
+						packet->vis_orig))
+					continue;
 				vis_data_insert_interface(entries[j].src,
 							  &vis_if_list,
-							  compare);
+							  false);
 			}
 
 			hlist_for_each_entry(entry, pos, &vis_if_list, list) {
@@ -276,14 +279,18 @@ int vis_seq_print_text(struct seq_file *seq, void *offset)
 			entries = (struct vis_info_entry *)
 				((char *)packet + sizeof(*packet));
 
+			vis_data_insert_interface(packet->vis_orig,
+						  &vis_if_list, true);
+
 			for (j = 0; j < packet->entries; j++) {
 				if (entries[j].quality == 0)
 					continue;
-				compare =
-				 compare_eth(entries[j].src, packet->vis_orig);
+				if (compare_eth(entries[j].src,
+						packet->vis_orig))
+					continue;
 				vis_data_insert_interface(entries[j].src,
 							  &vis_if_list,
-							  compare);
+							  false);
 			}
 
 			hlist_for_each_entry(entry, pos, &vis_if_list, list) {
-- 
1.7.9.4
