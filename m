From: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Subject: [PATCH v4 15/19] usb: gadget: amd5536udc: Replace PCI pool old API
Date: Wed,  1 Mar 2017 16:55:17 +0100
Message-ID: <20170301155521.30281-16-romain.perier@collabora.com>
References: <20170301155521.30281-1-romain.perier@collabora.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>,
        Peter Senna Tschudin <peter.senna-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org>
To: Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        "James E.J. Bottomley" <jejb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        "Martin K. Petersen" <martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Felipe Balbi <balbi-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170301155521.30281-1-romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The PCI pool API is deprecated. This commits replaces the PCI pool old
API by the appropriated function with the DMA pool API.

Signed-off-by: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Acked-by: Peter Senna Tschudin <peter.senna-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Tested-by: Peter Senna Tschudin <peter.senna-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
