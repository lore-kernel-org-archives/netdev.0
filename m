From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 2/4] [bonding 2.6] Reduce usage of the global value of abi_ver
Date: Thu, 8 Jan 2004 18:28:53 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401081828.54991.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <bonding-devel@lists.sourceforge.net>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Jeff Garzik" <jgarzik@pobox.com>, "Jay Vosburgh" <fubar@us.ibm.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

- Reduce usage of the global values of the ABI version received from
the application. Instead, pass it as a function argument were needed.

- Save a new slave's original HW address regardless of ABI version.

- Move the clearing of the bond's address and some references to the
bond's params structure so they are protected by the relevant locks.


diff -Nuarp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Thu Jan  8 18:06:45 2004
+++ b/drivers/net/bonding/bond_main.c	Thu Jan  8 18:06:46 2004
@@ -561,6 +561,11 @@ static int arp_ip_count	= 0;
 static u32 my_ip	= 0;
 static int bond_mode	= BOND_MODE_ROUNDROBIN;
 static int lacp_fast	= 0;
+
+/* The global abi_ver vars are only for providing backward compatibility with
+ * versions that locked bonding into using only the first abi_ver it has seen
+ * from userspace.
+ */
 static int app_abi_ver	= 0;
 static int orig_app_abi_ver = -1; /* This is used to save the first ABI version
 				   * we receive from the application. Once set,
@@ -1207,7 +1212,7 @@ static int bond_sethwaddr(struct net_dev
 }
 
 /* enslave device <slave> to bond device <master> */
