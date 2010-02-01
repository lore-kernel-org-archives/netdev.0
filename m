From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 6/7] qlcnic: add interrupt diagnostic test
Date: Mon,  1 Feb 2010 06:30:43 -0800
Message-ID: <1265034644-19461-7-git-send-email-amit.salecha@qlogic.com>
References: <1265034644-19461-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com,
	ameen.rahman@qlogic.com,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:9788 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754721Ab0BAOaq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Feb 2010 09:30:46 -0500
In-Reply-To: <1265034644-19461-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Interrupt test (offline) added in ethtool self test.
Register a temporary interrupt handler and then send command to fw
to raise an interrupt.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h         |   11 +++-
 drivers/net/qlcnic/qlcnic_ctx.c     |    2 +-
 drivers/net/qlcnic/qlcnic_ethtool.c |   41 ++++++++++++-
 drivers/net/qlcnic/qlcnic_main.c    |  112 +++++++++++++++++++++++++++++++---
 4 files changed, 152 insertions(+), 14 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 2fc710f..b19be26 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -896,6 +896,8 @@ struct qlcnic_mac_req {
 #define __QLCNIC_RESETTING		2
 #define __QLCNIC_START_FW 		4
 
+#define QLCNIC_INTERRUPT_TEST		1
+
 struct qlcnic_adapter {
 	struct qlcnic_hardware_context ahw;
 
@@ -948,9 +950,10 @@ struct qlcnic_adapter {
 	u32 heartbit;
 
 	u8 dev_state;
+	u8 diag_test;
+	u8 diag_cnt;
 	u8 rsrd1;
-	u32 rsrd2;
-
+	u16 rsrd2;
 
 	u8 mac_addr[ETH_ALEN];
 
@@ -1066,6 +1069,10 @@ int qlcnic_get_mac_addr(struct qlcnic_adapter *adapter, u64 *mac);
 
 /* Functions from qlcnic_main.c */
 int qlcnic_reset_context(struct qlcnic_adapter *);
+u32 qlcnic_issue_cmd(struct qlcnic_adapter *adapter,
+	u32 pci_fn, u32 version, u32 arg1, u32 arg2, u32 arg3, u32 cmd);
+void qlcnic_diag_free_res(struct net_device *netdev, int max_sds_rings);
+int qlcnic_diag_alloc_res(struct net_device *netdev, int test);
 
 /*
  * QLOGIC Board information
diff --git a/drivers/net/qlcnic/qlcnic_ctx.c b/drivers/net/qlcnic/qlcnic_ctx.c
index 510edc5..0a6a399 100644
--- a/drivers/net/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/qlcnic/qlcnic_ctx.c
@@ -43,7 +43,7 @@ qlcnic_poll_rsp(struct qlcnic_adapter *adapter)
 	return rsp;
 }
 
-static u32
+u32
 qlcnic_issue_cmd(struct qlcnic_adapter *adapter,
 	u32 pci_fn, u32 version, u32 arg1, u32 arg2, u32 arg3, u32 cmd)
 {
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index 5be4c8b..3aafcdd 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -66,7 +66,8 @@ static const struct qlcnic_stats qlcnic_gstrings_stats[] = {
 static const char qlcnic_gstrings_test[][ETH_GSTRING_LEN] = {
 	"Register_Test_on_offline",
 	"Link_Test_on_offline",
-	"LED_Test_on_offline"
+	"LED_Test_on_offline",
+	"Interrupt_Test_offline"
 };
 
 #define QLCNIC_TEST_LEN	ARRAY_SIZE(qlcnic_gstrings_test)
@@ -614,6 +615,38 @@ static int qlcnic_get_sset_count(struct net_device *dev, int sset)
 	}
 }
 
+static int qlcnic_irq_test(struct net_device *netdev)
+{
+	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+	int max_sds_rings = adapter->max_sds_rings;
+	int ret;
+
+	if (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
+		return -EIO;
+
+	ret = qlcnic_diag_alloc_res(netdev, QLCNIC_INTERRUPT_TEST);
+	if (ret)
+		goto clear_it;
+
+	adapter->diag_cnt = 0;
+	ret = qlcnic_issue_cmd(adapter, adapter->ahw.pci_func,
+			QLCHAL_VERSION, adapter->portnum, 0, 0, 0x00000011);
+	if (ret)
+		goto done;
+
+	msleep(10);
+
+	ret = !adapter->diag_cnt;
+
+done:
+	qlcnic_diag_free_res(netdev, max_sds_rings);
+
+clear_it:
+	adapter->max_sds_rings = max_sds_rings;
+	clear_bit(__QLCNIC_RESETTING, &adapter->state);
+	return ret;
+}
+
 static void
 qlcnic_diag_test(struct net_device *dev, struct ethtool_test *eth_test,
 		     u64 *data)
@@ -622,6 +655,12 @@ qlcnic_diag_test(struct net_device *dev, struct ethtool_test *eth_test,
 
 	memset(data, 0, sizeof(u64) * QLCNIC_TEST_LEN);
 
+	if (eth_test->flags == ETH_TEST_FL_OFFLINE) {
+		data[3] = qlcnic_irq_test(dev);
+		if (data[3])
+			eth_test->flags |= ETH_TEST_FL_FAILED;
+	}
+
 	data[0] = qlcnic_reg_test(dev);
 	if (data[0])
 		eth_test->flags |= ETH_TEST_FL_FAILED;
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 7259adc..a8b0712 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -88,6 +88,7 @@ static void qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter);
 static void qlcnic_clr_all_drv_state(struct qlcnic_adapter *adapter);
 static int qlcnic_can_start_firmware(struct qlcnic_adapter *adapter);
 
+static irqreturn_t qlcnic_tmp_intr(int irq, void *data);
 static irqreturn_t qlcnic_intr(int irq, void *data);
 static irqreturn_t qlcnic_msi_intr(int irq, void *data);
 static irqreturn_t qlcnic_msix_intr(int irq, void *data);
@@ -720,13 +721,20 @@ qlcnic_request_irq(struct qlcnic_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	struct qlcnic_recv_context *recv_ctx = &adapter->recv_ctx;
 
-	if (adapter->flags & QLCNIC_MSIX_ENABLED)
-		handler = qlcnic_msix_intr;
-	else if (adapter->flags & QLCNIC_MSI_ENABLED)
-		handler = qlcnic_msi_intr;
-	else {
-		flags |= IRQF_SHARED;
-		handler = qlcnic_intr;
+	if (adapter->diag_test == QLCNIC_INTERRUPT_TEST) {
+		handler = qlcnic_tmp_intr;
+		if (!QLCNIC_IS_MSI_FAMILY(adapter))
+			flags |= IRQF_SHARED;
+
+	} else {
+		if (adapter->flags & QLCNIC_MSIX_ENABLED)
+			handler = qlcnic_msix_intr;
+		else if (adapter->flags & QLCNIC_MSI_ENABLED)
+			handler = qlcnic_msi_intr;
+		else {
+			flags |= IRQF_SHARED;
+			handler = qlcnic_intr;
+		}
 	}
 	adapter->irq = netdev->irq;
 
@@ -923,6 +931,60 @@ qlcnic_detach(struct qlcnic_adapter *adapter)
 	adapter->is_up = 0;
 }
 
+void qlcnic_diag_free_res(struct net_device *netdev, int max_sds_rings)
+{
+	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+	struct qlcnic_host_sds_ring *sds_ring;
+	int ring;
+
+	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+		sds_ring = &adapter->recv_ctx.sds_rings[ring];
+		qlcnic_disable_int(sds_ring);
+	}
+
+	qlcnic_detach(adapter);
+
+	adapter->diag_test = 0;
+	adapter->max_sds_rings = max_sds_rings;
+
+	if (qlcnic_attach(adapter))
+		return;
+
+	if (netif_running(netdev))
+		__qlcnic_up(adapter, netdev);
+
+	netif_device_attach(netdev);
+}
+
+int qlcnic_diag_alloc_res(struct net_device *netdev, int test)
+{
+	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+	struct qlcnic_host_sds_ring *sds_ring;
+	int ring;
+	int ret;
+
+	netif_device_detach(netdev);
+
+	if (netif_running(netdev))
+		__qlcnic_down(adapter, netdev);
+
+	qlcnic_detach(adapter);
+
+	adapter->max_sds_rings = 1;
+	adapter->diag_test = test;
+
+	ret = qlcnic_attach(adapter);
+	if (ret)
+		return ret;
+
+	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+		sds_ring = &adapter->recv_ctx.sds_rings[ring];
+		qlcnic_enable_int(sds_ring);
+	}
+
+	return 0;
+}
+
 int
 qlcnic_reset_context(struct qlcnic_adapter *adapter)
 {
@@ -1689,10 +1751,8 @@ static struct net_device_stats *qlcnic_get_stats(struct net_device *netdev)
 	return stats;
 }
 
-static irqreturn_t qlcnic_intr(int irq, void *data)
+static irqreturn_t qlcnic_clear_legacy_intr(struct qlcnic_adapter *adapter)
 {
-	struct qlcnic_host_sds_ring *sds_ring = data;
-	struct qlcnic_adapter *adapter = sds_ring->adapter;
 	u32 status;
 
 	status = readl(adapter->isr_int_vec);
@@ -1710,6 +1770,38 @@ static irqreturn_t qlcnic_intr(int irq, void *data)
 	readl(adapter->isr_int_vec);
 	readl(adapter->isr_int_vec);
 
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t qlcnic_tmp_intr(int irq, void *data)
+{
+	struct qlcnic_host_sds_ring *sds_ring = data;
+	struct qlcnic_adapter *adapter = sds_ring->adapter;
+
+	if (adapter->flags & QLCNIC_MSIX_ENABLED)
+		goto done;
+	else if (adapter->flags & QLCNIC_MSI_ENABLED) {
+		writel(0xffffffff, adapter->tgt_status_reg);
+		goto done;
+	}
+
+	if (qlcnic_clear_legacy_intr(adapter) == IRQ_NONE)
+		return IRQ_NONE;
+
+done:
+	adapter->diag_cnt++;
+	qlcnic_enable_int(sds_ring);
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t qlcnic_intr(int irq, void *data)
+{
+	struct qlcnic_host_sds_ring *sds_ring = data;
+	struct qlcnic_adapter *adapter = sds_ring->adapter;
+
+	if (qlcnic_clear_legacy_intr(adapter) == IRQ_NONE)
+		return IRQ_NONE;
+
 	napi_schedule(&sds_ring->napi);
 
 	return IRQ_HANDLED;
-- 
1.6.0.2

