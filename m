From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 07/12] netxen: clean up frimware version checks
Date: Sun, 26 Jul 2009 23:07:42 -0700
Message-ID: <1248674867-18821-8-git-send-email-dhananjay@netxen.com>
References: <1248674867-18821-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:33578 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751374AbZG0GHs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2009 02:07:48 -0400
In-Reply-To: <1248674867-18821-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NX2031 firmware version will never be > 4.0.0, so replace
(adapter->fw_major < 4) checks with pci revision ID check.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |    2 +-
 drivers/net/netxen/netxen_nic_ctx.c  |    6 +++---
 drivers/net/netxen/netxen_nic_hw.c   |    1 -
 drivers/net/netxen/netxen_nic_init.c |    2 +-
 drivers/net/netxen/netxen_nic_main.c |    6 +++---
 5 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index e017827..b58d0b2 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1299,7 +1299,7 @@ struct netxen_adapter {
 
 	nx_nic_intr_coalesce_t coal;
 
-	u32 fw_major;
+	u32 resv5;
 	u32 fw_version;
 	const struct firmware *fw;
 };
diff --git a/drivers/net/netxen/netxen_nic_ctx.c b/drivers/net/netxen/netxen_nic_ctx.c
index 9f8ae47..9e04696 100644
--- a/drivers/net/netxen/netxen_nic_ctx.c
+++ b/drivers/net/netxen/netxen_nic_ctx.c
@@ -647,7 +647,7 @@ int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 		}
 		rds_ring->desc_head = (struct rcv_desc *)addr;
 
-		if (adapter->fw_major < 4)
+		if (NX_IS_REVISION_P2(adapter->ahw.revision_id))
 			rds_ring->crb_rcv_producer =
 				recv_crb_registers[port].crb_rcv_producer[ring];
 	}
@@ -675,7 +675,7 @@ int netxen_alloc_hw_resources(struct netxen_adapter *adapter)
 	}
 
 
-	if (adapter->fw_major >= 4) {
+	if (!NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
 		err = nx_fw_cmd_create_rx_ctx(adapter);
 		if (err)
 			goto err_out_free;
@@ -705,7 +705,7 @@ void netxen_free_hw_resources(struct netxen_adapter *adapter)
 
 	int port = adapter->portnum;
 
-	if (adapter->fw_major >= 4) {
+	if (!NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
 		nx_fw_cmd_destroy_rx_ctx(adapter);
 		nx_fw_cmd_destroy_tx_ctx(adapter);
 	} else {
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 088611b..ddb9deb 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -2045,7 +2045,6 @@ void netxen_nic_get_firmware_info(struct netxen_adapter *adapter)
 	fw_minor = NXRD32(adapter, NETXEN_FW_VERSION_MINOR);
 	fw_build = NXRD32(adapter, NETXEN_FW_VERSION_SUB);
 
-	adapter->fw_major = fw_major;
 	adapter->fw_version = NETXEN_VERSION_CODE(fw_major, fw_minor, fw_build);
 
 	if (adapter->portnum == 0) {
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 9135845..ef7f1b1 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1477,7 +1477,7 @@ netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ringid,
 		NXWR32(adapter, rds_ring->crb_rcv_producer,
 				(producer-1) & (rds_ring->num_desc-1));
 
-		if (adapter->fw_major < 4) {
+		if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
 			/*
 			 * Write a doorbell msg to tell phanmon of change in
 			 * receive ring producer
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 3f64a10..8d4c30a 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -952,7 +952,7 @@ netxen_nic_attach(struct netxen_adapter *adapter)
 		goto err_out_free_sw;
 	}
 
-	if (adapter->fw_major < 4) {
+	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
 		tx_ring = adapter->tx_ring;
 		tx_ring->crb_cmd_producer = crb_cmd_producer[adapter->portnum];
 		tx_ring->crb_cmd_consumer = crb_cmd_consumer[adapter->portnum];
@@ -1123,7 +1123,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 * See if the firmware gave us a virtual-physical port mapping.
 	 */
 	adapter->physical_port = adapter->portnum;
-	if (adapter->fw_major < 4) {
+	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
 		i = NXRD32(adapter, CRB_V2P(adapter->portnum));
 		if (i != 0x55555555)
 			adapter->physical_port = i;
@@ -1747,7 +1747,7 @@ static irqreturn_t netxen_intr(int irq, void *data)
 	}
 
 	/* clear interrupt */
-	if (adapter->fw_major < 4)
+	if (NX_IS_REVISION_P2(adapter->ahw.revision_id))
 		netxen_nic_disable_int(sds_ring);
 
 	adapter->pci_write_immediate(adapter,
-- 
1.6.0.2

