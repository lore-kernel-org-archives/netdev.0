From: Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 1/2] hso: fix for crash when unplugging the device
Date: Thu, 2 Apr 2009 10:57:20 +0200
Message-ID: <20090402085720.GA8663@raptor>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>

Changed the order in which things are freed. This fixes an oops when
unplugging the device while network traffic is ongoing.
    
Signed-off-by: Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
---
diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 28d1424..779a007 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -5,6 +5,7 @@
  *  Copyright (C) 2008 Option International
  *                     Filip Aben <f.aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
  *                     Denis Joseph Barrow <d.barow-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
+ *                     Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
  *  Copyright (C) 2007 Andrew Bird (Sphere Systems Ltd)
  *  			<ajb-5+cxppFmGx6/3pe1ocb+s/XRex20P6io@public.gmane.org>
  *  Copyright (C) 2008 Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>
@@ -2417,20 +2418,22 @@ static void hso_free_net_device(struct hso_device *hso_dev)
 	if (!hso_net)
 		return;
 
+	remove_net_device(hso_net->parent);
+
+	if (hso_net->net) {
+		unregister_netdev(hso_net->net);
+		free_netdev(hso_net->net);
+	}
+
 	/* start freeing */
 	for (i = 0; i < MUX_BULK_RX_BUF_COUNT; i++) {
 		usb_free_urb(hso_net->mux_bulk_rx_urb_pool[i]);
 		kfree(hso_net->mux_bulk_rx_buf_pool[i]);
+		hso_net->mux_bulk_rx_buf_pool[i] = NULL;
 	}
 	usb_free_urb(hso_net->mux_bulk_tx_urb);
 	kfree(hso_net->mux_bulk_tx_buf);
-
-	remove_net_device(hso_net->parent);
