From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [KJ] [PATCH 3/20] net/8139too: remove
	interruptible_sleep_on_timeout() usage
Date: Wed, 2 Feb 2005 10:11:29 -0800
Message-ID: <20050202181129.GD2546@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============15164152380464313=="
Cc: netdev@oss.sgi.com, kernel-janitors@lists.osdl.org
To: jgarzik@pobox.com
List-Unsubscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/kernel-janitors>
List-Post: <mailto:kernel-janitors@lists.osdl.org>
List-Help: <mailto:kernel-janitors-request@lists.osdl.org?subject=help>
List-Subscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=subscribe>
Sender: kernel-janitors-bounces@lists.osdl.org
Errors-To: kernel-janitors-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============15164152380464313==
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello,

Please consider applying.


One thing I would have preferred using here is use wait_event*(), but there is
no condition. However, try_to_freeze(PF_FREEZE) could be used as one, if the
return condition matters -- it can return 0 or 1, from what I understand. If the
intent is to loop until the task is "frozen," then I can revise the patch to use
wait_event_interruptible_timeout().

Description: Replace deprecated interruptible_sleep_on_timeout() function calls
with direct wait-queue usage. I did not find the direct wake_up_interruptible()
function call in this file for the wait-queue, but that may not be an issue.
Patch is compile-tested.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

--- 2.6.11-rc2-kj-v/drivers/net/8139too.c	2005-01-24 09:34:08.000000000 -0800
+++ 2.6.11-rc2-kj/drivers/net/8139too.c	2005-01-27 11:22:19.000000000 -0800
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

--===============15164152380464313==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Kernel-janitors mailing list
Kernel-janitors@lists.osdl.org
http://lists.osdl.org/mailman/listinfo/kernel-janitors

--===============15164152380464313==--
