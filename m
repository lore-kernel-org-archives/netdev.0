From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Fri, 18 Jan 2008 15:17:41 -0500
Message-ID: <20080118201741.GA23190@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:46585 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761277AbYARURm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2008 15:17:42 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 Documentation/networking/driver.txt      |    5 +-
 drivers/net/3c515.c                      |   60 +++++----
 drivers/net/Kconfig                      |    3 -
 drivers/net/atl1/atl1_main.c             |    8 +-
 drivers/net/bonding/bond_alb.c           |   23 ++--
 drivers/net/bonding/bond_main.c          |   64 +++++++---
 drivers/net/bonding/bond_sysfs.c         |   66 ++++-----
 drivers/net/bonding/bonding.h            |    4 +-
 drivers/net/cpmac.c                      |    2 +-
 drivers/net/dl2k.c                       |  215 +++++++++++++++---------------
 drivers/net/dl2k.h                       |  157 +---------------------
 drivers/net/ipg.c                        |   36 ++----
 drivers/net/pcmcia/3c574_cs.c            |   31 +++--
 drivers/net/s2io.c                       |   17 ++-
 drivers/net/sky2.c                       |   24 +++-
 drivers/net/wan/dscc4.c                  |   94 +++++++------
 drivers/net/wan/lmc/lmc_media.c          |   12 +--
 drivers/net/wan/sbni.h                   |   12 ++-
 drivers/net/wireless/b43/rfkill.c        |   11 +-
 drivers/net/wireless/hostap/hostap_plx.c |    6 +-
 drivers/net/wireless/ipw2200.c           |    2 +-
 drivers/net/wireless/libertas/if_sdio.c  |    4 +
 drivers/net/wireless/rt2x00/rt2x00pci.c  |    2 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c  |   11 ++-
 24 files changed, 387 insertions(+), 482 deletions(-)

Al Viro (9):
      dscc4 endian fixes
      wan/lmc bitfields fixes
      sbni endian fixes
      3c574, 3c515 bitfields abuse
      dl2k: BMCR_t fixes
      dl2k: ANAR, ANLPAR fixes
      dl2k: BMSR fixes
      dl2k: MSCR, MSSR, ESR, PHY_SCR fixes
      dl2k: the rest

Francois Romieu (4):
      ipg: balance locking in irq handler
      ipg: plug Tx completion leak
      ipg: fix queue stop condition in the xmit handler
      ipg: fix Tx completion irq request

Ivo van Doorn (1):
      rt2x00: Fix ieee80211 payload alignment

Jason Uhlenkott (1):
      e1000e Kconfig: remove ref to nonexistant docs

Jay Cliburn (1):
      atl1: fix frame length bug

Jay Vosburgh (7):
      bonding: fix locking in sysfs primary/active selection
      bonding: fix ASSERT_RTNL that produces spurious warnings
      bonding: fix locking during alb failover and slave removal
      bonding: release slaves when master removed via sysfs
      bonding: Fix up parameter parsing
      bonding: fix lock ordering for rtnl and bonding_rwsem
      bonding: Don't hold lock when calling rtnl_unlock

Marc Pignat (1):
      wireless/libertas support for 88w8385 sdio older revision

Matteo Croce (1):
      Replace cpmac fix

Matti Linnanvuori (1):
      Documentation: add a guideline for hard_start_xmit method

Randy Dunlap (1):
      hostap: section mismatch warning

Sreenivasa Honnur (1):
      S2io: Fixed synchronization between scheduling of napi with card reset and close

Stefano Brivio (2):
      ipw2200: fix typo in kerneldoc
      b43: fix use-after-free rfkill bug

Stephen Hemminger (1):
      Revert "sky2: remove check for PCI wakeup setting from BIOS"

diff --git a/Documentation/networking/driver.txt b/Documentation/networking/driver.txt
index 4f7da5a..ea72d2e 100644
--- a/Documentation/networking/driver.txt
+++ b/Documentation/networking/driver.txt
@@ -61,7 +61,10 @@ Transmit path guidelines:
 2) Do not forget to update netdev->trans_start to jiffies after
    each new tx packet is given to the hardware.
 
-3) Do not forget that once you return 0 from your hard_start_xmit
+3) A hard_start_xmit method must not modify the shared parts of a
+   cloned SKB.
+
+4) Do not forget that once you return 0 from your hard_start_xmit
    method, it is your driver's responsibility to free up the SKB
    and in some finite amount of time.
 
