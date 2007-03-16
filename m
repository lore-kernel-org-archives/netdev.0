From: Michal Schmidt <mschmidt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 2/3] airo: Fix an error path memory leak
Date: Fri, 16 Mar 2007 12:42:59 +0100
Message-ID: <45FA82C3.2070502@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: breed-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The airo driver leaks memory if request_irq() fails.

Signed-off-by: Michal Schmidt <mschmidt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 71ac1f1..0d5b433 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -2850,7 +2850,7 @@ static struct net_device *_init_airo_card( unsigned short irq, int port,
 	if (rc) {
 		airo_print_err(dev->name, "register interrupt %d failed, rc %d",
 				irq, rc);
-		goto err_out_unlink;
+		goto err_out_nets;
 	}
 	if (!is_pcmcia) {
 		if (!request_region( dev->base_addr, 64, dev->name )) {
@@ -2933,6 +2933,8 @@ err_out_res:
 	        release_region( dev->base_addr, 64 );
 err_out_irq:
 	free_irq(dev->irq, dev);
+err_out_nets:
+	airo_networks_free(ai);
 err_out_unlink:
 	del_airo_dev(dev);
 err_out_thr:
