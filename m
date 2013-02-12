From: Larry Baker <baker@usgs.gov>
Subject: decnet: /proc/sys/net/decnet sysctl entries disappear
Date: Mon, 11 Feb 2013 16:26:00 -0800
Message-ID: <FAAC90D7-8126-44CA-AACF-A5F8237C1A8E@usgs.gov>
Mime-Version: 1.0 (Apple Message framework v1085)
Content-Type: multipart/mixed; boundary=Apple-Mail-26-69471391
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gscamnlh01.wr.usgs.gov ([130.118.9.68]:55457 "EHLO
	gscamnlh01.wr.usgs.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761084Ab3BLAlF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 19:41:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Apple-Mail-26-69471391
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

Beginning with kernel 2.6.27, the decnet kernel module =
/proc/sys/net/decnet sysctl entries disappear.  With the generous =
assistance of Eric Biederman, I have developed these patches to restore =
the previous behavior and add minor features.  (N.b, Eric verified =
kernel 3.4-rc1 no longer has this behavior.)

I have developed three sets of patches, to account for changes in the =
kernel networking APIs.=

--Apple-Mail-26-69471391
Content-Transfer-Encoding: 7bit
Content-Type: application/octet-stream;
	name="linux-2.6.27-decnet-sysctl.patch"
Content-Disposition: attachment;
	filename=linux-2.6.27-decnet-sysctl.patch

Title

linux-2.6.27-decnet-sysctl.patch

decnet kernel module patches for Linux 2.6.27 through 2.6.32

Author

Larry Baker
US Geological Survey
baker@usgs.gov

Description

The decnet kernel module is configured using entries under /proc/sys/net/decnet.
There are executor settings in /proc/sys/net/decnet, template device settings
in /proc/sys/net/decnet/conf/{ddcmp,ethernet,ipgre,loopback}, and active device
settings for DECnet devices in /proc/sys/net/decnet/conf/{lo,eth0,...}.  All
Ethernet interfaces and the loopback interface are configured as DECnet devices
when the decnet kernel module is loaded.

The executor settings and template device settings are static; active device
settings are dynamic.  The active device settings for a network device are
copied from the appropriate template device settings when the network device is
configured as a DECnet device.  The active device settings are discarded when a
DECnet device is unconfigured (e.g., when the DECnet node address is set).

When the DECnet node address is set (e.g., by writing the new address to
/proc/sys/net/decnet/node_address) all DECnet devices are unconfigured, the new
DECnet node address is saved, and all Ethernet interfaces and the loopback
interface are reconfigured as DECnet devices.

When a DECnet device is unconfigured, its active device settings entries are
unregistered from the sysctl network namespace (/proc/sys/net).  When a DECnet
device is reconfigured, its active device settings entries are reregistered.

In kernel 2.6.27 the sysctl data structures were changed from a list to a tree.
The registration/unregistration behavior also changed.  As a result, when any
active device settings entries are unregistered, all the decnet kernel module
configuration settings entries in the sysctl network namespace are no longer
visible.  The only entries that are visible are the active device settings
entries that are reregistered when the DECnet devices are reconfigured.

The fix is to register an empty static /proc/sys/net/decnet/conf entry (ala
mkdir) before any of the (static or dynamic) entries beneath it are registered.
This workaround is not needed in 3.4 and later kernels.

After this patch, the registration order for sysctl entries is:

. Static executor entries in /proc/sys/net/decnet
. Static empty path entry /proc/sys/net/decnet/conf
. Static template device entries in /proc/sys/net/decnet/conf/<type>
. Dynamic active device entries in /proc/sys/net/decnet/conf/<dev-name>

Unregistration order is the reverse.

Other changes are:

. Updated banner
. DECnet device up/down KERN_INFO messages
. debug module parameter
. NETDEV_UP/DOWN KERN_DEBUG messages if (debug & 8)
. dn_route.c uses dn_hiord[ETH_ALEN] in dn_dev.c

--- original/net/decnet/af_decnet.c
+++ patched/net/decnet/af_decnet.c
@@ -1,2 +1 @@
-
 /*
@@ -42,2 +41,5 @@
  *                          prepare for sendpage etc.
+ *            Larry Baker : Register static /proc/sys/net/decnet entries before
+ *                          dynamic /proc/sys/net/decnet/conf entries in
+ *                          dn_dev_init().
  */
@@ -2090,2 +2092,4 @@
 		case NETDEV_UP:
+			if (decnet_debug_level & 8)
+				printk(KERN_DEBUG "DECnet: %s NETDEV_UP", dev->name);
 			dn_dev_up(dev);
@@ -2093,2 +2097,4 @@
 		case NETDEV_DOWN:
+			if (decnet_debug_level & 8)
+				printk(KERN_DEBUG "DECnet: %s NETDEV_DOWN", dev->name);
 			dn_dev_down(dev);
@@ -2363,3 +2369,3 @@

-static char banner[] __initdata = KERN_INFO "NET4: DECnet for Linux: V.2.5.68s (C) 1995-2003 Linux DECnet Project Team\n";
+static char banner[] __initdata = KERN_INFO "DECnet: DECnet for Linux: V.2.6.27 (C) 1995-2013 Linux DECnet Project Team\n";

@@ -2375,2 +2381,4 @@

+	dn_register_sysctl();
+
 	dn_neigh_init();
@@ -2385,3 +2393,2 @@
 	proc_net_fops_create(&init_net, "decnet", S_IRUGO, &dn_socket_seq_fops);
-	dn_register_sysctl();
 out:
@@ -2404,4 +2411,2 @@

-	dn_unregister_sysctl();
-
 	unregister_netdevice_notifier(&dn_dev_notifier);
@@ -2413,2 +2418,4 @@

+	dn_unregister_sysctl();
+
 	proc_net_remove(&init_net, "decnet");
--- original/net/decnet/dn_dev.c
+++ patched/net/decnet/dn_dev.c
@@ -24,2 +24,6 @@
  *                             devices. All mtu based now.
+ *               Larry Baker : Register empty static /proc/sys/net/decnet/conf
+ *                             before registering any entries beneath it due to
+ *                             tree-based sysctl tables since kernel 2.6.27.
+ *                             Workaround not needed in 3.4 and later kernels.
  */
@@ -60,3 +64,3 @@
 static char dn_rt_all_rt_mcast[ETH_ALEN]  = {0xAB,0x00,0x00,0x03,0x00,0x00};
-static char dn_hiord[ETH_ALEN]            = {0xAA,0x00,0x04,0x00,0x00,0x00};
+unsigned char dn_hiord[ETH_ALEN]          = {0xAA,0x00,0x04,0x00,0x00,0x00};
 static unsigned char dn_eco_version[3]    = {0x02,0x00,0x00};
@@ -172,2 +176,4 @@

+static struct ctl_table_header *dn_conf_path = NULL;
+
 static struct dn_dev_sysctl_table {
@@ -224,2 +230,13 @@

+static ctl_table empty[] = {
+        { }
+};
+
+static struct ctl_path dn_conf[] = {
+	{ .procname = "net", .ctl_name = CTL_NET, },
+	{ .procname = "decnet", .ctl_name = NET_DECNET, },
+	{ .procname = "conf", .ctl_name = NET_DECNET_CONF, },
+	{ },
+};
+
 static void dn_dev_sysctl_register(struct net_device *dev, struct dn_dev_parms *parms)
@@ -1176,2 +1193,3 @@
 	struct dn_dev *dn_db = (struct dn_dev *)dev->dn_ptr;
+	char dn_ascbuf[DN_ASCBUF_LEN];

@@ -1213,2 +1231,5 @@

+	dn_addr2asc(le16_to_cpu(addr), dn_ascbuf);
+	printk(KERN_INFO "DECnet: %s up [%s]", dev->name, dn_ascbuf);
+
 	/*
@@ -1256,2 +1277,3 @@
 	struct dn_ifaddr *ifa;
+	__le16 addr = decnet_address;

@@ -1266,2 +1288,14 @@
 	dn_dev_delete(dev);
+
+	if (dev->type == ARPHRD_ETHER) {
+		if (memcmp(dev->dev_addr, dn_hiord, 4) != 0)
+			return;
+		addr = dn_eth2dn(dev->dev_addr);
+	}
+
+	if (addr == 0)
+		return;
+
+	printk(KERN_INFO "DECnet: %s down", dev->name);
+
 }
@@ -1432,2 +1466,6 @@

+static int debug = 0;
+module_param(debug, int, 0444);
+MODULE_PARM_DESC(debug, "Debug level");
+
 static int addr[2];
@@ -1438,2 +1476,4 @@
 {
+	decnet_debug_level = debug;
+
 	if (addr[0] > 63 || addr[0] < 0) {
@@ -1450,11 +1490,4 @@

-	dn_dev_devices_on();
-
-	rtnl_register(PF_DECnet, RTM_NEWADDR, dn_nl_newaddr, NULL);
-	rtnl_register(PF_DECnet, RTM_DELADDR, dn_nl_deladdr, NULL);
-	rtnl_register(PF_DECnet, RTM_GETADDR, NULL, dn_nl_dump_ifaddr);
-
-	proc_net_fops_create(&init_net, "decnet_dev", S_IRUGO, &dn_dev_seq_fops);
-
 #ifdef CONFIG_SYSCTL
+	dn_conf_path = register_sysctl_paths(dn_conf, empty);
 	{
@@ -1465,2 +1498,10 @@
 #endif /* CONFIG_SYSCTL */
+
+	dn_dev_devices_on();
+
+	rtnl_register(PF_DECnet, RTM_NEWADDR, dn_nl_newaddr, NULL);
+	rtnl_register(PF_DECnet, RTM_DELADDR, dn_nl_deladdr, NULL);
+	rtnl_register(PF_DECnet, RTM_GETADDR, NULL, dn_nl_dump_ifaddr);
+
+	proc_net_fops_create(&init_net, "decnet_dev", S_IRUGO, &dn_dev_seq_fops);
 }
@@ -1469,2 +1510,6 @@
 {
+	proc_net_remove(&init_net, "decnet_dev");
+
+	dn_dev_devices_off();
+
 #ifdef CONFIG_SYSCTL
@@ -1475,7 +1520,4 @@
 	}
+	unregister_sysctl_table(dn_conf_path);
 #endif /* CONFIG_SYSCTL */
-
-	proc_net_remove(&init_net, "decnet_dev");
-
-	dn_dev_devices_off();
 }