diff --git a/drivers/net/3c515.c b/drivers/net/3c515.c
index 275e751..684bab7 100644
--- a/drivers/net/3c515.c
+++ b/drivers/net/3c515.c
@@ -243,14 +243,16 @@ enum eeprom_offset {
 enum Window3 {			/* Window 3: MAC/config bits. */
 	Wn3_Config = 0, Wn3_MAC_Ctrl = 6, Wn3_Options = 8,
 };
-union wn3_config {
-	int i;
-	struct w3_config_fields {
-		unsigned int ram_size:3, ram_width:1, ram_speed:2, rom_size:2;
-		int pad8:8;
-		unsigned int ram_split:2, pad18:2, xcvr:3, pad21:1, autoselect:1;
-		int pad24:7;
-	} u;
+enum wn3_config {
+	Ram_size = 7,
+	Ram_width = 8,
+	Ram_speed = 0x30,
+	Rom_size = 0xc0,
+	Ram_split_shift = 16,
+	Ram_split = 3 << Ram_split_shift,
+	Xcvr_shift = 20,
+	Xcvr = 7 << Xcvr_shift,
+	Autoselect = 0x1000000,
 };
 
 enum Window4 {
@@ -614,7 +616,7 @@ static int corkscrew_setup(struct net_device *dev, int ioaddr,
 	/* Read the station address from the EEPROM. */
 	EL3WINDOW(0);
 	for (i = 0; i < 0x18; i++) {
-		short *phys_addr = (short *) dev->dev_addr;
+		__be16 *phys_addr = (__be16 *) dev->dev_addr;
 		int timer;
 		outw(EEPROM_Read + i, ioaddr + Wn0EepromCmd);
 		/* Pause for at least 162 us. for the read to take place. */
@@ -646,22 +648,22 @@ static int corkscrew_setup(struct net_device *dev, int ioaddr,
 
 	{
 		char *ram_split[] = { "5:3", "3:1", "1:1", "3:5" };
-		union wn3_config config;
+		__u32 config;
 		EL3WINDOW(3);
 		vp->available_media = inw(ioaddr + Wn3_Options);
-		config.i = inl(ioaddr + Wn3_Config);
+		config = inl(ioaddr + Wn3_Config);
 		if (corkscrew_debug > 1)
 			printk(KERN_INFO "  Internal config register is %4.4x, transceivers %#x.\n",
-				config.i, inw(ioaddr + Wn3_Options));
+				config, inw(ioaddr + Wn3_Options));
 		printk(KERN_INFO "  %dK %s-wide RAM %s Rx:Tx split, %s%s interface.\n",
-			8 << config.u.ram_size,
-			config.u.ram_width ? "word" : "byte",
-			ram_split[config.u.ram_split],
-			config.u.autoselect ? "autoselect/" : "",
-			media_tbl[config.u.xcvr].name);
-		dev->if_port = config.u.xcvr;
-		vp->default_media = config.u.xcvr;
-		vp->autoselect = config.u.autoselect;
+			8 << config & Ram_size,
+			config & Ram_width ? "word" : "byte",
+			ram_split[(config & Ram_split) >> Ram_split_shift],
+			config & Autoselect ? "autoselect/" : "",
+			media_tbl[(config & Xcvr) >> Xcvr_shift].name);
+		vp->default_media = (config & Xcvr) >> Xcvr_shift;
+		vp->autoselect = config & Autoselect ? 1 : 0;
+		dev->if_port = vp->default_media;
 	}
 	if (vp->media_override != 7) {
 		printk(KERN_INFO "  Media override to transceiver type %d (%s).\n",
@@ -694,14 +696,14 @@ static int corkscrew_open(struct net_device *dev)
 {
 	int ioaddr = dev->base_addr;
 	struct corkscrew_private *vp = netdev_priv(dev);
-	union wn3_config config;
+	__u32 config;
 	int i;
 
 	/* Before initializing select the active media port. */
 	EL3WINDOW(3);
 	if (vp->full_duplex)
 		outb(0x20, ioaddr + Wn3_MAC_Ctrl);	/* Set the full-duplex bit. */
-	config.i = inl(ioaddr + Wn3_Config);
+	config = inl(ioaddr + Wn3_Config);
 
 	if (vp->media_override != 7) {
 		if (corkscrew_debug > 1)
@@ -727,12 +729,12 @@ static int corkscrew_open(struct net_device *dev)
 	} else
 		dev->if_port = vp->default_media;
 
-	config.u.xcvr = dev->if_port;
-	outl(config.i, ioaddr + Wn3_Config);
+	config = (config & ~Xcvr) | (dev->if_port << Xcvr_shift);
+	outl(config, ioaddr + Wn3_Config);
 
 	if (corkscrew_debug > 1) {
 		printk("%s: corkscrew_open() InternalConfig %8.8x.\n",
-		       dev->name, config.i);
+		       dev->name, config);
 	}
 
 	outw(TxReset, ioaddr + EL3_CMD);
@@ -901,7 +903,7 @@ static void corkscrew_timer(unsigned long data)
 			ok = 1;
 		}
 		if (!ok) {
-			union wn3_config config;
+			__u32 config;
 
 			do {
 				dev->if_port =
@@ -928,9 +930,9 @@ static void corkscrew_timer(unsigned long data)
 			     ioaddr + Wn4_Media);
 
 			EL3WINDOW(3);
-			config.i = inl(ioaddr + Wn3_Config);
-			config.u.xcvr = dev->if_port;
-			outl(config.i, ioaddr + Wn3_Config);
+			config = inl(ioaddr + Wn3_Config);
+			config = (config & ~Xcvr) | (dev->if_port << Xcvr_shift);
+			outl(config, ioaddr + Wn3_Config);
 
 			outw(dev->if_port == 3 ? StartCoax : StopCoax,
 			     ioaddr + EL3_CMD);
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 114771a..9ae3166 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1976,9 +1976,6 @@ config E1000E
 
 	  <http://support.intel.com>
 
-	  More specific information on configuring the driver is in
-	  <file:Documentation/networking/e1000e.txt>.
-
 	  To compile this driver as a module, choose M here. The module
 	  will be called e1000e.
 
diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index 35b0a7d..9200ee5 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -120,7 +120,7 @@ static int __devinit atl1_sw_init(struct atl1_adapter *adapter)
 	struct atl1_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
 
-	hw->max_frame_size = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
+	hw->max_frame_size = netdev->mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
 	hw->min_frame_size = ETH_ZLEN + ETH_FCS_LEN;
 
 	adapter->wol = 0;
@@ -688,7 +688,7 @@ static int atl1_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
 	int old_mtu = netdev->mtu;
-	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
+	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
 
 	if ((max_frame < ETH_ZLEN + ETH_FCS_LEN) ||
 	    (max_frame > MAX_JUMBO_FRAME_SIZE)) {
@@ -853,8 +853,8 @@ static u32 atl1_configure(struct atl1_adapter *adapter)
 	/* set Interrupt Clear Timer */
 	iowrite16(adapter->ict, hw->hw_addr + REG_CMBDISDMA_TIMER);
 
-	/* set MTU, 4 : VLAN */
-	iowrite32(hw->max_frame_size + 4, hw->hw_addr + REG_MTU);
+	/* set max frame size hw will accept */
+	iowrite32(hw->max_frame_size, hw->hw_addr + REG_MTU);
 
 	/* jumbo size & rrd retirement timer */
 	value = (((u32) hw->rx_jumbo_th & RXQ_JMBOSZ_TH_MASK)
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 25b8dbf..b57bc94 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -979,7 +979,7 @@ static void alb_swap_mac_addr(struct bonding *bond, struct slave *slave1, struct
 /*
  * Send learning packets after MAC address swap.
  *
- * Called with RTNL and bond->lock held for read.
+ * Called with RTNL and no other locks
  */
 static void alb_fasten_mac_swap(struct bonding *bond, struct slave *slave1,
 				struct slave *slave2)
@@ -987,6 +987,8 @@ static void alb_fasten_mac_swap(struct bonding *bond, struct slave *slave1,
 	int slaves_state_differ = (SLAVE_IS_OK(slave1) != SLAVE_IS_OK(slave2));
 	struct slave *disabled_slave = NULL;
 
+	ASSERT_RTNL();
+
 	/* fasten the change in the switch */
 	if (SLAVE_IS_OK(slave1)) {
 		alb_send_learning_packets(slave1, slave1->dev->dev_addr);
@@ -1031,7 +1033,7 @@ static void alb_fasten_mac_swap(struct bonding *bond, struct slave *slave1,
  * a slave that has @slave's permanet address as its current address.
  * We'll make sure that that slave no longer uses @slave's permanent address.
  *
- * Caller must hold bond lock
+ * Caller must hold RTNL and no other locks
  */
 static void alb_change_hw_addr_on_detach(struct bonding *bond, struct slave *slave)
 {
@@ -1542,7 +1544,12 @@ int bond_alb_init_slave(struct bonding *bond, struct slave *slave)
 	return 0;
 }
 
-/* Caller must hold bond lock for write */
+/*
+ * Remove slave from tlb and rlb hash tables, and fix up MAC addresses
+ * if necessary.
+ *
+ * Caller must hold RTNL and no other locks
+ */
 void bond_alb_deinit_slave(struct bonding *bond, struct slave *slave)
 {
 	if (bond->slave_cnt > 1) {
@@ -1601,9 +1608,6 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
 	struct slave *swap_slave;
 	int i;
 
-	if (new_slave)
-		ASSERT_RTNL();
-
 	if (bond->curr_active_slave == new_slave) {
 		return;
 	}
@@ -1649,6 +1653,8 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
 	write_unlock_bh(&bond->curr_slave_lock);
 	read_unlock(&bond->lock);
 
+	ASSERT_RTNL();
+
 	/* curr_active_slave must be set before calling alb_swap_mac_addr */
 	if (swap_slave) {
 		/* swap mac address */
@@ -1659,12 +1665,11 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
 				       bond->alb_info.rlb_enabled);
 	}
 
-	read_lock(&bond->lock);
-
 	if (swap_slave) {
 		alb_fasten_mac_swap(bond, swap_slave, new_slave);
+		read_lock(&bond->lock);
 	} else {
-		/* fasten bond mac on new current slave */
+		read_lock(&bond->lock);
 		alb_send_learning_packets(new_slave, bond->dev->dev_addr);
 	}
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index b0b2603..49a1982 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1746,7 +1746,9 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 		 * has been cleared (if our_slave == old_current),
 		 * but before a new active slave is selected.
 		 */
+		write_unlock_bh(&bond->lock);
 		bond_alb_deinit_slave(bond, slave);
+		write_lock_bh(&bond->lock);
 	}
 
 	if (oldcurrent == slave) {
@@ -1905,6 +1907,12 @@ static int bond_release_all(struct net_device *bond_dev)
 		slave_dev = slave->dev;
 		bond_detach_slave(bond, slave);
 
+		/* now that the slave is detached, unlock and perform
+		 * all the undo steps that should not be called from
+		 * within a lock.
+		 */
+		write_unlock_bh(&bond->lock);
+
 		if ((bond->params.mode == BOND_MODE_TLB) ||
 		    (bond->params.mode == BOND_MODE_ALB)) {
 			/* must be called only after the slave
@@ -1915,12 +1923,6 @@ static int bond_release_all(struct net_device *bond_dev)
 
 		bond_compute_features(bond);
 
-		/* now that the slave is detached, unlock and perform
-		 * all the undo steps that should not be called from
-		 * within a lock.
-		 */
-		write_unlock_bh(&bond->lock);
-
 		bond_destroy_slave_symlinks(bond_dev, slave_dev);
 		bond_del_vlans_from_slave(bond, slave_dev);
 
@@ -2384,7 +2386,9 @@ void bond_mii_monitor(struct work_struct *work)
 		rtnl_lock();
 		read_lock(&bond->lock);
 		__bond_mii_monitor(bond, 1);
-		rtnl_unlock();
+		read_unlock(&bond->lock);
+		rtnl_unlock();	/* might sleep, hold no other locks */
+		read_lock(&bond->lock);
 	}
 
 	delay = ((bond->params.miimon * HZ) / 1000) ? : 1;
@@ -3399,9 +3403,7 @@ static int bond_master_netdev_event(unsigned long event, struct net_device *bond
 	case NETDEV_CHANGENAME:
 		return bond_event_changename(event_bond);
 	case NETDEV_UNREGISTER:
-		/*
-		 * TODO: remove a bond from the list?
-		 */
+		bond_release_all(event_bond->dev);
 		break;
 	default:
 		break;
@@ -4540,18 +4542,27 @@ static void bond_free_all(void)
 
 /*
  * Convert string input module parms.  Accept either the
- * number of the mode or its string name.
+ * number of the mode or its string name.  A bit complicated because
+ * some mode names are substrings of other names, and calls from sysfs
+ * may have whitespace in the name (trailing newlines, for example).
  */
-int bond_parse_parm(char *mode_arg, struct bond_parm_tbl *tbl)
+int bond_parse_parm(const char *buf, struct bond_parm_tbl *tbl)
 {
-	int i;
+	int mode = -1, i, rv;
+	char modestr[BOND_MAX_MODENAME_LEN + 1] = { 0, };
+
+	rv = sscanf(buf, "%d", &mode);
+	if (!rv) {
+		rv = sscanf(buf, "%20s", modestr);
+		if (!rv)
+			return -1;
+	}
 
 	for (i = 0; tbl[i].modename; i++) {
-		if ((isdigit(*mode_arg) &&
-		     tbl[i].mode == simple_strtol(mode_arg, NULL, 0)) ||
-		    (strcmp(mode_arg, tbl[i].modename) == 0)) {
+		if (mode == tbl[i].mode)
+			return tbl[i].mode;
+		if (strcmp(modestr, tbl[i].modename) == 0)
 			return tbl[i].mode;
-		}
 	}
 
 	return -1;
@@ -4865,9 +4876,22 @@ static struct lock_class_key bonding_netdev_xmit_lock_key;
 int bond_create(char *name, struct bond_params *params, struct bonding **newbond)
 {
 	struct net_device *bond_dev;
+	struct bonding *bond, *nxt;
 	int res;
 
 	rtnl_lock();
+	down_write(&bonding_rwsem);
+
+	/* Check to see if the bond already exists. */
+	list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list)
+		if (strnicmp(bond->dev->name, name, IFNAMSIZ) == 0) {
+			printk(KERN_ERR DRV_NAME
+			       ": cannot add bond %s; it already exists\n",
+			       name);
+			res = -EPERM;
+			goto out_rtnl;
+		}
+
 	bond_dev = alloc_netdev(sizeof(struct bonding), name ? name : "",
 				ether_setup);
 	if (!bond_dev) {
@@ -4906,10 +4930,12 @@ int bond_create(char *name, struct bond_params *params, struct bonding **newbond
 
 	netif_carrier_off(bond_dev);
 
+	up_write(&bonding_rwsem);
 	rtnl_unlock(); /* allows sysfs registration of net device */
 	res = bond_create_sysfs_entry(bond_dev->priv);
 	if (res < 0) {
 		rtnl_lock();
+		down_write(&bonding_rwsem);
 		goto out_bond;
 	}
 
@@ -4920,6 +4946,7 @@ out_bond:
 out_netdev:
 	free_netdev(bond_dev);
 out_rtnl:
+	up_write(&bonding_rwsem);
 	rtnl_unlock();
 	return res;
 }
@@ -4940,6 +4967,9 @@ static int __init bonding_init(void)
 #ifdef CONFIG_PROC_FS
 	bond_create_proc_dir();
 #endif
+
+	init_rwsem(&bonding_rwsem);
+
 	for (i = 0; i < max_bonds; i++) {
 		res = bond_create(NULL, &bonding_defaults, NULL);
 		if (res)
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 11b76b3..90a1f31 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -109,11 +109,10 @@ static ssize_t bonding_store_bonds(struct class *cls, const char *buffer, size_t
 {
 	char command[IFNAMSIZ + 1] = {0, };
 	char *ifname;
-	int res = count;
+	int rv, res = count;
 	struct bonding *bond;
 	struct bonding *nxt;
 
-	down_write(&(bonding_rwsem));
 	sscanf(buffer, "%16s", command); /* IFNAMSIZ*/
 	ifname = command + 1;
 	if ((strlen(command) <= 1) ||
@@ -121,39 +120,28 @@ static ssize_t bonding_store_bonds(struct class *cls, const char *buffer, size_t
 		goto err_no_cmd;
 
 	if (command[0] == '+') {
-
-		/* Check to see if the bond already exists. */
-		list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list)
-			if (strnicmp(bond->dev->name, ifname, IFNAMSIZ) == 0) {
-				printk(KERN_ERR DRV_NAME
-					": cannot add bond %s; it already exists\n",
-					ifname);
-				res = -EPERM;
-				goto out;
-			}
-
 		printk(KERN_INFO DRV_NAME
 			": %s is being created...\n", ifname);
-		if (bond_create(ifname, &bonding_defaults, &bond)) {
-			printk(KERN_INFO DRV_NAME
-			": %s interface already exists. Bond creation failed.\n",
-			ifname);
-			res = -EPERM;
+		rv = bond_create(ifname, &bonding_defaults, &bond);
+		if (rv) {
+			printk(KERN_INFO DRV_NAME ": Bond creation failed.\n");
+			res = rv;
 		}
 		goto out;
 	}
 
 	if (command[0] == '-') {
+		rtnl_lock();
+		down_write(&bonding_rwsem);
+
 		list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list)
 			if (strnicmp(bond->dev->name, ifname, IFNAMSIZ) == 0) {
-				rtnl_lock();
 				/* check the ref count on the bond's kobject.
 				 * If it's > expected, then there's a file open,
 				 * and we have to fail.
 				 */
 				if (atomic_read(&bond->dev->dev.kobj.kref.refcount)
 							> expected_refcount){
-					rtnl_unlock();
 					printk(KERN_INFO DRV_NAME
 						": Unable remove bond %s due to open references.\n",
 						ifname);
@@ -164,6 +152,7 @@ static ssize_t bonding_store_bonds(struct class *cls, const char *buffer, size_t
 					": %s is being deleted...\n",
 					bond->dev->name);
 				bond_destroy(bond);
+				up_write(&bonding_rwsem);
 				rtnl_unlock();
 				goto out;
 			}
@@ -171,6 +160,8 @@ static ssize_t bonding_store_bonds(struct class *cls, const char *buffer, size_t
 		printk(KERN_ERR DRV_NAME
 			": unable to delete non-existent bond %s\n", ifname);
 		res = -ENODEV;
+		up_write(&bonding_rwsem);
+		rtnl_unlock();
 		goto out;
 	}
 
@@ -183,7 +174,6 @@ err_no_cmd:
 	 * get called forever, which is bad.
 	 */
 out:
-	up_write(&(bonding_rwsem));
 	return res;
 }
 /* class attribute for bond_masters file.  This ends up in /sys/class/net */
@@ -271,6 +261,9 @@ static ssize_t bonding_store_slaves(struct device *d,
 
 	/* Note:  We can't hold bond->lock here, as bond_create grabs it. */
 
+	rtnl_lock();
+	down_write(&(bonding_rwsem));
+
 	sscanf(buffer, "%16s", command); /* IFNAMSIZ*/
 	ifname = command + 1;
 	if ((strlen(command) <= 1) ||
@@ -336,12 +329,10 @@ static ssize_t bonding_store_slaves(struct device *d,
 				dev->mtu = bond->dev->mtu;
 			}
 		}
-		rtnl_lock();
 		res = bond_enslave(bond->dev, dev);
 		bond_for_each_slave(bond, slave, i)
 			if (strnicmp(slave->dev->name, ifname, IFNAMSIZ) == 0)
 				slave->original_mtu = original_mtu;
-		rtnl_unlock();
 		if (res) {
 			ret = res;
 		}
@@ -359,12 +350,10 @@ static ssize_t bonding_store_slaves(struct device *d,
 		if (dev) {
 			printk(KERN_INFO DRV_NAME ": %s: Removing slave %s\n",
 				bond->dev->name, dev->name);
-			rtnl_lock();
 			if (bond->setup_by_slave)
 				res = bond_release_and_destroy(bond->dev, dev);
 			else
 				res = bond_release(bond->dev, dev);
-			rtnl_unlock();
 			if (res) {
 				ret = res;
 				goto out;
@@ -389,6 +378,8 @@ err_no_cmd:
 	ret = -EPERM;
 
 out:
+	up_write(&(bonding_rwsem));
+	rtnl_unlock();
 	return ret;
 }
 
@@ -423,7 +414,7 @@ static ssize_t bonding_store_mode(struct device *d,
 		goto out;
 	}
 
-	new_value = bond_parse_parm((char *)buf, bond_mode_tbl);
+	new_value = bond_parse_parm(buf, bond_mode_tbl);
 	if (new_value < 0)  {
 		printk(KERN_ERR DRV_NAME
 		       ": %s: Ignoring invalid mode value %.*s.\n",
@@ -478,7 +469,7 @@ static ssize_t bonding_store_xmit_hash(struct device *d,
 		goto out;
 	}
 
-	new_value = bond_parse_parm((char *)buf, xmit_hashtype_tbl);
+	new_value = bond_parse_parm(buf, xmit_hashtype_tbl);
 	if (new_value < 0)  {
 		printk(KERN_ERR DRV_NAME
 		       ": %s: Ignoring invalid xmit hash policy value %.*s.\n",
@@ -518,7 +509,7 @@ static ssize_t bonding_store_arp_validate(struct device *d,
 	int new_value;
 	struct bonding *bond = to_bond(d);
 
-	new_value = bond_parse_parm((char *)buf, arp_validate_tbl);
+	new_value = bond_parse_parm(buf, arp_validate_tbl);
 	if (new_value < 0) {
 		printk(KERN_ERR DRV_NAME
 		       ": %s: Ignoring invalid arp_validate value %s\n",
@@ -941,7 +932,7 @@ static ssize_t bonding_store_lacp(struct device *d,
 		goto out;
 	}
 
-	new_value = bond_parse_parm((char *)buf, bond_lacp_tbl);
+	new_value = bond_parse_parm(buf, bond_lacp_tbl);
 
 	if ((new_value == 1) || (new_value == 0)) {
 		bond->params.lacp_fast = new_value;
@@ -1075,7 +1066,10 @@ static ssize_t bonding_store_primary(struct device *d,
 	struct slave *slave;
 	struct bonding *bond = to_bond(d);
 
-	write_lock_bh(&bond->lock);
+	rtnl_lock();
+	read_lock(&bond->lock);
+	write_lock_bh(&bond->curr_slave_lock);
+
 	if (!USES_PRIMARY(bond->params.mode)) {
 		printk(KERN_INFO DRV_NAME
 		       ": %s: Unable to set primary slave; %s is in mode %d\n",
@@ -1109,8 +1103,8 @@ static ssize_t bonding_store_primary(struct device *d,
 		}
 	}
 out:
-	write_unlock_bh(&bond->lock);
-
+	write_unlock_bh(&bond->curr_slave_lock);
+	read_unlock(&bond->lock);
 	rtnl_unlock();
 
 	return count;
@@ -1190,7 +1184,8 @@ static ssize_t bonding_store_active_slave(struct device *d,
 	struct bonding *bond = to_bond(d);
 
 	rtnl_lock();
-	write_lock_bh(&bond->lock);
+	read_lock(&bond->lock);
+	write_lock_bh(&bond->curr_slave_lock);
 
 	if (!USES_PRIMARY(bond->params.mode)) {
 		printk(KERN_INFO DRV_NAME
@@ -1247,7 +1242,8 @@ static ssize_t bonding_store_active_slave(struct device *d,
 		}
 	}
 out:
-	write_unlock_bh(&bond->lock);
+	write_unlock_bh(&bond->curr_slave_lock);
+	read_unlock(&bond->lock);
 	rtnl_unlock();
 
 	return count;
@@ -1418,8 +1414,6 @@ int bond_create_sysfs(void)
 	int ret = 0;
 	struct bonding *firstbond;
 
-	init_rwsem(&bonding_rwsem);
-
 	/* get the netdev class pointer */
 	firstbond = container_of(bond_dev_list.next, struct bonding, bond_list);
 	if (!firstbond)
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index e1e4734..6d83be4 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -141,6 +141,8 @@ struct bond_parm_tbl {
 	int mode;
 };
 
+#define BOND_MAX_MODENAME_LEN 20
+
 struct vlan_entry {
 	struct list_head vlan_list;
 	__be32 vlan_ip;
@@ -314,7 +316,7 @@ void bond_mii_monitor(struct work_struct *);
 void bond_loadbalance_arp_mon(struct work_struct *);
 void bond_activebackup_arp_mon(struct work_struct *);
 void bond_set_mode_ops(struct bonding *bond, int mode);
-int bond_parse_parm(char *mode_arg, struct bond_parm_tbl *tbl);
+int bond_parse_parm(const char *mode_arg, struct bond_parm_tbl *tbl);
 void bond_select_active_slave(struct bonding *bond);
 void bond_change_active_slave(struct bonding *bond, struct slave *new_active);
 void bond_register_arp(struct bonding *);
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index 6fd95a2..6e12d48 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -459,7 +459,7 @@ static int cpmac_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_OK;
 
 	len = max(skb->len, ETH_ZLEN);
-	queue = skb->queue_mapping;
+	queue = skb_get_queue_mapping(skb);
 #ifdef CONFIG_NETDEVICES_MULTIQUEUE
 	netif_stop_subqueue(dev, queue);
 #else
diff --git a/drivers/net/dl2k.c b/drivers/net/dl2k.c
index 47cce9c..e233d04 100644
--- a/drivers/net/dl2k.c
+++ b/drivers/net/dl2k.c
@@ -1316,9 +1316,10 @@ rio_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
 			    ("%02x:cur:%08x next:%08x status:%08x frag1:%08x frag0:%08x",
 			     i,
 			     (u32) (np->tx_ring_dma + i * sizeof (*desc)),
-			     (u32) desc->next_desc,
-			     (u32) desc->status, (u32) (desc->fraginfo >> 32),
-			     (u32) desc->fraginfo);
+			     (u32)le64_to_cpu(desc->next_desc),
+			     (u32)le64_to_cpu(desc->status),
+			     (u32)(le64_to_cpu(desc->fraginfo) >> 32),
+			     (u32)le64_to_cpu(desc->fraginfo));
 			printk ("\n");
 		}
 		printk ("\n");
@@ -1435,7 +1436,7 @@ mii_write (struct net_device *dev, int phy_addr, int reg_num, u16 data)
 static int
 mii_wait_link (struct net_device *dev, int wait)
 {
-	BMSR_t bmsr;
+	__u16 bmsr;
 	int phy_addr;
 	struct netdev_private *np;
 
@@ -1443,8 +1444,8 @@ mii_wait_link (struct net_device *dev, int wait)
 	phy_addr = np->phy_addr;
 
 	do {
-		bmsr.image = mii_read (dev, phy_addr, MII_BMSR);
-		if (bmsr.bits.link_status)
+		bmsr = mii_read (dev, phy_addr, MII_BMSR);
+		if (bmsr & MII_BMSR_LINK_STATUS)
 			return 0;
 		mdelay (1);
 	} while (--wait > 0);
@@ -1453,70 +1454,72 @@ mii_wait_link (struct net_device *dev, int wait)
 static int
 mii_get_media (struct net_device *dev)
 {
-	ANAR_t negotiate;
-	BMSR_t bmsr;
-	BMCR_t bmcr;
-	MSCR_t mscr;
-	MSSR_t mssr;
+	__u16 negotiate;
+	__u16 bmsr;
+	__u16 mscr;
+	__u16 mssr;
 	int phy_addr;
 	struct netdev_private *np;
 
 	np = netdev_priv(dev);
 	phy_addr = np->phy_addr;
 
-	bmsr.image = mii_read (dev, phy_addr, MII_BMSR);
+	bmsr = mii_read (dev, phy_addr, MII_BMSR);
 	if (np->an_enable) {
-		if (!bmsr.bits.an_complete) {
+		if (!(bmsr & MII_BMSR_AN_COMPLETE)) {
 			/* Auto-Negotiation not completed */
 			return -1;
 		}
-		negotiate.image = mii_read (dev, phy_addr, MII_ANAR) &
+		negotiate = mii_read (dev, phy_addr, MII_ANAR) &
 			mii_read (dev, phy_addr, MII_ANLPAR);
-		mscr.image = mii_read (dev, phy_addr, MII_MSCR);
-		mssr.image = mii_read (dev, phy_addr, MII_MSSR);
-		if (mscr.bits.media_1000BT_FD & mssr.bits.lp_1000BT_FD) {
+		mscr = mii_read (dev, phy_addr, MII_MSCR);
+		mssr = mii_read (dev, phy_addr, MII_MSSR);
+		if (mscr & MII_MSCR_1000BT_FD && mssr & MII_MSSR_LP_1000BT_FD) {
 			np->speed = 1000;
 			np->full_duplex = 1;
 			printk (KERN_INFO "Auto 1000 Mbps, Full duplex\n");
-		} else if (mscr.bits.media_1000BT_HD & mssr.bits.lp_1000BT_HD) {
+		} else if (mscr & MII_MSCR_1000BT_HD && mssr & MII_MSSR_LP_1000BT_HD) {
 			np->speed = 1000;
 			np->full_duplex = 0;
 			printk (KERN_INFO "Auto 1000 Mbps, Half duplex\n");
-		} else if (negotiate.bits.media_100BX_FD) {
+		} else if (negotiate & MII_ANAR_100BX_FD) {
 			np->speed = 100;
 			np->full_duplex = 1;
 			printk (KERN_INFO "Auto 100 Mbps, Full duplex\n");
-		} else if (negotiate.bits.media_100BX_HD) {
+		} else if (negotiate & MII_ANAR_100BX_HD) {
 			np->speed = 100;
 			np->full_duplex = 0;
 			printk (KERN_INFO "Auto 100 Mbps, Half duplex\n");
-		} else if (negotiate.bits.media_10BT_FD) {
+		} else if (negotiate & MII_ANAR_10BT_FD) {
 			np->speed = 10;
 			np->full_duplex = 1;
 			printk (KERN_INFO "Auto 10 Mbps, Full duplex\n");
-		} else if (negotiate.bits.media_10BT_HD) {
+		} else if (negotiate & MII_ANAR_10BT_HD) {
 			np->speed = 10;
 			np->full_duplex = 0;
 			printk (KERN_INFO "Auto 10 Mbps, Half duplex\n");
 		}
-		if (negotiate.bits.pause) {
+		if (negotiate & MII_ANAR_PAUSE) {
 			np->tx_flow &= 1;
 			np->rx_flow &= 1;
-		} else if (negotiate.bits.asymmetric) {
+		} else if (negotiate & MII_ANAR_ASYMMETRIC) {
 			np->tx_flow = 0;
 			np->rx_flow &= 1;
 		}
 		/* else tx_flow, rx_flow = user select  */
 	} else {
-		bmcr.image = mii_read (dev, phy_addr, MII_BMCR);
-		if (bmcr.bits.speed100 == 1 && bmcr.bits.speed1000 == 0) {
+		__u16 bmcr = mii_read (dev, phy_addr, MII_BMCR);
+		switch (bmcr & (MII_BMCR_SPEED_100 | MII_BMCR_SPEED_1000)) {
+		case MII_BMCR_SPEED_1000:
+			printk (KERN_INFO "Operating at 1000 Mbps, ");
+			break;
+		case MII_BMCR_SPEED_100:
 			printk (KERN_INFO "Operating at 100 Mbps, ");
-		} else if (bmcr.bits.speed100 == 0 && bmcr.bits.speed1000 == 0) {
+			break;
+		case 0:
 			printk (KERN_INFO "Operating at 10 Mbps, ");
-		} else if (bmcr.bits.speed100 == 0 && bmcr.bits.speed1000 == 1) {
-			printk (KERN_INFO "Operating at 1000 Mbps, ");
 		}
-		if (bmcr.bits.duplex_mode) {
+		if (bmcr & MII_BMCR_DUPLEX_MODE) {
 			printk ("Full duplex\n");
 		} else {
 			printk ("Half duplex\n");
@@ -1537,10 +1540,10 @@ mii_get_media (struct net_device *dev)
 static int
 mii_set_media (struct net_device *dev)
 {
-	PHY_SCR_t pscr;
-	BMCR_t bmcr;
-	BMSR_t bmsr;
-	ANAR_t anar;
+	__u16 pscr;
+	__u16 bmcr;
+	__u16 bmsr;
+	__u16 anar;
 	int phy_addr;
 	struct netdev_private *np;
 	np = netdev_priv(dev);
@@ -1549,76 +1552,77 @@ mii_set_media (struct net_device *dev)
 	/* Does user set speed? */
 	if (np->an_enable) {
 		/* Advertise capabilities */
-		bmsr.image = mii_read (dev, phy_addr, MII_BMSR);
-		anar.image = mii_read (dev, phy_addr, MII_ANAR);
-		anar.bits.media_100BX_FD = bmsr.bits.media_100BX_FD;
-		anar.bits.media_100BX_HD = bmsr.bits.media_100BX_HD;
-		anar.bits.media_100BT4 = bmsr.bits.media_100BT4;
-		anar.bits.media_10BT_FD = bmsr.bits.media_10BT_FD;
-		anar.bits.media_10BT_HD = bmsr.bits.media_10BT_HD;
-		anar.bits.pause = 1;
-		anar.bits.asymmetric = 1;
-		mii_write (dev, phy_addr, MII_ANAR, anar.image);
+		bmsr = mii_read (dev, phy_addr, MII_BMSR);
+		anar = mii_read (dev, phy_addr, MII_ANAR) &
+			     ~MII_ANAR_100BX_FD &
+			     ~MII_ANAR_100BX_HD &
+			     ~MII_ANAR_100BT4 &
+			     ~MII_ANAR_10BT_FD &
+			     ~MII_ANAR_10BT_HD;
+		if (bmsr & MII_BMSR_100BX_FD)
+			anar |= MII_ANAR_100BX_FD;
+		if (bmsr & MII_BMSR_100BX_HD)
+			anar |= MII_ANAR_100BX_HD;
+		if (bmsr & MII_BMSR_100BT4)
+			anar |= MII_ANAR_100BT4;
+		if (bmsr & MII_BMSR_10BT_FD)
+			anar |= MII_ANAR_10BT_FD;
+		if (bmsr & MII_BMSR_10BT_HD)
+			anar |= MII_ANAR_10BT_HD;
+		anar |= MII_ANAR_PAUSE | MII_ANAR_ASYMMETRIC;
+		mii_write (dev, phy_addr, MII_ANAR, anar);
 
 		/* Enable Auto crossover */
-		pscr.image = mii_read (dev, phy_addr, MII_PHY_SCR);
-		pscr.bits.mdi_crossover_mode = 3;	/* 11'b */
-		mii_write (dev, phy_addr, MII_PHY_SCR, pscr.image);
+		pscr = mii_read (dev, phy_addr, MII_PHY_SCR);
+		pscr |= 3 << 5;	/* 11'b */
+		mii_write (dev, phy_addr, MII_PHY_SCR, pscr);
 
 		/* Soft reset PHY */
 		mii_write (dev, phy_addr, MII_BMCR, MII_BMCR_RESET);
-		bmcr.image = 0;
-		bmcr.bits.an_enable = 1;
-		bmcr.bits.restart_an = 1;
-		bmcr.bits.reset = 1;
-		mii_write (dev, phy_addr, MII_BMCR, bmcr.image);
+		bmcr = MII_BMCR_AN_ENABLE | MII_BMCR_RESTART_AN | MII_BMCR_RESET;
+		mii_write (dev, phy_addr, MII_BMCR, bmcr);
 		mdelay(1);
 	} else {
 		/* Force speed setting */
 		/* 1) Disable Auto crossover */
-		pscr.image = mii_read (dev, phy_addr, MII_PHY_SCR);
-		pscr.bits.mdi_crossover_mode = 0;
-		mii_write (dev, phy_addr, MII_PHY_SCR, pscr.image);
+		pscr = mii_read (dev, phy_addr, MII_PHY_SCR);
+		pscr &= ~(3 << 5);
+		mii_write (dev, phy_addr, MII_PHY_SCR, pscr);
 
 		/* 2) PHY Reset */
-		bmcr.image = mii_read (dev, phy_addr, MII_BMCR);
-		bmcr.bits.reset = 1;
-		mii_write (dev, phy_addr, MII_BMCR, bmcr.image);
+		bmcr = mii_read (dev, phy_addr, MII_BMCR);
+		bmcr |= MII_BMCR_RESET;
+		mii_write (dev, phy_addr, MII_BMCR, bmcr);
 
 		/* 3) Power Down */
-		bmcr.image = 0x1940;	/* must be 0x1940 */
-		mii_write (dev, phy_addr, MII_BMCR, bmcr.image);
+		bmcr = 0x1940;	/* must be 0x1940 */
+		mii_write (dev, phy_addr, MII_BMCR, bmcr);
 		mdelay (100);	/* wait a certain time */
 
 		/* 4) Advertise nothing */
 		mii_write (dev, phy_addr, MII_ANAR, 0);
 
 		/* 5) Set media and Power Up */
-		bmcr.image = 0;
-		bmcr.bits.power_down = 1;
+		bmcr = MII_BMCR_POWER_DOWN;
 		if (np->speed == 100) {
-			bmcr.bits.speed100 = 1;
-			bmcr.bits.speed1000 = 0;
+			bmcr |= MII_BMCR_SPEED_100;
 			printk (KERN_INFO "Manual 100 Mbps, ");
 		} else if (np->speed == 10) {
-			bmcr.bits.speed100 = 0;
-			bmcr.bits.speed1000 = 0;
 			printk (KERN_INFO "Manual 10 Mbps, ");
 		}
 		if (np->full_duplex) {
-			bmcr.bits.duplex_mode = 1;
+			bmcr |= MII_BMCR_DUPLEX_MODE;
 			printk ("Full duplex\n");
 		} else {
-			bmcr.bits.duplex_mode = 0;
 			printk ("Half duplex\n");
 		}
 #if 0
 		/* Set 1000BaseT Master/Slave setting */
-		mscr.image = mii_read (dev, phy_addr, MII_MSCR);
-		mscr.bits.cfg_enable = 1;
-		mscr.bits.cfg_value = 0;
+		mscr = mii_read (dev, phy_addr, MII_MSCR);
+		mscr |= MII_MSCR_CFG_ENABLE;
+		mscr &= ~MII_MSCR_CFG_VALUE = 0;
 #endif
-		mii_write (dev, phy_addr, MII_BMCR, bmcr.image);
+		mii_write (dev, phy_addr, MII_BMCR, bmcr);
 		mdelay(10);
 	}
 	return 0;
@@ -1627,43 +1631,42 @@ mii_set_media (struct net_device *dev)
 static int
 mii_get_media_pcs (struct net_device *dev)
 {
-	ANAR_PCS_t negotiate;
-	BMSR_t bmsr;
-	BMCR_t bmcr;
+	__u16 negotiate;
+	__u16 bmsr;
 	int phy_addr;
 	struct netdev_private *np;
 
 	np = netdev_priv(dev);
 	phy_addr = np->phy_addr;
 
-	bmsr.image = mii_read (dev, phy_addr, PCS_BMSR);
+	bmsr = mii_read (dev, phy_addr, PCS_BMSR);
 	if (np->an_enable) {
-		if (!bmsr.bits.an_complete) {
+		if (!(bmsr & MII_BMSR_AN_COMPLETE)) {
 			/* Auto-Negotiation not completed */
 			return -1;
 		}
-		negotiate.image = mii_read (dev, phy_addr, PCS_ANAR) &
+		negotiate = mii_read (dev, phy_addr, PCS_ANAR) &
 			mii_read (dev, phy_addr, PCS_ANLPAR);
 		np->speed = 1000;
-		if (negotiate.bits.full_duplex) {
+		if (negotiate & PCS_ANAR_FULL_DUPLEX) {
 			printk (KERN_INFO "Auto 1000 Mbps, Full duplex\n");
 			np->full_duplex = 1;
 		} else {
 			printk (KERN_INFO "Auto 1000 Mbps, half duplex\n");
 			np->full_duplex = 0;
 		}
-		if (negotiate.bits.pause) {
+		if (negotiate & PCS_ANAR_PAUSE) {
 			np->tx_flow &= 1;
 			np->rx_flow &= 1;
-		} else if (negotiate.bits.asymmetric) {
+		} else if (negotiate & PCS_ANAR_ASYMMETRIC) {
 			np->tx_flow = 0;
 			np->rx_flow &= 1;
 		}
 		/* else tx_flow, rx_flow = user select  */
 	} else {
-		bmcr.image = mii_read (dev, phy_addr, PCS_BMCR);
+		__u16 bmcr = mii_read (dev, phy_addr, PCS_BMCR);
 		printk (KERN_INFO "Operating at 1000 Mbps, ");
-		if (bmcr.bits.duplex_mode) {
+		if (bmcr & MII_BMCR_DUPLEX_MODE) {
 			printk ("Full duplex\n");
 		} else {
 			printk ("Half duplex\n");
@@ -1684,9 +1687,9 @@ mii_get_media_pcs (struct net_device *dev)
 static int
 mii_set_media_pcs (struct net_device *dev)
 {
-	BMCR_t bmcr;
-	ESR_t esr;
-	ANAR_PCS_t anar;
+	__u16 bmcr;
+	__u16 esr;
+	__u16 anar;
 	int phy_addr;
 	struct netdev_private *np;
 	np = netdev_priv(dev);
@@ -1695,41 +1698,37 @@ mii_set_media_pcs (struct net_device *dev)
 	/* Auto-Negotiation? */
 	if (np->an_enable) {
 		/* Advertise capabilities */
-		esr.image = mii_read (dev, phy_addr, PCS_ESR);
-		anar.image = mii_read (dev, phy_addr, MII_ANAR);
-		anar.bits.half_duplex =
-			esr.bits.media_1000BT_HD | esr.bits.media_1000BX_HD;
-		anar.bits.full_duplex =
-			esr.bits.media_1000BT_FD | esr.bits.media_1000BX_FD;
-		anar.bits.pause = 1;
-		anar.bits.asymmetric = 1;
-		mii_write (dev, phy_addr, MII_ANAR, anar.image);
+		esr = mii_read (dev, phy_addr, PCS_ESR);
+		anar = mii_read (dev, phy_addr, MII_ANAR) &
+			~PCS_ANAR_HALF_DUPLEX &
+			~PCS_ANAR_FULL_DUPLEX;
+		if (esr & (MII_ESR_1000BT_HD | MII_ESR_1000BX_HD))
+			anar |= PCS_ANAR_HALF_DUPLEX;
+		if (esr & (MII_ESR_1000BT_FD | MII_ESR_1000BX_FD))
+			anar |= PCS_ANAR_FULL_DUPLEX;
+		anar |= PCS_ANAR_PAUSE | PCS_ANAR_ASYMMETRIC;
+		mii_write (dev, phy_addr, MII_ANAR, anar);
 
 		/* Soft reset PHY */
 		mii_write (dev, phy_addr, MII_BMCR, MII_BMCR_RESET);
-		bmcr.image = 0;
-		bmcr.bits.an_enable = 1;
-		bmcr.bits.restart_an = 1;
-		bmcr.bits.reset = 1;
-		mii_write (dev, phy_addr, MII_BMCR, bmcr.image);
+		bmcr = MII_BMCR_AN_ENABLE | MII_BMCR_RESTART_AN |
+		       MII_BMCR_RESET;
+		mii_write (dev, phy_addr, MII_BMCR, bmcr);
 		mdelay(1);
 	} else {
 		/* Force speed setting */
 		/* PHY Reset */
-		bmcr.image = 0;
-		bmcr.bits.reset = 1;
-		mii_write (dev, phy_addr, MII_BMCR, bmcr.image);
+		bmcr = MII_BMCR_RESET;
+		mii_write (dev, phy_addr, MII_BMCR, bmcr);
 		mdelay(10);
-		bmcr.image = 0;
-		bmcr.bits.an_enable = 0;
 		if (np->full_duplex) {
-			bmcr.bits.duplex_mode = 1;
+			bmcr = MII_BMCR_DUPLEX_MODE;
 			printk (KERN_INFO "Manual full duplex\n");
 		} else {
-			bmcr.bits.duplex_mode = 0;
+			bmcr = 0;
 			printk (KERN_INFO "Manual half duplex\n");
 		}
-		mii_write (dev, phy_addr, MII_BMCR, bmcr.image);
+		mii_write (dev, phy_addr, MII_BMCR, bmcr);
 		mdelay(10);
 
 		/*  Advertise nothing */
diff --git a/drivers/net/dl2k.h b/drivers/net/dl2k.h
index 014b77c..d66c605 100644
--- a/drivers/net/dl2k.h
+++ b/drivers/net/dl2k.h
@@ -298,23 +298,6 @@ enum _pcs_reg {
 };
 
 /* Basic Mode Control Register */
-typedef union t_MII_BMCR {
-	u16 image;
-	struct {
-		u16 _bit_5_0:6;	// bit 5:0
-		u16 speed1000:1;	// bit 6
-		u16 col_test_enable:1;	// bit 7
-		u16 duplex_mode:1;	// bit 8
-		u16 restart_an:1;	// bit 9
-		u16 isolate:1;	// bit 10
-		u16 power_down:1;	// bit 11
-		u16 an_enable:1;	// bit 12
-		u16 speed100:1;	// bit 13
-		u16 loopback:1;	// bit 14
-		u16 reset:1;	// bit 15
-	} bits;
-} BMCR_t, *PBMCR_t;
-
 enum _mii_bmcr {
 	MII_BMCR_RESET = 0x8000,
 	MII_BMCR_LOOP_BACK = 0x4000,
@@ -333,28 +316,6 @@ enum _mii_bmcr {
 };
 
 /* Basic Mode Status Register */
-typedef union t_MII_BMSR {
-	u16 image;
-	struct {
-		u16 ext_capability:1;	// bit 0
-		u16 japper_detect:1;	// bit 1
-		u16 link_status:1;	// bit 2
-		u16 an_ability:1;	// bit 3
-		u16 remote_fault:1;	// bit 4
-		u16 an_complete:1;	// bit 5
-		u16 preamble_supp:1;	// bit 6
-		u16 _bit_7:1;	// bit 7
-		u16 ext_status:1;	// bit 8
-		u16 media_100BT2_HD:1;	// bit 9
-		u16 media_100BT2_FD:1;	// bit 10
-		u16 media_10BT_HD:1;	// bit 11
-		u16 media_10BT_FD:1;	// bit 12
-		u16 media_100BX_HD:1;	// bit 13
-		u16 media_100BX_FD:1;	// bit 14
-		u16 media_100BT4:1;	// bit 15
-	} bits;
-} BMSR_t, *PBMSR_t;
-
 enum _mii_bmsr {
 	MII_BMSR_100BT4 = 0x8000,
 	MII_BMSR_100BX_FD = 0x4000,
@@ -374,24 +335,6 @@ enum _mii_bmsr {
 };
 
 /* ANAR */
-typedef union t_MII_ANAR {
-	u16 image;
-	struct {
-		u16 selector:5;	// bit 4:0
-		u16 media_10BT_HD:1;	// bit 5
-		u16 media_10BT_FD:1;	// bit 6
-		u16 media_100BX_HD:1;	// bit 7
-		u16 media_100BX_FD:1;	// bit 8
-		u16 media_100BT4:1;	// bit 9
-		u16 pause:1;	// bit 10
-		u16 asymmetric:1;	// bit 11
-		u16 _bit12:1;	// bit 12
-		u16 remote_fault:1;	// bit 13
-		u16 _bit14:1;	// bit 14
-		u16 next_page:1;	// bit 15
-	} bits;
-} ANAR_t, *PANAR_t;
-
 enum _mii_anar {
 	MII_ANAR_NEXT_PAGE = 0x8000,
 	MII_ANAR_REMOTE_FAULT = 0x4000,
@@ -407,24 +350,6 @@ enum _mii_anar {
 };
 
 /* ANLPAR */
-typedef union t_MII_ANLPAR {
-	u16 image;
-	struct {
-		u16 selector:5;	// bit 4:0
-		u16 media_10BT_HD:1;	// bit 5
-		u16 media_10BT_FD:1;	// bit 6
-		u16 media_100BX_HD:1;	// bit 7
-		u16 media_100BX_FD:1;	// bit 8
-		u16 media_100BT4:1;	// bit 9
-		u16 pause:1;	// bit 10
-		u16 asymmetric:1;	// bit 11
-		u16 _bit12:1;	// bit 12
-		u16 remote_fault:1;	// bit 13
-		u16 _bit14:1;	// bit 14
-		u16 next_page:1;	// bit 15
-	} bits;
-} ANLPAR_t, *PANLPAR_t;
-
 enum _mii_anlpar {
 	MII_ANLPAR_NEXT_PAGE = MII_ANAR_NEXT_PAGE,
 	MII_ANLPAR_REMOTE_FAULT = MII_ANAR_REMOTE_FAULT,
@@ -439,18 +364,6 @@ enum _mii_anlpar {
 };
 
 /* Auto-Negotiation Expansion Register */
-typedef union t_MII_ANER {
-	u16 image;
-	struct {
-		u16 lp_negotiable:1;	// bit 0
-		u16 page_received:1;	// bit 1
-		u16 nextpagable:1;	// bit 2
-		u16 lp_nextpagable:1;	// bit 3
-		u16 pdetect_fault:1;	// bit 4
-		u16 _bit15_5:11;	// bit 15:5
-	} bits;
-} ANER_t, *PANER_t;
-
 enum _mii_aner {
 	MII_ANER_PAR_DETECT_FAULT = 0x0010,
 	MII_ANER_LP_NEXTPAGABLE = 0x0008,
@@ -460,19 +373,6 @@ enum _mii_aner {
 };
 
 /* MASTER-SLAVE Control Register */
-typedef union t_MII_MSCR {
-	u16 image;
-	struct {
-		u16 _bit_7_0:8;	// bit 7:0
-		u16 media_1000BT_HD:1;	// bit 8
-		u16 media_1000BT_FD:1;	// bit 9
-		u16 port_type:1;	// bit 10
-		u16 cfg_value:1;	// bit 11
-		u16 cfg_enable:1;	// bit 12
-		u16 test_mode:3;	// bit 15:13
-	} bits;
-} MSCR_t, *PMSCR_t;
-
 enum _mii_mscr {
 	MII_MSCR_TEST_MODE = 0xe000,
 	MII_MSCR_CFG_ENABLE = 0x1000,
@@ -483,20 +383,6 @@ enum _mii_mscr {
 };
 
 /* MASTER-SLAVE Status Register */
-typedef union t_MII_MSSR {
-	u16 image;
-	struct {
-		u16 idle_err_count:8;	// bit 7:0
-		u16 _bit_9_8:2;	// bit 9:8
-		u16 lp_1000BT_HD:1;	// bit 10
-		u16 lp_1000BT_FD:1;	// bit 11
-		u16 remote_rcv_status:1;	// bit 12
-		u16 local_rcv_status:1;	// bit 13
-		u16 cfg_resolution:1;	// bit 14
-		u16 cfg_fault:1;	// bit 15
-	} bits;
-} MSSR_t, *PMSSR_t;
-
 enum _mii_mssr {
 	MII_MSSR_CFG_FAULT = 0x8000,
 	MII_MSSR_CFG_RES = 0x4000,
@@ -508,17 +394,6 @@ enum _mii_mssr {
 };
 
 /* IEEE Extened Status Register */
-typedef union t_MII_ESR {
-	u16 image;
-	struct {
-		u16 _bit_11_0:12;	// bit 11:0
-		u16 media_1000BT_HD:2;	// bit 12
-		u16 media_1000BT_FD:1;	// bit 13
-		u16 media_1000BX_HD:1;	// bit 14
-		u16 media_1000BX_FD:1;	// bit 15
-	} bits;
-} ESR_t, *PESR_t;
-
 enum _mii_esr {
 	MII_ESR_1000BX_FD = 0x8000,
 	MII_ESR_1000BX_HD = 0x4000,
@@ -526,6 +401,7 @@ enum _mii_esr {
 	MII_ESR_1000BT_HD = 0x1000,
 };
 /* PHY Specific Control Register */
+#if 0
 typedef union t_MII_PHY_SCR {
 	u16 image;
 	struct {
@@ -543,6 +419,7 @@ typedef union t_MII_PHY_SCR {
 		u16 xmit_fifo_depth:2;	// bit 15:14
 	} bits;
 } PHY_SCR_t, *PPHY_SCR_t;
+#endif
 
 typedef enum t_MII_ADMIN_STATUS {
 	adm_reset,
@@ -556,21 +433,6 @@ typedef enum t_MII_ADMIN_STATUS {
 /* PCS control and status registers bitmap as the same as MII */
 /* PCS Extended Status register bitmap as the same as MII */
 /* PCS ANAR */
-typedef union t_PCS_ANAR {
-	u16 image;
-	struct {
-		u16 _bit_4_0:5;		// bit 4:0
-		u16 full_duplex:1;	// bit 5
-		u16 half_duplex:1;	// bit 6
-		u16 asymmetric:1;	// bit 7
-		u16 pause:1;		// bit 8
-		u16 _bit_11_9:3;	// bit 11:9
-		u16 remote_fault:2;	// bit 13:12
-		u16 _bit_14:1;		// bit 14
-		u16 next_page:1;	// bit 15
-	} bits;
-} ANAR_PCS_t, *PANAR_PCS_t;
-
 enum _pcs_anar {
 	PCS_ANAR_NEXT_PAGE = 0x8000,
 	PCS_ANAR_REMOTE_FAULT = 0x3000,
@@ -580,21 +442,6 @@ enum _pcs_anar {
 	PCS_ANAR_FULL_DUPLEX = 0x0020,
 };
 /* PCS ANLPAR */
-typedef union t_PCS_ANLPAR {
-	u16 image;
-	struct {
-		u16 _bit_4_0:5;		// bit 4:0
-		u16 full_duplex:1;	// bit 5
-		u16 half_duplex:1;	// bit 6
-		u16 asymmetric:1;	// bit 7
-		u16 pause:1;		// bit 8
-		u16 _bit_11_9:3;	// bit 11:9
-		u16 remote_fault:2;	// bit 13:12
-		u16 _bit_14:1;		// bit 14
-		u16 next_page:1;	// bit 15
-	} bits;
-} ANLPAR_PCS_t, *PANLPAR_PCS_t;
-
 enum _pcs_anlpar {
 	PCS_ANLPAR_NEXT_PAGE = PCS_ANAR_NEXT_PAGE,
 	PCS_ANLPAR_REMOTE_FAULT = PCS_ANAR_REMOTE_FAULT,
diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index dbd23bb..50f0c17 100644
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -857,21 +857,14 @@ static void init_tfdlist(struct net_device *dev)
 static void ipg_nic_txfree(struct net_device *dev)
 {
 	struct ipg_nic_private *sp = netdev_priv(dev);
-	void __iomem *ioaddr = sp->ioaddr;
-	unsigned int curr;
-	u64 txd_map;
-	unsigned int released, pending;
-
-	txd_map = (u64)sp->txd_map;
-	curr = ipg_r32(TFD_LIST_PTR_0) -
-		do_div(txd_map, sizeof(struct ipg_tx)) - 1;
+	unsigned int released, pending, dirty;
 
 	IPG_DEBUG_MSG("_nic_txfree\n");
 
 	pending = sp->tx_current - sp->tx_dirty;
+	dirty = sp->tx_dirty % IPG_TFDLIST_LENGTH;
 
 	for (released = 0; released < pending; released++) {
-		unsigned int dirty = sp->tx_dirty % IPG_TFDLIST_LENGTH;
 		struct sk_buff *skb = sp->TxBuff[dirty];
 		struct ipg_tx *txfd = sp->txd + dirty;
 
@@ -882,11 +875,8 @@ static void ipg_nic_txfree(struct net_device *dev)
 		 * If the TFDDone bit is set, free the associated
 		 * buffer.
 		 */
-		if (dirty == curr)
-			break;
-
-		/* Setup TFDDONE for compatible issue. */
-		txfd->tfc |= cpu_to_le64(IPG_TFC_TFDDONE);
+		if (!(txfd->tfc & cpu_to_le64(IPG_TFC_TFDDONE)))
+                        break;
 
 		/* Free the transmit buffer. */
 		if (skb) {
@@ -898,6 +888,7 @@ static void ipg_nic_txfree(struct net_device *dev)
 
 			sp->TxBuff[dirty] = NULL;
 		}
+		dirty = (dirty + 1) % IPG_TFDLIST_LENGTH;
 	}
 
 	sp->tx_dirty += released;
@@ -1630,6 +1621,8 @@ static irqreturn_t ipg_interrupt_handler(int irq, void *dev_inst)
 #ifdef JUMBO_FRAME
 	ipg_nic_rxrestore(dev);
 #endif
+	spin_lock(&sp->lock);
+
 	/* Get interrupt source information, and acknowledge
 	 * some (i.e. TxDMAComplete, RxDMAComplete, RxEarly,
 	 * IntRequested, MacControlFrame, LinkEvent) interrupts
@@ -1647,9 +1640,7 @@ static irqreturn_t ipg_interrupt_handler(int irq, void *dev_inst)
 	handled = 1;
 
 	if (unlikely(!netif_running(dev)))
-		goto out;
-
-	spin_lock(&sp->lock);
+		goto out_unlock;
 
 	/* If RFDListEnd interrupt, restore all used RFDs. */
 	if (status & IPG_IS_RFD_LIST_END) {
@@ -1733,9 +1724,9 @@ out_enable:
 	ipg_w16(IPG_IE_TX_DMA_COMPLETE | IPG_IE_RX_DMA_COMPLETE |
 		IPG_IE_HOST_ERROR | IPG_IE_INT_REQUESTED | IPG_IE_TX_COMPLETE |
 		IPG_IE_LINK_EVENT | IPG_IE_UPDATE_STATS, INT_ENABLE);
-
+out_unlock:
 	spin_unlock(&sp->lock);
-out:
+
 	return IRQ_RETVAL(handled);
 }
 
@@ -1943,10 +1934,7 @@ static int ipg_nic_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 */
 	if (sp->tenmbpsmode)
 		txfd->tfc |= cpu_to_le64(IPG_TFC_TXINDICATE);
-	else if (!((sp->tx_current - sp->tx_dirty + 1) >
-	    IPG_FRAMESBETWEENTXDMACOMPLETES)) {
-		txfd->tfc |= cpu_to_le64(IPG_TFC_TXDMAINDICATE);
-	}
+	txfd->tfc |= cpu_to_le64(IPG_TFC_TXDMAINDICATE);
 	/* Based on compilation option, determine if FCS is to be
 	 * appended to transmit frame by IPG.
 	 */
@@ -2003,7 +1991,7 @@ static int ipg_nic_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	ipg_w32(IPG_DC_TX_DMA_POLL_NOW, DMA_CTRL);
 
 	if (sp->tx_current == (sp->tx_dirty + IPG_TFDLIST_LENGTH))
-		netif_wake_queue(dev);
+		netif_stop_queue(dev);
 
 	spin_unlock_irqrestore(&sp->lock, flags);
 
diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_cs.c
index 2881777..36a7ba3 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -187,14 +187,16 @@ enum Window1 {
 enum Window3 {			/* Window 3: MAC/config bits. */
 	Wn3_Config=0, Wn3_MAC_Ctrl=6, Wn3_Options=8,
 };
-union wn3_config {
-	int i;
-	struct w3_config_fields {
-		unsigned int ram_size:3, ram_width:1, ram_speed:2, rom_size:2;
-		int pad8:8;
-		unsigned int ram_split:2, pad18:2, xcvr:3, pad21:1, autoselect:1;
-		int pad24:7;
-	} u;
+enum wn3_config {
+	Ram_size = 7,
+	Ram_width = 8,
+	Ram_speed = 0x30,
+	Rom_size = 0xc0,
+	Ram_split_shift = 16,
+	Ram_split = 3 << Ram_split_shift,
+	Xcvr_shift = 20,
+	Xcvr = 7 << Xcvr_shift,
+	Autoselect = 0x1000000,
 };
 
 enum Window4 {		/* Window 4: Xcvr/media bits. */
@@ -342,7 +344,7 @@ static int tc574_config(struct pcmcia_device *link)
 	kio_addr_t ioaddr;
 	__be16 *phys_addr;
 	char *cardname;
-	union wn3_config config;
+	__u32 config;
 	DECLARE_MAC_BUF(mac);
 
 	phys_addr = (__be16 *)dev->dev_addr;
@@ -401,9 +403,9 @@ static int tc574_config(struct pcmcia_device *link)
 		outw(0<<11, ioaddr + RunnerRdCtrl);
 		printk(KERN_INFO "  ASIC rev %d,", mcr>>3);
 		EL3WINDOW(3);
-		config.i = inl(ioaddr + Wn3_Config);
-		lp->default_media = config.u.xcvr;
-		lp->autoselect = config.u.autoselect;
+		config = inl(ioaddr + Wn3_Config);
+		lp->default_media = (config & Xcvr) >> Xcvr_shift;
+		lp->autoselect = config & Autoselect ? 1 : 0;
 	}
 
 	init_timer(&lp->media);
@@ -464,8 +466,9 @@ static int tc574_config(struct pcmcia_device *link)
 	       dev->name, cardname, dev->base_addr, dev->irq,
 	       print_mac(mac, dev->dev_addr));
 	printk(" %dK FIFO split %s Rx:Tx, %sMII interface.\n",
-		   8 << config.u.ram_size, ram_split[config.u.ram_split],
-		   config.u.autoselect ? "autoselect " : "");
+		   8 << config & Ram_size,
+		   ram_split[(config & Ram_split) >> Ram_split_shift],
+		   config & Autoselect ? "autoselect " : "");
 
 	return 0;
 
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index fa57c49..f2ba944 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -84,7 +84,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.26.10"
+#define DRV_VERSION "2.0.26.17"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
@@ -3848,8 +3848,6 @@ static int s2io_open(struct net_device *dev)
 	netif_carrier_off(dev);
 	sp->last_link_state = 0;
 
-	napi_enable(&sp->napi);
-
 	if (sp->config.intr_type == MSI_X) {
 		int ret = s2io_enable_msi_x(sp);
 
@@ -3892,7 +3890,6 @@ static int s2io_open(struct net_device *dev)
 	return 0;
 
 hw_init_failed:
-	napi_disable(&sp->napi);
 	if (sp->config.intr_type == MSI_X) {
 		if (sp->entries) {
 			kfree(sp->entries);
@@ -3932,7 +3929,6 @@ static int s2io_close(struct net_device *dev)
 		return 0;
 
 	netif_stop_queue(dev);
-	napi_disable(&sp->napi);
 	/* Reset card, kill tasklet and free Tx and Rx buffers. */
 	s2io_card_down(sp);
 
@@ -6796,6 +6792,8 @@ static void do_s2io_card_down(struct s2io_nic * sp, int do_io)
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 	unsigned long flags;
 	register u64 val64 = 0;
+	struct config_param *config;
+	config = &sp->config;
 
 	if (!is_s2io_card_up(sp))
 		return;
@@ -6807,6 +6805,10 @@ static void do_s2io_card_down(struct s2io_nic * sp, int do_io)
 	}
 	clear_bit(__S2IO_STATE_CARD_UP, &sp->state);
 
+	/* Disable napi */
+	if (config->napi)
+		napi_disable(&sp->napi);
+
 	/* disable Tx and Rx traffic on the NIC */
 	if (do_io)
 		stop_nic(sp);
@@ -6900,6 +6902,11 @@ static int s2io_card_up(struct s2io_nic * sp)
 		DBG_PRINT(INFO_DBG, "Buf in ring:%d is %d:\n", i,
 			  atomic_read(&sp->rx_bufs_left[i]));
 	}
+
+	/* Initialise napi */
+	if (config->napi)
+		napi_enable(&sp->napi);
+
 	/* Maintain the state prior to the open */
 	if (sp->promisc_flg)
 		sp->promisc_flg = 0;
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 7023bbe..bc15940 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -3949,7 +3949,7 @@ static __exit void sky2_debug_cleanup(void)
 /* Initialize network device */
 static __devinit struct net_device *sky2_init_netdev(struct sky2_hw *hw,
 						     unsigned port,
-						     int highmem)
+						     int highmem, int wol)
 {
 	struct sky2_port *sky2;
 	struct net_device *dev = alloc_etherdev(sizeof(*sky2));
@@ -3989,7 +3989,7 @@ static __devinit struct net_device *sky2_init_netdev(struct sky2_hw *hw,
 	sky2->speed = -1;
 	sky2->advertising = sky2_supported_modes(hw);
 	sky2->rx_csum = (hw->chip_id != CHIP_ID_YUKON_XL);
-	sky2->wol = sky2_wol_supported(hw) & WAKE_MAGIC;
+	sky2->wol = wol;
 
 	spin_lock_init(&sky2->phy_lock);
 	sky2->tx_pending = TX_DEF_PENDING;
@@ -4086,12 +4086,24 @@ static int __devinit sky2_test_msi(struct sky2_hw *hw)
 	return err;
 }
 
+static int __devinit pci_wake_enabled(struct pci_dev *dev)
+{
+	int pm  = pci_find_capability(dev, PCI_CAP_ID_PM);
+	u16 value;
+
+	if (!pm)
+		return 0;
+	if (pci_read_config_word(dev, pm + PCI_PM_CTRL, &value))
+		return 0;
+	return value & PCI_PM_CTRL_PME_ENABLE;
+}
+
 static int __devinit sky2_probe(struct pci_dev *pdev,
 				const struct pci_device_id *ent)
 {
 	struct net_device *dev;
 	struct sky2_hw *hw;
-	int err, using_dac = 0;
+	int err, using_dac = 0, wol_default;
 
 	err = pci_enable_device(pdev);
 	if (err) {
@@ -4124,6 +4136,8 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 		}
 	}
 
+	wol_default = pci_wake_enabled(pdev) ? WAKE_MAGIC : 0;
+
 	err = -ENOMEM;
 	hw = kzalloc(sizeof(*hw), GFP_KERNEL);
 	if (!hw) {
@@ -4167,7 +4181,7 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 
 	sky2_reset(hw);
 
-	dev = sky2_init_netdev(hw, 0, using_dac);
+	dev = sky2_init_netdev(hw, 0, using_dac, wol_default);
 	if (!dev) {
 		err = -ENOMEM;
 		goto err_out_free_pci;
@@ -4204,7 +4218,7 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 	if (hw->ports > 1) {
 		struct net_device *dev1;
 
-		dev1 = sky2_init_netdev(hw, 1, using_dac);
+		dev1 = sky2_init_netdev(hw, 1, using_dac, wol_default);
 		if (!dev1)
 			dev_warn(&pdev->dev, "allocation for second device failed\n");
 		else if ((err = register_netdev(dev1))) {
diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index 33dc713..c6f26e2 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -139,19 +139,21 @@ struct thingie {
 };
 
 struct TxFD {
-	u32 state;
-	u32 next;
-	u32 data;
-	u32 complete;
+	__le32 state;
+	__le32 next;
+	__le32 data;
+	__le32 complete;
 	u32 jiffies; /* Allows sizeof(TxFD) == sizeof(RxFD) + extra hack */
+		     /* FWIW, datasheet calls that "dummy" and says that card
+		      * never looks at it; neither does the driver */
 };
 
 struct RxFD {
-	u32 state1;
-	u32 next;
-	u32 data;
-	u32 state2;
-	u32 end;
+	__le32 state1;
+	__le32 next;
+	__le32 data;
+	__le32 state2;
+	__le32 end;
 };
 
 #define DUMMY_SKB_SIZE		64
@@ -181,7 +183,7 @@ struct RxFD {
 #define SCC_REG_START(dpriv)	(SCC_START+(dpriv->dev_id)*SCC_OFFSET)
 
 struct dscc4_pci_priv {
-        u32 *iqcfg;
+        __le32 *iqcfg;
         int cfg_cur;
         spinlock_t lock;
         struct pci_dev *pdev;
@@ -197,8 +199,8 @@ struct dscc4_dev_priv {
 
         struct RxFD *rx_fd;
         struct TxFD *tx_fd;
-        u32 *iqrx;
-        u32 *iqtx;
+        __le32 *iqrx;
+        __le32 *iqtx;
 
 	/* FIXME: check all the volatile are required */
         volatile u32 tx_current;
@@ -298,7 +300,7 @@ struct dscc4_dev_priv {
 #define BrrExpMask	0x00000f00
 #define BrrMultMask	0x0000003f
 #define EncodingMask	0x00700000
-#define Hold		0x40000000
+#define Hold		cpu_to_le32(0x40000000)
 #define SccBusy		0x10000000
 #define PowerUp		0x80000000
 #define Vis		0x00001000
@@ -307,14 +309,14 @@ struct dscc4_dev_priv {
 #define FrameRdo	0x40
 #define FrameCrc	0x20
 #define FrameRab	0x10
-#define FrameAborted	0x00000200
-#define FrameEnd	0x80000000
-#define DataComplete	0x40000000
+#define FrameAborted	cpu_to_le32(0x00000200)
+#define FrameEnd	cpu_to_le32(0x80000000)
+#define DataComplete	cpu_to_le32(0x40000000)
 #define LengthCheck	0x00008000
 #define SccEvt		0x02000000
 #define NoAck		0x00000200
 #define Action		0x00000001
-#define HiDesc		0x20000000
+#define HiDesc		cpu_to_le32(0x20000000)
 
 /* SCC events */
 #define RxEvt		0xf0000000
@@ -489,8 +491,8 @@ static void dscc4_release_ring(struct dscc4_dev_priv *dpriv)
 	skbuff = dpriv->tx_skbuff;
 	for (i = 0; i < TX_RING_SIZE; i++) {
 		if (*skbuff) {
-			pci_unmap_single(pdev, tx_fd->data, (*skbuff)->len,
-				PCI_DMA_TODEVICE);
+			pci_unmap_single(pdev, le32_to_cpu(tx_fd->data),
+				(*skbuff)->len, PCI_DMA_TODEVICE);
 			dev_kfree_skb(*skbuff);
 		}
 		skbuff++;
@@ -500,7 +502,7 @@ static void dscc4_release_ring(struct dscc4_dev_priv *dpriv)
 	skbuff = dpriv->rx_skbuff;
 	for (i = 0; i < RX_RING_SIZE; i++) {
 		if (*skbuff) {
-			pci_unmap_single(pdev, rx_fd->data,
+			pci_unmap_single(pdev, le32_to_cpu(rx_fd->data),
 				RX_MAX(HDLC_MAX_MRU), PCI_DMA_FROMDEVICE);
 			dev_kfree_skb(*skbuff);
 		}
@@ -522,10 +524,10 @@ static inline int try_get_rx_skb(struct dscc4_dev_priv *dpriv,
 	dpriv->rx_skbuff[dirty] = skb;
 	if (skb) {
 		skb->protocol = hdlc_type_trans(skb, dev);
-		rx_fd->data = pci_map_single(dpriv->pci_priv->pdev, skb->data,
-					     len, PCI_DMA_FROMDEVICE);
+		rx_fd->data = cpu_to_le32(pci_map_single(dpriv->pci_priv->pdev,
+					  skb->data, len, PCI_DMA_FROMDEVICE));
 	} else {
-		rx_fd->data = (u32) NULL;
+		rx_fd->data = 0;
 		ret = -1;
 	}
 	return ret;
@@ -587,7 +589,7 @@ static inline int dscc4_xpr_ack(struct dscc4_dev_priv *dpriv)
 
 	do {
 		if (!(dpriv->flags & (NeedIDR | NeedIDT)) ||
-		    (dpriv->iqtx[cur] & Xpr))
+		    (dpriv->iqtx[cur] & cpu_to_le32(Xpr)))
 			break;
 		smp_rmb();
 		schedule_timeout_uninterruptible(10);
@@ -650,8 +652,9 @@ static inline void dscc4_rx_skb(struct dscc4_dev_priv *dpriv,
 		printk(KERN_DEBUG "%s: skb=0 (%s)\n", dev->name, __FUNCTION__);
 		goto refill;
 	}
-	pkt_len = TO_SIZE(rx_fd->state2);
-	pci_unmap_single(pdev, rx_fd->data, RX_MAX(HDLC_MAX_MRU), PCI_DMA_FROMDEVICE);
+	pkt_len = TO_SIZE(le32_to_cpu(rx_fd->state2));
+	pci_unmap_single(pdev, le32_to_cpu(rx_fd->data),
+			 RX_MAX(HDLC_MAX_MRU), PCI_DMA_FROMDEVICE);
 	if ((skb->data[--pkt_len] & FrameOk) == FrameOk) {
 		stats->rx_packets++;
 		stats->rx_bytes += pkt_len;
@@ -679,7 +682,7 @@ refill:
 	}
 	dscc4_rx_update(dpriv, dev);
 	rx_fd->state2 = 0x00000000;
-	rx_fd->end = 0xbabeface;
+	rx_fd->end = cpu_to_le32(0xbabeface);
 }
 
 static void dscc4_free1(struct pci_dev *pdev)
@@ -772,8 +775,8 @@ static int __devinit dscc4_init_one(struct pci_dev *pdev,
 	}
 	/* Global interrupt queue */
 	writel((u32)(((IRQ_RING_SIZE >> 5) - 1) << 20), ioaddr + IQLENR1);
-	priv->iqcfg = (u32 *) pci_alloc_consistent(pdev,
-		IRQ_RING_SIZE*sizeof(u32), &priv->iqcfg_dma);
+	priv->iqcfg = (__le32 *) pci_alloc_consistent(pdev,
+		IRQ_RING_SIZE*sizeof(__le32), &priv->iqcfg_dma);
 	if (!priv->iqcfg)
 		goto err_free_irq_5;
 	writel(priv->iqcfg_dma, ioaddr + IQCFG);
@@ -786,7 +789,7 @@ static int __devinit dscc4_init_one(struct pci_dev *pdev,
 	 */
 	for (i = 0; i < dev_per_card; i++) {
 		dpriv = priv->root + i;
-		dpriv->iqtx = (u32 *) pci_alloc_consistent(pdev,
+		dpriv->iqtx = (__le32 *) pci_alloc_consistent(pdev,
 			IRQ_RING_SIZE*sizeof(u32), &dpriv->iqtx_dma);
 		if (!dpriv->iqtx)
 			goto err_free_iqtx_6;
@@ -794,7 +797,7 @@ static int __devinit dscc4_init_one(struct pci_dev *pdev,
 	}
 	for (i = 0; i < dev_per_card; i++) {
 		dpriv = priv->root + i;
-		dpriv->iqrx = (u32 *) pci_alloc_consistent(pdev,
+		dpriv->iqrx = (__le32 *) pci_alloc_consistent(pdev,
 			IRQ_RING_SIZE*sizeof(u32), &dpriv->iqrx_dma);
 		if (!dpriv->iqrx)
 			goto err_free_iqrx_7;
@@ -1156,8 +1159,8 @@ static int dscc4_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	dpriv->tx_skbuff[next] = skb;
 	tx_fd = dpriv->tx_fd + next;
 	tx_fd->state = FrameEnd | TO_STATE_TX(skb->len);
-	tx_fd->data = pci_map_single(ppriv->pdev, skb->data, skb->len,
-				     PCI_DMA_TODEVICE);
+	tx_fd->data = cpu_to_le32(pci_map_single(ppriv->pdev, skb->data, skb->len,
+				     PCI_DMA_TODEVICE));
 	tx_fd->complete = 0x00000000;
 	tx_fd->jiffies = jiffies;
 	mb();
@@ -1508,7 +1511,7 @@ static irqreturn_t dscc4_irq(int irq, void *token)
 	if (state & Cfg) {
 		if (debug > 0)
 			printk(KERN_DEBUG "%s: CfgIV\n", DRV_NAME);
-		if (priv->iqcfg[priv->cfg_cur++%IRQ_RING_SIZE] & Arf)
+		if (priv->iqcfg[priv->cfg_cur++%IRQ_RING_SIZE] & cpu_to_le32(Arf))
 			printk(KERN_ERR "%s: %s failed\n", dev->name, "CFG");
 		if (!(state &= ~Cfg))
 			goto out;
@@ -1541,7 +1544,7 @@ static void dscc4_tx_irq(struct dscc4_pci_priv *ppriv,
 
 try:
 	cur = dpriv->iqtx_current%IRQ_RING_SIZE;
-	state = dpriv->iqtx[cur];
+	state = le32_to_cpu(dpriv->iqtx[cur]);
 	if (!state) {
 		if (debug > 4)
 			printk(KERN_DEBUG "%s: Tx ISR = 0x%08x\n", dev->name,
@@ -1580,7 +1583,7 @@ try:
 			tx_fd = dpriv->tx_fd + cur;
 			skb = dpriv->tx_skbuff[cur];
 			if (skb) {
-				pci_unmap_single(ppriv->pdev, tx_fd->data,
+				pci_unmap_single(ppriv->pdev, le32_to_cpu(tx_fd->data),
 						 skb->len, PCI_DMA_TODEVICE);
 				if (tx_fd->state & FrameEnd) {
 					stats->tx_packets++;
@@ -1711,7 +1714,7 @@ static void dscc4_rx_irq(struct dscc4_pci_priv *priv,
 
 try:
 	cur = dpriv->iqrx_current%IRQ_RING_SIZE;
-	state = dpriv->iqrx[cur];
+	state = le32_to_cpu(dpriv->iqrx[cur]);
 	if (!state)
 		return;
 	dpriv->iqrx[cur] = 0;
@@ -1755,7 +1758,7 @@ try:
 					goto try;
 				rx_fd->state1 &= ~Hold;
 				rx_fd->state2 = 0x00000000;
-				rx_fd->end = 0xbabeface;
+				rx_fd->end = cpu_to_le32(0xbabeface);
 			//}
 			goto try;
 		}
@@ -1834,7 +1837,7 @@ try:
 					hdlc_stats(dev)->rx_over_errors++;
 					rx_fd->state1 |= Hold;
 					rx_fd->state2 = 0x00000000;
-					rx_fd->end = 0xbabeface;
+					rx_fd->end = cpu_to_le32(0xbabeface);
 				} else
 					dscc4_rx_skb(dpriv, dev);
 			} while (1);
@@ -1904,8 +1907,9 @@ static struct sk_buff *dscc4_init_dummy_skb(struct dscc4_dev_priv *dpriv)
 		skb_copy_to_linear_data(skb, version,
 					strlen(version) % DUMMY_SKB_SIZE);
 		tx_fd->state = FrameEnd | TO_STATE_TX(DUMMY_SKB_SIZE);
-		tx_fd->data = pci_map_single(dpriv->pci_priv->pdev, skb->data,
-					     DUMMY_SKB_SIZE, PCI_DMA_TODEVICE);
+		tx_fd->data = cpu_to_le32(pci_map_single(dpriv->pci_priv->pdev,
+					     skb->data, DUMMY_SKB_SIZE,
+					     PCI_DMA_TODEVICE));
 		dpriv->tx_skbuff[last] = skb;
 	}
 	return skb;
@@ -1937,8 +1941,8 @@ static int dscc4_init_ring(struct net_device *dev)
 		tx_fd->state = FrameEnd | TO_STATE_TX(2*DUMMY_SKB_SIZE);
 		tx_fd->complete = 0x00000000;
 	        /* FIXME: NULL should be ok - to be tried */
-	        tx_fd->data = dpriv->tx_fd_dma;
-		(tx_fd++)->next = (u32)(dpriv->tx_fd_dma +
+	        tx_fd->data = cpu_to_le32(dpriv->tx_fd_dma);
+		(tx_fd++)->next = cpu_to_le32(dpriv->tx_fd_dma +
 					(++i%TX_RING_SIZE)*sizeof(*tx_fd));
 	} while (i < TX_RING_SIZE);
 
@@ -1951,12 +1955,12 @@ static int dscc4_init_ring(struct net_device *dev)
 		/* size set by the host. Multiple of 4 bytes please */
 	        rx_fd->state1 = HiDesc;
 	        rx_fd->state2 = 0x00000000;
-	        rx_fd->end = 0xbabeface;
+	        rx_fd->end = cpu_to_le32(0xbabeface);
 	        rx_fd->state1 |= TO_STATE_RX(HDLC_MAX_MRU);
 		// FIXME: return value verifiee mais traitement suspect
 		if (try_get_rx_skb(dpriv, dev) >= 0)
 			dpriv->rx_dirty++;
-		(rx_fd++)->next = (u32)(dpriv->rx_fd_dma +
+		(rx_fd++)->next = cpu_to_le32(dpriv->rx_fd_dma +
 					(++i%RX_RING_SIZE)*sizeof(*rx_fd));
 	} while (i < RX_RING_SIZE);
 
diff --git a/drivers/net/wan/lmc/lmc_media.c b/drivers/net/wan/lmc/lmc_media.c
index 574737b..c9c878c 100644
--- a/drivers/net/wan/lmc/lmc_media.c
+++ b/drivers/net/wan/lmc/lmc_media.c
@@ -890,16 +890,8 @@ write_av9110 (lmc_softc_t * sc, u_int32_t n, u_int32_t m, u_int32_t v,
 static void
 lmc_ssi_watchdog (lmc_softc_t * const sc)
 {
-  u_int16_t mii17;
-  struct ssicsr2
-  {
-    unsigned short dtr:1, dsr:1, rts:1, cable:3, crc:1, led0:1, led1:1,
-      led2:1, led3:1, fifo:1, ll:1, rl:1, tm:1, loop:1;
-  };
-  struct ssicsr2 *ssicsr;
-  mii17 = lmc_mii_readreg (sc, 0, 17);
-  ssicsr = (struct ssicsr2 *) &mii17;
-  if (ssicsr->cable == 7)
+  u_int16_t mii17 = lmc_mii_readreg (sc, 0, 17);
+  if (((mii17 >> 3) & 7) == 7)
     {
       lmc_led_off (sc, LMC_MII16_LED2);
     }
diff --git a/drivers/net/wan/sbni.h b/drivers/net/wan/sbni.h
index 27715e7..8426451 100644
--- a/drivers/net/wan/sbni.h
+++ b/drivers/net/wan/sbni.h
@@ -44,9 +44,15 @@ enum {
 #define PR_RES 0x80
 
 struct sbni_csr1 {
-	unsigned rxl	: 5;
-	unsigned rate	: 2;
-	unsigned 	: 1;
+#ifdef __LITTLE_ENDIAN_BITFIELD
+	u8 rxl	: 5;
+	u8 rate	: 2;
+	u8 	: 1;
+#else
+	u8 	: 1;
+	u8 rate	: 2;
+	u8 rxl	: 5;
+#endif
 };
 
 /* fields in frame header */
diff --git a/drivers/net/wireless/b43/rfkill.c b/drivers/net/wireless/b43/rfkill.c
index 98cf70c..11f53cb 100644
--- a/drivers/net/wireless/b43/rfkill.c
+++ b/drivers/net/wireless/b43/rfkill.c
@@ -138,8 +138,11 @@ void b43_rfkill_init(struct b43_wldev *dev)
 	rfk->rfkill->user_claim_unsupported = 1;
 
 	rfk->poll_dev = input_allocate_polled_device();
-	if (!rfk->poll_dev)
-		goto err_free_rfk;
+	if (!rfk->poll_dev) {
+		rfkill_free(rfk->rfkill);
+		goto err_freed_rfk;
+	}
+
 	rfk->poll_dev->private = dev;
 	rfk->poll_dev->poll = b43_rfkill_poll;
 	rfk->poll_dev->poll_interval = 1000; /* msecs */
@@ -175,8 +178,7 @@ err_unreg_rfk:
 err_free_polldev:
 	input_free_polled_device(rfk->poll_dev);
 	rfk->poll_dev = NULL;
-err_free_rfk:
-	rfkill_free(rfk->rfkill);
+err_freed_rfk:
 	rfk->rfkill = NULL;
 out_error:
 	rfk->registered = 0;
@@ -195,6 +197,5 @@ void b43_rfkill_exit(struct b43_wldev *dev)
 	rfkill_unregister(rfk->rfkill);
 	input_free_polled_device(rfk->poll_dev);
 	rfk->poll_dev = NULL;
-	rfkill_free(rfk->rfkill);
 	rfk->rfkill = NULL;
 }
diff --git a/drivers/net/wireless/hostap/hostap_plx.c b/drivers/net/wireless/hostap/hostap_plx.c
index 040dc3e..cbf15d7 100644
--- a/drivers/net/wireless/hostap/hostap_plx.c
+++ b/drivers/net/wireless/hostap/hostap_plx.c
@@ -608,7 +608,7 @@ static void prism2_plx_remove(struct pci_dev *pdev)
 
 MODULE_DEVICE_TABLE(pci, prism2_plx_id_table);
 
-static struct pci_driver prism2_plx_drv_id = {
+static struct pci_driver prism2_plx_driver = {
 	.name		= "hostap_plx",
 	.id_table	= prism2_plx_id_table,
 	.probe		= prism2_plx_probe,
@@ -618,13 +618,13 @@ static struct pci_driver prism2_plx_drv_id = {
 
 static int __init init_prism2_plx(void)
 {
-	return pci_register_driver(&prism2_plx_drv_id);
+	return pci_register_driver(&prism2_plx_driver);
 }
 
 
 static void __exit exit_prism2_plx(void)
 {
-	pci_unregister_driver(&prism2_plx_drv_id);
+	pci_unregister_driver(&prism2_plx_driver);
 }
 
 
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 88062c1..003f73f 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -4935,7 +4935,7 @@ static int ipw_queue_reset(struct ipw_priv *priv)
 /**
  * Reclaim Tx queue entries no more used by NIC.
  *
- * When FW adwances 'R' index, all entries between old and
+ * When FW advances 'R' index, all entries between old and
  * new 'R' index need to be reclaimed. As result, some free space
  * forms. If there is enough free space (> low mark), wake Tx queue.
  *
diff --git a/drivers/net/wireless/libertas/if_sdio.c b/drivers/net/wireless/libertas/if_sdio.c
index b24425f..4f1efb1 100644
--- a/drivers/net/wireless/libertas/if_sdio.c
+++ b/drivers/net/wireless/libertas/if_sdio.c
@@ -871,6 +871,10 @@ static int if_sdio_probe(struct sdio_func *func,
 		if (sscanf(func->card->info[i],
 				"ID: %x", &model) == 1)
 			break;
+               if (!strcmp(func->card->info[i], "IBIS Wireless SDIO Card")) {
+                       model = 4;
+                       break;
+               }
 	}
 
 	if (i == func->card->num_info) {
diff --git a/drivers/net/wireless/rt2x00/rt2x00pci.c b/drivers/net/wireless/rt2x00/rt2x00pci.c
index 6d5d9ab..04663eb 100644
--- a/drivers/net/wireless/rt2x00/rt2x00pci.c
+++ b/drivers/net/wireless/rt2x00/rt2x00pci.c
@@ -149,7 +149,7 @@ void rt2x00pci_rxdone(struct rt2x00_dev *rt2x00dev)
 		 * The data behind the ieee80211 header must be
 		 * aligned on a 4 byte boundary.
 		 */
-		align = NET_IP_ALIGN + (2 * (header_size % 4 == 0));
+		align = header_size % 4;
 
 		/*
 		 * Allocate the sk_buffer, initialize it and copy
diff --git a/drivers/net/wireless/rt2x00/rt2x00usb.c b/drivers/net/wireless/rt2x00/rt2x00usb.c
index ab4797e..568d738 100644
--- a/drivers/net/wireless/rt2x00/rt2x00usb.c
+++ b/drivers/net/wireless/rt2x00/rt2x00usb.c
@@ -245,13 +245,20 @@ static void rt2x00usb_interrupt_rxdone(struct urb *urb)
 	 * Allocate a new sk buffer to replace the current one.
 	 * If allocation fails, we should drop the current frame
 	 * so we can recycle the existing sk buffer for the new frame.
+	 * As alignment we use 2 and not NET_IP_ALIGN because we need
+	 * to be sure we have 2 bytes room in the head. (NET_IP_ALIGN
+	 * can be 0 on some hardware). We use these 2 bytes for frame
+	 * alignment later, we assume that the chance that
+	 * header_size % 4 == 2 is bigger then header_size % 2 == 0
+	 * and thus optimize alignment by reserving the 2 bytes in
+	 * advance.
 	 */
 	frame_size = entry->ring->data_size + entry->ring->desc_size;
-	skb = dev_alloc_skb(frame_size + NET_IP_ALIGN);
+	skb = dev_alloc_skb(frame_size + 2);
 	if (!skb)
 		goto skip_entry;
 
-	skb_reserve(skb, NET_IP_ALIGN);
+	skb_reserve(skb, 2);
 	skb_put(skb, frame_size);
 
 	/*
