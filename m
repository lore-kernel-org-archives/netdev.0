From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 2/7] enic: Add support for firmware management
	device
Date: Tue, 10 Aug 2010 21:55:00 -0700
Message-ID: <20100811045500.3877.42493.stgit@savbu-pc100.cisco.com>
References: <20100811045436.3877.51650.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:13215 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751791Ab0HKEzA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 00:55:00 -0400
In-Reply-To: <20100811045436.3877.51650.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

This patch adds support for firmware management device in enic driver.
A management device is a virtual PCIe device that firmware can present
to the host as its management endpoint. It provides the interface between
the host and adapter firmware for all management operations.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
---
 drivers/net/enic/vnic_dev.c      |   25 ++++++++++++++++++-------
 drivers/net/enic/vnic_resource.h |   13 +++++++++++++
 2 files changed, 31 insertions(+), 7 deletions(-)


diff --git a/drivers/net/enic/vnic_dev.c b/drivers/net/enic/vnic_dev.c
index 6a5b578..08d5d42 100644
--- a/drivers/net/enic/vnic_dev.c
+++ b/drivers/net/enic/vnic_dev.c
@@ -74,6 +74,7 @@ static int vnic_dev_discover_res(struct vnic_dev *vdev,
 	struct vnic_dev_bar *bar, unsigned int num_bars)
 {
 	struct vnic_resource_header __iomem *rh;
+	struct mgmt_barmap_hdr __iomem *mrh;
 	struct vnic_resource __iomem *r;
 	u8 type;
 
@@ -85,22 +86,32 @@ static int vnic_dev_discover_res(struct vnic_dev *vdev,
 		return -EINVAL;
 	}
 
-	rh = bar->vaddr;
+	rh  = bar->vaddr;
+	mrh = bar->vaddr;
 	if (!rh) {
 		pr_err("vNIC BAR0 res hdr not mem-mapped\n");
 		return -EINVAL;
 	}
 
-	if (ioread32(&rh->magic) != VNIC_RES_MAGIC ||
-	    ioread32(&rh->version) != VNIC_RES_VERSION) {
-		pr_err("vNIC BAR0 res magic/version error "
-			"exp (%lx/%lx) curr (%x/%x)\n",
+	/* Check for mgmt vnic in addition to normal vnic */
+	if ((ioread32(&rh->magic) != VNIC_RES_MAGIC) ||
+		(ioread32(&rh->version) != VNIC_RES_VERSION)) {
+		if ((ioread32(&mrh->magic) != MGMTVNIC_MAGIC) ||
+			(ioread32(&mrh->version) != MGMTVNIC_VERSION)) {
+			pr_err("vNIC BAR0 res magic/version error "
+			"exp (%lx/%lx) or (%lx/%lx), curr (%x/%x)\n",
 			VNIC_RES_MAGIC, VNIC_RES_VERSION,
+			MGMTVNIC_MAGIC, MGMTVNIC_VERSION,
 			ioread32(&rh->magic), ioread32(&rh->version));
-		return -EINVAL;
+			return -EINVAL;
+		}
 	}
 
-	r = (struct vnic_resource __iomem *)(rh + 1);
+	if (ioread32(&mrh->magic) == MGMTVNIC_MAGIC)
+		r = (struct vnic_resource __iomem *)(mrh + 1);
+	else
+		r = (struct vnic_resource __iomem *)(rh + 1);
+
 
 	while ((type = ioread8(&r->type)) != RES_TYPE_EOL) {
 
diff --git a/drivers/net/enic/vnic_resource.h b/drivers/net/enic/vnic_resource.h
index 810287b..e0a73f1 100644
--- a/drivers/net/enic/vnic_resource.h
+++ b/drivers/net/enic/vnic_resource.h
@@ -22,6 +22,11 @@
 
 #define VNIC_RES_MAGIC		0x766E6963L	/* 'vnic' */
 #define VNIC_RES_VERSION	0x00000000L
+#define MGMTVNIC_MAGIC		0x544d474dL	/* 'MGMT' */
+#define MGMTVNIC_VERSION	0x00000000L
+
+/* The MAC address assigned to the CFG vNIC is fixed. */
+#define MGMTVNIC_MAC		{ 0x02, 0x00, 0x54, 0x4d, 0x47, 0x4d }
 
 /* vNIC resource types */
 enum vnic_res_type {
@@ -52,6 +57,14 @@ struct vnic_resource_header {
 	u32 version;
 };
 
+struct mgmt_barmap_hdr {
+	u32 magic;			/* magic number */
+	u32 version;			/* header format version */
+	u16 lif;			/* loopback lif for mgmt frames */
+	u16 pci_slot;			/* installed pci slot */
+	char serial[16];		/* card serial number */
+};
+
 struct vnic_resource {
 	u8 type;
 	u8 bar;

