From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 7/7] be2net: use MCCQ instead of MBOX in be_cmd_rss_config()
Date: Fri, 9 May 2014 13:29:19 +0530
Message-ID: <1399622359-25926-8-git-send-email-sathya.perla@emulex.com>
References: <1399622359-25926-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:3302 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755214AbaEIH4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 03:56:23 -0400
In-Reply-To: <1399622359-25926-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

be_cmd_rss_config() is called after the MCCQ is created; so this cmd is
now modified to use the MCCQ instead of MBOX. Also fixed some indentation
problem in this routine.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 5b23664..476752d 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -2042,10 +2042,13 @@ int be_cmd_rss_config(struct be_adapter *adapter, u8 *rsstable,
 	if (!(be_if_cap_flags(adapter) & BE_IF_FLAGS_RSS))
 		return 0;
 
-	if (mutex_lock_interruptible(&adapter->mbox_lock))
-		return -1;
+	spin_lock_bh(&adapter->mcc_lock);
 
-	wrb = wrb_from_mbox(adapter);
+	wrb = wrb_from_mccq(adapter);
+	if (!wrb) {
+		status = -EBUSY;
+		goto err;
+	}
 	req = embedded_payload(wrb);
 
 	be_wrb_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_ETH,
@@ -2055,16 +2058,16 @@ int be_cmd_rss_config(struct be_adapter *adapter, u8 *rsstable,
 	req->enable_rss = cpu_to_le16(rss_hash_opts);
 	req->cpu_table_size_log2 = cpu_to_le16(fls(table_size) - 1);
 
-	if (lancer_chip(adapter) || skyhawk_chip(adapter))
+	if (!BEx_chip(adapter))
 		req->hdr.version = 1;
 
 	memcpy(req->cpu_table, rsstable, table_size);
 	memcpy(req->hash, rss_hkey, RSS_HASH_KEY_LEN);
 	be_dws_cpu_to_le(req->hash, sizeof(req->hash));
 
-	status = be_mbox_notify_wait(adapter);
-
-	mutex_unlock(&adapter->mbox_lock);
+	status = be_mcc_notify_wait(adapter);
+err:
+	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
 }
 
-- 
1.7.1
