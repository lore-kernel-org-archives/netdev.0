From: samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org
Subject: [PATCH 1/7] [IrDA] af_irda: irda_recvmsg_stream cleanup
Date: Thu, 19 Apr 2007 00:32:03 +0300
Message-ID: <20070418214750.230933366@sortiz.org>
References: <20070418213202.214829666@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Olaf Kirch <olaf.kirch-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline;
	filename=0002-IrDA-net-2.6.22-af_irda-irda_recvmsg_stream-cle.patch
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

From: Olaf Kirch <olaf.kirch-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>

This patch cleans up some code in irda_recvmsg_stream, replacing some
homebrew code with prepare_to_wait/finish_wait, and by making the
code honor sock_rcvtimeo.

Signed-off-by: Olaf Kirch <olaf.kirch-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
---
 net/irda/af_irda.c |   31 +++++++++++++------------------
 1 files changed, 13 insertions(+), 18 deletions(-)

Index: net-2.6.22-quilt/net/irda/af_irda.c
===================================================================
--- net-2.6.22-quilt.orig/net/irda/af_irda.c	2007-04-18 01:40:14.000000000 +0300
+++ net-2.6.22-quilt/net/irda/af_irda.c	2007-04-18 01:40:28.000000000 +0300
@@ -1403,8 +1403,8 @@
 	struct irda_sock *self = irda_sk(sk);
 	int noblock = flags & MSG_DONTWAIT;
 	size_t copied = 0;
-	int target = 1;
-	DECLARE_WAITQUEUE(waitq, current);
+	int target;
+	long timeo;
 
 	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
 
@@ -1417,8 +1417,8 @@
 	if (flags & MSG_OOB)
 		return -EOPNOTSUPP;
 
-	if (flags & MSG_WAITALL)
-		target = size;
+	target = sock_rcvlowat(sk, flags & MSG_WAITALL, size);
+	timeo = sock_rcvtimeo(sk, noblock);
 
 	msg->msg_namelen = 0;
 
@@ -1426,19 +1426,14 @@
 		int chunk;
 		struct sk_buff *skb = skb_dequeue(&sk->sk_receive_queue);
 
-		if (skb==NULL) {
+		if (skb == NULL) {
+			DEFINE_WAIT(wait);
 			int ret = 0;
 
 			if (copied >= target)
 				break;
 
-			/* The following code is a cut'n'paste of the
-			 * wait_event_interruptible() macro.
-			 * We don't us the macro because the test condition
-			 * is messy. - Jean II */
-			set_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
-			add_wait_queue(sk->sk_sleep, &waitq);
-			set_current_state(TASK_INTERRUPTIBLE);
+			prepare_to_wait_exclusive(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 
 			/*
 			 *	POSIX 1003.1g mandates this order.
@@ -1451,17 +1446,17 @@
 			else if (noblock)
 				ret = -EAGAIN;
 			else if (signal_pending(current))
-				ret = -ERESTARTSYS;
+				ret = sock_intr_errno(timeo);
+			else if (sk->sk_state != TCP_ESTABLISHED)
+				ret = -ENOTCONN;
 			else if (skb_peek(&sk->sk_receive_queue) == NULL)
 				/* Wait process until data arrives */
 				schedule();
 
-			current->state = TASK_RUNNING;
-			remove_wait_queue(sk->sk_sleep, &waitq);
-			clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+			finish_wait(sk->sk_sleep, &wait);
 
-			if(ret)
-				return(ret);
+			if (ret)
+				return ret;
 			if (sk->sk_shutdown & RCV_SHUTDOWN)
 				break;
 

--


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
