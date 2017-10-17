From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 09/58] net/irda: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:28:53 -0700
Message-ID: <1508200182-104605-10-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        Samuel Ortiz <samuel@sortiz.org>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Johannes Berg <johannes.berg@intel.com>,
        Ingo Molnar <mingo@kernel.org>, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:48733 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933203AbdJQAaF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 20:30:05 -0400
Received: by mail-pg0-f54.google.com with SMTP id v78so47489pgb.5
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 17:30:04 -0700 (PDT)
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Samuel Ortiz <samuel@sortiz.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Johannes Berg <johannes.berg@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 .../staging/irda/include/net/irda/irlmp_event.h    |  6 +--
 drivers/staging/irda/include/net/irda/timer.h      | 11 ++---
 drivers/staging/irda/net/af_irda.c                 |  7 ++-
 drivers/staging/irda/net/ircomm/ircomm_tty.c       |  2 +-
 .../staging/irda/net/ircomm/ircomm_tty_attach.c    |  8 ++--
 drivers/staging/irda/net/irda_device.c             | 10 ++--
 drivers/staging/irda/net/iriap.c                   | 10 ++--
 drivers/staging/irda/net/irlan/irlan_client.c      |  6 +--
 drivers/staging/irda/net/irlan/irlan_common.c      |  4 +-
 drivers/staging/irda/net/irlap.c                   | 16 +++----
 drivers/staging/irda/net/irlap_event.c             |  6 +--
 drivers/staging/irda/net/irlmp.c                   |  8 ++--
 drivers/staging/irda/net/irlmp_event.c             | 10 ++--
 drivers/staging/irda/net/irttp.c                   | 11 ++---
 drivers/staging/irda/net/timer.c                   | 54 +++++++++++-----------
 15 files changed, 79 insertions(+), 90 deletions(-)

