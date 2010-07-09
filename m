From: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Subject: [PATCH net-next-2.6] be2net: Patch to determine if function is VF
 while running in guest OS.
Date: Fri, 9 Jul 2010 17:13:55 +0530
Message-ID: <20100709114344.GA2392@serverengines.com>
Reply-To: Sarveshwar Bandi <sarveshwarb@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:40483 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753849Ab0GILn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 07:43:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When driver is loaded in guest OS, the pci variables is_virtfn and is_physfn are
both set to 0. This change uses registers in controller to determine the same.

Signed-off-by: Sarveshwar Bandi <sarveshwarb@serverengines.com>
---
 drivers/net/benet/be.h      |   12 +++++++++++-
 drivers/net/benet/be_main.c |    1 +
 2 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 1a0d2d0..f17428c 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -291,9 +291,10 @@ struct be_adapter {
 	u32 vf_if_handle[BE_MAX_VF];
 	u32 vf_pmac_id[BE_MAX_VF];
 	u8 base_eq_id;
+	u8 is_virtfn;
 };
 
-#define be_physfn(adapter) (!adapter->pdev->is_virtfn)
+#define be_physfn(adapter) (!adapter->is_virtfn)
 
 /* BladeEngine Generation numbers */
 #define BE_GEN2 2
@@ -393,6 +394,15 @@ static inline u8 is_udp_pkt(struct sk_bu
 	return val;
 }
 
+static inline void be_check_sriov_fn_type(struct be_adapter *adapter)
+{
+	u8 data;
+
+	pci_write_config_byte(adapter->pdev, 0xFE, 0xAA);
+	pci_read_config_byte(adapter->pdev, 0xFE, &data);
+	adapter->is_virtfn = (data != 0xAA);
+}
+
 extern void be_cq_notify(struct be_adapter *adapter, u16 qid, bool arm,
 		u16 num_popped);
 extern void be_link_status_update(struct be_adapter *adapter, bool link_up);
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index b636879..e6ca923 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1631,6 +1631,7 @@ static void be_sriov_enable(struct be_ad
 {
 #ifdef CONFIG_PCI_IOV
 	int status;
+	be_check_sriov_fn_type(adapter);
 	if (be_physfn(adapter) && num_vfs) {
 		status = pci_enable_sriov(adapter->pdev, num_vfs);
 		adapter->sriov_enabled = status ? false : true;
-- 
1.4.0

