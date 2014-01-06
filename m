From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH 3/3] be2net: fix max_evt_qs calculation for BE3 in SR-IOV config
Date: Mon, 6 Jan 2014 13:02:25 +0530
Message-ID: <1388993545-25634-4-git-send-email-sathya.perla@emulex.com>
References: <1388993545-25634-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:19013 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751457AbaAFH2g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 02:28:36 -0500
In-Reply-To: <1388993545-25634-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <suresh.reddy@emulex.com>

The driver wrongly assumes 16 EQs/vectors are available for each BE3 PF.
When SR-IOV is enabled, a BE3 PF can support only a max of 8 EQs.

Signed-off-by: Suresh Reddy <suresh.reddy@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    1 +
 drivers/net/ethernet/emulex/benet/be_main.c |   12 ++++++++----
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 2e031f2..4ccaf9a 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -104,6 +104,7 @@ static inline char *nic_name(struct pci_dev *pdev)
 #define BE3_MAX_RSS_QS		16
 #define BE3_MAX_TX_QS		16
 #define BE3_MAX_EVT_QS		16
+#define BE3_SRIOV_MAX_EVT_QS	8
 
 #define MAX_RX_QS		32
 #define MAX_EVT_QS		32
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index fa44bba..bf40fda 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3127,11 +3127,11 @@ static void BEx_get_resources(struct be_adapter *adapter,
 {
 	struct pci_dev *pdev = adapter->pdev;
 	bool use_sriov = false;
+	int max_vfs;
 
-	if (BE3_chip(adapter) && sriov_want(adapter)) {
-		int max_vfs;
+	max_vfs = pci_sriov_get_totalvfs(pdev);
 
-		max_vfs = pci_sriov_get_totalvfs(pdev);
+	if (BE3_chip(adapter) && sriov_want(adapter)) {
 		res->max_vfs = max_vfs > 0 ? min(MAX_VFS, max_vfs) : 0;
 		use_sriov = res->max_vfs;
 	}
@@ -3162,7 +3162,11 @@ static void BEx_get_resources(struct be_adapter *adapter,
 					   BE3_MAX_RSS_QS : BE2_MAX_RSS_QS;
 	res->max_rx_qs = res->max_rss_qs + 1;
 
-	res->max_evt_qs = be_physfn(adapter) ? BE3_MAX_EVT_QS : 1;
+	if (be_physfn(adapter))
+		res->max_evt_qs = (max_vfs > 0) ?
+					BE3_SRIOV_MAX_EVT_QS : BE3_MAX_EVT_QS;
+	else
+		res->max_evt_qs = 1;
 
 	res->if_cap_flags = BE_IF_CAP_FLAGS_WANT;
 	if (!(adapter->function_caps & BE_FUNCTION_CAPS_RSS))
-- 
1.7.1
