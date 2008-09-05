From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 06/18] netdevice chelsio: Convert directly reference of netdev->priv
 to netdev->ml_priv
Date: Fri, 05 Sep 2008 11:15:29 +0800
Message-ID: <48C0A451.10001@cn.fujitsu.com>
References: <48C0A219.2030004@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, NETDEV <netdev@vger.kernel.org>,
	divy@chelsio.com
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59045 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752489AbYIEDRw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2008 23:17:52 -0400
In-Reply-To: <48C0A219.2030004@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have some reasons to kill netdev->priv:
1. netdev->priv is equal to netdev_priv().
2. netdev_priv() wraps the calculation of netdev->priv's offset, obviously
   netdev_priv() is more flexible than netdev->priv.
But we cann't kill netdev->priv, because so many drivers reference to it
directly.

OK, becasue Dave S. Miller said, "every direct netdev->priv usage is a bug",
and I want to kill netdev->priv later, I decided to convert all the direct
reference of netdev->priv first.

Different to readonly reference of netdev->priv, in this driver, netdev->priv
was changed. I use netdev->ml_priv to replace netdev->priv.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/chelsio/cxgb2.c |   60 +++++++++++++++++++++---------------------
 drivers/net/chelsio/sge.c   |    2 +-
 2 files changed, 31 insertions(+), 31 deletions(-)

diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index 638c9a2..5fb0038 100644
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -120,7 +120,7 @@ static const char pci_speed[][4] = {
  */
 static void t1_set_rxmode(struct net_device *dev)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = dev->ml_priv;
 	struct cmac *mac = adapter->port[dev->if_port].mac;
 	struct t1_rx_mode rm;
 
@@ -252,7 +252,7 @@ static void cxgb_down(struct adapter *adapter)
 static int cxgb_open(struct net_device *dev)
 {
 	int err;
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = dev->ml_priv;
 	int other_ports = adapter->open_device_map & PORT_MASK;
 
 	napi_enable(&adapter->napi);
@@ -272,7 +272,7 @@ static int cxgb_open(struct net_device *dev)
 
 static int cxgb_close(struct net_device *dev)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = dev->ml_priv;
 	struct port_info *p = &adapter->port[dev->if_port];
 	struct cmac *mac = p->mac;
 
@@ -298,7 +298,7 @@ static int cxgb_close(struct net_device *dev)
 
 static struct net_device_stats *t1_get_stats(struct net_device *dev)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = dev->ml_priv;
 	struct port_info *p = &adapter->port[dev->if_port];
 	struct net_device_stats *ns = &p->netstats;
 	const struct cmac_statistics *pstats;
@@ -346,14 +346,14 @@ static struct net_device_stats *t1_get_stats(struct net_device *dev)
 
 static u32 get_msglevel(struct net_device *dev)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = dev->ml_priv;
 
 	return adapter->msg_enable;
 }
 
 static void set_msglevel(struct net_device *dev, u32 val)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = dev->ml_priv;
 
 	adapter->msg_enable = val;
 }
@@ -434,7 +434,7 @@ static int get_regs_len(struct net_device *dev)
 
 static void get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = dev->ml_priv;
 
 	strcpy(info->driver, DRV_NAME);
 	strcpy(info->version, DRV_VERSION);
@@ -461,7 +461,7 @@ static void get_strings(struct net_device *dev, u32 stringset, u8 *data)
 static void get_stats(struct net_device *dev, struct ethtool_stats *stats,
 		      u64 *data)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = dev->ml_priv;
 	struct cmac *mac = adapter->port[dev->if_port].mac;
 	const struct cmac_statistics *s;
 	const struct sge_intr_counts *t;
