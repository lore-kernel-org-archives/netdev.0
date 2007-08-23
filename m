From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2.6.23 RESEND] cxgb3 - Fix dev->priv usage
Date: Thu, 23 Aug 2007 15:06:28 -0700
Message-ID: <20070823220628.9835.73819.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:21386 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758578AbXHWWGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2007 18:06:33 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

cxgb3 used netdev_priv() and dev->priv for different purposes.
In 2.6.23, netdev_priv() == dev->priv, cxgb3 needs a fix.
This patch is a partial backport of Dave Miller's changes in the 
net-2.6.24 git branch. 

Without this fix, cxgb3 crashes on 2.6.23.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/adapter.h       |   10 +++
 drivers/net/cxgb3/cxgb3_main.c    |  126 +++++++++++++++++++++----------------
 drivers/net/cxgb3/cxgb3_offload.c |    6 +-
 drivers/net/cxgb3/sge.c           |   23 ++++---
 drivers/net/cxgb3/t3cdev.h        |    3 -
 5 files changed, 100 insertions(+), 68 deletions(-)

diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index ab72563..c1dc344 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -50,7 +50,9 @@ typedef irqreturn_t(*intr_handler_t) (int, void *);
 
 struct vlan_group;
 
+struct adapter;
 struct port_info {
+	struct adapter *adapter;
 	struct vlan_group *vlan_grp;
 	const struct port_type_info *port_type;
 	u8 port_id;
@@ -246,6 +248,14 @@ static inline void t3_write_reg(struct adapter *adapter, u32 reg_addr, u32 val)
 	writel(val, adapter->regs + reg_addr);
 }
 