--- original/net/decnet/dn_route.c
+++ patched/net/decnet/dn_route.c
@@ -100,4 +100,3 @@

-
-static unsigned char dn_hiord_addr[6] = {0xAA,0x00,0x04,0x00,0x00,0x00};
+extern unsigned char dn_hiord[ETH_ALEN];

@@ -504,3 +504,3 @@
 	cb->dst = dn_eth2dn(ptr);
-	if (memcmp(ptr, dn_hiord_addr, 4) != 0)
+	if (memcmp(ptr, dn_hiord, 4) != 0)
 		goto drop_it;
@@ -512,3 +512,3 @@
 	cb->src = dn_eth2dn(ptr);
-	if (memcmp(ptr, dn_hiord_addr, 4) != 0)
+	if (memcmp(ptr, dn_hiord, 4) != 0)
 		goto drop_it;

--Apple-Mail-26-69471391
Content-Transfer-Encoding: 7bit
Content-Type: application/octet-stream;
	name="linux-2.6.33-decnet-sysctl.patch"
Content-Disposition: attachment;
	filename=linux-2.6.33-decnet-sysctl.patch

Title

linux-2.6.33-decnet-sysctl.patch

decnet kernel module patches for Linux 2.6.33 through 3.4.x

Author

Larry Baker
US Geological Survey
baker@usgs.gov

