From: Phil Sutter <phil@nwl.cc>
Subject: [net-next PATCH v6 2/3] net: rtnetlink: Use a local dev_num_vf() implementation
Date: Thu,  5 Jan 2017 20:09:12 +0100
Message-ID: <20170105190913.29986-3-phil@nwl.cc>
References: <20170105190913.29986-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:48356 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1763448AbdAETJt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Jan 2017 14:09:49 -0500
In-Reply-To: <20170105190913.29986-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Promote dev_num_vf() to be no longer PCI device specific but use
ndo_get_vf_count() if implemented and only fall back to pci_num_vf()
like the old dev_num_vf() did.

Since this implementation no longer requires a parent device to be
present, don't pass the parent but the actual device to it and have it
check for parent existence only in the fallback case. This in turn
allows to eliminate parent existence checks in callers.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
Changes since v5:
- Introduced this patch.
---
 include/linux/pci.h  |  2 --
 net/core/rtnetlink.c | 37 ++++++++++++++++++++++++-------------
 2 files changed, 24 insertions(+), 15 deletions(-)

diff --git a/include/linux/pci.h b/include/linux/pci.h
index e2d1a124216a9..adbc859fe7c4c 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -885,7 +885,6 @@ void pcibios_setup_bridge(struct pci_bus *bus, unsigned long type);
 void pci_sort_breadthfirst(void);
 #define dev_is_pci(d) ((d)->bus == &pci_bus_type)
 #define dev_is_pf(d) ((dev_is_pci(d) ? to_pci_dev(d)->is_physfn : false))
-#define dev_num_vf(d) ((dev_is_pci(d) ? pci_num_vf(to_pci_dev(d)) : 0))
 
 /* Generic PCI functions exported to card drivers */
 
@@ -1630,7 +1629,6 @@ static inline int pci_get_new_domain_nr(void) { return -ENOSYS; }
 
 #define dev_is_pci(d) (false)
 #define dev_is_pf(d) (false)
-#define dev_num_vf(d) (0)
 #endif /* CONFIG_PCI */
 
 /* Include architecture-dependent settings and functions */
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 18b5aae99becf..84294593e0306 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -833,13 +833,24 @@ static void copy_rtnl_link_stats(struct rtnl_link_stats *a,
 	a->rx_nohandler = b->rx_nohandler;
 }
 
+static int dev_num_vf(const struct net_device *dev)
+{
+	if (dev->netdev_ops->ndo_get_vf_count)
+		return dev->netdev_ops->ndo_get_vf_count(dev);
+#ifdef CONFIG_PCI
+	if (dev->dev.parent && dev_is_pci(dev->dev.parent))
+		return pci_num_vf(to_pci_dev(dev->dev.parent));
+#endif
+	return 0;
+}
+
 /* All VF info */
 static inline int rtnl_vfinfo_size(const struct net_device *dev,
 				   u32 ext_filter_mask)
 {
-	if (dev->dev.parent && dev_is_pci(dev->dev.parent) &&
-	    (ext_filter_mask & RTEXT_FILTER_VF)) {
-		int num_vfs = dev_num_vf(dev->dev.parent);
+	int num_vfs = dev_num_vf(dev);
+
+	if (num_vfs && (ext_filter_mask & RTEXT_FILTER_VF)) {
 		size_t size = nla_total_size(0);
 		size += num_vfs *
 			(nla_total_size(0) +
@@ -889,12 +900,12 @@ static size_t rtnl_port_size(const struct net_device *dev,
 	size_t port_self_size = nla_total_size(sizeof(struct nlattr))
 		+ port_size;
 
-	if (!dev->netdev_ops->ndo_get_vf_port || !dev->dev.parent ||
+	if (!dev->netdev_ops->ndo_get_vf_port ||
 	    !(ext_filter_mask & RTEXT_FILTER_VF))
 		return 0;
-	if (dev_num_vf(dev->dev.parent))
+	if (dev_num_vf(dev))
 		return port_self_size + vf_ports_size +
-			vf_port_size * dev_num_vf(dev->dev.parent);
+			vf_port_size * dev_num_vf(dev);
 	else
 		return port_self_size;
 }
@@ -962,7 +973,7 @@ static int rtnl_vf_ports_fill(struct sk_buff *skb, struct net_device *dev)
 	if (!vf_ports)
 		return -EMSGSIZE;
 
-	for (vf = 0; vf < dev_num_vf(dev->dev.parent); vf++) {
+	for (vf = 0; vf < dev_num_vf(dev); vf++) {
 		vf_port = nla_nest_start(skb, IFLA_VF_PORT);
 		if (!vf_port)
 			goto nla_put_failure;
@@ -1012,7 +1023,7 @@ static int rtnl_port_fill(struct sk_buff *skb, struct net_device *dev,
 {
 	int err;
 
-	if (!dev->netdev_ops->ndo_get_vf_port || !dev->dev.parent ||
+	if (!dev->netdev_ops->ndo_get_vf_port ||
 	    !(ext_filter_mask & RTEXT_FILTER_VF))
 		return 0;
 
@@ -1020,7 +1031,7 @@ static int rtnl_port_fill(struct sk_buff *skb, struct net_device *dev,
 	if (err)
 		return err;
 
-	if (dev_num_vf(dev->dev.parent)) {
+	if (dev_num_vf(dev)) {
 		err = rtnl_vf_ports_fill(skb, dev);
 		if (err)
 			return err;
@@ -1351,15 +1362,15 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	if (rtnl_fill_stats(skb, dev))
 		goto nla_put_failure;
 
-	if (dev->dev.parent && (ext_filter_mask & RTEXT_FILTER_VF) &&
-	    nla_put_u32(skb, IFLA_NUM_VF, dev_num_vf(dev->dev.parent)))
+	if (ext_filter_mask & RTEXT_FILTER_VF &&
+	    nla_put_u32(skb, IFLA_NUM_VF, dev_num_vf(dev)))
 		goto nla_put_failure;
 
-	if (dev->netdev_ops->ndo_get_vf_config && dev->dev.parent &&
+	if (dev->netdev_ops->ndo_get_vf_config &&
 	    ext_filter_mask & RTEXT_FILTER_VF) {
 		int i;
 		struct nlattr *vfinfo;
-		int num_vfs = dev_num_vf(dev->dev.parent);
+		int num_vfs = dev_num_vf(dev);
 
 		vfinfo = nla_nest_start(skb, IFLA_VFINFO_LIST);
 		if (!vfinfo)
-- 
2.11.0
