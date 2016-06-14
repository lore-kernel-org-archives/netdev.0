From: Shrikrishna Khare <skhare@vmware.com>
Subject: [PATCH net-next v3 5/7] vmxnet3: add support for get_coalesce, set_coalesce ethtool operations
Date: Mon, 13 Jun 2016 18:50:05 -0700
Message-ID: <1465869007-10822-6-git-send-email-skhare@vmware.com>
References: <1465869007-10822-1-git-send-email-skhare@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shrikrishna Khare <skhare@vmware.com>,
	Keyong Sun <sunk@vmware.com>,
	"Manoj Tammali" <tammalim@vmware.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<pv-drivers@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465869007-10822-1-git-send-email-skhare@vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Keyong Sun <sunk@vmware.com>
Signed-off-by: Manoj Tammali <tammalim@vmware.com>
Signed-off-by: Shrikrishna Khare <skhare@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_defs.h    |  33 ++++++-
 drivers/net/vmxnet3/vmxnet3_drv.c     |  54 ++++++++++++
 drivers/net/vmxnet3/vmxnet3_ethtool.c | 160 ++++++++++++++++++++++++++++++++++
 drivers/net/vmxnet3/vmxnet3_int.h     |   9 ++
 4 files changed, 255 insertions(+), 1 deletion(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_defs.h b/drivers/net/vmxnet3/vmxnet3_defs.h
index f3b31c2..274e145 100644
--- a/drivers/net/vmxnet3/vmxnet3_defs.h
+++ b/drivers/net/vmxnet3/vmxnet3_defs.h
@@ -80,6 +80,7 @@ enum {
 	VMXNET3_CMD_LOAD_PLUGIN,
 	VMXNET3_CMD_RESERVED2,
 	VMXNET3_CMD_RESERVED3,
+	VMXNET3_CMD_SET_COALESCE,
 
 	VMXNET3_CMD_FIRST_GET = 0xF00D0000,
 	VMXNET3_CMD_GET_QUEUE_STATUS = VMXNET3_CMD_FIRST_GET,
@@ -92,7 +93,8 @@ enum {
 	VMXNET3_CMD_GET_DEV_EXTRA_INFO,
 	VMXNET3_CMD_GET_CONF_INTR,
 	VMXNET3_CMD_GET_RESERVED1,
-	VMXNET3_CMD_GET_TXDATA_DESC_SIZE
+	VMXNET3_CMD_GET_TXDATA_DESC_SIZE,
+	VMXNET3_CMD_GET_COALESCE,
 };
 
 /*
@@ -637,6 +639,35 @@ struct Vmxnet3_SetPolling {
 	u8					enablePolling;
 };
 
+#define VMXNET3_COAL_STATIC_MAX_DEPTH		128
+#define VMXNET3_COAL_RBC_MIN_RATE		100
+#define VMXNET3_COAL_RBC_MAX_RATE		100000
+
+enum Vmxnet3_CoalesceMode {
+	VMXNET3_COALESCE_DISABLED   = 0,
+	VMXNET3_COALESCE_ADAPT      = 1,
+	VMXNET3_COALESCE_STATIC     = 2,
+	VMXNET3_COALESCE_RBC        = 3
+};
+
+struct Vmxnet3_CoalesceRbc {
+	u32					rbc_rate;
+};
+
+struct Vmxnet3_CoalesceStatic {
+	u32					tx_depth;
+	u32					tx_comp_depth;
+	u32					rx_depth;
+};
+
+struct Vmxnet3_CoalesceScheme {
+	enum Vmxnet3_CoalesceMode		coalMode;
+	union {
+		struct Vmxnet3_CoalesceRbc	coalRbc;
+		struct Vmxnet3_CoalesceStatic	coalStatic;
+	} coalPara;
+};
+
 /* If the command data <= 16 bytes, use the shared memory directly.
  * otherwise, use variable length configuration descriptor.
  */
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 6449d2e..d0bcc1d9 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -2491,6 +2491,32 @@ vmxnet3_setup_driver_shared(struct vmxnet3_adapter *adapter)
 	/* the rest are already zeroed */
 }
 
+static void
+vmxnet3_init_coalesce(struct vmxnet3_adapter *adapter)
+{
+	struct Vmxnet3_DriverShared *shared = adapter->shared;
+	union Vmxnet3_CmdInfo *cmdInfo = &shared->cu.cmdInfo;
+	unsigned long flags;
+
+	if (!VMXNET3_VERSION_GE_3(adapter))
+		return;
+
+	spin_lock_irqsave(&adapter->cmd_lock, flags);
+	cmdInfo->varConf.confVer = 1;
+	cmdInfo->varConf.confLen =
+		cpu_to_le32(sizeof(*adapter->coal_conf));
+	cmdInfo->varConf.confPA  = cpu_to_le64(adapter->coal_conf_pa);
+
+	if (adapter->default_coal_mode) {
+		VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
+				       VMXNET3_CMD_GET_COALESCE);
+	} else {
+		VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
+				       VMXNET3_CMD_SET_COALESCE);
+	}
+
+	spin_unlock_irqrestore(&adapter->cmd_lock, flags);
+}
 
 int
 vmxnet3_activate_dev(struct vmxnet3_adapter *adapter)
