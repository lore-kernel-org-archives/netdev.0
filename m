From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net] be2net: fix qnq mode detection on VFs
Date: Mon, 23 Jun 2014 16:41:29 +0530
Message-ID: <1403521889-8048-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:16377 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308AbaFWLIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 07:08:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <suresh.reddy@emulex.com>

The driver (on PF or VF) needs to detect if the function is in qnq mode for
a HW hack in be_rx_compl_get() to work.

The driver queries this information using the GET_PROFILE_CONFIG cmd
(since the commit below can caused this regression.) But this cmd is not
available on VFs and so the VFs fail to detect qnq mode. This causes
vlan traffic to not work.

The fix is to use the the adapter->function_mode value queried via
QUERY_FIRMWARE_CONFIG cmd on both PFs and VFs to detect the qnq mode.

Also QNQ_MODE was incorrectly named FLEX10_MODE; correcting that too as the
fix reads much better with the name change.

Fixes: f93f160b5 ("refactor multi-channel config code for Skyhawk-R chip")

Signed-off-by: Suresh Reddy <Suresh.Reddy@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    4 +---
 drivers/net/ethernet/emulex/benet/be_cmds.h |    2 +-
 drivers/net/ethernet/emulex/benet/be_main.c |    4 ++--
 3 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 2e7c555..c2f5d2d 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -557,9 +557,7 @@ static inline u16 be_max_qs(struct be_adapter *adapter)
 #define be_pvid_tagging_enabled(adapter)	(adapter->pvid)
 
 /* Is BE in QNQ multi-channel mode */
-#define be_is_qnq_mode(adapter)		(adapter->mc_type == FLEX10 ||  \
-					 adapter->mc_type == vNIC1 ||	\
-					 adapter->mc_type == UFP)
+#define be_is_qnq_mode(adapter)		(adapter->function_mode & QNQ_MODE)
 
 #define lancer_chip(adapter)	(adapter->pdev->device == OC_DEVICE_ID3 || \
 				 adapter->pdev->device == OC_DEVICE_ID4)
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 3e0a6b2..59b3c05 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1091,7 +1091,7 @@ struct be_cmd_resp_modify_eq_delay {
  * based on the skew/IPL.
  */
 #define RDMA_ENABLED				0x4
-#define FLEX10_MODE				0x400
+#define QNQ_MODE				0x400
 #define VNIC_MODE				0x20000
 #define UMC_ENABLED				0x1000000
 struct be_cmd_req_query_fw_cfg {
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 6822b3d..34a26e4 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3254,9 +3254,9 @@ err:
 
 static u8 be_convert_mc_type(u32 function_mode)
 {
-	if (function_mode & VNIC_MODE && function_mode & FLEX10_MODE)
+	if (function_mode & VNIC_MODE && function_mode & QNQ_MODE)
 		return vNIC1;
-	else if (function_mode & FLEX10_MODE)
+	else if (function_mode & QNQ_MODE)
 		return FLEX10;
 	else if (function_mode & VNIC_MODE)
 		return vNIC2;
-- 
1.7.1
