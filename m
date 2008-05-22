From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates for .27
Date: Thu, 22 May 2008 15:10:49 -0400
Message-ID: <20080522191049.GA29882@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:44035 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755471AbYEVTKu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 15:10:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Please pull from 'upstream-next-davem' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-next-davem

to receive the following updates:

 Documentation/networking/bonding.txt   |   96 +++--
 drivers/net/3c509.c                    |   15 +-
 drivers/net/3c515.c                    |    4 +
 drivers/net/Kconfig                    |    1 +
 drivers/net/atlx/atl1.c                |    5 +-
 drivers/net/bonding/bond_main.c        |  706 +++++++++++++++++++-------------
 drivers/net/bonding/bond_sysfs.c       |   81 +++-
 drivers/net/bonding/bonding.h          |   13 +-
 drivers/net/cxgb3/adapter.h            |   18 +
 drivers/net/cxgb3/common.h             |    1 +
 drivers/net/cxgb3/cxgb3_ioctl.h        |    1 +
 drivers/net/cxgb3/cxgb3_main.c         |   19 +
 drivers/net/cxgb3/sge.c                |  391 +++++++++++++++---
 drivers/net/cxgb3/t3_cpl.h             |   11 +
 drivers/net/dl2k.c                     |    8 +-
 drivers/net/hamachi.c                  |   12 +-
 drivers/net/ixp2000/ixpdev.c           |    4 +-
 drivers/net/phy/Kconfig                |    3 +-
 drivers/net/phy/broadcom.c             |  201 +++++++++-
 drivers/net/sb1250-mac.c               |   67 ++--
 drivers/net/tg3.c                      |   32 +-
 drivers/net/usb/catc.c                 |    5 +-
 drivers/net/usb/rndis_host.c           |    4 +-
 drivers/net/via-velocity.c             |   25 +-
 drivers/net/wireless/zd1211rw/zd_mac.c |    2 +-
 drivers/net/wireless/zd1211rw/zd_usb.c |    2 +-
 26 files changed, 1234 insertions(+), 493 deletions(-)

Al Viro (1):
      misc drivers/net endianness noise

Divy Le Ray (3):
      cxgb3 - Fix dma mapping error path
      cxgb3 - Add page support to jumbo frame Rx queue
      cxgb3 - Add LRO support

Jay Vosburgh (4):
      bonding: Use msecs_to_jiffies, eliminate panic
      bonding: remove test for IP in ARP monitor
      bonding: refactor ARP active-backup monitor
      bonding: Add "follow" option to fail_over_mac

Maciej W. Rozycki (2):
      PHYLIB: Kconfig: Complete the list of Broadcom PHYs supported
      sb1250: use netdev_alloc_skb

Moni Shoua (1):
      bonding: Send more than one gratuitous ARP when slave takes over

Nate Case (1):
      PHYLIB: Add 1000Base-X support for Broadcom bcm5482

Pavel Emelyanov (3):
      bonding: Remove redundant argument from bond_create.
      bonding: Relax unneeded _safe lists iterations.
      bonding: Remove unneeded list_empty checks.

Randy Dunlap (1):
      3c515: fix using pnp_get_resource when CONFIG_ISAPNP=n

Stephen Hemminger (7):
      tg3: remove unneeded semicolons
      atl1: use netdev_alloc_skb
      ixp2000: use netdev_alloc_skb
      hamachi: use netdev_alloc_skb
      dl2k: use netdev_alloc_skb
      via-velocity: use netdev_alloc_skb
      via-velocity: use memmove

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index a0cda06..8e6b8d3 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -289,35 +289,73 @@ downdelay
 fail_over_mac
 
 	Specifies whether active-backup mode should set all slaves to
