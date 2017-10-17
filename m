From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 38/58] hdlc: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:29:22 -0700
Message-ID: <1508200182-104605-39-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        Krzysztof Halasa <khc@pm.waw.pl>, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly. This adds a pointer back to the
net_device, and drops needless open-coded resetting of the .function and
.data fields.

Cc: David S. Miller <davem@davemloft.net>
Cc: Krzysztof Halasa <khc@pm.waw.pl>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/wan/hdlc_cisco.c | 13 ++++++-------
 drivers/net/wan/hdlc_fr.c    | 12 ++++++------
 2 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/drivers/net/wan/hdlc_cisco.c b/drivers/net/wan/hdlc_cisco.c
index c696d42f4502..320039d329c7 100644
--- a/drivers/net/wan/hdlc_cisco.c
+++ b/drivers/net/wan/hdlc_cisco.c
@@ -54,6 +54,7 @@ struct cisco_state {
 	cisco_proto settings;
 
 	struct timer_list timer;
+	struct net_device *dev;
 	spinlock_t lock;
 	unsigned long last_poll;
 	int up;
@@ -257,11 +258,10 @@ static int cisco_rx(struct sk_buff *skb)
 
 
 
-static void cisco_timer(unsigned long arg)
+static void cisco_timer(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *)arg;
-	hdlc_device *hdlc = dev_to_hdlc(dev);
-	struct cisco_state *st = state(hdlc);
+	struct cisco_state *st = from_timer(st, t, timer);
+	struct net_device *dev = st->dev;
 
 	spin_lock(&st->lock);
 	if (st->up &&
@@ -276,8 +276,6 @@ static void cisco_timer(unsigned long arg)
 	spin_unlock(&st->lock);
 
 	st->timer.expires = jiffies + st->settings.interval * HZ;
-	st->timer.function = cisco_timer;
-	st->timer.data = arg;
 	add_timer(&st->timer);
 }
 
@@ -293,7 +291,8 @@ static void cisco_start(struct net_device *dev)
 	st->up = st->txseq = st->rxseq = 0;
 	spin_unlock_irqrestore(&st->lock, flags);
 
-	setup_timer(&st->timer, cisco_timer, (unsigned long)dev);
+	st->dev = dev;
+	timer_setup(&st->timer, cisco_timer, 0);
 	st->timer.expires = jiffies + HZ; /* First poll after 1 s */
 	add_timer(&st->timer);
 }
diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
index 425a47ffed25..038236a9c60e 100644
--- a/drivers/net/wan/hdlc_fr.c
+++ b/drivers/net/wan/hdlc_fr.c
@@ -140,6 +140,7 @@ struct frad_state {
 	int dce_pvc_count;
 
 	struct timer_list timer;
+	struct net_device *dev;
 	unsigned long last_poll;
 	int reliable;
 	int dce_changed;
@@ -597,9 +598,10 @@ static void fr_set_link_state(int reliable, struct net_device *dev)
 }
 
 
-static void fr_timer(unsigned long arg)
+static void fr_timer(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *)arg;
+	struct frad_state *st = from_timer(st, t, timer);
+	struct net_device *dev = st->dev;
 	hdlc_device *hdlc = dev_to_hdlc(dev);
 	int i, cnt = 0, reliable;
 	u32 list;
@@ -644,8 +646,6 @@ static void fr_timer(unsigned long arg)
 			state(hdlc)->settings.t391 * HZ;
 	}
 
-	state(hdlc)->timer.function = fr_timer;
-	state(hdlc)->timer.data = arg;
 	add_timer(&state(hdlc)->timer);
 }
 
@@ -1003,8 +1003,8 @@ static void fr_start(struct net_device *dev)
 		state(hdlc)->n391cnt = 0;
 		state(hdlc)->txseq = state(hdlc)->rxseq = 0;
 
-		setup_timer(&state(hdlc)->timer, fr_timer,
-			    (unsigned long)dev);
+		state(hdlc)->dev = dev;
+		timer_setup(&state(hdlc)->timer, fr_timer, 0);
 		/* First poll after 1 s */
 		state(hdlc)->timer.expires = jiffies + HZ;
 		add_timer(&state(hdlc)->timer);
-- 
2.7.4
