From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 1/3] [bonding 2.4] Save parameters in a per-bond data structure
Date: Mon, 5 Jan 2004 17:26:26 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401051726.33613.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Jeff Garzik" <jgarzik@pobox.com>, "Jay Vosburgh" <fubar@us.ibm.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

- Save the bonding parameters in a per-bond data structure.
- Move all handling of the insmod parameters to bond_check_params().
- Fix the handling of some warning messages regarding parameter use.


diff -Nuarp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Mon Jan  5 17:05:01 2004
+++ b/drivers/net/bonding/bond_main.c	Mon Jan  5 17:05:02 2004
@@ -509,7 +509,6 @@
 /* monitor all links that often (in milliseconds). <=0 disables monitoring */
 #define BOND_LINK_MON_INTERV	0
 #define BOND_LINK_ARP_INTERV	0
-#define MAX_ARP_IP_TARGETS	16
 
 static int max_bonds	= BOND_DEFAULT_MAX_BONDS;
 static int miimon	= BOND_LINK_MON_INTERV;
@@ -520,7 +519,7 @@ static char *mode	= NULL;
 static char *primary	= NULL;
 static char *lacp_rate	= NULL;
 static int arp_interval = BOND_LINK_ARP_INTERV;
-static char *arp_ip_target[MAX_ARP_IP_TARGETS] = { NULL, };
+static char *arp_ip_target[BOND_MAX_ARP_TARGETS] = { NULL, };
 
 MODULE_PARM(max_bonds, "i");
 MODULE_PARM_DESC(max_bonds, "Max number of bonded devices");
@@ -540,7 +539,7 @@ MODULE_PARM(lacp_rate, "s");
 MODULE_PARM_DESC(lacp_rate, "LACPDU tx rate to request from 802.3ad partner (slow/fast)");
 MODULE_PARM(arp_interval, "i");
 MODULE_PARM_DESC(arp_interval, "arp interval in milliseconds");
-MODULE_PARM(arp_ip_target, "1-" __MODULE_STRING(MAX_ARP_IP_TARGETS) "s");
+MODULE_PARM(arp_ip_target, "1-" __MODULE_STRING(BOND_MAX_ARP_TARGETS) "s");
 MODULE_PARM_DESC(arp_ip_target, "arp targets in n.n.n.n form");
 
 /*----------------------------- Global variables ----------------------------*/
@@ -554,7 +553,7 @@ static LIST_HEAD(bond_dev_list);
 static struct proc_dir_entry *bond_proc_dir = NULL;
 #endif
 
-static u32 arp_target[MAX_ARP_IP_TARGETS] = { 0, } ;
+static u32 arp_target[BOND_MAX_ARP_TARGETS] = { 0, } ;
 static int arp_ip_count	= 0;
 static u32 my_ip	= 0;
 static int bond_mode	= BOND_MODE_ROUNDROBIN;
@@ -590,6 +589,10 @@ static struct bond_parm_tbl bond_mode_tb
 {	NULL,			-1},
 };
 
+/*-------------------------- Forward declarations ---------------------------*/
+
+static inline void bond_set_mode_ops(struct net_device *bond_dev, int mode);
+
 /*---------------------------- General routines -----------------------------*/
 
 static const char *bond_mode_name(void)
