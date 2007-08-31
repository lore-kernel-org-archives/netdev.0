From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Fri, 31 Aug 2007 14:46:26 -0400
Message-ID: <20070831184626.GA23011@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:57561 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965928AbXHaSq1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 14:46:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/infiniband/hw/cxgb3/cxio_hal.c |    2 +-
 drivers/net/cxgb3/adapter.h            |    2 +
 drivers/net/cxgb3/common.h             |    3 +-
 drivers/net/cxgb3/cxgb3_main.c         |  252 +++++++++++++++++++-------------
 drivers/net/cxgb3/cxgb3_offload.c      |   16 ++-
 drivers/net/cxgb3/cxgb3_offload.h      |    2 +
 drivers/net/cxgb3/sge.c                |   23 ++-
 drivers/net/cxgb3/t3_hw.c              |   46 +++++-
 drivers/net/cxgb3/t3cdev.h             |    3 -
 drivers/net/ioc3-eth.c                 |   80 ++++++++---
 drivers/net/netxen/netxen_nic_hdr.h    |    6 +-
 drivers/net/netxen/netxen_nic_hw.c     |    8 +-
 drivers/net/netxen/netxen_nic_main.c   |   19 +--
 drivers/net/ps3_gelic_net.c            |    1 -
 drivers/s390/net/qeth.h                |    4 +-
 drivers/s390/net/qeth_main.c           |  158 +++++++++++++++-----
 drivers/s390/net/qeth_mpc.h            |    1 +
 drivers/s390/net/qeth_sys.c            |    8 +-
 18 files changed, 428 insertions(+), 206 deletions(-)

Divy Le Ray (2):
      cxgb3 - Fix dev->priv usage
      - cxgb3 engine microcode load

Frank Blaschka (2):
      qeth: enforce a rate limit for inbound scatter gather messages
      qeth: Announce tx checksumming for qeth devices in TSO/EDDP mode

Heiko Carstens (1):
      qeth: dont return the return values of void functions.

Klaus D. Wacker (1):
      qeth: Drop ARP packages on HiperSockets interface with NOARP attribute.

Masakazu Mokuno (1):
      PS3: fix the bug that 'ifconfig down' would hang

Ralf Baechle (1):
      IOC3: Program UART predividers.

Ursula Braun (3):
      qeth: ungrouping a device must not be interruptible
      qeth: crash during reboot after failing online setting
      qeth: provide specific message for OSA-adapters exclusively used

dhananjay@netxen.com (2):
      netxen: Avoid firmware load in PCI probe
      netxen: fix crashes during module unload

diff --git a/drivers/infiniband/hw/cxgb3/cxio_hal.c b/drivers/infiniband/hw/cxgb3/cxio_hal.c
index 1518b41..beb2a38 100644
--- a/drivers/infiniband/hw/cxgb3/cxio_hal.c
+++ b/drivers/infiniband/hw/cxgb3/cxio_hal.c
@@ -916,7 +916,7 @@ int cxio_rdev_open(struct cxio_rdev *rdev_p)
 	PDBG("%s opening rnic dev %s\n", __FUNCTION__, rdev_p->dev_name);
 	memset(&rdev_p->ctrl_qp, 0, sizeof(rdev_p->ctrl_qp));
 	if (!rdev_p->t3cdev_p)
-		rdev_p->t3cdev_p = T3CDEV(netdev_p);
+		rdev_p->t3cdev_p = dev2t3cdev(netdev_p);
 	rdev_p->t3cdev_p->ulp = (void *) rdev_p;
 	err = rdev_p->t3cdev_p->ctl(rdev_p->t3cdev_p, RDMA_GET_PARAMS,
 					 &(rdev_p->rnic_info));
diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index ab72563..20e887d 100644
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
diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
index 1637800..2129210 100644
--- a/drivers/net/cxgb3/common.h
+++ b/drivers/net/cxgb3/common.h
@@ -679,7 +679,8 @@ const struct adapter_info *t3_get_adapter_info(unsigned int board_id);
 int t3_seeprom_read(struct adapter *adapter, u32 addr, u32 *data);
 int t3_seeprom_write(struct adapter *adapter, u32 addr, u32 data);
 int t3_seeprom_wp(struct adapter *adapter, int enable);
-int t3_check_tpsram_version(struct adapter *adapter);
+int t3_get_tp_version(struct adapter *adapter, u32 *vers);
+int t3_check_tpsram_version(struct adapter *adapter, int *must_load);
 int t3_check_tpsram(struct adapter *adapter, u8 *tp_ram, unsigned int size);
 int t3_set_proto_sram(struct adapter *adap, u8 *data);
 int t3_read_flash(struct adapter *adapter, unsigned int addr,
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index dc5d269..5ab319c 100644
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
@@ -721,6 +729,7 @@ static void bind_qsets(struct adapter *adap)
 }
 
 #define FW_FNAME "t3fw-%d.%d.%d.bin"
+#define TPSRAM_NAME "t3%c_protocol_sram-%d.%d.%d.bin"
 
 static int upgrade_fw(struct adapter *adap)
 {
@@ -739,6 +748,71 @@ static int upgrade_fw(struct adapter *adap)
 	}
 	ret = t3_load_fw(adap, fw->data, fw->size);
 	release_firmware(fw);
