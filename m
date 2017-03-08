From: Romain Perier <romain.perier@collabora.com>
Subject: [PATCH v5 16/19] usb: gadget: net2280: Replace PCI pool old API
Date: Wed,  8 Mar 2017 17:19:54 +0100
Message-ID: <20170308161957.28941-17-romain.perier@collabora.com>
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
 drivers/usb/gadget/udc/net2280.c | 12 ++++++------
 drivers/usb/gadget/udc/net2280.h |  2 +-
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/usb/gadget/udc/net2280.c b/drivers/usb/gadget/udc/net2280.c
index 8550441..089081e 100644
--- a/drivers/usb/gadget/udc/net2280.c
+++ b/drivers/usb/gadget/udc/net2280.c
@@ -569,7 +569,7 @@ static struct usb_request
 	if (ep->dma) {
 		struct net2280_dma	*td;
 
-		td = pci_pool_alloc(ep->dev->requests, gfp_flags,
+		td = dma_pool_alloc(ep->dev->requests, gfp_flags,
 				&req->td_dma);
 		if (!td) {
 			kfree(req);
@@ -597,7 +597,7 @@ static void net2280_free_request(struct usb_ep *_ep, struct usb_request *_req)
 	req = container_of(_req, struct net2280_request, req);
 	WARN_ON(!list_empty(&req->queue));
 	if (req->td)
-		pci_pool_free(ep->dev->requests, req->td, req->td_dma);
+		dma_pool_free(ep->dev->requests, req->td, req->td_dma);
 	kfree(req);
 }
 
@@ -3578,10 +3578,10 @@ static void net2280_remove(struct pci_dev *pdev)
 		for (i = 1; i < 5; i++) {
 			if (!dev->ep[i].dummy)
 				continue;
-			pci_pool_free(dev->requests, dev->ep[i].dummy,
+			dma_pool_free(dev->requests, dev->ep[i].dummy,
 					dev->ep[i].td_dma);
 		}
-		pci_pool_destroy(dev->requests);
+		dma_pool_destroy(dev->requests);
 	}
 	if (dev->got_irq)
 		free_irq(pdev->irq, dev);
@@ -3723,7 +3723,7 @@ static int net2280_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 
 	/* DMA setup */
 	/* NOTE:  we know only the 32 LSBs of dma addresses may be nonzero */
-	dev->requests = pci_pool_create("requests", pdev,
+	dev->requests = dma_pool_create("requests", &pdev->dev,
 		sizeof(struct net2280_dma),
 		0 /* no alignment requirements */,
 		0 /* or page-crossing issues */);
@@ -3735,7 +3735,7 @@ static int net2280_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	for (i = 1; i < 5; i++) {
 		struct net2280_dma	*td;
 
-		td = pci_pool_alloc(dev->requests, GFP_KERNEL,
+		td = dma_pool_alloc(dev->requests, GFP_KERNEL,
 				&dev->ep[i].td_dma);
 		if (!td) {
 			ep_dbg(dev, "can't get dummy %d\n", i);
diff --git a/drivers/usb/gadget/udc/net2280.h b/drivers/usb/gadget/udc/net2280.h
index 2736a95..1088c37 100644
--- a/drivers/usb/gadget/udc/net2280.h
+++ b/drivers/usb/gadget/udc/net2280.h
@@ -187,7 +187,7 @@ struct net2280 {
 	struct usb338x_ll_chi_regs	__iomem *ll_chicken_reg;
 	struct usb338x_pl_regs		__iomem *plregs;
 
-	struct pci_pool			*requests;
+	struct dma_pool			*requests;
 	/* statistics...*/
 };
 
-- 
2.9.3
