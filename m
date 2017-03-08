From: Romain Perier <romain.perier@collabora.com>
Subject: [PATCH v5 15/19] usb: gadget: amd5536udc: Replace PCI pool old API
Date: Wed,  8 Mar 2017 17:19:53 +0100
Message-ID: <20170308161957.28941-16-romain.perier@collabora.com>
References: <20170308161957.28941-1-romain.perier@collabora.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-scsi@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Romain Perier <romain.perier@collabora.com>,
        Peter Senna Tschudin <peter.senna@collabora.co.uk>
To: Dan Williams <dan.j.williams@intel.com>,
        Doug Ledford <dledford@redhat.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        jeffrey.t.kirsher@intel.com,
        "David S. Miller" <davem@davemloft.net>, stas.yakovlev@gmail.com,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Felipe Balbi <balbi@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170308161957.28941-1-romain.perier@collabora.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The PCI pool API is deprecated. This commit replaces the PCI pool old
API by the appropriate function with the DMA pool API.

Signed-off-by: Romain Perier <romain.perier@collabora.com>
Acked-by: Peter Senna Tschudin <peter.senna@collabora.com>
Tested-by: Peter Senna Tschudin <peter.senna@collabora.com>
---
 drivers/usb/gadget/udc/amd5536udc.c | 8 ++++----
 drivers/usb/gadget/udc/amd5536udc.h | 4 ++--
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/usb/gadget/udc/amd5536udc.c b/drivers/usb/gadget/udc/amd5536udc.c
index ea03ca7..270876b 100644
--- a/drivers/usb/gadget/udc/amd5536udc.c
+++ b/drivers/usb/gadget/udc/amd5536udc.c
@@ -583,7 +583,7 @@ udc_alloc_request(struct usb_ep *usbep, gfp_t gfp)
 
 	if (ep->dma) {
 		/* ep0 in requests are allocated from data pool here */
-		dma_desc = pci_pool_alloc(ep->dev->data_requests, gfp,
+		dma_desc = dma_pool_alloc(ep->dev->data_requests, gfp,
 						&req->td_phys);
 		if (!dma_desc) {
 			kfree(req);
@@ -622,7 +622,7 @@ static int udc_free_dma_chain(struct udc *dev, struct udc_request *req)
 	td = phys_to_virt(td_last->next);
 
 	for (i = 1; i < req->chain_len; i++) {
-		pci_pool_free(dev->data_requests, td,
+		dma_pool_free(dev->data_requests, td,
 			      (dma_addr_t)td_last->next);
 		td_last = td;
 		td = phys_to_virt(td_last->next);
@@ -652,7 +652,7 @@ udc_free_request(struct usb_ep *usbep, struct usb_request *usbreq)
 		if (req->chain_len > 1)
 			udc_free_dma_chain(ep->dev, req);
 
-		pci_pool_free(ep->dev->data_requests, req->td_data,
+		dma_pool_free(ep->dev->data_requests, req->td_data,
 							req->td_phys);
 	}
 	kfree(req);
@@ -847,7 +847,7 @@ static int udc_create_dma_chain(
 	for (i = buf_len; i < bytes; i += buf_len) {
 		/* create or determine next desc. */
 		if (create_new_chain) {
-			td = pci_pool_alloc(ep->dev->data_requests,
+			td = dma_pool_alloc(ep->dev->data_requests,
 					    gfp_flags, &dma_addr);
 			if (!td)
 				return -ENOMEM;
diff --git a/drivers/usb/gadget/udc/amd5536udc.h b/drivers/usb/gadget/udc/amd5536udc.h
index 4638d70..85d5aa5 100644
--- a/drivers/usb/gadget/udc/amd5536udc.h
+++ b/drivers/usb/gadget/udc/amd5536udc.h
@@ -545,8 +545,8 @@ struct udc {
 	u32 __iomem			*txfifo;
 
 	/* DMA desc pools */
-	struct pci_pool			*data_requests;
-	struct pci_pool			*stp_requests;
+	struct dma_pool			*data_requests;
+	struct dma_pool			*stp_requests;
 
 	/* device data */
 	unsigned long			phys_addr;
-- 
2.9.3
