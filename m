From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v4 3/4] USBNET: support DMA SG
Date: Thu,  8 Aug 2013 21:48:24 +0800
Message-ID: <1375969705-24877-4-git-send-email-ming.lei@canonical.com>
References: <1375969705-24877-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>,
	Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Ming Lei <ming.lei@canonical.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Grant Grundler <grundler@google.com>,
	Freddy Xin <freddy@asix.com.tw>,
	Alan Stern <stern@rowland.harvard.edu>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:41689 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965336Ab3HHNtx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 09:49:53 -0400
In-Reply-To: <1375969705-24877-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces support of DMA SG if the USB host controller
which usbnet device is attached to is capable of building packet from
discontinuous buffers.

The patch supports passing the skb fragment buffers to usb stack directly
via urb->sg.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>
Cc: Grant Grundler <grundler@google.com>
Cc: Freddy Xin <freddy@asix.com.tw>
Cc: Alan Stern <stern@rowland.harvard.edu>
Acked-by: Oliver Neukum <oneukum@suse.de>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/usb/usbnet.c   |   45 +++++++++++++++++++++++++++++++++++++++++---
 include/linux/usb/usbnet.h |    1 +
 2 files changed, 43 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index e4811d7..534b60b 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1232,6 +1232,37 @@ EXPORT_SYMBOL_GPL(usbnet_tx_timeout);
 
 /*-------------------------------------------------------------------------*/
 
+static int build_dma_sg(const struct sk_buff *skb, struct urb *urb)
+{
+	unsigned num_sgs, total_len = 0;
+	int i, s = 0;
+
+	num_sgs = skb_shinfo(skb)->nr_frags + 1;
+	if (num_sgs == 1)
+		return 0;
+
+	urb->sg = kmalloc(num_sgs * sizeof(struct scatterlist), GFP_ATOMIC);
+	if (!urb->sg)
+		return -ENOMEM;
+
+	urb->num_sgs = num_sgs;
+	sg_init_table(urb->sg, urb->num_sgs);
+
+	sg_set_buf(&urb->sg[s++], skb->data, skb_headlen(skb));
+	total_len += skb_headlen(skb);
+
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		struct skb_frag_struct *f = &skb_shinfo(skb)->frags[i];
+
+		total_len += skb_frag_size(f);
+		sg_set_page(&urb->sg[i + s], f->page.p, f->size,
+				f->page_offset);
+	}
+	urb->transfer_buffer_length = total_len;
+
+	return 1;
+}
+
 netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 				     struct net_device *net)
 {
@@ -1258,7 +1289,6 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 			goto drop;
 		}
 	}
-	length = skb->len;
 
 	if (!(urb = usb_alloc_urb (0, GFP_ATOMIC))) {
 		netif_dbg(dev, tx_err, dev->net, "no urb\n");
@@ -1268,10 +1298,14 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 	entry = (struct skb_data *) skb->cb;
 	entry->urb = urb;
 	entry->dev = dev;
-	entry->length = length;
 
 	usb_fill_bulk_urb (urb, dev->udev, dev->out,
 			skb->data, skb->len, tx_complete, skb);
+	if (dev->can_dma_sg) {
+		if (build_dma_sg(skb, urb) < 0)
+			goto drop;
+	}
+	entry->length = length = urb->transfer_buffer_length;
 
 	/* don't assume the hardware handles USB_ZERO_PACKET
 	 * NOTE:  strictly conforming cdc-ether devices should expect
@@ -1340,7 +1374,10 @@ drop:
 not_drop:
 		if (skb)
 			dev_kfree_skb_any (skb);
-		usb_free_urb (urb);
+		if (urb) {
+			kfree(urb->sg);
+			usb_free_urb(urb);
+		}
 	} else
 		netif_dbg(dev, tx_queued, dev->net,
 			  "> tx, len %d, type 0x%x\n", length, skb->protocol);
@@ -1391,6 +1428,7 @@ static void usbnet_bh (unsigned long param)
 			rx_process (dev, skb);
 			continue;
 		case tx_done:
+			kfree(entry->urb->sg);
 		case rx_cleanup:
 			usb_free_urb (entry->urb);
 			dev_kfree_skb (skb);
@@ -1727,6 +1765,7 @@ int usbnet_resume (struct usb_interface *intf)
 			retval = usb_submit_urb(res, GFP_ATOMIC);
 			if (retval < 0) {
 				dev_kfree_skb_any(skb);
+				kfree(res->sg);
 				usb_free_urb(res);
 				usb_autopm_put_interface_async(dev->intf);
 			} else {
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 8fbc008..9cb2fe8 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -35,6 +35,7 @@ struct usbnet {
 	unsigned char		suspend_count;
 	unsigned char		pkt_cnt, pkt_err;
 	unsigned short		rx_qlen, tx_qlen;
+	unsigned		can_dma_sg:1;
 
 	/* i/o info: pipes etc */
 	unsigned		in, out;
-- 
1.7.9.5
