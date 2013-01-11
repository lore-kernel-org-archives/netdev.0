From: Shannon Nelson <shannon.nelson@intel.com>
Subject: [PATCH 3/3] ixgbe: add interrupt control parameters
Date: Thu, 10 Jan 2013 18:02:44 -0800
Message-ID: <20130111020242.15463.36498.stgit@starfish.jf.intel.com>
References: <20130111020046.15463.72333.stgit@starfish.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, dwmw2@infradead.org,
	jeffrey.t.kirsher@intel.com, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130111020046.15463.72333.stgit@starfish.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

MSIX is used by default in the driver, with MSI and legacy interrupt
handling as fallbacks.  These options allow for controlling which handling
will get used.

nomsi
nomsix
	Disable the use of MSI and/or MSIX interrupt handling

Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: David Woodhouse <dwmw2@infradead.org>
---

 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c  |    6 ++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   15 +++++++++++++++
 2 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index 8c74f73..464d8cf 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -704,6 +704,9 @@ static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
 {
 	int err, vector_threshold;
 
+	if (!(adapter->flags & IXGBE_FLAG_MSIX_CAPABLE))
+		return;
+
 	/* We'll want at least 2 (vector_threshold):
 	 * 1) TxQ[0] + RxQ[0] handler
 	 * 2) Other (Link Status Change, etc.)
@@ -1107,6 +1110,9 @@ static void ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 	ixgbe_set_num_queues(adapter);
 	adapter->num_q_vectors = 1;
 
+	if (!(adapter->flags & IXGBE_FLAG_MSI_CAPABLE))
+		return;
+
 	err = pci_enable_msi(adapter->pdev);
 	if (err) {
 		netif_printk(adapter, hw, KERN_DEBUG, adapter->netdev,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 9a94ca2..baa778e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -169,6 +169,8 @@ enum {
 #endif
 	Opt_FdirPballoc,
 	Opt_AtrSampleRate,
+	Opt_nomsix,
+	Opt_nomsi,
 };
 
 static const match_table_t tokens = {
@@ -182,6 +184,8 @@ static const match_table_t tokens = {
 #endif
 	{ Opt_FdirPballoc, "FdirPballoc=%u" },
 	{ Opt_AtrSampleRate, "AtrSampleRate=%u" },
+	{ Opt_nomsix, "nomsix" },
+	{ Opt_nomsi, "nomsi" },
 
 	/* terminator token */
 	{ 0, NULL },
@@ -194,6 +198,8 @@ MODULE_INFO(fw_option,
 MODULE_INFO(fw_option, "nodca : Disable Direct Cache Access");
 MODULE_INFO(fw_option, "FdirPballoc=N : Flow Director packet buffer allocation level - 1, 2, or 3");
 MODULE_INFO(fw_option, "AtrSampleRate=N : Software ATR Tx packet sample rate, 0-255");
+MODULE_INFO(fw_option, "nomsix : Disable the use of MSI-X interrupt handling");
+MODULE_INFO(fw_option, "nomsi  : Disable the use of MSI interrupt handling");
 
 /**
  * ixgbe_parse_option_line - find ixgbe options
@@ -300,6 +306,14 @@ static void ixgbe_parse_option_line(struct ixgbe_adapter *adapter,
 				e_dev_err("Bad AtrSampleRate %d\n", value);
 			break;
 
+		case Opt_nomsix:
+			adapter->flags &= ~IXGBE_FLAG_MSIX_CAPABLE;
+			break;
+
+		case Opt_nomsi:
+			adapter->flags &= ~IXGBE_FLAG_MSI_CAPABLE;
+			break;
+
 		default:
 			goto parse_error;
 			break;
@@ -4722,6 +4736,7 @@ static int ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	/* Set capability flags */
 	rss = min_t(int, IXGBE_MAX_RSS_INDICES, num_online_cpus());
 	adapter->ring_feature[RING_F_RSS].limit = rss;
+	adapter->flags |= (IXGBE_FLAG_MSIX_CAPABLE | IXGBE_FLAG_MSI_CAPABLE);
 	switch (hw->mac.type) {
 	case ixgbe_mac_82598EB:
 		if (hw->device_id == IXGBE_DEV_ID_82598AT)