Description

The decnet kernel module is configured using entries under /proc/sys/net/decnet.
There are executor settings in /proc/sys/net/decnet, template device settings
in /proc/sys/net/decnet/conf/{ddcmp,ethernet,ipgre,loopback}, and active device
settings for DECnet devices in /proc/sys/net/decnet/conf/{lo,eth0,...}.  All
Ethernet interfaces and the loopback interface are configured as DECnet devices
when the decnet kernel module is loaded.

The executor settings and template device settings are static; active device
settings are dynamic.  The active device settings for a network device are
copied from the appropriate template device settings when the network device is
configured as a DECnet device.  The active device settings are discarded when a
DECnet device is unconfigured (e.g., when the DECnet node address is set).

When the DECnet node address is set (e.g., by writing the new address to
/proc/sys/net/decnet/node_address) all DECnet devices are unconfigured, the new
DECnet node address is saved, and all Ethernet interfaces and the loopback
interface are reconfigured as DECnet devices.

When a DECnet device is unconfigured, its active device settings entries are
unregistered from the sysctl network namespace (/proc/sys/net).  When a DECnet
device is reconfigured, its active device settings entries are reregistered.

In kernel 2.6.27 the sysctl data structures were changed from a list to a tree.
The registration/unregistration behavior also changed.  As a result, when any
active device settings entries are unregistered, all the decnet kernel module
configuration settings entries in the sysctl network namespace are no longer
visible.  The only entries that are visible are the active device settings
entries that are reregistered when the DECnet devices are reconfigured.

The fix is to register an empty static /proc/sys/net/decnet/conf entry (ala
mkdir) before any of the (static or dynamic) entries beneath it are registered.
This workaround is not needed in 3.4 and later kernels.

After this patch, the registration order for sysctl entries is:

. Static executor entries in /proc/sys/net/decnet
. Static empty path entry /proc/sys/net/decnet/conf
. Static template device entries in /proc/sys/net/decnet/conf/<type>
. Dynamic active device entries in /proc/sys/net/decnet/conf/<dev-name>

