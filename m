From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net,stable 3/3] net: qmi_wwan: prevent duplicate mac address on link (firmware bug workaround)
Date: Fri, 19 Apr 2013 00:57:11 +0200
Message-ID: <1366325831-13727-4-git-send-email-bjorn@mork.no>
References: <1366325831-13727-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1366325831-13727-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

We normally trust and use the CDC functional descriptors provided by a
number of devices.  But some of these will erroneously list the address
reserved for the device end of the link.  Attempting to use this on
both the device and host side will naturally not work.

Work around this bug by ignoring the functional descriptor and assign a
random address instead in this case.

Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/qmi_wwan.c |    9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index cff0bbd..2a3579f 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -53,6 +53,9 @@ struct qmi_wwan_state {
 	struct usb_interface *data;
 };
=20
+/* default ethernet address used by the modem */
+static const u8 default_modem_addr[ETH_ALEN] =3D {0x02, 0x50, 0xf3};
+
 /* Make up an ethernet header if the packet doesn't have one.
  *
  * A firmware bug common among several devices cause them to send raw
@@ -317,6 +320,12 @@ next_desc:
 		usb_driver_release_interface(driver, info->data);
 	}
=20
+	/* Never use the same address on both ends of the link, even
+	 * if the buggy firmware told us to.
+	 */
+	if (!compare_ether_addr(dev->net->dev_addr, default_modem_addr))
+		eth_hw_addr_random(dev->net);
+
 	/* make MAC addr easily distinguishable from an IP header */
 	if (possibly_iphdr(dev->net->dev_addr)) {
 		dev->net->dev_addr[0] |=3D 0x02;	/* set local assignment bit */
--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
