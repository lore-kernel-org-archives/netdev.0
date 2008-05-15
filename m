From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: [patch] resource leak in error case in rtl8187 #2
Date: Thu, 15 May 2008 21:49:16 +0200
Message-ID: <200805152149.16876.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>,
	Andrea Merello <andreamrl-IWqWACnzNjyonA0d6jMUrA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

this fixes resource leaks in error cases due to urb submission failures.

	Regards
		Oliver

Signed-off-by: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>

---

--- linux-2.6.26-rc1/drivers/net/wireless/rtl8187_dev.c.alt	2008-05-15 15:53:58.000000000 +0200
+++ linux-2.6.26-rc1/drivers/net/wireless/rtl8187_dev.c	2008-05-15 21:42:02.000000000 +0200
@@ -92,6 +92,7 @@ static void rtl8187_iowrite_async(struct
 		u8 data[4];
 		struct usb_ctrlrequest dr;
 	} *buf;
+	int rc;
 
 	buf = kmalloc(sizeof(*buf), GFP_ATOMIC);
 	if (!buf)
@@ -116,7 +117,11 @@ static void rtl8187_iowrite_async(struct
 	usb_fill_control_urb(urb, priv->udev, usb_sndctrlpipe(priv->udev, 0),
 			     (unsigned char *)dr, buf, len,
 			     rtl8187_iowrite_async_cb, buf);
-	usb_submit_urb(urb, GFP_ATOMIC);
+	rc = usb_submit_urb(urb, GFP_ATOMIC);
+	if (rc < 0) {
+		kfree(buf);
+		usb_free_urb(urb);
+	}
 }
 
 static inline void rtl818x_iowrite32_async(struct rtl8187_priv *priv,
@@ -169,6 +174,7 @@ static int rtl8187_tx(struct ieee80211_h
 	struct urb *urb;
 	__le16 rts_dur = 0;
 	u32 flags;
+	int rc;
 
 	urb = usb_alloc_urb(0, GFP_ATOMIC);
 	if (!urb) {
@@ -208,7 +214,11 @@ static int rtl8187_tx(struct ieee80211_h
 	info->dev = dev;
 	usb_fill_bulk_urb(urb, priv->udev, usb_sndbulkpipe(priv->udev, 2),
 			  hdr, skb->len, rtl8187_tx_cb, skb);
-	usb_submit_urb(urb, GFP_ATOMIC);
+	rc = usb_submit_urb(urb, GFP_ATOMIC);
+	if (rc < 0) {
+		usb_free_urb(urb);
+		kfree_skb(skb);
+	}
 
 	return 0;
 }
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