Unregistration order is the reverse.

Other changes are:

. Updated banner
. DECnet device up/down KERN_INFO messages
. debug module parameter
. NETDEV_UP/DOWN KERN_DEBUG messages if (debug & 8)
. dn_route.c uses dn_hiord[ETH_ALEN] in dn_dev.c

--- original/net/decnet/af_decnet.c
+++ patched/net/decnet/af_decnet.c
@@ -1,2 +1 @@
-
 /*
@@ -42,2 +41,5 @@
  *                          prepare for sendpage etc.
+ *            Larry Baker : Register static /proc/sys/net/decnet entries before
+ *                          dynamic /proc/sys/net/decnet/conf entries in
+ *                          dn_dev_init().
  */
@@ -2091,2 +2093,4 @@
 	case NETDEV_UP:
+		if (decnet_debug_level & 8)
+			printk(KERN_DEBUG "DECnet: %s NETDEV_UP", dev->name);
 		dn_dev_up(dev);
@@ -2094,2 +2098,4 @@
 	case NETDEV_DOWN:
+		if (decnet_debug_level & 8)
+			printk(KERN_DEBUG "DECnet: %s NETDEV_DOWN", dev->name);
 		dn_dev_down(dev);
@@ -2364,3 +2370,3 @@

-static char banner[] __initdata = KERN_INFO "NET4: DECnet for Linux: V.2.5.68s (C) 1995-2003 Linux DECnet Project Team\n";
+static char banner[] __initdata = KERN_INFO "DECnet: DECnet for Linux: V.2.6.33 (C) 1995-2013 Linux DECnet Project Team\n";

@@ -2376,2 +2382,4 @@

+	dn_register_sysctl();
+
 	dn_neigh_init();
@@ -2386,3 +2394,2 @@
 	proc_net_fops_create(&init_net, "decnet", S_IRUGO, &dn_socket_seq_fops);
-	dn_register_sysctl();
 out:
@@ -2405,4 +2412,2 @@

-	dn_unregister_sysctl();
-
 	unregister_netdevice_notifier(&dn_dev_notifier);
@@ -2414,2 +2419,4 @@

+	dn_unregister_sysctl();
+
 	proc_net_remove(&init_net, "decnet");
--- original/net/decnet/dn_dev.c
+++ patched/net/decnet/dn_dev.c
@@ -24,2 +24,6 @@
  *                             devices. All mtu based now.
+ *               Larry Baker : Register empty static /proc/sys/net/decnet/conf
+ *                             before registering any entries beneath it due to
+ *                             tree-based sysctl tables since kernel 2.6.27.
+ *                             Workaround not needed in 3.4 and later kernels.
  */
@@ -61,3 +65,3 @@
 static char dn_rt_all_rt_mcast[ETH_ALEN]  = {0xAB,0x00,0x00,0x03,0x00,0x00};
-static char dn_hiord[ETH_ALEN]            = {0xAA,0x00,0x04,0x00,0x00,0x00};
+unsigned char dn_hiord[ETH_ALEN]          = {0xAA,0x00,0x04,0x00,0x00,0x00};
 static unsigned char dn_eco_version[3]    = {0x02,0x00,0x00};
@@ -163,2 +167,5 @@
 			void __user *, size_t *, loff_t *);
