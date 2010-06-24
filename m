From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH 04/10] enic: Clean up: Add wrapper routines for
	firmware devcmd calls
Date: Thu, 24 Jun 2010 13:50:12 -0700
Message-ID: <20100624205005.22595.1526.stgit@savbu-pc100.cisco.com>
References: <20100624204723.22595.42990.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, scofeldm@cisco.com, vkolluri@cisco.com,
	roprabhu@cisco.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:7053 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755802Ab0FXUuN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 16:50:13 -0400
In-Reply-To: <20100624204723.22595.42990.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>

Add wrapper routines that issue devcmds to firmware and ensure that a
devcmd lock is held for each devcmd call.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
---
 drivers/net/enic/enic_main.c |  226 ++++++++++++++++++++++++++++++++----------
 drivers/net/enic/enic_res.c  |   23 +---
 drivers/net/enic/enic_res.h  |    6 -
 drivers/net/enic/vnic_dev.c  |   23 +++-
 drivers/net/enic/vnic_dev.h  |    7 +
 5 files changed, 201 insertions(+), 84 deletions(-)

diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index d7434b7..9e05805 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -145,15 +145,25 @@ static int enic_get_settings(struct net_device *netdev,
 	return 0;
 }
 
+static int enic_dev_fw_info(struct enic *enic,
+	struct vnic_devcmd_fw_info **fw_info)
+{
+	int err;
+
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_fw_info(enic->vdev, fw_info);
+	spin_unlock(&enic->devcmd_lock);
+
+	return err;
+}
+
 static void enic_get_drvinfo(struct net_device *netdev,
 	struct ethtool_drvinfo *drvinfo)
 {
 	struct enic *enic = netdev_priv(netdev);
 	struct vnic_devcmd_fw_info *fw_info;
 
-	spin_lock(&enic->devcmd_lock);
-	vnic_dev_fw_info(enic->vdev, &fw_info);
-	spin_unlock(&enic->devcmd_lock);
+	enic_dev_fw_info(enic, &fw_info);
 
 	strncpy(drvinfo->driver, DRV_NAME, sizeof(drvinfo->driver));
 	strncpy(drvinfo->version, DRV_VERSION, sizeof(drvinfo->version));
@@ -191,6 +201,17 @@ static int enic_get_sset_count(struct net_device *netdev, int sset)
 	}
 }
 
+static int enic_dev_stats_dump(struct enic *enic, struct vnic_stats **vstats)
+{
+	int err;
+
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_stats_dump(enic->vdev, vstats);
+	spin_unlock(&enic->devcmd_lock);
+
+	return err;
+}
+
 static void enic_get_ethtool_stats(struct net_device *netdev,
 	struct ethtool_stats *stats, u64 *data)
 {
@@ -198,9 +219,7 @@ static void enic_get_ethtool_stats(struct net_device *netdev,
 	struct vnic_stats *vstats;
 	unsigned int i;
 
-	spin_lock(&enic->devcmd_lock);
-	vnic_dev_stats_dump(enic->vdev, &vstats);
-	spin_unlock(&enic->devcmd_lock);
+	enic_dev_stats_dump(enic, &vstats);
 
 	for (i = 0; i < enic_n_tx_stats; i++)
 		*(data++) = ((u64 *)&vstats->tx)[enic_tx_stats[i].offset];
@@ -411,17 +430,14 @@ static void enic_log_q_error(struct enic *enic)
 	}
 }
 
-static void enic_link_check(struct enic *enic)
+static void enic_msglvl_check(struct enic *enic)
 {
-	int link_status = vnic_dev_link_status(enic->vdev);
-	int carrier_ok = netif_carrier_ok(enic->netdev);
+	u32 msg_enable = vnic_dev_msg_lvl(enic->vdev);
 
-	if (link_status && !carrier_ok) {
-		printk(KERN_INFO PFX "%s: Link UP\n", enic->netdev->name);
-		netif_carrier_on(enic->netdev);
-	} else if (!link_status && carrier_ok) {
-		printk(KERN_INFO PFX "%s: Link DOWN\n", enic->netdev->name);
-		netif_carrier_off(enic->netdev);
+	if (msg_enable != enic->msg_enable) {
+		printk(KERN_INFO PFX "%s: msg lvl changed from 0x%x to 0x%x\n",
+			enic->netdev->name, enic->msg_enable, msg_enable);
+		enic->msg_enable = msg_enable;
 	}
 }
 
@@ -439,14 +455,17 @@ static void enic_mtu_check(struct enic *enic)
 	}
 }
 