@@ -552,7 +552,7 @@ static inline void reg_block_dump(struct adapter *ap, void *buf,
 static void get_regs(struct net_device *dev, struct ethtool_regs *regs,
 		     void *buf)
 {
-	struct adapter *ap = dev->priv;
+	struct adapter *ap = dev->ml_priv;
 
 	/*
 	 * Version scheme: bits 0..9: chip version, bits 10..15: chip revision
@@ -574,7 +574,7 @@ static void get_regs(struct net_device *dev, struct ethtool_regs *regs,
 
 static int get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = dev->ml_priv;
 	struct port_info *p = &adapter->port[dev->if_port];
 
 	cmd->supported = p->link_config.supported;
@@ -634,7 +634,7 @@ static int speed_duplex_to_caps(int speed, int duplex)
 
 static int set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = dev->ml_priv;
 	struct port_info *p = &adapter->port[dev->if_port];
 	struct link_config *lc = &p->link_config;
 
@@ -669,7 +669,7 @@ static int set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 static void get_pauseparam(struct net_device *dev,
 			   struct ethtool_pauseparam *epause)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = dev->ml_priv;
 	struct port_info *p = &adapter->port[dev->if_port];
 
 	epause->autoneg = (p->link_config.requested_fc & PAUSE_AUTONEG) != 0;
@@ -680,7 +680,7 @@ static void get_pauseparam(struct net_device *dev,
 static int set_pauseparam(struct net_device *dev,
 			  struct ethtool_pauseparam *epause)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = dev->ml_priv;
 	struct port_info *p = &adapter->port[dev->if_port];
 	struct link_config *lc = &p->link_config;
 
@@ -709,14 +709,14 @@ static int set_pauseparam(struct net_device *dev,
 
 static u32 get_rx_csum(struct net_device *dev)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = dev->ml_priv;
 
 	return (adapter->flags & RX_CSUM_ENABLED) != 0;
 }
 
 static int set_rx_csum(struct net_device *dev, u32 data)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = dev->ml_priv;
 
 	if (data)
 		adapter->flags |= RX_CSUM_ENABLED;
@@ -727,7 +727,7 @@ static int set_rx_csum(struct net_device *dev, u32 data)
 
 static int set_tso(struct net_device *dev, u32 value)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = dev->ml_priv;
 
 	if (!(adapter->flags & TSO_CAPABLE))
 		return value ? -EOPNOTSUPP : 0;
@@ -736,7 +736,7 @@ static int set_tso(struct net_device *dev, u32 value)
 
 static void get_sge_param(struct net_device *dev, struct ethtool_ringparam *e)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = dev->ml_priv;
 	int jumbo_fl = t1_is_T1B(adapter) ? 1 : 0;
 
 	e->rx_max_pending = MAX_RX_BUFFERS;
@@ -752,7 +752,7 @@ static void get_sge_param(struct net_device *dev, struct ethtool_ringparam *e)
 
 static int set_sge_param(struct net_device *dev, struct ethtool_ringparam *e)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = dev->ml_priv;
 	int jumbo_fl = t1_is_T1B(adapter) ? 1 : 0;
 
 	if (e->rx_pending > MAX_RX_BUFFERS || e->rx_mini_pending ||
@@ -776,7 +776,7 @@ static int set_sge_param(struct net_device *dev, struct ethtool_ringparam *e)
 
 static int set_coalesce(struct net_device *dev, struct ethtool_coalesce *c)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = dev->ml_priv;
 
 	adapter->params.sge.rx_coalesce_usecs = c->rx_coalesce_usecs;
 	adapter->params.sge.coalesce_enable = c->use_adaptive_rx_coalesce;
@@ -787,7 +787,7 @@ static int set_coalesce(struct net_device *dev, struct ethtool_coalesce *c)
 
 static int get_coalesce(struct net_device *dev, struct ethtool_coalesce *c)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = dev->ml_priv;
 
 	c->rx_coalesce_usecs = adapter->params.sge.rx_coalesce_usecs;
 	c->rate_sample_interval = adapter->params.sge.sample_interval_usecs;
@@ -797,7 +797,7 @@ static int get_coalesce(struct net_device *dev, struct ethtool_coalesce *c)
 
 static int get_eeprom_len(struct net_device *dev)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = dev->ml_priv;
 
 	return t1_is_asic(adapter) ? EEPROM_SIZE : 0;
 }
@@ -810,7 +810,7 @@ static int get_eeprom(struct net_device *dev, struct ethtool_eeprom *e,
 {
 	int i;
 	u8 buf[EEPROM_SIZE] __attribute__((aligned(4)));
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = dev->ml_priv;
 
 	e->magic = EEPROM_MAGIC(adapter);
 	for (i = e->offset & ~3; i < e->offset + e->len; i += sizeof(u32))
@@ -848,7 +848,7 @@ static const struct ethtool_ops t1_ethtool_ops = {
 
 static int t1_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = dev->ml_priv;
 	struct mii_ioctl_data *data = if_mii(req);
 
 	switch (cmd) {
@@ -887,7 +887,7 @@ static int t1_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 static int t1_change_mtu(struct net_device *dev, int new_mtu)
 {
 	int ret;
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = dev->ml_priv;
 	struct cmac *mac = adapter->port[dev->if_port].mac;
 
 	if (!mac->ops->set_mtu)
@@ -902,7 +902,7 @@ static int t1_change_mtu(struct net_device *dev, int new_mtu)
 
 static int t1_set_mac_addr(struct net_device *dev, void *p)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = dev->ml_priv;
 	struct cmac *mac = adapter->port[dev->if_port].mac;
 	struct sockaddr *addr = p;
 
@@ -918,7 +918,7 @@ static int t1_set_mac_addr(struct net_device *dev, void *p)
 static void vlan_rx_register(struct net_device *dev,
 				   struct vlan_group *grp)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = dev->ml_priv;
 
 	spin_lock_irq(&adapter->async_lock);
 	adapter->vlan_grp = grp;
@@ -931,7 +931,7 @@ static void vlan_rx_register(struct net_device *dev,
 static void t1_netpoll(struct net_device *dev)
 {
 	unsigned long flags;
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = dev->ml_priv;
 
 	local_irq_save(flags);
 	t1_interrupt(adapter->pdev->irq, adapter);
@@ -1077,7 +1077,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 		SET_NETDEV_DEV(netdev, &pdev->dev);
 
 		if (!adapter) {
-			adapter = netdev->priv;
+			adapter = netdev_priv(netdev);
 			adapter->pdev = pdev;
 			adapter->port[0].dev = netdev;  /* so we don't leak it */
 
@@ -1118,7 +1118,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 		netdev->if_port = i;
 		netdev->mem_start = mmio_start;
 		netdev->mem_end = mmio_start + mmio_len - 1;
-		netdev->priv = adapter;
+		netdev->ml_priv = adapter;
 		netdev->features |= NETIF_F_SG | NETIF_F_IP_CSUM;
 		netdev->features |= NETIF_F_LLTX;
 
@@ -1382,7 +1382,7 @@ static inline void t1_sw_reset(struct pci_dev *pdev)
 static void __devexit remove_one(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = dev->ml_priv;
 	int i;
 
 	for_each_port(adapter, i) {
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index d6c7d2a..27cf059 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -1786,7 +1786,7 @@ static inline int eth_hdr_len(const void *data)
  */
 int t1_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct adapter *adapter = dev->priv;
+	struct adapter *adapter = dev->ml_priv;
 	struct sge *sge = adapter->sge;
 	struct sge_port_stats *st = per_cpu_ptr(sge->port_stats[dev->if_port],
 						smp_processor_id());
-- 
1.5.3.4