+
+static struct ctl_table_header *dn_conf_path = NULL;
+
 static struct dn_dev_sysctl_table {
@@ -207,2 +214,13 @@

+static ctl_table empty[] = {
+        { }
+};
+
+static struct ctl_path dn_conf[] = {
+	{ .procname = "net", },
+	{ .procname = "decnet", },
+	{ .procname = "conf", },
+	{ },
+};
+
 static void dn_dev_sysctl_register(struct net_device *dev, struct dn_dev_parms *parms)
@@ -1143,2 +1161,3 @@
 	struct dn_dev *dn_db = rtnl_dereference(dev->dn_ptr);
+	char dn_ascbuf[DN_ASCBUF_LEN];

@@ -1180,2 +1199,5 @@

+	dn_addr2asc(le16_to_cpu(addr), dn_ascbuf);
+	printk(KERN_INFO "DECnet: %s up [%s]", dev->name, dn_ascbuf);
+
 	/*
@@ -1223,2 +1245,3 @@
 	struct dn_ifaddr *ifa;
+	__le16 addr = decnet_address;

@@ -1233,2 +1256,14 @@
 	dn_dev_delete(dev);
+
+	if (dev->type == ARPHRD_ETHER) {
+		if (memcmp(dev->dev_addr, dn_hiord, 4) != 0)
+			return;
+		addr = dn_eth2dn(dev->dev_addr);
+	}
+
+	if (addr == 0)
+		return;
+
+	printk(KERN_INFO "DECnet: %s down", dev->name);
+
 }
@@ -1396,2 +1431,6 @@

+static int debug = 0;
+module_param(debug, int, 0444);
+MODULE_PARM_DESC(debug, "Debug level");
+
 static int addr[2];
@@ -1402,2 +1441,4 @@
 {
+	decnet_debug_level = debug;
+
 	if (addr[0] > 63 || addr[0] < 0) {
@@ -1414,11 +1455,4 @@

-	dn_dev_devices_on();
-
-	rtnl_register(PF_DECnet, RTM_NEWADDR, dn_nl_newaddr, NULL, NULL);
-	rtnl_register(PF_DECnet, RTM_DELADDR, dn_nl_deladdr, NULL, NULL);
-	rtnl_register(PF_DECnet, RTM_GETADDR, NULL, dn_nl_dump_ifaddr, NULL);
-
-	proc_net_fops_create(&init_net, "decnet_dev", S_IRUGO, &dn_dev_seq_fops);
-
 #ifdef CONFIG_SYSCTL
+	dn_conf_path = register_sysctl_paths(dn_conf, empty);
 	{
@@ -1429,2 +1463,10 @@
 #endif /* CONFIG_SYSCTL */
+
+	dn_dev_devices_on();
+
+	rtnl_register(PF_DECnet, RTM_NEWADDR, dn_nl_newaddr, NULL, NULL);
+	rtnl_register(PF_DECnet, RTM_DELADDR, dn_nl_deladdr, NULL, NULL);
+	rtnl_register(PF_DECnet, RTM_GETADDR, NULL, dn_nl_dump_ifaddr, NULL);
+
+	proc_net_fops_create(&init_net, "decnet_dev", S_IRUGO, &dn_dev_seq_fops);
 }
@@ -1433,2 +1475,6 @@
 {
+	proc_net_remove(&init_net, "decnet_dev");
+
+	dn_dev_devices_off();
+
 #ifdef CONFIG_SYSCTL
@@ -1439,7 +1485,4 @@
 	}
+	unregister_sysctl_table(dn_conf_path);
 #endif /* CONFIG_SYSCTL */
-
-	proc_net_remove(&init_net, "decnet_dev");
-
-	dn_dev_devices_off();
 }
--- original/net/decnet/dn_route.c
+++ patched/net/decnet/dn_route.c
@@ -101,4 +101,3 @@

-
-static unsigned char dn_hiord_addr[6] = {0xAA,0x00,0x04,0x00,0x00,0x00};
+extern unsigned char dn_hiord[ETH_ALEN];

@@ -527,3 +526,3 @@
 	cb->dst = dn_eth2dn(ptr);
-	if (memcmp(ptr, dn_hiord_addr, 4) != 0)
+	if (memcmp(ptr, dn_hiord, 4) != 0)
 		goto drop_it;
@@ -535,3 +534,3 @@
 	cb->src = dn_eth2dn(ptr);
-	if (memcmp(ptr, dn_hiord_addr, 4) != 0)
+	if (memcmp(ptr, dn_hiord, 4) != 0)
 		goto drop_it;

--Apple-Mail-26-69471391
Content-Transfer-Encoding: 7bit
Content-Type: application/octet-stream;
	name="linux-3.5-decnet-sysctl.patch"
Content-Disposition: attachment;
	filename=linux-3.5-decnet-sysctl.patch

Title

linux-3.5-decnet-sysctl.patch

decnet kernel module patches for Linux 3.5 and later

Author

Larry Baker
US Geological Survey
baker@usgs.gov

Description

The decnet kernel module is configured using entries under /proc/sys/net/decnet.
There are executor settings in /proc/sys/net/decnet, template device settings
in /proc/sys/net/decnet/conf/{ddcmp,ethernet,ipgre,loopback}, and active device
settings for DECnet devices in /proc/sys/net/decnet/conf/{lo,eth0,...}.  All
Ethernet interfaces and the loopback interface are configured as DECnet devices
when the decnet kernel module is loaded.

The executor settings and template device settings are static; active device
settings are dynamic.  The active device settings for a network device are
copied from the appropriate template device settings when the network device is
configured as a DECnet device.  The active device settings are discarded when a
DECnet device is unconfigured (e.g., when the DECnet node address is set).

When the DECnet node address is set (e.g., by writing the new address to
/proc/sys/net/decnet/node_address) all DECnet devices are unconfigured, the new
DECnet node address is saved, and all Ethernet interfaces and the loopback
interface are reconfigured as DECnet devices.

