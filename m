From: Ben Chan <benchan-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: [PATCH 2/2] net: cdc_ncm: respect operator preferred MTU reported by MBIM
Date: Sat, 15 Mar 2014 23:49:10 -0700
Message-ID: <1394952550-9308-2-git-send-email-benchan@chromium.org>
References: <1394952550-9308-1-git-send-email-benchan@chromium.org>
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394952550-9308-1-git-send-email-benchan-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

According to "Universal Serial Bus Communications Class Subclass
Specification for Mobile Broadband Interface Model, Revision 1.0,
Errata-1" published by USB-IF, the wMTU field of the MBIM extended
functional descriptor indicates the operator preferred MTU for IP data
streams.

This patch modifies cdc_ncm_setup to ensure that the MTU value set on
the usbnet device does not exceed the operator preferred MTU indicated
by wMTU if the MBIM device exposes a MBIM extended functional
descriptor.

Signed-off-by: Ben Chan <benchan-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
---
 drivers/net/usb/cdc_ncm.c   | 15 +++++++++++++++
 include/linux/usb/cdc_ncm.h |  1 +
 2 files changed, 16 insertions(+)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index dbff290..0b036ed 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -261,6 +261,13 @@ out:
 	/* set MTU to max supported by the device if necessary */
 	if (dev->net->mtu > ctx->max_datagram_size - eth_hlen)
 		dev->net->mtu = ctx->max_datagram_size - eth_hlen;
+
+	/* do not exceed operater preferred MTU */
+	if (ctx->mbim_extended_desc &&
+		ctx->mbim_extended_desc->wMTU != 0 &&
+		dev->net->mtu > ctx->mbim_extended_desc->wMTU)
+		dev->net->mtu = ctx->mbim_extended_desc->wMTU;
+
 	return 0;
 }
 
@@ -399,6 +406,14 @@ int cdc_ncm_bind_common(struct usbnet *dev, struct usb_interface *intf, u8 data_
 			ctx->mbim_desc = (const struct usb_cdc_mbim_desc *)buf;
 			break;
 
+		case USB_CDC_MBIM_EXTENDED_TYPE:
+			if (buf[0] < sizeof(*(ctx->mbim_extended_desc)))
+				break;
+
+			ctx->mbim_extended_desc =
+				(const struct usb_cdc_mbim_extended_desc *)buf;
+			break;
+
 		default:
 			break;
 		}
diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index c3fa807..bdf05fb 100644
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -93,6 +93,7 @@ struct cdc_ncm_ctx {
 
 	const struct usb_cdc_ncm_desc *func_desc;
 	const struct usb_cdc_mbim_desc *mbim_desc;
+	const struct usb_cdc_mbim_extended_desc *mbim_extended_desc;
 	const struct usb_cdc_ether_desc *ether_desc;
 
 	struct usb_interface *control;
-- 
1.9.0.279.gdc9e3eb

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