-static void enic_msglvl_check(struct enic *enic)
+static void enic_link_check(struct enic *enic)
 {
-	u32 msg_enable = vnic_dev_msg_lvl(enic->vdev);
+	int link_status = vnic_dev_link_status(enic->vdev);
+	int carrier_ok = netif_carrier_ok(enic->netdev);
 
-	if (msg_enable != enic->msg_enable) {
-		printk(KERN_INFO PFX "%s: msg lvl changed from 0x%x to 0x%x\n",
-			enic->netdev->name, enic->msg_enable, msg_enable);
-		enic->msg_enable = msg_enable;
+	if (link_status && !carrier_ok) {
+		printk(KERN_INFO PFX "%s: Link UP\n", enic->netdev->name);
+		netif_carrier_on(enic->netdev);
+	} else if (!link_status && carrier_ok) {
+		printk(KERN_INFO PFX "%s: Link DOWN\n", enic->netdev->name);
+		netif_carrier_off(enic->netdev);
 	}
 }
 
@@ -792,9 +811,7 @@ static struct net_device_stats *enic_get_stats(struct net_device *netdev)
 	struct net_device_stats *net_stats = &netdev->stats;
 	struct vnic_stats *stats;
 
-	spin_lock(&enic->devcmd_lock);
-	vnic_dev_stats_dump(enic->vdev, &stats);
-	spin_unlock(&enic->devcmd_lock);
+	enic_dev_stats_dump(enic, &stats);
 
 	net_stats->tx_packets = stats->tx.tx_frames_ok;
 	net_stats->tx_bytes = stats->tx.tx_bytes_ok;
@@ -892,6 +909,41 @@ static int enic_set_mac_address(struct net_device *netdev, void *p)
 	return -EOPNOTSUPP;
 }
 
+static int enic_dev_packet_filter(struct enic *enic, int directed,
+	int multicast, int broadcast, int promisc, int allmulti)
+{
+	int err;
+
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_packet_filter(enic->vdev, directed,
+		multicast, broadcast, promisc, allmulti);
+	spin_unlock(&enic->devcmd_lock);
+
+	return err;
+}
+
+static int enic_dev_add_multicast_addr(struct enic *enic, u8 *addr)
+{
+	int err;
+
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_add_addr(enic->vdev, addr);
+	spin_unlock(&enic->devcmd_lock);
+
+	return err;
+}
+
+static int enic_dev_del_multicast_addr(struct enic *enic, u8 *addr)
+{
+	int err;
+
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_del_addr(enic->vdev, addr);
+	spin_unlock(&enic->devcmd_lock);
+
+	return err;
+}
+
 /* netif_tx_lock held, BHs disabled */
 static void enic_set_multicast_list(struct net_device *netdev)
 {
@@ -911,11 +963,9 @@ static void enic_set_multicast_list(struct net_device *netdev)
 	if (mc_count > ENIC_MULTICAST_PERFECT_FILTERS)
 		mc_count = ENIC_MULTICAST_PERFECT_FILTERS;
 
-	spin_lock(&enic->devcmd_lock);
-
 	if (enic->flags != flags) {
 		enic->flags = flags;
-		vnic_dev_packet_filter(enic->vdev, directed,
+		enic_dev_packet_filter(enic, directed,
 			multicast, broadcast, promisc, allmulti);
 	}
 
@@ -938,7 +988,7 @@ static void enic_set_multicast_list(struct net_device *netdev)
 				mc_addr[j]) == 0)
 				break;
 		if (j == mc_count)
-			enic_del_multicast_addr(enic, enic->mc_addr[i]);
+			enic_dev_del_multicast_addr(enic, enic->mc_addr[i]);
 	}
 
 	for (i = 0; i < mc_count; i++) {
@@ -947,7 +997,7 @@ static void enic_set_multicast_list(struct net_device *netdev)
 				enic->mc_addr[j]) == 0)
 				break;
 		if (j == enic->mc_count)
-			enic_add_multicast_addr(enic, mc_addr[i]);
+			enic_dev_add_multicast_addr(enic, mc_addr[i]);
 	}
 
 	/* Save the list to compare against next time
@@ -957,8 +1007,6 @@ static void enic_set_multicast_list(struct net_device *netdev)
 		memcpy(enic->mc_addr[i], mc_addr[i], ETH_ALEN);
 
 	enic->mc_count = mc_count;
-
-	spin_unlock(&enic->devcmd_lock);
 }
 
 /* rtnl lock is held */
