From: domen@coderock.org
Subject: [patch 18/26] net/8139too: remove interruptible_sleep_on_timeout() usage
Date: Sun, 06 Mar 2005 11:33:36 +0100
Message-ID: <20050306103337.3B60B1F202@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, nacc@us.ibm.com
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



One thing I would have preferred using here is use wait_event*(), but there is
no condition. However, try_to_freeze(PF_FREEZE) could be used as one, if the
return condition matters -- it can return 0 or 1, from what I understand. If the
intent is to loop until the task is "frozen," then I can revise the patch to use
wait_event_interruptible_timeout().

Replace deprecated interruptible_sleep_on_timeout() function calls
with direct wait-queue usage. I did not find the direct wake_up_interruptible()
function call in this file for the wait-queue, but that may not be an issue.
Patch is compile-tested.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/drivers/net/8139too.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletion(-)

diff -puN drivers/net/8139too.c~int_sleep_on-drivers_net_8139too drivers/net/8139too.c
--- kj/drivers/net/8139too.c~int_sleep_on-drivers_net_8139too	2005-03-05 16:12:09.000000000 +0100
+++ kj-domen/drivers/net/8139too.c	2005-03-05 16:12:09.000000000 +0100
@@ -108,6 +108,7 @@
 #include <linux/mii.h>
 #include <linux/completion.h>
 #include <linux/crc32.h>
+#include <linux/wait.h>
 #include <asm/io.h>
 #include <asm/uaccess.h>
 #include <asm/irq.h>
@@ -1612,6 +1613,7 @@ static inline void rtl8139_thread_iter (
 
 static int rtl8139_thread (void *data)
 {
+	DEFINE_WAIT(wait);
 	struct net_device *dev = data;
 	struct rtl8139_private *tp = dev->priv;
 	unsigned long timeout;
@@ -1622,7 +1624,9 @@ static int rtl8139_thread (void *data)
 	while (1) {
 		timeout = next_tick;
 		do {
-			timeout = interruptible_sleep_on_timeout (&tp->thr_wait, timeout);
+			prepare_to_wait(&tp->thr_wait, &wait, TASK_INTERRUPTIBLE);
+			timeout = schedule_timeout(timeout);
+			finish_wait(&tp->thr_wait, &wait);
 			/* make swsusp happy with our thread */
 			try_to_freeze(PF_FREEZE);
 		} while (!signal_pending (current) && (timeout > 0));
_