@@ -2540,6 +2566,8 @@ vmxnet3_activate_dev(struct vmxnet3_adapter *adapter)
 		goto activate_err;
 	}
 
+	vmxnet3_init_coalesce(adapter);
+
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		VMXNET3_WRITE_BAR0_REG(adapter,
 				VMXNET3_REG_RXPROD + i * VMXNET3_REG_ALIGN,
@@ -3345,6 +3373,22 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 		goto err_ver;
 	}
 
+	if (VMXNET3_VERSION_GE_3(adapter)) {
+		adapter->coal_conf =
+			dma_alloc_coherent(&adapter->pdev->dev,
+					   sizeof(struct Vmxnet3_CoalesceScheme)
+					   ,
+					   &adapter->coal_conf_pa,
+					   GFP_KERNEL);
+		if (!adapter->coal_conf) {
+			err = -ENOMEM;
+			goto err_ver;
+		}
+		memset(adapter->coal_conf, 0, sizeof(*adapter->coal_conf));
+		adapter->coal_conf->coalMode = VMXNET3_COALESCE_DISABLED;
+		adapter->default_coal_mode = true;
+	}
+
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 	vmxnet3_declare_features(adapter, dma64);
 
@@ -3407,6 +3451,11 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 	return 0;
 
 err_register:
+	if (VMXNET3_VERSION_GE_3(adapter)) {
+		dma_free_coherent(&adapter->pdev->dev,
+				  sizeof(struct Vmxnet3_CoalesceScheme),
+				  adapter->coal_conf, adapter->coal_conf_pa);
+	}
 	vmxnet3_free_intr_resources(adapter);
 err_ver:
 	vmxnet3_free_pci_resources(adapter);
@@ -3457,6 +3506,11 @@ vmxnet3_remove_device(struct pci_dev *pdev)
 
 	vmxnet3_free_intr_resources(adapter);
 	vmxnet3_free_pci_resources(adapter);
+	if (VMXNET3_VERSION_GE_3(adapter)) {
+		dma_free_coherent(&adapter->pdev->dev,
+				  sizeof(struct Vmxnet3_CoalesceScheme),
+				  adapter->coal_conf, adapter->coal_conf_pa);
+	}
 #ifdef VMXNET3_RSS
 	dma_free_coherent(&adapter->pdev->dev, sizeof(struct UPT1_RSSConf),
 			  adapter->rss_conf, adapter->rss_conf_pa);
diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vmxnet3_ethtool.c
index 38f7c79..3a0ada6 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -725,6 +725,164 @@ vmxnet3_set_rss(struct net_device *netdev, const u32 *p, const u8 *key,
 }
 #endif
 
