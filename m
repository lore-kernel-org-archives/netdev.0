From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 04/10] netxen: defer firmware handshake
Date: Sun,  5 Apr 2009 23:27:54 -0700
Message-ID: <1238999280-8114-5-git-send-email-dhananjay@netxen.com>
References: <1238999280-8114-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:50774 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752415AbZDFG2E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Apr 2009 02:28:04 -0400
In-Reply-To: <1238999280-8114-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removed duplicate firmware handshake, defer it until first
port (interface) is brought up.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |    1 -
 drivers/net/netxen/netxen_nic_init.c |   59 ++++++++++++---------------------
 drivers/net/netxen/netxen_nic_main.c |    4 --
 3 files changed, 22 insertions(+), 42 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 2aa658d..7e208b3 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1359,7 +1359,6 @@ unsigned long netxen_nic_pci_set_window_2M(struct netxen_adapter *adapter,
 void netxen_free_adapter_offload(struct netxen_adapter *adapter);
 int netxen_initialize_adapter_offload(struct netxen_adapter *adapter);
 int netxen_phantom_init(struct netxen_adapter *adapter, int pegtune_val);
-int netxen_receive_peg_ready(struct netxen_adapter *adapter);
 int netxen_load_firmware(struct netxen_adapter *adapter);
 int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose);
 
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 8e45dcc..9991951 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -108,42 +108,6 @@ static void crb_addr_transform_setup(void)
 	crb_addr_transform(I2C0);
 }
 
-int netxen_init_firmware(struct netxen_adapter *adapter)
-{
-	u32 state = 0, loops = 0, err = 0;
-
-	/* Window 1 call */
-	state = adapter->pci_read_normalize(adapter, CRB_CMDPEG_STATE);
-
-	if (state == PHAN_INITIALIZE_ACK)
-		return 0;
-
-	while (state != PHAN_INITIALIZE_COMPLETE && loops < 2000) {
-		msleep(1);
-		/* Window 1 call */
-		state = adapter->pci_read_normalize(adapter, CRB_CMDPEG_STATE);
-
-		loops++;
-	}
-	if (loops >= 2000) {
-		printk(KERN_ERR "Cmd Peg initialization not complete:%x.\n",
-		       state);
-		err = -EIO;
-		return err;
-	}
-	/* Window 1 call */
-	adapter->pci_write_normalize(adapter,
-			CRB_NIC_CAPABILITIES_HOST, INTR_SCHEME_PERPORT);
-	adapter->pci_write_normalize(adapter,
-			CRB_NIC_MSI_MODE_HOST, MSI_MODE_MULTIFUNC);
-	adapter->pci_write_normalize(adapter,
-			CRB_MPORT_MODE, MPORT_MULTI_FUNCTION_MODE);
-	adapter->pci_write_normalize(adapter,
-			CRB_CMDPEG_STATE, PHAN_INITIALIZE_ACK);
-
-	return err;
-}
-
 void netxen_release_rx_buffers(struct netxen_adapter *adapter)
 {
 	struct netxen_recv_context *recv_ctx;
@@ -789,7 +753,8 @@ int netxen_phantom_init(struct netxen_adapter *adapter, int pegtune_val)
 	return 0;
 }
 
-int netxen_receive_peg_ready(struct netxen_adapter *adapter)
+static int
+netxen_receive_peg_ready(struct netxen_adapter *adapter)
 {
 	u32 val = 0;
 	int retries = 2000;
@@ -813,6 +778,26 @@ int netxen_receive_peg_ready(struct netxen_adapter *adapter)
 	return 0;
 }
 
+int netxen_init_firmware(struct netxen_adapter *adapter)
+{
+	int err;
+
+	err = netxen_receive_peg_ready(adapter);
+	if (err)
+		return err;
+
+	adapter->pci_write_normalize(adapter,
+			CRB_NIC_CAPABILITIES_HOST, INTR_SCHEME_PERPORT);
+	adapter->pci_write_normalize(adapter,
+			CRB_NIC_MSI_MODE_HOST, MSI_MODE_MULTIFUNC);
+	adapter->pci_write_normalize(adapter,
+			CRB_MPORT_MODE, MPORT_MULTI_FUNCTION_MODE);
+	adapter->pci_write_normalize(adapter,
+			CRB_CMDPEG_STATE, PHAN_INITIALIZE_ACK);
+
+	return err;
+}
+
 static int
 netxen_alloc_rx_skb(struct netxen_adapter *adapter,
 		struct nx_host_rds_ring *rds_ring,
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 5599da3..f3fbe11 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1027,10 +1027,6 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	netxen_napi_add(adapter, netdev);
 
-	err = netxen_receive_peg_ready(adapter);
-	if (err)
-		goto err_out_disable_msi;
-
 	init_timer(&adapter->watchdog_timer);
 	adapter->watchdog_timer.function = &netxen_watchdog;
 	adapter->watchdog_timer.data = (unsigned long)adapter;
-- 
1.6.0.2

