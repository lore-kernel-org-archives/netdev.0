From: Ben Greear <greearb@candelatech.com>
Subject: [PATCH 1/3] rx_all_ethtool.patch
Date: Mon, 24 Nov 2003 23:53:53 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FC30A91.6090309@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020803080508050906080400"
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020803080508050906080400
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


--------------020803080508050906080400
Content-Type: text/plain;
 name="rx_all_ethtool.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="rx_all_ethtool.patch"

--- linux-2.4.22/include/linux/ethtool.h	2003-11-24 23:14:20.000000000 -0800
+++ linux-2.4.22.p4s/include/linux/ethtool.h	2003-11-24 23:18:29.000000000 -0800
@@ -1,4 +1,4 @@
-/*
+/* -*-linux-c-*-
  * ethtool.h: Defines for Linux ethtool.
  *
  * Copyright (C) 1998 David S. Miller (davem@redhat.com)
@@ -289,6 +289,10 @@
  * get_strings: Return a set of strings that describe the requested objects 
  * phys_id: Identify the device
  * get_stats: Return statistics about the device
+ * set_rx_all: Set or clear IFF_ACCEPT_ALL_FRAMES, see if.h
+ * get_rx_all: Return 1 if set, 0 if not.
+ * set_save_fcs: Set or clear IFF_SAVE_FCS, see if.h
+ * get_save_fcs: Return 1 if set, 0 if not.
  *
  * Description:
  *
@@ -345,7 +349,11 @@
 	int	(*phys_id)(struct net_device *, u32);
 	int	(*get_stats_count)(struct net_device *);
 	void	(*get_ethtool_stats)(struct net_device *, struct ethtool_stats *, u64 *);
+	int     (*set_rx_all)(struct net_device *, u32);
+	int     (*get_rx_all)(struct net_device *, u32 *);
+	int     (*set_save_fcs)(struct net_device *, u32);
+	int     (*get_save_fcs)(struct net_device *, u32 *);
 };
 
 /* CMDs currently supported */
@@ -381,7 +396,15 @@
 #define ETHTOOL_GTSO		0x0000001e /* Get TSO enable (ethtool_value) */
 #define ETHTOOL_STSO		0x0000001f /* Set TSO enable (ethtool_value) */
 
+
+#define ETHTOOL_GETRXALL         0x00000071 /* Retrieve whether or not
+					     * IFF_ACCEPT_ALL_FRAMES is set. */
+#define ETHTOOL_SETRXALL         0x00000072 /* Set IFF_ACCEPT_ALL_FRAMES */
+#define ETHTOOL_GETRXFCS         0x00000073 /* Set IFF_SAVE_FCS */
+#define ETHTOOL_SETRXFCS         0x00000074 /* Set IFF_SAVE_FCS */
+
+
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
 #define SPARC_ETH_SSET		ETHTOOL_SSET
--- linux-2.4.22/net/core/ethtool.c	2003-11-24 23:14:22.000000000 -0800
+++ linux-2.4.22.p4s/net/core/ethtool.c	2003-11-18 22:40:06.000000000 -0800
@@ -1,4 +1,4 @@
-/*
+/* -*- linux-c -*-
  * net/core/ethtool.c - Ethtool ioctl handler
  * Copyright (c) 2003 Matthew Wilcox <matthew@wil.cx>
  *
@@ -31,6 +31,12 @@
 	return (dev->features & NETIF_F_IP_CSUM) != 0;
 }
 
+u32 ethtool_op_get_rx_all(struct net_device *dev, u32* retval)
+{
+	*retval = ((dev->priv_flags & IFF_ACCEPT_ALL_FRAMES) != 0);
+	return 0;
+}
+
 int ethtool_op_set_tx_csum(struct net_device *dev, u32 data)
 {
 	if (data)
@@ -569,6 +575,38 @@
 	return dev->ethtool_ops->phys_id(dev, id.data);
 }
 
+
+static int ethtool_get_rx_all(struct net_device *dev, char *useraddr)
+{
+	struct ethtool_value edata = { ETHTOOL_GSG };
+	int rv = 0;
+	
+	if (!dev->ethtool_ops->get_rx_all)
+		return -EOPNOTSUPP;
+
+	if ((rv = dev->ethtool_ops->get_rx_all(dev, &edata.data)) < 0) {
+		return rv;
+	}
+
+	if (copy_to_user(useraddr, &edata, sizeof(edata)))
+		return -EFAULT;
+	return 0;
+}
+
+
+static int ethtool_set_rx_all(struct net_device *dev, void *useraddr)
+{
+	struct ethtool_value id;
+
+	if (!dev->ethtool_ops->set_rx_all)
+		return -EOPNOTSUPP;
+
+	if (copy_from_user(&id, useraddr, sizeof(id)))
+		return -EFAULT;
+
+	return dev->ethtool_ops->set_rx_all(dev, id.data);
+}
+
 static int ethtool_get_stats(struct net_device *dev, void *useraddr)
 {
 	struct ethtool_stats stats;
@@ -602,5 +640,5 @@
 	return ret;
 }
 
 /* The main entry point in this file.  Called from net/core/dev.c */
@@ -681,6 +747,10 @@
 		return ethtool_get_strings(dev, useraddr);
 	case ETHTOOL_PHYS_ID:
 		return ethtool_phys_id(dev, useraddr);
+	case ETHTOOL_SETRXALL:
+		return ethtool_set_rx_all(dev, useraddr);
+	case ETHTOOL_GETRXALL:
+		return ethtool_get_rx_all(dev, useraddr);
 	case ETHTOOL_GSTATS:
 		return ethtool_get_stats(dev, useraddr);
 	default:

--------------020803080508050906080400--