+static int
+vmxnet3_get_coalesce(struct net_device *netdev, struct ethtool_coalesce *ec)
+{
+	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
+
+	if (!VMXNET3_VERSION_GE_3(adapter))
+		return -EOPNOTSUPP;
+
+	memset(ec, 0, sizeof(struct ethtool_coalesce));
+
+	switch (adapter->coal_conf->coalMode) {
+	case VMXNET3_COALESCE_DISABLED:
+		/* struct ethtool_coalesce is already initialized to 0 */
+		break;
+	case VMXNET3_COALESCE_ADAPT:
+		ec->use_adaptive_rx_coalesce = true;
+		break;
+	case VMXNET3_COALESCE_STATIC:
+		ec->tx_max_coalesced_frames =
+			adapter->coal_conf->coalPara.coalStatic.tx_comp_depth;
+		ec->rx_max_coalesced_frames =
+			adapter->coal_conf->coalPara.coalStatic.rx_depth;
+		break;
+	case VMXNET3_COALESCE_RBC: {
+		u32 rbc_rate;
+
+		rbc_rate = adapter->coal_conf->coalPara.coalRbc.rbc_rate;
+		ec->rx_coalesce_usecs = VMXNET3_COAL_RBC_USECS(rbc_rate);
+	}
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
+static int
+vmxnet3_set_coalesce(struct net_device *netdev, struct ethtool_coalesce *ec)
+{
+	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
+	struct Vmxnet3_DriverShared *shared = adapter->shared;
+	union Vmxnet3_CmdInfo *cmdInfo = &shared->cu.cmdInfo;
+	unsigned long flags;
+
+	if (!VMXNET3_VERSION_GE_3(adapter))
+		return -EOPNOTSUPP;
+
+	if (ec->rx_coalesce_usecs_irq ||
+	    ec->rx_max_coalesced_frames_irq ||
+	    ec->tx_coalesce_usecs ||
+	    ec->tx_coalesce_usecs_irq ||
+	    ec->tx_max_coalesced_frames_irq ||
+	    ec->stats_block_coalesce_usecs ||
+	    ec->use_adaptive_tx_coalesce ||
+	    ec->pkt_rate_low ||
+	    ec->rx_coalesce_usecs_low ||
+	    ec->rx_max_coalesced_frames_low ||
+	    ec->tx_coalesce_usecs_low ||
+	    ec->tx_max_coalesced_frames_low ||
+	    ec->pkt_rate_high ||
+	    ec->rx_coalesce_usecs_high ||
+	    ec->rx_max_coalesced_frames_high ||
+	    ec->tx_coalesce_usecs_high ||
+	    ec->tx_max_coalesced_frames_high ||
+	    ec->rate_sample_interval) {
+		return -EINVAL;
+	}
+
+	if ((ec->rx_coalesce_usecs == 0) &&
+	    (ec->use_adaptive_rx_coalesce == 0) &&
+	    (ec->tx_max_coalesced_frames == 0) &&
+	    (ec->rx_max_coalesced_frames == 0)) {
+		memset(adapter->coal_conf, 0, sizeof(*adapter->coal_conf));
+		adapter->coal_conf->coalMode = VMXNET3_COALESCE_DISABLED;
+		goto done;
+	}
+
+	if (ec->rx_coalesce_usecs != 0) {
+		u32 rbc_rate;
+
+		if ((ec->use_adaptive_rx_coalesce != 0) ||
+		    (ec->tx_max_coalesced_frames != 0) ||
+		    (ec->rx_max_coalesced_frames != 0)) {
+			return -EINVAL;
+		}
+
+		rbc_rate = VMXNET3_COAL_RBC_RATE(ec->rx_coalesce_usecs);
+		if (rbc_rate < VMXNET3_COAL_RBC_MIN_RATE ||
+		    rbc_rate > VMXNET3_COAL_RBC_MAX_RATE) {
+			return -EINVAL;
+		}
+
+		memset(adapter->coal_conf, 0, sizeof(*adapter->coal_conf));
+		adapter->coal_conf->coalMode = VMXNET3_COALESCE_RBC;
+		adapter->coal_conf->coalPara.coalRbc.rbc_rate = rbc_rate;
+		goto done;
+	}
+
+	if (ec->use_adaptive_rx_coalesce != 0) {
+		if ((ec->rx_coalesce_usecs != 0) ||
+		    (ec->tx_max_coalesced_frames != 0) ||
+		    (ec->rx_max_coalesced_frames != 0)) {
+			return -EINVAL;
+		}
+		memset(adapter->coal_conf, 0, sizeof(*adapter->coal_conf));
+		adapter->coal_conf->coalMode = VMXNET3_COALESCE_ADAPT;
+		goto done;
+	}
+
+	if ((ec->tx_max_coalesced_frames != 0) ||
+	    (ec->rx_max_coalesced_frames != 0)) {
+		if ((ec->rx_coalesce_usecs != 0) ||
+		    (ec->use_adaptive_rx_coalesce != 0)) {
+			return -EINVAL;
+		}
+
+		if ((ec->tx_max_coalesced_frames >
+		    VMXNET3_COAL_STATIC_MAX_DEPTH) ||
+		    (ec->rx_max_coalesced_frames >
+		     VMXNET3_COAL_STATIC_MAX_DEPTH)) {
+			return -EINVAL;
+		}
+
+		memset(adapter->coal_conf, 0, sizeof(*adapter->coal_conf));
+		adapter->coal_conf->coalMode = VMXNET3_COALESCE_STATIC;
+
+		adapter->coal_conf->coalPara.coalStatic.tx_comp_depth =
+			(ec->tx_max_coalesced_frames ?
+			 ec->tx_max_coalesced_frames :
+			 VMXNET3_COAL_STATIC_DEFAULT_DEPTH);
+
+		adapter->coal_conf->coalPara.coalStatic.rx_depth =
+			(ec->rx_max_coalesced_frames ?
+			 ec->rx_max_coalesced_frames :
+			 VMXNET3_COAL_STATIC_DEFAULT_DEPTH);
+
+		adapter->coal_conf->coalPara.coalStatic.tx_depth =
+			 VMXNET3_COAL_STATIC_DEFAULT_DEPTH;
+		goto done;
+	}
+
+done:
+	adapter->default_coal_mode = false;
+	if (netif_running(netdev)) {
+		spin_lock_irqsave(&adapter->cmd_lock, flags);
+		cmdInfo->varConf.confVer = 1;
+		cmdInfo->varConf.confLen =
+			cpu_to_le32(sizeof(*adapter->coal_conf));
+		cmdInfo->varConf.confPA  = cpu_to_le64(adapter->coal_conf_pa);
+		VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
+				       VMXNET3_CMD_SET_COALESCE);
+		spin_unlock_irqrestore(&adapter->cmd_lock, flags);
+	}
+
+	return 0;
+}
+
 static const struct ethtool_ops vmxnet3_ethtool_ops = {
 	.get_settings      = vmxnet3_get_settings,
 	.get_drvinfo       = vmxnet3_get_drvinfo,
@@ -733,6 +891,8 @@ static const struct ethtool_ops vmxnet3_ethtool_ops = {
 	.get_wol           = vmxnet3_get_wol,
 	.set_wol           = vmxnet3_set_wol,
 	.get_link          = ethtool_op_get_link,
+	.get_coalesce      = vmxnet3_get_coalesce,
+	.set_coalesce      = vmxnet3_set_coalesce,
 	.get_strings       = vmxnet3_get_strings,
 	.get_sset_count	   = vmxnet3_get_sset_count,
 	.get_ethtool_stats = vmxnet3_get_ethtool_stats,
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index c46bf09..63df4f2 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -358,6 +358,7 @@ struct vmxnet3_adapter {
 	int		rx_buf_per_pkt;  /* only apply to the 1st ring */
 	dma_addr_t			shared_pa;
 	dma_addr_t queue_desc_pa;
+	dma_addr_t coal_conf_pa;
 
 	/* Wake-on-LAN */
 	u32     wol;
@@ -384,6 +385,9 @@ struct vmxnet3_adapter {
 
 	int share_intr;
 
+	struct Vmxnet3_CoalesceScheme *coal_conf;
+	bool   default_coal_mode;
+
 	dma_addr_t adapter_pa;
 	dma_addr_t pm_conf_pa;
 	dma_addr_t rss_conf_pa;
@@ -429,6 +433,11 @@ struct vmxnet3_adapter {
 	(rqID >= 2 * adapter->num_rx_queues &&		\
 	rqID < 3 * adapter->num_rx_queues)		\
 
+#define VMXNET3_COAL_STATIC_DEFAULT_DEPTH	64
+
+#define VMXNET3_COAL_RBC_RATE(usecs) (1000000 / usecs)
+#define VMXNET3_COAL_RBC_USECS(rbc_rate) (1000000 / rbc_rate)
+
 int
 vmxnet3_quiesce_dev(struct vmxnet3_adapter *adapter);
 
-- 
2.8.2
