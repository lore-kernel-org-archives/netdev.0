From: Shmulik Hen <shmulik.hen@intel.com>
Subject: [SET 2][PATCH 5/8][bonding] Propagating master's settings to slaves
Date: Fri, 8 Aug 2003 17:45:10 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308081745.10710.shmulik.hen@intel.com>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

5 - Add support for changing HW address and MTU with proper unwind.

diff -Nuarp linux-2.4.22-rc1/drivers/net/bonding/bond_main.c linux-2.4.22-rc1-devel/drivers/net/bonding/bond_main.c
--- linux-2.4.22-rc1/drivers/net/bonding/bond_main.c	Fri Aug  8 14:03:22 2003
+++ linux-2.4.22-rc1-devel/drivers/net/bonding/bond_main.c	Fri Aug  8 14:03:23 2003
@@ -592,6 +592,11 @@ static struct slave *find_best_interface
 
 
 /* #define BONDING_DEBUG 1 */
+#ifdef BONDING_DEBUG
+#define dprintk(x...) printk(x...)
+#else /* BONDING_DEBUG */
+#define dprintk(x...) do {} while (0)
+#endif /* BONDING_DEBUG */
 
 /* several macros */
 
@@ -680,19 +685,6 @@ update_slave_cnt(bonding_t *bond, int in
 		BUG();
 }
 
-/*
- * Set MAC.  Differs from eth_mac_addr in that we allow changes while
- * netif_running().
- */
-static int
-bond_set_mac_address(struct net_device *dev, void *p)
-{
-	struct sockaddr *addr = p;
-
-	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
-	return 0;
-}
-
 /* 
  * This function detaches the slave <slave> from the list <bond>.
  * WARNING: no check is made to verify if the slave effectively
@@ -3037,10 +3029,6 @@ static int bond_ioctl(struct net_device 
 		case SIOCBONDRELEASE:	
 			ret = bond_release(master_dev, slave_dev); 
 			break;
-		case BOND_SETHWADDR_OLD:
-		case SIOCBONDSETHWADDR:	
-			ret = bond_sethwaddr(master_dev, slave_dev);
-			break;
 		case BOND_CHANGE_ACTIVE_OLD:
 		case SIOCBONDCHANGEACTIVE:
 			if (USES_PRIMARY(bond_mode)) {
@@ -3480,6 +3468,132 @@ static int bond_read_proc(char *buf, cha
 }
 #endif /* CONFIG_PROC_FS */
 
+
+/*
+ * Change HW address
+ *
+ * Note that many devices must be down to change the HW address, and
+ * downing the master releases all slaves.  We can make bonds full of
+ * bonding devices to test this, however.
+ */
+static inline int
+bond_set_mac_address(struct net_device *dev, void *addr)
+{
+	struct bonding *bond = dev->priv;
+	struct sockaddr *sa = addr, tmp_sa;
+	struct slave *slave;
+	int error;
+
+	dprintk(KERN_INFO "bond_set_mac_address %p %s\n", dev,
+	       dev->name);
+
+	if (!is_valid_ether_addr(sa->sa_data)) {
+		return -EADDRNOTAVAIL;
+	}
+
+	for (slave = bond->prev; slave != (struct slave *)bond;
+	     slave = slave->prev) {
+		dprintk(KERN_INFO "bond_set_mac: slave %p %s\n", slave,
+			slave->dev->name);
+		if (slave->dev->set_mac_address == NULL) {
+			error = -EOPNOTSUPP;
+			dprintk(KERN_INFO "bond_set_mac EOPNOTSUPP %s\n",
+				slave->dev->name);
+			goto unwind;
+		}
+
+		error = slave->dev->set_mac_address(slave->dev, addr);
+		if (error) {
+			/* TODO: consider downing the slave 
+			 * and retry ?
+			 * User should expect communications
+			 * breakage anyway until ARP finish
+			 * updating, so...
+			 */
+			dprintk(KERN_INFO "bond_set_mac err %d %s\n",
+				error, slave->dev->name);
+			goto unwind;
+		}
+	}
+
+	/* success */
+	memcpy(dev->dev_addr, sa->sa_data, dev->addr_len);
+	return 0;
+
+unwind:
+	memcpy(tmp_sa.sa_data, dev->dev_addr, dev->addr_len);
+	tmp_sa.sa_family = dev->type;
+
+	for (slave = slave->next; slave != bond->next;
+	     slave = slave->next) {
+		int tmp_error;
+
+		tmp_error = slave->dev->set_mac_address(slave->dev, &tmp_sa);
+		if (tmp_error) {
+			dprintk(KERN_INFO "bond_set_mac_address: "
+				"unwind err %d dev %s\n",
+				tmp_error, slave->dev->name);
+		}
+	}
+
+	return error;
+}
+
+/*
+ * Change the MTU of all of a master's slaves to match the master
+ */
+static inline int
+bond_change_mtu(struct net_device *dev, int newmtu)
+{
+	bonding_t *bond = dev->priv;
+	slave_t *slave;
+	int error;
+
+	dprintk(KERN_INFO "CM: b %p nm %d\n", bond, newmtu);
+	for (slave = bond->prev; slave != (slave_t *)bond;
+	     slave = slave->prev) {
+		dprintk(KERN_INFO "CM: s %p s->p %p c_m %p\n", slave,
+			slave->prev, slave->dev->change_mtu);
+		if (slave->dev->change_mtu) {
+			error = slave->dev->change_mtu(slave->dev, newmtu);
+		} else {
+			slave->dev->mtu = newmtu;
+			error = 0;
+		}
+
+		if (error) {
+			/* If we failed to set the slave's mtu to the new value
+			 * we must abort the operation even in ACTIVE_BACKUP
+			 * mode, because if we allow the backup slaves to have
+			 * different mtu values than the active slave we'll
+			 * need to change their mtu when doing a failover. That
+			 * means changing their mtu from timer context, which
+			 * is probably not a good idea.
+			 */
+			dprintk(KERN_INFO "bond_change_mtu err %d %s\n",
+			       error, slave->dev->name);
+			goto unwind;
+		}
+	}
+
+	dev->mtu = newmtu;
+	return 0;
+
+
+unwind:
+	for (slave = slave->next; slave != bond->next;
+	     slave = slave->next) {
+
+		if (slave->dev->change_mtu) {
+			slave->dev->change_mtu(slave->dev, dev->mtu);
+		} else {
+			slave->dev->mtu = dev->mtu;
+		}
+	}
+
+	return error;
+}
+
 static int bond_event(struct notifier_block *this, unsigned long event, 
 			void *ptr)
 {
@@ -3572,6 +3686,7 @@ static int __init bond_init(struct net_d
 	dev->stop = bond_close;
 	dev->set_multicast_list = set_multicast_list;
 	dev->do_ioctl = bond_ioctl;
+	dev->change_mtu = bond_change_mtu;
 	dev->set_mac_address = bond_set_mac_address;
 	dev->tx_queue_len = 0;
 	dev->flags |= IFF_MASTER|IFF_MULTICAST;

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
