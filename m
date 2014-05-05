From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 09/24] net, diet: Make ethtool optional
Date: Mon,  5 May 2014 15:25:58 -0700
Message-ID: <1399328773-6531-10-git-send-email-andi@firstfloor.org>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, tom.zanussi@linux.intel.com,
	Andi Kleen <ak@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58941 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933110AbaEEW0X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 May 2014 18:26:23 -0400
In-Reply-To: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <ak@linux.intel.com>

Small embedded systems don't need ethtool, so make it optional.

Right now the driver code is not removed, unless the driver
uses SET_ETHTOOL_OPS and LTO (which can eliminate unused code)

Saves about 10k text(without driver code):

   text	   data	    bss	    dec	    hex	filename
 489877	  19371	  13480	 522728	  7f9e8	net/built-in.o
 478967	  19369	  13480	 511816	  7cf48	net/built-in.o-wo-ethtool

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 include/linux/ethtool.h   | 14 ++++++++++++++
 include/linux/netdevice.h | 21 ++++++++++++++++++---
 net/Kconfig               |  6 ++++++
 net/core/Makefile         |  3 ++-
 net/core/dev.c            |  2 ++
 5 files changed, 42 insertions(+), 4 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 0a114d0..e90c958 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -40,8 +40,14 @@ struct compat_ethtool_rxnfc {
 
 #include <linux/rculist.h>
 
+#ifdef CONFIG_NET_ETHTOOL
 extern int __ethtool_get_settings(struct net_device *dev,
 				  struct ethtool_cmd *cmd);
+#else
+static inline int __ethtool_get_settings(struct net_device *dev,
+					 struct ethtool_cmd *cmd)
+{ return -EINVAL; }
+#endif
 
 /**
  * enum ethtool_phys_id_state - indicator state for physical identification
@@ -61,9 +67,17 @@ enum ethtool_phys_id_state {
 
 struct net_device;
 
+#ifdef CONFIG_NET_ETHTOOL
 /* Some generic methods drivers may use in their ethtool_ops */
 u32 ethtool_op_get_link(struct net_device *dev);
 int ethtool_op_get_ts_info(struct net_device *dev, struct ethtool_ts_info *eti);
+#else
+/* Some generic methods drivers may use in their ethtool_ops */
+static inline u32 ethtool_op_get_link(struct net_device *dev) { return 0; }
+static inline int
+ethtool_op_get_ts_info(struct net_device *dev, struct ethtool_ts_info *eti)
+{ return -EINVAL; }
+#endif
 
 /**
  * ethtool_rxfh_indir_default - get default value for RX flow hash indirection
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7ed3a3a..29e0409 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -56,12 +56,28 @@ struct device;
 struct phy_device;
 /* 802.11 specific */
 struct wireless_dev;
-					/* source back-compat hooks */
+
+#ifdef CONFIG_NET_ETHTOOL
+
+/* When the driver uses this macro ethtool code can be optimized out
+ * when not needed. We still reference it to avoid unused static
+ * warnings.
+ */
 #define SET_ETHTOOL_OPS(netdev,ops) \
-	( (netdev)->ethtool_ops = (ops) )
+	( (void)(ops), (netdev)->ethtool_ops = (ops) )
 
 void netdev_set_default_ethtool_ops(struct net_device *dev,
 				    const struct ethtool_ops *ops);
+int dev_ethtool(struct net *net, struct ifreq *);
+
+#else
+#define SET_ETHTOOL_OPS(netdev,ops) do {} while(0)
+static inline void
+netdev_set_default_ethtool_ops(struct net_device *dev,
+			       const struct ethtool_ops *ops) {}
+static inline int
+dev_ethtool(struct net *net, struct ifreq *ifr) { return -EINVAL; }
+#endif
 
 /* Backlog congestion levels */
 #define NET_RX_SUCCESS		0	/* keep 'em coming, baby */
@@ -2616,7 +2632,6 @@ void netdev_rx_handler_unregister(struct net_device *dev);
 
 bool dev_valid_name(const char *name);
 int dev_ioctl(struct net *net, unsigned int cmd, void __user *);
-int dev_ethtool(struct net *net, struct ifreq *);
 unsigned int dev_get_flags(const struct net_device *);
 int __dev_change_flags(struct net_device *, unsigned int flags);
 int dev_change_flags(struct net_device *, unsigned int);
diff --git a/net/Kconfig b/net/Kconfig
index d92afe4..281d172 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -82,6 +82,12 @@ source "net/netlabel/Kconfig"
 
 endif # if INET
 
+config NET_ETHTOOL
+	bool "Ethtool support"
+	default y
+	help
+	  Support changing ethernet driver parameters from user tools.
+
 config NETWORK_SECMARK
 	bool "Security Marking"
 	help
diff --git a/net/core/Makefile b/net/core/Makefile
index 826b925..bfd28b1 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -7,12 +7,13 @@ obj-y := sock.o request_sock.o skbuff.o iovec.o datagram.o stream.o scm.o \
 
 obj-$(CONFIG_SYSCTL) += sysctl_net_core.o
 
-obj-y		     += dev.o ethtool.o dev_addr_lists.o dst.o netevent.o \
+obj-y		     += dev.o dev_addr_lists.o dst.o netevent.o \
 			neighbour.o rtnetlink.o utils.o link_watch.o filter.o \
 			sock_diag.o dev_ioctl.o
 
 obj-$(CONFIG_XFRM) += flow.o
 obj-y += net-sysfs.o
+obj-$(CONFIG_NET_ETHTOOL) += ethtool.o
 obj-$(CONFIG_PROC_FS) += net-procfs.o
 obj-$(CONFIG_NET_PKTGEN) += pktgen.o
 obj-$(CONFIG_NETPOLL) += netpoll.o
diff --git a/net/core/dev.c b/net/core/dev.c
index c6cbe69..cf102a4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6310,6 +6310,7 @@ struct netdev_queue *dev_ingress_queue_create(struct net_device *dev)
 
 static const struct ethtool_ops default_ethtool_ops;
 
+#ifdef CONFIG_NET_ETHTOOL
 void netdev_set_default_ethtool_ops(struct net_device *dev,
 				    const struct ethtool_ops *ops)
 {
@@ -6317,6 +6318,7 @@ void netdev_set_default_ethtool_ops(struct net_device *dev,
 		dev->ethtool_ops = ops;
 }
 EXPORT_SYMBOL_GPL(netdev_set_default_ethtool_ops);
+#endif
 
 void netdev_freemem(struct net_device *dev)
 {
-- 
1.9.0
