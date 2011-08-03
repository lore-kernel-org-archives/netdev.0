From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 4/6] be2net: use RX_FILTER cmd to program multicast addresses
Date: Wed, 3 Aug 2011 11:27:44 +0530
Message-ID: <1312351066-16745-5-git-send-email-sathya.perla@emulex.com>
References: <1312351066-16745-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:24506 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754400Ab1HCF4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 01:56:31 -0400
In-Reply-To: <1312351066-16745-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use this cmd for both promiscous and multicast address programming. Get rid
of the old MULTICAST_SET cmd.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/benet/be.h      |    4 +-
 drivers/net/benet/be_cmds.c |  103 +++++++++---------------------------------
 drivers/net/benet/be_cmds.h |   20 ++-------
 drivers/net/benet/be_main.c |   28 +++++-------
 4 files changed, 41 insertions(+), 114 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 8d897d1..1e7f009 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -334,7 +334,7 @@ struct be_adapter {
 	u8 vlan_tag[VLAN_N_VID];
 	u8 vlan_prio_bmap;	/* Available Priority BitMap */
 	u16 recommended_prio;	/* Recommended Priority */
-	struct be_dma_mem mc_cmd_mem;
+	struct be_dma_mem rx_filter; /* Cmd DMA mem for rx-filter */
 
 	struct be_dma_mem stats_cmd;
 	/* Work queue used to perform periodic tasks like getting statistics */
@@ -381,6 +381,8 @@ struct be_adapter {
 #define BE_GEN2 2
 #define BE_GEN3 3
 
+#define ON				1
+#define OFF				0
 #define lancer_chip(adapter)	((adapter->pdev->device == OC_DEVICE_ID3) || \
 				 (adapter->pdev->device == OC_DEVICE_ID4))
 
diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 73fd949..f138fbb 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1548,72 +1548,11 @@ err:
 	return status;
 }
 
-/* Uses MCC for this command as it may be called in BH context
- * Uses synchronous mcc
- */
-int be_cmd_promiscuous_config(struct be_adapter *adapter, bool en)
-{
-	struct be_mcc_wrb *wrb;
-	struct be_cmd_req_rx_filter *req;
-	struct be_dma_mem promiscous_cmd;
-	struct be_sge *sge;
-	int status;
-
-	memset(&promiscous_cmd, 0, sizeof(struct be_dma_mem));
-	promiscous_cmd.size = sizeof(struct be_cmd_req_rx_filter);
-	promiscous_cmd.va = pci_alloc_consistent(adapter->pdev,
-				promiscous_cmd.size, &promiscous_cmd.dma);
-	if (!promiscous_cmd.va) {
-		dev_err(&adapter->pdev->dev,
-				"Memory allocation failure\n");
-		return -ENOMEM;
-	}
-
-	spin_lock_bh(&adapter->mcc_lock);
-
-	wrb = wrb_from_mccq(adapter);
-	if (!wrb) {
-		status = -EBUSY;
-		goto err;
-	}
-
-	req = promiscous_cmd.va;
-	sge = nonembedded_sgl(wrb);
-
-	be_wrb_hdr_prepare(wrb, sizeof(*req), false, 1,
-					OPCODE_COMMON_NTWK_RX_FILTER);
-	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-			OPCODE_COMMON_NTWK_RX_FILTER, sizeof(*req));
-
-	req->if_id = cpu_to_le32(adapter->if_handle);
-	req->if_flags_mask = cpu_to_le32(BE_IF_FLAGS_PROMISCUOUS
-				| BE_IF_FLAGS_VLAN_PROMISCUOUS);
-	if (en)
-		req->if_flags = cpu_to_le32(BE_IF_FLAGS_PROMISCUOUS
-				| BE_IF_FLAGS_VLAN_PROMISCUOUS);
-
-	sge->pa_hi = cpu_to_le32(upper_32_bits(promiscous_cmd.dma));
-	sge->pa_lo = cpu_to_le32(promiscous_cmd.dma & 0xFFFFFFFF);
-	sge->len = cpu_to_le32(promiscous_cmd.size);
-
-	status = be_mcc_notify_wait(adapter);
-
-err:
-	spin_unlock_bh(&adapter->mcc_lock);
-	pci_free_consistent(adapter->pdev, promiscous_cmd.size,
-			promiscous_cmd.va, promiscous_cmd.dma);
-	return status;
-}
-
-/*
- * Uses MCC for this command as it may be called in BH context
- * (mc == NULL) => multicast promiscuous
- */
-int be_cmd_multicast_set(struct be_adapter *adapter, u32 if_id,
-		struct net_device *netdev, struct be_dma_mem *mem)
+int be_cmd_rx_filter(struct be_adapter *adapter, u32 flags, u32 value)
 {
 	struct be_mcc_wrb *wrb;
-	struct be_cmd_req_mcast_mac_config *req = mem->va;
+	struct be_dma_mem *mem = &adapter->rx_filter;
+	struct be_cmd_req_rx_filter *req = mem->va;
 	struct be_sge *sge;
 	int status;
 
@@ -1625,33 +1564,35 @@ int be_cmd_multicast_set(struct be_adapter *adapter, u32 if_id,
 		goto err;
 	}
 	sge = nonembedded_sgl(wrb);
-	memset(req, 0, sizeof(*req));
-
-	be_wrb_hdr_prepare(wrb, sizeof(*req), false, 1,
-			OPCODE_COMMON_NTWK_MULTICAST_SET);
 	sge->pa_hi = cpu_to_le32(upper_32_bits(mem->dma));
 	sge->pa_lo = cpu_to_le32(mem->dma & 0xFFFFFFFF);
 	sge->len = cpu_to_le32(mem->size);
+	be_wrb_hdr_prepare(wrb, sizeof(*req), false, 1,
+				OPCODE_COMMON_NTWK_RX_FILTER);
 
+	memset(req, 0, sizeof(*req));
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-		OPCODE_COMMON_NTWK_MULTICAST_SET, sizeof(*req));
+				OPCODE_COMMON_NTWK_RX_FILTER, sizeof(*req));
 
