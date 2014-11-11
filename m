From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH v2 3/5] phonet: Replace calls to __skb_alloc_page
 with __netdev_alloc_page
Date: Tue, 11 Nov 2014 09:11:09 -0800
Message-ID: <20141111171109.15976.13624.stgit@ahduyck-vm-fedora20>
References: <20141111170711.15976.44062.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: leedom@chelsio.com, hariprasad@chelsio.com,
	donald.c.skidmore@intel.com, oliver@neukum.org, balbi@ti.com,
	matthew.vick@intel.com, mgorman@suse.de, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60314 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751184AbaKKRL0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2014 12:11:26 -0500
In-Reply-To: <20141111170711.15976.44062.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace the calls to __skb_alloc_page that are passed NULL with calls to
__netdev_alloc_page.

In addition remove __GFP_COLD flag from allocations as we only want it for
the Rx buffer which is taken care of by __dev_alloc_skb, not for any
secondary allocations such as the queue element transmit descriptors.

Cc: Oliver Neukum <oliver@neukum.org>
Cc: Felipe Balbi <balbi@ti.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/usb/cdc-phonet.c           |    6 +++---
 drivers/usb/gadget/function/f_phonet.c |    6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/cdc-phonet.c b/drivers/net/usb/cdc-phonet.c
index 2ec1500..415ce8b 100644
--- a/drivers/net/usb/cdc-phonet.c
+++ b/drivers/net/usb/cdc-phonet.c
@@ -130,7 +130,7 @@ static int rx_submit(struct usbpn_dev *pnd, struct urb *req, gfp_t gfp_flags)
 	struct page *page;
 	int err;
 
-	page = __skb_alloc_page(gfp_flags | __GFP_NOMEMALLOC, NULL);
+	page = __dev_alloc_page(gfp_flags | __GFP_NOMEMALLOC);
 	if (!page)
 		return -ENOMEM;
 
@@ -212,7 +212,7 @@ resubmit:
 	if (page)
 		put_page(page);
 	if (req)
-		rx_submit(pnd, req, GFP_ATOMIC | __GFP_COLD);
+		rx_submit(pnd, req, GFP_ATOMIC);
 }
 
 static int usbpn_close(struct net_device *dev);
@@ -231,7 +231,7 @@ static int usbpn_open(struct net_device *dev)
 	for (i = 0; i < rxq_size; i++) {
 		struct urb *req = usb_alloc_urb(0, GFP_KERNEL);
 
-		if (!req || rx_submit(pnd, req, GFP_KERNEL | __GFP_COLD)) {
+		if (!req || rx_submit(pnd, req, GFP_KERNEL)) {
 			usb_free_urb(req);
 			usbpn_close(dev);
 			return -ENOMEM;
diff --git a/drivers/usb/gadget/function/f_phonet.c b/drivers/usb/gadget/function/f_phonet.c
index b9cfc15..cde7397 100644
--- a/drivers/usb/gadget/function/f_phonet.c
+++ b/drivers/usb/gadget/function/f_phonet.c
@@ -303,7 +303,7 @@ pn_rx_submit(struct f_phonet *fp, struct usb_request *req, gfp_t gfp_flags)
 	struct page *page;
 	int err;
 
-	page = __skb_alloc_page(gfp_flags | __GFP_NOMEMALLOC, NULL);
+	page = __dev_alloc_page(gfp_flags | __GFP_NOMEMALLOC);
 	if (!page)
 		return -ENOMEM;
 
@@ -377,7 +377,7 @@ static void pn_rx_complete(struct usb_ep *ep, struct usb_request *req)
 	if (page)
 		put_page(page);
 	if (req)
-		pn_rx_submit(fp, req, GFP_ATOMIC | __GFP_COLD);
+		pn_rx_submit(fp, req, GFP_ATOMIC);
 }
 
 /*-------------------------------------------------------------------------*/
@@ -437,7 +437,7 @@ static int pn_set_alt(struct usb_function *f, unsigned intf, unsigned alt)
 
 			netif_carrier_on(dev);
 			for (i = 0; i < phonet_rxq_size; i++)
-				pn_rx_submit(fp, fp->out_reqv[i], GFP_ATOMIC | __GFP_COLD);
+				pn_rx_submit(fp, fp->out_reqv[i], GFP_ATOMIC);
 		}
 		spin_unlock(&port->lock);
 		return 0;
