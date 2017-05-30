From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: FW upgrade fixes
Date: Tue, 30 May 2017 12:45:25 +0530
Message-ID: <1496128525-7881-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, Arjun Vynipadath <arjun@chelsio.com>,
        Casey Leedom <leedom@chelsio.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:14520 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750796AbdE3HPl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 03:15:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arjun Vynipadath <arjun@chelsio.com>

Disable FW_OK flags while flashing Firmware. This will help to fix any
potential mailbox timeouts during Firmware flash.

Grab new devlog parameters after Firmware restart. When we FLASH new
Firmware onto an adapter, the new Firmware may have the Firmware Device Log
located at a different memory address or have a different size for it.

Signed-off-by: Arjun Vynipadath <arjun@chelsio.com>
Signed-off-by: Casey Leedom <leedom@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 21 ++++++++++++++++++---
 1 file changed, 18 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index b97ce4a..325f98c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -6288,13 +6288,18 @@ int t4_fw_upgrade(struct adapter *adap, unsigned int mbox,
 	if (!t4_fw_matches_chip(adap, fw_hdr))
 		return -EINVAL;
 
+	/* Disable FW_OK flags so that mbox commands with FW_OK flags check
+	 * wont be send when we are flashing FW.
+	 */
+	adap->flags &= ~FW_OK;
+
 	ret = t4_fw_halt(adap, mbox, force);
 	if (ret < 0 && !force)
-		return ret;
+		goto out;
 
 	ret = t4_load_fw(adap, fw_data, size);
 	if (ret < 0)
-		return ret;
+		goto out;
 
 	/*
 	 * Older versions of the firmware don't understand the new
@@ -6305,7 +6310,17 @@ int t4_fw_upgrade(struct adapter *adap, unsigned int mbox,
 	 * its header flags to see if it advertises the capability.
 	 */
 	reset = ((be32_to_cpu(fw_hdr->flags) & FW_HDR_FLAGS_RESET_HALT) == 0);
-	return t4_fw_restart(adap, mbox, reset);
+	ret = t4_fw_restart(adap, mbox, reset);
+
+	/* Grab potentially new Firmware Device Log parameters so we can see
+	 * how healthy the new Firmware is.  It's okay to contact the new
+	 * Firmware for these parameters even though, as far as it's
+	 * concerned, we've never said "HELLO" to it ...
+	 */
+	(void)t4_init_devlog_params(adap);
+out:
+	adap->flags |= FW_OK;
+	return ret;
 }
 
 /**
-- 
2.1.0
