From: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 2/6] IrDA: Process context
	ppp_unregister_channel() call
Date: Wed, 14 Mar 2007 21:23:01 +0200
Message-ID: <20070314192301.GC3397@sortiz.org>
Reply-To: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>,
	irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Guennadi Liakhovetski <gl-o/hVf8ie6tKzQB+pC5nmwQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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

We need to call ppp_unregister_channel() when IrNET disconnects, and this
must be done from a process context.
This patch applies on top of "[PATCH 1/7] IrDA: IrNET code indentation".
Also, this is a bug fix, certainly not a critical one. Should I forward it to
stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org though ?

Patch tested by Guennadi Liakhovetski.

Reported-by: Guennadi Liakhovetski <gl-o/hVf8ie6tKzQB+pC5nmwQ@public.gmane.org>
Signed-off-by: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
---
 net/irda/irnet/irnet.h      |    1 +
 net/irda/irnet/irnet_irda.c |   37 +++++++++++++++++++++++++------------
 2 files changed, 26 insertions(+), 12 deletions(-)

diff --git a/net/irda/irnet/irnet.h b/net/irda/irnet/irnet.h
index 44b58a6..ec1a2a8 100644
--- a/net/irda/irnet/irnet.h
+++ b/net/irda/irnet/irnet.h
@@ -418,6 +418,7 @@ typedef struct irnet_socket {
 	u32 raccm;		/* to please pppd - dummy) */
 	unsigned int flags;	/* PPP flags (compression, ...) */
 	unsigned int rbits;	/* Unused receive flags ??? */
+	struct work_struct disconnect_work; /* Process context disconnection */
 
 	/* ------------------------ IrTTP part ------------------------ */
 	/* We create a pseudo "socket" over the IrDA tranport */
diff --git a/net/irda/irnet/irnet_irda.c b/net/irda/irnet/irnet_irda.c
index 843b767..0f462a9 100644
--- a/net/irda/irnet/irnet_irda.c
+++ b/net/irda/irnet/irnet_irda.c
@@ -10,6 +10,27 @@
 
 #include "irnet_irda.h"		/* Private header */
 
+/*
+ * PPP disconnect work: we need to make sure we're in
+ * process context when calling ppp_unregister_channel().
+ */
+static void irnet_ppp_disconnect(struct work_struct *work)
+{
+	irnet_socket * self =
+		container_of(work, irnet_socket, disconnect_work);
+
+	if (self == NULL)
+		return;
+	/*
+	 * If we were connected, cleanup & close the PPP
+	 * channel, which will kill pppd (hangup) and the rest.
+	 */
+	if (self->ppp_open && !self->ttp_open && !self->ttp_connect) {
+		ppp_unregister_channel(&self->chan);
+		self->ppp_open = 0;
+	}
+}
+
 /************************* CONTROL CHANNEL *************************/
 /*
  * When ppp is not active, /dev/irnet act as a control channel.
@@ -487,6 +508,8 @@ int irda_irnet_create(irnet_socket * self)
 #endif				/* DISCOVERY_NOMASK */
 	self->tx_flow = FLOW_START;	/* Flow control from IrTTP */
 
+	INIT_WORK(&self->disconnect_work, irnet_ppp_disconnect);
+
 	DEXIT(IRDA_SOCK_TRACE, "\n");
 	return (0);
 }
@@ -1123,18 +1146,8 @@ irnet_disconnect_indication(void *instance,
 	/* Deal with the ppp instance if it's still alive */
 	if (self->ppp_open) {
 		if (test_open) {
-#ifdef MISSING_PPP_API
-			/*
-			 * ppp_unregister_channel() wants a user context,
-			 * which we are guaranteed to NOT have here.
-			 * What are we supposed to do here ? Jean II */
-			/*
-			 * If we were connected, cleanup & close the PPP
-			 * channel, which will kill pppd (hangup) and the rest.
-			 */
-			ppp_unregister_channel(&self->chan);
-			self->ppp_open = 0;
-#endif
+			/* ppp_unregister_channel() wants a user context. */
+			schedule_work(&self->disconnect_work);
 		} else {
 			/*
 			 * If we were trying to connect, flush (drain)
-- 
1.4.4.4


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
