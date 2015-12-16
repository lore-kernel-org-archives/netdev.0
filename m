From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 08/12] batman-adv: detect local excess vlans in TT request
Date: Wed, 16 Dec 2015 15:49:29 +0800
Message-ID: <1450252173-20949-9-git-send-email-antonio@meshcoding.com>
References: <1450252173-20949-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:14941 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932763AbbLPHvd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2015 02:51:33 -0500
In-Reply-To: <1450252173-20949-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <sw@simonwunderlich.de>

If the local representation of the global TT table of one originator has
more VLAN entries than the respective TT update, there is some
inconsistency present. By detecting and reporting this inconsistency,
the global table gets updated and the excess VLAN will get removed in
the process.

Reported-by: Alessandro Bolletta <alessandro@mediaspot.net>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
Acked-by: Antonio Quartulli <antonio@meshcoding.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/translation-table.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 4228b10..17822de 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -2411,8 +2411,8 @@ static bool batadv_tt_global_check_crc(struct batadv_orig_node *orig_node,
 {
 	struct batadv_tvlv_tt_vlan_data *tt_vlan_tmp;
 	struct batadv_orig_node_vlan *vlan;
+	int i, orig_num_vlan;
 	u32 crc;
-	int i;
 
 	/* check if each received CRC matches the locally stored one */
 	for (i = 0; i < num_vlan; i++) {
@@ -2438,6 +2438,18 @@ static bool batadv_tt_global_check_crc(struct batadv_orig_node *orig_node,
 			return false;
 	}
 
+	/* check if any excess VLANs exist locally for the originator
+	 * which are not mentioned in the TVLV from the originator.
+	 */
+	rcu_read_lock();
+	orig_num_vlan = 0;
+	hlist_for_each_entry_rcu(vlan, &orig_node->vlan_list, list)
+		orig_num_vlan++;
+	rcu_read_unlock();
+
+	if (orig_num_vlan > num_vlan)
+		return false;
+
 	return true;
 }
 
-- 
2.6.4
