From: akpm@linux-foundation.org
Subject: [patch 12/12] Configure out ethtool support
Date: Wed, 30 Jul 2008 12:39:04 -0700
Message-ID: <200807301939.m6UJd5lT012610@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	thomas.petazzoni@free-electrons.com, davem@davemloft.net,
	mpm@selenic.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40051 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754027AbYG3Txt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 15:53:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

Add the CONFIG_ETHTOOL option which allows to remove support for ethtool,
not necessarly used on embedded systems.  As this is a size-reduction
option, it depends on CONFIG_EMBEDDED.  It allows to save ~6 kilobytes of
kernel code:

   text	   data	    bss	    dec	    hex	filename
1258447	 123592	 212992	1595031	 185697	vmlinux
1252147	 123592	 212992	1588731	 183dfb	vmlinux.new
  -6300       0       0   -6300   -189C +/-

Question: should we also remove ethtool-related functions from all network
drivers ?

This patch has been originally written by Matt Mackall
<mpm@selenic.com>, and is part of the Linux Tiny project.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Cc: Matt Mackall <mpm@selenic.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/ethtool.h |   16 ++++++++++++++++
 init/Kconfig            |    8 ++++++++
 net/core/Makefile       |    3 ++-
 net/core/dev.c          |    4 ++++
 4 files changed, 30 insertions(+), 1 deletion(-)

diff -puN include/linux/ethtool.h~configure-out-ethtool-support include/linux/ethtool.h
--- a/include/linux/ethtool.h~configure-out-ethtool-support
+++ a/include/linux/ethtool.h
@@ -283,6 +283,7 @@ struct ethtool_rxnfc {
 struct net_device;
 
 /* Some generic methods drivers may use in their ethtool_ops */
+#ifdef CONFIG_ETHTOOL
 u32 ethtool_op_get_link(struct net_device *dev);
 u32 ethtool_op_get_tx_csum(struct net_device *dev);
 int ethtool_op_set_tx_csum(struct net_device *dev, u32 data);
@@ -296,6 +297,21 @@ u32 ethtool_op_get_ufo(struct net_device
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
diff -puN init/Kconfig~configure-out-ethtool-support init/Kconfig
--- a/init/Kconfig~configure-out-ethtool-support
+++ a/init/Kconfig
@@ -732,6 +732,14 @@ config IGMP
 	  Disabling this option removes support for the Internet group
           management protocol, used for multicast. Saves about 10k.
 
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
diff -puN net/core/Makefile~configure-out-ethtool-support net/core/Makefile
--- a/net/core/Makefile~configure-out-ethtool-support
+++ a/net/core/Makefile
@@ -7,10 +7,11 @@ obj-y := sock.o request_sock.o skbuff.o 
 
 obj-$(CONFIG_SYSCTL) += sysctl_net_core.o
 
-obj-y		     += dev.o ethtool.o dev_mcast.o dst.o netevent.o \
+obj-y		     += dev.o dev_mcast.o dst.o netevent.o \
 			neighbour.o rtnetlink.o utils.o link_watch.o filter.o
 
 obj-$(CONFIG_XFRM) += flow.o
+obj-$(CONFIG_ETHTOOL) += ethtool.o
 obj-y += net-sysfs.o
 obj-$(CONFIG_NET_PKTGEN) += pktgen.o
 obj-$(CONFIG_NETPOLL) += netpoll.o
diff -puN net/core/dev.c~configure-out-ethtool-support net/core/dev.c
--- a/net/core/dev.c~configure-out-ethtool-support
+++ a/net/core/dev.c
@@ -3669,6 +3669,7 @@ int dev_ioctl(struct net *net, unsigned 
 			return ret;
 
 		case SIOCETHTOOL:
+#ifdef CONFIG_ETHTOOL
 			dev_load(net, ifr.ifr_name);
 			rtnl_lock();
 			ret = dev_ethtool(net, &ifr);
@@ -3681,6 +3682,9 @@ int dev_ioctl(struct net *net, unsigned 
 					ret = -EFAULT;
 			}
 			return ret;
+#else
+			return -EINVAL;
+#endif
 
 		/*
 		 *	These ioctl calls:
_