+
+	if (ret == 0)
+		dev_info(dev, "successful upgrade to firmware %d.%d.%d\n",
+			 FW_VERSION_MAJOR, FW_VERSION_MINOR, FW_VERSION_MICRO);
+	else
+		dev_err(dev, "failed to upgrade to firmware %d.%d.%d\n",
+			FW_VERSION_MAJOR, FW_VERSION_MINOR, FW_VERSION_MICRO);
+	
+	return ret;
+}
+
+static inline char t3rev2char(struct adapter *adapter)
+{
+	char rev = 0;
+
+	switch(adapter->params.rev) {
+	case T3_REV_B:
+	case T3_REV_B2:
+		rev = 'b';
+		break;
+	}
+	return rev;
+}
+
+int update_tpsram(struct adapter *adap)
+{
+	const struct firmware *tpsram;
+	char buf[64];
+	struct device *dev = &adap->pdev->dev;
+	int ret;
+	char rev;
+	
+	rev = t3rev2char(adap);
+	if (!rev)
+		return 0;
+
+	snprintf(buf, sizeof(buf), TPSRAM_NAME, rev,
+		 TP_VERSION_MAJOR, TP_VERSION_MINOR, TP_VERSION_MICRO);
+
+	ret = request_firmware(&tpsram, buf, dev);
+	if (ret < 0) {
+		dev_err(dev, "could not load TP SRAM: unable to load %s\n",
+			buf);
+		return ret;
+	}
+	
+	ret = t3_check_tpsram(adap, tpsram->data, tpsram->size);
+	if (ret)
+		goto release_tpsram;	
+
+	ret = t3_set_proto_sram(adap, tpsram->data);
+	if (ret == 0)
+		dev_info(dev,
+			 "successful update of protocol engine "
+			 "to %d.%d.%d\n",
+			 TP_VERSION_MAJOR, TP_VERSION_MINOR, TP_VERSION_MICRO);
+	else
+		dev_err(dev, "failed to update of protocol engine %d.%d.%d\n",
+			TP_VERSION_MAJOR, TP_VERSION_MINOR, TP_VERSION_MICRO);
+	if (ret)
+		dev_err(dev, "loading protocol SRAM failed\n");
+
+release_tpsram:
+	release_firmware(tpsram);
+	
 	return ret;
 }
 
