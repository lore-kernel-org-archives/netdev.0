From: Andy Fleming <afleming@freescale.com>
Subject: RFC new ethtool command
Date: Tue, 1 Mar 2005 09:22:07 -0600
Message-ID: <3a958240e12af10ef6777f908abfe682@freescale.com>
Mime-Version: 1.0 (Apple Message framework v619.2)
Content-Type: multipart/mixed; boundary=Apple-Mail-5-386825446
Cc: Jeff Garzik <jgarzik@pobox.com>
To: Netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Apple-Mail-5-386825446
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=US-ASCII;
	format=flowed

I propose adding a new command to ethtool which allows ethernet drivers 
to specify a command list.  A command list would consist of a 
name/value pair, conforming to the cmdline_info structure already 
present in ethtool.  I see two immediate benefits of this system:

1) controllers which have "cutting-edge", or at least unusual, features 
can easily add support for these features.  As an example, the 85xx 
allows the ethernet controller's DMA engine to allocate and/or lock 
buffer descriptors into the L2 cache of the processor.  Using this 
method, a command could be created which is specific to that driver 
which allows users to turn this feature on or off.

2) When debugging a new driver, or a new feature for an old driver, it 
is easy to add a quick interface to change the testing parameters 
without having to add new /proc entries.

Three patches follow; the first allows ethtool to use this new feature, 
the second allows the kernel to invoke the new feature, and the third 
is an example of how the gianfar driver uses this feature to expose 
failure testing features in the PHY-level code (note that this third 
patch is not a final version.  It also contains a few elements from the 
PHY abstraction patch, which can be ignored for the purposes of this 
discussion).

Andy Fleming
Open Source Software
Freescale Semiconductor, Inc


--Apple-Mail-5-386825446
Content-Transfer-Encoding: 7bit
Content-Type: application/octet-stream;
	x-unix-mode=0644;
	name="xcmd-gfar.patch"
Content-Disposition: attachment;
	filename=xcmd-gfar.patch

diff -Nru a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtool.c
--- a/drivers/net/gianfar_ethtool.c     2005-02-28 17:57:34 -06:00
+++ b/drivers/net/gianfar_ethtool.c     2005-02-28 17:57:34 -06:00
@@ -118,6 +116,12 @@
        "tx-fragmented-frames",
 };
 
+static struct cmdline_info gfar_xcmds[] = {
+       {"phytest", CMDL_BOOL, NULL, NULL},
+       {"ptest_reg", CMDL_INT, NULL, NULL},
+       {"ptest_read", CMDL_BOOL, NULL, NULL},
+};
+
 /* Fill in an array of 64-bit statistics from various sources.
  * This array will be appended to the end of the ethtool_stats
  * structure, and returned to user space
@@ -179,34 +183,75 @@
        drvinfo->testinfo_len = 0;
        drvinfo->regdump_len = 0;
        drvinfo->eedump_len = 0;
+       drvinfo->n_xcmds = (sizeof(gfar_xcmds)/sizeof(gfar_xcmds[0]));
+}
+
+
+static int gfar_ssettings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+       struct gfar_private *priv = netdev_priv(dev);
+       struct phy_device *phydev = priv->phydev;
+
+       if (NULL == phydev)
+               return -ENODEV;
+
+       /* We make sure that we don't pass unsupported
+        * values in to the PHY */
+       cmd->advertising &= phydev->supported;
+
+       /* Verify the settings we care about. */
+       if (cmd->autoneg != AUTONEG_ENABLE && cmd->autoneg != AUTONEG_DISABLE)
+               return -EINVAL;
+
+       if (cmd->autoneg == AUTONEG_ENABLE && cmd->advertising == 0)
+               return -EINVAL;
+
+       if (cmd->autoneg == AUTONEG_DISABLE
+                       && ((cmd->speed != SPEED_1000
+                                       && cmd->speed != SPEED_100
+                                       && cmd->speed != SPEED_10)
+                               || (cmd->duplex != DUPLEX_HALF 
+                                       && cmd->duplex != DUPLEX_FULL)))
+               return -EINVAL;
+
+       phydev->autoneg = cmd->autoneg;
+
+       phydev->speed = cmd->speed;
+
+       phydev->advertising = cmd->advertising;
+
+       if (AUTONEG_ENABLE == cmd->autoneg)
+               phydev->advertising |= ADVERTISED_Autoneg;
+       else
+               phydev->advertising &= ~ADVERTISED_Autoneg;
+
+       phydev->duplex = cmd->duplex;
+
+       /* Restart the PHY */
+       phy_start_aneg(phydev);
+
+       return 0;
 }
 
 /* Return the current settings in the ethtool_cmd structure */
 int gfar_gsettings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
        struct gfar_private *priv = netdev_priv(dev);