-static int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
+static int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev, int abi_ver)
 {
 	struct bonding *bond = bond_dev->priv;
 	struct slave *new_slave = NULL;
@@ -1234,7 +1239,7 @@ static int bond_enslave(struct net_devic
 		return -EBUSY;
 	}
 
-	if (app_abi_ver >= 1) {
+	if (abi_ver >= 1) {
 		/* The application is using an ABI, which requires the
 		 * slave interface to be closed.
 		 */
@@ -1289,13 +1294,12 @@ static int bond_enslave(struct net_devic
 	 */
 	new_slave->original_flags = slave_dev->flags;
 
-	if (app_abi_ver >= 1) {
-		/* save slave's original ("permanent") mac address for
-		 * modes that needs it, and for restoring it upon release,
-		 * and then set it to the master's address
-		 */
-		memcpy(new_slave->perm_hwaddr, slave_dev->dev_addr, ETH_ALEN);
+	/* save slave's original ("permanent") mac address for restoring it
+	 * upon release
+	 */
+	memcpy(new_slave->perm_hwaddr, slave_dev->dev_addr, ETH_ALEN);
 
+	if (abi_ver >= 1) {
 		/* set slave to master's mac address
 		 * The application already set the master's
 		 * mac address to that of the first slave
@@ -1319,7 +1323,7 @@ static int bond_enslave(struct net_devic
 	res = netdev_set_master(slave_dev, bond_dev);
 	if (res) {
 		dprintk("Error %d calling netdev_set_master\n", res);
-		if (app_abi_ver < 1) {
+		if (abi_ver < 1) {
 			goto err_free;
 		} else {
 			goto err_close;
@@ -1520,7 +1524,7 @@ static int bond_enslave(struct net_devic
 
 	write_unlock_bh(&bond->lock);
 
-	if (app_abi_ver < 1) {
+	if (abi_ver < 1) {
 		/*
 		 * !!! This is to support old versions of ifenslave.
 		 * We can remove this in 2.5 because our ifenslave takes
@@ -1689,6 +1693,14 @@ static int bond_release(struct net_devic
 		}
 	}
 
+	if (bond->slave_cnt == 0) {
+		/* if the last slave was removed, zero the mac address
+		 * of the master so it will be set by the application
+		 * to the mac address of the first slave
+		 */
+		memset(bond_dev->dev_addr, 0, bond_dev->addr_len);
+	}
+
 	write_unlock_bh(&bond->lock);
 
 	/* If the mode USES_PRIMARY, then we should only remove its
@@ -1715,12 +1727,10 @@ static int bond_release(struct net_devic
 	/* close slave before restoring its mac address */
 	dev_close(slave_dev);
 
-	if (app_abi_ver >= 1) {
-		/* restore original ("permanent") mac address */
-		memcpy(addr.sa_data, slave->perm_hwaddr, ETH_ALEN);
-		addr.sa_family = slave_dev->type;
-		slave_dev->set_mac_address(slave_dev, &addr);
-	}
+	/* restore original ("permanent") mac address */
+	memcpy(addr.sa_data, slave->perm_hwaddr, ETH_ALEN);
+	addr.sa_family = slave_dev->type;
+	slave_dev->set_mac_address(slave_dev, &addr);
 
 	/* restore the original state of the
 	 * IFF_NOARP flag that might have been
@@ -1732,14 +1742,6 @@ static int bond_release(struct net_devic
 
 	kfree(slave);
 
-	/* if the last slave was removed, zero the mac address
-	 * of the master so it will be set by the application
-	 * to the mac address of the first slave
-	 */
-	if (bond->slave_cnt == 0) {
-		memset(bond_dev->dev_addr, 0, bond_dev->addr_len);
-	}
-
 	return 0;  /* deletion OK */
 }
 
@@ -1812,12 +1814,10 @@ static int bond_release_all(struct net_d
 		/* close slave before restoring its mac address */
 		dev_close(slave_dev);
 
-		if (app_abi_ver >= 1) {
-			/* restore original ("permanent") mac address*/
-			memcpy(addr.sa_data, slave->perm_hwaddr, ETH_ALEN);
-			addr.sa_family = slave_dev->type;
-			slave_dev->set_mac_address(slave_dev, &addr);
-		}
+		/* restore original ("permanent") mac address*/
+		memcpy(addr.sa_data, slave->perm_hwaddr, ETH_ALEN);
+		addr.sa_family = slave_dev->type;
+		slave_dev->set_mac_address(slave_dev, &addr);
 
 		/* restore the original state of the IFF_NOARP flag that might have
 		 * been set by bond_set_slave_inactive_flags()
@@ -1958,10 +1958,9 @@ static int bond_info_query(struct net_de
 {
 	struct bonding *bond = bond_dev->priv;
 
+	read_lock_bh(&bond->lock);
 	info->bond_mode = bond->params.mode;
 	info->miimon = bond->params.miimon;
-
-	read_lock_bh(&bond->lock);
 	info->num_slaves = bond->slave_cnt;
 	read_unlock_bh(&bond->lock);
 
@@ -2754,16 +2753,14 @@ static void bond_info_show_slave(struct 
 	seq_printf(seq, "Link Failure Count: %d\n",
 		   slave->link_failure_count);
 
-	if (app_abi_ver >= 1) {
-		seq_printf(seq,
-			   "Permanent HW addr: %02x:%02x:%02x:%02x:%02x:%02x\n",
-			   slave->perm_hwaddr[0],
-			   slave->perm_hwaddr[1],
-			   slave->perm_hwaddr[2],
-			   slave->perm_hwaddr[3],
-			   slave->perm_hwaddr[4],
-			   slave->perm_hwaddr[5]);
-	}
+	seq_printf(seq,
+		   "Permanent HW addr: %02x:%02x:%02x:%02x:%02x:%02x\n",
+		   slave->perm_hwaddr[0],
+		   slave->perm_hwaddr[1],
+		   slave->perm_hwaddr[2],
+		   slave->perm_hwaddr[3],
+		   slave->perm_hwaddr[4],
+		   slave->perm_hwaddr[5]);
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		const struct aggregator *agg
@@ -3325,7 +3322,7 @@ static int bond_do_ioctl(struct net_devi
 		switch (cmd) {
 		case BOND_ENSLAVE_OLD:
 		case SIOCBONDENSLAVE:
-			res = bond_enslave(bond_dev, slave_dev);
+			res = bond_enslave(bond_dev, slave_dev, app_abi_ver);
 			break;
 		case BOND_RELEASE_OLD:
 		case SIOCBONDRELEASE:
