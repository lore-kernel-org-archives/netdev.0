From: Shreyas N Bhatewara <sbhatewara@vmware.com>
Subject: [PATCH net-next 7/8] vmxnet3: Add locking for access to command
	register
Date: Fri, 14 Jan 2011 16:59:57 -0800
Message-ID: <20110115005957.1064.20279.stgit@sbhatewara-dev1.eng.vmware.com>
References: <20110115005701.1064.67435.stgit@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, Matthieu Bucchianeri <matthieu@vmware.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110115005701.1064.67435.stgit@sbhatewara-dev1.eng.vmware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Access to cmd register is racey, especially in smp environments. Protect
it using a spinlock.

Signed-off-by: Matthieu Bucchianeri <matthieu@vmware.com>
Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c     |   38 +++++++++++++++++++++++++++++++++
 drivers/net/vmxnet3/vmxnet3_ethtool.c |   15 +++++++++++++
 drivers/net/vmxnet3/vmxnet3_int.h     |    1 +
 3 files changed, 54 insertions(+), 0 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 20ef4f3..3b5b134 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -142,9 +142,13 @@ vmxnet3_check_link(struct vmxnet3_adapter *adapter, bool affectTxQueue)
 {
 	u32 ret;
 	int i;
+	unsigned long flags;
 
+	spin_lock_irqsave(&adapter->cmd_lock, flags);
 	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD, VMXNET3_CMD_GET_LINK);
 	ret = VMXNET3_READ_BAR1_REG(adapter, VMXNET3_REG_CMD);
+	spin_unlock_irqrestore(&adapter->cmd_lock, flags);
+
 	adapter->link_speed = ret >> 16;
 	if (ret & 1) { /* Link is up. */
 		printk(KERN_INFO "%s: NIC Link is Up %d Mbps\n",
@@ -186,8 +190,10 @@ vmxnet3_process_events(struct vmxnet3_adapter *adapter)
 
 	/* Check if there is an error on xmit/recv queues */
 	if (events & (VMXNET3_ECR_TQERR | VMXNET3_ECR_RQERR)) {
+		spin_lock(&adapter->cmd_lock);
 		VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
 				       VMXNET3_CMD_GET_QUEUE_STATUS);
+		spin_unlock(&adapter->cmd_lock);
 
 		for (i = 0; i < adapter->num_tx_queues; i++)
 			if (adapter->tqd_start[i].status.stopped)
@@ -1857,6 +1863,7 @@ vmxnet3_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
 	struct Vmxnet3_DriverShared *shared = adapter->shared;
 	u32 *vfTable = adapter->shared->devRead.rxFilterConf.vfTable;
+	unsigned long flags;
 
 	if (grp) {
 		/* add vlan rx stripping. */
@@ -1873,8 +1880,10 @@ vmxnet3_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 				vfTable[i] = 0;
 
 			VMXNET3_SET_VFTABLE_ENTRY(vfTable, 0);
+			spin_lock_irqsave(&adapter->cmd_lock, flags);
 			VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
 					       VMXNET3_CMD_UPDATE_VLAN_FILTERS);
+			spin_unlock_irqrestore(&adapter->cmd_lock, flags);
 		} else {
 			printk(KERN_ERR "%s: vlan_rx_register when device has "
 			       "no NETIF_F_HW_VLAN_RX\n", netdev->name);
@@ -1893,8 +1902,10 @@ vmxnet3_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 				 */
 				vfTable[i] = 0;
 			}
+			spin_lock_irqsave(&adapter->cmd_lock, flags);
 			VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
 					       VMXNET3_CMD_UPDATE_VLAN_FILTERS);
+			spin_unlock_irqrestore(&adapter->cmd_lock, flags);
 		}
 	}
 }
@@ -1927,10 +1938,13 @@ vmxnet3_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 {
 	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
 	u32 *vfTable = adapter->shared->devRead.rxFilterConf.vfTable;
+	unsigned long flags;
 
 	VMXNET3_SET_VFTABLE_ENTRY(vfTable, vid);
+	spin_lock_irqsave(&adapter->cmd_lock, flags);
 	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
 			       VMXNET3_CMD_UPDATE_VLAN_FILTERS);
+	spin_unlock_irqrestore(&adapter->cmd_lock, flags);
 }
 
 
@@ -1939,10 +1953,13 @@ vmxnet3_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 {
 	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
 	u32 *vfTable = adapter->shared->devRead.rxFilterConf.vfTable;
+	unsigned long flags;
 
 	VMXNET3_CLEAR_VFTABLE_ENTRY(vfTable, vid);
+	spin_lock_irqsave(&adapter->cmd_lock, flags);
 	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
 			       VMXNET3_CMD_UPDATE_VLAN_FILTERS);
+	spin_unlock_irqrestore(&adapter->cmd_lock, flags);
 }
 
 
@@ -1973,6 +1990,7 @@ static void
 vmxnet3_set_mc(struct net_device *netdev)
 {
 	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
+	unsigned long flags;
 	struct Vmxnet3_RxFilterConf *rxConf =
 					&adapter->shared->devRead.rxFilterConf;
 	u8 *new_table = NULL;
@@ -2008,6 +2026,7 @@ vmxnet3_set_mc(struct net_device *netdev)
 		rxConf->mfTablePA = 0;
 	}
 
