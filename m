From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 3 of 3][ATM]: [zatm] replace sleep_on() with wait_event()
Date: Fri, 04 Feb 2005 13:23:53 -0500
Message-ID: <200502041823.j14INqY4020685@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6.

thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/02/03 12:05:12-05:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [zatm] replace sleep_on() with wait_event()
#   
#     Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
#     Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/zatm.c
#   2005/02/03 12:04:54-05:00 chas@relax.cmf.nrl.navy.mil +10 -19
#   [ATM]: [zatm] replace sleep_on() with wait_event()
#   
#     Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
#     Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
diff -Nru a/drivers/atm/zatm.c b/drivers/atm/zatm.c
--- a/drivers/atm/zatm.c	2005-02-03 12:18:33 -05:00
+++ b/drivers/atm/zatm.c	2005-02-03 12:18:33 -05:00
@@ -22,6 +22,7 @@
 #include <linux/atm_zatm.h>
 #include <linux/capability.h>
 #include <linux/bitops.h>
+#include <linux/wait.h>
 #include <asm/byteorder.h>
 #include <asm/system.h>
 #include <asm/string.h>
@@ -867,31 +868,21 @@
 	struct zatm_vcc *zatm_vcc;
 	unsigned long flags;
 	int chan;
-struct sk_buff *skb;
-int once = 1;
 
 	zatm_vcc = ZATM_VCC(vcc);
 	zatm_dev = ZATM_DEV(vcc->dev);
 	chan = zatm_vcc->tx_chan;
 	if (!chan) return;
 	DPRINTK("close_tx\n");
-	while (skb_peek(&zatm_vcc->backlog)) {
-if (once) {
-printk("waiting for backlog to drain ...\n");
-event_dump();
-once = 0;
-}
-		sleep_on(&zatm_vcc->tx_wait);
-	}
-once = 1;
-	while ((skb = skb_peek(&zatm_vcc->tx_queue))) {
-if (once) {
-printk("waiting for TX queue to drain ... %p\n",skb);
-event_dump();
-once = 0;
-}
-		DPRINTK("waiting for TX queue to drain ... %p\n",skb);
-		sleep_on(&zatm_vcc->tx_wait);
+	if (skb_peek(&zatm_vcc->backlog)) {
+		printk("waiting for backlog to drain ...\n");
+		event_dump();
+		wait_event(zatm_vcc->tx_wait, !skb_peek(&zatm_vcc->backlog));
+	}
+	if (skb_peek(&zatm_vcc->tx_queue)) {
+		printk("waiting for TX queue to drain ...\n");
+		event_dump();
+		wait_event(zatm_vcc->tx_wait, !skb_peek(&zatm_vcc->tx_queue));
 	}
 	spin_lock_irqsave(&zatm_dev->lock, flags);
 #if 0
