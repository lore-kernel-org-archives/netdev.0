From: sfeldma@gmail.com
Subject: [PATCH net-next 2/7] rocker: store rocker_port in fdb key rather than pport
Date: Fri, 18 Sep 2015 12:55:46 -0700
Message-ID: <1442606151-50429-3-git-send-email-sfeldma@gmail.com>
References: <1442606151-50429-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, siva.mannem.lnx@gmail.com, pjonnala@broadcom.com,
	stephen@networkplumber.org, roopa@cumulusnetworks.com,
	andrew@lunn.ch, f.fainelli@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34758 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753338AbbIRTxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 15:53:08 -0400
Received: by padhy16 with SMTP id hy16so59088996pad.1
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 12:53:08 -0700 (PDT)
In-Reply-To: <1442606151-50429-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

We'll need more info from rocker_port than just pport when we age out fdb
entries, so store rocker_port rather than pport in each fdb entry.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index e517e9c..f55ed2c 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -154,7 +154,7 @@ struct rocker_fdb_tbl_entry {
 	bool learned;
 	unsigned long touched;
 	struct rocker_fdb_tbl_key {
-		u32 pport;
+		struct rocker_port *rocker_port;
 		u8 addr[ETH_ALEN];
 		__be16 vlan_id;
 	} key;
@@ -3631,7 +3631,7 @@ static int rocker_port_fdb(struct rocker_port *rocker_port,
 
 	fdb->learned = (flags & ROCKER_OP_FLAG_LEARNED);
 	fdb->touched = jiffies;
-	fdb->key.pport = rocker_port->pport;
+	fdb->key.rocker_port = rocker_port;
 	ether_addr_copy(fdb->key.addr, addr);
 	fdb->key.vlan_id = vlan_id;
 	fdb->key_crc32 = crc32(~0, &fdb->key, sizeof(fdb->key));
@@ -3686,7 +3686,7 @@ static int rocker_port_fdb_flush(struct rocker_port *rocker_port,
 	spin_lock_irqsave(&rocker->fdb_tbl_lock, lock_flags);
 
 	hash_for_each_safe(rocker->fdb_tbl, bkt, tmp, found, entry) {
-		if (found->key.pport != rocker_port->pport)
+		if (found->key.rocker_port != rocker_port)
 			continue;
 		if (!found->learned)
 			continue;
@@ -4553,7 +4553,7 @@ static int rocker_port_fdb_dump(const struct rocker_port *rocker_port,
 
 	spin_lock_irqsave(&rocker->fdb_tbl_lock, lock_flags);
 	hash_for_each_safe(rocker->fdb_tbl, bkt, tmp, found, entry) {
-		if (found->key.pport != rocker_port->pport)
+		if (found->key.rocker_port != rocker_port)
 			continue;
 		fdb->addr = found->key.addr;
 		fdb->ndm_state = NUD_REACHABLE;
-- 
1.7.10.4