+	spin_lock_irqsave(&adapter->cmd_lock, flags);
 	if (new_mode != rxConf->rxMode) {
 		rxConf->rxMode = cpu_to_le32(new_mode);
 		VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
@@ -2016,6 +2035,7 @@ vmxnet3_set_mc(struct net_device *netdev)
 
 	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
 			       VMXNET3_CMD_UPDATE_MAC_FILTERS);
+	spin_unlock_irqrestore(&adapter->cmd_lock, flags);
 
 	kfree(new_table);
 }
@@ -2165,6 +2185,7 @@ vmxnet3_activate_dev(struct vmxnet3_adapter *adapter)
 {
 	int err, i;
 	u32 ret;
+	unsigned long flags;
 
 	dev_dbg(&adapter->netdev->dev, "%s: skb_buf_size %d, rx_buf_per_pkt %d,"
 		" ring sizes %u %u %u\n", adapter->netdev->name,
@@ -2194,9 +2215,11 @@ vmxnet3_activate_dev(struct vmxnet3_adapter *adapter)
 			       adapter->shared_pa));
 	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_DSAH, VMXNET3_GET_ADDR_HI(
 			       adapter->shared_pa));
+	spin_lock_irqsave(&adapter->cmd_lock, flags);
 	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
 			       VMXNET3_CMD_ACTIVATE_DEV);
 	ret = VMXNET3_READ_BAR1_REG(adapter, VMXNET3_REG_CMD);
+	spin_unlock_irqrestore(&adapter->cmd_lock, flags);
 
 	if (ret != 0) {
 		printk(KERN_ERR "Failed to activate dev %s: error %u\n",
@@ -2243,7 +2266,10 @@ rq_err:
 void
 vmxnet3_reset_dev(struct vmxnet3_adapter *adapter)
 {
+	unsigned long flags;
+	spin_lock_irqsave(&adapter->cmd_lock, flags);
 	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD, VMXNET3_CMD_RESET_DEV);
+	spin_unlock_irqrestore(&adapter->cmd_lock, flags);
 }
 
 
@@ -2251,12 +2277,15 @@ int
 vmxnet3_quiesce_dev(struct vmxnet3_adapter *adapter)
 {
 	int i;
+	unsigned long flags;
 	if (test_and_set_bit(VMXNET3_STATE_BIT_QUIESCED, &adapter->state))
 		return 0;
 
 
+	spin_lock_irqsave(&adapter->cmd_lock, flags);
 	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
 			       VMXNET3_CMD_QUIESCE_DEV);
+	spin_unlock_irqrestore(&adapter->cmd_lock, flags);
 	vmxnet3_disable_all_intrs(adapter);
 
 	for (i = 0; i < adapter->num_rx_queues; i++)
@@ -2706,9 +2735,11 @@ vmxnet3_alloc_intr_resources(struct vmxnet3_adapter *adapter)
 	u32 cfg;
 
 	/* intr settings */
+	spin_lock(&adapter->cmd_lock);
 	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
 			       VMXNET3_CMD_GET_CONF_INTR);
 	cfg = VMXNET3_READ_BAR1_REG(adapter, VMXNET3_REG_CMD);
+	spin_unlock(&adapter->cmd_lock);
 	adapter->intr.type = cfg & 0x3;
 	adapter->intr.mask_mode = (cfg >> 2) & 0x3;
 
@@ -2893,6 +2924,7 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 	adapter->netdev = netdev;
 	adapter->pdev = pdev;
 
+	spin_lock_init(&adapter->cmd_lock);
 	adapter->shared = pci_alloc_consistent(adapter->pdev,
 			  sizeof(struct Vmxnet3_DriverShared),
 			  &adapter->shared_pa);
@@ -3096,6 +3128,7 @@ vmxnet3_suspend(struct device *device)
 	u8 *arpreq;
 	struct in_device *in_dev;
 	struct in_ifaddr *ifa;
+	unsigned long flags;
 	int i = 0;
 
 	if (!netif_running(netdev))
@@ -3179,8 +3212,10 @@ skip_arp:
 	adapter->shared->devRead.pmConfDesc.confPA = cpu_to_le64(virt_to_phys(
 								 pmConf));
 
+	spin_lock_irqsave(&adapter->cmd_lock, flags);
 	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
 			       VMXNET3_CMD_UPDATE_PMCFG);