-       uint gigabit_support = 
-               priv->einfo->flags & GFAR_HAS_GIGABIT ? SUPPORTED_1000baseT_Full : 0;
-       uint gigabit_advert = 
-               priv->einfo->flags & GFAR_HAS_GIGABIT ? ADVERTISED_1000baseT_Full: 0;
-
-       cmd->supported = (SUPPORTED_10baseT_Half
-                         | SUPPORTED_100baseT_Half
-                         | SUPPORTED_100baseT_Full
-                         | gigabit_support | SUPPORTED_Autoneg);
-
-       /* For now, we always advertise everything */
-       cmd->advertising = (ADVERTISED_10baseT_Half
-                           | ADVERTISED_100baseT_Half
-                           | ADVERTISED_100baseT_Full
-                           | gigabit_advert | ADVERTISED_Autoneg);
+       struct phy_device *phydev = priv->phydev;
+
+       if (NULL == phydev)
+               return -ENODEV;
+
+       cmd->supported = phydev->supported;
+
+       cmd->advertising = phydev->advertising;
 
-       cmd->speed = priv->mii_info->speed;
-       cmd->duplex = priv->mii_info->duplex;
+       cmd->speed = phydev->speed;
+       cmd->duplex = phydev->duplex;
        cmd->port = PORT_MII;
-       cmd->phy_address = priv->mii_info->mii_id;
+       cmd->phy_address = phydev->addr;
        cmd->transceiver = XCVR_EXTERNAL;
-       cmd->autoneg = AUTONEG_ENABLE;
+       cmd->autoneg = phydev->autoneg;
        cmd->maxtxpkt = priv->txcount;
        cmd->maxrxpkt = priv->rxcount;
 
@@ -461,7 +512,33 @@
        return err;
 }
 
