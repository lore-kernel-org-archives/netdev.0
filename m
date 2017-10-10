From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] hdlc: Convert timers to use timer_setup()
Date: Tue, 10 Oct 2017 15:08:33 -0700
Message-ID: <20171010220833.GA97664@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krzysztof Halasa <khc@pm.waw.pl>, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
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
This requires commit 686fef928bba ("timer: Prepare to change timer
callback argument type") in v4.14-rc3, but should be otherwise
stand-alone.
---
 drivers/net/wan/hdlc_cisco.c | 15 ++++++---------
 drivers/net/wan/hdlc_fr.c    | 13 ++++++-------
 2 files changed, 12 insertions(+), 16 deletions(-)

diff --git a/drivers/net/wan/hdlc_cisco.c b/drivers/net/wan/hdlc_cisco.c
index a408abc25512..320039d329c7 100644
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
 
@@ -293,10 +291,9 @@ static void cisco_start(struct net_device *dev)
 	st->up = st->txseq = st->rxseq = 0;
 	spin_unlock_irqrestore(&st->lock, flags);
 
-	init_timer(&st->timer);
+	st->dev = dev;
+	timer_setup(&st->timer, cisco_timer, 0);
 	st->timer.expires = jiffies + HZ; /* First poll after 1 s */
-	st->timer.function = cisco_timer;
-	st->timer.data = (unsigned long)dev;
 	add_timer(&st->timer);
 }
 
diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
index 78596e42a3f3..038236a9c60e 100644
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
 
@@ -1003,11 +1003,10 @@ static void fr_start(struct net_device *dev)
 		state(hdlc)->n391cnt = 0;
 		state(hdlc)->txseq = state(hdlc)->rxseq = 0;
 
-		init_timer(&state(hdlc)->timer);
+		state(hdlc)->dev = dev;
+		timer_setup(&state(hdlc)->timer, fr_timer, 0);
 		/* First poll after 1 s */
 		state(hdlc)->timer.expires = jiffies + HZ;
-		state(hdlc)->timer.function = fr_timer;
-		state(hdlc)->timer.data = (unsigned long)dev;
 		add_timer(&state(hdlc)->timer);
 	} else
 		fr_set_link_state(1, dev);
-- 
2.7.4


-- 
Kees Cook
Pixel Security