When a DECnet device is unconfigured, its active device settings entries are
unregistered from the sysctl network namespace (/proc/sys/net).  When a DECnet
device is reconfigured, its active device settings entries are reregistered.

In kernel 2.6.27 the sysctl data structures were changed from a list to a tree.
The registration/unregistration behavior also changed.  As a result, when any
active device settings entries are unregistered, all the decnet kernel module
configuration settings entries in the sysctl network namespace are no longer
visible.  The only entries that are visible are the active device settings
entries that are reregistered when the DECnet devices are reconfigured.

The fix is to register an empty static /proc/sys/net/decnet/conf entry (ala
mkdir) before any of the (static or dynamic) entries beneath it are registered.
This workaround is not needed in 3.4 and later kernels.

After this patch, the registration order for sysctl entries is:

. Static executor entries in /proc/sys/net/decnet
. Static empty path entry /proc/sys/net/decnet/conf
. Static template device entries in /proc/sys/net/decnet/conf/<type>
. Dynamic active device entries in /proc/sys/net/decnet/conf/<dev-name>

Unregistration order is the reverse.

Other changes are:

. Updated banner
. DECnet device up/down KERN_INFO messages
. debug module parameter
. NETDEV_UP/DOWN KERN_DEBUG messages if (debug & 8)
. dn_route.c uses dn_hiord[ETH_ALEN] in dn_dev.c

--- original/net/decnet/af_decnet.c
+++ patched/net/decnet/af_decnet.c
@@ -1,2 +1 @@
-
 /*
@@ -42,2 +41,5 @@
  *                          prepare for sendpage etc.
+ *            Larry Baker : Register static /proc/sys/net/decnet entries before
+ *                          dynamic /proc/sys/net/decnet/conf entries in
+ *                          dn_dev_init().
  */
@@ -2090,2 +2092,4 @@
 	case NETDEV_UP:
+		if (decnet_debug_level & 8)
+			printk(KERN_DEBUG "DECnet: %s NETDEV_UP", dev->name);
 		dn_dev_up(dev);
@@ -2093,2 +2097,4 @@
 	case NETDEV_DOWN:
+		if (decnet_debug_level & 8)
+			printk(KERN_DEBUG "DECnet: %s NETDEV_DOWN", dev->name);
 		dn_dev_down(dev);
@@ -2363,3 +2369,3 @@

-static char banner[] __initdata = KERN_INFO "NET4: DECnet for Linux: V.2.5.68s (C) 1995-2003 Linux DECnet Project Team\n";
+static char banner[] __initdata = KERN_INFO "DECnet: DECnet for Linux: V.3.5 (C) 1995-2013 Linux DECnet Project Team\n";

@@ -2375,2 +2381,4 @@

+	dn_register_sysctl();
+
 	dn_neigh_init();
@@ -2385,3 +2393,2 @@
 	proc_net_fops_create(&init_net, "decnet", S_IRUGO, &dn_socket_seq_fops);
-	dn_register_sysctl();
 out:
@@ -2404,4 +2411,2 @@

-	dn_unregister_sysctl();
-
 	unregister_netdevice_notifier(&dn_dev_notifier);
@@ -2413,2 +2418,4 @@

+	dn_unregister_sysctl();
+
 	proc_net_remove(&init_net, "decnet");
--- original/net/decnet/dn_dev.c
+++ patched/net/decnet/dn_dev.c
@@ -24,2 +24,6 @@
  *                             devices. All mtu based now.
+ *               Larry Baker : Register empty static /proc/sys/net/decnet/conf
+ *                             before registering any entries beneath it due to
+ *                             tree-based sysctl tables since kernel 2.6.27.
+ *                             Workaround not needed in 3.4 and later kernels.
  */
@@ -60,3 +64,3 @@
 static char dn_rt_all_rt_mcast[ETH_ALEN]  = {0xAB,0x00,0x00,0x03,0x00,0x00};
-static char dn_hiord[ETH_ALEN]            = {0xAA,0x00,0x04,0x00,0x00,0x00};
+unsigned char dn_hiord[ETH_ALEN]          = {0xAA,0x00,0x04,0x00,0x00,0x00};
 static unsigned char dn_eco_version[3]    = {0x02,0x00,0x00};
@@ -162,2 +166,5 @@
 			void __user *, size_t *, loff_t *);