+static void gfar_gxcmds(struct net_device *dev,
+               struct ethtool_xcmd *xcmd, void *data)
+{
+       memcpy(data, &gfar_xcmds, sizeof(gfar_xcmds));
+}
+
+static void gfar_gxvals(struct net_device *dev,
+               struct ethtool_xcmd *xcmd, void *data)
+{
+       struct gfar_private *priv = netdev_priv(dev);
+
+       memcpy(data, &priv->xvals, sizeof(struct gfar_xvals));
+}
+
+static void gfar_sxvals(struct net_device *dev, struct ethtool_xcmd *xcmd)
+{
+       struct gfar_private *priv = netdev_priv(dev);
+       struct gfar_xvals *xvals = (struct gfar_xvals *)&(xcmd->data[0]);
+
+       priv->xvals = *xvals;
+
+       gfar_phy_test(priv->mii_bus, priv->phydev, xvals->phytest, 
+                       xvals->ptest_reg, xvals->ptest_read);
+}
+
 struct ethtool_ops gfar_ethtool_ops = {
+       .set_settings = gfar_ssettings,
        .get_settings = gfar_gsettings,
        .get_drvinfo = gfar_gdrvinfo,
        .get_regs_len = gfar_reglen,
@@ -474,9 +551,13 @@
        .get_strings = gfar_gstrings,
        .get_stats_count = gfar_stats_count,
        .get_ethtool_stats = gfar_fill_stats,
+       .get_ethtool_xcmds = gfar_gxcmds,
+       .get_ethtool_xcmd_vals = gfar_gxvals,
+       .set_ethtool_xcmd_vals = gfar_sxvals,
 };
 
 struct ethtool_ops gfar_normon_nocoalesce_ethtool_ops = {
+       .set_settings = gfar_ssettings,
        .get_settings = gfar_gsettings,
        .get_drvinfo = gfar_gdrvinfo,
        .get_regs_len = gfar_reglen,
@@ -487,9 +568,13 @@
        .get_strings = gfar_gstrings_normon,
        .get_stats_count = gfar_stats_count_normon,
        .get_ethtool_stats = gfar_fill_stats_normon,
+       .get_ethtool_xcmds = gfar_gxcmds,
+       .get_ethtool_xcmd_vals = gfar_gxvals,
+       .set_ethtool_xcmd_vals = gfar_sxvals,
 };
 
 struct ethtool_ops gfar_nocoalesce_ethtool_ops = {
+       .set_settings = gfar_ssettings,
        .get_settings = gfar_gsettings,
        .get_drvinfo = gfar_gdrvinfo,
        .get_regs_len = gfar_reglen,
@@ -500,9 +585,13 @@
        .get_strings = gfar_gstrings,
        .get_stats_count = gfar_stats_count,
        .get_ethtool_stats = gfar_fill_stats,
+       .get_ethtool_xcmds = gfar_gxcmds,
+       .get_ethtool_xcmd_vals = gfar_gxvals,
+       .set_ethtool_xcmd_vals = gfar_sxvals,
 };
 
 struct ethtool_ops gfar_normon_ethtool_ops = {
+       .set_settings = gfar_ssettings,
        .get_settings = gfar_gsettings,
        .get_drvinfo = gfar_gdrvinfo,
        .get_regs_len = gfar_reglen,
@@ -515,6 +604,9 @@
        .get_strings = gfar_gstrings_normon,
        .get_stats_count = gfar_stats_count_normon,
        .get_ethtool_stats = gfar_fill_stats_normon,
+       .get_ethtool_xcmds = gfar_gxcmds,
+       .get_ethtool_xcmd_vals = gfar_gxvals,
+       .set_ethtool_xcmd_vals = gfar_sxvals,
 };
 
 struct ethtool_ops *gfar_op_array[] = {

--Apple-Mail-5-386825446
Content-Transfer-Encoding: 7bit
Content-Type: application/octet-stream;
	x-unix-mode=0644;
	name="xcmd-kernel.patch"
Content-Disposition: attachment;
	filename=xcmd-kernel.patch

diff -Nru a/net/core/ethtool.c b/net/core/ethtool.c
--- a/net/core/ethtool.c        2005-02-28 17:57:35 -06:00
+++ b/net/core/ethtool.c        2005-02-28 17:57:35 -06:00
@@ -674,6 +674,101 @@
        return ret;
 }
 
