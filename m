From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next PATCH 01/11] enic: add support for multiple BARs
Date: Thu, 03 Sep 2009 20:01:53 -0700
Message-ID: <20090904030152.5047.83899.stgit@palito_client100.nuovasystems.com>
References: <20090904030046.5047.46509.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:6327 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932623AbZIDDBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 23:01:50 -0400
In-Reply-To: <20090904030046.5047.46509.stgit@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enic: add support for multiple BARs

Nic firmware can place resources (queues, intrs, etc) on multiple BARs, so
allow driver to discover/map resources beyond BAR0.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 drivers/net/enic/enic.h      |    8 ++++---
 drivers/net/enic/enic_main.c |   48 +++++++++++++++++++++---------------------
 drivers/net/enic/vnic_dev.c  |   41 +++++++++++++++++++++++++++++-------
 drivers/net/enic/vnic_dev.h  |    5 ++++
 4 files changed, 66 insertions(+), 36 deletions(-)

diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index c26cea0..cfe94b2 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -33,13 +33,15 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco 10G Ethernet Driver"
-#define DRV_VERSION		"1.0.0.933"
-#define DRV_COPYRIGHT		"Copyright 2008 Cisco Systems, Inc"
+#define DRV_VERSION		"1.1.0.100"
+#define DRV_COPYRIGHT		"Copyright 2008-2009 Cisco Systems, Inc"
 #define PFX			DRV_NAME ": "
 
 #define ENIC_LRO_MAX_DESC	8
 #define ENIC_LRO_MAX_AGGR	64
 