diff --git a/drivers/staging/irda/include/net/irda/irlmp_event.h b/drivers/staging/irda/include/net/irda/irlmp_event.h
index 9e4ec17a7449..a1a082fe384e 100644
--- a/drivers/staging/irda/include/net/irda/irlmp_event.h
+++ b/drivers/staging/irda/include/net/irda/irlmp_event.h
@@ -82,9 +82,9 @@ typedef enum {
 extern const char *const irlmp_state[];
 extern const char *const irlsap_state[];
 
-void irlmp_watchdog_timer_expired(void *data);
-void irlmp_discovery_timer_expired(void *data);
-void irlmp_idle_timer_expired(void *data);
+void irlmp_watchdog_timer_expired(struct timer_list *t);
+void irlmp_discovery_timer_expired(struct timer_list *t);
+void irlmp_idle_timer_expired(struct timer_list *t);
 
 void irlmp_do_lap_event(struct lap_cb *self, IRLMP_EVENT event, 
 			struct sk_buff *skb);
diff --git a/drivers/staging/irda/include/net/irda/timer.h b/drivers/staging/irda/include/net/irda/timer.h
index d784f242cf7b..a6635f0afae9 100644
--- a/drivers/staging/irda/include/net/irda/timer.h
+++ b/drivers/staging/irda/include/net/irda/timer.h
@@ -72,14 +72,11 @@ struct lap_cb;
 
 #define WATCHDOG_TIMEOUT        (20*HZ)       /* 20 sec */
 
-typedef void (*TIMER_CALLBACK)(void *);
-
-static inline void irda_start_timer(struct timer_list *ptimer, int timeout, 
-				    void* data, TIMER_CALLBACK callback)
+static inline void irda_start_timer(struct timer_list *ptimer, int timeout,
+				    void (*callback)(struct timer_list *))
 {
-	ptimer->function = (void (*)(unsigned long)) callback;
-	ptimer->data = (unsigned long) data;
-	
+	ptimer->function = (TIMER_FUNC_TYPE) callback;
+
 	/* Set new value for timer (update or add timer).
 	 * We use mod_timer() because it's more efficient and also
 	 * safer with respect to race conditions - Jean II */
diff --git a/drivers/staging/irda/net/af_irda.c b/drivers/staging/irda/net/af_irda.c
index 23fa7c8b09a5..b82a47b9ef0b 100644
--- a/drivers/staging/irda/net/af_irda.c
+++ b/drivers/staging/irda/net/af_irda.c
@@ -429,11 +429,11 @@ static void irda_selective_discovery_indication(discinfo_t *discovery,
  * We were waiting for a node to be discovered, but nothing has come up
  * so far. Wake up the user and tell him that we failed...
  */
-static void irda_discovery_timeout(u_long priv)
+static void irda_discovery_timeout(struct timer_list *t)
 {
 	struct irda_sock *self;
 
-	self = (struct irda_sock *) priv;
+	self = from_timer(self, t, watchdog);
 	BUG_ON(self == NULL);
 
 	/* Nothing for the caller */
@@ -2505,8 +2505,7 @@ static int irda_getsockopt(struct socket *sock, int level, int optname,
 
 			/* Set watchdog timer to expire in <val> ms. */
 			self->errno = 0;
-			setup_timer(&self->watchdog, irda_discovery_timeout,
-					(unsigned long)self);
+			timer_setup(&self->watchdog, irda_discovery_timeout, 0);
 			mod_timer(&self->watchdog,
 				  jiffies + msecs_to_jiffies(val));
 
diff --git a/drivers/staging/irda/net/ircomm/ircomm_tty.c b/drivers/staging/irda/net/ircomm/ircomm_tty.c
index ec157c3419b5..473abfaffe7b 100644
--- a/drivers/staging/irda/net/ircomm/ircomm_tty.c
+++ b/drivers/staging/irda/net/ircomm/ircomm_tty.c
@@ -395,7 +395,7 @@ static int ircomm_tty_install(struct tty_driver *driver, struct tty_struct *tty)
 		self->max_data_size = IRCOMM_TTY_DATA_UNINITIALISED;
 
 		/* Init some important stuff */
-		init_timer(&self->watchdog_timer);
+		timer_setup(&self->watchdog_timer, NULL, 0);
 		spin_lock_init(&self->spinlock);
 
 		/*
diff --git a/drivers/staging/irda/net/ircomm/ircomm_tty_attach.c b/drivers/staging/irda/net/ircomm/ircomm_tty_attach.c
index 0a411019c098..e2d5ce8ba0db 100644
--- a/drivers/staging/irda/net/ircomm/ircomm_tty_attach.c
+++ b/drivers/staging/irda/net/ircomm/ircomm_tty_attach.c
@@ -52,7 +52,7 @@ static void ircomm_tty_getvalue_confirm(int result, __u16 obj_id,
 					struct ias_value *value, void *priv);
 static void ircomm_tty_start_watchdog_timer(struct ircomm_tty_cb *self,
 					    int timeout);
-static void ircomm_tty_watchdog_timer_expired(void *data);
+static void ircomm_tty_watchdog_timer_expired(struct timer_list *timer);
 
 static int ircomm_tty_state_idle(struct ircomm_tty_cb *self,
 				 IRCOMM_TTY_EVENT event,
@@ -587,7 +587,7 @@ static void ircomm_tty_start_watchdog_timer(struct ircomm_tty_cb *self,
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
 
-	irda_start_timer(&self->watchdog_timer, timeout, (void *) self,
+	irda_start_timer(&self->watchdog_timer, timeout,
 			 ircomm_tty_watchdog_timer_expired);
 }
 
@@ -597,9 +597,9 @@ static void ircomm_tty_start_watchdog_timer(struct ircomm_tty_cb *self,
  *    Called when the connect procedure have taken to much time.
  *
  */
-static void ircomm_tty_watchdog_timer_expired(void *data)
+static void ircomm_tty_watchdog_timer_expired(struct timer_list *t)
 {
-	struct ircomm_tty_cb *self = (struct ircomm_tty_cb *) data;
+	struct ircomm_tty_cb *self = from_timer(self, t, watchdog_timer);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRCOMM_TTY_MAGIC, return;);
diff --git a/drivers/staging/irda/net/irda_device.c b/drivers/staging/irda/net/irda_device.c
index d33de8a8762a..682b4eea15e0 100644
--- a/drivers/staging/irda/net/irda_device.c
+++ b/drivers/staging/irda/net/irda_device.c
@@ -57,7 +57,7 @@ static void __irda_task_delete(struct irda_task *task);
 static hashbin_t *dongles;
 static hashbin_t *tasks;
 
-static void irda_task_timer_expired(void *data);
+static void irda_task_timer_expired(struct timer_list *timer);
 
 int __init irda_device_init(void)
 {
@@ -233,7 +233,7 @@ static int irda_task_kick(struct irda_task *task)
 		}
 		irda_task_delete(task);
 	} else if (timeout > 0) {
-		irda_start_timer(&task->timer, timeout, (void *)task,
+		irda_start_timer(&task->timer, timeout,
 				 irda_task_timer_expired);
 		finished = FALSE;
 	} else {
@@ -251,11 +251,9 @@ static int irda_task_kick(struct irda_task *task)
  *    Task time has expired. We now try to execute task (again), and restart
  *    the timer if the task has not finished yet
  */
-static void irda_task_timer_expired(void *data)
+static void irda_task_timer_expired(struct timer_list *t)
 {
-	struct irda_task *task;
-
-	task = data;
+	struct irda_task *task = from_timer(task, t, timer);
 
 	irda_task_kick(task);
 }
diff --git a/drivers/staging/irda/net/iriap.c b/drivers/staging/irda/net/iriap.c
index 1138eaf5c682..d64192e9db8b 100644
--- a/drivers/staging/irda/net/iriap.c
+++ b/drivers/staging/irda/net/iriap.c
@@ -76,12 +76,12 @@ static void iriap_connect_confirm(void *instance, void *sap,
 static int iriap_data_indication(void *instance, void *sap,
 				 struct sk_buff *skb);
 
-static void iriap_watchdog_timer_expired(void *data);
+static void iriap_watchdog_timer_expired(struct timer_list *t);
 
 static inline void iriap_start_watchdog_timer(struct iriap_cb *self,
 					      int timeout)
 {
-	irda_start_timer(&self->watchdog_timer, timeout, self,
+	irda_start_timer(&self->watchdog_timer, timeout,
 			 iriap_watchdog_timer_expired);
 }
 
@@ -199,7 +199,7 @@ struct iriap_cb *iriap_open(__u8 slsap_sel, int mode, void *priv,
 	 * we connect, so this must have a sane value... Jean II */
 	self->max_header_size = LMP_MAX_HEADER;
 
-	init_timer(&self->watchdog_timer);
+	timer_setup(&self->watchdog_timer, NULL, 0);
 
 	hashbin_insert(iriap, (irda_queue_t *) self, (long) self, NULL);
 
@@ -946,9 +946,9 @@ void iriap_call_indication(struct iriap_cb *self, struct sk_buff *skb)
  *    Query has taken too long time, so abort
  *
  */
-static void iriap_watchdog_timer_expired(void *data)
+static void iriap_watchdog_timer_expired(struct timer_list *t)
 {
-	struct iriap_cb *self = (struct iriap_cb *) data;
+	struct iriap_cb *self = from_timer(self, t, watchdog_timer);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IAS_MAGIC, return;);
diff --git a/drivers/staging/irda/net/irlan/irlan_client.c b/drivers/staging/irda/net/irlan/irlan_client.c
index c5837a40c78e..0b65e80849ae 100644
--- a/drivers/staging/irda/net/irlan/irlan_client.c
+++ b/drivers/staging/irda/net/irlan/irlan_client.c
@@ -68,9 +68,9 @@ static void irlan_check_response_param(struct irlan_cb *self, char *param,
 				       char *value, int val_len);
 static void irlan_client_open_ctrl_tsap(struct irlan_cb *self);
 
-static void irlan_client_kick_timer_expired(void *data)
+static void irlan_client_kick_timer_expired(struct timer_list *t)
 {
-	struct irlan_cb *self = (struct irlan_cb *) data;
+	struct irlan_cb *self = from_timer(self, t, client.kick_timer);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == IRLAN_MAGIC, return;);
@@ -89,7 +89,7 @@ static void irlan_client_kick_timer_expired(void *data)
 
 static void irlan_client_start_kick_timer(struct irlan_cb *self, int timeout)
 {
-	irda_start_timer(&self->client.kick_timer, timeout, (void *) self,
+	irda_start_timer(&self->client.kick_timer, timeout,
 			 irlan_client_kick_timer_expired);
 }
 
diff --git a/drivers/staging/irda/net/irlan/irlan_common.c b/drivers/staging/irda/net/irlan/irlan_common.c
index 481bbc2a4349..fdcd7147007d 100644
--- a/drivers/staging/irda/net/irlan/irlan_common.c
+++ b/drivers/staging/irda/net/irlan/irlan_common.c
@@ -228,8 +228,8 @@ static struct irlan_cb __init *irlan_open(__u32 saddr, __u32 daddr)
 
 	self->media = MEDIA_802_3;
 	self->disconnect_reason = LM_USER_REQUEST;
-	init_timer(&self->watchdog_timer);
-	init_timer(&self->client.kick_timer);
+	timer_setup(&self->watchdog_timer, NULL, 0);
+	timer_setup(&self->client.kick_timer, NULL, 0);
 	init_waitqueue_head(&self->open_wait);
 
 	skb_queue_head_init(&self->client.txq);
diff --git a/drivers/staging/irda/net/irlap.c b/drivers/staging/irda/net/irlap.c
index 1cde711bcab5..d7d894423b4f 100644
--- a/drivers/staging/irda/net/irlap.c
+++ b/drivers/staging/irda/net/irlap.c
@@ -148,14 +148,14 @@ struct irlap_cb *irlap_open(struct net_device *dev, struct qos_info *qos,
 	/* Copy to the driver */
 	memcpy(dev->dev_addr, &self->saddr, 4);
 
-	init_timer(&self->slot_timer);
-	init_timer(&self->query_timer);
-	init_timer(&self->discovery_timer);
-	init_timer(&self->final_timer);
-	init_timer(&self->poll_timer);
-	init_timer(&self->wd_timer);
-	init_timer(&self->backoff_timer);
-	init_timer(&self->media_busy_timer);
+	timer_setup(&self->slot_timer, NULL, 0);
+	timer_setup(&self->query_timer, NULL, 0);
+	timer_setup(&self->discovery_timer, NULL, 0);
+	timer_setup(&self->final_timer, NULL, 0);
+	timer_setup(&self->poll_timer, NULL, 0);
+	timer_setup(&self->wd_timer, NULL, 0);
+	timer_setup(&self->backoff_timer, NULL, 0);
+	timer_setup(&self->media_busy_timer, NULL, 0);
 
 	irlap_apply_default_connection_parameters(self);
 
diff --git a/drivers/staging/irda/net/irlap_event.c b/drivers/staging/irda/net/irlap_event.c
index 0e1b4d79f745..634188b07e0a 100644
--- a/drivers/staging/irda/net/irlap_event.c
+++ b/drivers/staging/irda/net/irlap_event.c
@@ -163,9 +163,9 @@ static int (*state[])(struct irlap_cb *self, IRLAP_EVENT event,
  *    Poll timer has expired. Normally we must now send a RR frame to the
  *    remote device
  */
-static void irlap_poll_timer_expired(void *data)
+static void irlap_poll_timer_expired(struct timer_list *t)
 {
-	struct irlap_cb *self = (struct irlap_cb *) data;
+	struct irlap_cb *self = from_timer(self, t, poll_timer);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
@@ -222,7 +222,7 @@ static void irlap_start_poll_timer(struct irlap_cb *self, int timeout)
 	if (timeout == 0)
 		irlap_do_event(self, POLL_TIMER_EXPIRED, NULL, NULL);
 	else
-		irda_start_timer(&self->poll_timer, timeout, self,
+		irda_start_timer(&self->poll_timer, timeout,
 				 irlap_poll_timer_expired);
 }
 
diff --git a/drivers/staging/irda/net/irlmp.c b/drivers/staging/irda/net/irlmp.c
index 43964594aa12..34355061ab0b 100644
--- a/drivers/staging/irda/net/irlmp.c
+++ b/drivers/staging/irda/net/irlmp.c
@@ -109,7 +109,7 @@ int __init irlmp_init(void)
 	irlmp->last_lsap_sel = 0x0f; /* Reserved 0x00-0x0f */
 	strcpy(sysctl_devname, "Linux");
 
-	init_timer(&irlmp->discovery_timer);
+	timer_setup(&irlmp->discovery_timer, NULL, 0);
 
 	/* Do discovery every 3 seconds, conditionally */
 	if (sysctl_discovery)
@@ -185,7 +185,7 @@ struct lsap_cb *irlmp_open_lsap(__u8 slsap_sel, notify_t *notify, __u8 pid)
 		self->dlsap_sel = LSAP_ANY;
 	/* self->connected = FALSE; -> already NULL via memset() */
 
-	init_timer(&self->watchdog_timer);
+	timer_setup(&self->watchdog_timer, NULL, 0);
 
 	self->notify = *notify;
 
@@ -311,7 +311,7 @@ void irlmp_register_link(struct irlap_cb *irlap, __u32 saddr, notify_t *notify)
 
 	lap->lap_state = LAP_STANDBY;
 
-	init_timer(&lap->idle_timer);
+	timer_setup(&lap->idle_timer, NULL, 0);
 
 	/*
 	 *  Insert into queue of LMP links
@@ -655,7 +655,7 @@ struct lsap_cb *irlmp_dup(struct lsap_cb *orig, void *instance)
 	/* Not everything is the same */
 	new->notify.instance = instance;
 
-	init_timer(&new->watchdog_timer);
+	timer_setup(&new->watchdog_timer, NULL, 0);
 
 	hashbin_insert(irlmp->unconnected_lsaps, (irda_queue_t *) new,
 		       (long) new, NULL);
diff --git a/drivers/staging/irda/net/irlmp_event.c b/drivers/staging/irda/net/irlmp_event.c
index e306cf2c1e04..ddad0994b6dc 100644
--- a/drivers/staging/irda/net/irlmp_event.c
+++ b/drivers/staging/irda/net/irlmp_event.c
@@ -165,7 +165,7 @@ void irlmp_do_lap_event(struct lap_cb *self, IRLMP_EVENT event,
 	(*lap_state[self->lap_state]) (self, event, skb);
 }
 
-void irlmp_discovery_timer_expired(void *data)
+void irlmp_discovery_timer_expired(struct timer_list *t)
 {
 	/* We always cleanup the log (active & passive discovery) */
 	irlmp_do_expiry();
@@ -176,9 +176,9 @@ void irlmp_discovery_timer_expired(void *data)
 	irlmp_start_discovery_timer(irlmp, sysctl_discovery_timeout * HZ);
 }
 
-void irlmp_watchdog_timer_expired(void *data)
+void irlmp_watchdog_timer_expired(struct timer_list *t)
 {
-	struct lsap_cb *self = (struct lsap_cb *) data;
+	struct lsap_cb *self = from_timer(self, t, watchdog_timer);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LMP_LSAP_MAGIC, return;);
@@ -186,9 +186,9 @@ void irlmp_watchdog_timer_expired(void *data)
 	irlmp_do_lsap_event(self, LM_WATCHDOG_TIMEOUT, NULL);
 }
 
-void irlmp_idle_timer_expired(void *data)
+void irlmp_idle_timer_expired(struct timer_list *t)
 {
-	struct lap_cb *self = (struct lap_cb *) data;
+	struct lap_cb *self = from_timer(self, t, idle_timer);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LMP_LAP_MAGIC, return;);
diff --git a/drivers/staging/irda/net/irttp.c b/drivers/staging/irda/net/irttp.c
index b6ab41d5b3a3..741a94f39b4e 100644
--- a/drivers/staging/irda/net/irttp.c
+++ b/drivers/staging/irda/net/irttp.c
@@ -62,7 +62,6 @@ static void irttp_run_rx_queue(struct tsap_cb *self);
 static void irttp_flush_queues(struct tsap_cb *self);
 static void irttp_fragment_skb(struct tsap_cb *self, struct sk_buff *skb);
 static struct sk_buff *irttp_reassemble_skb(struct tsap_cb *self);
-static void irttp_todo_expired(unsigned long data);
 static int irttp_param_max_sdu_size(void *instance, irda_param_t *param,
 				    int get);
 
@@ -160,9 +159,9 @@ static inline void irttp_start_todo_timer(struct tsap_cb *self, int timeout)
  * killed (need user context), and we can't guarantee that here...
  * Jean II
  */
-static void irttp_todo_expired(unsigned long data)
+static void irttp_todo_expired(struct timer_list *t)
 {
-	struct tsap_cb *self = (struct tsap_cb *) data;
+	struct tsap_cb *self = from_timer(self, t, todo_timer);
 
 	/* Check that we still exist */
 	if (!self || self->magic != TTP_TSAP_MAGIC)
@@ -374,7 +373,7 @@ static int irttp_param_max_sdu_size(void *instance, irda_param_t *param,
 static void irttp_init_tsap(struct tsap_cb *tsap)
 {
 	spin_lock_init(&tsap->lock);
-	init_timer(&tsap->todo_timer);
+	timer_setup(&tsap->todo_timer, irttp_todo_expired, 0);
 
 	skb_queue_head_init(&tsap->rx_queue);
 	skb_queue_head_init(&tsap->tx_queue);
@@ -410,10 +409,6 @@ struct tsap_cb *irttp_open_tsap(__u8 stsap_sel, int credit, notify_t *notify)
 	/* Initialize internal objects */
 	irttp_init_tsap(self);
 
-	/* Initialise todo timer */
-	self->todo_timer.data     = (unsigned long) self;
-	self->todo_timer.function = &irttp_todo_expired;
-
 	/* Initialize callbacks for IrLMP to use */
 	irda_notify_init(&ttp_notify);
 	ttp_notify.connect_confirm = irttp_connect_confirm;
diff --git a/drivers/staging/irda/net/timer.c b/drivers/staging/irda/net/timer.c
index f2280f73b057..cf00c0d848aa 100644
--- a/drivers/staging/irda/net/timer.c
+++ b/drivers/staging/irda/net/timer.c
@@ -34,16 +34,16 @@
 
 extern int  sysctl_slot_timeout;
 
-static void irlap_slot_timer_expired(void* data);
-static void irlap_query_timer_expired(void* data);
-static void irlap_final_timer_expired(void* data);
-static void irlap_wd_timer_expired(void* data);
-static void irlap_backoff_timer_expired(void* data);
-static void irlap_media_busy_expired(void* data);
+static void irlap_slot_timer_expired(struct timer_list *t);
+static void irlap_query_timer_expired(struct timer_list *t);
+static void irlap_final_timer_expired(struct timer_list *t);
+static void irlap_wd_timer_expired(struct timer_list *t);
+static void irlap_backoff_timer_expired(struct timer_list *t);
+static void irlap_media_busy_expired(struct timer_list *t);
 
 void irlap_start_slot_timer(struct irlap_cb *self, int timeout)
 {
-	irda_start_timer(&self->slot_timer, timeout, (void *) self,
+	irda_start_timer(&self->slot_timer, timeout,
 			 irlap_slot_timer_expired);
 }
 
@@ -66,32 +66,32 @@ void irlap_start_query_timer(struct irlap_cb *self, int S, int s)
 	/* Set or re-set the timer. We reset the timer for each received
 	 * discovery query, which allow us to automatically adjust to
 	 * the speed of the peer discovery (faster or slower). Jean II */
-	irda_start_timer( &self->query_timer, timeout, (void *) self,
+	irda_start_timer(&self->query_timer, timeout,
 			  irlap_query_timer_expired);
 }
 
 void irlap_start_final_timer(struct irlap_cb *self, int timeout)
 {
-	irda_start_timer(&self->final_timer, timeout, (void *) self,
+	irda_start_timer(&self->final_timer, timeout,
 			 irlap_final_timer_expired);
 }
 
 void irlap_start_wd_timer(struct irlap_cb *self, int timeout)
 {
-	irda_start_timer(&self->wd_timer, timeout, (void *) self,
+	irda_start_timer(&self->wd_timer, timeout,
 			 irlap_wd_timer_expired);
 }
 
 void irlap_start_backoff_timer(struct irlap_cb *self, int timeout)
 {
-	irda_start_timer(&self->backoff_timer, timeout, (void *) self,
+	irda_start_timer(&self->backoff_timer, timeout,
 			 irlap_backoff_timer_expired);
 }
 
 void irlap_start_mbusy_timer(struct irlap_cb *self, int timeout)
 {
 	irda_start_timer(&self->media_busy_timer, timeout,
-			 (void *) self, irlap_media_busy_expired);
+			 irlap_media_busy_expired);
 }
 
 void irlap_stop_mbusy_timer(struct irlap_cb *self)
@@ -110,19 +110,19 @@ void irlap_stop_mbusy_timer(struct irlap_cb *self)
 
 void irlmp_start_watchdog_timer(struct lsap_cb *self, int timeout)
 {
-	irda_start_timer(&self->watchdog_timer, timeout, (void *) self,
+	irda_start_timer(&self->watchdog_timer, timeout,
 			 irlmp_watchdog_timer_expired);
 }
 
 void irlmp_start_discovery_timer(struct irlmp_cb *self, int timeout)
 {
-	irda_start_timer(&self->discovery_timer, timeout, (void *) self,
+	irda_start_timer(&self->discovery_timer, timeout,
 			 irlmp_discovery_timer_expired);
 }
 
 void irlmp_start_idle_timer(struct lap_cb *self, int timeout)
 {
-	irda_start_timer(&self->idle_timer, timeout, (void *) self,
+	irda_start_timer(&self->idle_timer, timeout,
 			 irlmp_idle_timer_expired);
 }
 
@@ -138,9 +138,9 @@ void irlmp_stop_idle_timer(struct lap_cb *self)
  *    IrLAP slot timer has expired
  *
  */
-static void irlap_slot_timer_expired(void *data)
+static void irlap_slot_timer_expired(struct timer_list *t)
 {
-	struct irlap_cb *self = (struct irlap_cb *) data;
+	struct irlap_cb *self = from_timer(self, t, slot_timer);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
@@ -154,9 +154,9 @@ static void irlap_slot_timer_expired(void *data)
  *    IrLAP query timer has expired
  *
  */
-static void irlap_query_timer_expired(void *data)
+static void irlap_query_timer_expired(struct timer_list *t)
 {
-	struct irlap_cb *self = (struct irlap_cb *) data;
+	struct irlap_cb *self = from_timer(self, t, query_timer);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
@@ -170,9 +170,9 @@ static void irlap_query_timer_expired(void *data)
  *
  *
  */
-static void irlap_final_timer_expired(void *data)
+static void irlap_final_timer_expired(struct timer_list *t)
 {
-	struct irlap_cb *self = (struct irlap_cb *) data;
+	struct irlap_cb *self = from_timer(self, t, final_timer);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
@@ -186,9 +186,9 @@ static void irlap_final_timer_expired(void *data)
  *
  *
  */
-static void irlap_wd_timer_expired(void *data)
+static void irlap_wd_timer_expired(struct timer_list *t)
 {
-	struct irlap_cb *self = (struct irlap_cb *) data;
+	struct irlap_cb *self = from_timer(self, t, wd_timer);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
@@ -202,9 +202,9 @@ static void irlap_wd_timer_expired(void *data)
  *
  *
  */
-static void irlap_backoff_timer_expired(void *data)
+static void irlap_backoff_timer_expired(struct timer_list *t)
 {
-	struct irlap_cb *self = (struct irlap_cb *) data;
+	struct irlap_cb *self = from_timer(self, t, backoff_timer);
 
 	IRDA_ASSERT(self != NULL, return;);
 	IRDA_ASSERT(self->magic == LAP_MAGIC, return;);
@@ -218,9 +218,9 @@ static void irlap_backoff_timer_expired(void *data)
  *
  *
  */
-static void irlap_media_busy_expired(void *data)
+static void irlap_media_busy_expired(struct timer_list *t)
 {
-	struct irlap_cb *self = (struct irlap_cb *) data;
+	struct irlap_cb *self = from_timer(self, t, media_busy_timer);
 
 	IRDA_ASSERT(self != NULL, return;);
 
-- 
2.7.4
