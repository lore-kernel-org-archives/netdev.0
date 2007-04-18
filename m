From: samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org
Subject: [PATCH 2/7] [IrDA] af_irda: Silence kernel message in
	irda_recvmsg_stream
Date: Thu, 19 Apr 2007 00:32:04 +0300
Message-ID: <20070418214750.515230054@sortiz.org>
References: <20070418213202.214829666@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Olaf Kirch <olaf.kirch-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline;
	filename=0003-IrDA-net-2.6.22-af_irda-Silence-kernel-message.patch
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

This patch silences an IRDA_ASSERT in irda_recvmsg_stream, as described in
http://bugzilla.kernel.org/show_bug.cgi?id=7512 irda_disconnect_indication
would set sk->sk_err to ECONNRESET, and a subsequent call to recvmsg
would print an irritating kernel message and return -1.

When a connected socket is closed by the peer, recvmsg should return 0
rather than an error. This patch fixes this.

Signed-off-by: Olaf Kirch <olaf.kirch-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
---
 net/irda/af_irda.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

Index: net-2.6.22-quilt/net/irda/af_irda.c
===================================================================
--- net-2.6.22-quilt.orig/net/irda/af_irda.c	2007-04-18 02:10:56.000000000 +0300
+++ net-2.6.22-quilt/net/irda/af_irda.c	2007-04-18 02:14:24.000000000 +0300
@@ -131,15 +131,13 @@
 	}
 
 	/* Prevent race conditions with irda_release() and irda_shutdown() */
+	bh_lock_sock(sk);
 	if (!sock_flag(sk, SOCK_DEAD) && sk->sk_state != TCP_CLOSE) {
-		lock_sock(sk);
 		sk->sk_state     = TCP_CLOSE;
-		sk->sk_err       = ECONNRESET;
 		sk->sk_shutdown |= SEND_SHUTDOWN;
 
 		sk->sk_state_change(sk);
 		sock_orphan(sk);
-		release_sock(sk);
 
 		/* Close our TSAP.
 		 * If we leave it open, IrLMP put it back into the list of
@@ -159,6 +157,7 @@
 			self->tsap = NULL;
 		}
 	}
+	bh_unlock_sock(sk);
 
 	/* Note : once we are there, there is not much you want to do
 	 * with the socket anymore, apart from closing it.
@@ -1062,7 +1061,8 @@
 
 	if (sk->sk_state != TCP_ESTABLISHED) {
 		sock->state = SS_UNCONNECTED;
-		return sock_error(sk);	/* Always set at this point */
+		err = sock_error(sk);
+		return err? err : -ECONNRESET;
 	}
 
 	sock->state = SS_CONNECTED;
@@ -1356,7 +1356,9 @@
 	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
 
 	IRDA_ASSERT(self != NULL, return -1;);
-	IRDA_ASSERT(!sock_error(sk), return -1;);
+
+	if ((err = sock_error(sk)) < 0)
+		return err;
 
 	skb = skb_recv_datagram(sk, flags & ~MSG_DONTWAIT,
 				flags & MSG_DONTWAIT, &err);
@@ -1403,13 +1405,15 @@
 	struct irda_sock *self = irda_sk(sk);
 	int noblock = flags & MSG_DONTWAIT;
 	size_t copied = 0;
-	int target;
+	int target, err;
 	long timeo;
 
 	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
 
 	IRDA_ASSERT(self != NULL, return -1;);
-	IRDA_ASSERT(!sock_error(sk), return -1;);
+
+	if ((err = sock_error(sk)) < 0)
+		return err;
 
 	if (sock->flags & __SO_ACCEPTCON)
 		return(-EINVAL);

--


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
