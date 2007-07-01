From: samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org
Subject: [PATCH 4/4] [IrDA] tsap init routine factorisation
Date: Mon, 02 Jul 2007 01:14:31 +0300
Message-ID: <20070701221706.468909173@sortiz.org>
References: <20070701221427.101308704@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "G. Liakhovetski" <gl-o/hVf8ie6tKzQB+pC5nmwQ@public.gmane.org>,
	irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline; filename=patch_tsap_init
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch extracts common code from irttp_open_tsap() and irttp_dup() 
into a new function to 1) avoid code duplication, 2) help avoid forgetting 
object initialization in the tsap duplication path in the future.

Signed-off-by: G. Liakhovetski <gl-o/hVf8ie6tKzQB+pC5nmwQ@public.gmane.org>
Signed-off-by: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>

--- a/net/irda/irttp.c	2 Apr 2007 10:36:28 -0000	1.1.1.11.4.2
+++ b/net/irda/irttp.c	30 May 2007 13:14:19 -0000
@@ -369,6 +369,20 @@ static int irttp_param_max_sdu_size(void
 /* Everything is happily mixed up. Waiting for next clean up - Jean II */
 
 /*
+ * Initialization, that has to be done on new tsap
+ * instance allocation and on duplication
+ */
+static void irttp_init_tsap(struct tsap_cb *tsap)
+{
+	spin_lock_init(&tsap->lock);
+	init_timer(&tsap->todo_timer);
+
+	skb_queue_head_init(&tsap->rx_queue);
+	skb_queue_head_init(&tsap->tx_queue);
+	skb_queue_head_init(&tsap->rx_fragments);
+}
+
+/*
  * Function irttp_open_tsap (stsap, notify)
  *
  *    Create TSAP connection endpoint,
@@ -395,10 +409,11 @@ struct tsap_cb *irttp_open_tsap(__u8 sts
 		IRDA_DEBUG(0, "%s(), unable to kmalloc!\n", __FUNCTION__);
 		return NULL;
 	}
-	spin_lock_init(&self->lock);
+
+	/* Initialize internal objects */
+	irttp_init_tsap(self);
 
 	/* Initialise todo timer */
-	init_timer(&self->todo_timer);
 	self->todo_timer.data     = (unsigned long) self;
 	self->todo_timer.function = &irttp_todo_expired;
 
@@ -418,9 +433,6 @@ struct tsap_cb *irttp_open_tsap(__u8 sts
 	self->magic = TTP_TSAP_MAGIC;
 	self->connected = FALSE;
 
-	skb_queue_head_init(&self->rx_queue);
-	skb_queue_head_init(&self->tx_queue);
-	skb_queue_head_init(&self->rx_fragments);
 	/*
 	 *  Create LSAP at IrLMP layer
 	 */
@@ -1455,12 +1467,9 @@ struct tsap_cb *irttp_dup(struct tsap_cb
 
 	/* Not everything should be copied */
 	new->notify.instance = instance;
-	spin_lock_init(&new->lock);
-	init_timer(&new->todo_timer);
 
-	skb_queue_head_init(&new->rx_queue);
-	skb_queue_head_init(&new->tx_queue);
-	skb_queue_head_init(&new->rx_fragments);
+	/* Initialize internal objects */
+	irttp_init_tsap(new);
 
 	/* This is locked */
 	hashbin_insert(irttp->tsaps, (irda_queue_t *) new, (long) new, NULL);

-- 

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
