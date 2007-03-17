From: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 3/3] [net-2.6] IrDA: Calling
	ppp_unregister_channel() from process context
Date: Sat, 17 Mar 2007 04:05:33 +0200
Message-ID: <20070317020533.GG3429@sortiz.org>
Reply-To: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Guennadi Liakhovetski <gl-o/hVf8ie6tKzQB+pC5nmwQ@public.gmane.org>,
	irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
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

Bug reported and patch tested by Guennadi Liakhovetski.

Signed-off-by: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
---
 net/irda/irnet/irnet.h      |    2 +-
 net/irda/irnet/irnet_irda.c |   34 +++++++++++++++++++++++++---------
 2 files changed, 26 insertions(+), 10 deletions(-)

diff --git a/net/irda/irnet/irnet.h b/net/irda/irnet/irnet.h
index 873ae18..bc2e15c 100644
--- a/net/irda/irnet/irnet.h
+++ b/net/irda/irnet/irnet.h
@@ -419,7 +419,7 @@ typedef struct irnet_socket
   u32			raccm;		/* to please pppd - dummy) */
   unsigned int		flags;		/* PPP flags (compression, ...) */
   unsigned int		rbits;		/* Unused receive flags ??? */
-
+  struct work_struct disconnect_work;   /* Process context disconnection */
   /* ------------------------ IrTTP part ------------------------ */
   /* We create a pseudo "socket" over the IrDA tranport */
   unsigned long		ttp_open;	/* Set when IrTTP is ready */
diff --git a/net/irda/irnet/irnet_irda.c b/net/irda/irnet/irnet_irda.c
index c378e66..a4f1439 100644
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
@@ -499,6 +520,8 @@ irda_irnet_create(irnet_socket *	self)
 #endif /* DISCOVERY_NOMASK */
   self->tx_flow = FLOW_START;	/* Flow control from IrTTP */
 
+  INIT_WORK(&self->disconnect_work, irnet_ppp_disconnect);
+
   DEXIT(IRDA_SOCK_TRACE, "\n");
   return(0);
 }
@@ -1134,15 +1157,8 @@ irnet_disconnect_indication(void *	instance,
     {
       if(test_open)
 	{
-#ifdef MISSING_PPP_API
-	  /* ppp_unregister_channel() wants a user context, which we
-	   * are guaranteed to NOT have here. What are we supposed
-	   * to do here ? Jean II */
-	  /* If we were connected, cleanup & close the PPP channel,
-	   * which will kill pppd (hangup) and the rest */
-	  ppp_unregister_channel(&self->chan);
-	  self->ppp_open = 0;
-#endif
+	  /* ppp_unregister_channel() wants a user context. */
+	  schedule_work(&self->disconnect_work);
 	}
       else
 	{
-- 
1.5.0.2


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
