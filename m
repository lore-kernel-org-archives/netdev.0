From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: [patch] resource leak in error case in rtl8187
Date: Thu, 15 May 2008 16:17:36 +0200
Message-ID: <200805151617.37968.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>,
	Andrea Merello <andreamrl-IWqWACnzNjyonA0d6jMUrA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

this fixes a resource leak in the error case of the write code path.

	Regards
		Oliver

Signed-off-by: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>

---

--- linux-2.6.26-rc1/drivers/net/wireless/rtl8187_dev.c.alt	2008-05-15 15:53:58.000000000 +0200
+++ linux-2.6.26-rc1/drivers/net/wireless/rtl8187_dev.c	2008-05-15 15:57:35.000000000 +0200
@@ -169,6 +169,7 @@ static int rtl8187_tx(struct ieee80211_h
 	struct urb *urb;
 	__le16 rts_dur = 0;
 	u32 flags;
+	int rv;
 
 	urb = usb_alloc_urb(0, GFP_ATOMIC);
 	if (!urb) {
@@ -208,7 +209,11 @@ static int rtl8187_tx(struct ieee80211_h
 	info->dev = dev;
 	usb_fill_bulk_urb(urb, priv->udev, usb_sndbulkpipe(priv->udev, 2),
 			  hdr, skb->len, rtl8187_tx_cb, skb);
-	usb_submit_urb(urb, GFP_ATOMIC);
+	rv = usb_submit_urb(urb, GFP_ATOMIC);
+	if (rv < 0) {
+		usb_free_urb(urb);
+		kfree_skb(skb);
+	}
 
 	return 0;
 }
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