@@ -755,6 +829,7 @@ static int upgrade_fw(struct adapter *adap)
 static int cxgb_up(struct adapter *adap)
 {
 	int err = 0;
+	int must_load;
 
 	if (!(adap->flags & FULL_INIT_DONE)) {
 		err = t3_check_fw_version(adap);
@@ -763,6 +838,13 @@ static int cxgb_up(struct adapter *adap)
 		if (err)
 			goto out;
 
+		err = t3_check_tpsram_version(adap, &must_load);
+		if (err == -EINVAL) {
+			err = update_tpsram(adap);
+			if (err && must_load)
+				goto out;
+		}
+
 		err = init_dummy_netdevs(adap);
 		if (err)
 			goto out;
@@ -858,8 +940,9 @@ static void schedule_chk_task(struct adapter *adap)
 
 static int offload_open(struct net_device *dev)
 {
-	struct adapter *adapter = dev->priv;
-	struct t3cdev *tdev = T3CDEV(dev);
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
+	struct t3cdev *tdev = dev2t3cdev(dev);
 	int adap_up = adapter->open_device_map & PORT_MASK;
 	int err = 0;
 
@@ -924,10 +1007,10 @@ static int offload_close(struct t3cdev *tdev)
 
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
@@ -951,17 +1034,17 @@ static int cxgb_open(struct net_device *dev)
 
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
@@ -976,13 +1059,13 @@ static int cxgb_close(struct net_device *dev)
 
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
@@ -1015,14 +1098,16 @@ static struct net_device_stats *cxgb_get_stats(struct net_device *dev)
 
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
@@ -1096,10 +1181,13 @@ static int get_eeprom_len(struct net_device *dev)
 
 static void get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	u32 fw_vers = 0;
-	struct adapter *adapter = dev->priv;
+	u32 tp_vers = 0;
 
 	t3_get_fw_version(adapter, &fw_vers);
+	t3_get_tp_version(adapter, &tp_vers);
 
 	strcpy(info->driver, DRV_NAME);
 	strcpy(info->version, DRV_VERSION);
@@ -1108,11 +1196,14 @@ static void get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 		strcpy(info->fw_version, "N/A");
 	else {
 		snprintf(info->fw_version, sizeof(info->fw_version),
-			 "%s %u.%u.%u",
+			 "%s %u.%u.%u TP %u.%u.%u",
 			 G_FW_VERSION_TYPE(fw_vers) ? "T" : "N",
 			 G_FW_VERSION_MAJOR(fw_vers),
 			 G_FW_VERSION_MINOR(fw_vers),
-			 G_FW_VERSION_MICRO(fw_vers));
+			 G_FW_VERSION_MICRO(fw_vers),
+			 G_TP_VERSION_MAJOR(tp_vers),
+			 G_TP_VERSION_MINOR(tp_vers),
+			 G_TP_VERSION_MICRO(tp_vers));
 	}
 }
 
@@ -1136,8 +1227,8 @@ static unsigned long collect_sge_port_stats(struct adapter *adapter,
 static void get_stats(struct net_device *dev, struct ethtool_stats *stats,
 		      u64 *data)
 {
-	struct adapter *adapter = dev->priv;
 	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	const struct mac_stats *s;
 
 	spin_lock(&adapter->stats_lock);
@@ -1205,7 +1296,8 @@ static inline void reg_block_dump(struct adapter *ap, void *buf,
 static void get_regs(struct net_device *dev, struct ethtool_regs *regs,
 		     void *buf)
 {
-	struct adapter *ap = dev->priv;
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *ap = pi->adapter;
 
 	/*
 	 * Version scheme:
@@ -1246,8 +1338,9 @@ static int restart_autoneg(struct net_device *dev)
 
 static int cxgb3_phys_id(struct net_device *dev, u32 data)
 {
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	int i;
-	struct adapter *adapter = dev->priv;
 
 	if (data == 0)
 		data = 2;
@@ -1408,8 +1501,8 @@ static int set_rx_csum(struct net_device *dev, u32 data)
 
 static void get_sge_param(struct net_device *dev, struct ethtool_ringparam *e)
 {
-	const struct adapter *adapter = dev->priv;
-	const struct port_info *pi = netdev_priv(dev);
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	const struct qset_params *q = &adapter->params.sge.qset[pi->first_qset];
 
 	e->rx_max_pending = MAX_RX_BUFFERS;
@@ -1425,10 +1518,10 @@ static void get_sge_param(struct net_device *dev, struct ethtool_ringparam *e)
 
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
@@ -1457,7 +1550,8 @@ static int set_sge_param(struct net_device *dev, struct ethtool_ringparam *e)
 
 static int set_coalesce(struct net_device *dev, struct ethtool_coalesce *c)
 {
-	struct adapter *adapter = dev->priv;
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	struct qset_params *qsp = &adapter->params.sge.qset[0];
 	struct sge_qset *qs = &adapter->sge.qs[0];
 
@@ -1471,7 +1565,8 @@ static int set_coalesce(struct net_device *dev, struct ethtool_coalesce *c)
 
 static int get_coalesce(struct net_device *dev, struct ethtool_coalesce *c)
 {
-	struct adapter *adapter = dev->priv;
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	struct qset_params *q = adapter->params.sge.qset;
 
 	c->rx_coalesce_usecs = q->coalesce_usecs;
@@ -1481,8 +1576,9 @@ static int get_coalesce(struct net_device *dev, struct ethtool_coalesce *c)
 static int get_eeprom(struct net_device *dev, struct ethtool_eeprom *e,
 		      u8 * data)
 {
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	int i, err = 0;
-	struct adapter *adapter = dev->priv;
 
 	u8 *buf = kmalloc(EEPROMSIZE, GFP_KERNEL);
 	if (!buf)
@@ -1501,10 +1597,11 @@ static int get_eeprom(struct net_device *dev, struct ethtool_eeprom *e,
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
@@ -1592,9 +1689,10 @@ static int in_range(int val, int lo, int hi)
 
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
@@ -1923,10 +2021,10 @@ static int cxgb_extension_ioctl(struct net_device *dev, void __user *useraddr)
 
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
@@ -1994,9 +2092,9 @@ static int cxgb_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 
 static int cxgb_change_mtu(struct net_device *dev, int new_mtu)
 {
-	int ret;
-	struct adapter *adapter = dev->priv;
 	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
+	int ret;
 
 	if (new_mtu < 81)	/* accommodate SACK */
 		return -EINVAL;
@@ -2013,8 +2111,8 @@ static int cxgb_change_mtu(struct net_device *dev, int new_mtu)
 
 static int cxgb_set_mac_addr(struct net_device *dev, void *p)
 {
-	struct adapter *adapter = dev->priv;
 	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	struct sockaddr *addr = p;
 
 	if (!is_valid_ether_addr(addr->sa_data))
@@ -2050,8 +2148,8 @@ static void t3_synchronize_rx(struct adapter *adap, const struct port_info *p)
 
 static void vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
 {
-	struct adapter *adapter = dev->priv;
 	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 
 	pi->vlan_grp = grp;
 	if (adapter->params.rev > 0)
@@ -2070,8 +2168,8 @@ static void vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void cxgb_netpoll(struct net_device *dev)
 {
-	struct adapter *adapter = dev->priv;
 	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	int qidx;
 
 	for (qidx = pi->first_qset; qidx < pi->first_qset + pi->nqsets; qidx++) {
@@ -2088,42 +2186,6 @@ static void cxgb_netpoll(struct net_device *dev)
 }
 #endif
 
-#define TPSRAM_NAME "t3%c_protocol_sram-%d.%d.%d.bin"
-int update_tpsram(struct adapter *adap)
-{
-	const struct firmware *tpsram;
-	char buf[64];
-	struct device *dev = &adap->pdev->dev;
-	int ret;
-	char rev;
-	
-	rev = adap->params.rev == T3_REV_B2 ? 'b' : 'a';
-
-	snprintf(buf, sizeof(buf), TPSRAM_NAME, rev,
-		 TP_VERSION_MAJOR, TP_VERSION_MINOR, TP_VERSION_MICRO);
-
-	ret = request_firmware(&tpsram, buf, dev);
-	if (ret < 0) {
-		dev_err(dev, "could not load TP SRAM: unable to load %s\n",
-			buf);
-		return ret;
-	}
-	
-	ret = t3_check_tpsram(adap, tpsram->data, tpsram->size);
-	if (ret)
-		goto release_tpsram;	
-
-	ret = t3_set_proto_sram(adap, tpsram->data);
-	if (ret)
-		dev_err(dev, "loading protocol SRAM failed\n");
-
-release_tpsram:
-	release_firmware(tpsram);
-	
-	return ret;
-}
-
-
 /*
  * Periodic accumulation of MAC statistics.
  */
@@ -2433,6 +2495,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 
 		adapter->port[i] = netdev;
 		pi = netdev_priv(netdev);
+		pi->adapter = adapter;
 		pi->rx_csum_offload = 1;
 		pi->nqsets = 1;
 		pi->first_qset = i;
@@ -2442,7 +2505,6 @@ static int __devinit init_one(struct pci_dev *pdev,
 		netdev->irq = pdev->irq;
 		netdev->mem_start = mmio_start;
 		netdev->mem_end = mmio_start + mmio_len - 1;
-		netdev->priv = adapter;
 		netdev->features |= NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO;
 		netdev->features |= NETIF_F_LLTX;
 		if (pci_using_dac)
@@ -2467,18 +2529,11 @@ static int __devinit init_one(struct pci_dev *pdev,
 		SET_ETHTOOL_OPS(netdev, &cxgb_ethtool_ops);
 	}
 
-	pci_set_drvdata(pdev, adapter->port[0]);
+	pci_set_drvdata(pdev, adapter);
 	if (t3_prep_adapter(adapter, ai, 1) < 0) {
 		err = -ENODEV;
 		goto out_free_dev;
 	}
-
-	err = t3_check_tpsram_version(adapter);
-	if (err == -EINVAL)
-		err = update_tpsram(adapter);
-
-	if (err)
-		goto out_free_dev;
 		
 	/*
 	 * The card is now ready to go.  If any errors occur during device
@@ -2547,11 +2602,10 @@ out_release_regions:
 
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
index e620ed4..bdff7ba 100644
--- a/drivers/net/cxgb3/cxgb3_offload.c
+++ b/drivers/net/cxgb3/cxgb3_offload.c
@@ -593,6 +593,16 @@ int cxgb3_alloc_stid(struct t3cdev *tdev, struct cxgb3_client *client,
 
 EXPORT_SYMBOL(cxgb3_alloc_stid);
 
+/* Get the t3cdev associated with a net_device */
+struct t3cdev *dev2t3cdev(struct net_device *dev)
+{
+	const struct port_info *pi = netdev_priv(dev);
+
+	return (struct t3cdev *)pi->adapter;
+}
+
+EXPORT_SYMBOL(dev2t3cdev);
+
 static int do_smt_write_rpl(struct t3cdev *dev, struct sk_buff *skb)
 {
 	struct cpl_smt_write_rpl *rpl = cplhdr(skb);
@@ -925,7 +935,7 @@ void cxgb_neigh_update(struct neighbour *neigh)
 	struct net_device *dev = neigh->dev;
 
 	if (dev && (is_offloading(dev))) {
-		struct t3cdev *tdev = T3CDEV(dev);
+		struct t3cdev *tdev = dev2t3cdev(dev);
 
 		BUG_ON(!tdev);
 		t3_l2t_update(tdev, neigh);
@@ -973,9 +983,9 @@ void cxgb_redirect(struct dst_entry *old, struct dst_entry *new)
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
diff --git a/drivers/net/cxgb3/cxgb3_offload.h b/drivers/net/cxgb3/cxgb3_offload.h
index f15446a..7a37913 100644
--- a/drivers/net/cxgb3/cxgb3_offload.h
+++ b/drivers/net/cxgb3/cxgb3_offload.h
@@ -51,6 +51,8 @@ void cxgb3_offload_deactivate(struct adapter *adapter);
 
 void cxgb3_set_dummy_ops(struct t3cdev *dev);
 
+struct t3cdev *dev2t3cdev(struct net_device *dev);
+
 /*
  * Client registration.  Users of T3 driver must register themselves.
  * The T3 driver will call the add function of every client for each T3
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
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index dd3149d..b02d15d 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -848,16 +848,15 @@ static int t3_write_flash(struct adapter *adapter, unsigned int addr,
 }
 
 /**
- *	t3_check_tpsram_version - read the tp sram version
+ *	t3_get_tp_version - read the tp sram version
  *	@adapter: the adapter
+ *	@vers: where to place the version
  *
- *	Reads the protocol sram version from serial eeprom.
+ *	Reads the protocol sram version from sram.
  */
-int t3_check_tpsram_version(struct adapter *adapter)
+int t3_get_tp_version(struct adapter *adapter, u32 *vers)
 {
 	int ret;
-	u32 vers;
-	unsigned int major, minor;
 
 	/* Get version loaded in SRAM */
 	t3_write_reg(adapter, A_TP_EMBED_OP_FIELD0, 0);
@@ -866,7 +865,32 @@ int t3_check_tpsram_version(struct adapter *adapter)
 	if (ret)
 		return ret;
 	
-	vers = t3_read_reg(adapter, A_TP_EMBED_OP_FIELD1);
+	*vers = t3_read_reg(adapter, A_TP_EMBED_OP_FIELD1);
+
+	return 0;
+}
+
+/**
+ *	t3_check_tpsram_version - read the tp sram version
+ *	@adapter: the adapter
+ *	@must_load: set to 1 if loading a new microcode image is required
+ *
+ *	Reads the protocol sram version from flash.
+ */
+int t3_check_tpsram_version(struct adapter *adapter, int *must_load)
+{
+	int ret;
+	u32 vers;
+	unsigned int major, minor;
+
+	if (adapter->params.rev == T3_REV_A)
+		return 0;
+
+	*must_load = 1;
+
+	ret = t3_get_tp_version(adapter, &vers);
+	if (ret)
+		return ret;
 
 	major = G_TP_VERSION_MAJOR(vers);
 	minor = G_TP_VERSION_MINOR(vers);
@@ -874,6 +898,16 @@ int t3_check_tpsram_version(struct adapter *adapter)
 	if (major == TP_VERSION_MAJOR && minor == TP_VERSION_MINOR) 
 		return 0;
 
+	if (major != TP_VERSION_MAJOR)
+		CH_ERR(adapter, "found wrong TP version (%u.%u), "
+		       "driver needs version %d.%d\n", major, minor,
+		       TP_VERSION_MAJOR, TP_VERSION_MINOR);
+	else {
+		*must_load = 0;
+		CH_ERR(adapter, "found wrong TP version (%u.%u), "
+		       "driver compiled for version %d.%d\n", major, minor,
+		       TP_VERSION_MAJOR, TP_VERSION_MINOR);
+	}
 	return -EINVAL;
 }
 
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
diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
index 3ca1e8e..0834ef0 100644
--- a/drivers/net/ioc3-eth.c
+++ b/drivers/net/ioc3-eth.c
@@ -48,6 +48,7 @@
 #ifdef CONFIG_SERIAL_8250
 #include <linux/serial_core.h>
 #include <linux/serial_8250.h>
+#include <linux/serial_reg.h>
 #endif
 
 #include <linux/netdevice.h>
@@ -1151,13 +1152,41 @@ static int ioc3_is_menet(struct pci_dev *pdev)
  * Also look in ip27-pci.c:pci_fixup_ioc3() for some comments on working
  * around ioc3 oddities in this respect.
  *
- * The IOC3 serials use a 22MHz clock rate with an additional divider by 3.
+ * The IOC3 serials use a 22MHz clock rate with an additional divider which
+ * can be programmed in the SCR register if the DLAB bit is set.
+ *
+ * Register to interrupt zero because we share the interrupt with
+ * the serial driver which we don't properly support yet.
+ *
+ * Can't use UPF_IOREMAP as the whole of IOC3 resources have already been
+ * registered.
  */
+static void __devinit ioc3_8250_register(struct ioc3_uartregs __iomem *uart)
+{
+#define COSMISC_CONSTANT 6
+
+	struct uart_port port = {
+		.irq		= 0,
+		.flags		= UPF_SKIP_TEST | UPF_BOOT_AUTOCONF,
+		.iotype		= UPIO_MEM,
+		.regshift	= 0,
+		.uartclk	= (22000000 << 1) / COSMISC_CONSTANT,
+
+		.membase	= (unsigned char __iomem *) uart,
+		.mapbase	= (unsigned long) uart,
+	};
+	unsigned char lcr;
+
+	lcr = uart->iu_lcr;
+	uart->iu_lcr = lcr | UART_LCR_DLAB;
+	uart->iu_scr = COSMISC_CONSTANT,
+	uart->iu_lcr = lcr;
+	uart->iu_lcr;
+	serial8250_register_port(&port);
+}
 
 static void __devinit ioc3_serial_probe(struct pci_dev *pdev, struct ioc3 *ioc3)
 {
-	struct uart_port port;
-
 	/*
 	 * We need to recognice and treat the fourth MENET serial as it
 	 * does not have an SuperIO chip attached to it, therefore attempting
@@ -1171,24 +1200,35 @@ static void __devinit ioc3_serial_probe(struct pci_dev *pdev, struct ioc3 *ioc3)
 		return;
 
 	/*
-	 * Register to interrupt zero because we share the interrupt with
-	 * the serial driver which we don't properly support yet.
-	 *
-	 * Can't use UPF_IOREMAP as the whole of IOC3 resources have already
-	 * been registered.
+	 * Switch IOC3 to PIO mode.  It probably already was but let's be
+	 * paranoid
 	 */
-	memset(&port, 0, sizeof(port));
-	port.irq      = 0;
-	port.flags    = UPF_SKIP_TEST | UPF_BOOT_AUTOCONF;
-	port.iotype   = UPIO_MEM;
-	port.regshift = 0;
-	port.uartclk  = 22000000 / 3;
-
-	port.membase  = (unsigned char *) &ioc3->sregs.uarta;
-	serial8250_register_port(&port);
-
-	port.membase  = (unsigned char *) &ioc3->sregs.uartb;
-	serial8250_register_port(&port);
+	ioc3->gpcr_s = GPCR_UARTA_MODESEL | GPCR_UARTB_MODESEL;
+	ioc3->gpcr_s;
+	ioc3->gppr_6 = 0;
+	ioc3->gppr_6;
+	ioc3->gppr_7 = 0;
+	ioc3->gppr_7;
+	ioc3->sscr_a = ioc3->sscr_a & ~SSCR_DMA_EN;
+	ioc3->sscr_a;
+	ioc3->sscr_b = ioc3->sscr_b & ~SSCR_DMA_EN;
+	ioc3->sscr_b;
+	/* Disable all SA/B interrupts except for SA/B_INT in SIO_IEC. */
+	ioc3->sio_iec &= ~ (SIO_IR_SA_TX_MT | SIO_IR_SA_RX_FULL |
+			    SIO_IR_SA_RX_HIGH | SIO_IR_SA_RX_TIMER |
+			    SIO_IR_SA_DELTA_DCD | SIO_IR_SA_DELTA_CTS |
+			    SIO_IR_SA_TX_EXPLICIT | SIO_IR_SA_MEMERR);
+	ioc3->sio_iec |= SIO_IR_SA_INT;
+	ioc3->sscr_a = 0;
+	ioc3->sio_iec &= ~ (SIO_IR_SB_TX_MT | SIO_IR_SB_RX_FULL |
+			    SIO_IR_SB_RX_HIGH | SIO_IR_SB_RX_TIMER |
+			    SIO_IR_SB_DELTA_DCD | SIO_IR_SB_DELTA_CTS |
+			    SIO_IR_SB_TX_EXPLICIT | SIO_IR_SB_MEMERR);
+	ioc3->sio_iec |= SIO_IR_SB_INT;
+	ioc3->sscr_b = 0;
+
+	ioc3_8250_register(&ioc3->sregs.uarta);
+	ioc3_8250_register(&ioc3->sregs.uartb);
 }
 #endif
 
diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index 3276866..d72f8f8 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -649,9 +649,11 @@ enum {
 #define PCIX_INT_VECTOR		(0x10100)
 #define PCIX_INT_MASK		(0x10104)
 
-#define PCIX_MN_WINDOW		(0x10200)
+#define PCIX_MN_WINDOW_F0	(0x10200)
+#define PCIX_MN_WINDOW(_f)	(PCIX_MN_WINDOW_F0 + (0x20 * (_f)))
 #define PCIX_MS_WINDOW		(0x10204)
-#define PCIX_SN_WINDOW		(0x10208)
+#define PCIX_SN_WINDOW_F0	(0x10208)
+#define PCIX_SN_WINDOW(_f)	(PCIX_SN_WINDOW_F0 + (0x20 * (_f)))
 #define PCIX_CRB_WINDOW		(0x10210)
 #define PCIX_CRB_WINDOW_F0	(0x10210)
 #define PCIX_CRB_WINDOW_F1	(0x10230)
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index aac1542..a7b8d7f 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -904,11 +904,11 @@ netxen_nic_pci_set_window(struct netxen_adapter *adapter,
 			ddr_mn_window = window;
 			writel(window, PCI_OFFSET_SECOND_RANGE(adapter,
 							       NETXEN_PCIX_PH_REG
-							       (PCIX_MN_WINDOW)));
+							       (PCIX_MN_WINDOW(adapter->ahw.pci_func))));
 			/* MUST make sure window is set before we forge on... */
 			readl(PCI_OFFSET_SECOND_RANGE(adapter,
 						      NETXEN_PCIX_PH_REG
-						      (PCIX_MN_WINDOW)));
+						      (PCIX_MN_WINDOW(adapter->ahw.pci_func))));
 		}
 		addr -= (window * NETXEN_WINDOW_ONE);
 		addr += NETXEN_PCI_DDR_NET;
@@ -929,11 +929,11 @@ netxen_nic_pci_set_window(struct netxen_adapter *adapter,
 			writel((window << 22),
 			       PCI_OFFSET_SECOND_RANGE(adapter,
 						       NETXEN_PCIX_PH_REG
-						       (PCIX_SN_WINDOW)));
+						       (PCIX_SN_WINDOW(adapter->ahw.pci_func))));
 			/* MUST make sure window is set before we forge on... */
 			readl(PCI_OFFSET_SECOND_RANGE(adapter,
 						      NETXEN_PCIX_PH_REG
-						      (PCIX_SN_WINDOW)));
+						      (PCIX_SN_WINDOW(adapter->ahw.pci_func))));
 		}
 		addr -= (window * 0x400000);
 		addr += NETXEN_PCI_QDR_NET;
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 08a62ac..3122d01 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -639,10 +639,6 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			NETXEN_CRB_NORMALIZE(adapter,
 				NETXEN_ROMUSB_GLB_PEGTUNE_DONE));
 		/* Handshake with the card before we register the devices. */
-		writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
-		netxen_pinit_from_rom(adapter, 0);
-		msleep(1);
-		netxen_load_firmware(adapter);
 		netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
 	}
 
@@ -750,9 +746,6 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 
 	netxen_nic_disable_int(adapter);
 
-	if (adapter->irq)
-		free_irq(adapter->irq, adapter);
-
 	if (adapter->is_up == NETXEN_ADAPTER_UP_MAGIC) {
 		init_firmware_done++;
 		netxen_free_hw_resources(adapter);
@@ -776,13 +769,8 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 		}
 	}
 
-	if (adapter->flags & NETXEN_NIC_MSI_ENABLED)
-		pci_disable_msi(pdev);
-
 	vfree(adapter->cmd_buf_arr);
 
-	pci_disable_device(pdev);
-
 	if (adapter->portnum == 0) {
 		if (init_firmware_done) {
 			i = 100;
@@ -833,12 +821,19 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 		}
 	}
 
+	if (adapter->irq)
+		free_irq(adapter->irq, adapter);
+
+	if (adapter->flags & NETXEN_NIC_MSI_ENABLED)
+		pci_disable_msi(pdev);
+
 	iounmap(adapter->ahw.db_base);
 	iounmap(adapter->ahw.pci_base0);
 	iounmap(adapter->ahw.pci_base1);
 	iounmap(adapter->ahw.pci_base2);
 
 	pci_release_regions(pdev);
+	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
 
 	free_netdev(netdev);
diff --git a/drivers/net/ps3_gelic_net.c b/drivers/net/ps3_gelic_net.c
index 13d1c0a..e565039 100644
--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -556,7 +556,6 @@ static int gelic_net_stop(struct net_device *netdev)
 {
 	struct gelic_net_card *card = netdev_priv(netdev);
 
-	netif_poll_disable(netdev);
 	netif_stop_queue(netdev);
 
 	/* turn off DMA, force end */
diff --git a/drivers/s390/net/qeth.h b/drivers/s390/net/qeth.h
index ec18bae..6d49598 100644
--- a/drivers/s390/net/qeth.h
+++ b/drivers/s390/net/qeth.h
@@ -1178,9 +1178,9 @@ qeth_ipaddr_to_string(enum qeth_prot_versions proto, const __u8 *addr,
 		      char *buf)
 {
 	if (proto == QETH_PROT_IPV4)
-		return qeth_ipaddr4_to_string(addr, buf);
+		qeth_ipaddr4_to_string(addr, buf);
 	else if (proto == QETH_PROT_IPV6)
-		return qeth_ipaddr6_to_string(addr, buf);
+		qeth_ipaddr6_to_string(addr, buf);
 }
 
 static inline int
diff --git a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
index 57f6943..f3e6fbe 100644
--- a/drivers/s390/net/qeth_main.c
+++ b/drivers/s390/net/qeth_main.c
@@ -561,7 +561,7 @@ qeth_set_offline(struct ccwgroup_device *cgdev)
 }
 
 static int
-qeth_wait_for_threads(struct qeth_card *card, unsigned long threads);
+qeth_threads_running(struct qeth_card *card, unsigned long threads);
 
 
 static void
@@ -576,8 +576,7 @@ qeth_remove_device(struct ccwgroup_device *cgdev)
 	if (!card)
 		return;
 
-	if (qeth_wait_for_threads(card, 0xffffffff))
-		return;
+	wait_event(card->wait_q, qeth_threads_running(card, 0xffffffff) == 0);
 
 	if (cgdev->state == CCWGROUP_ONLINE){
 		card->use_hard_stop = 1;
@@ -1542,16 +1541,21 @@ qeth_idx_write_cb(struct qeth_channel *channel, struct qeth_cmd_buffer *iob)
 	card = CARD_FROM_CDEV(channel->ccwdev);
 
 	if (!(QETH_IS_IDX_ACT_POS_REPLY(iob->data))) {
-		PRINT_ERR("IDX_ACTIVATE on write channel device %s: negative "
-			  "reply\n", CARD_WDEV_ID(card));
+		if (QETH_IDX_ACT_CAUSE_CODE(iob->data) == 0x19)
+			PRINT_ERR("IDX_ACTIVATE on write channel device %s: "
+				"adapter exclusively used by another host\n",
+				CARD_WDEV_ID(card));
+		else
+			PRINT_ERR("IDX_ACTIVATE on write channel device %s: "
+				"negative reply\n", CARD_WDEV_ID(card));
 		goto out;
 	}
 	memcpy(&temp, QETH_IDX_ACT_FUNC_LEVEL(iob->data), 2);
 	if ((temp & ~0x0100) != qeth_peer_func_level(card->info.func_level)) {
 		PRINT_WARN("IDX_ACTIVATE on write channel device %s: "
-			   "function level mismatch "
-			   "(sent: 0x%x, received: 0x%x)\n",
-			   CARD_WDEV_ID(card), card->info.func_level, temp);
+			"function level mismatch "
+			"(sent: 0x%x, received: 0x%x)\n",
+			CARD_WDEV_ID(card), card->info.func_level, temp);
 		goto out;
 	}
 	channel->state = CH_STATE_UP;
@@ -1597,8 +1601,13 @@ qeth_idx_read_cb(struct qeth_channel *channel, struct qeth_cmd_buffer *iob)
 			goto out;
 	}
 	if (!(QETH_IS_IDX_ACT_POS_REPLY(iob->data))) {
-		PRINT_ERR("IDX_ACTIVATE on read channel device %s: negative "
-			  "reply\n", CARD_RDEV_ID(card));
+		if (QETH_IDX_ACT_CAUSE_CODE(iob->data) == 0x19)
+			PRINT_ERR("IDX_ACTIVATE on read channel device %s: "
+				"adapter exclusively used by another host\n",
+				CARD_RDEV_ID(card));
+		else
+			PRINT_ERR("IDX_ACTIVATE on read channel device %s: "
+				"negative reply\n", CARD_RDEV_ID(card));
 		goto out;
 	}
 
