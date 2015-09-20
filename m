From: sfeldma@gmail.com
Subject: [PATCH net-next v2 1/7] rocker: track when FDB entry is touched.
Date: Sun, 20 Sep 2015 08:48:23 -0700
Message-ID: <1442764109-11110-2-git-send-email-sfeldma@gmail.com>
References: <1442764109-11110-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, siva.mannem.lnx@gmail.com, pjonnala@broadcom.com,
	stephen@networkplumber.org, roopa@cumulusnetworks.com,
	andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33940 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753198AbbITPpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2015 11:45:42 -0400
Received: by padhy16 with SMTP id hy16so93641351pad.1
        for <netdev@vger.kernel.org>; Sun, 20 Sep 2015 08:45:42 -0700 (PDT)
In-Reply-To: <1442764109-11110-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

The entry is touched once when created, and touched again for each update.
The touched time is used to calculate FDB entry age.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Acked-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/rocker/rocker.c |   18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 34ac41a..e517e9c 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -152,6 +152,7 @@ struct rocker_fdb_tbl_entry {
 	struct hlist_node entry;
 	u32 key_crc32; /* key */
 	bool learned;
+	unsigned long touched;
 	struct rocker_fdb_tbl_key {
 		u32 pport;
 		u8 addr[ETH_ALEN];
@@ -3629,6 +3630,7 @@ static int rocker_port_fdb(struct rocker_port *rocker_port,
 		return -ENOMEM;
 
 	fdb->learned = (flags & ROCKER_OP_FLAG_LEARNED);
+	fdb->touched = jiffies;
 	fdb->key.pport = rocker_port->pport;
 	ether_addr_copy(fdb->key.addr, addr);
 	fdb->key.vlan_id = vlan_id;
@@ -3638,13 +3640,17 @@ static int rocker_port_fdb(struct rocker_port *rocker_port,
 
 	found = rocker_fdb_tbl_find(rocker, fdb);
 
-	if (removing && found) {
-		rocker_port_kfree(trans, fdb);
-		if (trans != SWITCHDEV_TRANS_PREPARE)
-			hash_del(&found->entry);
-	} else if (!removing && !found) {
+	if (found) {
+		found->touched = jiffies;
+		if (removing) {
+			rocker_port_kfree(trans, fdb);
+			if (trans != SWITCHDEV_TRANS_PREPARE)
+				hash_del(&found->entry);
+		}
+	} else if (!removing) {
 		if (trans != SWITCHDEV_TRANS_PREPARE)
-			hash_add(rocker->fdb_tbl, &fdb->entry, fdb->key_crc32);
+			hash_add(rocker->fdb_tbl, &fdb->entry,
+				 fdb->key_crc32);
 	}
 
 	spin_unlock_irqrestore(&rocker->fdb_tbl_lock, lock_flags);
-- 
1.7.10.4
