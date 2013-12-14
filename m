From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 11/15] sfc: Store VPD serial number at probe time
Date: Sat, 14 Dec 2013 23:05:38 +0000
Message-ID: <1387062338.12172.69.camel@deadeye.wl.decadent.org.uk>
References: <1387061852.12172.58.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	"Richard Cochran" <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17396 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754148Ab3LNXFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 18:05:44 -0500
In-Reply-To: <1387061852.12172.58.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Original version by Stuart Hodgson.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c        |   38 ++++++++++++++++++++++++++------
 drivers/net/ethernet/sfc/net_driver.h |    3 ++
 2 files changed, 34 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index b9929d9ed69d..5745a9fd034e 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2628,6 +2628,8 @@ static void efx_fini_struct(struct efx_nic *efx)
 	for (i = 0; i < EFX_MAX_CHANNELS; i++)
 		kfree(efx->channel[i]);
 
+	kfree(efx->vpd_sn);
+
 	if (efx->workqueue) {
 		destroy_workqueue(efx->workqueue);
 		efx->workqueue = NULL;
@@ -2699,12 +2701,12 @@ static void efx_pci_remove(struct pci_dev *pci_dev)
  * always appear within the first 512 bytes.
  */
 #define SFC_VPD_LEN 512
-static void efx_print_product_vpd(struct efx_nic *efx)
+static void efx_probe_vpd_strings(struct efx_nic *efx)
 {
 	struct pci_dev *dev = efx->pci_dev;
 	char vpd_data[SFC_VPD_LEN];
 	ssize_t vpd_size;
-	int i, j;
+	int ro_start, ro_size, i, j;
 
 	/* Get the vpd data from the device */
 	vpd_size = pci_read_vpd(dev, 0, sizeof(vpd_data), vpd_data);
@@ -2714,14 +2716,15 @@ static void efx_print_product_vpd(struct efx_nic *efx)
 	}
 
 	/* Get the Read only section */
-	i = pci_vpd_find_tag(vpd_data, 0, vpd_size, PCI_VPD_LRDT_RO_DATA);
-	if (i < 0) {
+	ro_start = pci_vpd_find_tag(vpd_data, 0, vpd_size, PCI_VPD_LRDT_RO_DATA);
+	if (ro_start < 0) {
 		netif_err(efx, drv, efx->net_dev, "VPD Read-only not found\n");
 		return;
 	}
 
-	j = pci_vpd_lrdt_size(&vpd_data[i]);
-	i += PCI_VPD_LRDT_TAG_SIZE;
+	ro_size = pci_vpd_lrdt_size(&vpd_data[ro_start]);
+	j = ro_size;
+	i = ro_start + PCI_VPD_LRDT_TAG_SIZE;
 	if (i + j > vpd_size)
 		j = vpd_size - i;
 
@@ -2741,6 +2744,27 @@ static void efx_print_product_vpd(struct efx_nic *efx)
 
 	netif_info(efx, drv, efx->net_dev,
 		   "Part Number : %.*s\n", j, &vpd_data[i]);
+
+	i = ro_start + PCI_VPD_LRDT_TAG_SIZE;
+	j = ro_size;
+	i = pci_vpd_find_info_keyword(vpd_data, i, j, "SN");
+	if (i < 0) {
+		netif_err(efx, drv, efx->net_dev, "Serial number not found\n");
+		return;
+	}
+
+	j = pci_vpd_info_field_size(&vpd_data[i]);
+	i += PCI_VPD_INFO_FLD_HDR_SIZE;
+	if (i + j > vpd_size) {
+		netif_err(efx, drv, efx->net_dev, "Incomplete serial number\n");
+		return;
+	}
+
+	efx->vpd_sn = kmalloc(j + 1, GFP_KERNEL);
+	if (!efx->vpd_sn)
+		return;
+
+	snprintf(efx->vpd_sn, j + 1, "%s", &vpd_data[i]);
 }
 

@@ -2837,7 +2861,7 @@ static int efx_pci_probe(struct pci_dev *pci_dev,
 	netif_info(efx, probe, efx->net_dev,
 		   "Solarflare NIC detected\n");
 
-	efx_print_product_vpd(efx);
+	efx_probe_vpd_strings(efx);
 
 	/* Set up basic I/O (BAR mappings etc) */
 	rc = efx_init_io(efx);
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 0d0e8eb88332..be8a616a1649 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -771,6 +771,7 @@ struct vfdi_status;
  * @local_lock: Mutex protecting %local_addr_list and %local_page_list.
  * @peer_work: Work item to broadcast peer addresses to VMs.
  * @ptp_data: PTP state data
+ * @vpd_sn: Serial number read from VPD
  * @monitor_work: Hardware monitor workitem
  * @biu_lock: BIU (bus interface unit) lock
  * @last_irq_cpu: Last CPU to handle a possible test interrupt.  This
@@ -920,6 +921,8 @@ struct efx_nic {
 
 	struct efx_ptp_data *ptp_data;
 
+	char *vpd_sn;
+
 	/* The following fields may be written more often */
 
 	struct delayed_work monitor_work ____cacheline_aligned_in_smp;


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