+static int ethtool_get_xcmds(struct net_device *dev, void __user *useraddr)
+{
+       struct ethtool_xcmd xcmd;
+       struct ethtool_ops *ops = dev->ethtool_ops;
+       void *data;
+       int ret;
+
+       if (!ops->get_ethtool_xcmds)
+               return -EOPNOTSUPP;
+
+       if (copy_from_user(&xcmd, useraddr, sizeof(xcmd)))
+               return -EFAULT;
+
+       data = kmalloc(xcmd.nr_xcmds * sizeof(struct cmdline_info), GFP_USER);
+       if (!data)
+               return -ENOMEM;
+
+       ops->get_ethtool_xcmds(dev, &xcmd, data);
+
+       ret = -EFAULT;
+       if (copy_to_user(useraddr, &xcmd, sizeof(xcmd)))
+               goto out;
+       useraddr += sizeof(xcmd);
+       if (copy_to_user(useraddr, data,
+                               xcmd.nr_xcmds * sizeof(struct cmdline_info)))
+               goto out;
+       ret = 0;
+
+out:
+       kfree(data);
+       return ret;
+}
+
+static int ethtool_get_xcmd_vals(struct net_device *dev, void __user *useraddr)
+{
+       struct ethtool_xcmd xcmd_vals;
+       struct ethtool_ops *ops = dev->ethtool_ops;
+       u32 *data;
+       int ret;
+
+       if (!ops->get_ethtool_xcmd_vals)
+               return -EOPNOTSUPP;
+
+       if (copy_from_user(&xcmd_vals, useraddr, sizeof(xcmd_vals)))
+               return -EFAULT;
+
+       data = kmalloc(xcmd_vals.nr_xcmds * sizeof(u32), GFP_USER);
+       if (!data)
+               return -ENOMEM;
+
+       ops->get_ethtool_xcmd_vals(dev, &xcmd_vals, data);
+
+       ret = -EFAULT;
+       if (copy_to_user(useraddr, &xcmd_vals, sizeof(xcmd_vals)))
+               goto out;
+       useraddr += sizeof(xcmd_vals);
+       if (copy_to_user(useraddr, data, xcmd_vals.nr_xcmds*sizeof(u32)))
+               goto out;
+       ret = 0;
+
+out:
+       kfree(data);
+       return ret;
+}
+static int ethtool_set_xcmd_vals(struct net_device *dev, void __user *useraddr)
+{
+       struct ethtool_xcmd xcmd;
+       struct ethtool_xcmd *xcmd_vals;
+       struct ethtool_ops *ops = dev->ethtool_ops;
+       int ret;
+
+       if (!ops->set_ethtool_xcmd_vals)
+               return -EOPNOTSUPP;
+
+       if (copy_from_user(&xcmd, useraddr, sizeof(xcmd)))
+               return -EFAULT;
+
+       xcmd_vals = kmalloc(sizeof(xcmd)+xcmd.nr_xcmds * sizeof(u32),
+                       GFP_KERNEL);
+       if (!xcmd_vals)
+               return -ENOMEM;
+
+       ret = -EFAULT;
+       if (copy_from_user(xcmd_vals, useraddr,
+                               sizeof(xcmd)+xcmd.nr_xcmds * sizeof(u32)))
+               goto out;
+
+       ops->set_ethtool_xcmd_vals(dev, xcmd_vals);
+
+       ret = 0;
+
+out:
+       kfree(xcmd_vals);
+       return ret;
+}
 /* The main entry point in this file.  Called from net/core/dev.c */
 
 int dev_ethtool(struct ifreq *ifr)
@@ -794,6 +889,15 @@
                break;
        case ETHTOOL_GSTATS:
                rc = ethtool_get_stats(dev, useraddr);
+               break;
+       case ETHTOOL_GXCMDS:
+               rc = ethtool_get_xcmds(dev, useraddr);
+               break;
+       case ETHTOOL_GXCMDVALS:
+               rc = ethtool_get_xcmd_vals(dev, useraddr);
+               break;
+       case ETHTOOL_SXCMDVALS:
+               rc = ethtool_set_xcmd_vals(dev, useraddr);
                break;
        default:
                rc =  -EOPNOTSUPP;
diff -Nru a/include/linux/ethtool.h b/include/linux/ethtool.h
--- a/include/linux/ethtool.h   2005-02-28 17:57:34 -06:00
+++ b/include/linux/ethtool.h   2005-02-28 17:57:34 -06:00
@@ -44,6 +44,8 @@
        u32     testinfo_len;
        u32     eedump_len;     /* Size of data from ETHTOOL_GEEPROM (bytes) */
        u32     regdump_len;    /* Size of data from ETHTOOL_GREGS (bytes) */