+/* Get the t3cdev associated with a net_device */
+static inline struct t3cdev *dev2t3cdev(struct net_device *dev)
+{
+	const struct port_info *pi = netdev_priv(dev);
+
+	return (struct t3cdev *)pi->adapter;
+}
+
 static inline struct port_info *adap2pinfo(struct adapter *adap, int idx)
 {
 	return netdev_priv(adap->port[idx]);
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index dc5d269..f3bf128 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -358,11 +358,14 @@ static int init_dummy_netdevs(struct adapter *adap)
 
 		for (j = 0; j < pi->nqsets - 1; j++) {
 			if (!adap->dummy_netdev[dummy_idx]) {
-				nd = alloc_netdev(0, "", ether_setup);
+				struct port_info *p;
+
+				nd = alloc_netdev(sizeof(*p), "", ether_setup);
 				if (!nd)
 					goto free_all;
 
-				nd->priv = adap;
+				p = netdev_priv(nd);
+				p->adapter = adap;
 				nd->weight = 64;
 				set_bit(__LINK_STATE_START, &nd->state);
 				adap->dummy_netdev[dummy_idx] = nd;
@@ -482,7 +485,8 @@ static ssize_t attr_store(struct device *d, struct device_attribute *attr,
 #define CXGB3_SHOW(name, val_expr) \
 static ssize_t format_##name(struct net_device *dev, char *buf) \
 { \
-	struct adapter *adap = dev->priv; \
+	struct port_info *pi = netdev_priv(dev); \
+	struct adapter *adap = pi->adapter; \
 	return sprintf(buf, "%u\n", val_expr); \
 } \
 static ssize_t show_##name(struct device *d, struct device_attribute *attr, \
@@ -493,7 +497,8 @@ static ssize_t show_##name(struct device *d, struct device_attribute *attr, \
 
 static ssize_t set_nfilters(struct net_device *dev, unsigned int val)
 {
-	struct adapter *adap = dev->priv;
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adap = pi->adapter;
 	int min_tids = is_offload(adap) ? MC5_MIN_TIDS : 0;
 
 	if (adap->flags & FULL_INIT_DONE)
@@ -515,7 +520,8 @@ static ssize_t store_nfilters(struct device *d, struct device_attribute *attr,
 
 static ssize_t set_nservers(struct net_device *dev, unsigned int val)
 {
-	struct adapter *adap = dev->priv;
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adap = pi->adapter;
 
 	if (adap->flags & FULL_INIT_DONE)
 		return -EBUSY;
@@ -556,9 +562,10 @@ static struct attribute_group cxgb3_attr_group = {.attrs = cxgb3_attrs };
 static ssize_t tm_attr_show(struct device *d, struct device_attribute *attr,
 			    char *buf, int sched)
 {
-	ssize_t len;
+	struct port_info *pi = netdev_priv(to_net_dev(d));
+	struct adapter *adap = pi->adapter;
 	unsigned int v, addr, bpt, cpt;
-	struct adapter *adap = to_net_dev(d)->priv;
+	ssize_t len;
 
 	addr = A_TP_TX_MOD_Q1_Q0_RATE_LIMIT - sched / 2;
 	rtnl_lock();
@@ -581,10 +588,11 @@ static ssize_t tm_attr_show(struct device *d, struct device_attribute *attr,
 static ssize_t tm_attr_store(struct device *d, struct device_attribute *attr,
 			     const char *buf, size_t len, int sched)
 {
+	struct port_info *pi = netdev_priv(to_net_dev(d));
+	struct adapter *adap = pi->adapter;
+	unsigned int val;
 	char *endp;
 	ssize_t ret;
-	unsigned int val;
-	struct adapter *adap = to_net_dev(d)->priv;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -858,8 +866,9 @@ static void schedule_chk_task(struct adapter *adap)
 
 static int offload_open(struct net_device *dev)
 {
-	struct adapter *adapter = dev->priv;
-	struct t3cdev *tdev = T3CDEV(dev);
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
+	struct t3cdev *tdev = dev2t3cdev(dev);
 	int adap_up = adapter->open_device_map & PORT_MASK;
 	int err = 0;
 
@@ -924,10 +933,10 @@ static int offload_close(struct t3cdev *tdev)
 
 static int cxgb_open(struct net_device *dev)
 {
-	int err;
-	struct adapter *adapter = dev->priv;
 	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	int other_ports = adapter->open_device_map & PORT_MASK;
+	int err;
 
 	if (!adapter->open_device_map && (err = cxgb_up(adapter)) < 0)
 		return err;
@@ -951,17 +960,17 @@ static int cxgb_open(struct net_device *dev)
 
 static int cxgb_close(struct net_device *dev)
 {
-	struct adapter *adapter = dev->priv;
-	struct port_info *p = netdev_priv(dev);
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 
-	t3_port_intr_disable(adapter, p->port_id);
+	t3_port_intr_disable(adapter, pi->port_id);
 	netif_stop_queue(dev);
-	p->phy.ops->power_down(&p->phy, 1);
+	pi->phy.ops->power_down(&pi->phy, 1);
 	netif_carrier_off(dev);
-	t3_mac_disable(&p->mac, MAC_DIRECTION_TX | MAC_DIRECTION_RX);
+	t3_mac_disable(&pi->mac, MAC_DIRECTION_TX | MAC_DIRECTION_RX);
 
 	spin_lock(&adapter->work_lock);	/* sync with update task */
-	clear_bit(p->port_id, &adapter->open_device_map);
+	clear_bit(pi->port_id, &adapter->open_device_map);
 	spin_unlock(&adapter->work_lock);
 
 	if (!(adapter->open_device_map & PORT_MASK))
@@ -976,13 +985,13 @@ static int cxgb_close(struct net_device *dev)
 
 static struct net_device_stats *cxgb_get_stats(struct net_device *dev)
 {
-	struct adapter *adapter = dev->priv;
-	struct port_info *p = netdev_priv(dev);
-	struct net_device_stats *ns = &p->netstats;
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
+	struct net_device_stats *ns = &pi->netstats;
 	const struct mac_stats *pstats;
 
 	spin_lock(&adapter->stats_lock);
-	pstats = t3_mac_update_stats(&p->mac);
+	pstats = t3_mac_update_stats(&pi->mac);
 	spin_unlock(&adapter->stats_lock);
 
 	ns->tx_bytes = pstats->tx_octets;
@@ -1015,14 +1024,16 @@ static struct net_device_stats *cxgb_get_stats(struct net_device *dev)
 
 static u32 get_msglevel(struct net_device *dev)
 {
-	struct adapter *adapter = dev->priv;
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 
 	return adapter->msg_enable;
 }
 
 static void set_msglevel(struct net_device *dev, u32 val)
 {
-	struct adapter *adapter = dev->priv;
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 
 	adapter->msg_enable = val;
 }
@@ -1096,8 +1107,9 @@ static int get_eeprom_len(struct net_device *dev)
 
 static void get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	u32 fw_vers = 0;
-	struct adapter *adapter = dev->priv;
 
 	t3_get_fw_version(adapter, &fw_vers);
 
@@ -1136,8 +1148,8 @@ static unsigned long collect_sge_port_stats(struct adapter *adapter,
 static void get_stats(struct net_device *dev, struct ethtool_stats *stats,
 		      u64 *data)
 {
-	struct adapter *adapter = dev->priv;
 	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	const struct mac_stats *s;
 
 	spin_lock(&adapter->stats_lock);
@@ -1205,7 +1217,8 @@ static inline void reg_block_dump(struct adapter *ap, void *buf,
 static void get_regs(struct net_device *dev, struct ethtool_regs *regs,
 		     void *buf)
 {
-	struct adapter *ap = dev->priv;
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *ap = pi->adapter;
 
 	/*
 	 * Version scheme:
@@ -1246,8 +1259,9 @@ static int restart_autoneg(struct net_device *dev)
 
 static int cxgb3_phys_id(struct net_device *dev, u32 data)
 {
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	int i;
-	struct adapter *adapter = dev->priv;
 
 	if (data == 0)
 		data = 2;
@@ -1408,8 +1422,8 @@ static int set_rx_csum(struct net_device *dev, u32 data)
 
 static void get_sge_param(struct net_device *dev, struct ethtool_ringparam *e)
 {
-	const struct adapter *adapter = dev->priv;
-	const struct port_info *pi = netdev_priv(dev);
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	const struct qset_params *q = &adapter->params.sge.qset[pi->first_qset];
 
 	e->rx_max_pending = MAX_RX_BUFFERS;
@@ -1425,10 +1439,10 @@ static void get_sge_param(struct net_device *dev, struct ethtool_ringparam *e)
 
 static int set_sge_param(struct net_device *dev, struct ethtool_ringparam *e)
 {
-	int i;
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	struct qset_params *q;
-	struct adapter *adapter = dev->priv;
-	const struct port_info *pi = netdev_priv(dev);
+	int i;
 
 	if (e->rx_pending > MAX_RX_BUFFERS ||
 	    e->rx_jumbo_pending > MAX_RX_JUMBO_BUFFERS ||
@@ -1457,7 +1471,8 @@ static int set_sge_param(struct net_device *dev, struct ethtool_ringparam *e)
 
 static int set_coalesce(struct net_device *dev, struct ethtool_coalesce *c)
 {
-	struct adapter *adapter = dev->priv;
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	struct qset_params *qsp = &adapter->params.sge.qset[0];
 	struct sge_qset *qs = &adapter->sge.qs[0];
 
@@ -1471,7 +1486,8 @@ static int set_coalesce(struct net_device *dev, struct ethtool_coalesce *c)
 
 static int get_coalesce(struct net_device *dev, struct ethtool_coalesce *c)
 {
-	struct adapter *adapter = dev->priv;
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	struct qset_params *q = adapter->params.sge.qset;
 
 	c->rx_coalesce_usecs = q->coalesce_usecs;
@@ -1481,8 +1497,9 @@ static int get_coalesce(struct net_device *dev, struct ethtool_coalesce *c)
 static int get_eeprom(struct net_device *dev, struct ethtool_eeprom *e,
 		      u8 * data)
 {
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	int i, err = 0;
-	struct adapter *adapter = dev->priv;
 
 	u8 *buf = kmalloc(EEPROMSIZE, GFP_KERNEL);
 	if (!buf)
@@ -1501,10 +1518,11 @@ static int get_eeprom(struct net_device *dev, struct ethtool_eeprom *e,
 static int set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 		      u8 * data)
 {
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
+	u32 aligned_offset, aligned_len, *p;
 	u8 *buf;
 	int err = 0;
-	u32 aligned_offset, aligned_len, *p;
-	struct adapter *adapter = dev->priv;
 
 	if (eeprom->magic != EEPROM_MAGIC)
 		return -EINVAL;
@@ -1592,9 +1610,10 @@ static int in_range(int val, int lo, int hi)
 
 static int cxgb_extension_ioctl(struct net_device *dev, void __user *useraddr)
 {
-	int ret;
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	u32 cmd;
-	struct adapter *adapter = dev->priv;
+	int ret;
 
 	if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
 		return -EFAULT;
@@ -1923,10 +1942,10 @@ static int cxgb_extension_ioctl(struct net_device *dev, void __user *useraddr)
 
 static int cxgb_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 {
-	int ret, mmd;
-	struct adapter *adapter = dev->priv;
-	struct port_info *pi = netdev_priv(dev);
 	struct mii_ioctl_data *data = if_mii(req);
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
+	int ret, mmd;
 
 	switch (cmd) {
 	case SIOCGMIIPHY:
@@ -1994,9 +2013,9 @@ static int cxgb_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 
 static int cxgb_change_mtu(struct net_device *dev, int new_mtu)
 {
-	int ret;
-	struct adapter *adapter = dev->priv;
 	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
+	int ret;
 
 	if (new_mtu < 81)	/* accommodate SACK */
 		return -EINVAL;
@@ -2013,8 +2032,8 @@ static int cxgb_change_mtu(struct net_device *dev, int new_mtu)
 
 static int cxgb_set_mac_addr(struct net_device *dev, void *p)
 {
-	struct adapter *adapter = dev->priv;
 	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	struct sockaddr *addr = p;
 
 	if (!is_valid_ether_addr(addr->sa_data))
@@ -2050,8 +2069,8 @@ static void t3_synchronize_rx(struct adapter *adap, const struct port_info *p)
 
 static void vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
 {
-	struct adapter *adapter = dev->priv;
 	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 
 	pi->vlan_grp = grp;
 	if (adapter->params.rev > 0)
@@ -2070,8 +2089,8 @@ static void vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void cxgb_netpoll(struct net_device *dev)
 {
-	struct adapter *adapter = dev->priv;
 	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	int qidx;
 
 	for (qidx = pi->first_qset; qidx < pi->first_qset + pi->nqsets; qidx++) {
@@ -2433,6 +2452,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 
 		adapter->port[i] = netdev;
 		pi = netdev_priv(netdev);
+		pi->adapter = adapter;
 		pi->rx_csum_offload = 1;
 		pi->nqsets = 1;
 		pi->first_qset = i;
@@ -2442,7 +2462,6 @@ static int __devinit init_one(struct pci_dev *pdev,
 		netdev->irq = pdev->irq;
 		netdev->mem_start = mmio_start;
 		netdev->mem_end = mmio_start + mmio_len - 1;
-		netdev->priv = adapter;
 		netdev->features |= NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO;
 		netdev->features |= NETIF_F_LLTX;
 		if (pci_using_dac)
@@ -2467,7 +2486,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 		SET_ETHTOOL_OPS(netdev, &cxgb_ethtool_ops);
 	}
 
-	pci_set_drvdata(pdev, adapter->port[0]);
+	pci_set_drvdata(pdev, adapter);
 	if (t3_prep_adapter(adapter, ai, 1) < 0) {
 		err = -ENODEV;
 		goto out_free_dev;
@@ -2547,11 +2566,10 @@ out_release_regions:
 
 static void __devexit remove_one(struct pci_dev *pdev)
 {
-	struct net_device *dev = pci_get_drvdata(pdev);
+	struct adapter *adapter = pci_get_drvdata(pdev);
 
-	if (dev) {
+	if (adapter) {
 		int i;
-		struct adapter *adapter = dev->priv;
 
 		t3_sge_stop(adapter);
 		sysfs_remove_group(&adapter->port[0]->dev.kobj,
diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cxgb3_offload.c
index e620ed4..83d3555 100644
--- a/drivers/net/cxgb3/cxgb3_offload.c
+++ b/drivers/net/cxgb3/cxgb3_offload.c
@@ -925,7 +925,7 @@ void cxgb_neigh_update(struct neighbour *neigh)
 	struct net_device *dev = neigh->dev;
 
 	if (dev && (is_offloading(dev))) {
-		struct t3cdev *tdev = T3CDEV(dev);
+		struct t3cdev *tdev = dev2t3cdev(dev);
 
 		BUG_ON(!tdev);
 		t3_l2t_update(tdev, neigh);
@@ -973,9 +973,9 @@ void cxgb_redirect(struct dst_entry *old, struct dst_entry *new)
 		       "device ignored.\n", __FUNCTION__);
 		return;
 	}
-	tdev = T3CDEV(olddev);
+	tdev = dev2t3cdev(olddev);
 	BUG_ON(!tdev);
-	if (tdev != T3CDEV(newdev)) {
+	if (tdev != dev2t3cdev(newdev)) {
 		printk(KERN_WARNING "%s: Redirect to different "
 		       "offload device ignored.\n", __FUNCTION__);
 		return;
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index a2cfd68..58a5f60 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -1073,7 +1073,7 @@ int t3_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned int ndesc, pidx, credits, gen, compl;
 	const struct port_info *pi = netdev_priv(dev);
-	struct adapter *adap = dev->priv;
+	struct adapter *adap = pi->adapter;
 	struct sge_qset *qs = dev2qset(dev);
 	struct sge_txq *q = &qs->txq[TXQ_ETH];
 
@@ -1326,7 +1326,8 @@ static void restart_ctrlq(unsigned long data)
 	struct sk_buff *skb;
 	struct sge_qset *qs = (struct sge_qset *)data;
 	struct sge_txq *q = &qs->txq[TXQ_CTRL];
-	struct adapter *adap = qs->netdev->priv;
+	const struct port_info *pi = netdev_priv(qs->netdev);
+	struct adapter *adap = pi->adapter;
 
 	spin_lock(&q->lock);
       again:reclaim_completed_tx_imm(q);
@@ -1531,7 +1532,8 @@ static void restart_offloadq(unsigned long data)
 	struct sk_buff *skb;
 	struct sge_qset *qs = (struct sge_qset *)data;
 	struct sge_txq *q = &qs->txq[TXQ_OFLD];
-	struct adapter *adap = qs->netdev->priv;
+	const struct port_info *pi = netdev_priv(qs->netdev);
+	struct adapter *adap = pi->adapter;
 
 	spin_lock(&q->lock);
       again:reclaim_completed_tx(adap, q);
@@ -1675,7 +1677,8 @@ static inline void deliver_partial_bundle(struct t3cdev *tdev,
  */
 static int ofld_poll(struct net_device *dev, int *budget)
 {
-	struct adapter *adapter = dev->priv;
+	const struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	struct sge_qset *qs = dev2qset(dev);
 	struct sge_rspq *q = &qs->rspq;
 	int work_done, limit = min(*budget, dev->quota), avail = limit;
@@ -2075,7 +2078,8 @@ static inline int is_pure_response(const struct rsp_desc *r)
  */
 static int napi_rx_handler(struct net_device *dev, int *budget)
 {
-	struct adapter *adap = dev->priv;
+	const struct port_info *pi = netdev_priv(dev);
+	struct adapter *adap = pi->adapter;
 	struct sge_qset *qs = dev2qset(dev);
 	int effective_budget = min(*budget, dev->quota);
 
@@ -2205,7 +2209,8 @@ static inline int handle_responses(struct adapter *adap, struct sge_rspq *q)
 irqreturn_t t3_sge_intr_msix(int irq, void *cookie)
 {
 	struct sge_qset *qs = cookie;
-	struct adapter *adap = qs->netdev->priv;
+	const struct port_info *pi = netdev_priv(qs->netdev);
+	struct adapter *adap = pi->adapter;
 	struct sge_rspq *q = &qs->rspq;
 
 	spin_lock(&q->lock);
@@ -2224,7 +2229,8 @@ irqreturn_t t3_sge_intr_msix(int irq, void *cookie)
 irqreturn_t t3_sge_intr_msix_napi(int irq, void *cookie)
 {
 	struct sge_qset *qs = cookie;
-	struct adapter *adap = qs->netdev->priv;
+	const struct port_info *pi = netdev_priv(qs->netdev);
+	struct adapter *adap = pi->adapter;
 	struct sge_rspq *q = &qs->rspq;
 
 	spin_lock(&q->lock);
@@ -2508,7 +2514,8 @@ static void sge_timer_cb(unsigned long data)
 {
 	spinlock_t *lock;
 	struct sge_qset *qs = (struct sge_qset *)data;
-	struct adapter *adap = qs->netdev->priv;
+	const struct port_info *pi = netdev_priv(qs->netdev);
+	struct adapter *adap = pi->adapter;
 
 	if (spin_trylock(&qs->txq[TXQ_ETH].lock)) {
 		reclaim_completed_tx(adap, &qs->txq[TXQ_ETH]);
diff --git a/drivers/net/cxgb3/t3cdev.h b/drivers/net/cxgb3/t3cdev.h
index fa4099b..77fcc1a 100644
--- a/drivers/net/cxgb3/t3cdev.h
+++ b/drivers/net/cxgb3/t3cdev.h
@@ -42,9 +42,6 @@
 
 #define T3CNAMSIZ 16
 
-/* Get the t3cdev associated with a net_device */
-#define T3CDEV(netdev) (struct t3cdev *)(netdev->priv)
-
 struct cxgb3_client;
 
 enum t3ctype {
