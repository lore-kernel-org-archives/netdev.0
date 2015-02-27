From: Aleksander Morgado <aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>
Subject: [PATCH] hso: add missing spinlock grab when iterating the serial table
Date: Fri, 27 Feb 2015 19:44:52 +0100
Message-ID: <1425062692-25155-1-git-send-email-aleksander@aleksander.es>
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Aleksander Morgado <aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>
To: j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Access to the 'serial_table' array needs to be protected by the spinlock.

Signed-off-by: Aleksander Morgado <aleksander-Dvg4H30XQSRVIjRurl1/8g@public.gmane.org>
---
 drivers/net/usb/hso.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 3c8dfe5..4f6deff 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -607,19 +607,24 @@ static struct hso_serial *get_serial_by_shared_int_and_type(
 					struct hso_shared_int *shared_int,
 					int mux)
 {
+	struct hso_serial *serial = NULL;
 	int i, port;
+	unsigned long flags;
 
 	port = hso_mux_to_port(mux);
 
+	spin_lock_irqsave(&serial_table_lock, flags);
 	for (i = 0; i < HSO_SERIAL_TTY_MINORS; i++) {
 		if (serial_table[i] &&
 		    (dev2ser(serial_table[i])->shared_int == shared_int) &&
 		    ((serial_table[i]->port_spec & HSO_PORT_MASK) == port)) {
-			return dev2ser(serial_table[i]);
+			serial = dev2ser(serial_table[i]);
+			break;
 		}
 	}
+	spin_unlock_irqrestore(&serial_table_lock, flags);
 
-	return NULL;
+	return serial;
 }
 
 static struct hso_serial *get_serial_by_index(unsigned index)
-- 
2.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
