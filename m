From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v1 3/4] USBNET: support DMA SG
Date: Sat,  3 Aug 2013 10:46:36 +0800
Message-ID: <1375497998-7424-4-git-send-email-ming.lei@canonical.com>
References: <1375497998-7424-1-git-send-email-ming.lei@canonical.com>
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
Received: from mail-pd0-f173.google.com ([209.85.192.173]:39373 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753512Ab3HCCsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 22:48:13 -0400
In-Reply-To: <1375497998-7424-1-git-send-email-ming.lei@canonical.com>
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
Cc: Oliver Neukum <oneukum@suse.de>
Cc: Alan Stern <stern@rowland.harvard.edu>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/usb/usbnet.c   |   38 ++++++++++++++++++++++++++++++++++++--
 include/linux/usb/usbnet.h |    1 +
 2 files changed, 37 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index e4811d7..51753b3 100644
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
