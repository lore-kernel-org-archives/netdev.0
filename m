From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next] be2net: remove BUG_ON() in be_mcc_compl_is_new()
Date: Wed, 13 Feb 2013 14:35:19 +0530
Message-ID: <df52a8ca-fbd1-41aa-ad6f-995fd724a4d4@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:38154 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752226Ab3BMJCp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 04:02:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code expects that the last word (with valid bit)
of an MCC compl is DMAed in one shot. This may not be the case.
Remove this assertion.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 8b04880..071aea7 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -93,13 +93,16 @@ static void be_mcc_notify(struct be_adapter *adapter)
  * little endian) */
 static inline bool be_mcc_compl_is_new(struct be_mcc_compl *compl)
 {
+	u32 flags;
+
 	if (compl->flags != 0) {
-		compl->flags = le32_to_cpu(compl->flags);
-		BUG_ON((compl->flags & CQE_FLAGS_VALID_MASK) == 0);
-		return true;
-	} else {
-		return false;
+		flags = le32_to_cpu(compl->flags);
+		if (flags & CQE_FLAGS_VALID_MASK) {
+			compl->flags = flags;
+			return true;
+		}
 	}
+	return false;
 }
 
 /* Need to reset the entire word that houses the valid bit */
-- 
1.7.1