+       u32     n_xcmds;        /* number of driver-defined commands */
+
 };
 
 #define SOPASS_MAX     6
@@ -215,6 +217,29 @@
        u32     tx_pause;
 };
 
+/* For getting the driver-specified command list, and also for
+ * getting the current values for those commands */
+struct ethtool_xcmd {
+       u32 cmd;
+       u32 nr_xcmds;
+       u8 data[0];
+};
+
+typedef enum {
+       CMDL_NONE,
+       CMDL_BOOL,
+       CMDL_INT,
+} cmdline_type_t;
+
+#define CMDLINE_NAME_LEN 32
+struct cmdline_info {
+       const char name[CMDLINE_NAME_LEN];
+       cmdline_type_t type;
+       void *wanted_val;
+       void *ioctl_val;
+};
+
+
 #define ETH_GSTRING_LEN                32
 enum ethtool_stringset {
        ETH_SS_TEST             = 0,
@@ -351,6 +376,9 @@
        int     (*phys_id)(struct net_device *, u32);
        int     (*get_stats_count)(struct net_device *);
        void    (*get_ethtool_stats)(struct net_device *, struct ethtool_stats *, u64 *);
+       void    (*get_ethtool_xcmds)(struct net_device *, struct ethtool_xcmd *, void *);
+       void    (*get_ethtool_xcmd_vals)(struct net_device *, struct ethtool_xcmd *, void *);
+       void    (*set_ethtool_xcmd_vals)(struct net_device *, struct ethtool_xcmd *);
        int     (*begin)(struct net_device *);
        void    (*complete)(struct net_device *);
 };
@@ -388,6 +416,10 @@
 #define ETHTOOL_GSTATS         0x0000001d /* get NIC-specific statistics */
 #define ETHTOOL_GTSO           0x0000001e /* Get TSO enable (ethtool_value) */
 #define ETHTOOL_STSO           0x0000001f /* Set TSO enable (ethtool_value) */
+#define ETHTOOL_GXCMDS          0x00000020 /* Get XCMD list */
+#define ETHTOOL_GXCMDVALS       0x00000021 /* Get current XCMD values */
+#define ETHTOOL_SXCMDVALS       0x00000022 /* Set current XCMD values */
+
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET         ETHTOOL_GSET

--Apple-Mail-5-386825446
Content-Transfer-Encoding: 7bit
Content-Type: application/octet-stream;
	x-unix-mode=0644;
	name="xcmd.patch"
Content-Disposition: attachment;
	filename=xcmd.patch

? xcmd.patch
Index: ChangeLog
===================================================================
RCS file: /cvsroot/gkernel/ethtool/ChangeLog,v
retrieving revision 1.60
diff -u -r1.60 ChangeLog
--- ChangeLog	17 Aug 2004 12:05:45 -0000	1.60
+++ ChangeLog	28 Feb 2005 22:41:26 -0000
@@ -1,3 +1,8 @@
+Mon Feb 28 2005  Andy Fleming <afleming@freescale.com>
+
+	* ethtool.c, ethtool-copy.h: Added a new command (-x)
+	which allows drivers to specify command-line arguments
+
 Tue Aug 17 2004  Jeff Garzik <jgarzik@pobox.com>
 
 	* NEWS, configure.ac:  Release version 2
Index: ethtool-copy.h
===================================================================
RCS file: /cvsroot/gkernel/ethtool/ethtool-copy.h,v
retrieving revision 1.13
diff -u -r1.13 ethtool-copy.h
--- ethtool-copy.h	19 Jul 2003 15:19:52 -0000	1.13
+++ ethtool-copy.h	28 Feb 2005 22:41:26 -0000
@@ -44,6 +44,7 @@
 	u32	testinfo_len;
 	u32	eedump_len;	/* Size of data from ETHTOOL_GEEPROM (bytes) */
 	u32	regdump_len;	/* Size of data from ETHTOOL_GREGS (bytes) */