-	the same MAC address (the traditional behavior), or, when
-	enabled, change the bond's MAC address when changing the
-	active interface (i.e., fail over the MAC address itself).
-
-	Fail over MAC is useful for devices that cannot ever alter
-	their MAC address, or for devices that refuse incoming
-	broadcasts with their own source MAC (which interferes with
-	the ARP monitor).
-
-	The down side of fail over MAC is that every device on the
-	network must be updated via gratuitous ARP, vs. just updating
-	a switch or set of switches (which often takes place for any
-	traffic, not just ARP traffic, if the switch snoops incoming
-	traffic to update its tables) for the traditional method.  If
-	the gratuitous ARP is lost, communication may be disrupted.
-
-	When fail over MAC is used in conjuction with the mii monitor,
-	devices which assert link up prior to being able to actually
-	transmit and receive are particularly susecptible to loss of
-	the gratuitous ARP, and an appropriate updelay setting may be
-	required.
-
-	A value of 0 disables fail over MAC, and is the default.  A
-	value of 1 enables fail over MAC.  This option is enabled
-	automatically if the first slave added cannot change its MAC
-	address.  This option may be modified via sysfs only when no
-	slaves are present in the bond.
-
-	This option was added in bonding version 3.2.0.
+	the same MAC address at enslavement (the traditional
+	behavior), or, when enabled, perform special handling of the
+	bond's MAC address in accordance with the selected policy.
+
+	Possible values are:
+
+	none or 0
+
+		This setting disables fail_over_mac, and causes
+		bonding to set all slaves of an active-backup bond to
+		the same MAC address at enslavement time.  This is the
+		default.
+
+	active or 1
+
+		The "active" fail_over_mac policy indicates that the
+		MAC address of the bond should always be the MAC
+		address of the currently active slave.  The MAC
+		address of the slaves is not changed; instead, the MAC
+		address of the bond changes during a failover.
+
+		This policy is useful for devices that cannot ever
+		alter their MAC address, or for devices that refuse
+		incoming broadcasts with their own source MAC (which
+		interferes with the ARP monitor).
+
+		The down side of this policy is that every device on
+		the network must be updated via gratuitous ARP,
+		vs. just updating a switch or set of switches (which
+		often takes place for any traffic, not just ARP
+		traffic, if the switch snoops incoming traffic to
+		update its tables) for the traditional method.  If the
+		gratuitous ARP is lost, communication may be
+		disrupted.
+
+		When this policy is used in conjuction with the mii
+		monitor, devices which assert link up prior to being
+		able to actually transmit and receive are particularly
+		susecptible to loss of the gratuitous ARP, and an
+		appropriate updelay setting may be required.
+
+	follow or 2
+
+		The "follow" fail_over_mac policy causes the MAC
+		address of the bond to be selected normally (normally
+		the MAC address of the first slave added to the bond).
+		However, the second and subsequent slaves are not set
+		to this MAC address while they are in a backup role; a
+		slave is programmed with the bond's MAC address at
+		failover time (and the formerly active slave receives
+		the newly active slave's MAC address).
+
+		This policy is useful for multiport devices that
+		either become confused or incur a performance penalty
+		when multiple ports are programmed with the same MAC
+		address.
+
+
+	The default policy is none, unless the first slave cannot
+	change its MAC address, in which case the active policy is
+	selected by default.
+
+	This option may be modified via sysfs only when no slaves are
+	present in the bond.
+
+	This option was added in bonding version 3.2.0.  The "follow"
+	policy was added in bonding version 3.3.0.
 
 lacp_rate
 
diff --git a/drivers/net/3c509.c b/drivers/net/3c509.c
index e6c545f..87d8795 100644
--- a/drivers/net/3c509.c
+++ b/drivers/net/3c509.c
@@ -413,7 +413,7 @@ static int __devinit el3_pnp_probe(struct pnp_dev *pdev,
 {
 	short i;
 	int ioaddr, irq, if_port;
-	u16 phys_addr[3];
+	__be16 phys_addr[3];
 	struct net_device *dev = NULL;
 	int err;
 
@@ -605,7 +605,7 @@ static int __init el3_mca_probe(struct device *device)
 
 	short i;
 	int ioaddr, irq, if_port;
-	u16 phys_addr[3];
+	__be16 phys_addr[3];
 	struct net_device *dev = NULL;
 	u_char pos4, pos5;
 	struct mca_device *mdev = to_mca_device(device);
@@ -635,14 +635,13 @@ static int __init el3_mca_probe(struct device *device)
 			printk(KERN_DEBUG "3c529: irq %d  ioaddr 0x%x  ifport %d\n", irq, ioaddr, if_port);
 	}
 	EL3WINDOW(0);
-	for (i = 0; i < 3; i++) {
-			phys_addr[i] = htons(read_eeprom(ioaddr, i));
-	}
+	for (i = 0; i < 3; i++)
+		phys_addr[i] = htons(read_eeprom(ioaddr, i));
 
 	dev = alloc_etherdev(sizeof (struct el3_private));
 	if (dev == NULL) {
-			release_region(ioaddr, EL3_IO_EXTENT);
-			return -ENOMEM;
+		release_region(ioaddr, EL3_IO_EXTENT);
+		return -ENOMEM;
 	}
 
 	netdev_boot_setup_check(dev);
@@ -668,7 +667,7 @@ static int __init el3_eisa_probe (struct device *device)
 {
 	short i;
 	int ioaddr, irq, if_port;
-	u16 phys_addr[3];
+	__be16 phys_addr[3];
 	struct net_device *dev = NULL;
 	struct eisa_device *edev;
 	int err;
diff --git a/drivers/net/3c515.c b/drivers/net/3c515.c
index 105a8c7..e4e3241 100644
--- a/drivers/net/3c515.c
+++ b/drivers/net/3c515.c
@@ -572,12 +572,16 @@ static int corkscrew_setup(struct net_device *dev, int ioaddr,
 	int irq;
 	DECLARE_MAC_BUF(mac);
 
+#ifdef __ISAPNP__
 	if (idev) {
 		irq = pnp_irq(idev, 0);
 		vp->dev = &idev->dev;
 	} else {
 		irq = inw(ioaddr + 0x2002) & 15;
 	}
+#else
+	irq = inw(ioaddr + 0x2002) & 15;
+#endif
 
 	dev->base_addr = ioaddr;
 	dev->irq = irq;
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 9f6cc8a..daeb23d 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2409,6 +2409,7 @@ config CHELSIO_T3
 	tristate "Chelsio Communications T3 10Gb Ethernet support"
 	depends on PCI
 	select FW_LOADER
+	select INET_LRO
 	help
 	  This driver supports Chelsio T3-based gigabit and 10Gb Ethernet
 	  adapters.
diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 9c2394d..db04bfb 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -1876,7 +1876,8 @@ static u16 atl1_alloc_rx_buffers(struct atl1_adapter *adapter)
 
 		rfd_desc = ATL1_RFD_DESC(rfd_ring, rfd_next_to_use);
 
-		skb = dev_alloc_skb(adapter->rx_buffer_len + NET_IP_ALIGN);
+		skb = netdev_alloc_skb(adapter->netdev,
+				       adapter->rx_buffer_len + NET_IP_ALIGN);
 		if (unlikely(!skb)) {
 			/* Better luck next round */
 			adapter->net_stats.rx_dropped++;
@@ -2135,7 +2136,7 @@ static int atl1_tso(struct atl1_adapter *adapter, struct sk_buff *skb,
 				return -1;
 		}
 
-		if (skb->protocol == ntohs(ETH_P_IP)) {
+		if (skb->protocol == htons(ETH_P_IP)) {
 			struct iphdr *iph = ip_hdr(skb);
 
 			real_len = (((unsigned char *)iph - skb->data) +
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 50a40e4..5b4af3c 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -88,6 +88,7 @@
 #define BOND_LINK_ARP_INTERV	0
 
 static int max_bonds	= BOND_DEFAULT_MAX_BONDS;
+static int num_grat_arp = 1;
 static int miimon	= BOND_LINK_MON_INTERV;
 static int updelay	= 0;
 static int downdelay	= 0;
@@ -99,11 +100,13 @@ static char *xmit_hash_policy = NULL;
 static int arp_interval = BOND_LINK_ARP_INTERV;
 static char *arp_ip_target[BOND_MAX_ARP_TARGETS] = { NULL, };
 static char *arp_validate = NULL;
-static int fail_over_mac = 0;
+static char *fail_over_mac = NULL;
 struct bond_params bonding_defaults;
 
 module_param(max_bonds, int, 0);
 MODULE_PARM_DESC(max_bonds, "Max number of bonded devices");
+module_param(num_grat_arp, int, 0644);
+MODULE_PARM_DESC(num_grat_arp, "Number of gratuitous ARP packets to send on failover event");
 module_param(miimon, int, 0);
 MODULE_PARM_DESC(miimon, "Link check interval in milliseconds");
 module_param(updelay, int, 0);
@@ -133,8 +136,8 @@ module_param_array(arp_ip_target, charp, NULL, 0);
 MODULE_PARM_DESC(arp_ip_target, "arp targets in n.n.n.n form");
 module_param(arp_validate, charp, 0);
 MODULE_PARM_DESC(arp_validate, "validate src/dst of ARP probes: none (default), active, backup or all");
-module_param(fail_over_mac, int, 0);
-MODULE_PARM_DESC(fail_over_mac, "For active-backup, do not set all slaves to the same MAC.  0 of off (default), 1 for on.");
+module_param(fail_over_mac, charp, 0);
+MODULE_PARM_DESC(fail_over_mac, "For active-backup, do not set all slaves to the same MAC.  none (default), active or follow");
 
 /*----------------------------- Global variables ----------------------------*/
 
@@ -187,6 +190,13 @@ struct bond_parm_tbl arp_validate_tbl[] = {
 {	NULL,			-1},
 };
 
+struct bond_parm_tbl fail_over_mac_tbl[] = {
+{	"none",			BOND_FOM_NONE},
+{	"active",		BOND_FOM_ACTIVE},
+{	"follow",		BOND_FOM_FOLLOW},
+{	NULL,			-1},
+};
+
 /*-------------------------- Forward declarations ---------------------------*/
 
 static void bond_send_gratuitous_arp(struct bonding *bond);
@@ -261,14 +271,14 @@ static int bond_add_vlan(struct bonding *bond, unsigned short vlan_id)
  */
 static int bond_del_vlan(struct bonding *bond, unsigned short vlan_id)
 {
-	struct vlan_entry *vlan, *next;
+	struct vlan_entry *vlan;
 	int res = -ENODEV;
 
 	dprintk("bond: %s, vlan id %d\n", bond->dev->name, vlan_id);
 
 	write_lock_bh(&bond->lock);
 
-	list_for_each_entry_safe(vlan, next, &bond->vlan_list, vlan_list) {
+	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
 		if (vlan->vlan_id == vlan_id) {
 			list_del(&vlan->vlan_list);
 
@@ -970,6 +980,82 @@ static void bond_mc_swap(struct bonding *bond, struct slave *new_active, struct
 	}
 }
 
+/*
+ * bond_do_fail_over_mac
+ *
+ * Perform special MAC address swapping for fail_over_mac settings
+ *
+ * Called with RTNL, bond->lock for read, curr_slave_lock for write_bh.
+ */
+static void bond_do_fail_over_mac(struct bonding *bond,
+				  struct slave *new_active,
+				  struct slave *old_active)
+{
+	u8 tmp_mac[ETH_ALEN];
+	struct sockaddr saddr;
+	int rv;
+
+	switch (bond->params.fail_over_mac) {
+	case BOND_FOM_ACTIVE:
+		if (new_active)
+			memcpy(bond->dev->dev_addr,  new_active->dev->dev_addr,
+			       new_active->dev->addr_len);
+		break;
+	case BOND_FOM_FOLLOW:
+		/*
+		 * if new_active && old_active, swap them
+		 * if just old_active, do nothing (going to no active slave)
+		 * if just new_active, set new_active to bond's MAC
+		 */
+		if (!new_active)
+			return;
+
+		write_unlock_bh(&bond->curr_slave_lock);
+		read_unlock(&bond->lock);
+
+		if (old_active) {
+			memcpy(tmp_mac, new_active->dev->dev_addr, ETH_ALEN);
+			memcpy(saddr.sa_data, old_active->dev->dev_addr,
+			       ETH_ALEN);
+			saddr.sa_family = new_active->dev->type;
+		} else {
+			memcpy(saddr.sa_data, bond->dev->dev_addr, ETH_ALEN);
+			saddr.sa_family = bond->dev->type;
+		}
+
+		rv = dev_set_mac_address(new_active->dev, &saddr);
+		if (rv) {
+			printk(KERN_ERR DRV_NAME
+			       ": %s: Error %d setting MAC of slave %s\n",
+			       bond->dev->name, -rv, new_active->dev->name);
+			goto out;
+		}
+
+		if (!old_active)
+			goto out;
+
+		memcpy(saddr.sa_data, tmp_mac, ETH_ALEN);
+		saddr.sa_family = old_active->dev->type;
+
+		rv = dev_set_mac_address(old_active->dev, &saddr);
+		if (rv)
+			printk(KERN_ERR DRV_NAME
+			       ": %s: Error %d setting MAC of slave %s\n",
+			       bond->dev->name, -rv, new_active->dev->name);
+out:
+		read_lock(&bond->lock);
+		write_lock_bh(&bond->curr_slave_lock);
+		break;
+	default:
+		printk(KERN_ERR DRV_NAME
+		       ": %s: bond_do_fail_over_mac impossible: bad policy %d\n",
+		       bond->dev->name, bond->params.fail_over_mac);
+		break;
+	}
+
+}
+
+
 /**
  * find_best_interface - select the best available slave to be the active one
  * @bond: our bonding struct
@@ -1037,7 +1123,8 @@ static struct slave *bond_find_best_slave(struct bonding *bond)
  * because it is apparently the best available slave we have, even though its
  * updelay hasn't timed out yet.
  *
- * Warning: Caller must hold curr_slave_lock for writing.
+ * If new_active is not NULL, caller must hold bond->lock for read and
+ * curr_slave_lock for write_bh.
  */
 void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 {
@@ -1048,6 +1135,8 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 	}
 
 	if (new_active) {
+		new_active->jiffies = jiffies;
+
 		if (new_active->link == BOND_LINK_BACK) {
 			if (USES_PRIMARY(bond->params.mode)) {
 				printk(KERN_INFO DRV_NAME
@@ -1059,7 +1148,6 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 
 			new_active->delay = 0;
 			new_active->link = BOND_LINK_UP;
-			new_active->jiffies = jiffies;
 
 			if (bond->params.mode == BOND_MODE_8023AD) {
 				bond_3ad_handle_link_change(new_active, BOND_LINK_UP);
@@ -1103,20 +1191,21 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 			bond_set_slave_active_flags(new_active);
 		}
 
-		/* when bonding does not set the slave MAC address, the bond MAC
-		 * address is the one of the active slave.
-		 */
 		if (new_active && bond->params.fail_over_mac)
-			memcpy(bond->dev->dev_addr,  new_active->dev->dev_addr,
-				new_active->dev->addr_len);
+			bond_do_fail_over_mac(bond, new_active, old_active);
+
+		bond->send_grat_arp = bond->params.num_grat_arp;
 		if (bond->curr_active_slave &&
 			test_bit(__LINK_STATE_LINKWATCH_PENDING,
 					&bond->curr_active_slave->dev->state)) {
 			dprintk("delaying gratuitous arp on %s\n",
 				bond->curr_active_slave->dev->name);
-			bond->send_grat_arp = 1;
-		} else
-			bond_send_gratuitous_arp(bond);
+		} else {
+			if (bond->send_grat_arp > 0) {
+				bond_send_gratuitous_arp(bond);
+				bond->send_grat_arp--;
+			}
+		}
 	}
 }
 
@@ -1129,7 +1218,7 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
  * - The primary_slave has got its link back.
  * - A slave has got its link back and there's no old curr_active_slave.
  *
- * Warning: Caller must hold curr_slave_lock for writing.
+ * Caller must hold bond->lock for read and curr_slave_lock for write_bh.
  */
 void bond_select_active_slave(struct bonding *bond)
 {
@@ -1376,14 +1465,14 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 			printk(KERN_WARNING DRV_NAME
 			       ": %s: Warning: The first slave device "
 			       "specified does not support setting the MAC "
-			       "address. Enabling the fail_over_mac option.",
+			       "address. Setting fail_over_mac to active.",
 			       bond_dev->name);
-			bond->params.fail_over_mac = 1;
-		} else if (!bond->params.fail_over_mac) {
+			bond->params.fail_over_mac = BOND_FOM_ACTIVE;
+		} else if (bond->params.fail_over_mac != BOND_FOM_ACTIVE) {
 			printk(KERN_ERR DRV_NAME
 				": %s: Error: The slave device specified "
 				"does not support setting the MAC address, "
-				"but fail_over_mac is not enabled.\n"
+				"but fail_over_mac is not set to active.\n"
 				, bond_dev->name);
 			res = -EOPNOTSUPP;
 			goto err_undo_flags;
@@ -1490,6 +1579,10 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	bond_compute_features(bond);
 
+	write_unlock_bh(&bond->lock);
+
+	read_lock(&bond->lock);
+
 	new_slave->last_arp_rx = jiffies;
 
 	if (bond->params.miimon && !bond->params.use_carrier) {
@@ -1566,6 +1659,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		}
 	}
 
+	write_lock_bh(&bond->curr_slave_lock);
+
 	switch (bond->params.mode) {
 	case BOND_MODE_ACTIVEBACKUP:
 		bond_set_slave_inactive_flags(new_slave);
@@ -1613,9 +1708,11 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		break;
 	} /* switch(bond_mode) */
 
+	write_unlock_bh(&bond->curr_slave_lock);
+
 	bond_set_carrier(bond);
 
-	write_unlock_bh(&bond->lock);
+	read_unlock(&bond->lock);
 
 	res = bond_create_slave_symlinks(bond_dev, slave_dev);
 	if (res)
@@ -1639,6 +1736,10 @@ err_unset_master:
 
 err_restore_mac:
 	if (!bond->params.fail_over_mac) {
+		/* XXX TODO - fom follow mode needs to change master's
+		 * MAC if this slave's MAC is in use by the bond, or at
+		 * least print a warning.
+		 */
 		memcpy(addr.sa_data, new_slave->perm_hwaddr, ETH_ALEN);
 		addr.sa_family = slave_dev->type;
 		dev_set_mac_address(slave_dev, &addr);
@@ -1693,20 +1794,18 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 		return -EINVAL;
 	}
 
-	mac_addr_differ = memcmp(bond_dev->dev_addr,
-				 slave->perm_hwaddr,
-				 ETH_ALEN);
-	if (!mac_addr_differ && (bond->slave_cnt > 1)) {
-		printk(KERN_WARNING DRV_NAME
-		       ": %s: Warning: the permanent HWaddr of %s - "
-		       "%s - is still in use by %s. "
-		       "Set the HWaddr of %s to a different address "
-		       "to avoid conflicts.\n",
-		       bond_dev->name,
-		       slave_dev->name,
-		       print_mac(mac, slave->perm_hwaddr),
-		       bond_dev->name,
-		       slave_dev->name);
+	if (!bond->params.fail_over_mac) {
+		mac_addr_differ = memcmp(bond_dev->dev_addr, slave->perm_hwaddr,
+					 ETH_ALEN);
+		if (!mac_addr_differ && (bond->slave_cnt > 1))
+			printk(KERN_WARNING DRV_NAME
+			       ": %s: Warning: the permanent HWaddr of %s - "
+			       "%s - is still in use by %s. "
+			       "Set the HWaddr of %s to a different address "
+			       "to avoid conflicts.\n",
+			       bond_dev->name, slave_dev->name,
+			       print_mac(mac, slave->perm_hwaddr),
+			       bond_dev->name, slave_dev->name);
 	}
 
 	/* Inform AD package of unbinding of slave. */
@@ -1833,7 +1932,7 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 	/* close slave before restoring its mac address */
 	dev_close(slave_dev);
 
-	if (!bond->params.fail_over_mac) {
+	if (bond->params.fail_over_mac != BOND_FOM_ACTIVE) {
 		/* restore original ("permanent") mac address */
 		memcpy(addr.sa_data, slave->perm_hwaddr, ETH_ALEN);
 		addr.sa_family = slave_dev->type;
@@ -2144,7 +2243,7 @@ static int __bond_mii_monitor(struct bonding *bond, int have_locks)
 			dprintk("sending delayed gratuitous arp on on %s\n",
 				bond->curr_active_slave->dev->name);
 			bond_send_gratuitous_arp(bond);
-			bond->send_grat_arp = 0;
+			bond->send_grat_arp--;
 		}
 	}
 	read_lock(&bond->curr_slave_lock);
@@ -2397,7 +2496,7 @@ void bond_mii_monitor(struct work_struct *work)
 		read_lock(&bond->lock);
 	}
 
-	delay = ((bond->params.miimon * HZ) / 1000) ? : 1;
+	delay = msecs_to_jiffies(bond->params.miimon);
 	read_unlock(&bond->lock);
 	queue_delayed_work(bond->wq, &bond->mii_work, delay);
 }
@@ -2426,37 +2525,14 @@ out:
 	return addr;
 }
 
-static int bond_has_ip(struct bonding *bond)
-{
-	struct vlan_entry *vlan, *vlan_next;
-
-	if (bond->master_ip)
-		return 1;
-
-	if (list_empty(&bond->vlan_list))
-		return 0;
-
-	list_for_each_entry_safe(vlan, vlan_next, &bond->vlan_list,
-				 vlan_list) {
-		if (vlan->vlan_ip)
-			return 1;
-	}
-
-	return 0;
-}
-
 static int bond_has_this_ip(struct bonding *bond, __be32 ip)
 {
-	struct vlan_entry *vlan, *vlan_next;
+	struct vlan_entry *vlan;
 
 	if (ip == bond->master_ip)
 		return 1;
 
-	if (list_empty(&bond->vlan_list))
-		return 0;
-
-	list_for_each_entry_safe(vlan, vlan_next, &bond->vlan_list,
-				 vlan_list) {
+	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
 		if (ip == vlan->vlan_ip)
 			return 1;
 	}
@@ -2498,7 +2574,7 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 {
 	int i, vlan_id, rv;
 	__be32 *targets = bond->params.arp_targets;
-	struct vlan_entry *vlan, *vlan_next;
+	struct vlan_entry *vlan;
 	struct net_device *vlan_dev;
 	struct flowi fl;
 	struct rtable *rt;
@@ -2545,8 +2621,7 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 		}
 
 		vlan_id = 0;
-		list_for_each_entry_safe(vlan, vlan_next, &bond->vlan_list,
-					 vlan_list) {
+		list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
 			vlan_dev = vlan_group_get_device(bond->vlgrp, vlan->vlan_id);
 			if (vlan_dev == rt->u.dst.dev) {
 				vlan_id = vlan->vlan_id;
@@ -2707,7 +2782,7 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 
 	read_lock(&bond->lock);
 
-	delta_in_ticks = (bond->params.arp_interval * HZ) / 1000;
+	delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval);
 
 	if (bond->kill_timers) {
 		goto out;
@@ -2764,8 +2839,7 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 			 * if we don't know our ip yet
 			 */
 			if (time_after_eq(jiffies, slave->dev->trans_start + 2*delta_in_ticks) ||
-			    (time_after_eq(jiffies, slave->dev->last_rx + 2*delta_in_ticks) &&
-			     bond_has_ip(bond))) {
+			    (time_after_eq(jiffies, slave->dev->last_rx + 2*delta_in_ticks))) {
 
 				slave->link  = BOND_LINK_DOWN;
 				slave->state = BOND_STATE_BACKUP;
@@ -2813,246 +2887,299 @@ out:
 }
 
 /*
- * When using arp monitoring in active-backup mode, this function is
- * called to determine if any backup slaves have went down or a new
- * current slave needs to be found.
- * The backup slaves never generate traffic, they are considered up by merely
- * receiving traffic. If the current slave goes down, each backup slave will
- * be given the opportunity to tx/rx an arp before being taken down - this
- * prevents all slaves from being taken down due to the current slave not
- * sending any traffic for the backups to receive. The arps are not necessarily
- * necessary, any tx and rx traffic will keep the current slave up. While any
- * rx traffic will keep the backup slaves up, the current slave is responsible
- * for generating traffic to keep them up regardless of any other traffic they
- * may have received.
- * see loadbalance_arp_monitor for arp monitoring in load balancing mode
+ * Called to inspect slaves for active-backup mode ARP monitor link state
+ * changes.  Sets new_link in slaves to specify what action should take
+ * place for the slave.  Returns 0 if no changes are found, >0 if changes
+ * to link states must be committed.
+ *
+ * Called with bond->lock held for read.
  */
-void bond_activebackup_arp_mon(struct work_struct *work)
+static int bond_ab_arp_inspect(struct bonding *bond, int delta_in_ticks)
 {
-	struct bonding *bond = container_of(work, struct bonding,
-					    arp_work.work);
 	struct slave *slave;
-	int delta_in_ticks;
-	int i;
+	int i, commit = 0;
 
-	read_lock(&bond->lock);
+	bond_for_each_slave(bond, slave, i) {
+		slave->new_link = BOND_LINK_NOCHANGE;
 
-	delta_in_ticks = (bond->params.arp_interval * HZ) / 1000;
+		if (slave->link != BOND_LINK_UP) {
+			if (time_before_eq(jiffies, slave_last_rx(bond, slave) +
+					   delta_in_ticks)) {
+				slave->new_link = BOND_LINK_UP;
+				commit++;
+			}
 
-	if (bond->kill_timers) {
-		goto out;
-	}
+			continue;
+		}
 
-	if (bond->slave_cnt == 0) {
-		goto re_arm;
+		/*
+		 * Give slaves 2*delta after being enslaved or made
+		 * active.  This avoids bouncing, as the last receive
+		 * times need a full ARP monitor cycle to be updated.
+		 */
+		if (!time_after_eq(jiffies, slave->jiffies +
+				   2 * delta_in_ticks))
+			continue;
+
+		/*
+		 * Backup slave is down if:
+		 * - No current_arp_slave AND
+		 * - more than 3*delta since last receive AND
+		 * - the bond has an IP address
+		 *
+		 * Note: a non-null current_arp_slave indicates
+		 * the curr_active_slave went down and we are
+		 * searching for a new one; under this condition
+		 * we only take the curr_active_slave down - this
+		 * gives each slave a chance to tx/rx traffic
+		 * before being taken out
+		 */
+		if (slave->state == BOND_STATE_BACKUP &&
+		    !bond->current_arp_slave &&
+		    time_after(jiffies, slave_last_rx(bond, slave) +
+			       3 * delta_in_ticks)) {
+			slave->new_link = BOND_LINK_DOWN;
+			commit++;
+		}
+
+		/*
+		 * Active slave is down if:
+		 * - more than 2*delta since transmitting OR
+		 * - (more than 2*delta since receive AND
+		 *    the bond has an IP address)
+		 */
+		if ((slave->state == BOND_STATE_ACTIVE) &&
+		    (time_after_eq(jiffies, slave->dev->trans_start +
+				    2 * delta_in_ticks) ||
+		      (time_after_eq(jiffies, slave_last_rx(bond, slave)
+				     + 2 * delta_in_ticks)))) {
+			slave->new_link = BOND_LINK_DOWN;
+			commit++;
+		}
 	}
 
-	/* determine if any slave has come up or any backup slave has
-	 * gone down
-	 * TODO: what about up/down delay in arp mode? it wasn't here before
-	 *       so it can wait
+	read_lock(&bond->curr_slave_lock);
+
+	/*
+	 * Trigger a commit if the primary option setting has changed.
 	 */
-	bond_for_each_slave(bond, slave, i) {
-		if (slave->link != BOND_LINK_UP) {
-			if (time_before_eq(jiffies,
-			    slave_last_rx(bond, slave) + delta_in_ticks)) {
+	if (bond->primary_slave &&
+	    (bond->primary_slave != bond->curr_active_slave) &&
+	    (bond->primary_slave->link == BOND_LINK_UP))
+		commit++;
 
-				slave->link = BOND_LINK_UP;
+	read_unlock(&bond->curr_slave_lock);
 
-				write_lock_bh(&bond->curr_slave_lock);
+	return commit;
+}
 
-				if ((!bond->curr_active_slave) &&
-				    time_before_eq(jiffies, slave->dev->trans_start + delta_in_ticks)) {
-					bond_change_active_slave(bond, slave);
-					bond->current_arp_slave = NULL;
-				} else if (bond->curr_active_slave != slave) {
-					/* this slave has just come up but we
-					 * already have a current slave; this
-					 * can also happen if bond_enslave adds
-					 * a new slave that is up while we are
-					 * searching for a new slave
-					 */
-					bond_set_slave_inactive_flags(slave);
-					bond->current_arp_slave = NULL;
-				}
+/*
+ * Called to commit link state changes noted by inspection step of
+ * active-backup mode ARP monitor.
+ *
+ * Called with RTNL and bond->lock for read.
+ */
+static void bond_ab_arp_commit(struct bonding *bond, int delta_in_ticks)
+{
+	struct slave *slave;
+	int i;
 
-				bond_set_carrier(bond);
+	bond_for_each_slave(bond, slave, i) {
+		switch (slave->new_link) {
+		case BOND_LINK_NOCHANGE:
+			continue;
 
-				if (slave == bond->curr_active_slave) {
-					printk(KERN_INFO DRV_NAME
-					       ": %s: %s is up and now the "
-					       "active interface\n",
-					       bond->dev->name,
-					       slave->dev->name);
-					netif_carrier_on(bond->dev);
-				} else {
-					printk(KERN_INFO DRV_NAME
-					       ": %s: backup interface %s is "
-					       "now up\n",
-					       bond->dev->name,
-					       slave->dev->name);
-				}
+		case BOND_LINK_UP:
+			write_lock_bh(&bond->curr_slave_lock);
 
-				write_unlock_bh(&bond->curr_slave_lock);
-			}
-		} else {
-			read_lock(&bond->curr_slave_lock);
+			if (!bond->curr_active_slave &&
+			    time_before_eq(jiffies, slave->dev->trans_start +
+					   delta_in_ticks)) {
+				slave->link = BOND_LINK_UP;
+				bond_change_active_slave(bond, slave);
+				bond->current_arp_slave = NULL;
 
-			if ((slave != bond->curr_active_slave) &&
-			    (!bond->current_arp_slave) &&
-			    (time_after_eq(jiffies, slave_last_rx(bond, slave) + 3*delta_in_ticks) &&
-			     bond_has_ip(bond))) {
-				/* a backup slave has gone down; three times
-				 * the delta allows the current slave to be
-				 * taken out before the backup slave.
-				 * note: a non-null current_arp_slave indicates
-				 * the curr_active_slave went down and we are
-				 * searching for a new one; under this
-				 * condition we only take the curr_active_slave
-				 * down - this gives each slave a chance to
-				 * tx/rx traffic before being taken out
+				printk(KERN_INFO DRV_NAME
+				       ": %s: %s is up and now the "
+				       "active interface\n",
+				       bond->dev->name, slave->dev->name);
+
+			} else if (bond->curr_active_slave != slave) {
+				/* this slave has just come up but we
+				 * already have a current slave; this can
+				 * also happen if bond_enslave adds a new
+				 * slave that is up while we are searching
+				 * for a new slave
 				 */
+				slave->link = BOND_LINK_UP;
+				bond_set_slave_inactive_flags(slave);
+				bond->current_arp_slave = NULL;
 
-				read_unlock(&bond->curr_slave_lock);
+				printk(KERN_INFO DRV_NAME
+				       ": %s: backup interface %s is now up\n",
+				       bond->dev->name, slave->dev->name);
+			}
 
-				slave->link  = BOND_LINK_DOWN;
+			write_unlock_bh(&bond->curr_slave_lock);
 
-				if (slave->link_failure_count < UINT_MAX) {
-					slave->link_failure_count++;
-				}
+			break;
+
+		case BOND_LINK_DOWN:
+			if (slave->link_failure_count < UINT_MAX)
+				slave->link_failure_count++;
+
+			slave->link = BOND_LINK_DOWN;
+
+			if (slave == bond->curr_active_slave) {
+				printk(KERN_INFO DRV_NAME
+				       ": %s: link status down for active "
+				       "interface %s, disabling it\n",
+				       bond->dev->name, slave->dev->name);
 
 				bond_set_slave_inactive_flags(slave);
 
+				write_lock_bh(&bond->curr_slave_lock);
+
+				bond_select_active_slave(bond);
+				if (bond->curr_active_slave)
+					bond->curr_active_slave->jiffies =
+						jiffies;
+
+				write_unlock_bh(&bond->curr_slave_lock);
+
+				bond->current_arp_slave = NULL;
+
+			} else if (slave->state == BOND_STATE_BACKUP) {
 				printk(KERN_INFO DRV_NAME
 				       ": %s: backup interface %s is now down\n",
-				       bond->dev->name,
-				       slave->dev->name);
-			} else {
-				read_unlock(&bond->curr_slave_lock);
+				       bond->dev->name, slave->dev->name);
+
+				bond_set_slave_inactive_flags(slave);
 			}
+			break;
+
+		default:
+			printk(KERN_ERR DRV_NAME
+			       ": %s: impossible: new_link %d on slave %s\n",
+			       bond->dev->name, slave->new_link,
+			       slave->dev->name);
 		}
 	}
 
-	read_lock(&bond->curr_slave_lock);
-	slave = bond->curr_active_slave;
-	read_unlock(&bond->curr_slave_lock);
-
-	if (slave) {
-		/* if we have sent traffic in the past 2*arp_intervals but
-		 * haven't xmit and rx traffic in that time interval, select
-		 * a different slave. slave->jiffies is only updated when
-		 * a slave first becomes the curr_active_slave - not necessarily
-		 * after every arp; this ensures the slave has a full 2*delta
-		 * before being taken out. if a primary is being used, check
-		 * if it is up and needs to take over as the curr_active_slave
-		 */
-		if ((time_after_eq(jiffies, slave->dev->trans_start + 2*delta_in_ticks) ||
-			(time_after_eq(jiffies, slave_last_rx(bond, slave) + 2*delta_in_ticks) &&
-			 bond_has_ip(bond))) &&
-			time_after_eq(jiffies, slave->jiffies + 2*delta_in_ticks)) {
+	/*
+	 * No race with changes to primary via sysfs, as we hold rtnl.
+	 */
+	if (bond->primary_slave &&
+	    (bond->primary_slave != bond->curr_active_slave) &&
+	    (bond->primary_slave->link == BOND_LINK_UP)) {
+		write_lock_bh(&bond->curr_slave_lock);
+		bond_change_active_slave(bond, bond->primary_slave);
+		write_unlock_bh(&bond->curr_slave_lock);
+	}
 
-			slave->link  = BOND_LINK_DOWN;
+	bond_set_carrier(bond);
+}
 
-			if (slave->link_failure_count < UINT_MAX) {
-				slave->link_failure_count++;
-			}
+/*
+ * Send ARP probes for active-backup mode ARP monitor.
+ *
+ * Called with bond->lock held for read.
+ */
+static void bond_ab_arp_probe(struct bonding *bond)
+{
+	struct slave *slave;
+	int i;
 
-			printk(KERN_INFO DRV_NAME
-			       ": %s: link status down for active interface "
-			       "%s, disabling it\n",
-			       bond->dev->name,
-			       slave->dev->name);
+	read_lock(&bond->curr_slave_lock);
 
-			write_lock_bh(&bond->curr_slave_lock);
+	if (bond->current_arp_slave && bond->curr_active_slave)
+		printk("PROBE: c_arp %s && cas %s BAD\n",
+		       bond->current_arp_slave->dev->name,
+		       bond->curr_active_slave->dev->name);
 
-			bond_select_active_slave(bond);
-			slave = bond->curr_active_slave;
+	if (bond->curr_active_slave) {
+		bond_arp_send_all(bond, bond->curr_active_slave);
+		read_unlock(&bond->curr_slave_lock);
+		return;
+	}
 
-			write_unlock_bh(&bond->curr_slave_lock);
+	read_unlock(&bond->curr_slave_lock);
 
-			bond->current_arp_slave = slave;
+	/* if we don't have a curr_active_slave, search for the next available
+	 * backup slave from the current_arp_slave and make it the candidate
+	 * for becoming the curr_active_slave
+	 */
 
-			if (slave) {
-				slave->jiffies = jiffies;
-			}
-		} else if ((bond->primary_slave) &&
-			   (bond->primary_slave != slave) &&
-			   (bond->primary_slave->link == BOND_LINK_UP)) {
-			/* at this point, slave is the curr_active_slave */
-			printk(KERN_INFO DRV_NAME
-			       ": %s: changing from interface %s to primary "
-			       "interface %s\n",
-			       bond->dev->name,
-			       slave->dev->name,
-			       bond->primary_slave->dev->name);
+	if (!bond->current_arp_slave) {
+		bond->current_arp_slave = bond->first_slave;
+		if (!bond->current_arp_slave)
+			return;
+	}
 
-			/* primary is up so switch to it */
-			write_lock_bh(&bond->curr_slave_lock);
-			bond_change_active_slave(bond, bond->primary_slave);
-			write_unlock_bh(&bond->curr_slave_lock);
+	bond_set_slave_inactive_flags(bond->current_arp_slave);
 
-			slave = bond->primary_slave;
+	/* search for next candidate */
+	bond_for_each_slave_from(bond, slave, i, bond->current_arp_slave->next) {
+		if (IS_UP(slave->dev)) {
+			slave->link = BOND_LINK_BACK;
+			bond_set_slave_active_flags(slave);
+			bond_arp_send_all(bond, slave);
 			slave->jiffies = jiffies;
-		} else {
-			bond->current_arp_slave = NULL;
+			bond->current_arp_slave = slave;
+			break;
 		}
 
-		/* the current slave must tx an arp to ensure backup slaves
-		 * rx traffic
+		/* if the link state is up at this point, we
+		 * mark it down - this can happen if we have
+		 * simultaneous link failures and
+		 * reselect_active_interface doesn't make this
+		 * one the current slave so it is still marked
+		 * up when it is actually down
 		 */
-		if (slave && bond_has_ip(bond)) {
-			bond_arp_send_all(bond, slave);
+		if (slave->link == BOND_LINK_UP) {
+			slave->link = BOND_LINK_DOWN;
+			if (slave->link_failure_count < UINT_MAX)
+				slave->link_failure_count++;
+
+			bond_set_slave_inactive_flags(slave);
+
+			printk(KERN_INFO DRV_NAME
+			       ": %s: backup interface %s is now down.\n",
+			       bond->dev->name, slave->dev->name);
 		}
 	}
+}
 
-	/* if we don't have a curr_active_slave, search for the next available
-	 * backup slave from the current_arp_slave and make it the candidate
-	 * for becoming the curr_active_slave
-	 */
-	if (!slave) {
-		if (!bond->current_arp_slave) {
-			bond->current_arp_slave = bond->first_slave;
-		}
+void bond_activebackup_arp_mon(struct work_struct *work)
+{
+	struct bonding *bond = container_of(work, struct bonding,
+					    arp_work.work);
+	int delta_in_ticks;
 
-		if (bond->current_arp_slave) {
-			bond_set_slave_inactive_flags(bond->current_arp_slave);
+	read_lock(&bond->lock);
 
-			/* search for next candidate */
-			bond_for_each_slave_from(bond, slave, i, bond->current_arp_slave->next) {
-				if (IS_UP(slave->dev)) {
-					slave->link = BOND_LINK_BACK;
-					bond_set_slave_active_flags(slave);
-					bond_arp_send_all(bond, slave);
-					slave->jiffies = jiffies;
-					bond->current_arp_slave = slave;
-					break;
-				}
+	if (bond->kill_timers)
+		goto out;
 
-				/* if the link state is up at this point, we
-				 * mark it down - this can happen if we have
-				 * simultaneous link failures and
-				 * reselect_active_interface doesn't make this
-				 * one the current slave so it is still marked
-				 * up when it is actually down
-				 */
-				if (slave->link == BOND_LINK_UP) {
-					slave->link  = BOND_LINK_DOWN;
-					if (slave->link_failure_count < UINT_MAX) {
-						slave->link_failure_count++;
-					}
+	delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval);
 
-					bond_set_slave_inactive_flags(slave);
+	if (bond->slave_cnt == 0)
+		goto re_arm;
 
-					printk(KERN_INFO DRV_NAME
-					       ": %s: backup interface %s is "
-					       "now down.\n",
-					       bond->dev->name,
-					       slave->dev->name);
-				}
-			}
-		}
+	if (bond_ab_arp_inspect(bond, delta_in_ticks)) {
+		read_unlock(&bond->lock);
+		rtnl_lock();
+		read_lock(&bond->lock);
+
+		bond_ab_arp_commit(bond, delta_in_ticks);
+
+		read_unlock(&bond->lock);
+		rtnl_unlock();
+		read_lock(&bond->lock);
 	}
 
+	bond_ab_arp_probe(bond);
+
 re_arm:
 	if (bond->params.arp_interval) {
 		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
@@ -3128,7 +3255,8 @@ static void bond_info_show_master(struct seq_file *seq)
 
 	if (bond->params.mode == BOND_MODE_ACTIVEBACKUP &&
 	    bond->params.fail_over_mac)
-		seq_printf(seq, " (fail_over_mac)");
+		seq_printf(seq, " (fail_over_mac %s)",
+		   fail_over_mac_tbl[bond->params.fail_over_mac].modename);
 
 	seq_printf(seq, "\n");
 
@@ -3500,13 +3628,13 @@ static int bond_inetaddr_event(struct notifier_block *this, unsigned long event,
 {
 	struct in_ifaddr *ifa = ptr;
 	struct net_device *vlan_dev, *event_dev = ifa->ifa_dev->dev;
-	struct bonding *bond, *bond_next;
-	struct vlan_entry *vlan, *vlan_next;
+	struct bonding *bond;
+	struct vlan_entry *vlan;
 
 	if (dev_net(ifa->ifa_dev->dev) != &init_net)
 		return NOTIFY_DONE;
 
-	list_for_each_entry_safe(bond, bond_next, &bond_dev_list, bond_list) {
+	list_for_each_entry(bond, &bond_dev_list, bond_list) {
 		if (bond->dev == event_dev) {
 			switch (event) {
 			case NETDEV_UP:
@@ -3520,11 +3648,7 @@ static int bond_inetaddr_event(struct notifier_block *this, unsigned long event,
 			}
 		}
 
-		if (list_empty(&bond->vlan_list))
-			continue;
-
-		list_for_each_entry_safe(vlan, vlan_next, &bond->vlan_list,
-					 vlan_list) {
+		list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
 			vlan_dev = vlan_group_get_device(bond->vlgrp, vlan->vlan_id);
 			if (vlan_dev == event_dev) {
 				switch (event) {
@@ -4060,10 +4184,10 @@ static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
 	dprintk("bond=%p, name=%s\n", bond, (bond_dev ? bond_dev->name : "None"));
 
 	/*
-	 * If fail_over_mac is enabled, do nothing and return success.
-	 * Returning an error causes ifenslave to fail.
+	 * If fail_over_mac is set to active, do nothing and return
+	 * success.  Returning an error causes ifenslave to fail.
 	 */
-	if (bond->params.fail_over_mac)
+	if (bond->params.fail_over_mac == BOND_FOM_ACTIVE)
 		return 0;
 
 	if (!is_valid_ether_addr(sa->sa_data)) {
@@ -4568,7 +4692,7 @@ int bond_parse_parm(const char *buf, struct bond_parm_tbl *tbl)
 
 static int bond_check_params(struct bond_params *params)
 {
-	int arp_validate_value;
+	int arp_validate_value, fail_over_mac_value;
 
 	/*
 	 * Convert string parameters.
@@ -4658,6 +4782,13 @@ static int bond_check_params(struct bond_params *params)
 		use_carrier = 1;
 	}
 
+	if (num_grat_arp < 0 || num_grat_arp > 255) {
+		printk(KERN_WARNING DRV_NAME
+		       ": Warning: num_grat_arp (%d) not in range 0-255 so it "
+		       "was reset to 1 \n", num_grat_arp);
+		num_grat_arp = 1;
+	}
+
 	/* reset values for 802.3ad */
 	if (bond_mode == BOND_MODE_8023AD) {
 		if (!miimon) {
@@ -4836,15 +4967,29 @@ static int bond_check_params(struct bond_params *params)
 		primary = NULL;
 	}
 
-	if (fail_over_mac && (bond_mode != BOND_MODE_ACTIVEBACKUP))
-		printk(KERN_WARNING DRV_NAME
-		       ": Warning: fail_over_mac only affects "
-		       "active-backup mode.\n");
+	if (fail_over_mac) {
+		fail_over_mac_value = bond_parse_parm(fail_over_mac,
+						      fail_over_mac_tbl);
+		if (fail_over_mac_value == -1) {
+			printk(KERN_ERR DRV_NAME
+			       ": Error: invalid fail_over_mac \"%s\"\n",
+			       arp_validate == NULL ? "NULL" : arp_validate);
+			return -EINVAL;
+		}
+
+		if (bond_mode != BOND_MODE_ACTIVEBACKUP)
+			printk(KERN_WARNING DRV_NAME
+			       ": Warning: fail_over_mac only affects "
+			       "active-backup mode.\n");
+	} else {
+		fail_over_mac_value = BOND_FOM_NONE;
+	}
 
 	/* fill params struct with the proper values */
 	params->mode = bond_mode;
 	params->xmit_policy = xmit_hashtype;
 	params->miimon = miimon;
+	params->num_grat_arp = num_grat_arp;
 	params->arp_interval = arp_interval;
 	params->arp_validate = arp_validate_value;
 	params->updelay = updelay;
@@ -4852,7 +4997,7 @@ static int bond_check_params(struct bond_params *params)
 	params->use_carrier = use_carrier;
 	params->lacp_fast = lacp_fast;
 	params->primary[0] = 0;
-	params->fail_over_mac = fail_over_mac;
+	params->fail_over_mac = fail_over_mac_value;
 
 	if (primary) {
 		strncpy(params->primary, primary, IFNAMSIZ);
@@ -4871,10 +5016,10 @@ static struct lock_class_key bonding_netdev_xmit_lock_key;
  * Caller must NOT hold rtnl_lock; we need to release it here before we
  * set up our sysfs entries.
  */
-int bond_create(char *name, struct bond_params *params, struct bonding **newbond)
+int bond_create(char *name, struct bond_params *params)
 {
 	struct net_device *bond_dev;
-	struct bonding *bond, *nxt;
+	struct bonding *bond;
 	int res;
 
 	rtnl_lock();
@@ -4882,7 +5027,7 @@ int bond_create(char *name, struct bond_params *params, struct bonding **newbond
 
 	/* Check to see if the bond already exists. */
 	if (name) {
-		list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list)
+		list_for_each_entry(bond, &bond_dev_list, bond_list)
 			if (strnicmp(bond->dev->name, name, IFNAMSIZ) == 0) {
 				printk(KERN_ERR DRV_NAME
 			       ": cannot add bond %s; it already exists\n",
@@ -4925,9 +5070,6 @@ int bond_create(char *name, struct bond_params *params, struct bonding **newbond
 
 	lockdep_set_class(&bond_dev->_xmit_lock, &bonding_netdev_xmit_lock_key);
 
-	if (newbond)
-		*newbond = bond_dev->priv;
-
 	netif_carrier_off(bond_dev);
 
 	up_write(&bonding_rwsem);
@@ -4957,7 +5099,7 @@ static int __init bonding_init(void)
 {
 	int i;
 	int res;
-	struct bonding *bond, *nxt;
+	struct bonding *bond;
 
 	printk(KERN_INFO "%s", version);
 
@@ -4973,7 +5115,7 @@ static int __init bonding_init(void)
 	init_rwsem(&bonding_rwsem);
 
 	for (i = 0; i < max_bonds; i++) {
-		res = bond_create(NULL, &bonding_defaults, NULL);
+		res = bond_create(NULL, &bonding_defaults);
 		if (res)
 			goto err;
 	}
@@ -4987,7 +5129,7 @@ static int __init bonding_init(void)
 
 	goto out;
 err:
-	list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list) {
+	list_for_each_entry(bond, &bond_dev_list, bond_list) {
 		bond_work_cancel_all(bond);
 		destroy_workqueue(bond->wq);
 	}
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 08f3d39..dd265c6 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -50,6 +50,7 @@ extern struct bond_parm_tbl bond_mode_tbl[];
 extern struct bond_parm_tbl bond_lacp_tbl[];
 extern struct bond_parm_tbl xmit_hashtype_tbl[];
 extern struct bond_parm_tbl arp_validate_tbl[];
+extern struct bond_parm_tbl fail_over_mac_tbl[];
 
 static int expected_refcount = -1;
 static struct class *netdev_class;
@@ -111,7 +112,6 @@ static ssize_t bonding_store_bonds(struct class *cls, const char *buffer, size_t
 	char *ifname;
 	int rv, res = count;
 	struct bonding *bond;
-	struct bonding *nxt;
 
 	sscanf(buffer, "%16s", command); /* IFNAMSIZ*/
 	ifname = command + 1;
@@ -122,7 +122,7 @@ static ssize_t bonding_store_bonds(struct class *cls, const char *buffer, size_t
 	if (command[0] == '+') {
 		printk(KERN_INFO DRV_NAME
 			": %s is being created...\n", ifname);
-		rv = bond_create(ifname, &bonding_defaults, &bond);
+		rv = bond_create(ifname, &bonding_defaults);
 		if (rv) {
 			printk(KERN_INFO DRV_NAME ": Bond creation failed.\n");
 			res = rv;
@@ -134,7 +134,7 @@ static ssize_t bonding_store_bonds(struct class *cls, const char *buffer, size_t
 		rtnl_lock();
 		down_write(&bonding_rwsem);
 
-		list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list)
+		list_for_each_entry(bond, &bond_dev_list, bond_list)
 			if (strnicmp(bond->dev->name, ifname, IFNAMSIZ) == 0) {
 				/* check the ref count on the bond's kobject.
 				 * If it's > expected, then there's a file open,
@@ -548,42 +548,37 @@ static ssize_t bonding_show_fail_over_mac(struct device *d, struct device_attrib
 {
 	struct bonding *bond = to_bond(d);
 
-	return sprintf(buf, "%d\n", bond->params.fail_over_mac) + 1;
+	return sprintf(buf, "%s %d\n",
+		       fail_over_mac_tbl[bond->params.fail_over_mac].modename,
+		       bond->params.fail_over_mac);
 }
 
 static ssize_t bonding_store_fail_over_mac(struct device *d, struct device_attribute *attr, const char *buf, size_t count)
 {
 	int new_value;
-	int ret = count;
 	struct bonding *bond = to_bond(d);
 
 	if (bond->slave_cnt != 0) {
 		printk(KERN_ERR DRV_NAME
 		       ": %s: Can't alter fail_over_mac with slaves in bond.\n",
 		       bond->dev->name);
-		ret = -EPERM;
-		goto out;
+		return -EPERM;
 	}
 
-	if (sscanf(buf, "%d", &new_value) != 1) {
+	new_value = bond_parse_parm(buf, fail_over_mac_tbl);
+	if (new_value < 0) {
 		printk(KERN_ERR DRV_NAME
-		       ": %s: no fail_over_mac value specified.\n",
-		       bond->dev->name);
-		ret = -EINVAL;
-		goto out;
+		       ": %s: Ignoring invalid fail_over_mac value %s.\n",
+		       bond->dev->name, buf);
+		return -EINVAL;
 	}
 
-	if ((new_value == 0) || (new_value == 1)) {
-		bond->params.fail_over_mac = new_value;
-		printk(KERN_INFO DRV_NAME ": %s: Setting fail_over_mac to %d.\n",
-		       bond->dev->name, new_value);
-	} else {
-		printk(KERN_INFO DRV_NAME
-		       ": %s: Ignoring invalid fail_over_mac value %d.\n",
-		       bond->dev->name, new_value);
-	}
-out:
-	return ret;
+	bond->params.fail_over_mac = new_value;
+	printk(KERN_INFO DRV_NAME ": %s: Setting fail_over_mac to %s (%d).\n",
+	       bond->dev->name, fail_over_mac_tbl[new_value].modename,
+	       new_value);
+
+	return count;
 }
 
 static DEVICE_ATTR(fail_over_mac, S_IRUGO | S_IWUSR, bonding_show_fail_over_mac, bonding_store_fail_over_mac);
@@ -952,6 +947,45 @@ out:
 static DEVICE_ATTR(lacp_rate, S_IRUGO | S_IWUSR, bonding_show_lacp, bonding_store_lacp);
 
 /*
+ * Show and set the number of grat ARP to send after a failover event.
+ */
+static ssize_t bonding_show_n_grat_arp(struct device *d,
+				   struct device_attribute *attr,
+				   char *buf)
+{
+	struct bonding *bond = to_bond(d);
+
+	return sprintf(buf, "%d\n", bond->params.num_grat_arp);
+}
+
+static ssize_t bonding_store_n_grat_arp(struct device *d,
+				    struct device_attribute *attr,
+				    const char *buf, size_t count)
+{
+	int new_value, ret = count;
+	struct bonding *bond = to_bond(d);
+
+	if (sscanf(buf, "%d", &new_value) != 1) {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: no num_grat_arp value specified.\n",
+		       bond->dev->name);
+		ret = -EINVAL;
+		goto out;
+	}
+	if (new_value < 0 || new_value > 255) {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: Invalid num_grat_arp value %d not in range 0-255; rejected.\n",
+		       bond->dev->name, new_value);
+		ret = -EINVAL;
+		goto out;
+	} else {
+		bond->params.num_grat_arp = new_value;
+	}
+out:
+	return ret;
+}
+static DEVICE_ATTR(num_grat_arp, S_IRUGO | S_IWUSR, bonding_show_n_grat_arp, bonding_store_n_grat_arp);
+/*
  * Show and set the MII monitor interval.  There are two tricky bits
  * here.  First, if MII monitoring is activated, then we must disable
  * ARP monitoring.  Second, if the timer isn't running, we must
@@ -1388,6 +1422,7 @@ static struct attribute *per_bond_attrs[] = {
 	&dev_attr_updelay.attr,
 	&dev_attr_lacp_rate.attr,
 	&dev_attr_xmit_hash_policy.attr,
+	&dev_attr_num_grat_arp.attr,
 	&dev_attr_miimon.attr,
 	&dev_attr_primary.attr,
 	&dev_attr_use_carrier.attr,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index a3c74e2..89fd996 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -125,6 +125,7 @@ struct bond_params {
 	int mode;
 	int xmit_policy;
 	int miimon;
+	int num_grat_arp;
 	int arp_interval;
 	int arp_validate;
 	int use_carrier;
@@ -157,6 +158,7 @@ struct slave {
 	unsigned long jiffies;
 	unsigned long last_arp_rx;
 	s8     link;    /* one of BOND_LINK_XXXX */
+	s8     new_link;
 	s8     state;   /* one of BOND_STATE_XXXX */
 	u32    original_flags;
 	u32    original_mtu;
@@ -169,6 +171,11 @@ struct slave {
 };
 
 /*
+ * Link pseudo-state only used internally by monitors
+ */
+#define BOND_LINK_NOCHANGE -1
+
+/*
  * Here are the locking policies for the two bonding locks:
  *
  * 1) Get bond->lock when reading/writing slave list.
@@ -241,6 +248,10 @@ static inline struct bonding *bond_get_bond_by_slave(struct slave *slave)
 	return (struct bonding *)slave->dev->master->priv;
 }
 
+#define BOND_FOM_NONE			0
+#define BOND_FOM_ACTIVE			1
+#define BOND_FOM_FOLLOW			2
+
 #define BOND_ARP_VALIDATE_NONE		0
 #define BOND_ARP_VALIDATE_ACTIVE	(1 << BOND_STATE_ACTIVE)
 #define BOND_ARP_VALIDATE_BACKUP	(1 << BOND_STATE_BACKUP)
@@ -301,7 +312,7 @@ static inline void bond_unset_master_alb_flags(struct bonding *bond)
 
 struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr);
 int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
-int bond_create(char *name, struct bond_params *params, struct bonding **newbond);
+int bond_create(char *name, struct bond_params *params);
 void bond_destroy(struct bonding *bond);
 int  bond_release_and_destroy(struct net_device *bond_dev, struct net_device *slave_dev);
 int bond_create_sysfs(void);
diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index acebe43..2711404 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -42,6 +42,7 @@
 #include <linux/cache.h>
 #include <linux/mutex.h>
 #include <linux/bitops.h>
+#include <linux/inet_lro.h>
 #include "t3cdev.h"
 #include <asm/io.h>
 
@@ -92,6 +93,7 @@ struct sge_fl {                     /* SGE per free-buffer list state */
 	unsigned int gen;           /* free list generation */
 	struct fl_pg_chunk pg_chunk;/* page chunk cache */
 	unsigned int use_pages;     /* whether FL uses pages or sk_buffs */
+	unsigned int order;	    /* order of page allocations */
 	struct rx_desc *desc;       /* address of HW Rx descriptor ring */
 	struct rx_sw_desc *sdesc;   /* address of SW Rx descriptor ring */
 	dma_addr_t   phys_addr;     /* physical address of HW ring start */
@@ -116,12 +118,15 @@ struct sge_rspq {		/* state for an SGE response queue */
 	unsigned int polling;	/* is the queue serviced through NAPI? */
 	unsigned int holdoff_tmr;	/* interrupt holdoff timer in 100ns */
 	unsigned int next_holdoff;	/* holdoff time for next interrupt */
+	unsigned int rx_recycle_buf; /* whether recycling occurred
+					within current sop-eop */
 	struct rsp_desc *desc;	/* address of HW response ring */
 	dma_addr_t phys_addr;	/* physical address of the ring */
 	unsigned int cntxt_id;	/* SGE context id for the response q */
 	spinlock_t lock;	/* guards response processing */
 	struct sk_buff *rx_head;	/* offload packet receive queue head */
 	struct sk_buff *rx_tail;	/* offload packet receive queue tail */
+	struct sk_buff *pg_skb; /* used to build frag list in napi handler */
 
 	unsigned long offload_pkts;
 	unsigned long offload_bundles;
@@ -169,16 +174,29 @@ enum {				/* per port SGE statistics */
 	SGE_PSTAT_TX_CSUM,	/* # of TX checksum offloads */
 	SGE_PSTAT_VLANEX,	/* # of VLAN tag extractions */
 	SGE_PSTAT_VLANINS,	/* # of VLAN tag insertions */
+	SGE_PSTAT_LRO_AGGR,	/* # of page chunks added to LRO sessions */
+	SGE_PSTAT_LRO_FLUSHED,	/* # of flushed LRO sessions */
+	SGE_PSTAT_LRO_NO_DESC,	/* # of overflown LRO sessions */
 
 	SGE_PSTAT_MAX		/* must be last */
 };
 
+#define T3_MAX_LRO_SES 8
+#define T3_MAX_LRO_MAX_PKTS 64
+
 struct sge_qset {		/* an SGE queue set */
 	struct adapter *adap;
 	struct napi_struct napi;
 	struct sge_rspq rspq;
 	struct sge_fl fl[SGE_RXQ_PER_SET];
 	struct sge_txq txq[SGE_TXQ_PER_SET];
+	struct net_lro_mgr lro_mgr;
+	struct net_lro_desc lro_desc[T3_MAX_LRO_SES];
+	struct skb_frag_struct *lro_frag_tbl;
+	int lro_nfrags;
+	int lro_enabled;
+	int lro_frag_len;
+	void *lro_va;
 	struct net_device *netdev;
 	unsigned long txq_stopped;	/* which Tx queues are stopped */
 	struct timer_list tx_reclaim_timer;	/* reclaims TX buffers */
diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
index 579bee4..d444f58 100644
--- a/drivers/net/cxgb3/common.h
+++ b/drivers/net/cxgb3/common.h
@@ -351,6 +351,7 @@ struct tp_params {
 
 struct qset_params {		/* SGE queue set parameters */
 	unsigned int polling;	/* polling/interrupt service for rspq */
+	unsigned int lro;	/* large receive offload */
 	unsigned int coalesce_usecs;	/* irq coalescing timer */
 	unsigned int rspq_size;	/* # of entries in response queue */
 	unsigned int fl_size;	/* # of entries in regular free list */
diff --git a/drivers/net/cxgb3/cxgb3_ioctl.h b/drivers/net/cxgb3/cxgb3_ioctl.h
index 0a82fcd..68200a1 100644
--- a/drivers/net/cxgb3/cxgb3_ioctl.h
+++ b/drivers/net/cxgb3/cxgb3_ioctl.h
@@ -90,6 +90,7 @@ struct ch_qset_params {
 	int32_t fl_size[2];
 	int32_t intr_lat;
 	int32_t polling;
+	int32_t lro;
 	int32_t cong_thres;
 };
 
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 3a31272..5447f3e 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -1212,6 +1212,9 @@ static char stats_strings[][ETH_GSTRING_LEN] = {
 	"VLANinsertions     ",
 	"TxCsumOffload      ",
 	"RxCsumGood         ",
+	"LroAggregated      ",
+	"LroFlushed         ",
+	"LroNoDesc          ",
 	"RxDrops            ",
 
 	"CheckTXEnToggled   ",
@@ -1340,6 +1343,9 @@ static void get_stats(struct net_device *dev, struct ethtool_stats *stats,
 	*data++ = collect_sge_port_stats(adapter, pi, SGE_PSTAT_VLANINS);
 	*data++ = collect_sge_port_stats(adapter, pi, SGE_PSTAT_TX_CSUM);
 	*data++ = collect_sge_port_stats(adapter, pi, SGE_PSTAT_RX_CSUM_GOOD);
+	*data++ = collect_sge_port_stats(adapter, pi, SGE_PSTAT_LRO_AGGR);
+	*data++ = collect_sge_port_stats(adapter, pi, SGE_PSTAT_LRO_FLUSHED);
+	*data++ = collect_sge_port_stats(adapter, pi, SGE_PSTAT_LRO_NO_DESC);
 	*data++ = s->rx_cong_drops;
 
 	*data++ = s->num_toggled;
@@ -1558,6 +1564,13 @@ static int set_rx_csum(struct net_device *dev, u32 data)
 	struct port_info *p = netdev_priv(dev);
 
 	p->rx_csum_offload = data;
+	if (!data) {
+		struct adapter *adap = p->adapter;
+		int i;
+
+		for (i = p->first_qset; i < p->first_qset + p->nqsets; i++)
+			adap->sge.qs[i].lro_enabled = 0;
+	}
 	return 0;
 }
 
@@ -1830,6 +1843,11 @@ static int cxgb_extension_ioctl(struct net_device *dev, void __user *useraddr)
 				}
 			}
 		}
+		if (t.lro >= 0) {
+			struct sge_qset *qs = &adapter->sge.qs[t.qset_idx];
+			q->lro = t.lro;
+			qs->lro_enabled = t.lro;
+		}
 		break;
 	}
 	case CHELSIO_GET_QSET_PARAMS:{
@@ -1849,6 +1867,7 @@ static int cxgb_extension_ioctl(struct net_device *dev, void __user *useraddr)
 		t.fl_size[0] = q->fl_size;
 		t.fl_size[1] = q->jumbo_size;
 		t.polling = q->polling;
+		t.lro = q->lro;
 		t.intr_lat = q->coalesce_usecs;
 		t.cong_thres = q->cong_thres;
 
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 796eb30..a96331c 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -55,6 +55,9 @@
  * directly.
  */
 #define FL0_PG_CHUNK_SIZE  2048
+#define FL0_PG_ORDER 0
+#define FL1_PG_CHUNK_SIZE (PAGE_SIZE > 8192 ? 16384 : 8192)
+#define FL1_PG_ORDER (PAGE_SIZE > 8192 ? 0 : 1)
 
 #define SGE_RX_DROP_THRES 16
 
@@ -359,7 +362,7 @@ static void free_rx_bufs(struct pci_dev *pdev, struct sge_fl *q)
 	}
 
 	if (q->pg_chunk.page) {
-		__free_page(q->pg_chunk.page);
+		__free_pages(q->pg_chunk.page, q->order);
 		q->pg_chunk.page = NULL;
 	}
 }
@@ -376,13 +379,16 @@ static void free_rx_bufs(struct pci_dev *pdev, struct sge_fl *q)
  *	Add a buffer of the given length to the supplied HW and SW Rx
  *	descriptors.
  */
-static inline void add_one_rx_buf(void *va, unsigned int len,
-				  struct rx_desc *d, struct rx_sw_desc *sd,
-				  unsigned int gen, struct pci_dev *pdev)
+static inline int add_one_rx_buf(void *va, unsigned int len,
+				 struct rx_desc *d, struct rx_sw_desc *sd,
+				 unsigned int gen, struct pci_dev *pdev)
 {
 	dma_addr_t mapping;
 
 	mapping = pci_map_single(pdev, va, len, PCI_DMA_FROMDEVICE);
+	if (unlikely(pci_dma_mapping_error(mapping)))
+		return -ENOMEM;
+
 	pci_unmap_addr_set(sd, dma_addr, mapping);
 
 	d->addr_lo = cpu_to_be32(mapping);
@@ -390,12 +396,14 @@ static inline void add_one_rx_buf(void *va, unsigned int len,
 	wmb();
 	d->len_gen = cpu_to_be32(V_FLD_GEN1(gen));
 	d->gen2 = cpu_to_be32(V_FLD_GEN2(gen));
+	return 0;
 }
 
-static int alloc_pg_chunk(struct sge_fl *q, struct rx_sw_desc *sd, gfp_t gfp)
+static int alloc_pg_chunk(struct sge_fl *q, struct rx_sw_desc *sd, gfp_t gfp,
+			  unsigned int order)
 {
 	if (!q->pg_chunk.page) {
-		q->pg_chunk.page = alloc_page(gfp);
+		q->pg_chunk.page = alloc_pages(gfp, order);
 		if (unlikely(!q->pg_chunk.page))
 			return -ENOMEM;
 		q->pg_chunk.va = page_address(q->pg_chunk.page);
@@ -404,7 +412,7 @@ static int alloc_pg_chunk(struct sge_fl *q, struct rx_sw_desc *sd, gfp_t gfp)
 	sd->pg_chunk = q->pg_chunk;
 
 	q->pg_chunk.offset += q->buf_size;
-	if (q->pg_chunk.offset == PAGE_SIZE)
+	if (q->pg_chunk.offset == (PAGE_SIZE << order))
 		q->pg_chunk.page = NULL;
 	else {
 		q->pg_chunk.va += q->buf_size;
@@ -424,15 +432,18 @@ static int alloc_pg_chunk(struct sge_fl *q, struct rx_sw_desc *sd, gfp_t gfp)
  *	allocated with the supplied gfp flags.  The caller must assure that
  *	@n does not exceed the queue's capacity.
  */
-static void refill_fl(struct adapter *adap, struct sge_fl *q, int n, gfp_t gfp)
+static int refill_fl(struct adapter *adap, struct sge_fl *q, int n, gfp_t gfp)
 {
 	void *buf_start;
 	struct rx_sw_desc *sd = &q->sdesc[q->pidx];
 	struct rx_desc *d = &q->desc[q->pidx];
+	unsigned int count = 0;
 
 	while (n--) {
+		int err;
+
 		if (q->use_pages) {
-			if (unlikely(alloc_pg_chunk(q, sd, gfp))) {
+			if (unlikely(alloc_pg_chunk(q, sd, gfp, q->order))) {
 nomem:				q->alloc_failed++;
 				break;
 			}
@@ -447,8 +458,16 @@ nomem:				q->alloc_failed++;
 			buf_start = skb->data;
 		}
 
-		add_one_rx_buf(buf_start, q->buf_size, d, sd, q->gen,
-			       adap->pdev);
+		err = add_one_rx_buf(buf_start, q->buf_size, d, sd, q->gen,
+				     adap->pdev);
+		if (unlikely(err)) {
+			if (!q->use_pages) {
+				kfree_skb(sd->skb);
+				sd->skb = NULL;
+			}
+			break;
+		}
+
 		d++;
 		sd++;
 		if (++q->pidx == q->size) {
@@ -458,14 +477,19 @@ nomem:				q->alloc_failed++;
 			d = q->desc;
 		}
 		q->credits++;
+		count++;
 	}
 	wmb();
-	t3_write_reg(adap, A_SG_KDOORBELL, V_EGRCNTX(q->cntxt_id));
+	if (likely(count))
+		t3_write_reg(adap, A_SG_KDOORBELL, V_EGRCNTX(q->cntxt_id));
+
+	return count;
 }
 
 static inline void __refill_fl(struct adapter *adap, struct sge_fl *fl)
 {
-	refill_fl(adap, fl, min(16U, fl->size - fl->credits), GFP_ATOMIC);
+	refill_fl(adap, fl, min(16U, fl->size - fl->credits),
+		  GFP_ATOMIC | __GFP_COMP);
 }
 
 /**
@@ -560,6 +584,8 @@ static void t3_reset_qset(struct sge_qset *q)
 	memset(q->txq, 0, sizeof(struct sge_txq) * SGE_TXQ_PER_SET);
 	q->txq_stopped = 0;
 	memset(&q->tx_reclaim_timer, 0, sizeof(q->tx_reclaim_timer));
+	kfree(q->lro_frag_tbl);
+	q->lro_nfrags = q->lro_frag_len = 0;
 }
 
 
@@ -740,19 +766,22 @@ use_orig_buf:
  * 	that are page chunks rather than sk_buffs.
  */
 static struct sk_buff *get_packet_pg(struct adapter *adap, struct sge_fl *fl,
-				     unsigned int len, unsigned int drop_thres)
+				     struct sge_rspq *q, unsigned int len,
+				     unsigned int drop_thres)
 {
-	struct sk_buff *skb = NULL;
+	struct sk_buff *newskb, *skb;
 	struct rx_sw_desc *sd = &fl->sdesc[fl->cidx];
 
-	if (len <= SGE_RX_COPY_THRES) {
-		skb = alloc_skb(len, GFP_ATOMIC);
-		if (likely(skb != NULL)) {
-			__skb_put(skb, len);
+	newskb = skb = q->pg_skb;
+
+	if (!skb && (len <= SGE_RX_COPY_THRES)) {
+		newskb = alloc_skb(len, GFP_ATOMIC);
+		if (likely(newskb != NULL)) {
+			__skb_put(newskb, len);
 			pci_dma_sync_single_for_cpu(adap->pdev,
 					    pci_unmap_addr(sd, dma_addr), len,
 					    PCI_DMA_FROMDEVICE);
-			memcpy(skb->data, sd->pg_chunk.va, len);
+			memcpy(newskb->data, sd->pg_chunk.va, len);
 			pci_dma_sync_single_for_device(adap->pdev,
 					    pci_unmap_addr(sd, dma_addr), len,
 					    PCI_DMA_FROMDEVICE);
@@ -761,14 +790,16 @@ static struct sk_buff *get_packet_pg(struct adapter *adap, struct sge_fl *fl,
 recycle:
 		fl->credits--;
 		recycle_rx_buf(adap, fl, fl->cidx);
-		return skb;
+		q->rx_recycle_buf++;
+		return newskb;
 	}
 
-	if (unlikely(fl->credits <= drop_thres))
+	if (unlikely(q->rx_recycle_buf || (!skb && fl->credits <= drop_thres)))
 		goto recycle;
 
-	skb = alloc_skb(SGE_RX_PULL_LEN, GFP_ATOMIC);
-	if (unlikely(!skb)) {
+	if (!skb)
+		newskb = alloc_skb(SGE_RX_PULL_LEN, GFP_ATOMIC);
+	if (unlikely(!newskb)) {
 		if (!drop_thres)
 			return NULL;
 		goto recycle;
@@ -776,21 +807,29 @@ recycle:
 
 	pci_unmap_single(adap->pdev, pci_unmap_addr(sd, dma_addr),
 			 fl->buf_size, PCI_DMA_FROMDEVICE);
-	__skb_put(skb, SGE_RX_PULL_LEN);
-	memcpy(skb->data, sd->pg_chunk.va, SGE_RX_PULL_LEN);
-	skb_fill_page_desc(skb, 0, sd->pg_chunk.page,
-			   sd->pg_chunk.offset + SGE_RX_PULL_LEN,
-			   len - SGE_RX_PULL_LEN);
-	skb->len = len;
-	skb->data_len = len - SGE_RX_PULL_LEN;
-	skb->truesize += skb->data_len;
+	if (!skb) {
+		__skb_put(newskb, SGE_RX_PULL_LEN);
+		memcpy(newskb->data, sd->pg_chunk.va, SGE_RX_PULL_LEN);
+		skb_fill_page_desc(newskb, 0, sd->pg_chunk.page,
+				   sd->pg_chunk.offset + SGE_RX_PULL_LEN,
+				   len - SGE_RX_PULL_LEN);
+		newskb->len = len;
+		newskb->data_len = len - SGE_RX_PULL_LEN;
+	} else {
+		skb_fill_page_desc(newskb, skb_shinfo(newskb)->nr_frags,
+				   sd->pg_chunk.page,
+				   sd->pg_chunk.offset, len);
+		newskb->len += len;
+		newskb->data_len += len;
+	}
+	newskb->truesize += newskb->data_len;
 
 	fl->credits--;
 	/*
 	 * We do not refill FLs here, we let the caller do it to overlap a
 	 * prefetch.
 	 */
-	return skb;
+	return newskb;
 }
 
 /**
@@ -1831,9 +1870,10 @@ static void restart_tx(struct sge_qset *qs)
  *	if it was immediate data in a response.
  */
 static void rx_eth(struct adapter *adap, struct sge_rspq *rq,
-		   struct sk_buff *skb, int pad)
+		   struct sk_buff *skb, int pad, int lro)
 {
 	struct cpl_rx_pkt *p = (struct cpl_rx_pkt *)(skb->data + pad);
+	struct sge_qset *qs = rspq_to_qset(rq);
 	struct port_info *pi;
 
 	skb_pull(skb, sizeof(*p) + pad);
@@ -1850,18 +1890,202 @@ static void rx_eth(struct adapter *adap, struct sge_rspq *rq,
 	if (unlikely(p->vlan_valid)) {
 		struct vlan_group *grp = pi->vlan_grp;
 
-		rspq_to_qset(rq)->port_stats[SGE_PSTAT_VLANEX]++;
+		qs->port_stats[SGE_PSTAT_VLANEX]++;
 		if (likely(grp))
-			__vlan_hwaccel_rx(skb, grp, ntohs(p->vlan),
-					  rq->polling);
+			if (lro)
+				lro_vlan_hwaccel_receive_skb(&qs->lro_mgr, skb,
+							     grp,
+							     ntohs(p->vlan),
+							     p);
+			else
+				__vlan_hwaccel_rx(skb, grp, ntohs(p->vlan),
+					  	  rq->polling);
 		else
 			dev_kfree_skb_any(skb);
-	} else if (rq->polling)
-		netif_receive_skb(skb);
-	else
+	} else if (rq->polling) {
+		if (lro)
+			lro_receive_skb(&qs->lro_mgr, skb, p);
+		else
+			netif_receive_skb(skb);
+	} else
 		netif_rx(skb);
 }
 
+static inline int is_eth_tcp(u32 rss)
+{
+	return G_HASHTYPE(ntohl(rss)) == RSS_HASH_4_TUPLE;
+}
+
+/**
+ *	lro_frame_ok - check if an ingress packet is eligible for LRO
+ *	@p: the CPL header of the packet
+ *
+ *	Returns true if a received packet is eligible for LRO.
+ *	The following conditions must be true:
+ *	- packet is TCP/IP Ethernet II (checked elsewhere)
+ *	- not an IP fragment
+ *	- no IP options
+ *	- TCP/IP checksums are correct
+ *	- the packet is for this host
+ */
+static inline int lro_frame_ok(const struct cpl_rx_pkt *p)
+{
+	const struct ethhdr *eh = (struct ethhdr *)(p + 1);
+	const struct iphdr *ih = (struct iphdr *)(eh + 1);
+
+	return (*((u8 *)p + 1) & 0x90) == 0x10 && p->csum == htons(0xffff) &&
+		eh->h_proto == htons(ETH_P_IP) && ih->ihl == (sizeof(*ih) >> 2);
+}
+
+#define TCP_FLAG_MASK (TCP_FLAG_CWR | TCP_FLAG_ECE | TCP_FLAG_URG |\
+                       TCP_FLAG_ACK | TCP_FLAG_PSH | TCP_FLAG_RST |\
+		                       TCP_FLAG_SYN | TCP_FLAG_FIN)
+#define TSTAMP_WORD ((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16) |\
+                     (TCPOPT_TIMESTAMP << 8) | TCPOLEN_TIMESTAMP)
+
+/**
+ *	lro_segment_ok - check if a TCP segment is eligible for LRO
+ *	@tcph: the TCP header of the packet
+ *
+ *	Returns true if a TCP packet is eligible for LRO.  This requires that
+ *	the packet have only the ACK flag set and no TCP options besides
+ *	time stamps.
+ */
+static inline int lro_segment_ok(const struct tcphdr *tcph)
+{
+	int optlen;
+
+	if (unlikely((tcp_flag_word(tcph) & TCP_FLAG_MASK) != TCP_FLAG_ACK))
+		return 0;
+
+	optlen = (tcph->doff << 2) - sizeof(*tcph);
+	if (optlen) {
+		const u32 *opt = (const u32 *)(tcph + 1);
+
+		if (optlen != TCPOLEN_TSTAMP_ALIGNED ||
+		    *opt != htonl(TSTAMP_WORD) || !opt[2])
+			return 0;
+	}
+	return 1;
+}
+
+static int t3_get_lro_header(void **eh,  void **iph, void **tcph,
+			     u64 *hdr_flags, void *priv)
+{
+	const struct cpl_rx_pkt *cpl = priv;
+
+	if (!lro_frame_ok(cpl))
+		return -1;
+
+	*eh = (struct ethhdr *)(cpl + 1);
+	*iph = (struct iphdr *)((struct ethhdr *)*eh + 1);
+	*tcph = (struct tcphdr *)((struct iphdr *)*iph + 1);
+
+	 if (!lro_segment_ok(*tcph))
+		return -1;
+
+	*hdr_flags = LRO_IPV4 | LRO_TCP;
+	return 0;
+}
+
+static int t3_get_skb_header(struct sk_buff *skb,
+			      void **iph, void **tcph, u64 *hdr_flags,
+			      void *priv)
+{
+	void *eh;
+
+	return t3_get_lro_header(&eh, iph, tcph, hdr_flags, priv);
+}
+
+static int t3_get_frag_header(struct skb_frag_struct *frag, void **eh,
+			      void **iph, void **tcph, u64 *hdr_flags,
+			      void *priv)
+{
+	return t3_get_lro_header(eh, iph, tcph, hdr_flags, priv);
+}
+
+/**
+ *	lro_add_page - add a page chunk to an LRO session
+ *	@adap: the adapter
+ *	@qs: the associated queue set
+ *	@fl: the free list containing the page chunk to add
+ *	@len: packet length
+ *	@complete: Indicates the last fragment of a frame
+ *
+ *	Add a received packet contained in a page chunk to an existing LRO
+ *	session.
+ */
+static void lro_add_page(struct adapter *adap, struct sge_qset *qs,
+			 struct sge_fl *fl, int len, int complete)
+{
+	struct rx_sw_desc *sd = &fl->sdesc[fl->cidx];
+	struct cpl_rx_pkt *cpl;
+	struct skb_frag_struct *rx_frag = qs->lro_frag_tbl;
+	int nr_frags = qs->lro_nfrags, frag_len = qs->lro_frag_len;
+	int offset = 0;
+
+	if (!nr_frags) {
+		offset = 2 + sizeof(struct cpl_rx_pkt);
+		qs->lro_va = cpl = sd->pg_chunk.va + 2;
+	}
+
+	fl->credits--;
+
+	len -= offset;
+	pci_unmap_single(adap->pdev, pci_unmap_addr(sd, dma_addr),
+			 fl->buf_size, PCI_DMA_FROMDEVICE);
+
+	rx_frag += nr_frags;
+	rx_frag->page = sd->pg_chunk.page;
+	rx_frag->page_offset = sd->pg_chunk.offset + offset;
+	rx_frag->size = len;
+	frag_len += len;
+	qs->lro_nfrags++;
+	qs->lro_frag_len = frag_len;
+
+	if (!complete)
+		return;
+
+	qs->lro_nfrags = qs->lro_frag_len = 0;
+	cpl = qs->lro_va;
+
+	if (unlikely(cpl->vlan_valid)) {
+		struct net_device *dev = qs->netdev;
+		struct port_info *pi = netdev_priv(dev);
+		struct vlan_group *grp = pi->vlan_grp;
+
+		if (likely(grp != NULL)) {
+			lro_vlan_hwaccel_receive_frags(&qs->lro_mgr,
+						       qs->lro_frag_tbl,
+						       frag_len, frag_len,
+						       grp, ntohs(cpl->vlan),
+						       cpl, 0);
+			return;
+		}
+	}
+	lro_receive_frags(&qs->lro_mgr, qs->lro_frag_tbl,
+			  frag_len, frag_len, cpl, 0);
+}
+
+/**
+ *	init_lro_mgr - initialize a LRO manager object
+ *	@lro_mgr: the LRO manager object
+ */
+static void init_lro_mgr(struct sge_qset *qs, struct net_lro_mgr *lro_mgr)
+{
+	lro_mgr->dev = qs->netdev;
+	lro_mgr->features = LRO_F_NAPI;
+	lro_mgr->ip_summed = CHECKSUM_UNNECESSARY;
+	lro_mgr->ip_summed_aggr = CHECKSUM_UNNECESSARY;
+	lro_mgr->max_desc = T3_MAX_LRO_SES;
+	lro_mgr->lro_arr = qs->lro_desc;
+	lro_mgr->get_frag_header = t3_get_frag_header;
+	lro_mgr->get_skb_header = t3_get_skb_header;
+	lro_mgr->max_aggr = T3_MAX_LRO_MAX_PKTS;
+	if (lro_mgr->max_aggr > MAX_SKB_FRAGS)
+		lro_mgr->max_aggr = MAX_SKB_FRAGS;
+}
+
 /**
  *	handle_rsp_cntrl_info - handles control information in a response
  *	@qs: the queue set corresponding to the response
@@ -1947,6 +2171,12 @@ static inline int is_new_response(const struct rsp_desc *r,
 	return (r->intr_gen & F_RSPD_GEN2) == q->gen;
 }
 
+static inline void clear_rspq_bufstate(struct sge_rspq * const q)
+{
+	q->pg_skb = NULL;
+	q->rx_recycle_buf = 0;
+}
+
 #define RSPD_GTS_MASK  (F_RSPD_TXQ0_GTS | F_RSPD_TXQ1_GTS)
 #define RSPD_CTRL_MASK (RSPD_GTS_MASK | \
 			V_RSPD_TXQ0_CR(M_RSPD_TXQ0_CR) | \
@@ -1984,10 +2214,11 @@ static int process_responses(struct adapter *adap, struct sge_qset *qs,
 	q->next_holdoff = q->holdoff_tmr;
 
 	while (likely(budget_left && is_new_response(r, q))) {
-		int eth, ethpad = 2;
+		int packet_complete, eth, ethpad = 2, lro = qs->lro_enabled;
 		struct sk_buff *skb = NULL;
 		u32 len, flags = ntohl(r->flags);
-		__be32 rss_hi = *(const __be32 *)r, rss_lo = r->rss_hdr.rss_hash_val;
+		__be32 rss_hi = *(const __be32 *)r,
+		       rss_lo = r->rss_hdr.rss_hash_val;
 
 		eth = r->rss_hdr.opcode == CPL_RX_PKT;
 
@@ -2015,6 +2246,9 @@ no_mem:
 		} else if ((len = ntohl(r->len_cq)) != 0) {
 			struct sge_fl *fl;
 
+			if (eth)
+				lro = qs->lro_enabled && is_eth_tcp(rss_hi);
+
 			fl = (len & F_RSPD_FLQ) ? &qs->fl[1] : &qs->fl[0];
 			if (fl->use_pages) {
 				void *addr = fl->sdesc[fl->cidx].pg_chunk.va;
@@ -2024,9 +2258,18 @@ no_mem:
 				prefetch(addr + L1_CACHE_BYTES);
 #endif
 				__refill_fl(adap, fl);
+				if (lro > 0) {
+					lro_add_page(adap, qs, fl,
+						     G_RSPD_LEN(len),
+						     flags & F_RSPD_EOP);
+					 goto next_fl;
+				}
 
-				skb = get_packet_pg(adap, fl, G_RSPD_LEN(len),
-						 eth ? SGE_RX_DROP_THRES : 0);
+				skb = get_packet_pg(adap, fl, q,
+						    G_RSPD_LEN(len),
+						    eth ?
+						    SGE_RX_DROP_THRES : 0);
+				q->pg_skb = skb;
 			} else
 				skb = get_packet(adap, fl, G_RSPD_LEN(len),
 						 eth ? SGE_RX_DROP_THRES : 0);
@@ -2036,7 +2279,7 @@ no_mem:
 				q->rx_drops++;
 			} else if (unlikely(r->rss_hdr.opcode == CPL_TRACE_PKT))
 				__skb_pull(skb, 2);
-
+next_fl:
 			if (++fl->cidx == fl->size)
 				fl->cidx = 0;
 		} else
@@ -2060,9 +2303,13 @@ no_mem:
 			q->credits = 0;
 		}
 
-		if (likely(skb != NULL)) {
+		packet_complete = flags &
+				  (F_RSPD_EOP | F_RSPD_IMM_DATA_VALID |
+				   F_RSPD_ASYNC_NOTIF);
+
+		if (skb != NULL && packet_complete) {
 			if (eth)
-				rx_eth(adap, q, skb, ethpad);
+				rx_eth(adap, q, skb, ethpad, lro);
 			else {
 				q->offload_pkts++;
 				/* Preserve the RSS info in csum & priority */
@@ -2072,11 +2319,19 @@ no_mem:
 						       offload_skbs,
 						       ngathered);
 			}
+
+			if (flags & F_RSPD_EOP)
+				clear_rspq_bufstate(q);
 		}
 		--budget_left;
 	}
 
 	deliver_partial_bundle(&adap->tdev, q, offload_skbs, ngathered);
+	lro_flush_all(&qs->lro_mgr);
+	qs->port_stats[SGE_PSTAT_LRO_AGGR] = qs->lro_mgr.stats.aggregated;
+	qs->port_stats[SGE_PSTAT_LRO_FLUSHED] = qs->lro_mgr.stats.flushed;
+	qs->port_stats[SGE_PSTAT_LRO_NO_DESC] = qs->lro_mgr.stats.no_desc;
+
 	if (sleeping)
 		check_ring_db(adap, qs, sleeping);
 
@@ -2618,8 +2873,9 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 		      int irq_vec_idx, const struct qset_params *p,
 		      int ntxq, struct net_device *dev)
 {
-	int i, ret = -ENOMEM;
+	int i, avail, ret = -ENOMEM;
 	struct sge_qset *q = &adapter->sge.qs[id];
+	struct net_lro_mgr *lro_mgr = &q->lro_mgr;
 
 	init_qset_cntxt(q, id);
 	init_timer(&q->tx_reclaim_timer);
@@ -2687,11 +2943,23 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 #else
 	q->fl[0].buf_size = SGE_RX_SM_BUF_SIZE + sizeof(struct cpl_rx_data);
 #endif
-	q->fl[0].use_pages = FL0_PG_CHUNK_SIZE > 0;
+#if FL1_PG_CHUNK_SIZE > 0
+	q->fl[1].buf_size = FL1_PG_CHUNK_SIZE;
+#else
 	q->fl[1].buf_size = is_offload(adapter) ?
 		(16 * 1024) - SKB_DATA_ALIGN(sizeof(struct skb_shared_info)) :
 		MAX_FRAME_SIZE + 2 + sizeof(struct cpl_rx_pkt);
+#endif
 
+	q->fl[0].use_pages = FL0_PG_CHUNK_SIZE > 0;
+	q->fl[1].use_pages = FL1_PG_CHUNK_SIZE > 0;
+	q->fl[0].order = FL0_PG_ORDER;
+	q->fl[1].order = FL1_PG_ORDER;
+
+	q->lro_frag_tbl = kcalloc(MAX_FRAME_SIZE / FL1_PG_CHUNK_SIZE + 1,
+				  sizeof(struct skb_frag_struct),
+				  GFP_KERNEL);
+	q->lro_nfrags = q->lro_frag_len = 0;
 	spin_lock_irq(&adapter->sge.reg_lock);
 
 	/* FL threshold comparison uses < */
@@ -2742,8 +3010,23 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 	q->netdev = dev;
 	t3_update_qset_coalesce(q, p);
 
-	refill_fl(adapter, &q->fl[0], q->fl[0].size, GFP_KERNEL);
-	refill_fl(adapter, &q->fl[1], q->fl[1].size, GFP_KERNEL);
+	init_lro_mgr(q, lro_mgr);
+
+	avail = refill_fl(adapter, &q->fl[0], q->fl[0].size,
+			  GFP_KERNEL | __GFP_COMP);
+	if (!avail) {
+		CH_ALERT(adapter, "free list queue 0 initialization failed\n");
+		goto err;
+	}
+	if (avail < q->fl[0].size)
+		CH_WARN(adapter, "free list queue 0 enabled with %d credits\n",
+			avail);
+
+	avail = refill_fl(adapter, &q->fl[1], q->fl[1].size,
+			  GFP_KERNEL | __GFP_COMP);
+	if (avail < q->fl[1].size)
+		CH_WARN(adapter, "free list queue 1 enabled with %d credits\n",
+			avail);
 	refill_rspq(adapter, &q->rspq, q->rspq.size - 1);
 
 	t3_write_reg(adapter, A_SG_GTS, V_RSPQ(q->rspq.cntxt_id) |
@@ -2752,9 +3035,9 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 	mod_timer(&q->tx_reclaim_timer, jiffies + TX_RECLAIM_PERIOD);
 	return 0;
 
-      err_unlock:
+err_unlock:
 	spin_unlock_irq(&adapter->sge.reg_lock);
-      err:
+err:
 	t3_free_qset(adapter, q);
 	return ret;
 }
@@ -2876,7 +3159,7 @@ void t3_sge_prep(struct adapter *adap, struct sge_params *p)
 		q->coalesce_usecs = 5;
 		q->rspq_size = 1024;
 		q->fl_size = 1024;
-		q->jumbo_size = 512;
+ 		q->jumbo_size = 512;
 		q->txq_size[TXQ_ETH] = 1024;
 		q->txq_size[TXQ_OFLD] = 1024;
 		q->txq_size[TXQ_CTRL] = 256;
diff --git a/drivers/net/cxgb3/t3_cpl.h b/drivers/net/cxgb3/t3_cpl.h
index b7a1a31..a666c5d 100644
--- a/drivers/net/cxgb3/t3_cpl.h
+++ b/drivers/net/cxgb3/t3_cpl.h
@@ -174,6 +174,13 @@ enum {				/* TCP congestion control algorithms */
 	CONG_ALG_HIGHSPEED
 };
 
+enum {			/* RSS hash type */
+	RSS_HASH_NONE = 0,
+	RSS_HASH_2_TUPLE = 1,
+	RSS_HASH_4_TUPLE = 2,
+	RSS_HASH_TCPV6 = 3
+};
+
 union opcode_tid {
 	__be32 opcode_tid;
 	__u8 opcode;
@@ -184,6 +191,10 @@ union opcode_tid {
 #define G_OPCODE(x) (((x) >> S_OPCODE) & 0xFF)
 #define G_TID(x)    ((x) & 0xFFFFFF)
 
+#define S_HASHTYPE 22
+#define M_HASHTYPE 0x3
+#define G_HASHTYPE(x) (((x) >> S_HASHTYPE) & M_HASHTYPE)
+
 /* tid is assumed to be 24-bits */
 #define MK_OPCODE_TID(opcode, tid) (V_OPCODE(opcode) | (tid))
 
diff --git a/drivers/net/dl2k.c b/drivers/net/dl2k.c
index e233d04..8277e89 100644
--- a/drivers/net/dl2k.c
+++ b/drivers/net/dl2k.c
@@ -499,7 +499,7 @@ rio_timer (unsigned long data)
 			entry = np->old_rx % RX_RING_SIZE;
 			/* Dropped packets don't need to re-allocate */
 			if (np->rx_skbuff[entry] == NULL) {
-				skb = dev_alloc_skb (np->rx_buf_sz);
+				skb = netdev_alloc_skb (dev, np->rx_buf_sz);
 				if (skb == NULL) {
 					np->rx_ring[entry].fraginfo = 0;
 					printk (KERN_INFO
@@ -570,7 +570,7 @@ alloc_list (struct net_device *dev)
 	/* Allocate the rx buffers */
 	for (i = 0; i < RX_RING_SIZE; i++) {
 		/* Allocated fixed size of skbuff */
-		struct sk_buff *skb = dev_alloc_skb (np->rx_buf_sz);
+		struct sk_buff *skb = netdev_alloc_skb (dev, np->rx_buf_sz);
 		np->rx_skbuff[i] = skb;
 		if (skb == NULL) {
 			printk (KERN_ERR
@@ -867,7 +867,7 @@ receive_packet (struct net_device *dev)
 						  PCI_DMA_FROMDEVICE);
 				skb_put (skb = np->rx_skbuff[entry], pkt_len);
 				np->rx_skbuff[entry] = NULL;
-			} else if ((skb = dev_alloc_skb (pkt_len + 2)) != NULL) {
+			} else if ((skb = netdev_alloc_skb(dev, pkt_len + 2))) {
 				pci_dma_sync_single_for_cpu(np->pdev,
 							    desc_to_dma(desc),
 							    np->rx_buf_sz,
@@ -904,7 +904,7 @@ receive_packet (struct net_device *dev)
 		struct sk_buff *skb;
 		/* Dropped packets don't need to re-allocate */
 		if (np->rx_skbuff[entry] == NULL) {
-			skb = dev_alloc_skb (np->rx_buf_sz);
+			skb = netdev_alloc_skb(dev, np->rx_buf_sz);
 			if (skb == NULL) {
 				np->rx_ring[entry].fraginfo = 0;
 				printk (KERN_INFO
diff --git a/drivers/net/hamachi.c b/drivers/net/hamachi.c
index e5c2380..3199526 100644
--- a/drivers/net/hamachi.c
+++ b/drivers/net/hamachi.c
@@ -1140,11 +1140,11 @@ static void hamachi_tx_timeout(struct net_device *dev)
 	}
 	/* Fill in the Rx buffers.  Handle allocation failure gracefully. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
-		struct sk_buff *skb = dev_alloc_skb(hmp->rx_buf_sz);
+		struct sk_buff *skb = netdev_alloc_skb(dev, hmp->rx_buf_sz);
 		hmp->rx_skbuff[i] = skb;
 		if (skb == NULL)
 			break;
-		skb->dev = dev;         /* Mark as being used by this device. */
+
 		skb_reserve(skb, 2); /* 16 byte align the IP header. */
                 hmp->rx_ring[i].addr = cpu_to_leXX(pci_map_single(hmp->pci_dev,
 			skb->data, hmp->rx_buf_sz, PCI_DMA_FROMDEVICE));
@@ -1178,14 +1178,6 @@ static void hamachi_init_ring(struct net_device *dev)
 	hmp->cur_rx = hmp->cur_tx = 0;
 	hmp->dirty_rx = hmp->dirty_tx = 0;
 
-#if 0
-	/* This is wrong.  I'm not sure what the original plan was, but this
-	 * is wrong.  An MTU of 1 gets you a buffer of 1536, while an MTU
-	 * of 1501 gets a buffer of 1533? -KDU
-	 */
-	hmp->rx_buf_sz = (dev->mtu <= 1500 ? PKT_BUF_SZ : dev->mtu + 32);
-#endif
-	/* My attempt at a reasonable correction */
 	/* +26 gets the maximum ethernet encapsulation, +7 & ~7 because the
 	 * card needs room to do 8 byte alignment, +2 so we can reserve
 	 * the first 2 bytes, and +16 gets room for the status word from the
diff --git a/drivers/net/ixp2000/ixpdev.c b/drivers/net/ixp2000/ixpdev.c
index 484cb2b..7111c65 100644
--- a/drivers/net/ixp2000/ixpdev.c
+++ b/drivers/net/ixp2000/ixpdev.c
@@ -108,14 +108,14 @@ static int ixpdev_rx(struct net_device *dev, int processed, int budget)
 		if (unlikely(!netif_running(nds[desc->channel])))
 			goto err;
 
-		skb = dev_alloc_skb(desc->pkt_length + 2);
+		skb = netdev_alloc_skb(dev, desc->pkt_length + 2);
 		if (likely(skb != NULL)) {
 			skb_reserve(skb, 2);
 			skb_copy_to_linear_data(skb, buf, desc->pkt_length);
 			skb_put(skb, desc->pkt_length);
 			skb->protocol = eth_type_trans(skb, nds[desc->channel]);
 
-			skb->dev->last_rx = jiffies;
+			dev->last_rx = jiffies;
 
 			netif_receive_skb(skb);
 		}
diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 6bf9e76..35b4319 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -53,7 +53,8 @@ config SMSC_PHY
 config BROADCOM_PHY
 	tristate "Drivers for Broadcom PHYs"
 	---help---
-	  Currently supports the BCM5411, BCM5421 and BCM5461 PHYs.
+	  Currently supports the BCM5411, BCM5421, BCM5461, BCM5464, BCM5481
+	  and BCM5482 PHYs.
 
 config ICPLUS_PHY
 	tristate "Drivers for ICPlus PHYs"
diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 60c5cfe..4b4dc98 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -24,6 +24,12 @@
 #define MII_BCM54XX_ESR		0x11	/* BCM54xx extended status register */
 #define MII_BCM54XX_ESR_IS	0x1000	/* Interrupt status */
 
+#define MII_BCM54XX_EXP_DATA	0x15	/* Expansion register data */
+#define MII_BCM54XX_EXP_SEL	0x17	/* Expansion register select */
+#define MII_BCM54XX_EXP_SEL_SSD	0x0e00	/* Secondary SerDes select */
+#define MII_BCM54XX_EXP_SEL_ER	0x0f00	/* Expansion register select */
+
+#define MII_BCM54XX_AUX_CTL	0x18	/* Auxiliary control register */
 #define MII_BCM54XX_ISR		0x1a	/* BCM54xx interrupt status register */
 #define MII_BCM54XX_IMR		0x1b	/* BCM54xx interrupt mask register */
 #define MII_BCM54XX_INT_CRCERR	0x0001	/* CRC error */
@@ -42,10 +48,120 @@
 #define MII_BCM54XX_INT_MDIX	0x2000	/* MDIX status change */
 #define MII_BCM54XX_INT_PSERR	0x4000	/* Pair swap error */
 
+#define MII_BCM54XX_SHD		0x1c	/* 0x1c shadow registers */
+#define MII_BCM54XX_SHD_WRITE	0x8000
+#define MII_BCM54XX_SHD_VAL(x)	((x & 0x1f) << 10)
+#define MII_BCM54XX_SHD_DATA(x)	((x & 0x3ff) << 0)
+
+/*
+ * Broadcom LED source encodings.  These are used in BCM5461, BCM5481,
+ * BCM5482, and possibly some others.
+ */
+#define BCM_LED_SRC_LINKSPD1	0x0
+#define BCM_LED_SRC_LINKSPD2	0x1
+#define BCM_LED_SRC_XMITLED	0x2
+#define BCM_LED_SRC_ACTIVITYLED	0x3
+#define BCM_LED_SRC_FDXLED	0x4
+#define BCM_LED_SRC_SLAVE	0x5
+#define BCM_LED_SRC_INTR	0x6
+#define BCM_LED_SRC_QUALITY	0x7
+#define BCM_LED_SRC_RCVLED	0x8
+#define BCM_LED_SRC_MULTICOLOR1	0xa
+#define BCM_LED_SRC_OPENSHORT	0xb
+#define BCM_LED_SRC_OFF		0xe	/* Tied high */
+#define BCM_LED_SRC_ON		0xf	/* Tied low */
+
+/*
+ * BCM5482: Shadow registers
+ * Shadow values go into bits [14:10] of register 0x1c to select a shadow
+ * register to access.
+ */
+#define BCM5482_SHD_LEDS1	0x0d	/* 01101: LED Selector 1 */
+					/* LED3 / ~LINKSPD[2] selector */
+#define BCM5482_SHD_LEDS1_LED3(src)	((src & 0xf) << 4)
+					/* LED1 / ~LINKSPD[1] selector */
+#define BCM5482_SHD_LEDS1_LED1(src)	((src & 0xf) << 0)
+#define BCM5482_SHD_SSD		0x14	/* 10100: Secondary SerDes control */
+#define BCM5482_SHD_SSD_LEDM	0x0008	/* SSD LED Mode enable */
+#define BCM5482_SHD_SSD_EN	0x0001	/* SSD enable */
+#define BCM5482_SHD_MODE	0x1f	/* 11111: Mode Control Register */
+#define BCM5482_SHD_MODE_1000BX	0x0001	/* Enable 1000BASE-X registers */
+
+/*
+ * BCM5482: Secondary SerDes registers
+ */
+#define BCM5482_SSD_1000BX_CTL		0x00	/* 1000BASE-X Control */
+#define BCM5482_SSD_1000BX_CTL_PWRDOWN	0x0800	/* Power-down SSD */
+#define BCM5482_SSD_SGMII_SLAVE		0x15	/* SGMII Slave Register */
+#define BCM5482_SSD_SGMII_SLAVE_EN	0x0002	/* Slave mode enable */
+#define BCM5482_SSD_SGMII_SLAVE_AD	0x0001	/* Slave auto-detection */
+
+/*
+ * Device flags for PHYs that can be configured for different operating
+ * modes.
+ */
+#define PHY_BCM_FLAGS_VALID		0x80000000
+#define PHY_BCM_FLAGS_INTF_XAUI		0x00000020
+#define PHY_BCM_FLAGS_INTF_SGMII	0x00000010
+#define PHY_BCM_FLAGS_MODE_1000BX	0x00000002
+#define PHY_BCM_FLAGS_MODE_COPPER	0x00000001
+
 MODULE_DESCRIPTION("Broadcom PHY driver");
 MODULE_AUTHOR("Maciej W. Rozycki");
 MODULE_LICENSE("GPL");
 
+/*
+ * Indirect register access functions for the 1000BASE-T/100BASE-TX/10BASE-T
+ * 0x1c shadow registers.
+ */
+static int bcm54xx_shadow_read(struct phy_device *phydev, u16 shadow)
+{
+	phy_write(phydev, MII_BCM54XX_SHD, MII_BCM54XX_SHD_VAL(shadow));
+	return MII_BCM54XX_SHD_DATA(phy_read(phydev, MII_BCM54XX_SHD));
+}
+
+static int bcm54xx_shadow_write(struct phy_device *phydev, u16 shadow, u16 val)
+{
+	return phy_write(phydev, MII_BCM54XX_SHD,
+			 MII_BCM54XX_SHD_WRITE |
+			 MII_BCM54XX_SHD_VAL(shadow) |
+			 MII_BCM54XX_SHD_DATA(val));
+}
+
+/*
+ * Indirect register access functions for the Expansion Registers
+ * and Secondary SerDes registers (when sec_serdes=1).
+ */
+static int bcm54xx_exp_read(struct phy_device *phydev,
+			    int sec_serdes, u8 regnum)
+{
+	int val;
+
+	phy_write(phydev, MII_BCM54XX_EXP_SEL,
+		  (sec_serdes ? MII_BCM54XX_EXP_SEL_SSD :
+				MII_BCM54XX_EXP_SEL_ER) |
+		  regnum);
+	val = phy_read(phydev, MII_BCM54XX_EXP_DATA);
+	phy_write(phydev, MII_BCM54XX_EXP_SEL, regnum);
+
+	return val;
+}
+
+static int bcm54xx_exp_write(struct phy_device *phydev,
+			     int sec_serdes, u8 regnum, u16 val)
+{
+	int ret;
+
+	phy_write(phydev, MII_BCM54XX_EXP_SEL,
+		  (sec_serdes ? MII_BCM54XX_EXP_SEL_SSD :
+				MII_BCM54XX_EXP_SEL_ER) |
+		  regnum);
+	ret = phy_write(phydev, MII_BCM54XX_EXP_DATA, val);
+	phy_write(phydev, MII_BCM54XX_EXP_SEL, regnum);
+
+	return ret;
+}
+
 static int bcm54xx_config_init(struct phy_device *phydev)
 {
 	int reg, err;
@@ -70,6 +186,87 @@ static int bcm54xx_config_init(struct phy_device *phydev)
 	return 0;
 }
 
+static int bcm5482_config_init(struct phy_device *phydev)
+{
+	int err, reg;
+
+	err = bcm54xx_config_init(phydev);
+
+	if (phydev->dev_flags & PHY_BCM_FLAGS_MODE_1000BX) {
+		/*
+		 * Enable secondary SerDes and its use as an LED source
+		 */
+		reg = bcm54xx_shadow_read(phydev, BCM5482_SHD_SSD);
+		bcm54xx_shadow_write(phydev, BCM5482_SHD_SSD,
+				     reg |
+				     BCM5482_SHD_SSD_LEDM |
+				     BCM5482_SHD_SSD_EN);
+
+		/*
+		 * Enable SGMII slave mode and auto-detection
+		 */
+		reg = bcm54xx_exp_read(phydev, 1, BCM5482_SSD_SGMII_SLAVE);
+		bcm54xx_exp_write(phydev, 1, BCM5482_SSD_SGMII_SLAVE,
+				  reg |
+				  BCM5482_SSD_SGMII_SLAVE_EN |
+				  BCM5482_SSD_SGMII_SLAVE_AD);
+
+		/*
+		 * Disable secondary SerDes powerdown
+		 */
+		reg = bcm54xx_exp_read(phydev, 1, BCM5482_SSD_1000BX_CTL);
+		bcm54xx_exp_write(phydev, 1, BCM5482_SSD_1000BX_CTL,
+				  reg & ~BCM5482_SSD_1000BX_CTL_PWRDOWN);
+
+		/*
+		 * Select 1000BASE-X register set (primary SerDes)
+		 */
+		reg = bcm54xx_shadow_read(phydev, BCM5482_SHD_MODE);
+		bcm54xx_shadow_write(phydev, BCM5482_SHD_MODE,
+				     reg | BCM5482_SHD_MODE_1000BX);
+
+		/*
+		 * LED1=ACTIVITYLED, LED3=LINKSPD[2]
+		 * (Use LED1 as secondary SerDes ACTIVITY LED)
+		 */
+		bcm54xx_shadow_write(phydev, BCM5482_SHD_LEDS1,
+			BCM5482_SHD_LEDS1_LED1(BCM_LED_SRC_ACTIVITYLED) |
+			BCM5482_SHD_LEDS1_LED3(BCM_LED_SRC_LINKSPD2));
+
+		/*
+		 * Auto-negotiation doesn't seem to work quite right
+		 * in this mode, so we disable it and force it to the
+		 * right speed/duplex setting.  Only 'link status'
+		 * is important.
+		 */
+		phydev->autoneg = AUTONEG_DISABLE;
+		phydev->speed = SPEED_1000;
+		phydev->duplex = DUPLEX_FULL;
+	}
+
+	return err;
+}
+
+static int bcm5482_read_status(struct phy_device *phydev)
+{
+	int err;
+
+	err = genphy_read_status(phydev);
+
+	if (phydev->dev_flags & PHY_BCM_FLAGS_MODE_1000BX) {
+		/*
+		 * Only link status matters for 1000Base-X mode, so force
+		 * 1000 Mbit/s full-duplex status
+		 */
+		if (phydev->link) {
+			phydev->speed = SPEED_1000;
+			phydev->duplex = DUPLEX_FULL;
+		}
+	}
+
+	return err;
+}
+
 static int bcm54xx_ack_interrupt(struct phy_device *phydev)
 {
 	int reg;
@@ -210,9 +407,9 @@ static struct phy_driver bcm5482_driver = {
 	.name		= "Broadcom BCM5482",
 	.features	= PHY_GBIT_FEATURES,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
-	.config_init	= bcm54xx_config_init,
+	.config_init	= bcm5482_config_init,
 	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
+	.read_status	= bcm5482_read_status,
 	.ack_interrupt	= bcm54xx_ack_interrupt,
 	.config_intr	= bcm54xx_config_intr,
 	.driver 	= { .owner = THIS_MODULE },
diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index 2951990..fe41e4e 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -179,8 +179,7 @@ enum sbmac_state {
 #define SBMAC_MAX_TXDESCR	256
 #define SBMAC_MAX_RXDESCR	256
 
-#define ETHER_ALIGN	2
-#define ETHER_ADDR_LEN	6
+#define ETHER_ADDR_LEN		6
 #define ENET_PACKET_SIZE	1518
 /*#define ENET_PACKET_SIZE	9216 */
 
@@ -262,8 +261,6 @@ struct sbmac_softc {
 	spinlock_t		sbm_lock;	/* spin lock */
 	int			sbm_devflags;	/* current device flags */
 
-	int			sbm_buffersize;
-
 	/*
 	 * Controller-specific things
 	 */
@@ -305,10 +302,11 @@ struct sbmac_softc {
 static void sbdma_initctx(struct sbmacdma *d, struct sbmac_softc *s, int chan,
 			  int txrx, int maxdescr);
 static void sbdma_channel_start(struct sbmacdma *d, int rxtx);
-static int sbdma_add_rcvbuffer(struct sbmacdma *d, struct sk_buff *m);
+static int sbdma_add_rcvbuffer(struct sbmac_softc *sc, struct sbmacdma *d,
+			       struct sk_buff *m);
 static int sbdma_add_txbuffer(struct sbmacdma *d, struct sk_buff *m);
 static void sbdma_emptyring(struct sbmacdma *d);
-static void sbdma_fillring(struct sbmacdma *d);
+static void sbdma_fillring(struct sbmac_softc *sc, struct sbmacdma *d);
 static int sbdma_rx_process(struct sbmac_softc *sc, struct sbmacdma *d,
 			    int work_to_do, int poll);
 static void sbdma_tx_process(struct sbmac_softc *sc, struct sbmacdma *d,
@@ -777,16 +775,13 @@ static void sbdma_channel_stop(struct sbmacdma *d)
 	d->sbdma_remptr = NULL;
 }
 
-static void sbdma_align_skb(struct sk_buff *skb,int power2,int offset)
+static inline void sbdma_align_skb(struct sk_buff *skb,
+				   unsigned int power2, unsigned int offset)
 {
-	unsigned long addr;
-	unsigned long newaddr;
-
-	addr = (unsigned long) skb->data;
-
-	newaddr = (addr + power2 - 1) & ~(power2 - 1);
+	unsigned char *addr = skb->data;
+	unsigned char *newaddr = PTR_ALIGN(addr, power2);
 
-	skb_reserve(skb,newaddr-addr+offset);
+	skb_reserve(skb, newaddr - addr + offset);
 }
 
 
@@ -797,7 +792,8 @@ static void sbdma_align_skb(struct sk_buff *skb,int power2,int offset)
  *  this queues a buffer for inbound packets.
  *
  *  Input parameters:
- *  	   d - DMA channel descriptor
+ *	   sc - softc structure
+ *  	    d - DMA channel descriptor
  * 	   sb - sk_buff to add, or NULL if we should allocate one
  *
  *  Return value:
@@ -806,8 +802,10 @@ static void sbdma_align_skb(struct sk_buff *skb,int power2,int offset)
  ********************************************************************* */
 
 
-static int sbdma_add_rcvbuffer(struct sbmacdma *d, struct sk_buff *sb)
+static int sbdma_add_rcvbuffer(struct sbmac_softc *sc, struct sbmacdma *d,
+			       struct sk_buff *sb)
 {
+	struct net_device *dev = sc->sbm_dev;
 	struct sbdmadscr *dsc;
 	struct sbdmadscr *nextdsc;
 	struct sk_buff *sb_new = NULL;
@@ -848,14 +846,16 @@ static int sbdma_add_rcvbuffer(struct sbmacdma *d, struct sk_buff *sb)
 	 */
 
 	if (sb == NULL) {
-		sb_new = dev_alloc_skb(ENET_PACKET_SIZE + SMP_CACHE_BYTES * 2 + ETHER_ALIGN);
+		sb_new = netdev_alloc_skb(dev, ENET_PACKET_SIZE +
+					       SMP_CACHE_BYTES * 2 +
+					       NET_IP_ALIGN);
 		if (sb_new == NULL) {
 			pr_info("%s: sk_buff allocation failed\n",
 			       d->sbdma_eth->sbm_dev->name);
 			return -ENOBUFS;
 		}
 
-		sbdma_align_skb(sb_new, SMP_CACHE_BYTES, ETHER_ALIGN);
+		sbdma_align_skb(sb_new, SMP_CACHE_BYTES, NET_IP_ALIGN);
 	}
 	else {
 		sb_new = sb;
@@ -874,10 +874,10 @@ static int sbdma_add_rcvbuffer(struct sbmacdma *d, struct sk_buff *sb)
 	 * Do not interrupt per DMA transfer.
 	 */
 	dsc->dscr_a = virt_to_phys(sb_new->data) |
-		V_DMA_DSCRA_A_SIZE(NUMCACHEBLKS(pktsize+ETHER_ALIGN)) | 0;
+		V_DMA_DSCRA_A_SIZE(NUMCACHEBLKS(pktsize + NET_IP_ALIGN)) | 0;
 #else
 	dsc->dscr_a = virt_to_phys(sb_new->data) |
-		V_DMA_DSCRA_A_SIZE(NUMCACHEBLKS(pktsize+ETHER_ALIGN)) |
+		V_DMA_DSCRA_A_SIZE(NUMCACHEBLKS(pktsize + NET_IP_ALIGN)) |
 		M_DMA_DSCRA_INTERRUPT;
 #endif
 
@@ -1032,18 +1032,19 @@ static void sbdma_emptyring(struct sbmacdma *d)
  *  with sk_buffs
  *
  *  Input parameters:
- *  	   d - DMA channel
+ *	   sc - softc structure
+ *  	    d - DMA channel
  *
  *  Return value:
  *  	   nothing
  ********************************************************************* */
 
-static void sbdma_fillring(struct sbmacdma *d)
+static void sbdma_fillring(struct sbmac_softc *sc, struct sbmacdma *d)
 {
 	int idx;
 
-	for (idx = 0; idx < SBMAC_MAX_RXDESCR-1; idx++) {
-		if (sbdma_add_rcvbuffer(d,NULL) != 0)
+	for (idx = 0; idx < SBMAC_MAX_RXDESCR - 1; idx++) {
+		if (sbdma_add_rcvbuffer(sc, d, NULL) != 0)
 			break;
 	}
 }
@@ -1159,10 +1160,11 @@ again:
 			 * packet and put it right back on the receive ring.
 			 */
 
-			if (unlikely (sbdma_add_rcvbuffer(d,NULL) ==
-				      -ENOBUFS)) {
+			if (unlikely(sbdma_add_rcvbuffer(sc, d, NULL) ==
+				     -ENOBUFS)) {
 				dev->stats.rx_dropped++;
-				sbdma_add_rcvbuffer(d,sb); /* re-add old buffer */
+				/* Re-add old buffer */
+				sbdma_add_rcvbuffer(sc, d, sb);
 				/* No point in continuing at the moment */
 				printk(KERN_ERR "dropped packet (1)\n");
 				d->sbdma_remptr = SBDMA_NEXTBUF(d,sbdma_remptr);
@@ -1212,7 +1214,7 @@ again:
 			 * put it back on the receive ring.
 			 */
 			dev->stats.rx_errors++;
-			sbdma_add_rcvbuffer(d,sb);
+			sbdma_add_rcvbuffer(sc, d, sb);
 		}
 
 
@@ -1570,7 +1572,7 @@ static void sbmac_channel_start(struct sbmac_softc *s)
 	 * Fill the receive ring
 	 */
 
-	sbdma_fillring(&(s->sbm_rxdma));
+	sbdma_fillring(s, &(s->sbm_rxdma));
 
 	/*
 	 * Turn on the rest of the bits in the enable register
@@ -2312,13 +2314,6 @@ static int sbmac_init(struct platform_device *pldev, long long base)
 		dev->dev_addr[i] = eaddr[i];
 	}
 
-
-	/*
-	 * Init packet size
-	 */
-
-	sc->sbm_buffersize = ENET_PACKET_SIZE + SMP_CACHE_BYTES * 2 + ETHER_ALIGN;
-
 	/*
 	 * Initialize context (get pointers to registers and stuff), then
 	 * allocate the memory for the descriptor tables.
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 07b3f77..ae11c67 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1480,7 +1480,7 @@ static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
 		       "requested.\n",
 		       tp->dev->name, state);
 		return -EINVAL;
-	};
+	}
 
 	power_control |= PCI_PM_CTRL_PME_ENABLE;
 
@@ -1906,7 +1906,7 @@ static void tg3_aux_stat_to_speed_duplex(struct tg3 *tp, u32 val, u16 *speed, u8
 		*speed = SPEED_INVALID;
 		*duplex = DUPLEX_INVALID;
 		break;
-	};
+	}
 }
 
 static void tg3_phy_copper_begin(struct tg3 *tp)
@@ -2018,7 +2018,7 @@ static void tg3_phy_copper_begin(struct tg3 *tp)
 		case SPEED_1000:
 			bmcr |= TG3_BMCR_SPEED1000;
 			break;
-		};
+		}
 
 		if (tp->link_config.duplex == DUPLEX_FULL)
 			bmcr |= BMCR_FULLDPLX;
@@ -2716,7 +2716,7 @@ static int tg3_fiber_aneg_smachine(struct tg3 *tp,
 	default:
 		ret = ANEG_FAILED;
 		break;
-	};
+	}
 
 	return ret;
 }
@@ -3558,7 +3558,7 @@ static int tg3_alloc_rx_skb(struct tg3 *tp, u32 opaque_key,
 
 	default:
 		return -EINVAL;
-	};
+	}
 
 	/* Do not overwrite any of the map or rp information
 	 * until we are sure we can commit to a new buffer.
@@ -3618,7 +3618,7 @@ static void tg3_recycle_rx(struct tg3 *tp, u32 opaque_key,
 
 	default:
 		return;
-	};
+	}
 
 	dest_map->skb = src_map->skb;
 	pci_unmap_addr_set(dest_map, mapping,
@@ -4961,7 +4961,7 @@ static int tg3_stop_block(struct tg3 *tp, unsigned long ofs, u32 enable_bit, int
 
 		default:
 			break;
-		};
+		}
 	}
 
 	val = tr32(ofs);
@@ -5203,7 +5203,7 @@ static void tg3_write_sig_pre_reset(struct tg3 *tp, int kind)
 
 		default:
 			break;
-		};
+		}
 	}
 
 	if (kind == RESET_KIND_INIT ||
@@ -5228,7 +5228,7 @@ static void tg3_write_sig_post_reset(struct tg3 *tp, int kind)
 
 		default:
 			break;
-		};
+		}
 	}
 
 	if (kind == RESET_KIND_SHUTDOWN)
@@ -5257,7 +5257,7 @@ static void tg3_write_sig_legacy(struct tg3 *tp, int kind)
 
 		default:
 			break;
-		};
+		}
 	}
 }
 
@@ -7282,7 +7282,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 
 	default:
 		break;
-	};
+	}
 
 	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_APE)
 		/* Write our heartbeat update interval to APE. */
@@ -10879,7 +10879,7 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 						 LED_CTRL_MODE_PHY_2);
 			break;
 
-		};
+		}
 
 		if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5700 ||
 		     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701) &&
@@ -12178,7 +12178,7 @@ static u32 __devinit tg3_calc_dma_bndry(struct tg3 *tp, u32 val)
 			val |= (DMA_RWCTRL_READ_BNDRY_384_PCIX |
 				DMA_RWCTRL_WRITE_BNDRY_384_PCIX);
 			break;
-		};
+		}
 	} else if (tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) {
 		switch (cacheline_size) {
 		case 16:
@@ -12195,7 +12195,7 @@ static u32 __devinit tg3_calc_dma_bndry(struct tg3 *tp, u32 val)
 			val &= ~DMA_RWCTRL_WRITE_BNDRY_DISAB_PCIE;
 			val |= DMA_RWCTRL_WRITE_BNDRY_128_PCIE;
 			break;
-		};
+		}
 	} else {
 		switch (cacheline_size) {
 		case 16:
@@ -12239,7 +12239,7 @@ static u32 __devinit tg3_calc_dma_bndry(struct tg3 *tp, u32 val)
 			val |= (DMA_RWCTRL_READ_BNDRY_1024 |
 				DMA_RWCTRL_WRITE_BNDRY_1024);
 			break;
-		};
+		}
 	}
 
 out:
@@ -12599,7 +12599,7 @@ static char * __devinit tg3_phy_string(struct tg3 *tp)
 	case PHY_ID_BCM8002:	return "8002/serdes";
 	case 0:			return "serdes";
 	default:		return "unknown";
-	};
+	}
 }
 
 static char * __devinit tg3_bus_string(struct tg3 *tp, char *str)
diff --git a/drivers/net/usb/catc.c b/drivers/net/usb/catc.c
index 76752d8..22c17bb 100644
--- a/drivers/net/usb/catc.c
+++ b/drivers/net/usb/catc.c
@@ -423,7 +423,10 @@ static int catc_hard_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 	catc->tx_ptr = (((catc->tx_ptr - 1) >> 6) + 1) << 6;
 	tx_buf = catc->tx_buf[catc->tx_idx] + catc->tx_ptr;
-	*((u16*)tx_buf) = (catc->is_f5u011) ? cpu_to_be16((u16)skb->len) : cpu_to_le16((u16)skb->len);
+	if (catc->is_f5u011)
+		*(__be16 *)tx_buf = cpu_to_be16(skb->len);
+	else
+		*(__le16 *)tx_buf = cpu_to_le16(skb->len);
 	skb_copy_from_linear_data(skb, tx_buf + 2, skb->len);
 	catc->tx_ptr += skb->len + 2;
 
diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index 21a7785..3969b7a 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -283,8 +283,8 @@ generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf, int flags)
 		struct rndis_set_c	*set_c;
 		struct rndis_halt	*halt;
 	} u;
-	u32			tmp, phym_unspec;
-	__le32			*phym;
+	u32			tmp;
+	__le32			phym_unspec, *phym;
 	int			reply_len;
 	unsigned char		*bp;
 
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 6b8d882..bcbf2fa 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1495,24 +1495,18 @@ static inline void velocity_rx_csum(struct rx_desc *rd, struct sk_buff *skb)
  *	enough. This function returns a negative value if the received
  *	packet is too big or if memory is exhausted.
  */
-static inline int velocity_rx_copy(struct sk_buff **rx_skb, int pkt_size,
-				   struct velocity_info *vptr)
+static int velocity_rx_copy(struct sk_buff **rx_skb, int pkt_size,
+			    struct velocity_info *vptr)
 {
 	int ret = -1;
-
 	if (pkt_size < rx_copybreak) {
 		struct sk_buff *new_skb;
 
-		new_skb = dev_alloc_skb(pkt_size + 2);
+		new_skb = netdev_alloc_skb(vptr->dev, pkt_size + 2);
 		if (new_skb) {
-			new_skb->dev = vptr->dev;
 			new_skb->ip_summed = rx_skb[0]->ip_summed;
-
-			if (vptr->flags & VELOCITY_FLAGS_IP_ALIGN)
-				skb_reserve(new_skb, 2);
-
-			skb_copy_from_linear_data(rx_skb[0], new_skb->data,
-						  pkt_size);
+			skb_reserve(new_skb, 2);
+			skb_copy_from_linear_data(*rx_skb, new_skb->data, pkt_size);
 			*rx_skb = new_skb;
 			ret = 0;
 		}
@@ -1533,12 +1527,8 @@ static inline int velocity_rx_copy(struct sk_buff **rx_skb, int pkt_size,
 static inline void velocity_iph_realign(struct velocity_info *vptr,
 					struct sk_buff *skb, int pkt_size)
 {
-	/* FIXME - memmove ? */
 	if (vptr->flags & VELOCITY_FLAGS_IP_ALIGN) {
-		int i;
-
-		for (i = pkt_size; i >= 0; i--)
-			*(skb->data + i + 2) = *(skb->data + i);
+		memmove(skb->data + 2, skb->data, pkt_size);
 		skb_reserve(skb, 2);
 	}
 }
@@ -1629,7 +1619,7 @@ static int velocity_alloc_rx_buf(struct velocity_info *vptr, int idx)
 	struct rx_desc *rd = &(vptr->rd_ring[idx]);
 	struct velocity_rd_info *rd_info = &(vptr->rd_info[idx]);
 
-	rd_info->skb = dev_alloc_skb(vptr->rx_buf_sz + 64);
+	rd_info->skb = netdev_alloc_skb(vptr->dev, vptr->rx_buf_sz + 64);
 	if (rd_info->skb == NULL)
 		return -ENOMEM;
 
@@ -1638,7 +1628,6 @@ static int velocity_alloc_rx_buf(struct velocity_info *vptr, int idx)
 	 *	64byte alignment.
 	 */
 	skb_reserve(rd_info->skb, (unsigned long) rd_info->skb->data & 63);
-	rd_info->skb->dev = vptr->dev;
 	rd_info->skb_dma = pci_map_single(vptr->pdev, rd_info->skb->data, vptr->rx_buf_sz, PCI_DMA_FROMDEVICE);
 
 	/*
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index 0c73673..c99d4a4 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -807,7 +807,7 @@ void zd_process_intr(struct work_struct *work)
 	u16 int_status;
 	struct zd_mac *mac = container_of(work, struct zd_mac, process_intr);
 
-	int_status = le16_to_cpu(*(u16 *)(mac->intr_buffer+4));
+	int_status = le16_to_cpu(*(__le16 *)(mac->intr_buffer+4));
 	if (int_status & INT_CFG_NEXT_BCN) {
 		if (net_ratelimit())
 			dev_dbg_f(zd_mac_dev(mac), "INT_CFG_NEXT_BCN\n");
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index 12e24f0..8941f5e 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -342,7 +342,7 @@ static inline void handle_regs_int(struct urb *urb)
 	ZD_ASSERT(in_interrupt());
 	spin_lock(&intr->lock);
 
-	int_num = le16_to_cpu(*(u16 *)(urb->transfer_buffer+2));
+	int_num = le16_to_cpu(*(__le16 *)(urb->transfer_buffer+2));
 	if (int_num == CR_INTERRUPT) {
 		struct zd_mac *mac = zd_hw_mac(zd_usb_to_hw(urb->context));
 		memcpy(&mac->intr_buffer, urb->transfer_buffer,
