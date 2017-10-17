From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 45/58] net: seeq: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:29:29 -0700
Message-ID: <1508200182-104605-46-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        Russell King <linux@armlinux.org.uk>,
        linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Russell King <linux@armlinux.org.uk>
Cc: linux-arm-kernel@lists.infradead.org
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/seeq/ether3.c | 11 ++++++-----
 drivers/net/ethernet/seeq/ether3.h |  1 +
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/seeq/ether3.c b/drivers/net/ethernet/seeq/ether3.c
index 244c1e171017..da4807723a06 100644
--- a/drivers/net/ethernet/seeq/ether3.c
+++ b/drivers/net/ethernet/seeq/ether3.c
@@ -170,9 +170,11 @@ ether3_setbuffer(struct net_device *dev, buffer_rw_t read, int start)
 /*
  * Switch LED off...
  */
-static void ether3_ledoff(unsigned long data)
+static void ether3_ledoff(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *)data;
+	struct dev_priv *private = from_timer(priv, t, timer);
+	struct net_device *dev = private->dev;
+
 	ether3_outw(priv(dev)->regs.config2 |= CFG2_CTRLO, REG_CONFIG2);
 }
 
@@ -183,8 +185,6 @@ static inline void ether3_ledon(struct net_device *dev)
 {
 	del_timer(&priv(dev)->timer);
 	priv(dev)->timer.expires = jiffies + HZ / 50; /* leave on for 1/50th second */
-	priv(dev)->timer.data = (unsigned long)dev;
-	priv(dev)->timer.function = ether3_ledoff;
 	add_timer(&priv(dev)->timer);
 	if (priv(dev)->regs.config2 & CFG2_CTRLO)
 		ether3_outw(priv(dev)->regs.config2 &= ~CFG2_CTRLO, REG_CONFIG2);
@@ -783,7 +783,8 @@ ether3_probe(struct expansion_card *ec, const struct ecard_id *id)
 
 	ether3_addr(dev->dev_addr, ec);
 
-	init_timer(&priv(dev)->timer);
+	priv(dev)->dev = dev;
+	timer_setup(&priv(dev)->timer, ether3_ledoff, 0);
 
 	/* Reset card...
 	 */
diff --git a/drivers/net/ethernet/seeq/ether3.h b/drivers/net/ethernet/seeq/ether3.h
index 2db63b08bdf3..ea2ba286e665 100644
--- a/drivers/net/ethernet/seeq/ether3.h
+++ b/drivers/net/ethernet/seeq/ether3.h
@@ -165,6 +165,7 @@ struct dev_priv {
     unsigned char tx_tail;		/* buffer nr of transmitting packet	 */
     unsigned int rx_head;		/* address to fetch next packet from	 */
     struct timer_list timer;
+    net_device *dev;
     int broken;				/* 0 = ok, 1 = something went wrong	 */
 };
 
-- 
2.7.4