+	u32	n_xcmds;	/* number of driver-defined commands */
 };
 
 #define SOPASS_MAX	6
@@ -215,6 +216,14 @@
 	u32	tx_pause;
 };
 
+/* For getting the driver-specified command list, and also for getting
+ * the current values for those commands */
+struct ethtool_xcmd {
+	u32 cmd;
+	u32 nr_xcmds;
+	u8 data[0];
+};
+
 #define ETH_GSTRING_LEN		32
 enum ethtool_stringset {
 	ETH_SS_TEST		= 0,
@@ -283,6 +292,9 @@
 #define ETHTOOL_GSTATS		0x0000001d /* get NIC-specific statistics */
 #define ETHTOOL_GTSO		0x0000001e /* Get TSO enable (ethtool_value) */
 #define ETHTOOL_STSO		0x0000001f /* Set TSO enable (ethtool_value) */
+#define ETHTOOL_GXCMDS		0x00000020 /* Get XCMD list */
+#define ETHTOOL_GXCMDVALS	0x00000021 /* Get current XCMD values */
+#define ETHTOOL_SXCMDVALS	0x00000022 /* Set current XCMD values */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
Index: ethtool.c
===================================================================
RCS file: /cvsroot/gkernel/ethtool/ethtool.c,v
retrieving revision 1.50
diff -u -r1.50 ethtool.c
--- ethtool.c	2 Jul 2004 15:35:09 -0000	1.50
+++ ethtool.c	28 Feb 2005 22:41:26 -0000
@@ -64,6 +64,7 @@
 static int do_goffload(int fd, struct ifreq *ifr);
 static int do_soffload(int fd, struct ifreq *ifr);
 static int do_gstats(int fd, struct ifreq *ifr);
+static int do_xcmd(int fd, struct ifreq *ifr);
 
 /* Syntax:
  *
@@ -132,6 +133,7 @@
  *		[ sopass %x:%x:%x:%x:%x:%x ] \
  *		[ msglvl %d ]
  *	ethtool -S DEVNAME
+ *	ethtool -x DEVNAME [x-command list]
  */
 
 static void show_usage(int badarg)
@@ -205,6 +207,7 @@
 		"		[ sopass %%x:%%x:%%x:%%x:%%x:%%x ] \\\n"
 		"		[ msglvl %%d ] \n"
 		"	ethtool -S DEVNAME\n"
+		"	ethtool -x DEVNAME [x-command list]\n"
 	);
 	exit(badarg);
 }
@@ -229,6 +232,7 @@
 	MODE_GOFFLOAD,
 	MODE_SOFFLOAD,
 	MODE_GSTATS,
+	MODE_XCMD,
 } mode = MODE_GSET;
 
 static int goffload_changed = 0;
@@ -300,6 +304,10 @@
 static int seeprom_magic = 0;
 static int seeprom_offset = -1;
 static int seeprom_value = 0;
+
+static char **gxcmd_argp = NULL;
+static int gxcmd_argc = 0;
+
 static enum {
 	ONLINE=0,
 	OFFLINE,
@@ -311,8 +319,9 @@
 	CMDL_INT,
 } cmdline_type_t;
 
+#define CMDLINE_NAME_LEN 32
 struct cmdline_info {
-	const char *name;
+	const char name[CMDLINE_NAME_LEN];
 	cmdline_type_t type;
 	void *wanted_val;
 	void *ioctl_val;
@@ -456,6 +465,8 @@
 				mode = MODE_TEST;
 			else if (!strcmp(argp[i], "-S"))
 				mode = MODE_GSTATS;
+			else if (!strcmp(argp[i], "-x"))
+				mode = MODE_XCMD;
 			else if (!strcmp(argp[i], "-h"))
 				show_usage(0);
 			else
@@ -478,6 +489,7 @@
 			    (mode == MODE_GOFFLOAD) ||
 			    (mode == MODE_SOFFLOAD) ||
 			    (mode == MODE_GSTATS) ||
+			    (mode == MODE_XCMD) ||
 			    (mode == MODE_PHYS_ID)) {
 				devname = argp[i];
 				break;
@@ -557,6 +569,13 @@
 				i = argc;
 				break;
 			}