@@ -1264,12 +1312,24 @@ static int enic_rq_alloc_buf_a1(struct vnic_rq *rq)
 	return 0;
 }
 
+static int enic_dev_hw_version(struct enic *enic,
+	enum vnic_dev_hw_version *hw_ver)
+{
+	int err;
+
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_hw_version(enic->vdev, hw_ver);
+	spin_unlock(&enic->devcmd_lock);
+
+	return err;
+}
+
 static int enic_set_rq_alloc_buf(struct enic *enic)
 {
 	enum vnic_dev_hw_version hw_ver;
 	int err;
 
-	err = vnic_dev_hw_version(enic->vdev, &hw_ver);
+	err = enic_dev_hw_version(enic, &hw_ver);
 	if (err)
 		return err;
 
@@ -1603,7 +1663,7 @@ static void enic_synchronize_irqs(struct enic *enic)
 	}
 }
 
-static int enic_notify_set(struct enic *enic)
+static int enic_dev_notify_set(struct enic *enic)
 {
 	int err;
 
@@ -1624,6 +1684,39 @@ static int enic_notify_set(struct enic *enic)
 	return err;
 }
 
+static int enic_dev_notify_unset(struct enic *enic)
+{
+	int err;
+
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_notify_unset(enic->vdev);
+	spin_unlock(&enic->devcmd_lock);
+
+	return err;
+}
+
+static int enic_dev_enable(struct enic *enic)
+{
+	int err;
+
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_enable(enic->vdev);
+	spin_unlock(&enic->devcmd_lock);
+
+	return err;
+}
+
+static int enic_dev_disable(struct enic *enic)
+{
+	int err;
+
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_disable(enic->vdev);
+	spin_unlock(&enic->devcmd_lock);
+
+	return err;
+}
+
 static void enic_notify_timer_start(struct enic *enic)
 {
 	switch (vnic_dev_get_intr_mode(enic->vdev)) {
@@ -1650,7 +1743,7 @@ static int enic_open(struct net_device *netdev)
 		return err;
 	}
 
-	err = enic_notify_set(enic);
+	err = enic_dev_notify_set(enic);
 	if (err) {
 		printk(KERN_ERR PFX
 			"%s: Failed to alloc notify buffer, aborting.\n",
@@ -1680,9 +1773,7 @@ static int enic_open(struct net_device *netdev)
 
 	netif_wake_queue(netdev);
 	napi_enable(&enic->napi);
-	spin_lock(&enic->devcmd_lock);
-	vnic_dev_enable(enic->vdev);
-	spin_unlock(&enic->devcmd_lock);
+	enic_dev_enable(enic);
 
 	for (i = 0; i < enic->intr_count; i++)
 		vnic_intr_unmask(&enic->intr[i]);
@@ -1692,9 +1783,7 @@ static int enic_open(struct net_device *netdev)
 	return 0;
 
 err_out_notify_unset:
-	spin_lock(&enic->devcmd_lock);
-	vnic_dev_notify_unset(enic->vdev);
-	spin_unlock(&enic->devcmd_lock);
+	enic_dev_notify_unset(enic);
 err_out_free_intr:
 	enic_free_intr(enic);
 
@@ -1715,9 +1804,7 @@ static int enic_stop(struct net_device *netdev)
 
 	del_timer_sync(&enic->notify_timer);
 
-	spin_lock(&enic->devcmd_lock);
-	vnic_dev_disable(enic->vdev);
-	spin_unlock(&enic->devcmd_lock);
+	enic_dev_disable(enic);
 	napi_disable(&enic->napi);
 	netif_carrier_off(netdev);
 	netif_tx_disable(netdev);
@@ -1735,9 +1822,7 @@ static int enic_stop(struct net_device *netdev)
 			return err;
 	}
 
-	spin_lock(&enic->devcmd_lock);
-	vnic_dev_notify_unset(enic->vdev);
-	spin_unlock(&enic->devcmd_lock);
+	enic_dev_notify_unset(enic);
 	enic_free_intr(enic);
 
 	for (i = 0; i < enic->wq_count; i++)
@@ -1870,15 +1955,31 @@ static int enic_set_niccfg(struct enic *enic)
 	const u8 rss_enable = 0;
 	const u8 tso_ipid_split_en = 0;
 	const u8 ig_vlan_strip_en = 1;
+	int err;
 
 	/* Enable VLAN tag stripping.  RSS not enabled (yet).
 	 */
 
-	return enic_set_nic_cfg(enic,
+	spin_lock(&enic->devcmd_lock);
+	err = enic_set_nic_cfg(enic,
 		rss_default_cpu, rss_hash_type,
 		rss_hash_bits, rss_base_cpu,
 		rss_enable, tso_ipid_split_en,
 		ig_vlan_strip_en);
+	spin_unlock(&enic->devcmd_lock);
+
+	return err;
+}
+
+static int enic_dev_hang_notify(struct enic *enic)
+{
+	int err;
+
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_hang_notify(enic->vdev);
+	spin_unlock(&enic->devcmd_lock);
+
+	return err;
 }
 
 int enic_dev_set_ig_vlan_rewrite_mode(struct enic *enic)
@@ -1902,10 +2003,7 @@ static void enic_reset(struct work_struct *work)
 
 	rtnl_lock();
 
-	spin_lock(&enic->devcmd_lock);
-	vnic_dev_hang_notify(enic->vdev);
-	spin_unlock(&enic->devcmd_lock);
-
+	enic_dev_hang_notify(enic);
 	enic_stop(enic->netdev);
 	enic_dev_hang_reset(enic);
 	enic_reset_multicast_list(enic);
@@ -2047,8 +2145,8 @@ static const struct net_device_ops enic_netdev_ops = {
 	.ndo_start_xmit		= enic_hard_start_xmit,
 	.ndo_get_stats		= enic_get_stats,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_multicast_list	= enic_set_multicast_list,
 	.ndo_set_mac_address	= enic_set_mac_address,
+	.ndo_set_multicast_list	= enic_set_multicast_list,
 	.ndo_change_mtu		= enic_change_mtu,
 	.ndo_vlan_rx_register	= enic_vlan_rx_register,
 	.ndo_vlan_rx_add_vid	= enic_vlan_rx_add_vid,
@@ -2066,6 +2164,17 @@ void enic_dev_deinit(struct enic *enic)
 	enic_clear_intr_mode(enic);
 }
 
+static int enic_dev_stats_clear(struct enic *enic)
+{
+	int err;
+
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_stats_clear(enic->vdev);
+	spin_unlock(&enic->devcmd_lock);
+
+	return err;
+}
+
 int enic_dev_init(struct enic *enic)
 {
 	struct net_device *netdev = enic->netdev;
@@ -2110,6 +2219,10 @@ int enic_dev_init(struct enic *enic)
 
 	enic_init_vnic_resources(enic);
 
+	/* Clear LIF stats
+	 */
+	enic_dev_stats_clear(enic);
+
 	err = enic_set_rq_alloc_buf(enic);
 	if (err) {
 		printk(KERN_ERR PFX
@@ -2293,6 +2406,11 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 		}
 	}
 
+	/* Setup devcmd lock
+	 */
+
+	spin_lock_init(&enic->devcmd_lock);
+
 	err = enic_dev_init(enic);
 	if (err) {
 		printk(KERN_ERR PFX
@@ -2300,7 +2418,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 		goto err_out_dev_close;
 	}
 
-	/* Setup notification timer, HW reset task, and locks
+	/* Setup notification timer, HW reset task, and wq locks
 	 */
 
 	init_timer(&enic->notify_timer);
@@ -2312,8 +2430,6 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	for (i = 0; i < enic->wq_count; i++)
 		spin_lock_init(&enic->wq_lock[i]);
 
-	spin_lock_init(&enic->devcmd_lock);
-
 	/* Register net device
 	 */
 
diff --git a/drivers/net/enic/enic_res.c b/drivers/net/enic/enic_res.c
index 9b18840..04cfc4e 100644
--- a/drivers/net/enic/enic_res.c
+++ b/drivers/net/enic/enic_res.c
@@ -103,17 +103,7 @@ int enic_get_vnic_config(struct enic *enic)
 	return 0;
 }
 
-void enic_add_multicast_addr(struct enic *enic, u8 *addr)
-{
-	vnic_dev_add_addr(enic->vdev, addr);
-}
-
-void enic_del_multicast_addr(struct enic *enic, u8 *addr)
-{
-	vnic_dev_del_addr(enic->vdev, addr);
-}
-
-void enic_add_vlan(struct enic *enic, u16 vlanid)
+int enic_add_vlan(struct enic *enic, u16 vlanid)
 {
 	u64 a0 = vlanid, a1 = 0;
 	int wait = 1000;
@@ -122,9 +112,11 @@ void enic_add_vlan(struct enic *enic, u16 vlanid)
 	err = vnic_dev_cmd(enic->vdev, CMD_VLAN_ADD, &a0, &a1, wait);
 	if (err)
 		printk(KERN_ERR PFX "Can't add vlan id, %d\n", err);
+
+	return err;
 }
 
-void enic_del_vlan(struct enic *enic, u16 vlanid)
+int enic_del_vlan(struct enic *enic, u16 vlanid)
 {
 	u64 a0 = vlanid, a1 = 0;
 	int wait = 1000;
@@ -133,6 +125,8 @@ void enic_del_vlan(struct enic *enic, u16 vlanid)
 	err = vnic_dev_cmd(enic->vdev, CMD_VLAN_DEL, &a0, &a1, wait);
 	if (err)
 		printk(KERN_ERR PFX "Can't delete vlan id, %d\n", err);
+
+	return err;
 }
 
 int enic_set_nic_cfg(struct enic *enic, u8 rss_default_cpu, u8 rss_hash_type,
@@ -304,11 +298,6 @@ void enic_init_vnic_resources(struct enic *enic)
 			enic->config.intr_timer_type,
 			mask_on_assertion);
 	}
-
-	/* Clear LIF stats
-	 */
-
-	vnic_dev_stats_clear(enic->vdev);
 }
 
 int enic_alloc_vnic_resources(struct enic *enic)
diff --git a/drivers/net/enic/enic_res.h b/drivers/net/enic/enic_res.h
index 494664f..3f6e039 100644
--- a/drivers/net/enic/enic_res.h
+++ b/drivers/net/enic/enic_res.h
@@ -131,10 +131,8 @@ static inline void enic_queue_rq_desc(struct vnic_rq *rq,
 struct enic;
 
 int enic_get_vnic_config(struct enic *);
-void enic_add_multicast_addr(struct enic *enic, u8 *addr);
-void enic_del_multicast_addr(struct enic *enic, u8 *addr);
-void enic_add_vlan(struct enic *enic, u16 vlanid);
-void enic_del_vlan(struct enic *enic, u16 vlanid);
+int enic_add_vlan(struct enic *enic, u16 vlanid);
+int enic_del_vlan(struct enic *enic, u16 vlanid);
 int enic_set_nic_cfg(struct enic *enic, u8 rss_default_cpu, u8 rss_hash_type,
 	u8 rss_hash_bits, u8 rss_base_cpu, u8 rss_enable, u8 tso_ipid_split_en,
 	u8 ig_vlan_strip_en);
diff --git a/drivers/net/enic/vnic_dev.c b/drivers/net/enic/vnic_dev.c
index c93012f..bebadb3 100644
--- a/drivers/net/enic/vnic_dev.c
+++ b/drivers/net/enic/vnic_dev.c
@@ -550,7 +550,7 @@ int vnic_dev_mac_addr(struct vnic_dev *vdev, u8 *mac_addr)
 	return 0;
 }
 
-void vnic_dev_packet_filter(struct vnic_dev *vdev, int directed, int multicast,
+int vnic_dev_packet_filter(struct vnic_dev *vdev, int directed, int multicast,
 	int broadcast, int promisc, int allmulti)
 {
 	u64 a0, a1 = 0;
@@ -566,6 +566,8 @@ void vnic_dev_packet_filter(struct vnic_dev *vdev, int directed, int multicast,
 	err = vnic_dev_cmd(vdev, CMD_PACKET_FILTER, &a0, &a1, wait);
 	if (err)
 		printk(KERN_ERR "Can't set packet filter\n");
+
+	return err;
 }
 
 int vnic_dev_add_addr(struct vnic_dev *vdev, u8 *addr)
@@ -670,22 +672,25 @@ int vnic_dev_notify_set(struct vnic_dev *vdev, u16 intr)
 	return vnic_dev_notify_setcmd(vdev, notify_addr, notify_pa, intr);
 }
 
-void vnic_dev_notify_unsetcmd(struct vnic_dev *vdev)
+int vnic_dev_notify_unsetcmd(struct vnic_dev *vdev)
 {
 	u64 a0, a1;
 	int wait = 1000;
+	int err;
 
 	a0 = 0;  /* paddr = 0 to unset notify buffer */
 	a1 = 0x0000ffff00000000ULL; /* intr num = -1 to unreg for intr */
 	a1 += sizeof(struct vnic_devcmd_notify);
 
-	vnic_dev_cmd(vdev, CMD_NOTIFY, &a0, &a1, wait);
+	err = vnic_dev_cmd(vdev, CMD_NOTIFY, &a0, &a1, wait);
 	vdev->notify = NULL;
 	vdev->notify_pa = 0;
 	vdev->notify_sz = 0;
+
+	return err;
 }
 
-void vnic_dev_notify_unset(struct vnic_dev *vdev)
+int vnic_dev_notify_unset(struct vnic_dev *vdev)
 {
 	if (vdev->notify) {
 		pci_free_consistent(vdev->pdev,
@@ -694,7 +699,7 @@ void vnic_dev_notify_unset(struct vnic_dev *vdev)
 			vdev->notify_pa);
 	}
 
-	vnic_dev_notify_unsetcmd(vdev);
+	return vnic_dev_notify_unsetcmd(vdev);
 }
 
 static int vnic_dev_notify_ready(struct vnic_dev *vdev)
@@ -839,6 +844,14 @@ u32 vnic_dev_notify_status(struct vnic_dev *vdev)
 	return vdev->notify_copy.status;
 }
 
+u32 vnic_dev_uif(struct vnic_dev *vdev)
+{
+	if (!vnic_dev_notify_ready(vdev))
+		return 0;
+
+	return vdev->notify_copy.uif;
+}
+
 void vnic_dev_set_intr_mode(struct vnic_dev *vdev,
 	enum vnic_dev_intr_mode intr_mode)
 {
diff --git a/drivers/net/enic/vnic_dev.h b/drivers/net/enic/vnic_dev.h
index 4980615..3a29681 100644
--- a/drivers/net/enic/vnic_dev.h
+++ b/drivers/net/enic/vnic_dev.h
@@ -101,7 +101,7 @@ int vnic_dev_spec(struct vnic_dev *vdev, unsigned int offset, unsigned int size,
 int vnic_dev_stats_clear(struct vnic_dev *vdev);
 int vnic_dev_stats_dump(struct vnic_dev *vdev, struct vnic_stats **stats);
 int vnic_dev_hang_notify(struct vnic_dev *vdev);
-void vnic_dev_packet_filter(struct vnic_dev *vdev, int directed, int multicast,
+int vnic_dev_packet_filter(struct vnic_dev *vdev, int directed, int multicast,
 	int broadcast, int promisc, int allmulti);
 int vnic_dev_add_addr(struct vnic_dev *vdev, u8 *addr);
 int vnic_dev_del_addr(struct vnic_dev *vdev, u8 *addr);
@@ -110,14 +110,15 @@ int vnic_dev_raise_intr(struct vnic_dev *vdev, u16 intr);
 int vnic_dev_notify_setcmd(struct vnic_dev *vdev,
 	void *notify_addr, dma_addr_t notify_pa, u16 intr);
 int vnic_dev_notify_set(struct vnic_dev *vdev, u16 intr);
-void vnic_dev_notify_unsetcmd(struct vnic_dev *vdev);
-void vnic_dev_notify_unset(struct vnic_dev *vdev);
+int vnic_dev_notify_unsetcmd(struct vnic_dev *vdev);
+int vnic_dev_notify_unset(struct vnic_dev *vdev);
 int vnic_dev_link_status(struct vnic_dev *vdev);
 u32 vnic_dev_port_speed(struct vnic_dev *vdev);
 u32 vnic_dev_msg_lvl(struct vnic_dev *vdev);
 u32 vnic_dev_mtu(struct vnic_dev *vdev);
 u32 vnic_dev_link_down_cnt(struct vnic_dev *vdev);
 u32 vnic_dev_notify_status(struct vnic_dev *vdev);
+u32 vnic_dev_uif(struct vnic_dev *vdev);
 int vnic_dev_close(struct vnic_dev *vdev);
 int vnic_dev_enable(struct vnic_dev *vdev);
 int vnic_dev_disable(struct vnic_dev *vdev);

