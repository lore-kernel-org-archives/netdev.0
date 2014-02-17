From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 03/10] batman-adv: release vlan object after checking the CRC
Date: Mon, 17 Feb 2014 21:48:42 +0100
Message-ID: <1392670129-2498-4-git-send-email-antonio@meshcoding.com>
References: <1392670129-2498-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@meshcoding.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:21771 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341AbaBQUxB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 15:53:01 -0500
In-Reply-To: <1392670129-2498-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a refcounter unbalance in the CRC checking routine
invoked on OGM reception. A vlan object is retrieved (thus
its refcounter is increased by one) but it is never properly
released. This leads to a memleak because the vlan object
will never be free'd.

Fix this by releasing the vlan object after having read the
CRC.

Reported-by: Russell Senior <russell@personaltelco.net>
Reported-by: Daniel <daniel@makrotopia.org>
Reported-by: cmsv <cmsv@wirelesspt.net>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/translation-table.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index beba13f..c21c557 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -2262,6 +2262,7 @@ static bool batadv_tt_global_check_crc(struct batadv_orig_node *orig_node,
 {
 	struct batadv_tvlv_tt_vlan_data *tt_vlan_tmp;
 	struct batadv_orig_node_vlan *vlan;
+	uint32_t crc;
 	int i;
 
 	/* check if each received CRC matches the locally stored one */
@@ -2281,7 +2282,10 @@ static bool batadv_tt_global_check_crc(struct batadv_orig_node *orig_node,
 		if (!vlan)
 			return false;
 
-		if (vlan->tt.crc != ntohl(tt_vlan_tmp->crc))
+		crc = vlan->tt.crc;
+		batadv_orig_node_vlan_free_ref(vlan);
+
+		if (crc != ntohl(tt_vlan_tmp->crc))
 			return false;
 	}
 
-- 
1.8.5.3