+	spin_unlock_irqrestore(&adapter->cmd_lock, flags);
 
 	pci_save_state(pdev);
 	pci_enable_wake(pdev, pci_choose_state(pdev, PMSG_SUSPEND),
@@ -3196,6 +3231,7 @@ static int
 vmxnet3_resume(struct device *device)
 {
 	int err, i = 0;
+	unsigned long flags;
 	struct pci_dev *pdev = to_pci_dev(device);
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
@@ -3223,8 +3259,10 @@ vmxnet3_resume(struct device *device)
 
 	pci_enable_wake(pdev, PCI_D0, 0);
 
+	spin_lock_irqsave(&adapter->cmd_lock, flags);
 	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
 			       VMXNET3_CMD_UPDATE_PMCFG);
+	spin_unlock_irqrestore(&adapter->cmd_lock, flags);
 	vmxnet3_alloc_intr_resources(adapter);
 	vmxnet3_request_irqs(adapter);
 	for (i = 0; i < adapter->num_rx_queues; i++)
diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vmxnet3_ethtool.c
index d70cee1..81254be 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -45,6 +45,7 @@ static int
 vmxnet3_set_rx_csum(struct net_device *netdev, u32 val)
 {
 	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
+	unsigned long flags;
 
 	if (adapter->rxcsum != val) {
 		adapter->rxcsum = val;
@@ -56,8 +57,10 @@ vmxnet3_set_rx_csum(struct net_device *netdev, u32 val)
 				adapter->shared->devRead.misc.uptFeatures &=
 				~UPT1_F_RXCSUM;
 
+			spin_lock_irqsave(&adapter->cmd_lock, flags);
 			VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
 					       VMXNET3_CMD_UPDATE_FEATURE);
+			spin_unlock_irqrestore(&adapter->cmd_lock, flags);
 		}
 	}
 	return 0;
@@ -153,12 +156,15 @@ vmxnet3_get_stats(struct net_device *netdev)
 	struct UPT1_TxStats *devTxStats;
 	struct UPT1_RxStats *devRxStats;
 	struct net_device_stats *net_stats = &netdev->stats;
+	unsigned long flags;
 	int i;
 
 	adapter = netdev_priv(netdev);
 
 	/* Collect the dev stats into the shared area */
+	spin_lock_irqsave(&adapter->cmd_lock, flags);
 	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD, VMXNET3_CMD_GET_STATS);
+	spin_unlock_irqrestore(&adapter->cmd_lock, flags);
 
 	memset(net_stats, 0, sizeof(*net_stats));
 	for (i = 0; i < adapter->num_tx_queues; i++) {
@@ -296,6 +302,7 @@ vmxnet3_set_flags(struct net_device *netdev, u32 data)
 	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
 	u8 lro_requested = (data & ETH_FLAG_LRO) == 0 ? 0 : 1;
 	u8 lro_present = (netdev->features & NETIF_F_LRO) == 0 ? 0 : 1;
+	unsigned long flags;
 
 	if (data & ~ETH_FLAG_LRO)
 		return -EOPNOTSUPP;
@@ -311,8 +318,10 @@ vmxnet3_set_flags(struct net_device *netdev, u32 data)
 		else
 			adapter->shared->devRead.misc.uptFeatures &=
 							~UPT1_F_LRO;
+		spin_lock_irqsave(&adapter->cmd_lock, flags);
 		VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
 				       VMXNET3_CMD_UPDATE_FEATURE);
+		spin_unlock_irqrestore(&adapter->cmd_lock, flags);
 	}
 	return 0;
 }
@@ -322,11 +331,14 @@ vmxnet3_get_ethtool_stats(struct net_device *netdev,
 			  struct ethtool_stats *stats, u64  *buf)
 {
 	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
+	unsigned long flags;
 	u8 *base;
 	int i;
 	int j = 0;
 
+	spin_lock_irqsave(&adapter->cmd_lock, flags);
 	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD, VMXNET3_CMD_GET_STATS);
+	spin_unlock_irqrestore(&adapter->cmd_lock, flags);
 
 	/* this does assume each counter is 64-bit wide */
 	for (j = 0; j < adapter->num_tx_queues; j++) {
@@ -605,6 +617,7 @@ vmxnet3_set_rss_indir(struct net_device *netdev,
 		      const struct ethtool_rxfh_indir *p)
 {
 	unsigned int i;
+	unsigned long flags;
 	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
 	struct UPT1_RSSConf *rssConf = adapter->rss_conf;
 
@@ -623,8 +636,10 @@ vmxnet3_set_rss_indir(struct net_device *netdev,
 	for (i = 0; i < rssConf->indTableSize; i++)
 		rssConf->indTable[i] = p->ring_index[i];
 
+	spin_lock_irqsave(&adapter->cmd_lock, flags);
 	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
 			       VMXNET3_CMD_UPDATE_RSSIDT);
+	spin_unlock_irqrestore(&adapter->cmd_lock, flags);
 
 	return 0;
 
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 7fadeed..474f5df 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -317,6 +317,7 @@ struct vmxnet3_adapter {
 	struct vmxnet3_rx_queue		rx_queue[VMXNET3_DEVICE_MAX_RX_QUEUES];
 	struct vlan_group		*vlan_grp;
 	struct vmxnet3_intr		intr;
+	spinlock_t			cmd_lock;
 	struct Vmxnet3_DriverShared	*shared;
 	struct Vmxnet3_PMConf		*pm_conf;
 	struct Vmxnet3_TxQueueDesc	*tqd_start;     /* all tx queue desc */