+
+static struct ctl_table_header *dn_conf_path = NULL;
+
 static struct dn_dev_sysctl_table {
@@ -206,2 +213,8 @@

+static ctl_table empty[] = {
+        { }
+};
+
+static const char dn_conf[] = "net/decnet/conf";
+
 static void dn_dev_sysctl_register(struct net_device *dev, struct dn_dev_parms *parms)
@@ -211,3 +224,3 @@

-	char path[sizeof("net/decnet/conf/") + IFNAMSIZ];
+	char dn_ctl_path[sizeof(dn_conf) + 1 + IFNAMSIZ];

@@ -222,4 +235,4 @@

-	snprintf(path, sizeof(path), "net/decnet/conf/%s",
-		dev? dev->name : parms->name);
+	snprintf(dn_ctl_path, sizeof(dn_ctl_path), "%s/%s", dn_conf,
+		dev ? dev->name : parms->name);

@@ -227,3 +240,3 @@

-	t->sysctl_header = register_net_sysctl(&init_net, path, t->dn_dev_vars);
+	t->sysctl_header = register_net_sysctl(&init_net, dn_ctl_path, t->dn_dev_vars);
 	if (t->sysctl_header == NULL)
@@ -1131,2 +1144,3 @@
 	struct dn_dev *dn_db = rtnl_dereference(dev->dn_ptr);
+	char dn_ascbuf[DN_ASCBUF_LEN];

@@ -1168,2 +1182,5 @@

+	dn_addr2asc(le16_to_cpu(addr), dn_ascbuf);
+	printk(KERN_INFO "DECnet: %s up [%s]", dev->name, dn_ascbuf);
+
 	/*
@@ -1211,2 +1228,3 @@
 	struct dn_ifaddr *ifa;
+	__le16 addr = decnet_address;

@@ -1221,2 +1239,14 @@
 	dn_dev_delete(dev);
+
+	if (dev->type == ARPHRD_ETHER) {
+		if (memcmp(dev->dev_addr, dn_hiord, 4) != 0)
+			return;
+		addr = dn_eth2dn(dev->dev_addr);
+	}
+
+	if (addr == 0)
+		return;
+
+	printk(KERN_INFO "DECnet: %s down", dev->name);
+
 }
@@ -1384,2 +1414,6 @@

+static int debug = 0;
+module_param(debug, int, 0444);
+MODULE_PARM_DESC(debug, "Debug level");
+
 static int addr[2];
@@ -1390,2 +1424,4 @@
 {
+	decnet_debug_level = debug;
+
 	if (addr[0] > 63 || addr[0] < 0) {
@@ -1402,11 +1438,4 @@

-	dn_dev_devices_on();
-
-	rtnl_register(PF_DECnet, RTM_NEWADDR, dn_nl_newaddr, NULL, NULL);
-	rtnl_register(PF_DECnet, RTM_DELADDR, dn_nl_deladdr, NULL, NULL);
-	rtnl_register(PF_DECnet, RTM_GETADDR, NULL, dn_nl_dump_ifaddr, NULL);
-
-	proc_net_fops_create(&init_net, "decnet_dev", S_IRUGO, &dn_dev_seq_fops);
-
 #ifdef CONFIG_SYSCTL
+	dn_conf_path = register_net_sysctl(&init_net, dn_conf, empty);
 	{
@@ -1417,2 +1446,10 @@
 #endif /* CONFIG_SYSCTL */
+
+	dn_dev_devices_on();
+
+	rtnl_register(PF_DECnet, RTM_NEWADDR, dn_nl_newaddr, NULL, NULL);
+	rtnl_register(PF_DECnet, RTM_DELADDR, dn_nl_deladdr, NULL, NULL);
+	rtnl_register(PF_DECnet, RTM_GETADDR, NULL, dn_nl_dump_ifaddr, NULL);
+
+	proc_net_fops_create(&init_net, "decnet_dev", S_IRUGO, &dn_dev_seq_fops);
 }
@@ -1421,2 +1458,6 @@
 {
+	proc_net_remove(&init_net, "decnet_dev");
+
+	dn_dev_devices_off();
+
 #ifdef CONFIG_SYSCTL
@@ -1427,7 +1468,4 @@
 	}
+	unregister_net_sysctl_table(dn_conf_path);
 #endif /* CONFIG_SYSCTL */
-
-	proc_net_remove(&init_net, "decnet_dev");
-
-	dn_dev_devices_off();
 }
--- original/net/decnet/dn_route.c
+++ patched/net/decnet/dn_route.c
@@ -102,4 +102,3 @@

-
-static unsigned char dn_hiord_addr[6] = {0xAA,0x00,0x04,0x00,0x00,0x00};
+extern unsigned char dn_hiord[ETH_ALEN];

