From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 40/58] drivers/net/appletalk: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:29:24 -0700
Message-ID: <1508200182-104605-41-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        David Howells <dhowells@redhat.com>, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly. Adds a static variable to hold the
polled net_device.

Cc: David Howells <dhowells@redhat.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/appletalk/ltpc.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/appletalk/ltpc.c b/drivers/net/appletalk/ltpc.c
index cc3dc9337eae..75a5a9b87c5a 100644
--- a/drivers/net/appletalk/ltpc.c
+++ b/drivers/net/appletalk/ltpc.c
@@ -694,6 +694,7 @@ static int do_read(struct net_device *dev, void *cbuf, int cbuflen,
 /* end of idle handlers -- what should be seen is do_read, do_write */
 
 static struct timer_list ltpc_timer;
+static struct net_device *ltpc_timer_dev;
 
 static netdev_tx_t ltpc_xmit(struct sk_buff *skb, struct net_device *dev);
 
@@ -867,10 +868,8 @@ static void set_multicast_list(struct net_device *dev)
 
 static int ltpc_poll_counter;
 
-static void ltpc_poll(unsigned long l)
+static void ltpc_poll(struct timer_list *unused)
 {
-	struct net_device *dev = (struct net_device *) l;
-
 	del_timer(&ltpc_timer);
 
 	if(debug & DEBUG_VERBOSE) {
@@ -882,7 +881,7 @@ static void ltpc_poll(unsigned long l)
 	}
 
 	/* poll 20 times per second */
-	idle(dev);
+	idle(ltpc_timer_dev);
 	ltpc_timer.expires = jiffies + HZ/20;
 	add_timer(&ltpc_timer);
 }
@@ -1161,7 +1160,8 @@ struct net_device * __init ltpc_probe(void)
 		dev->irq = 0;
 		/* polled mode -- 20 times per second */
 		/* this is really, really slow... should it poll more often? */
-		setup_timer(&ltpc_timer, ltpc_poll, (unsigned long)dev);
+		ltpc_timer_dev = dev;
+		timer_setup(&ltpc_timer, ltpc_poll, 0);
 
 		ltpc_timer.expires = jiffies + HZ/20;
 		add_timer(&ltpc_timer);
-- 
2.7.4
