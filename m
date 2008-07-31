From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [patch 3/4] Configure out ethtool support
Date: Thu, 31 Jul 2008 11:27:06 +0200
Message-ID: <20080731093221.236840420@free-electrons.com>
References: <20080731092703.661994657@free-electrons.com>
Cc: michael@free-electrons.com,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Matt Mackall <mpm@selenic.com>, jgarzik@pobox.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org
To: linux-kernel@vger.kernel.org, linux-embedded@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.191.46.45]:55002 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752983AbYGaJca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 05:32:30 -0400
Content-Disposition: inline; filename=configure-out-ethtool-support
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchs add the CONFIG_ETHTOOL option which allows to remove
support for ethtool, not necessarly used on embedded systems. As this
is a size-reduction option, it depends on CONFIG_EMBEDDED. It allows
to save ~6 kilobytes of kernel code:

   text	   data	    bss	    dec	    hex	filename
1258447	 123592	 212992	1595031	 185697	vmlinux
1252147	 123592	 212992	1588731	 183dfb	vmlinux.new
  -6300       0       0   -6300   -189C +/-

Bonding and bridging both depends on Ethtool functionnality, so
ETHTOOL is selected automatically when either bonding and bridging are
selected.

Question: should we also remove ethtool-related functions from all
network drivers ?

This patch has been originally written by Matt Mackall
<mpm@selenic.com>, and is part of the Linux Tiny project.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Signed-off-by: Matt Mackall <mpm@selenic.com>
Cc: jgarzik@pobox.com
Cc: netdev@vger.kernel.org
Cc: davem@davemloft.net
Cc: mpm@selenic.com
Cc: akpm@linux-foundation.org

---
 drivers/net/Kconfig     |    1 +
 include/linux/ethtool.h |   16 ++++++++++++++++
 init/Kconfig            |    8 ++++++++
 net/bridge/Kconfig      |    1 +
 net/core/Makefile       |    3 ++-
 net/core/dev.c          |    4 ++++
 6 files changed, 32 insertions(+), 1 deletion(-)

Index: linuxdev/drivers/net/Kconfig
===================================================================
--- linuxdev.orig/drivers/net/Kconfig
+++ linuxdev/drivers/net/Kconfig
@@ -61,6 +61,7 @@
 config BONDING
 	tristate "Bonding driver support"
 	depends on INET
+	select ETHTOOL
 	---help---
 	  Say 'Y' or 'M' if you wish to be able to 'bond' multiple Ethernet
 	  Channels together. This is called 'Etherchannel' by Cisco,
Index: linuxdev/include/linux/ethtool.h
===================================================================
--- linuxdev.orig/include/linux/ethtool.h
+++ linuxdev/include/linux/ethtool.h
@@ -283,6 +283,7 @@
 struct net_device;
 
 /* Some generic methods drivers may use in their ethtool_ops */
+#ifdef CONFIG_ETHTOOL
 u32 ethtool_op_get_link(struct net_device *dev);
 u32 ethtool_op_get_tx_csum(struct net_device *dev);
 int ethtool_op_set_tx_csum(struct net_device *dev, u32 data);
@@ -296,6 +297,21 @@
 int ethtool_op_set_ufo(struct net_device *dev, u32 data);
 u32 ethtool_op_get_flags(struct net_device *dev);
 int ethtool_op_set_flags(struct net_device *dev, u32 data);
+#else
+static inline u32 ethtool_op_get_link(struct net_device *dev) { return 0; }
+static inline u32 ethtool_op_get_tx_csum(struct net_device *dev) { return 0; }
+static inline int ethtool_op_set_tx_csum(struct net_device *dev, u32 data) { return 0; }
+static inline int ethtool_op_set_tx_hw_csum(struct net_device *dev, u32 data) { return 0; }
+static inline int ethtool_op_set_tx_ipv6_csum(struct net_device *dev, u32 data) { return 0; }
+static inline u32 ethtool_op_get_sg(struct net_device *dev) { return 0; }
+static inline int ethtool_op_set_sg(struct net_device *dev, u32 data) { return 0; }
+static inline u32 ethtool_op_get_tso(struct net_device *dev) { return 0; }
+static inline int ethtool_op_set_tso(struct net_device *dev, u32 data) { return 0; }
+static inline u32 ethtool_op_get_ufo(struct net_device *dev) { return 0; }
+static inline int ethtool_op_set_ufo(struct net_device *dev, u32 data) { return 0; }
+static inline u32 ethtool_op_get_flags(struct net_device *dev) { return 0; }
+static inline int ethtool_op_set_flags(struct net_device *dev, u32 data) { return 0; }
+#endif
 
 /**
  * &ethtool_ops - Alter and report network device settings
Index: linuxdev/init/Kconfig
===================================================================
--- linuxdev.orig/init/Kconfig
+++ linuxdev/init/Kconfig
@@ -740,6 +740,14 @@
           for filesystems like NFS and for the flock() system
           call. Disabling this option saves about 11k.
 
+config ETHTOOL
+	bool "Enable ethtool support" if EMBEDDED
+	depends on NET
+	default y
+	help
+	  Disabling this option removes support for configuring
+	  ethernet device features via ethtool. Saves about 6k.
+
 config VM_EVENT_COUNTERS
 	default y
 	bool "Enable VM event counters for /proc/vmstat" if EMBEDDED
Index: linuxdev/net/bridge/Kconfig
===================================================================
--- linuxdev.orig/net/bridge/Kconfig
+++ linuxdev/net/bridge/Kconfig
@@ -6,6 +6,7 @@
 	tristate "802.1d Ethernet Bridging"
 	select LLC
 	select STP
+	select ETHTOOL
 	---help---
 	  If you say Y here, then your Linux box will be able to act as an
 	  Ethernet bridge, which means that the different Ethernet segments it
Index: linuxdev/net/core/Makefile
===================================================================
--- linuxdev.orig/net/core/Makefile
+++ linuxdev/net/core/Makefile
@@ -7,10 +7,11 @@
 
 obj-$(CONFIG_SYSCTL) += sysctl_net_core.o
 
-obj-y		     += dev.o ethtool.o dev_mcast.o dst.o netevent.o \
+obj-y		     += dev.o dev_mcast.o dst.o netevent.o \
 			neighbour.o rtnetlink.o utils.o link_watch.o filter.o
 
 obj-$(CONFIG_XFRM) += flow.o
+obj-$(CONFIG_ETHTOOL) += ethtool.o
 obj-y += net-sysfs.o
 obj-$(CONFIG_NET_PKTGEN) += pktgen.o
 obj-$(CONFIG_NETPOLL) += netpoll.o
Index: linuxdev/net/core/dev.c
===================================================================
--- linuxdev.orig/net/core/dev.c
+++ linuxdev/net/core/dev.c
@@ -3669,6 +3669,7 @@
 			return ret;
 
 		case SIOCETHTOOL:
+#ifdef CONFIG_ETHTOOL
 			dev_load(net, ifr.ifr_name);
 			rtnl_lock();
 			ret = dev_ethtool(net, &ifr);
@@ -3681,6 +3682,9 @@
 					ret = -EFAULT;
 			}
 			return ret;
+#else
+			return -EINVAL;
+#endif
 
 		/*
 		 *	These ioctl calls:

-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers and embedded Linux development,
consulting, training and support.
http://free-electrons.com
