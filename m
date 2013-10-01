From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH next 1/6] be2net: Call be_vf_setup() even when VFs are enbaled from previous load
Date: Tue, 1 Oct 2013 15:59:56 +0530
Message-ID: <1380623401-15630-2-git-send-email-sathya.perla@emulex.com>
References: <1380623401-15630-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:8676 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752017Ab3JAK00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 06:26:26 -0400
In-Reply-To: <1380623401-15630-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

Re-define the sriov_want() macro to check for number of VFs that need
to be enabled in the current load of the driver or the number of VFs that
still remain enabled from the previous load (attached VFs cannot be disabled.)

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    4 ++--
 drivers/net/ethernet/emulex/benet/be_main.c |    6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 4a0d3b7..4a540af 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -470,8 +470,8 @@ struct be_adapter {
 
 #define be_physfn(adapter)		(!adapter->virtfn)
 #define	sriov_enabled(adapter)		(adapter->num_vfs > 0)
-#define sriov_want(adapter)             (be_max_vfs(adapter) && num_vfs && \
-					 be_physfn(adapter))
+#define sriov_want(adapter)             (be_physfn(adapter) &&	\
+					 (num_vfs || pci_num_vf(adapter->pdev)))
 #define for_all_vfs(adapter, vf_cfg, i)					\
 	for (i = 0, vf_cfg = &adapter->vf_cfg[i]; i < adapter->num_vfs;	\
 		i++, vf_cfg++)
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 100b528..4cb2ac7 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2948,12 +2948,12 @@ static void BEx_get_resources(struct be_adapter *adapter,
 	struct pci_dev *pdev = adapter->pdev;
 	bool use_sriov = false;
 
-	if (BE3_chip(adapter) && be_physfn(adapter)) {
+	if (BE3_chip(adapter) && sriov_want(adapter)) {
 		int max_vfs;
 
 		max_vfs = pci_sriov_get_totalvfs(pdev);
 		res->max_vfs = max_vfs > 0 ? min(MAX_VFS, max_vfs) : 0;
-		use_sriov = res->max_vfs && num_vfs;
+		use_sriov = res->max_vfs;
 	}
 
 	if (be_physfn(adapter))
@@ -3242,7 +3242,7 @@ static int be_setup(struct be_adapter *adapter)
 		be_cmd_set_flow_control(adapter, adapter->tx_fc,
 					adapter->rx_fc);
 
-	if (be_physfn(adapter) && num_vfs) {
+	if (sriov_want(adapter)) {
 		if (be_max_vfs(adapter))
 			be_vf_setup(adapter);
 		else
-- 
1.7.1
