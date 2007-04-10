From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: [irda-users] [BUG] 2.6.20.1-rt8 irnet + pppd recursive spinlock...
Date: Tue, 10 Apr 2007 21:10:37 +0300
Message-ID: <20070410181037.GA3780@sortiz.org>
References: <Pine.LNX.4.63.0704050846480.534@pcgl.dsa-ac.de> <Pine.LNX.4.63.0704051250170.534@pcgl.dsa-ac.de> <20070407005926.GE4177@sortiz.org>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Mackerras <paulus@samba.org>,
	irda-users@lists.sourceforge.net, linux-rt-users@vger.kernel.org,
	netdev@vger.kernel.org
To: Guennadi Liakhovetski <gl@dsa-ac.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp23.orange.fr ([193.252.22.30]:15531 "EHLO smtp23.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031359AbXDJSKk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2007 14:10:40 -0400
Content-Disposition: inline
In-Reply-To: <20070407005926.GE4177@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Guennadi,

On Sat, Apr 07, 2007 at 03:59:26AM +0300, Samuel Ortiz wrote:
> IMHO, irnet_flow_indication() should be called asynchronously by
> irttp_run_tx_queue(), through some bottom-half mechanism. That would fix your
> locking issues, and that would reduce the time we spend in the IrDA code with
> this lock taken.
> 
> I will try to come up with some patches for you later this weekend.
The patch below schedules irnet_flow_indication() asynchronously. Could
you please give it a try (it builds, but I couldn't test it...) ? :

diff --git a/include/net/irda/irttp.h b/include/net/irda/irttp.h
index a899e58..941f0f1 100644
--- a/include/net/irda/irttp.h
+++ b/include/net/irda/irttp.h
@@ -128,6 +128,7 @@ struct tsap_cb {
 
 	struct net_device_stats stats;
 	struct timer_list todo_timer; 
+	struct work_struct irnet_flow_work;   /* irttp asynchronous flow restart */
 
 	__u32 max_seg_size;     /* Max data that fit into an IrLAP frame */
 	__u8  max_header_size;
diff --git a/net/irda/irnet/irnet.h b/net/irda/irnet/irnet.h
diff --git a/net/irda/irttp.c b/net/irda/irttp.c
index 7069e4a..a0d0f26 100644
--- a/net/irda/irttp.c
+++ b/net/irda/irttp.c
@@ -367,6 +367,29 @@ static int irttp_param_max_sdu_size(void *instance, irda_param_t *param,
 /*************************** CLIENT CALLS ***************************/
 /************************** LMP CALLBACKS **************************/
 /* Everything is happily mixed up. Waiting for next clean up - Jean II */
+static void irttp_flow_restart(struct work_struct *work)
+{
+	struct tsap_cb * self =
+		container_of(work, struct tsap_cb, irnet_flow_work);
+
+	if (self == NULL)
+		return;
+
+	/* Check if we can accept more frames from client. */
+	if ((self->tx_sdu_busy) &&
+	    (skb_queue_len(&self->tx_queue) < TTP_TX_LOW_THRESHOLD) &&
+	    (!self->close_pend)) {
+		if (self->notify.flow_indication)
+			self->notify.flow_indication(self->notify.instance,
+						     self, FLOW_START);
+
+		/* self->tx_sdu_busy is the state of the client.
+		 * We don't really have a race here, but it's always safer
+		 * to update our state after the client - Jean II */
+		self->tx_sdu_busy = FALSE;
+	}
+}
+
 
 /*
  * Function irttp_open_tsap (stsap, notify)
@@ -402,6 +425,8 @@ struct tsap_cb *irttp_open_tsap(__u8 stsap_sel, int credit, notify_t *notify)
 	self->todo_timer.data     = (unsigned long) self;
 	self->todo_timer.function = &irttp_todo_expired;
 
+	INIT_WORK(&self->irnet_flow_work, irttp_flow_restart);
+
 	/* Initialize callbacks for IrLMP to use */
 	irda_notify_init(&ttp_notify);
 	ttp_notify.connect_confirm = irttp_connect_confirm;
@@ -761,25 +786,10 @@ static void irttp_run_tx_queue(struct tsap_cb *self)
 		self->stats.tx_packets++;
 	}
 
-	/* Check if we can accept more frames from client.
-	 * We don't want to wait until the todo timer to do that, and we
-	 * can't use tasklets (grr...), so we are obliged to give control
-	 * to client. That's ok, this test will be true not too often
-	 * (max once per LAP window) and we are called from places
-	 * where we can spend a bit of time doing stuff. - Jean II */
 	if ((self->tx_sdu_busy) &&
 	    (skb_queue_len(&self->tx_queue) < TTP_TX_LOW_THRESHOLD) &&
 	    (!self->close_pend))
-	{
-		if (self->notify.flow_indication)
-			self->notify.flow_indication(self->notify.instance,
-						     self, FLOW_START);
-
-		/* self->tx_sdu_busy is the state of the client.
-		 * We don't really have a race here, but it's always safer
-		 * to update our state after the client - Jean II */
-		self->tx_sdu_busy = FALSE;
-	}
+		schedule_work(&self->irnet_flow_work);
 
 	/* Reset lock */
 	self->tx_queue_lock = 0;

