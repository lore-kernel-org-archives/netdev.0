From: Sathya Perla <sathyap@serverengines.com>
Subject: [net-next-2.6 PATCH 1/5] be2net: support configuration of 64
 multicast addresses instead of 32
Date: Mon, 23 Nov 2009 13:31:10 +0530
Message-ID: <20091123080110.GA7726@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:44075 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751984AbZKWIBT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 03:01:19 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To send upto 64 addresses in the multicast-set cmd, the non-embeeded cmd format
that provides for a bigger buffer is used instead of an embedded format.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be.h      |    1 +
 drivers/net/benet/be_cmds.c |   23 ++++++++++++++---------
 drivers/net/benet/be_cmds.h |    7 +++++--
 drivers/net/benet/be_main.c |   41 +++++++++++++++++++++++++++++++++++------
 4 files changed, 55 insertions(+), 17 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 67e165c..dc7c19e 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -254,6 +254,7 @@ struct be_adapter {
 	struct vlan_group *vlan_grp;
 	u16 num_vlans;
 	u8 vlan_tag[VLAN_GROUP_ARRAY_LEN];
+	struct be_dma_mem mc_cmd_mem;
 
 	struct be_stats_obj stats;
 	/* Work queue used to perform periodic tasks like getting statistics */
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index cc75dd0..e333628 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -990,24 +990,30 @@ int be_cmd_promiscuous_config(struct be_adapter *adapter, u8 port_num, bool en)
  * (mc == NULL) => multicast promiscous
  */
 int be_cmd_multicast_set(struct be_adapter *adapter, u32 if_id,
-		struct dev_mc_list *mc_list, u32 mc_count)
+		struct dev_mc_list *mc_list, u32 mc_count,
+		struct be_dma_mem *mem)
 {
-#define BE_MAX_MC		32 /* set mcast promisc if > 32 */
 	struct be_mcc_wrb *wrb;
-	struct be_cmd_req_mcast_mac_config *req;
+	struct be_cmd_req_mcast_mac_config *req = mem->va;
+	struct be_sge *sge;
+	int status;
 
 	spin_lock_bh(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
-	req = embedded_payload(wrb);
+	sge = nonembedded_sgl(wrb);
+	memset(req, 0, sizeof(*req));
 
-	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
+	be_wrb_hdr_prepare(wrb, sizeof(*req), false, 1);
+	sge->pa_hi = cpu_to_le32(upper_32_bits(mem->dma));
+	sge->pa_lo = cpu_to_le32(mem->dma & 0xFFFFFFFF);
+	sge->len = cpu_to_le32(mem->size);
 
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 		OPCODE_COMMON_NTWK_MULTICAST_SET, sizeof(*req));
 
 	req->interface_id = if_id;
-	if (mc_list && mc_count <= BE_MAX_MC) {
+	if (mc_list) {
 		int i;
 		struct dev_mc_list *mc;
 
@@ -1019,11 +1025,10 @@ int be_cmd_multicast_set(struct be_adapter *adapter, u32 if_id,
 		req->promiscuous = 1;
 	}
 
-	be_mcc_notify_wait(adapter);
+	status = be_mcc_notify_wait(adapter);
 
 	spin_unlock_bh(&adapter->mcc_lock);
-
-	return 0;
+	return status;
 }
 
 /* Uses synchrounous mcc */
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 69dc017..711e832 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -590,6 +590,8 @@ struct be_cmd_req_promiscuous_config {
 	u16 rsvd0;
 } __packed;
 
+/******************** Multicast MAC Config *******************/
+#define BE_MAX_MC		64 /* set mcast promisc if > 64 */
 struct macaddr {
 	u8 byte[ETH_ALEN];
 };
@@ -599,7 +601,7 @@ struct be_cmd_req_mcast_mac_config {
 	u16 num_mac;
 	u8 promiscuous;
 	u8 interface_id;
-	struct macaddr mac[32];
+	struct macaddr mac[BE_MAX_MC];
 } __packed;
 
 static inline struct be_hw_stats *
@@ -828,7 +830,8 @@ extern int be_cmd_vlan_config(struct be_adapter *adapter, u32 if_id,
 extern int be_cmd_promiscuous_config(struct be_adapter *adapter,
 			u8 port_num, bool en);
 extern int be_cmd_multicast_set(struct be_adapter *adapter, u32 if_id,
-			struct dev_mc_list *mc_list, u32 mc_count);
+			struct dev_mc_list *mc_list, u32 mc_count,
+			struct be_dma_mem *mem);
 extern int be_cmd_set_flow_control(struct be_adapter *adapter,
 			u32 tx_fc, u32 rx_fc);
 extern int be_cmd_get_flow_control(struct be_adapter *adapter,
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index c0bd203..4f80c2b 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -562,13 +562,15 @@ static void be_set_multicast_list(struct net_device *netdev)
 		be_cmd_promiscuous_config(adapter, adapter->port_num, 0);
 	}
 
-	if (netdev->flags & IFF_ALLMULTI) {
-		be_cmd_multicast_set(adapter, adapter->if_handle, NULL, 0);
+	/* Enable multicast promisc if num configured exceeds what we support */
+	if (netdev->flags & IFF_ALLMULTI || netdev->mc_count > BE_MAX_MC) {
+		be_cmd_multicast_set(adapter, adapter->if_handle, NULL, 0,
+				&adapter->mc_cmd_mem);
 		goto done;
 	}
 
 	be_cmd_multicast_set(adapter, adapter->if_handle, netdev->mc_list,
-		netdev->mc_count);
+		netdev->mc_count, &adapter->mc_cmd_mem);
 done:
 	return;
 }
@@ -1978,34 +1980,61 @@ static void be_ctrl_cleanup(struct be_adapter *adapter)
 	if (mem->va)
 		pci_free_consistent(adapter->pdev, mem->size,
 			mem->va, mem->dma);
+
+	mem = &adapter->mc_cmd_mem;
+	if (mem->va)
+		pci_free_consistent(adapter->pdev, mem->size,
+			mem->va, mem->dma);
 }
 
 static int be_ctrl_init(struct be_adapter *adapter)
 {
 	struct be_dma_mem *mbox_mem_alloc = &adapter->mbox_mem_alloced;
 	struct be_dma_mem *mbox_mem_align = &adapter->mbox_mem;
+	struct be_dma_mem *mc_cmd_mem = &adapter->mc_cmd_mem;
 	int status;
 
 	status = be_map_pci_bars(adapter);
 	if (status)
-		return status;
+		goto done;
 
 	mbox_mem_alloc->size = sizeof(struct be_mcc_mailbox) + 16;
 	mbox_mem_alloc->va = pci_alloc_consistent(adapter->pdev,
 				mbox_mem_alloc->size, &mbox_mem_alloc->dma);
 	if (!mbox_mem_alloc->va) {
-		be_unmap_pci_bars(adapter);
-		return -1;
+		status = -ENOMEM;
+		goto unmap_pci_bars;
 	}
+
 	mbox_mem_align->size = sizeof(struct be_mcc_mailbox);
 	mbox_mem_align->va = PTR_ALIGN(mbox_mem_alloc->va, 16);
 	mbox_mem_align->dma = PTR_ALIGN(mbox_mem_alloc->dma, 16);
 	memset(mbox_mem_align->va, 0, sizeof(struct be_mcc_mailbox));
+
+	mc_cmd_mem->size = sizeof(struct be_cmd_req_mcast_mac_config);
+	mc_cmd_mem->va = pci_alloc_consistent(adapter->pdev, mc_cmd_mem->size,
+			&mc_cmd_mem->dma);
+	if (mc_cmd_mem->va == NULL) {
+		status = -ENOMEM;
+		goto free_mbox;
+	}
+	memset(mc_cmd_mem->va, 0, mc_cmd_mem->size);
+
 	spin_lock_init(&adapter->mbox_lock);
 	spin_lock_init(&adapter->mcc_lock);
 	spin_lock_init(&adapter->mcc_cq_lock);
 
 	return 0;
+
+free_mbox:
+	pci_free_consistent(adapter->pdev, mbox_mem_alloc->size,
+		mbox_mem_alloc->va, mbox_mem_alloc->dma);
+
+unmap_pci_bars:
+	be_unmap_pci_bars(adapter);
+
+done:
+	return status;
 }
 
 static void be_stats_cleanup(struct be_adapter *adapter)
-- 
1.6.5.2

