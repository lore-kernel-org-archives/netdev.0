From: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] [net-2.6] IrDA: Correctly handling socket error
Date: Thu, 19 Apr 2007 00:45:26 +0300
Message-ID: <20070418214526.GA4496@sortiz.org>
Reply-To: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	Olaf Kirch <olaf.kirch-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
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

This patch fixes an oops first reported in mid 2006 - see
http://lkml.org/lkml/2006/8/29/358 The cause of this bug report is that
when an error is signalled on the socket, irda_recvmsg_stream returns
without removing a local wait_queue variable from the socket's sk_sleep
queue. This causes havoc further down the road.

In response to this problem, a patch was made that invoked sock_orphan on
the socket when receiving a disconnect indication. This is not a good fix,
as this sets sk_sleep to NULL, causing applications sleeping in recvmsg
(and other places) to oops.

This is against the latest net-2.6 and should be considered for -stable
inclusion. 

Signed-off-by: Olaf Kirch <olaf.kirch-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
---
 net/irda/af_irda.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index f9b15d4..bf994c8 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -138,7 +138,6 @@ static void irda_disconnect_indication(void *instance, void *sap,
 		sk->sk_shutdown |= SEND_SHUTDOWN;
 
 		sk->sk_state_change(sk);
-		sock_orphan(sk);
 		release_sock(sk);
 
 		/* Close our TSAP.
@@ -1445,7 +1444,7 @@ static int irda_recvmsg_stream(struct kiocb *iocb, struct socket *sock,
 			 */
 			ret = sock_error(sk);
 			if (ret)
-				break;
+				;
 			else if (sk->sk_shutdown & RCV_SHUTDOWN)
 				;
 			else if (noblock)
-- 
1.5.1



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