@@ -2236,7 +2239,7 @@ static void bond_arp_send_all(struct sla
 {
 	int i;
 
-	for (i = 0; (i<MAX_ARP_IP_TARGETS) && arp_target[i]; i++) {
+	for (i = 0; (i < BOND_MAX_ARP_TARGETS) && arp_target[i]; i++) {
 		arp_send(ARPOP_REQUEST, ETH_P_ARP, arp_target[i], slave->dev,
 			 my_ip, NULL, slave->dev->dev_addr,
 			 NULL);
@@ -3755,13 +3758,47 @@ static int bond_accept_fastpath(struct n
 /*------------------------- Device initialization ---------------------------*/
 
 /*
+ * set bond mode specific net device operations
+ */
+static inline void bond_set_mode_ops(struct net_device *bond_dev, int mode)
+{
+	switch (mode) {
+	case BOND_MODE_ROUNDROBIN:
+		bond_dev->hard_start_xmit = bond_xmit_roundrobin;
+		break;
+	case BOND_MODE_ACTIVEBACKUP:
+		bond_dev->hard_start_xmit = bond_xmit_activebackup;
+		break;
+	case BOND_MODE_XOR:
+		bond_dev->hard_start_xmit = bond_xmit_xor;
+		break;
+	case BOND_MODE_BROADCAST:
+		bond_dev->hard_start_xmit = bond_xmit_broadcast;
+		break;
+	case BOND_MODE_8023AD:
+		bond_dev->hard_start_xmit = bond_3ad_xmit_xor;
+		break;
+	case BOND_MODE_TLB:
+	case BOND_MODE_ALB:
+		bond_dev->hard_start_xmit = bond_alb_xmit;
+		bond_dev->set_mac_address = bond_alb_set_mac_address;
+		break;
+	default:
+		/* Should never happen, mode already checked */
+		printk(KERN_ERR DRV_NAME
+		       ": Error: Unknown bonding mode %d\n",
+		       mode);
+		break;
+	}
+}
+
+/*
  * Does not allocate but creates a /proc entry.
  * Allowed to fail.
  */
-static int __init bond_init(struct net_device *bond_dev)
+static int __init bond_init(struct net_device *bond_dev, struct bond_params *params)
 {
 	struct bonding *bond = bond_dev->priv;
-	int count;
 
 	dprintk("Begin bond_init for %s\n", bond_dev->name);
 
@@ -3769,6 +3806,8 @@ static int __init bond_init(struct net_d
 	rwlock_init(&bond->lock);
 	rwlock_init(&bond->curr_slave_lock);
 
+	bond->params = *params; /* copy params struct */
+
 	/* Initialize pointers */
 	bond->first_slave = NULL;
 	bond->curr_active_slave = NULL;
@@ -3785,33 +3824,7 @@ static int __init bond_init(struct net_d
 	bond_dev->change_mtu = bond_change_mtu;
 	bond_dev->set_mac_address = bond_set_mac_address;
 
-	switch (bond_mode) {
-	case BOND_MODE_ROUNDROBIN:
-		bond_dev->hard_start_xmit = bond_xmit_roundrobin;
-		break;
-	case BOND_MODE_ACTIVEBACKUP:
-		bond_dev->hard_start_xmit = bond_xmit_activebackup;
-		break;
-	case BOND_MODE_XOR:
-		bond_dev->hard_start_xmit = bond_xmit_xor;
-		break;
-	case BOND_MODE_BROADCAST:
-		bond_dev->hard_start_xmit = bond_xmit_broadcast;
-		break;
-	case BOND_MODE_8023AD:
-		bond_dev->hard_start_xmit = bond_3ad_xmit_xor; /* extern */
-		break;
-	case BOND_MODE_TLB:
-	case BOND_MODE_ALB:
-		bond_dev->hard_start_xmit = bond_alb_xmit; /* extern */
-		bond_dev->set_mac_address = bond_alb_set_mac_address; /* extern */
-		break;
-	default:
-		printk(KERN_ERR DRV_NAME
-		       ": Error: Unknown bonding mode %d\n",
-		       bond_mode);
-		return -EINVAL;
-	}
+	bond_set_mode_ops(bond_dev, bond->params.mode);
 
 #ifdef CONFIG_NET_FASTROUTE
 	bond_dev->accept_fastpath = bond_accept_fastpath;
@@ -3821,27 +3834,6 @@ static int __init bond_init(struct net_d
 	bond_dev->tx_queue_len = 0;
 	bond_dev->flags |= IFF_MASTER|IFF_MULTICAST;
 
-	printk(KERN_INFO DRV_NAME ": %s registered with", bond_dev->name);
-	if (miimon) {
-		printk(" MII link monitoring set to %d ms", miimon);
-		updelay /= miimon;
-		downdelay /= miimon;
-	} else {
-		printk("out MII link monitoring");
-	}
-	printk(", in %s mode.\n", bond_mode_name());
-
-	printk(KERN_INFO DRV_NAME ": %s registered with", bond_dev->name);
-	if (arp_interval > 0) {
-		printk(" ARP monitoring set to %d ms with %d target(s):",
-		       arp_interval, arp_ip_count);
-		for (count=0 ; count<arp_ip_count ; count++) {
-			printk(" %s", arp_ip_target[count]);
-		}
-		printk("\n");
-	} else {
-		printk("out ARP monitoring\n");
-	}
 
 #ifdef CONFIG_PROC_FS
 	bond_create_proc_entry(bond);
@@ -3908,7 +3900,7 @@ static inline int bond_parse_parm(char *
 	return -1;
 }
 
-static int bond_check_params(void)
+static int bond_check_params(struct bond_params *params)
 {
 	/*
 	 * Convert string parameters.
@@ -3971,17 +3963,17 @@ static int bond_check_params(void)
 		downdelay = 0;
 	}
 
+	if ((use_carrier != 0) && (use_carrier != 1)) {
+		printk(KERN_WARNING DRV_NAME
+		       ": Warning: use_carrier module parameter (%d), "
+		       "not of valid value (0/1), so it was set to 1\n",
+		       use_carrier);
+		use_carrier = 1;
+	}
+
 	/* reset values for 802.3ad */
 	if (bond_mode == BOND_MODE_8023AD) {
-		if (arp_interval) {
-			printk(KERN_WARNING DRV_NAME
-			       ": Warning: ARP monitoring can't be used "
-			       "simultaneously with 802.3ad, disabling ARP "
-			       "monitoring\n");
-			arp_interval = 0;
-		}
-
-		if (miimon) {
+		if (!miimon) {
 			printk(KERN_WARNING DRV_NAME
 			       ": Warning: miimon must be specified, "
 			       "otherwise bonding will not detect link "
@@ -4040,25 +4032,23 @@ static int bond_check_params(void)
 		}
 
 		if ((updelay % miimon) != 0) {
-			/* updelay will be rounded in bond_init() when it
-			 * is divided by miimon, we just inform user here
-			 */
 			printk(KERN_WARNING DRV_NAME
 			       ": Warning: updelay (%d) is not a multiple "
 			       "of miimon (%d), updelay rounded to %d ms\n",
 			       updelay, miimon, (updelay / miimon) * miimon);
 		}
 
+		updelay /= miimon;
+
 		if ((downdelay % miimon) != 0) {
-			/* downdelay will be rounded in bond_init() when it
-			 * is divided by miimon, we just inform user here
-			 */
 			printk(KERN_WARNING DRV_NAME
 			       ": Warning: downdelay (%d) is not a multiple "
 			       "of miimon (%d), downdelay rounded to %d ms\n",
 			       downdelay, miimon,
 			       (downdelay / miimon) * miimon);
 		}
+
+		downdelay /= miimon;
 	}
 
 	if (arp_interval < 0) {
@@ -4070,7 +4060,7 @@ static int bond_check_params(void)
 	}
 
 	for (arp_ip_count = 0;
-	     (arp_ip_count < MAX_ARP_IP_TARGETS) && arp_ip_target[arp_ip_count];
+	     (arp_ip_count < BOND_MAX_ARP_TARGETS) && arp_ip_target[arp_ip_count];
 	     arp_ip_count++) {
 		/* not complete check, but should be good enough to
 		   catch mistakes */
@@ -4096,7 +4086,23 @@ static int bond_check_params(void)
 		arp_interval = 0;
 	}
 
-	if (!miimon && !arp_interval) {
+	if (miimon) {
+		printk(KERN_INFO DRV_NAME
+		       ": MII link monitoring set to %d ms\n",
+		       miimon);
+	} else if (arp_interval) {
+		int i;
+
+		printk(KERN_INFO DRV_NAME
+		       ": ARP monitoring set to %d ms with %d target(s):",
+		       arp_interval, arp_ip_count);
+
+		for (i = 0; i < arp_ip_count; i++)
+			printk (" %s", arp_ip_target[i]);
+
+		printk("\n");
+
+	} else {
 		/* miimon and arp_interval not set, we need one so things
 		 * work as expected, see bonding.txt for details
 		 */
@@ -4118,17 +4124,35 @@ static int bond_check_params(void)
 		primary = NULL;
 	}
 
+	/* fill params struct with the proper values */
+	params->mode = bond_mode;
+	params->miimon = miimon;
+	params->arp_interval = arp_interval;
+	params->updelay = updelay;
+	params->downdelay = downdelay;
+	params->use_carrier = use_carrier;
+	params->lacp_fast = lacp_fast;
+	params->primary[0] = 0;
+
+	if (primary) {
+		strncpy(params->primary, primary, IFNAMSIZ);
+		params->primary[IFNAMSIZ - 1] = 0;
+	}
+
+	memcpy(params->arp_targets, arp_target, sizeof(arp_target));
+
 	return 0;
 }
 
 static int __init bonding_init(void)
 {
+	struct bond_params params;
 	int i;
 	int res;
 
 	printk(KERN_INFO "%s", version);
 
-	res = bond_check_params();
+	res = bond_check_params(&params);
 	if (res) {
 		return res;
 	}
@@ -4158,7 +4182,7 @@ static int __init bonding_init(void)
 		 * /proc files), but before register_netdevice(), because we
 		 * need to set function pointers.
 		 */
-		res = bond_init(bond_dev);
+		res = bond_init(bond_dev, &params);
 		if (res < 0) {
 			free_netdev(bond_dev);
 			goto out_err;
diff -Nuarp a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
--- a/drivers/net/bonding/bonding.h	Mon Jan  5 17:05:01 2004
+++ b/drivers/net/bonding/bonding.h	Mon Jan  5 17:05:02 2004
@@ -36,11 +36,13 @@
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
-#define DRV_VERSION	"2.5.3"
+#define DRV_VERSION	"2.5.4"
 #define DRV_RELDATE	"December 30, 2003"
 #define DRV_NAME	"bonding"
 #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 
+#define BOND_MAX_ARP_TARGETS	16
+
 #ifdef BONDING_DEBUG
 #define dprintk(fmt, args...) \
 	printk(KERN_DEBUG     \
@@ -133,6 +135,18 @@
 		bond_for_each_slave_from(bond, pos, cnt, (bond)->first_slave)
 
 
+struct bond_params {
+	int mode;
+	int miimon;
+	int arp_interval;
+	int use_carrier;
+	int updelay;
+	int downdelay;
+	int lacp_fast;
+	char primary[IFNAMSIZ];
+	u32 arp_targets[BOND_MAX_ARP_TARGETS];
+};
+
 struct slave {
 	struct net_device *dev; /* first - usefull for panic debug */
 	struct slave *next;
@@ -181,6 +195,7 @@ struct bonding {
 	u16      flags;
 	struct   ad_bond_info ad_info;
 	struct   alb_bond_info alb_info;
+	struct   bond_params params;
 };
 
 /**
