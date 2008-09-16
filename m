From: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] hso for error -22 (-EINVAL) printk's
Date: Tue, 16 Sep 2008 16:50:41 +0200
Message-ID: <48CFC7C1.6020301@option.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux USB kernel mailing list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux netdev Mailing list <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Added check for IFF_UP in hso_resume, this should eliminate -EINVAL (-22)
errors caused from urb's being submitted twice, once by hso_resume
& once in hso_net_open, if suspend/resume USB power saving  mode is enabled
Signed-off-by: Denis Joseph Barrow <D.Barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
---
Index: linux-2.6.27-rc6/drivers/net/usb/hso.c
===================================================================
--- linux-2.6.27-rc6.orig/drivers/net/usb/hso.c	2008-09-16 16:17:11.000000000 +0200
+++ linux-2.6.27-rc6/drivers/net/usb/hso.c	2008-09-16 16:32:05.000000000 +0200
@@ -2606,18 +2606,21 @@
 		if (network_table[i] &&
 		    (network_table[i]->interface == iface)) {
 			hso_net = dev2net(network_table[i]);
-			/* First transmit any lingering data, then restart the
-			 * device. */
-			if (hso_net->skb_tx_buf) {
-				dev_dbg(&iface->dev,
-					"Transmitting lingering data\n");
-				hso_net_start_xmit(hso_net->skb_tx_buf,
-						   hso_net->net);
-				hso_net->skb_tx_buf = NULL;
+			if (hso_net->flags & IFF_UP) {
+				/* First transmit any lingering data,
+				   then restart the device. */
+				if (hso_net->skb_tx_buf) {
+					dev_dbg(&iface->dev,
+						"Transmitting"
+						" lingering data\n");
+					hso_net_start_xmit(hso_net->skb_tx_buf,
+							   hso_net->net);
+					hso_net->skb_tx_buf = NULL;
+				}
+				result = hso_start_net_device(network_table[i]);
+				if (result)
+					goto out;
 			}
-			result = hso_start_net_device(network_table[i]);
-			if (result)
-				goto out;
 		}
 	}
 

-- 
best regards,
D.J. Barrow
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
