From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 2 of 3][ATM]: [iphase] remove sleep_on*() usage
Date: Fri, 04 Feb 2005 13:23:34 -0500
Message-ID: <200502041823.j14INXtL020671@ginger.cmf.nrl.navy.mil>
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
#   2005/02/03 11:28:25-05:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [iphase] remove sleep_on*() usage
#   
#     Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
#     Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/iphase.c
#   2005/02/03 11:26:35-05:00 chas@relax.cmf.nrl.navy.mil +12 -14
#   [ATM]: [iphase] remove sleep_on*() usage
#   
#     Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
#     Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
diff -Nru a/drivers/atm/iphase.c b/drivers/atm/iphase.c
--- a/drivers/atm/iphase.c	2005-02-03 12:17:19 -05:00
+++ b/drivers/atm/iphase.c	2005-02-03 12:17:19 -05:00
@@ -53,6 +53,7 @@
 #include <linux/delay.h>  
 #include <linux/uio.h>  
 #include <linux/init.h>  
+#include <linux/wait.h>
 #include <asm/system.h>  
 #include <asm/io.h>  
 #include <asm/atomic.h>  
@@ -2586,14 +2587,14 @@
 }  
   
 static void ia_close(struct atm_vcc *vcc)  
-{  
+{
+	DEFINE_WAIT(wait);
         u16 *vc_table;
         IADEV *iadev;
         struct ia_vcc *ia_vcc;
         struct sk_buff *skb = NULL;
         struct sk_buff_head tmp_tx_backlog, tmp_vcc_backlog;
         unsigned long closetime, flags;
-        int ctimeout;
 
         iadev = INPH_IA_DEV(vcc->dev);
         ia_vcc = INPH_IA_VCC(vcc);
@@ -2606,7 +2607,9 @@
         skb_queue_head_init (&tmp_vcc_backlog); 
         if (vcc->qos.txtp.traffic_class != ATM_NONE) {
            iadev->close_pending++;
-           sleep_on_timeout(&iadev->timeout_wait, 50);
+	   prepare_to_wait(&iadev->timeout_wait, &wait, TASK_UNINTERRUPTIBLE);
+	   schedule_timeout(50);
+	   finish_wait(&iadev->timeout_wait, &wait);
            spin_lock_irqsave(&iadev->tx_lock, flags); 
            while((skb = skb_dequeue(&iadev->tx_backlog))) {
               if (ATM_SKB(skb)->vcc == vcc){ 
@@ -2619,17 +2622,12 @@
            while((skb = skb_dequeue(&tmp_tx_backlog))) 
              skb_queue_tail(&iadev->tx_backlog, skb);
            IF_EVENT(printk("IA TX Done decs_cnt = %d\n", ia_vcc->vc_desc_cnt);) 
-           closetime = jiffies;
-           ctimeout = 300000 / ia_vcc->pcr;
-           if (ctimeout == 0)
-              ctimeout = 1;
-           while (ia_vcc->vc_desc_cnt > 0){
-              if ((jiffies - closetime) >= ctimeout) 
-                 break;
-              spin_unlock_irqrestore(&iadev->tx_lock, flags);
-              sleep_on(&iadev->close_wait);
-              spin_lock_irqsave(&iadev->tx_lock, flags);
-           }    
+           closetime = 300000 / ia_vcc->pcr;
+           if (closetime == 0)
+              closetime = 1;
+           spin_unlock_irqrestore(&iadev->tx_lock, flags);
+           wait_event_timeout(iadev->close_wait, (ia_vcc->vc_desc_cnt <= 0), closetime);
+           spin_lock_irqsave(&iadev->tx_lock, flags);
            iadev->close_pending--;
            iadev->testTable[vcc->vci]->lastTime = 0;
            iadev->testTable[vcc->vci]->fract = 0; 