+			/* X-Commands are parsed later */
+			if (mode == MODE_XCMD) {
+				gxcmd_argp = &(argp[i]);
+				gxcmd_argc = argc - i;
+				i = argc;
+				break;
+			}
 			if (mode != MODE_SSET)
 				show_usage(1);
 			if (!strcmp(argp[i], "speed")) {
@@ -681,13 +700,21 @@
 		else if (speed_wanted == SPEED_100 &&
 			 duplex_wanted == DUPLEX_FULL)
 			advertising_wanted = ADVERTISED_100baseT_Full;
-		else
+		else if (speed_wanted == SPEED_1000 &&
+			 duplex_wanted == DUPLEX_HALF)
+			advertising_wanted = ADVERTISED_1000baseT_Half;
+		else if (speed_wanted == SPEED_1000 &&
+			 duplex_wanted == DUPLEX_FULL)
+			advertising_wanted = ADVERTISED_1000baseT_Full;
+		else {
 			/* auto negotiate without forcing */
 			advertising_wanted = ADVERTISED_100baseT_Full |
 				ADVERTISED_100baseT_Half |
 				ADVERTISED_10baseT_Full |
-				ADVERTISED_100baseT_Half;
-
+				ADVERTISED_10baseT_Half |
+				ADVERTISED_1000baseT_Half |
+				ADVERTISED_1000baseT_Full;
+		}
 	}
 
 	if (devname == NULL) {
@@ -857,7 +884,7 @@
 		fprintf(stdout, "internal\n");
 		break;
 	case XCVR_EXTERNAL:
-		fprintf(stdout, "externel\n");
+		fprintf(stdout, "external\n");
 		break;
 	default:
 		fprintf(stdout, "Unknown!\n");
@@ -1243,6 +1270,8 @@
 		return do_soffload(fd, &ifr);
 	} else if (mode == MODE_GSTATS) {
 		return do_gstats(fd, &ifr);
+	} else if (mode == MODE_XCMD) {
+		return do_xcmd(fd, &ifr);
 	}
 
 	return 69;
@@ -1313,6 +1342,151 @@
 		do_generic_set1(&info[i], changed_out);
 }
 
