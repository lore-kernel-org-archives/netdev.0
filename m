From: Matthew Wilcox <matthew@wil.cx>
Subject: [PATCH] [version 2] Remove support for old-style ethtool ioctl handlers
Date: Mon, 27 Nov 2006 11:33:46 -0700
Message-ID: <20061127183346.GR14076@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from palinux.external.hp.com ([192.25.206.14]:20703 "EHLO
	mail.parisc-linux.org") by vger.kernel.org with ESMTP
	id S933026AbWK0Sdr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Nov 2006 13:33:47 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


During the transition to the ethtool_ops way of doing things, we supported
calling the device's ->do_ioctl method to allow unconverted drivers to
continue working.  Those days are long behind us, all in-tree drivers
use the ethtool_ops way, and so we no longer need to support this.

The bonding driver and ethernet bridge code are the biggest beneficiaries
of this; calling the ioctl was unreliable as the context might well not
have CAP_SYS_ADMIN.

Thanks to Al Viro for pointing out I missed the bridge code in my first
version of this patch.

Signed-off-by: Matthew Wilcox <matthew@wil.cx>

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 17a4611..952b1be 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -613,38 +613,20 @@ down:
 static int bond_update_speed_duplex(struct slave *slave)
 {
 	struct net_device *slave_dev = slave->dev;
-	static int (* ioctl)(struct net_device *, struct ifreq *, int);
-	struct ifreq ifr;
 	struct ethtool_cmd etool;
+	int res;
 
 	/* Fake speed and duplex */
 	slave->speed = SPEED_100;
 	slave->duplex = DUPLEX_FULL;
 
-	if (slave_dev->ethtool_ops) {
-		int res;
-
-		if (!slave_dev->ethtool_ops->get_settings) {
-			return -1;
-		}
-
-		res = slave_dev->ethtool_ops->get_settings(slave_dev, &etool);
-		if (res < 0) {
-			return -1;
-		}
-
-		goto verify;
-	}
+	if (!slave_dev->ethtool_ops || !slave_dev->ethtool_ops->get_settings)
+		return -1;
 
-	ioctl = slave_dev->do_ioctl;
-	strncpy(ifr.ifr_name, slave_dev->name, IFNAMSIZ);
-	etool.cmd = ETHTOOL_GSET;
-	ifr.ifr_data = (char*)&etool;
-	if (!ioctl || (IOCTL(slave_dev, &ifr, SIOCETHTOOL) < 0)) {
+	res = slave_dev->ethtool_ops->get_settings(slave_dev, &etool);
+	if (res < 0)
 		return -1;
-	}
 
-verify:
 	switch (etool.speed) {
 	case SPEED_10:
 	case SPEED_100:
@@ -690,7 +672,6 @@ static int bond_check_dev_link(struct bo
 	static int (* ioctl)(struct net_device *, struct ifreq *, int);
 	struct ifreq ifr;
 	struct mii_ioctl_data *mii;
-	struct ethtool_value etool;
 
 	if (bond->params.use_carrier) {
 		return netif_carrier_ok(slave_dev) ? BMSR_LSTATUS : 0;
@@ -721,9 +702,9 @@ static int bond_check_dev_link(struct bo
 		}
 	}
 
-	/* try SIOCETHTOOL ioctl, some drivers cache ETHTOOL_GLINK */
-	/* for a period of time so we attempt to get link status   */
-	/* from it last if the above MII ioctls fail...            */
+	/* some drivers cache ETHTOOL_GLINK for a period of time so we only
+	 * attempt to get link status from it if the above MII ioctls fail.
+	 */
 	if (slave_dev->ethtool_ops) {
 		if (slave_dev->ethtool_ops->get_link) {
 			u32 link;
@@ -734,23 +715,9 @@ static int bond_check_dev_link(struct bo
 		}
 	}
 
-	if (ioctl) {
-		strncpy(ifr.ifr_name, slave_dev->name, IFNAMSIZ);
-		etool.cmd = ETHTOOL_GLINK;
-		ifr.ifr_data = (char*)&etool;
-		if (IOCTL(slave_dev, &ifr, SIOCETHTOOL) == 0) {
-			if (etool.data == 1) {
-				return BMSR_LSTATUS;
-			} else {
-				dprintk("SIOCETHTOOL shows link down\n");
-				return 0;
-			}
-		}
-	}
-
 	/*
 	 * If reporting, report that either there's no dev->do_ioctl,
-	 * or both SIOCGMIIREG and SIOCETHTOOL failed (meaning that we
+	 * or both SIOCGMIIREG and get_link failed (meaning that we
 	 * cannot report link status).  If not reporting, pretend
 	 * we're ok.
 	 */
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 60a508e..dfcedae 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -813,9 +813,6 @@ int vlan_dev_ioctl(struct net_device *de
 		if (real_dev->do_ioctl && netif_device_present(real_dev)) 
 			err = real_dev->do_ioctl(real_dev, &ifrr, cmd);
 		break;
-
-	case SIOCETHTOOL:
-		err = dev_ethtool(&ifrr);
 	}
 
 	if (!err) 
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index f753c40..000d7e5 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -29,35 +29,24 @@
  * Determine initial path cost based on speed.
  * using recommendations from 802.1d standard
  *
- * Need to simulate user ioctl because not all device's that support
- * ethtool, use ethtool_ops.  Also, since driver might sleep need to
- * not be holding any locks.
+ * Since driver might sleep need to not be holding any locks.
  */
 static int port_cost(struct net_device *dev)
 {
-	struct ethtool_cmd ecmd = { ETHTOOL_GSET };
-	struct ifreq ifr;
-	mm_segment_t old_fs;
-	int err;
-
-	strncpy(ifr.ifr_name, dev->name, IFNAMSIZ);
-	ifr.ifr_data = (void __user *) &ecmd;
-
-	old_fs = get_fs();
-	set_fs(KERNEL_DS);
-	err = dev_ethtool(&ifr);
-	set_fs(old_fs);
-	
-	if (!err) {
-		switch(ecmd.speed) {
-		case SPEED_100:
-			return 19;
-		case SPEED_1000:
-			return 4;
-		case SPEED_10000:
-			return 2;
-		case SPEED_10:
-			return 100;
+	if (dev->ethtool_ops->get_settings) {
+		struct ethtool_cmd ecmd = { ETHTOOL_GSET };
+		int err = dev->ethtool_ops->get_settings(dev, &ecmd);
+		if (!err) {
+			switch(ecmd.speed) {
+			case SPEED_100:
+				return 19;
+			case SPEED_1000:
+				return 4;
+			case SPEED_10000:
+				return 2;
+			case SPEED_10:
+				return 100;
+			}
 		}
 	}
 
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 87dc556..94645e3 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -810,7 +810,7 @@ int dev_ethtool(struct ifreq *ifr)
 		return -ENODEV;
 
 	if (!dev->ethtool_ops)
-		goto ioctl;
+		return -EOPNOTSUPP;
 
 	if (copy_from_user(&ethcmd, useraddr, sizeof (ethcmd)))
 		return -EFAULT;
@@ -959,15 +959,6 @@ int dev_ethtool(struct ifreq *ifr)
 		netdev_features_change(dev);
 
 	return rc;
-
- ioctl:
-	/* Keep existing behaviour for the moment.	 */
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
-	if (dev->do_ioctl)
-		return dev->do_ioctl(dev, ifr, SIOCETHTOOL);
-	return -EOPNOTSUPP;
 }
 
 EXPORT_SYMBOL(dev_ethtool);
