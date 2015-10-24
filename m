From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH 3/4] net: thunderx: Rewrite silicon revision tests.
Date: Fri, 23 Oct 2015 17:14:09 -0700
Message-ID: <1445645650-17328-4-git-send-email-ddaney.cavm@gmail.com>
References: <1445645650-17328-1-git-send-email-ddaney.cavm@gmail.com>
Cc: David Daney <david.daney@cavium.com>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, Sunil Goutham <sgoutham@cavium.com>,
	Robert Richter <rric@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445645650-17328-1-git-send-email-ddaney.cavm@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <david.daney@cavium.com>

The test for pass-1 silicon was incorrect, it should be for all
revisions less than 8.  Also the revision is already present in the
pci_dev, so there is no need to read and keep a private copy.

Remove rev_id and code to read it from struct nicpf.  Create new
static inline function pass1_silicon() to be used to testing the
silicon version.  Use pass1_silicon() for revision checks, this will
be more widely used in follow on patches.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nic_main.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic_main.c b/drivers/net/ethernet/cavium/thunder/nic_main.c
index d6e3219..52e1acb 100644
--- a/drivers/net/ethernet/cavium/thunder/nic_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nic_main.c
@@ -22,7 +22,6 @@
 
 struct nicpf {
 	struct pci_dev		*pdev;
-	u8			rev_id;
 	u8			node;
 	unsigned int		flags;
 	u8			num_vf_en;      /* No of VF enabled */
@@ -54,6 +53,11 @@ struct nicpf {
 	bool			irq_allocated[NIC_PF_MSIX_VECTORS];
 };
 
+static inline bool pass1_silicon(struct nicpf *nic)
+{
+	return nic->pdev->revision < 8;
+}
+
 /* Supported devices */
 static const struct pci_device_id nic_id_table[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_CAVIUM, PCI_DEVICE_ID_THUNDER_NIC_PF) },
@@ -117,7 +121,7 @@ static void nic_send_msg_to_vf(struct nicpf *nic, int vf, union nic_mbx *mbx)
 	 * when PF writes to MBOX(1), in next revisions when
 	 * PF writes to MBOX(0)
 	 */
-	if (nic->rev_id == 0) {
+	if (pass1_silicon(nic)) {
 		/* see the comment for nic_reg_write()/nic_reg_read()
 		 * functions above
 		 */
@@ -998,8 +1002,6 @@ static int nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_release_regions;
 	}
 
-	pci_read_config_byte(pdev, PCI_REVISION_ID, &nic->rev_id);
-
 	nic->node = nic_get_node_id(pdev);
 
 	nic_set_lmac_vf_mapping(nic);
-- 
1.8.3.1
