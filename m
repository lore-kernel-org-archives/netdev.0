From: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Subject: [PATCH v4 17/19] usb: gadget: pch_udc: Replace PCI pool old API
Date: Wed,  1 Mar 2017 16:55:19 +0100
Message-ID: <20170301155521.30281-18-romain.perier@collabora.com>
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
Reviewed-by: Peter Senna Tschudin <peter.senna-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
---
 drivers/usb/gadget/udc/pch_udc.c | 31 +++++++++++++++----------------
 1 file changed, 15 insertions(+), 16 deletions(-)

diff --git a/drivers/usb/gadget/udc/pch_udc.c b/drivers/usb/gadget/udc/pch_udc.c
index a97da64..84dcbcd 100644
--- a/drivers/usb/gadget/udc/pch_udc.c
+++ b/drivers/usb/gadget/udc/pch_udc.c
@@ -355,8 +355,8 @@ struct pch_udc_dev {
 			vbus_session:1,
 			set_cfg_not_acked:1,
 			waiting_zlp_ack:1;
-	struct pci_pool		*data_requests;
-	struct pci_pool		*stp_requests;
+	struct dma_pool		*data_requests;
+	struct dma_pool		*stp_requests;
 	dma_addr_t			dma_addr;
 	struct usb_ctrlrequest		setup_data;
 	void __iomem			*base_addr;
@@ -1522,7 +1522,7 @@ static void pch_udc_free_dma_chain(struct pch_udc_dev *dev,
 		/* do not free first desc., will be done by free for request */
 		td = phys_to_virt(addr);
 		addr2 = (dma_addr_t)td->next;
-		pci_pool_free(dev->data_requests, td, addr);
+		dma_pool_free(dev->data_requests, td, addr);
 		td->next = 0x00;
 		addr = addr2;
 	}
@@ -1539,7 +1539,7 @@ static void pch_udc_free_dma_chain(struct pch_udc_dev *dev,
  *
  * Return codes:
  *	0:		success,
- *	-ENOMEM:	pci_pool_alloc invocation fails
+ *	-ENOMEM:	dma_pool_alloc invocation fails
  */
 static int pch_udc_create_dma_chain(struct pch_udc_ep *ep,
 				    struct pch_udc_request *req,
@@ -1565,7 +1565,7 @@ static int pch_udc_create_dma_chain(struct pch_udc_ep *ep,
 		if (bytes <= buf_len)
 			break;
 		last = td;
-		td = pci_pool_alloc(ep->dev->data_requests, gfp_flags,
+		td = dma_pool_alloc(ep->dev->data_requests, gfp_flags,
 				    &dma_addr);
 		if (!td)
 			goto nomem;
@@ -1770,7 +1770,7 @@ static struct usb_request *pch_udc_alloc_request(struct usb_ep *usbep,
 	if (!ep->dev->dma_addr)
 		return &req->req;
 	/* ep0 in requests are allocated from data pool here */
-	dma_desc = pci_pool_alloc(ep->dev->data_requests, gfp,
+	dma_desc = dma_pool_alloc(ep->dev->data_requests, gfp,
 				  &req->td_data_phys);
 	if (NULL == dma_desc) {
 		kfree(req);
@@ -1809,7 +1809,7 @@ static void pch_udc_free_request(struct usb_ep *usbep,
 	if (req->td_data != NULL) {
 		if (req->chain_len > 1)
 			pch_udc_free_dma_chain(ep->dev, req);
-		pci_pool_free(ep->dev->data_requests, req->td_data,
+		dma_pool_free(ep->dev->data_requests, req->td_data,
 			      req->td_data_phys);
 	}
 	kfree(req);
@@ -2914,7 +2914,7 @@ static int init_dma_pools(struct pch_udc_dev *dev)
 	void				*ep0out_buf;
 
 	/* DMA setup */
-	dev->data_requests = pci_pool_create("data_requests", dev->pdev,
+	dev->data_requests = dma_pool_create("data_requests", &dev->pdev->dev,
 		sizeof(struct pch_udc_data_dma_desc), 0, 0);
 	if (!dev->data_requests) {
 		dev_err(&dev->pdev->dev, "%s: can't get request data pool\n",
@@ -2923,7 +2923,7 @@ static int init_dma_pools(struct pch_udc_dev *dev)
 	}
 
 	/* dma desc for setup data */
-	dev->stp_requests = pci_pool_create("setup requests", dev->pdev,
+	dev->stp_requests = dma_pool_create("setup requests", &dev->pdev->dev,
 		sizeof(struct pch_udc_stp_dma_desc), 0, 0);
 	if (!dev->stp_requests) {
 		dev_err(&dev->pdev->dev, "%s: can't get setup request pool\n",
@@ -2931,7 +2931,7 @@ static int init_dma_pools(struct pch_udc_dev *dev)
 		return -ENOMEM;
 	}
 	/* setup */
-	td_stp = pci_pool_alloc(dev->stp_requests, GFP_KERNEL,
+	td_stp = dma_pool_alloc(dev->stp_requests, GFP_KERNEL,
 				&dev->ep[UDC_EP0OUT_IDX].td_stp_phys);
 	if (!td_stp) {
 		dev_err(&dev->pdev->dev,
@@ -2941,7 +2941,7 @@ static int init_dma_pools(struct pch_udc_dev *dev)
 	dev->ep[UDC_EP0OUT_IDX].td_stp = td_stp;
 
 	/* data: 0 packets !? */
-	td_data = pci_pool_alloc(dev->data_requests, GFP_KERNEL,
+	td_data = dma_pool_alloc(dev->data_requests, GFP_KERNEL,
 				&dev->ep[UDC_EP0OUT_IDX].td_data_phys);
 	if (!td_data) {
 		dev_err(&dev->pdev->dev,
@@ -3021,22 +3021,21 @@ static void pch_udc_remove(struct pci_dev *pdev)
 		dev_err(&pdev->dev,
 			"%s: gadget driver still bound!!!\n", __func__);
 	/* dma pool cleanup */
-	if (dev->data_requests)
-		pci_pool_destroy(dev->data_requests);
+	dma_pool_destroy(dev->data_requests);
 
 	if (dev->stp_requests) {
 		/* cleanup DMA desc's for ep0in */
 		if (dev->ep[UDC_EP0OUT_IDX].td_stp) {
-			pci_pool_free(dev->stp_requests,
+			dma_pool_free(dev->stp_requests,
 				dev->ep[UDC_EP0OUT_IDX].td_stp,
 				dev->ep[UDC_EP0OUT_IDX].td_stp_phys);
 		}
 		if (dev->ep[UDC_EP0OUT_IDX].td_data) {
-			pci_pool_free(dev->stp_requests,
+			dma_pool_free(dev->stp_requests,
 				dev->ep[UDC_EP0OUT_IDX].td_data,
 				dev->ep[UDC_EP0OUT_IDX].td_data_phys);
 		}
-		pci_pool_destroy(dev->stp_requests);
+		dma_pool_destroy(dev->stp_requests);
 	}
 
 	if (dev->dma_addr)
-- 
2.9.3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
