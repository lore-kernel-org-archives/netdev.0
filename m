From: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
Subject: [PATCH 01/10] net: thunderx: Cleanup duplicate NODE_ID macros,
 add nic_get_node_id()
Date: Tue, 2 Jun 2015 11:00:18 -0700
Message-ID: <1433268028-23992-2-git-send-email-aleksey.makarov@caviumnetworks.com>
References: <1433268028-23992-1-git-send-email-aleksey.makarov@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Robert Richter <rric@kernel.org>, David Daney <david.daney@cavium.com>,
 Aleksey Makarov <aleksey.makarov@caviumnetworks.com>,
 linux-kernel@vger.kernel.org, Robert Richter <rrichter@cavium.com>,
 Robert Richter <robert.richter@caviumnetworks.com>,
 Sunil Goutham <sgoutham@cavium.com>, linux-arm-kernel@lists.infradead.org
To: <netdev@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1433268028-23992-1-git-send-email-aleksey.makarov@caviumnetworks.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Robert Richter <rrichter@cavium.com>

There are duplicate NODE_ID macro definitions. Move all of them to
nic.h for usage in nic and bgx driver and introduce nic_get_node_id()
helper function.

This patch also fixes 64bit mask which should have been ULL by
reworking the node calculation.

Signed-off-by: Robert Richter <rrichter@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nic.h         | 10 ++++++++++
 drivers/net/ethernet/cavium/thunder/nic_main.c    |  4 +---
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c |  4 ++--
 drivers/net/ethernet/cavium/thunder/thunder_bgx.h |  3 ---
 4 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic.h b/drivers/net/ethernet/cavium/thunder/nic.h
index 9b0be52..4f426db 100644
--- a/drivers/net/ethernet/cavium/thunder/nic.h
+++ b/drivers/net/ethernet/cavium/thunder/nic.h
@@ -11,6 +11,7 @@
 
 #include <linux/netdevice.h>
 #include <linux/interrupt.h>
+#include <linux/pci.h>
 #include "thunder_bgx.h"
 
 /* PCI device IDs */
@@ -398,6 +399,15 @@ union nic_mbx {
 	struct bgx_link_status  link_status;
 };
 
+#define NIC_NODE_ID_MASK	0x03
+#define NIC_NODE_ID_SHIFT	44
+
+static inline int nic_get_node_id(struct pci_dev *pdev)
+{
+	u64 addr = pci_resource_start(pdev, PCI_CFG_REG_BAR_NUM);
+	return ((addr >> NIC_NODE_ID_SHIFT) & NIC_NODE_ID_MASK);
+}
+
 int nicvf_set_real_num_queues(struct net_device *netdev,
 			      int tx_queues, int rx_queues);
 int nicvf_open(struct net_device *netdev);
diff --git a/drivers/net/ethernet/cavium/thunder/nic_main.c b/drivers/net/ethernet/cavium/thunder/nic_main.c
index 0f1f58b..3ca7ad8 100644
--- a/drivers/net/ethernet/cavium/thunder/nic_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nic_main.c
@@ -23,8 +23,6 @@
 struct nicpf {
 	struct pci_dev		*pdev;
 	u8			rev_id;
-#define NIC_NODE_ID_MASK	0x300000000000
-#define NIC_NODE_ID(x)		((x & NODE_ID_MASK) >> 44)
 	u8			node;
 	unsigned int		flags;
 	u8			num_vf_en;      /* No of VF enabled */
@@ -851,7 +849,7 @@ static int nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	pci_read_config_byte(pdev, PCI_REVISION_ID, &nic->rev_id);
 
-	nic->node = NIC_NODE_ID(pci_resource_start(pdev, PCI_CFG_REG_BAR_NUM));
+	nic->node = nic_get_node_id(pdev);
 
 	nic_set_lmac_vf_mapping(nic);
 
diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
index 020e11c..cde604a 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
@@ -894,8 +894,8 @@ static int bgx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_release_regions;
 	}
 	bgx->bgx_id = (pci_resource_start(pdev, PCI_CFG_REG_BAR_NUM) >> 24) & 1;
-	bgx->bgx_id += NODE_ID(pci_resource_start(pdev, PCI_CFG_REG_BAR_NUM))
-							* MAX_BGX_PER_CN88XX;
+	bgx->bgx_id += nic_get_node_id(pdev) * MAX_BGX_PER_CN88XX;
+
 	bgx_vnic[bgx->bgx_id] = bgx;
 	bgx_get_qlm_mode(bgx);
 
diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.h b/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
index 9d91ce4..f9e2170 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
@@ -20,9 +20,6 @@
 
 #define    MAX_LMAC	(MAX_BGX_PER_CN88XX * MAX_LMAC_PER_BGX)
 
-#define    NODE_ID_MASK				0x300000000000
-#define    NODE_ID(x)				((x & NODE_ID_MASK) >> 44)
-
 /* Registers */
 #define BGX_CMRX_CFG			0x00
 #define  CMR_PKT_TX_EN				BIT_ULL(13)
-- 
2.4.1
