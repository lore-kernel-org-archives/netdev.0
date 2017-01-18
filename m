From: Phil Sutter <phil@nwl.cc>
Subject: [net-next PATCH 3/3] device: Implement a bus agnostic dev_num_vf routine
Date: Wed, 18 Jan 2017 14:04:39 +0100
Message-ID: <20170118130439.15023-4-phil@nwl.cc>
References: <20170118130439.15023-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: David Miller <davem@davemloft.net>,
        Bjorn Helgaas <bhelgaas@google.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20170118130439.15023-1-phil@nwl.cc>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that pci_bus_type has num_vf callback set, dev_num_vf can be
implemented in a bus type independent way and the check for whether a
PCI device is being handled in rtnetlink can be dropped.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 include/linux/device.h | 7 +++++++
 include/linux/pci.h    | 2 --
 net/core/rtnetlink.c   | 3 +--
 3 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/include/linux/device.h b/include/linux/device.h
index 6d73b70a4a5d7..bd684fc8ec1d8 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -1144,6 +1144,13 @@ extern int device_online(struct device *dev);
 extern void set_primary_fwnode(struct device *dev, struct fwnode_handle *fwnode);
 extern void set_secondary_fwnode(struct device *dev, struct fwnode_handle *fwnode);
 
+static inline int dev_num_vf(struct device *dev)
+{
+	if (dev->bus && dev->bus->num_vf)
+		return dev->bus->num_vf(dev);
+	return 0;
+}
+
 /*
  * Root device objects for grouping under /sys/devices
  */
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
index 75e3ea7bda08f..94dd6d53ea9a5 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -837,8 +837,7 @@ static void copy_rtnl_link_stats(struct rtnl_link_stats *a,
 static inline int rtnl_vfinfo_size(const struct net_device *dev,
 				   u32 ext_filter_mask)
 {
-	if (dev->dev.parent && dev_is_pci(dev->dev.parent) &&
-	    (ext_filter_mask & RTEXT_FILTER_VF)) {
+	if (dev->dev.parent && (ext_filter_mask & RTEXT_FILTER_VF)) {
 		int num_vfs = dev_num_vf(dev->dev.parent);
 		size_t size = nla_total_size(0);
 		size += num_vfs *
-- 
2.11.0
