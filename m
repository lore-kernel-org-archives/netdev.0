From: Matthew Wilcox <willy@debian.org>
Subject: [PATCH] more CONFIG_NET removals
Date: Fri, 20 Jun 2003 12:25:04 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030620112504.GM24357@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Anyone see a problem with this patch against 2.5.72?  It worksforme.

 - Remove CONFIG_NET from files which are no longer built when
   CONFIG_NET isn't set.
 - Redo Makefiles a little to remove some ifeqs.  Also don't build
   compat.o if CONFIG_NET is unset.
 - Remove ifdefs around extern declarations
 - Remove <linux/mm.h> from sysctl_net.c

Index: net/Makefile
===================================================================
RCS file: /var/cvs/linux-2.5/net/Makefile,v
retrieving revision 1.11
diff -u -p -r1.11 Makefile
--- net/Makefile	8 Apr 2003 15:20:57 -0000	1.11
+++ net/Makefile	20 Jun 2003 10:45:38 -0000
@@ -7,9 +7,10 @@
 
 obj-y	:= nonet.o
 
-obj-$(CONFIG_NET)		:= socket.o core/
-
-obj-$(CONFIG_COMPAT)		+= compat.o
+net-$(CONFIG_COMPAT)		+= compat.o
+net-$(CONFIG_MODULES)		+= netsyms.o
+net-$(CONFIG_SYSCTL)		+= sysctl_net.o
+obj-$(CONFIG_NET)		:= socket.o core/ $(net-y)
 
 # LLC has to be linked before the files in net/802/
 obj-$(CONFIG_LLC)		+= llc/
@@ -38,8 +39,3 @@ obj-$(CONFIG_DECNET)		+= decnet/
 obj-$(CONFIG_ECONET)		+= econet/
 obj-$(CONFIG_VLAN_8021Q)	+= 8021q/
 obj-$(CONFIG_IP_SCTP)		+= sctp/
-
-ifeq ($(CONFIG_NET),y)
-obj-$(CONFIG_MODULES)		+= netsyms.o
-obj-$(CONFIG_SYSCTL)		+= sysctl_net.o
-endif
Index: net/netsyms.c
===================================================================
RCS file: /var/cvs/linux-2.5/net/netsyms.c,v
retrieving revision 1.22
diff -u -p -r1.22 netsyms.c
--- net/netsyms.c	14 Jun 2003 22:16:08 -0000	1.22
+++ net/netsyms.c	20 Jun 2003 10:45:38 -0000
@@ -36,12 +36,9 @@
 #include <linux/divert.h>
 #endif /* CONFIG_NET_DIVERT */
 
-#ifdef CONFIG_NET
 extern __u32 sysctl_wmem_max;
 extern __u32 sysctl_rmem_max;
-#endif
 
-#ifdef CONFIG_INET
 #include <linux/ip.h>
 #include <net/protocol.h>
 #include <net/arp.h>
@@ -80,8 +77,6 @@ extern int tcp_port_rover;
 extern int udp_port_rover;
 #endif
 
-#endif
-
 #include <linux/rtnetlink.h>
 
 #ifdef CONFIG_IPX_MODULE
@@ -557,7 +552,6 @@ EXPORT_SYMBOL(unregister_netdevice_notif
 EXPORT_SYMBOL(call_netdevice_notifiers);
 
 /* support for loadable net drivers */
-#ifdef CONFIG_NET
 EXPORT_SYMBOL(loopback_dev);
 EXPORT_SYMBOL(register_netdevice);
 EXPORT_SYMBOL(unregister_netdevice);
@@ -693,5 +687,3 @@ EXPORT_SYMBOL(wireless_spy_update);
 #endif	/* CONFIG_NET_RADIO */
 
 EXPORT_SYMBOL(linkwatch_fire_event);
-
-#endif  /* CONFIG_NET */
Index: net/sysctl_net.c
===================================================================
RCS file: /var/cvs/linux-2.5/net/sysctl_net.c,v
retrieving revision 1.3
diff -u -p -r1.3 sysctl_net.c
--- net/sysctl_net.c	30 Aug 2002 20:00:44 -0000	1.3
+++ net/sysctl_net.c	20 Jun 2003 10:45:38 -0000
@@ -13,26 +13,13 @@
  */
 
 #include <linux/config.h>
-#include <linux/mm.h>
 #include <linux/sysctl.h>
 
-#ifdef CONFIG_INET
 extern struct ctl_table ipv4_table[];
-#endif
-
 extern struct ctl_table core_table[];
-
-#ifdef CONFIG_NET
 extern struct ctl_table ether_table[];
-#endif
-
-#ifdef CONFIG_IPV6
 extern struct ctl_table ipv6_table[];
-#endif
-
-#ifdef CONFIG_TR
 extern struct ctl_table tr_table[];
-#endif
 
 struct ctl_table net_table[] = {
 	{
@@ -41,14 +28,12 @@ struct ctl_table net_table[] = {
 		.mode		= 0555,
 		.child		= core_table,
 	},
-#ifdef CONFIG_NET
 	{
 		.ctl_name	= NET_ETHER,
 		.procname	= "ethernet",
 		.mode		= 0555,
 		.child		= ether_table,
 	},
-#endif
 #ifdef CONFIG_INET
 	{
 		.ctl_name	= NET_IPV4,
Index: net/core/Makefile
===================================================================
RCS file: /var/cvs/linux-2.5/net/core/Makefile,v
retrieving revision 1.9
diff -u -p -r1.9 Makefile
--- net/core/Makefile	27 May 2003 17:29:33 -0000	1.9
+++ net/core/Makefile	20 Jun 2003 10:45:38 -0000
@@ -4,13 +4,9 @@
 
 obj-y := sock.o skbuff.o iovec.o datagram.o scm.o
 
-ifeq ($(CONFIG_SYSCTL),y)
-ifeq ($(CONFIG_NET),y)
-obj-y += sysctl_net_core.o
-endif
-endif
+obj-$(CONFIG_SYSCTL) += sysctl_net_core.o
 
-obj-$(CONFIG_NET) += flow.o dev.o net-sysfs.o dev_mcast.o dst.o neighbour.o \
+obj-y += flow.o dev.o net-sysfs.o dev_mcast.o dst.o neighbour.o \
 		     rtnetlink.o utils.o link_watch.o filter.o
 
 obj-$(CONFIG_NETFILTER) += netfilter.o
Index: net/core/sysctl_net_core.c
===================================================================
RCS file: /var/cvs/linux-2.5/net/core/sysctl_net_core.c,v
retrieving revision 1.4
diff -u -p -r1.4 sysctl_net_core.c
--- net/core/sysctl_net_core.c	5 May 2003 17:09:51 -0000	1.4
+++ net/core/sysctl_net_core.c	20 Jun 2003 10:45:38 -0000
@@ -34,7 +34,6 @@ extern char sysctl_divert_version[];
 #endif /* CONFIG_NET_DIVERT */
 
 ctl_table core_table[] = {
-#ifdef CONFIG_NET
 	{
 		.ctl_name	= NET_CORE_WMEM_MAX,
 		.procname	= "wmem_max",
@@ -159,7 +158,6 @@ ctl_table core_table[] = {
 		.proc_handler	= &proc_dostring
 	},
 #endif /* CONFIG_NET_DIVERT */
-#endif /* CONFIG_NET */
 	{ .ctl_name = 0 }
 };
 #endif

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
