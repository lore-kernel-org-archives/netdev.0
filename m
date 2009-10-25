From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [RFC] make per interface sysctl entries configurable
Date: Sun, 25 Oct 2009 19:54:49 +0200
Message-ID: <200910251954.49700.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_pDJ5KEpKdYtD27J"
Cc: Benjamin LaHaise <bcrl@lhnet.ca>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cosmin Ratiu <cratiu@ixiacom.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:21687 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752843AbZJYR5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2009 13:57:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_pDJ5KEpKdYtD27J
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit


RFC patches are attached.

Another possible approach: add an interface flag and use it to decide whether 
we want per interface sysctl entries or not.

Benchmarks for creating 1000 interface (with the ndst module previously posted 
on the list, ppc750 @800Mhz machine):

- without the patches:

real    4m 38.27s
user    0m 0.00s
sys     2m 18.90s

- with the patches:

real    0m 0.10s
user    0m 0.00s
sys     0m 0.05s

Thanks,
tavi

--Boundary-00=_pDJ5KEpKdYtD27J
Content-Type: text/x-patch;
  charset="us-ascii";
  name="818108.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="818108.diff"

net: CONFIG_NET_SYSCTL_DEV: make per interface dev_snmp6 proc entries optional
        
Use same CONFIG_NET_SYSCTL_DEV config option (we should probably
rename it to a better name) to enable/disable per interface dev_snmp6
proc entries.

--- //packages/linux_2.6.31/rc7/src/arch/powerpc/configs/ixia_ppc750_defconfig
+++ //packages/linux_2.6.31/rc7/src/arch/powerpc/configs/ixia_ppc750_defconfig
@@ -287,6 +287,7 @@
 #
 # Networking options
 #
+# CONFIG_NET_SYSCTL_DEV is not set
 CONFIG_PACKET=y
 CONFIG_PACKET_MMAP=y
 CONFIG_UNIX=y
--- //packages/linux_2.6.31/rc7/src/net/Kconfig
+++ //packages/linux_2.6.31/rc7/src/net/Kconfig
@@ -25,6 +25,15 @@
 
 menu "Networking options"
 
+config NET_SYSCTL_DEV
+	bool "Per device sysctl entries"
+	default y
+	depends on SYSCTL
+	help
+	  Enables per device sysctl entries. You want this enabled unless
+	  your system has a large number of interfaces and you want to reduce
+	  memory usage.
+
 source "net/packet/Kconfig"
 source "net/unix/Kconfig"
 source "net/xfrm/Kconfig"
--- //packages/linux_2.6.31/rc7/src/net/ipv4/devinet.c
+++ //packages/linux_2.6.31/rc7/src/net/ipv4/devinet.c
@@ -97,7 +97,7 @@
 static BLOCKING_NOTIFIER_HEAD(inetaddr_chain);
 static void inet_del_ifa(struct in_device *in_dev, struct in_ifaddr **ifap,
 			 int destroy);
-#ifdef CONFIG_SYSCTL
+#ifdef CONFIG_NET_SYSCTL_DEV
 static void devinet_sysctl_register(struct in_device *idev);
 static void devinet_sysctl_unregister(struct in_device *idev);
 #else
@@ -1397,7 +1397,6 @@
 	return ret;
 }
 
-
 #define DEVINET_SYSCTL_ENTRY(attr, name, mval, proc, sysctl) \
 	{ \
 		.ctl_name	= NET_IPV4_CONF_ ## attr, \
@@ -1531,6 +1530,7 @@
 	kfree(t);
 }
 
+#ifdef CONFIG_NET_SYSCTL_DEV
 static void devinet_sysctl_register(struct in_device *idev)
 {
 	neigh_sysctl_register(idev->dev, idev->arp_parms, NET_IPV4,
@@ -1544,6 +1544,7 @@
 	__devinet_sysctl_unregister(&idev->cnf);
 	neigh_sysctl_unregister(idev->arp_parms);
 }
+#endif
 
 static struct ctl_table ctl_forward_entry[] = {
 	{
--- //packages/linux_2.6.31/rc7/src/net/ipv6/addrconf.c
+++ //packages/linux_2.6.31/rc7/src/net/ipv6/addrconf.c
@@ -100,7 +100,7 @@
 #define	INFINITY_LIFE_TIME	0xFFFFFFFF
 #define TIME_DELTA(a,b) ((unsigned long)((long)(a) - (long)(b)))
 
-#ifdef CONFIG_SYSCTL
+#ifdef CONFIG_NET_SYSCTL_DEV
 static void addrconf_sysctl_register(struct inet6_dev *idev);
 static void addrconf_sysctl_unregister(struct inet6_dev *idev);
 #else
@@ -4412,6 +4412,7 @@
 	kfree(t);
 }
 
+#ifdef CONFIG_NET_SYSCTL_DEV
 static void addrconf_sysctl_register(struct inet6_dev *idev)
 {
 	neigh_sysctl_register(idev->dev, idev->nd_parms, NET_IPV6,
@@ -4427,7 +4428,7 @@
 	__addrconf_sysctl_unregister(&idev->cnf);
 	neigh_sysctl_unregister(idev->nd_parms);
 }
-
+#endif
 
 #endif
 

--Boundary-00=_pDJ5KEpKdYtD27J
Content-Type: text/x-patch;
  charset="us-ascii";
  name="818110.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="818110.diff"

net: CONFIG_NET_SYSCTL_DEV: make per interface dev_snmp6 proc entries optional
        
Use same CONFIG_NET_SYSCTL_DEV config option (we should probably
rename it to a better name) to enable/disable per interface dev_snmp6
proc entries.

--- //packages/linux_2.6.31/rc7/src/include/net/ipv6.h
+++ //packages/linux_2.6.31/rc7/src/include/net/ipv6.h
@@ -604,8 +604,14 @@
 extern void udplite6_proc_exit(void);
 extern int  ipv6_misc_proc_init(void);
 extern void ipv6_misc_proc_exit(void);
+
+#ifdef CONFIG_NET_SYSCTL_DEV
 extern int snmp6_register_dev(struct inet6_dev *idev);
 extern int snmp6_unregister_dev(struct inet6_dev *idev);
+#else
+static inline int snmp6_register_dev(struct inet6_dev *idev) { return 0; }
+static inline int snmp6_unregister_dev(struct inet6_dev *idev) { return 0; }
+#endif
 
 #else
 static inline int ac6_proc_init(struct net *net) { return 0; }
--- //packages/linux_2.6.31/rc7/src/net/ipv6/proc.c
+++ //packages/linux_2.6.31/rc7/src/net/ipv6/proc.c
@@ -232,6 +232,7 @@
 	.release = single_release,
 };
 
+#ifdef CONFIG_NET_SYSCTL_DEV
 int snmp6_register_dev(struct inet6_dev *idev)
 {
 	struct proc_dir_entry *p;
@@ -266,6 +267,7 @@
 	idev->stats.proc_dir_entry = NULL;
 	return 0;
 }
+#endif
 
 static int ipv6_proc_init_net(struct net *net)
 {

--Boundary-00=_pDJ5KEpKdYtD27J--