-	req->interface_id = if_id;
-	if (netdev) {
-		int i;
+	req->if_id = cpu_to_le32(adapter->if_handle);
+	if (flags & IFF_PROMISC) {
+		req->if_flags_mask = cpu_to_le32(BE_IF_FLAGS_PROMISCUOUS |
+					BE_IF_FLAGS_VLAN_PROMISCUOUS);
+		if (value == ON)
+			req->if_flags = cpu_to_le32(BE_IF_FLAGS_PROMISCUOUS |
+					BE_IF_FLAGS_VLAN_PROMISCUOUS);
+	} else if (flags & IFF_ALLMULTI) {
+		req->if_flags_mask = req->if_flags =
+			cpu_to_le32(BE_IF_FLAGS_MCAST_PROMISCUOUS);
+	} else {
 		struct netdev_hw_addr *ha;
+		int i = 0;
 
-		req->num_mac = cpu_to_le16(netdev_mc_count(netdev));
-
-		i = 0;
-		netdev_for_each_mc_addr(ha, netdev)
-			memcpy(req->mac[i++].byte, ha->addr, ETH_ALEN);
-	} else {
-		req->promiscuous = 1;
+		req->mcast_num = cpu_to_le16(netdev_mc_count(adapter->netdev));
+		netdev_for_each_mc_addr(ha, adapter->netdev)
+			memcpy(req->mcast_mac[i++].byte, ha->addr, ETH_ALEN);
 	}
 
-	status = be_mcc_notify_wait(adapter);
-
 err:
 	spin_unlock_bh(&adapter->mcc_lock);
 	return status;
diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 6db545f..008bfae9 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -910,21 +910,12 @@ struct be_cmd_req_vlan_config {
 	u16 normal_vlan[64];
 } __packed;
 
-/******************** Multicast MAC Config *******************/
+/******************* RX FILTER ******************************/
 #define BE_MAX_MC		64 /* set mcast promisc if > 64 */
 struct macaddr {
 	u8 byte[ETH_ALEN];
 };
 
-struct be_cmd_req_mcast_mac_config {
-	struct be_cmd_req_hdr hdr;
-	u16 num_mac;
-	u8 promiscuous;
-	u8 interface_id;
-	struct macaddr mac[BE_MAX_MC];
-} __packed;
-
-/******************* RX FILTER ******************************/
 struct be_cmd_req_rx_filter {
 	struct be_cmd_req_hdr hdr;
 	u32 global_flags_mask;
@@ -932,11 +923,10 @@ struct be_cmd_req_rx_filter {
 	u32 if_flags_mask;
 	u32 if_flags;
 	u32 if_id;
-	u32 multicast_num;
-	struct macaddr mac[BE_MAX_MC];
+	u32 mcast_num;
+	struct macaddr mcast_mac[BE_MAX_MC];
 };
 
-
 /******************** Link Status Query *******************/
 struct be_cmd_req_link_status {
 	struct be_cmd_req_hdr hdr;
@@ -1455,9 +1445,7 @@ extern int be_cmd_modify_eqd(struct be_adapter *adapter, u32 eq_id, u32 eqd);
 extern int be_cmd_vlan_config(struct be_adapter *adapter, u32 if_id,
 			u16 *vtag_array, u32 num, bool untagged,
 			bool promiscuous);
-extern int be_cmd_promiscuous_config(struct be_adapter *adapter, bool en);
-extern int be_cmd_multicast_set(struct be_adapter *adapter, u32 if_id,
-			struct net_device *netdev, struct be_dma_mem *mem);
+extern int be_cmd_rx_filter(struct be_adapter *adapter, u32 flags, u32 status);
 extern int be_cmd_set_flow_control(struct be_adapter *adapter,
 			u32 tx_fc, u32 rx_fc);
 extern int be_cmd_get_flow_control(struct be_adapter *adapter,
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 32a5b11..5890bca 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -782,7 +782,7 @@ static void be_set_multicast_list(struct net_device *netdev)
 	struct be_adapter *adapter = netdev_priv(netdev);
 
 	if (netdev->flags & IFF_PROMISC) {
-		be_cmd_promiscuous_config(adapter, true);
+		be_cmd_rx_filter(adapter, IFF_PROMISC, ON);
 		adapter->promiscuous = true;
 		goto done;
 	}
@@ -790,7 +790,7 @@ static void be_set_multicast_list(struct net_device *netdev)
 	/* BE was previously in promiscuous mode; disable it */
 	if (adapter->promiscuous) {
 		adapter->promiscuous = false;
-		be_cmd_promiscuous_config(adapter, false);
+		be_cmd_rx_filter(adapter, IFF_PROMISC, OFF);
 
 		if (adapter->vlans_added)
 			be_vid_config(adapter, false, 0);
@@ -798,14 +798,12 @@ static void be_set_multicast_list(struct net_device *netdev)
 
 	/* Enable multicast promisc if num configured exceeds what we support */
 	if (netdev->flags & IFF_ALLMULTI ||
-	    netdev_mc_count(netdev) > BE_MAX_MC) {
-		be_cmd_multicast_set(adapter, adapter->if_handle, NULL,
-				&adapter->mc_cmd_mem);
+			netdev_mc_count(netdev) > BE_MAX_MC) {
+		be_cmd_rx_filter(adapter, IFF_ALLMULTI, ON);
 		goto done;
 	}
 
-	be_cmd_multicast_set(adapter, adapter->if_handle, netdev,
-		&adapter->mc_cmd_mem);
+	be_cmd_rx_filter(adapter, IFF_MULTICAST, ON);
 done:
 	return;
 }
@@ -2976,7 +2974,7 @@ static void be_ctrl_cleanup(struct be_adapter *adapter)
 		dma_free_coherent(&adapter->pdev->dev, mem->size, mem->va,
 				  mem->dma);
 
-	mem = &adapter->mc_cmd_mem;
+	mem = &adapter->rx_filter;
 	if (mem->va)
 		dma_free_coherent(&adapter->pdev->dev, mem->size, mem->va,
 				  mem->dma);
@@ -2986,7 +2984,7 @@ static int be_ctrl_init(struct be_adapter *adapter)
 {
 	struct be_dma_mem *mbox_mem_alloc = &adapter->mbox_mem_alloced;
 	struct be_dma_mem *mbox_mem_align = &adapter->mbox_mem;
-	struct be_dma_mem *mc_cmd_mem = &adapter->mc_cmd_mem;
+	struct be_dma_mem *rx_filter = &adapter->rx_filter;
 	int status;
 
 	status = be_map_pci_bars(adapter);
@@ -3002,21 +3000,19 @@ static int be_ctrl_init(struct be_adapter *adapter)
 		status = -ENOMEM;
 		goto unmap_pci_bars;
 	}
-
 	mbox_mem_align->size = sizeof(struct be_mcc_mailbox);
 	mbox_mem_align->va = PTR_ALIGN(mbox_mem_alloc->va, 16);
 	mbox_mem_align->dma = PTR_ALIGN(mbox_mem_alloc->dma, 16);
 	memset(mbox_mem_align->va, 0, sizeof(struct be_mcc_mailbox));
 
-	mc_cmd_mem->size = sizeof(struct be_cmd_req_mcast_mac_config);
-	mc_cmd_mem->va = dma_alloc_coherent(&adapter->pdev->dev,
-					    mc_cmd_mem->size, &mc_cmd_mem->dma,
-					    GFP_KERNEL);
-	if (mc_cmd_mem->va == NULL) {
+	rx_filter->size = sizeof(struct be_cmd_req_rx_filter);
+	rx_filter->va = dma_alloc_coherent(&adapter->pdev->dev, rx_filter->size,
+					&rx_filter->dma, GFP_KERNEL);
+	if (rx_filter->va == NULL) {
 		status = -ENOMEM;
 		goto free_mbox;
 	}
-	memset(mc_cmd_mem->va, 0, mc_cmd_mem->size);
+	memset(rx_filter->va, 0, rx_filter->size);
 
 	mutex_init(&adapter->mbox_lock);
 	spin_lock_init(&adapter->mcc_lock);
-- 
1.7.4