+#define ENIC_BARS_MAX		6
+
 enum enic_cq_index {
 	ENIC_CQ_RQ,
 	ENIC_CQ_WQ,
@@ -73,7 +75,7 @@ struct enic {
 	struct net_device *netdev;
 	struct pci_dev *pdev;
 	struct vnic_enet_config config;
-	struct vnic_dev_bar bar0;
+	struct vnic_dev_bar bar[ENIC_BARS_MAX];
 	struct vnic_dev *vdev;
 	struct timer_list notify_timer;
 	struct work_struct reset;
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 8005b60..b17fe4b 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1608,12 +1608,6 @@ static void enic_clear_intr_mode(struct enic *enic)
 	vnic_dev_set_intr_mode(enic->vdev, VNIC_DEV_INTR_MODE_UNKNOWN);
 }
 
-static void enic_iounmap(struct enic *enic)
-{
-	if (enic->bar0.vaddr)
-		iounmap(enic->bar0.vaddr);
-}
-
 static const struct net_device_ops enic_netdev_ops = {
 	.ndo_open		= enic_open,
 	.ndo_stop		= enic_stop,
@@ -1632,6 +1626,15 @@ static const struct net_device_ops enic_netdev_ops = {
 #endif
 };
 
+static void enic_iounmap(struct enic *enic)
+{
+	unsigned int i;
+
+	for (i = 0; i < ARRAY_SIZE(enic->bar); i++)
+		if (enic->bar[i].vaddr)
+			iounmap(enic->bar[i].vaddr);
+}
+
 static int __devinit enic_probe(struct pci_dev *pdev,
 	const struct pci_device_id *ent)
 {
@@ -1709,31 +1712,28 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 		using_dac = 1;
 	}
 
-	/* Map vNIC resources from BAR0
+	/* Map vNIC resources from BAR0-5
 	 */
 
-	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
-		printk(KERN_ERR PFX
-			"BAR0 not memory-map'able, aborting.\n");
-		err = -ENODEV;
-		goto err_out_release_regions;
-	}
-
-	enic->bar0.vaddr = pci_iomap(pdev, 0, enic->bar0.len);
-	enic->bar0.bus_addr = pci_resource_start(pdev, 0);
-	enic->bar0.len = pci_resource_len(pdev, 0);
-
-	if (!enic->bar0.vaddr) {
-		printk(KERN_ERR PFX
-			"Cannot memory-map BAR0 res hdr, aborting.\n");
-		err = -ENODEV;
-		goto err_out_release_regions;
+	for (i = 0; i < ARRAY_SIZE(enic->bar); i++) {
+		if (!(pci_resource_flags(pdev, i) & IORESOURCE_MEM))
+			continue;
+		enic->bar[i].len = pci_resource_len(pdev, i);
+		enic->bar[i].vaddr = pci_iomap(pdev, i, enic->bar[i].len);
+		if (!enic->bar[i].vaddr) {
+			printk(KERN_ERR PFX
+				"Cannot memory-map BAR %d, aborting.\n", i);
+			err = -ENODEV;
+			goto err_out_iounmap;
+		}
+		enic->bar[i].bus_addr = pci_resource_start(pdev, i);
 	}
 
 	/* Register vNIC device
 	 */
 
-	enic->vdev = vnic_dev_register(NULL, enic, pdev, &enic->bar0);
+	enic->vdev = vnic_dev_register(NULL, enic, pdev, enic->bar,
+		ARRAY_SIZE(enic->bar));
 	if (!enic->vdev) {
 		printk(KERN_ERR PFX
 			"vNIC registration failed, aborting.\n");
diff --git a/drivers/net/enic/vnic_dev.c b/drivers/net/enic/vnic_dev.c
index e21b9d6..d5c28ef 100644
--- a/drivers/net/enic/vnic_dev.c
+++ b/drivers/net/enic/vnic_dev.c
@@ -31,6 +31,7 @@
 
 struct vnic_res {
 	void __iomem *vaddr;
+	dma_addr_t bus_addr;
 	unsigned int count;
 };
 
@@ -67,12 +68,15 @@ void *vnic_dev_priv(struct vnic_dev *vdev)
 }
 
 static int vnic_dev_discover_res(struct vnic_dev *vdev,
-	struct vnic_dev_bar *bar)
+	struct vnic_dev_bar *bar, unsigned int num_bars)
 {
 	struct vnic_resource_header __iomem *rh;
 	struct vnic_resource __iomem *r;
 	u8 type;
 
+	if (num_bars == 0)
+		return -EINVAL;
+
 	if (bar->len < VNIC_MAX_RES_HDR_SIZE) {
 		printk(KERN_ERR "vNIC BAR0 res hdr length error\n");
 		return -EINVAL;
@@ -104,7 +108,10 @@ static int vnic_dev_discover_res(struct vnic_dev *vdev,
 
 		r++;
 
-		if (bar_num != 0)  /* only mapping in BAR0 resources */
+		if (bar_num >= num_bars)
+			continue;
+
+		if (!bar[bar_num].len || !bar[bar_num].vaddr)
 			continue;
 
 		switch (type) {
@@ -114,13 +121,13 @@ static int vnic_dev_discover_res(struct vnic_dev *vdev,
 		case RES_TYPE_INTR_CTRL:
 			/* each count is stride bytes long */
 			len = count * VNIC_RES_STRIDE;
-			if (len + bar_offset > bar->len) {
+			if (len + bar_offset > bar[bar_num].len) {
 				printk(KERN_ERR "vNIC BAR0 resource %d "
 					"out-of-bounds, offset 0x%x + "
 					"size 0x%x > bar len 0x%lx\n",
 					type, bar_offset,
 					len,
-					bar->len);
+					bar[bar_num].len);
 				return -EINVAL;
 			}
 			break;
@@ -133,7 +140,9 @@ static int vnic_dev_discover_res(struct vnic_dev *vdev,
 		}
 
 		vdev->res[type].count = count;
-		vdev->res[type].vaddr = (char __iomem *)bar->vaddr + bar_offset;
+		vdev->res[type].vaddr = (char __iomem *)bar[bar_num].vaddr +
+			bar_offset;
+		vdev->res[type].bus_addr = bar[bar_num].bus_addr + bar_offset;
 	}
 
 	return 0;
@@ -163,6 +172,21 @@ void __iomem *vnic_dev_get_res(struct vnic_dev *vdev, enum vnic_res_type type,
 	}
 }
 
+dma_addr_t vnic_dev_get_res_bus_addr(struct vnic_dev *vdev,
+	enum vnic_res_type type, unsigned int index)
+{
+	switch (type) {
+	case RES_TYPE_WQ:
+	case RES_TYPE_RQ:
+	case RES_TYPE_CQ:
+	case RES_TYPE_INTR_CTRL:
+		return vdev->res[type].bus_addr +
+			index * VNIC_RES_STRIDE;
+	default:
+		return vdev->res[type].bus_addr;
+	}
+}
+
 unsigned int vnic_dev_desc_ring_size(struct vnic_dev_ring *ring,
 	unsigned int desc_count, unsigned int desc_size)
 {
@@ -257,7 +281,7 @@ int vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 	iowrite32(cmd, &devcmd->cmd);
 
 	if ((_CMD_FLAGS(cmd) & _CMD_FLAGS_NOWAIT))
-			return 0;
+		return 0;
 
 	for (delay = 0; delay < wait; delay++) {
 
@@ -684,7 +708,8 @@ void vnic_dev_unregister(struct vnic_dev *vdev)
 }
 
 struct vnic_dev *vnic_dev_register(struct vnic_dev *vdev,
-	void *priv, struct pci_dev *pdev, struct vnic_dev_bar *bar)
+	void *priv, struct pci_dev *pdev, struct vnic_dev_bar *bar,
+	unsigned int num_bars)
 {
 	if (!vdev) {
 		vdev = kzalloc(sizeof(struct vnic_dev), GFP_ATOMIC);
@@ -695,7 +720,7 @@ struct vnic_dev *vnic_dev_register(struct vnic_dev *vdev,
 	vdev->priv = priv;
 	vdev->pdev = pdev;
 
-	if (vnic_dev_discover_res(vdev, bar))
+	if (vnic_dev_discover_res(vdev, bar, num_bars))
 		goto err_out;
 
 	vdev->devcmd = vnic_dev_get_res(vdev, RES_TYPE_DEVCMD, 0);
diff --git a/drivers/net/enic/vnic_dev.h b/drivers/net/enic/vnic_dev.h
index 8aa8db2..d960edb 100644
--- a/drivers/net/enic/vnic_dev.h
+++ b/drivers/net/enic/vnic_dev.h
@@ -75,6 +75,8 @@ unsigned int vnic_dev_get_res_count(struct vnic_dev *vdev,
 	enum vnic_res_type type);
 void __iomem *vnic_dev_get_res(struct vnic_dev *vdev, enum vnic_res_type type,
 	unsigned int index);
+dma_addr_t vnic_dev_get_res_bus_addr(struct vnic_dev *vdev,
+	enum vnic_res_type type, unsigned int index);
 unsigned int vnic_dev_desc_ring_size(struct vnic_dev_ring *ring,
 	unsigned int desc_count, unsigned int desc_size);
 void vnic_dev_clear_desc_ring(struct vnic_dev_ring *ring);
@@ -117,6 +119,7 @@ void vnic_dev_set_intr_mode(struct vnic_dev *vdev,
 enum vnic_dev_intr_mode vnic_dev_get_intr_mode(struct vnic_dev *vdev);
 void vnic_dev_unregister(struct vnic_dev *vdev);
 struct vnic_dev *vnic_dev_register(struct vnic_dev *vdev,
-	void *priv, struct pci_dev *pdev, struct vnic_dev_bar *bar);
+	void *priv, struct pci_dev *pdev, struct vnic_dev_bar *bar,
+	unsigned int num_bars);
 
 #endif /* _VNIC_DEV_H_ */