@@ -1613,8 +1622,8 @@ qeth_idx_read_cb(struct qeth_channel *channel, struct qeth_cmd_buffer *iob)
 	memcpy(&temp, QETH_IDX_ACT_FUNC_LEVEL(iob->data), 2);
 	if (temp != qeth_peer_func_level(card->info.func_level)) {
 		PRINT_WARN("IDX_ACTIVATE on read channel device %s: function "
-			   "level mismatch (sent: 0x%x, received: 0x%x)\n",
-			   CARD_RDEV_ID(card), card->info.func_level, temp);
+			"level mismatch (sent: 0x%x, received: 0x%x)\n",
+			CARD_RDEV_ID(card), card->info.func_level, temp);
 		goto out;
 	}
 	memcpy(&card->token.issuer_rm_r,
@@ -2496,7 +2505,7 @@ qeth_rebuild_skb_fake_ll_tr(struct qeth_card *card, struct sk_buff *skb,
 	struct iphdr *ip_hdr;
 
 	QETH_DBF_TEXT(trace,5,"skbfktr");
-	skb_set_mac_header(skb, -QETH_FAKE_LL_LEN_TR);
+	skb_set_mac_header(skb, (int)-QETH_FAKE_LL_LEN_TR);
 	/* this is a fake ethernet header */
 	fake_hdr = tr_hdr(skb);
 
@@ -2804,13 +2813,16 @@ qeth_queue_input_buffer(struct qeth_card *card, int index)
 		if (newcount < count) {
 			/* we are in memory shortage so we switch back to
 			   traditional skb allocation and drop packages */
-			if (atomic_cmpxchg(&card->force_alloc_skb, 0, 1))
-				printk(KERN_WARNING
-					"qeth: switch to alloc skb\n");
+			if (!atomic_read(&card->force_alloc_skb) &&
+			    net_ratelimit())
+				PRINT_WARN("Switch to alloc skb\n");
+			atomic_set(&card->force_alloc_skb, 3);
 			count = newcount;
 		} else {
-			if (atomic_cmpxchg(&card->force_alloc_skb, 1, 0))
-				printk(KERN_WARNING "qeth: switch to sg\n");
+			if ((atomic_read(&card->force_alloc_skb) == 1) &&
+			    net_ratelimit())
+				PRINT_WARN("Switch to sg\n");
+			atomic_add_unless(&card->force_alloc_skb, -1, 0);
 		}
 
 		/*
@@ -3354,10 +3366,12 @@ out_freeoutq:
 	while (i > 0)
 		kfree(card->qdio.out_qs[--i]);
 	kfree(card->qdio.out_qs);
+	card->qdio.out_qs = NULL;
 out_freepool:
 	qeth_free_buffer_pool(card);
 out_freeinq:
 	kfree(card->qdio.in_q);
+	card->qdio.in_q = NULL;
 out_nomem:
 	atomic_set(&card->qdio.state, QETH_QDIO_UNINITIALIZED);
 	return -ENOMEM;
@@ -3373,16 +3387,20 @@ qeth_free_qdio_buffers(struct qeth_card *card)
 		QETH_QDIO_UNINITIALIZED)
 		return;
 	kfree(card->qdio.in_q);
+	card->qdio.in_q = NULL;
 	/* inbound buffer pool */
 	qeth_free_buffer_pool(card);
 	/* free outbound qdio_qs */
-	for (i = 0; i < card->qdio.no_out_queues; ++i){
-		for (j = 0; j < QDIO_MAX_BUFFERS_PER_Q; ++j)
-			qeth_clear_output_buffer(card->qdio.out_qs[i],
-					&card->qdio.out_qs[i]->bufs[j]);
-		kfree(card->qdio.out_qs[i]);
+	if (card->qdio.out_qs) {
+		for (i = 0; i < card->qdio.no_out_queues; ++i) {
+			for (j = 0; j < QDIO_MAX_BUFFERS_PER_Q; ++j)
+				qeth_clear_output_buffer(card->qdio.out_qs[i],
+						&card->qdio.out_qs[i]->bufs[j]);
+			kfree(card->qdio.out_qs[i]);
+		}
+		kfree(card->qdio.out_qs);
+		card->qdio.out_qs = NULL;
 	}
-	kfree(card->qdio.out_qs);
 }
 
 static void
@@ -3393,7 +3411,7 @@ qeth_clear_qdio_buffers(struct qeth_card *card)
 	QETH_DBF_TEXT(trace, 2, "clearqdbf");
 	/* clear outbound buffers to free skbs */
 	for (i = 0; i < card->qdio.no_out_queues; ++i)
-		if (card->qdio.out_qs[i]){
+		if (card->qdio.out_qs && card->qdio.out_qs[i]) {
 			for (j = 0; j < QDIO_MAX_BUFFERS_PER_Q; ++j)
 				qeth_clear_output_buffer(card->qdio.out_qs[i],
 						&card->qdio.out_qs[i]->bufs[j]);
@@ -4553,6 +4571,53 @@ qeth_get_elements_no(struct qeth_card *card, void *hdr,
         return elements_needed;
 }
 
+static void qeth_tx_csum(struct sk_buff *skb)
+{
+	int tlen;
+
+	if (skb->protocol == htons(ETH_P_IP)) {
+		tlen = ntohs(ip_hdr(skb)->tot_len) - (ip_hdr(skb)->ihl << 2);
+		switch (ip_hdr(skb)->protocol) {
+		case IPPROTO_TCP:
+			tcp_hdr(skb)->check = 0;
+			tcp_hdr(skb)->check = csum_tcpudp_magic(
+				ip_hdr(skb)->saddr, ip_hdr(skb)->daddr,
+				tlen, ip_hdr(skb)->protocol,
+				skb_checksum(skb, skb_transport_offset(skb),
+					tlen, 0));
+			break;
+		case IPPROTO_UDP:
+			udp_hdr(skb)->check = 0;
+			udp_hdr(skb)->check = csum_tcpudp_magic(
+				ip_hdr(skb)->saddr, ip_hdr(skb)->daddr,
+				tlen, ip_hdr(skb)->protocol,
+				skb_checksum(skb, skb_transport_offset(skb),
+					tlen, 0));
+			break;
+		}
+	} else if (skb->protocol == htons(ETH_P_IPV6)) {
+		switch (ipv6_hdr(skb)->nexthdr) {
+		case IPPROTO_TCP:
+			tcp_hdr(skb)->check = 0;
+			tcp_hdr(skb)->check = csum_ipv6_magic(
+				&ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr,
+				ipv6_hdr(skb)->payload_len,
+				ipv6_hdr(skb)->nexthdr,
+				skb_checksum(skb, skb_transport_offset(skb),
+					ipv6_hdr(skb)->payload_len, 0));
+			break;
+		case IPPROTO_UDP:
+			udp_hdr(skb)->check = 0;
+			udp_hdr(skb)->check = csum_ipv6_magic(
+				&ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr,
+				ipv6_hdr(skb)->payload_len,
+				ipv6_hdr(skb)->nexthdr,
+				skb_checksum(skb, skb_transport_offset(skb),
+					ipv6_hdr(skb)->payload_len, 0));
+			break;
+		}
+	}
+}
 
 static int
 qeth_send_packet(struct qeth_card *card, struct sk_buff *skb)
@@ -4638,12 +4703,22 @@ qeth_send_packet(struct qeth_card *card, struct sk_buff *skb)
 		elements_needed += elems;
 	}
 
+	if ((large_send == QETH_LARGE_SEND_NO) &&
+	    (skb->ip_summed == CHECKSUM_PARTIAL))
+		qeth_tx_csum(new_skb);
+
 	if (card->info.type != QETH_CARD_TYPE_IQD)
 		rc = qeth_do_send_packet(card, queue, new_skb, hdr,
 					 elements_needed, ctx);
-	else
+	else {
+		if ((skb->protocol == htons(ETH_P_ARP)) &&
+		    (card->dev->flags & IFF_NOARP)) {
+			__qeth_free_new_skb(skb, new_skb);
+			return -EPERM;
+		}
 		rc = qeth_do_send_packet_fast(card, queue, new_skb, hdr,
 					      elements_needed, ctx);
+	}
 	if (!rc) {
 		card->stats.tx_packets++;
 		card->stats.tx_bytes += tx_bytes;
@@ -6385,20 +6460,18 @@ qeth_deregister_addr_entry(struct qeth_card *card, struct qeth_ipaddr *addr)
 static u32
 qeth_ethtool_get_tx_csum(struct net_device *dev)
 {
-	/* We may need to say that we support tx csum offload if
-	 * we do EDDP or TSO. There are discussions going on to
-	 * enforce rules in the stack and in ethtool that make
-	 * SG and TSO depend on HW_CSUM. At the moment there are
-	 * no such rules....
-	 * If we say yes here, we have to checksum outbound packets
-	 * any time. */
-	return 0;
+	return (dev->features & NETIF_F_HW_CSUM) != 0;
 }
 
 static int
 qeth_ethtool_set_tx_csum(struct net_device *dev, u32 data)
 {
-	return -EINVAL;
+	if (data)
+		dev->features |= NETIF_F_HW_CSUM;
+	else
+		dev->features &= ~NETIF_F_HW_CSUM;
+
+	return 0;
 }
 
 static u32
@@ -7412,7 +7485,8 @@ qeth_start_ipa_tso(struct qeth_card *card)
 	}
 	if (rc && (card->options.large_send == QETH_LARGE_SEND_TSO)){
 		card->options.large_send = QETH_LARGE_SEND_NO;
-		card->dev->features &= ~ (NETIF_F_TSO | NETIF_F_SG);
+		card->dev->features &= ~(NETIF_F_TSO | NETIF_F_SG |
+						NETIF_F_HW_CSUM);
 	}
 	return rc;
 }
@@ -7552,22 +7626,26 @@ qeth_set_large_send(struct qeth_card *card, enum qeth_large_send_types type)
 	card->options.large_send = type;
 	switch (card->options.large_send) {
 	case QETH_LARGE_SEND_EDDP:
-		card->dev->features |= NETIF_F_TSO | NETIF_F_SG;
+		card->dev->features |= NETIF_F_TSO | NETIF_F_SG |
+					NETIF_F_HW_CSUM;
 		break;
 	case QETH_LARGE_SEND_TSO:
 		if (qeth_is_supported(card, IPA_OUTBOUND_TSO)){
-			card->dev->features |= NETIF_F_TSO | NETIF_F_SG;
+			card->dev->features |= NETIF_F_TSO | NETIF_F_SG |
+						NETIF_F_HW_CSUM;
 		} else {
 			PRINT_WARN("TSO not supported on %s. "
 				   "large_send set to 'no'.\n",
 				   card->dev->name);
-			card->dev->features &= ~(NETIF_F_TSO | NETIF_F_SG);
+			card->dev->features &= ~(NETIF_F_TSO | NETIF_F_SG |
+						NETIF_F_HW_CSUM);
 			card->options.large_send = QETH_LARGE_SEND_NO;
 			rc = -EOPNOTSUPP;
 		}
 		break;
 	default: /* includes QETH_LARGE_SEND_NO */
-		card->dev->features &= ~(NETIF_F_TSO | NETIF_F_SG);
+		card->dev->features &= ~(NETIF_F_TSO | NETIF_F_SG |
+					NETIF_F_HW_CSUM);
 		break;
 	}
 	if (card->state == CARD_STATE_UP)
diff --git a/drivers/s390/net/qeth_mpc.h b/drivers/s390/net/qeth_mpc.h
index 1d8083c..6de2da5 100644
--- a/drivers/s390/net/qeth_mpc.h
+++ b/drivers/s390/net/qeth_mpc.h
@@ -565,6 +565,7 @@ extern unsigned char IDX_ACTIVATE_WRITE[];
 #define QETH_IDX_ACT_QDIO_DEV_REALADDR(buffer) (buffer+0x20)
 #define QETH_IS_IDX_ACT_POS_REPLY(buffer) (((buffer)[0x08]&3)==2)
 #define QETH_IDX_REPLY_LEVEL(buffer) (buffer+0x12)
+#define QETH_IDX_ACT_CAUSE_CODE(buffer) (buffer)[0x09]
 
 #define PDU_ENCAPSULATION(buffer) \
 	(buffer + *(buffer + (*(buffer+0x0b)) + \
diff --git a/drivers/s390/net/qeth_sys.c b/drivers/s390/net/qeth_sys.c
index bb0287a..2cc3f3a 100644
--- a/drivers/s390/net/qeth_sys.c
+++ b/drivers/s390/net/qeth_sys.c
@@ -1760,10 +1760,10 @@ qeth_remove_device_attributes(struct device *dev)
 {
 	struct qeth_card *card = dev->driver_data;
 
-	if (card->info.type == QETH_CARD_TYPE_OSN)
-		return sysfs_remove_group(&dev->kobj,
-					  &qeth_osn_device_attr_group);
-
+	if (card->info.type == QETH_CARD_TYPE_OSN) {
+		sysfs_remove_group(&dev->kobj, &qeth_osn_device_attr_group);
+		return;
+	}
 	sysfs_remove_group(&dev->kobj, &qeth_device_attr_group);
 	sysfs_remove_group(&dev->kobj, &qeth_device_ipato_group);
 	sysfs_remove_group(&dev->kobj, &qeth_device_vipa_group);
