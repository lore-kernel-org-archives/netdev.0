From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] net: ax25: Convert timers to use timer_setup()
Date: Tue, 24 Oct 2017 01:45:39 -0700
Message-ID: <20171024084539.GA23749@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joerg Reuter <jreuter@yaina.de>,
        Ralf Baechle <ralf@linux-mips.org>, linux-hams@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Joerg Reuter <jreuter@yaina.de>
Cc: Ralf Baechle <ralf@linux-mips.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: linux-hams@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 net/ax25/af_ax25.c       |  7 +++----
 net/ax25/ax25_ds_timer.c |  9 ++++-----
 net/ax25/ax25_timer.c    | 41 ++++++++++++++++++++---------------------
 3 files changed, 27 insertions(+), 30 deletions(-)

diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index f3f9d18891de..06eac1f50c5e 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -268,9 +268,9 @@ void ax25_destroy_socket(ax25_cb *);
 /*
  *	Handler for deferred kills.
  */
-static void ax25_destroy_timer(unsigned long data)
+static void ax25_destroy_timer(struct timer_list *t)
 {
-	ax25_cb *ax25=(ax25_cb *)data;
+	ax25_cb *ax25 = from_timer(ax25, t, dtimer);
 	struct sock *sk;
 
 	sk=ax25->sk;
@@ -326,8 +326,7 @@ void ax25_destroy_socket(ax25_cb *ax25)
 	if (ax25->sk != NULL) {
 		if (sk_has_allocations(ax25->sk)) {
 			/* Defer: outstanding buffers */
-			setup_timer(&ax25->dtimer, ax25_destroy_timer,
-					(unsigned long)ax25);
+			timer_setup(&ax25->dtimer, ax25_destroy_timer, 0);
 			ax25->dtimer.expires  = jiffies + 2 * HZ;
 			add_timer(&ax25->dtimer);
 		} else {
diff --git a/net/ax25/ax25_ds_timer.c b/net/ax25/ax25_ds_timer.c
index 5fb2104b7304..e9d11313d45b 100644
--- a/net/ax25/ax25_ds_timer.c
+++ b/net/ax25/ax25_ds_timer.c
@@ -29,7 +29,7 @@
 #include <linux/mm.h>
 #include <linux/interrupt.h>
 
-static void ax25_ds_timeout(unsigned long);
+static void ax25_ds_timeout(struct timer_list *);
 
 /*
  *	Add DAMA slave timeout timer to timer list.
@@ -41,8 +41,7 @@ static void ax25_ds_timeout(unsigned long);
 
 void ax25_ds_setup_timer(ax25_dev *ax25_dev)
 {
-	setup_timer(&ax25_dev->dama.slave_timer, ax25_ds_timeout,
-		    (unsigned long)ax25_dev);
+	timer_setup(&ax25_dev->dama.slave_timer, ax25_ds_timeout, 0);
 }
 
 void ax25_ds_del_timer(ax25_dev *ax25_dev)
@@ -66,9 +65,9 @@ void ax25_ds_set_timer(ax25_dev *ax25_dev)
  *	Silently discard all (slave) connections in case our master forgot us...
  */
 
-static void ax25_ds_timeout(unsigned long arg)
+static void ax25_ds_timeout(struct timer_list *t)
 {
-	ax25_dev *ax25_dev = (struct ax25_dev *) arg;
+	ax25_dev *ax25_dev = from_timer(ax25_dev, t, dama.slave_timer);
 	ax25_cb *ax25;
 
 	if (ax25_dev == NULL || !ax25_dev->dama.slave)
diff --git a/net/ax25/ax25_timer.c b/net/ax25/ax25_timer.c
index 23a6f38a80bf..c47b7ee1e4da 100644
--- a/net/ax25/ax25_timer.c
+++ b/net/ax25/ax25_timer.c
@@ -33,20 +33,19 @@
 #include <linux/mm.h>
 #include <linux/interrupt.h>
 
-static void ax25_heartbeat_expiry(unsigned long);
-static void ax25_t1timer_expiry(unsigned long);
-static void ax25_t2timer_expiry(unsigned long);
-static void ax25_t3timer_expiry(unsigned long);
-static void ax25_idletimer_expiry(unsigned long);
+static void ax25_heartbeat_expiry(struct timer_list *);
+static void ax25_t1timer_expiry(struct timer_list *);
+static void ax25_t2timer_expiry(struct timer_list *);
+static void ax25_t3timer_expiry(struct timer_list *);
+static void ax25_idletimer_expiry(struct timer_list *);
 
 void ax25_setup_timers(ax25_cb *ax25)
 {
-	setup_timer(&ax25->timer, ax25_heartbeat_expiry, (unsigned long)ax25);
-	setup_timer(&ax25->t1timer, ax25_t1timer_expiry, (unsigned long)ax25);
-	setup_timer(&ax25->t2timer, ax25_t2timer_expiry, (unsigned long)ax25);
-	setup_timer(&ax25->t3timer, ax25_t3timer_expiry, (unsigned long)ax25);
-	setup_timer(&ax25->idletimer, ax25_idletimer_expiry,
-		    (unsigned long)ax25);
+	timer_setup(&ax25->timer, ax25_heartbeat_expiry, 0);
+	timer_setup(&ax25->t1timer, ax25_t1timer_expiry, 0);
+	timer_setup(&ax25->t2timer, ax25_t2timer_expiry, 0);
+	timer_setup(&ax25->t3timer, ax25_t3timer_expiry, 0);
+	timer_setup(&ax25->idletimer, ax25_idletimer_expiry, 0);
 }
 
 void ax25_start_heartbeat(ax25_cb *ax25)
@@ -120,10 +119,10 @@ unsigned long ax25_display_timer(struct timer_list *timer)
 
 EXPORT_SYMBOL(ax25_display_timer);
 
-static void ax25_heartbeat_expiry(unsigned long param)
+static void ax25_heartbeat_expiry(struct timer_list *t)
 {
 	int proto = AX25_PROTO_STD_SIMPLEX;
-	ax25_cb *ax25 = (ax25_cb *)param;
+	ax25_cb *ax25 = from_timer(ax25, t, timer);
 
 	if (ax25->ax25_dev)
 		proto = ax25->ax25_dev->values[AX25_VALUES_PROTOCOL];
@@ -145,9 +144,9 @@ static void ax25_heartbeat_expiry(unsigned long param)
 	}
 }
 
-static void ax25_t1timer_expiry(unsigned long param)
+static void ax25_t1timer_expiry(struct timer_list *t)
 {
-	ax25_cb *ax25 = (ax25_cb *)param;
+	ax25_cb *ax25 = from_timer(ax25, t, t1timer);
 
 	switch (ax25->ax25_dev->values[AX25_VALUES_PROTOCOL]) {
 	case AX25_PROTO_STD_SIMPLEX:
@@ -164,9 +163,9 @@ static void ax25_t1timer_expiry(unsigned long param)
 	}
 }
 
-static void ax25_t2timer_expiry(unsigned long param)
+static void ax25_t2timer_expiry(struct timer_list *t)
 {
-	ax25_cb *ax25 = (ax25_cb *)param;
+	ax25_cb *ax25 = from_timer(ax25, t, t2timer);
 
 	switch (ax25->ax25_dev->values[AX25_VALUES_PROTOCOL]) {
 	case AX25_PROTO_STD_SIMPLEX:
@@ -183,9 +182,9 @@ static void ax25_t2timer_expiry(unsigned long param)
 	}
 }
 
-static void ax25_t3timer_expiry(unsigned long param)
+static void ax25_t3timer_expiry(struct timer_list *t)
 {
-	ax25_cb *ax25 = (ax25_cb *)param;
+	ax25_cb *ax25 = from_timer(ax25, t, t3timer);
 
 	switch (ax25->ax25_dev->values[AX25_VALUES_PROTOCOL]) {
 	case AX25_PROTO_STD_SIMPLEX:
@@ -204,9 +203,9 @@ static void ax25_t3timer_expiry(unsigned long param)
 	}
 }
 
-static void ax25_idletimer_expiry(unsigned long param)
+static void ax25_idletimer_expiry(struct timer_list *t)
 {
-	ax25_cb *ax25 = (ax25_cb *)param;
+	ax25_cb *ax25 = from_timer(ax25, t, idletimer);
 
 	switch (ax25->ax25_dev->values[AX25_VALUES_PROTOCOL]) {
 	case AX25_PROTO_STD_SIMPLEX:
-- 
2.7.4


-- 
Kees Cook
Pixel Security