@@ -528,3 +527,3 @@
 	cb->dst = dn_eth2dn(ptr);
-	if (memcmp(ptr, dn_hiord_addr, 4) != 0)
+	if (memcmp(ptr, dn_hiord, 4) != 0)
 		goto drop_it;
@@ -536,3 +535,3 @@
 	cb->src = dn_eth2dn(ptr);
-	if (memcmp(ptr, dn_hiord_addr, 4) != 0)
+	if (memcmp(ptr, dn_hiord, 4) != 0)
 		goto drop_it;

--Apple-Mail-26-69471391
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii



. linux-2.6.27-decnet-sysctl.patch

  decnet kernel module patches for Linux 2.6.27 through 2.6.32 =
(tree-structured sysctl, struct ctl_path includes .ctl_name)

. linux-2.6.33-decnet-sysctl.patch

  decnet kernel module patches for Linux 2.6.33 through 3.4.x (struct =
ctl_path no longer includes .ctl_name, rtnl_register() adds =
rtnl_calcit_func calcit)

. linux-3.5-decnet-sysctl.patch

  decnet kernel module patches for Linux 3.5 and later =
(register_net_sysctl()/unregister_net_sysctl_table() in place of =
register_sysctl_paths()/unregister_sysctl_table())

I am running linux-2.6.27-decnet-sysctl.patch on a CentOS 6.3 x86_64 =
system (Linux atompc.wr.usgs.gov 2.6.32-279.19.1.el6.x86_64 #1 SMP Wed =
Dec 19 07:05:20 UTC 2012 x86_64 x86_64 x86_64 GNU/Linux).

I am running linux-2.6.33-decnet-sysctl.patch on an Arch Linux ARM =
3.1.10 system (Linux sheeva 3.1.10-15-ARCH #1 PREEMPT Wed Dec 12 =
15:25:18 UTC 2012 armv5tel GNU/Linux).

I do not have the ability to test linux-3.5-decnet-sysctl.patch.  I =
compared linux-2.6.33-decnet-sysctl.patch to =
linux-3.5-decnet-sysctl.patch, and inspected the patched files visually.

Description

The decnet kernel module is configured using entries under =
/proc/sys/net/decnet.  There are executor settings in =
/proc/sys/net/decnet, template device settings in =
/proc/sys/net/decnet/conf/{ddcmp,ethernet,ipgre,loopback}, and active =
device settings for DECnet devices in =
/proc/sys/net/decnet/conf/{lo,eth0,...}.  All Ethernet interfaces and =
the loopback interface are configured as DECnet devices when the decnet =
kernel module is loaded.

The executor settings and template device settings are static; active =
device settings are dynamic.  The active device settings for a network =
device are copied from the appropriate template device settings when the =
network device is configured as a DECnet device.  The active device =
settings are discarded when a DECnet device is unconfigured (e.g., when =
the DECnet node address is set).

When the DECnet node address is set (e.g., by writing the new address to =
/proc/sys/net/decnet/node_address) all DECnet devices are unconfigured, =
the new DECnet node address is saved, and all Ethernet interfaces and =
the loopback interface are reconfigured as DECnet devices.

When a DECnet device is unconfigured, its active device settings entries =
are unregistered from the sysctl network namespace (/proc/sys/net).  =
When a DECnet device is reconfigured, its active device settings entries =
are reregistered.

In kernel 2.6.27 the sysctl data structures were changed from a list to =
a tree.  The registration/unregistration behavior also changed.  As a =
result, when any active device settings entries are unregistered, all =
the decnet kernel module configuration settings entries in the sysctl =
network namespace are no longer visible.  The only entries that are =
visible are the active device settings entries that are reregistered =
when the DECnet devices are reconfigured.

The fix is to register an empty static /proc/sys/net/decnet/conf entry =
(ala mkdir) before any of the (static or dynamic) entries beneath it are =
registered.  This workaround is not needed in 3.4 and later kernels.

After this patch, the registration order for sysctl entries is:

. Static executor entries in /proc/sys/net/decnet
. Static empty path entry /proc/sys/net/decnet/conf
. Static template device entries in /proc/sys/net/decnet/conf/<type>
. Dynamic active device entries in /proc/sys/net/decnet/conf/<dev-name>

Unregistration order is the reverse.

Other changes are:

. Updated banner
. DECnet device up/down KERN_INFO messages
. debug module parameter
. NETDEV_UP/DOWN KERN_DEBUG messages if (debug & 8)
. dn_route.c uses dn_hiord[ETH_ALEN] in dn_dev.c

Larry Baker
US Geological Survey
650-329-5608
baker@usgs.gov


--Apple-Mail-26-69471391--
