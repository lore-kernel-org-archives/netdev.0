From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 10/10] sfc: Log the part number on probe
Date: Sat, 10 Mar 2012 00:53:03 +0000
Message-ID: <1331340783.2537.20.camel@bwh-desktop>
References: <1331340409.2537.10.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:51327 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755217Ab2CJAxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2012 19:53:06 -0500
In-Reply-To: <1331340409.2537.10.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During probe of each port, read and log the part number from VPD.
Remove the Falcon-specific board name lookup.

Initial version by Stuart Hodgson <smhodgson@solarflare.com>.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c           |   53 ++++++++++++++++++++++++++++++
 drivers/net/ethernet/sfc/falcon_boards.c |   13 -------
 drivers/net/ethernet/sfc/nic.h           |    4 --
 3 files changed, 53 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 7683e53..3cbfbff 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2497,6 +2497,57 @@ static void efx_pci_remove(struct pci_dev *pci_dev)
 	free_netdev(efx->net_dev);
 };
 
+/* NIC VPD information
+ * Called during probe to display the part number of the
+ * installed NIC.  VPD is potentially very large but this should
+ * always appear within the first 512 bytes.
+ */
+#define SFC_VPD_LEN 512
+static void efx_print_product_vpd(struct efx_nic *efx)
+{
+	struct pci_dev *dev = efx->pci_dev;
+	char vpd_data[SFC_VPD_LEN];
+	ssize_t vpd_size;
+	int i, j;
+
+	/* Get the vpd data from the device */
+	vpd_size = pci_read_vpd(dev, 0, sizeof(vpd_data), vpd_data);
+	if (vpd_size <= 0) {
+		netif_err(efx, drv, efx->net_dev, "Unable to read VPD\n");
+		return;
+	}
+
+	/* Get the Read only section */
+	i = pci_vpd_find_tag(vpd_data, 0, vpd_size, PCI_VPD_LRDT_RO_DATA);
+	if (i < 0) {
+		netif_err(efx, drv, efx->net_dev, "VPD Read-only not found\n");
+		return;
+	}
+
+	j = pci_vpd_lrdt_size(&vpd_data[i]);
+	i += PCI_VPD_LRDT_TAG_SIZE;
+	if (i + j > vpd_size)
+		j = vpd_size - i;
+
+	/* Get the Part number */
+	i = pci_vpd_find_info_keyword(vpd_data, i, j, "PN");
+	if (i < 0) {
+		netif_err(efx, drv, efx->net_dev, "Part number not found\n");
+		return;
+	}
+
+	j = pci_vpd_info_field_size(&vpd_data[i]);
+	i += PCI_VPD_INFO_FLD_HDR_SIZE;
+	if (i + j > vpd_size) {
+		netif_err(efx, drv, efx->net_dev, "Incomplete part number\n");
+		return;
+	}
+
+	netif_info(efx, drv, efx->net_dev,
+		   "Part Number : %.*s\n", j, &vpd_data[i]);
+}
+
+
 /* Main body of NIC initialisation
  * This is called at module load (or hotplug insertion, theoretically).
  */
@@ -2586,6 +2637,8 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 	netif_info(efx, probe, efx->net_dev,
 		   "Solarflare NIC detected\n");
 
+	efx_print_product_vpd(efx);
+
 	/* Set up basic I/O (BAR mappings etc) */
 	rc = efx_init_io(efx);
 	if (rc)
diff --git a/drivers/net/ethernet/sfc/falcon_boards.c b/drivers/net/ethernet/sfc/falcon_boards.c
index 2084cc6..8687a6c 100644
--- a/drivers/net/ethernet/sfc/falcon_boards.c
+++ b/drivers/net/ethernet/sfc/falcon_boards.c
@@ -709,8 +709,6 @@ static int sfe4003_init(struct efx_nic *efx)
 static const struct falcon_board_type board_types[] = {
 	{
 		.id		= FALCON_BOARD_SFE4001,
-		.ref_model	= "SFE4001",
-		.gen_type	= "10GBASE-T adapter",
 		.init		= sfe4001_init,
 		.init_phy	= efx_port_dummy_op_void,
 		.fini		= sfe4001_fini,
@@ -719,8 +717,6 @@ static const struct falcon_board_type board_types[] = {
 	},
 	{
 		.id		= FALCON_BOARD_SFE4002,
-		.ref_model	= "SFE4002",
-		.gen_type	= "XFP adapter",
 		.init		= sfe4002_init,
 		.init_phy	= sfe4002_init_phy,
 		.fini		= efx_fini_lm87,
@@ -729,8 +725,6 @@ static const struct falcon_board_type board_types[] = {
 	},
 	{
 		.id		= FALCON_BOARD_SFE4003,
-		.ref_model	= "SFE4003",
-		.gen_type	= "10GBASE-CX4 adapter",
 		.init		= sfe4003_init,
 		.init_phy	= sfe4003_init_phy,
 		.fini		= efx_fini_lm87,
@@ -739,8 +733,6 @@ static const struct falcon_board_type board_types[] = {
 	},
 	{
 		.id		= FALCON_BOARD_SFN4112F,
-		.ref_model	= "SFN4112F",
-		.gen_type	= "SFP+ adapter",
 		.init		= sfn4112f_init,
 		.init_phy	= sfn4112f_init_phy,
 		.fini		= efx_fini_lm87,
@@ -763,11 +755,6 @@ int falcon_probe_board(struct efx_nic *efx, u16 revision_info)
 			board->type = &board_types[i];
 
 	if (board->type) {
-		netif_info(efx, probe, efx->net_dev, "board is %s rev %c%d\n",
-			 (efx->pci_dev->subsystem_vendor ==
-			  PCI_VENDOR_ID_SOLARFLARE)
-			 ? board->type->ref_model : board->type->gen_type,
-			 'A' + board->major, board->minor);
 		return 0;
 	} else {
 		netif_err(efx, probe, efx->net_dev, "unknown board type %d\n",
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index f46e2ce..f48ccf6 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -69,8 +69,6 @@ enum {
 /**
  * struct falcon_board_type - board operations and type information
  * @id: Board type id, as found in NVRAM
- * @ref_model: Model number of Solarflare reference design
- * @gen_type: Generic board type description
  * @init: Allocate resources and initialise peripheral hardware
  * @init_phy: Do board-specific PHY initialisation
  * @fini: Shut down hardware and free resources
@@ -79,8 +77,6 @@ enum {
  */
 struct falcon_board_type {
 	u8 id;
-	const char *ref_model;
-	const char *gen_type;
 	int (*init) (struct efx_nic *nic);
 	void (*init_phy) (struct efx_nic *efx);
 	void (*fini) (struct efx_nic *nic);
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
