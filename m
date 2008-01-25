From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: [PATCH 08/14] [rndis_host] export functions
Date: Sat, 26 Jan 2008 00:51:17 +0200
Message-ID: <20080125225117.11716.70766.stgit@fate.lan>
References: <20080125225032.11716.77713.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bjd@jooz.net, david-b@pacbell.net
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout4-sn2.hy.skanova.net ([81.228.8.154]:53569 "EHLO
	pne-smtpout4-sn2.hy.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756316AbYAYWvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 17:51:25 -0500
In-Reply-To: <20080125225032.11716.77713.stgit@fate.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Export rndis_host functions and also rename rndis_bind() to
generic_rndis_bind() for modules using rndis_host as base.

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
---

 drivers/net/usb/rndis_host.c |   20 +++++++++++++-------
 drivers/net/usb/rndis_host.h |    9 +++++++++
 2 files changed, 22 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index 29d7e3b..1d6bf0a 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -60,13 +60,14 @@
  * RNDIS notifications from device: command completion; "reverse"
  * keepalives; etc
  */
-static void rndis_status(struct usbnet *dev, struct urb *urb)
+void rndis_status(struct usbnet *dev, struct urb *urb)
 {
 	devdbg(dev, "rndis status urb, len %d stat %d",
 		urb->actual_length, urb->status);
 	// FIXME for keepalives, respond immediately (asynchronously)
 	// if not an RNDIS status, do like cdc_status(dev,urb) does
 }
+EXPORT_SYMBOL_GPL(rndis_status);
 
 /*
  * RPC done RNDIS-style.  Caller guarantees:
@@ -78,7 +79,7 @@ static void rndis_status(struct usbnet *dev, struct urb *urb)
  * Call context is likely probe(), before interface name is known,
  * which is why we won't try to use it in the diagnostics.
  */
-static int rndis_command(struct usbnet *dev, struct rndis_msg_hdr *buf)
+int rndis_command(struct usbnet *dev, struct rndis_msg_hdr *buf)
 {
 	struct cdc_state	*info = (void *) &dev->data;
 	int			master_ifnum;
@@ -187,6 +188,7 @@ static int rndis_command(struct usbnet *dev, struct rndis_msg_hdr *buf)
 	dev_dbg(&info->control->dev, "rndis response timeout\n");
 	return -ETIMEDOUT;
 }
+EXPORT_SYMBOL_GPL(rndis_command);
 
 /*
  * rndis_query:
@@ -253,7 +255,7 @@ response_error:
 	return -EDOM;
 }
 
-static int rndis_bind(struct usbnet *dev, struct usb_interface *intf)
+int generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf)
 {
 	int			retval;
 	struct net_device	*net = dev->net;
@@ -377,8 +379,9 @@ fail:
 	kfree(u.buf);
 	return retval;
 }
+EXPORT_SYMBOL_GPL(generic_rndis_bind);
 
-static void rndis_unbind(struct usbnet *dev, struct usb_interface *intf)
+void rndis_unbind(struct usbnet *dev, struct usb_interface *intf)
 {
 	struct rndis_halt	*halt;
 
@@ -393,11 +396,12 @@ static void rndis_unbind(struct usbnet *dev, struct usb_interface *intf)
 
 	usbnet_cdc_unbind(dev, intf);
 }
+EXPORT_SYMBOL_GPL(rndis_unbind);
 
 /*
  * DATA -- host must not write zlps
  */
-static int rndis_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
+int rndis_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 {
 	/* peripheral may have batched packets to us... */
 	while (likely(skb->len)) {
@@ -439,8 +443,9 @@ static int rndis_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	/* caller will usbnet_skb_return the remaining packet */
 	return 1;
 }
+EXPORT_SYMBOL_GPL(rndis_rx_fixup);
 
-static struct sk_buff *
+struct sk_buff *
 rndis_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
 {
 	struct rndis_data_hdr	*hdr;
@@ -485,12 +490,13 @@ fill:
 	/* FIXME make the last packet always be short ... */
 	return skb;
 }
+EXPORT_SYMBOL_GPL(rndis_tx_fixup);
 
 
 static const struct driver_info	rndis_info = {
 	.description =	"RNDIS device",
 	.flags =	FLAG_ETHER | FLAG_FRAMING_RN | FLAG_NO_SETINT,
-	.bind =		rndis_bind,
+	.bind =		generic_rndis_bind,
 	.unbind =	rndis_unbind,
 	.status =	rndis_status,
 	.rx_fixup =	rndis_rx_fixup,
diff --git a/drivers/net/usb/rndis_host.h b/drivers/net/usb/rndis_host.h
index 1386a17..61f1fd8 100644
--- a/drivers/net/usb/rndis_host.h
+++ b/drivers/net/usb/rndis_host.h
@@ -244,5 +244,14 @@ struct rndis_keepalive_c {	/* IN (optionally OUT) */
 	RNDIS_PACKET_TYPE_ALL_MULTICAST | \
 	RNDIS_PACKET_TYPE_PROMISCUOUS)
 
+
+extern void rndis_status(struct usbnet *dev, struct urb *urb);
+extern int rndis_command(struct usbnet *dev, struct rndis_msg_hdr *buf);
+extern int generic_rndis_bind(struct usbnet *dev, struct usb_interface *intf);
+extern void rndis_unbind(struct usbnet *dev, struct usb_interface *intf);
+extern int rndis_rx_fixup(struct usbnet *dev, struct sk_buff *skb);
+extern struct sk_buff *
+rndis_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags);
+
 #endif	/* __RNDIS_HOST_H */
 

