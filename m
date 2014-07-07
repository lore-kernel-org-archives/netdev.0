From: Olivier Sobrie <olivier@sobrie.be>
Subject: [PATCH 1/2] hso: remove unused workqueue
Date: Mon,  7 Jul 2014 11:06:06 +0200
Message-ID: <1404723967-24245-1-git-send-email-olivier@sobrie.be>
Cc: linux-kernel@vger.kernel.org, Olivier Sobrie <olivier@sobrie.be>
To: Jan Dumon <j.dumon@option.com>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:46143 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751383AbaGGJH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2014 05:07:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The workqueue "retry_unthrottle_workqueue" is not scheduled anywhere
in the code. So, remove it.

Signed-off-by: Olivier Sobrie <olivier@sobrie.be>
---
 drivers/net/usb/hso.c |   12 ------------
 1 file changed, 12 deletions(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index a3a0586..9ca2b41 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -261,7 +261,6 @@ struct hso_serial {
 	u16  curr_rx_urb_offset;
 	u8   rx_urb_filled[MAX_RX_URBS];
 	struct tasklet_struct unthrottle_tasklet;
-	struct work_struct    retry_unthrottle_workqueue;
 };
 
 struct hso_device {
@@ -1252,14 +1251,6 @@ static	void hso_unthrottle(struct tty_struct *tty)
 	tasklet_hi_schedule(&serial->unthrottle_tasklet);
 }
 
-static void hso_unthrottle_workfunc(struct work_struct *work)
-{
-	struct hso_serial *serial =
-	    container_of(work, struct hso_serial,
-			 retry_unthrottle_workqueue);
-	hso_unthrottle_tasklet(serial);
-}
-
 /* open the requested serial port */
 static int hso_serial_open(struct tty_struct *tty, struct file *filp)
 {
@@ -1295,8 +1286,6 @@ static int hso_serial_open(struct tty_struct *tty, struct file *filp)
 		tasklet_init(&serial->unthrottle_tasklet,
 			     (void (*)(unsigned long))hso_unthrottle_tasklet,
 			     (unsigned long)serial);
-		INIT_WORK(&serial->retry_unthrottle_workqueue,
-			  hso_unthrottle_workfunc);
 		result = hso_start_serial_device(serial->parent, GFP_KERNEL);
 		if (result) {
 			hso_stop_serial_device(serial->parent);
@@ -1345,7 +1334,6 @@ static void hso_serial_close(struct tty_struct *tty, struct file *filp)
 		if (!usb_gone)
 			hso_stop_serial_device(serial->parent);
 		tasklet_kill(&serial->unthrottle_tasklet);
-		cancel_work_sync(&serial->retry_unthrottle_workqueue);
 	}
 
 	if (!usb_gone)
-- 
1.7.9.5
