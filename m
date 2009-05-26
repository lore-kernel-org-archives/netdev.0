From: Tadashi Abe <tabe@mvista.com>
Subject: [PATCH] irda-usb: suspend/resume support
Date: Tue, 26 May 2009 15:53:27 +0900
Message-ID: <4A1B91E7.8010606@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sonicwall.montavista.co.jp ([202.232.97.131]:19791 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754087AbZEZH0J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 03:26:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds power management suspend/resume hooks for irda-usb.

Signed-off-by: Tadashi Abe <tabe@mvista.com>
---
 drivers/net/irda/irda-usb.c |   40 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 40 insertions(+), 0 deletions(-)

diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index 006ba23..394b2b1 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -1859,6 +1859,42 @@ static void irda_usb_disconnect(struct usb_interface *intf)
 	IRDA_DEBUG(0, "%s(), USB IrDA Disconnected\n", __func__);
 }
 
+#ifdef CONFIG_PM
+/* USB suspend, so power off the transmitter/receiver */
+static int irda_usb_suspend(struct usb_interface *intf, pm_message_t message)
+{
+	struct irda_usb_cb *self = usb_get_intfdata(intf);
+	int i;
+
+	netif_device_detach(self->netdev);
+
+	if (self->tx_urb != NULL)
+		usb_kill_urb(self->tx_urb);
+	if (self->speed_urb != NULL)
+		usb_kill_urb(self->speed_urb);
+	for (i = 0; i < self->max_rx_urb; i++) {
+		if (self->rx_urb[i] != NULL)
+			usb_kill_urb(self->rx_urb[i]);
+	}
+	return 0;
+}
+
+/* Coming out of suspend, so reset hardware */
+static int irda_usb_resume(struct usb_interface *intf)
+{
+	struct irda_usb_cb *self = usb_get_intfdata(intf);
+	int i;
+
+	for (i = 0; i < self->max_rx_urb; i++) {
+		if (self->rx_urb[i] != NULL)
+			usb_submit_urb(self->rx_urb[i], GFP_KERNEL);
+	}
+
+	netif_device_attach(self->netdev);
+	return 0;
+}
+#endif
+
 /*------------------------------------------------------------------*/
 /*
  * USB device callbacks
@@ -1868,6 +1904,10 @@ static struct usb_driver irda_driver = {
 	.probe		= irda_usb_probe,
 	.disconnect	= irda_usb_disconnect,
 	.id_table	= dongles,
+#ifdef CONFIG_PM
+	.suspend	= irda_usb_suspend,
+	.resume		= irda_usb_resume,
+#endif
 };
 
 /************************* MODULE CALLBACKS *************************/