+static void dump_command(struct cmdline_info *info)
+{
+	fprintf(stderr, "%s %s\n", info->name,
+			(info->type == CMDL_BOOL) ? "[on|off]" :
+			(info->type == CMDL_INT) ? "<int>" : "<val>");
+}
+
+static void dump_command_list(struct cmdline_info *info,
+		unsigned int n_info)
+{
+	int idx;
+
+	fprintf(stderr, "Commands supported by %s:\n", devname);
+
+	for (idx = 0; idx < n_info; idx++) {
+		fprintf(stderr, "\t");
+		dump_command(&info[idx]);
+	}
+}
+
+/* Each driver may specify a list of arbitrary commands to change
+ * driver values.  These can be used to enable features which
+ * aren't widely available (thus meriting a unique ethtool
+ * command), or turn specific debugging features on and off. */
+static int do_xcmd(int fd, struct ifreq *ifr)
+{
+	int nr_xcmds;
+	int err;
+	struct cmdline_info *xcmd_list;
+	struct ethtool_drvinfo drvinfo;
+	struct ethtool_xcmd *xcmd;
+	struct ethtool_xcmd *xcmd_vals;
+	u32 *wanted_vals;
+	int changed;
+	int idx;
+
+	/* Get the driver's info, so we know how many commands
+	 * it provides */
+	drvinfo.cmd = ETHTOOL_GDRVINFO;
+	ifr->ifr_data = (caddr_t)&drvinfo;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	if (err < 0) {
+		perror("Cannot get X-Command list size");
+		return err;
+	}
+
+	nr_xcmds = drvinfo.n_xcmds;
+
+	if (nr_xcmds < 1) {
+		fprintf(stderr, "No commands supported\n");
+		return 94;
+	}
+
+	/* Allocate space for the command list */
+	xcmd = calloc(1, sizeof(*xcmd) + sizeof(*xcmd_list) * nr_xcmds);
+
+	if (NULL == xcmd) {
+		fprintf(stderr, "No memory\n");
+		return 94;
+	}
+
+	/* Get the command list */
+	xcmd->cmd = ETHTOOL_GXCMDS;
+	xcmd->nr_xcmds = nr_xcmds;
+	ifr->ifr_data = (caddr_t)xcmd;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	if (err < 0) {
+		perror("Cannot get X-Command list");
+		free(xcmd);
+		return err;
+	}
+
+	xcmd_list = (struct cmdline_info *)&(xcmd->data);
+
+	/* If the user didn't specify any commands, print out the
+	 * command list */
+	if (gxcmd_argc < 2) {
+		dump_command_list(xcmd_list, nr_xcmds);
+		return 94;
+	}
+
+	/* Allocate space for the current values from the driver */
+	xcmd_vals = calloc(1, sizeof(*xcmd) + sizeof(u32) * nr_xcmds);
+
+	if (NULL == xcmd_vals) {
+		fprintf(stderr, "No memory\n");
+		free(xcmd);
+		return 94;
+	}
+
+	/* Get the xcmd values */
+	xcmd_vals->cmd = ETHTOOL_GXCMDVALS;
+	xcmd_vals->nr_xcmds = nr_xcmds;
+	ifr->ifr_data = (caddr_t)xcmd_vals;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	if (err < 0) {
+		perror("Cannot get X-Command values");
+		free(xcmd);
+		free(xcmd_vals);
+		return err;
+	}
+
+	/* Create a temporary array to store the values the user
+	 * specified on the command line */
+	wanted_vals = calloc(1, sizeof(u32)*nr_xcmds);
+
+	/* Now tie the wanted_val fields of each command to
+	 * entries in the wanted_vals array, and tie the
+	 * ioctl_val fields to the data from xcmd_vals */
+	for (idx = 0; idx < nr_xcmds; idx++) {
+		xcmd_list[idx].wanted_val = &wanted_vals[idx];
+		xcmd_list[idx].ioctl_val = &xcmd_vals->data[idx*sizeof(u32)];
+	}
+
+	/* Parse the command line, and fill in the 
+	 * wanted_vals array */
+	parse_generic_cmdline(gxcmd_argc, gxcmd_argp, 0,
+			&changed, xcmd_list, nr_xcmds);
+
+	if (!changed) {
+		fprintf(stderr, "No xcmds specified\n");
+		return 80;
+	}
+
+	/* Now change the values in xcmd_vals to reflect
+	 * those in the wanted_vals array */
+	do_generic_set(xcmd_list, nr_xcmds, &changed);
+
+	if (!changed) {
+		fprintf(stderr, "No xcmd values changed\n");
+		return 80;
+	}
+
+	/* Pass the new values back up to the driver */
+	xcmd_vals->cmd = ETHTOOL_SXCMDVALS;
+	ifr->ifr_data = (caddr_t)xcmd_vals;
+	err = ioctl(fd, SIOCETHTOOL, ifr);
+	if (err < 0) {
+		perror("Could not set new X-Command values");
+		return err;
+	}
+
+	return 0;
+}
+
 static int do_spause(int fd, struct ifreq *ifr)
 {
 	int err, changed = 0;

--Apple-Mail-5-386825446--
