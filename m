From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH][6 of 7][ATM]: [ambassador] use msleep() instead of schedule_timeout()
Date: Tue, 18 Jan 2005 14:09:52 -0500
Message-ID: <200501181909.j0IJ9q4n022396@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6.

thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/14 08:54:21-05:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [ambassador] use msleep() instead of schedule_timeout()
#   
#   Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
#   Signed-off-by: Domen Puncer <domen@coderock.org>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/ambassador.c
#   2005/01/14 08:54:02-05:00 chas@relax.cmf.nrl.navy.mil +14 -29
#   [ATM]: [ambassador] use msleep() instead of schedule_timeout()
#   
#   Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
#   Signed-off-by: Domen Puncer <domen@coderock.org>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
diff -Nru a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
--- a/drivers/atm/ambassador.c	2005-01-14 09:02:07 -05:00
+++ b/drivers/atm/ambassador.c	2005-01-14 09:02:07 -05:00
@@ -574,7 +574,6 @@
   amb_cq * cq = &dev->cq;
   volatile amb_cq_ptrs * ptrs = &cq->ptrs;
   command * my_slot;
-  unsigned long timeout;
   
   PRINTD (DBG_FLOW|DBG_CMD, "command_do %p", dev);
   
@@ -599,20 +598,14 @@
     // mail the command
     wr_mem (dev, offsetof(amb_mem, mb.adapter.cmd_address), virt_to_bus (ptrs->in));
     
-    // prepare to wait for cq->pending milliseconds
-    // effectively one centisecond on i386
-    timeout = (cq->pending*HZ+999)/1000;
-    
     if (cq->pending > cq->high)
       cq->high = cq->pending;
     spin_unlock (&cq->lock);
     
-    while (timeout) {
-      // go to sleep
-      // PRINTD (DBG_CMD, "wait: sleeping %lu for command", timeout);
-      set_current_state(TASK_UNINTERRUPTIBLE);
-      timeout = schedule_timeout (timeout);
-    }
+    // these comments were in a while-loop before, msleep removes the loop
+    // go to sleep
+    // PRINTD (DBG_CMD, "wait: sleeping %lu for command", timeout);
+    msleep(cq->pending);
     
     // wait for my slot to be reached (all waiters are here or above, until...)
     while (ptrs->out != my_slot) {
@@ -1799,12 +1792,11 @@
   // dump_loader_block (lb);
   wr_mem (dev, offsetof(amb_mem, doorbell), virt_to_bus (lb) & ~onegigmask);
   
-  timeout = command_timeouts[cmd] * HZ/100;
+  timeout = command_timeouts[cmd] * 10;
   
   while (!lb->result || lb->result == cpu_to_be32 (COMMAND_IN_PROGRESS))
     if (timeout) {
-      set_current_state(TASK_UNINTERRUPTIBLE);
-      timeout = schedule_timeout (timeout);
+      timeout = msleep_interruptible(timeout);
     } else {
       PRINTD (DBG_LOAD|DBG_ERR, "command %d timed out", cmd);
       dump_registers (dev);
@@ -1814,10 +1806,10 @@
   
   if (cmd == adapter_start) {
     // wait for start command to acknowledge...
-    timeout = HZ/10;
+    timeout = 100;
     while (rd_plain (dev, offsetof(amb_mem, doorbell)))
       if (timeout) {
-	timeout = schedule_timeout (timeout);
+	timeout = msleep_interruptible(timeout);
       } else {
 	PRINTD (DBG_LOAD|DBG_ERR, "start command did not clear doorbell, res=%08x",
 		be32_to_cpu (lb->result));
@@ -1932,17 +1924,12 @@
   if (diags) { 
     unsigned long timeout;
     // 4.2 second wait
-    timeout = HZ*42/10;
-    while (timeout) {
-      set_current_state(TASK_UNINTERRUPTIBLE);
-      timeout = schedule_timeout (timeout);
-    }
+    msleep(4200);
     // half second time-out
-    timeout = HZ/2;
+    timeout = 500;
     while (!rd_plain (dev, offsetof(amb_mem, mb.loader.ready)))
       if (timeout) {
-        set_current_state(TASK_UNINTERRUPTIBLE);
-	timeout = schedule_timeout (timeout);
+	timeout = msleep_interruptible(timeout);
       } else {
 	PRINTD (DBG_LOAD|DBG_ERR, "reset timed out");
 	return -ETIMEDOUT;
@@ -2056,14 +2043,12 @@
   wr_mem (dev, offsetof(amb_mem, doorbell), virt_to_bus (&a));
   
   // 2.2 second wait (must not touch doorbell during 2 second DMA test)
-  timeout = HZ*22/10;
-  while (timeout)
-    timeout = schedule_timeout (timeout);
+  msleep(2200);
   // give the adapter another half second?
-  timeout = HZ/2;
+  timeout = 500;
   while (rd_plain (dev, offsetof(amb_mem, doorbell)))
     if (timeout) {
-      timeout = schedule_timeout (timeout);
+      timeout = msleep_interruptible(timeout);
     } else {
       PRINTD (DBG_INIT|DBG_ERR, "adapter init timed out");
       return -ETIMEDOUT;
