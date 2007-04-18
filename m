From: samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org
Subject: [PATCH 3/7] [IrDA] af_irda: irda_accept cleanup
Date: Thu, 19 Apr 2007 00:32:05 +0300
Message-ID: <20070418214750.826786570@sortiz.org>
References: <20070418213202.214829666@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Olaf Kirch <olaf.kirch-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline;
	filename=0004-IrDA-net-2.6.22-af_irda-irda_accept-cleanup.patch
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch removes a cut'n'paste copy of wait_event_interruptible
from irda_accept.

Signed-off-by: Samuel Ortiz <samuel-1iRGAI7R+ZvYtjvyW6yDsg@public.gmane.org>
Acked-by: Olaf Kirch <olaf.kirch-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
 net/irda/af_irda.c |   34 ++++++++--------------------------
 1 files changed, 8 insertions(+), 26 deletions(-)

Index: net-2.6.22-quilt/net/irda/af_irda.c
===================================================================
--- net-2.6.22-quilt.orig/net/irda/af_irda.c	2007-04-18 02:16:43.000000000 +0300
+++ net-2.6.22-quilt/net/irda/af_irda.c	2007-04-18 02:16:43.000000000 +0300
@@ -873,37 +873,19 @@
 	 * calling us, the data is waiting for us ;-)
 	 * Jean II
 	 */
-	skb = skb_dequeue(&sk->sk_receive_queue);
-	if (skb == NULL) {
-		int ret = 0;
-		DECLARE_WAITQUEUE(waitq, current);
+	while (1) {
+		skb = skb_dequeue(&sk->sk_receive_queue);
+		if (skb)
+			break;
 
 		/* Non blocking operation */
 		if (flags & O_NONBLOCK)
 			return -EWOULDBLOCK;
 
-		/* The following code is a cut'n'paste of the
-		 * wait_event_interruptible() macro.
-		 * We don't us the macro because the condition has
-		 * side effects : we want to make sure that only one
-		 * skb get dequeued - Jean II */
-		add_wait_queue(sk->sk_sleep, &waitq);
-		for (;;) {
-			set_current_state(TASK_INTERRUPTIBLE);
-			skb = skb_dequeue(&sk->sk_receive_queue);
-			if (skb != NULL)
-				break;
-			if (!signal_pending(current)) {
-				schedule();
-				continue;
-			}
-			ret = -ERESTARTSYS;
-			break;
-		}
-		current->state = TASK_RUNNING;
-		remove_wait_queue(sk->sk_sleep, &waitq);
-		if(ret)
-			return -ERESTARTSYS;
+		err = wait_event_interruptible(*(sk->sk_sleep),
+					skb_peek(&sk->sk_receive_queue));
+		if (err)
+			return err;
 	}
 
 	newsk = newsock->sk;

--


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
