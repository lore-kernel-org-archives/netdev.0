From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] net: dl2k: Convert timers to use timer_setup()
Date: Wed, 4 Oct 2017 17:51:50 -0700
Message-ID: <20171005005150.GA23486@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Jarod Wilson <jarod@redhat.com>,
        Tobias Klauser <tklauser@distanz.ch>,
        Philippe Reynes <tremyfr@gmail.com>, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Jarod Wilson <jarod@redhat.com>
Cc: Tobias Klauser <tklauser@distanz.ch>
Cc: Philippe Reynes <tremyfr@gmail.com>
Cc: netdev@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
This requires commit 686fef928bba ("timer: Prepare to change timer
callback argument type") in v4.14-rc3, but should be otherwise
stand-alone.
---
 drivers/net/ethernet/dlink/dl2k.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/dlink/dl2k.c b/drivers/net/ethernet/dlink/dl2k.c
index 778f974e2928..a2f6758d38dd 100644
--- a/drivers/net/ethernet/dlink/dl2k.c
+++ b/drivers/net/ethernet/dlink/dl2k.c
@@ -68,7 +68,7 @@ static const int max_intrloop = 50;
 static const int multicast_filter_limit = 0x40;
 
 static int rio_open (struct net_device *dev);
-static void rio_timer (unsigned long data);
+static void rio_timer (struct timer_list *t);
 static void rio_tx_timeout (struct net_device *dev);
 static netdev_tx_t start_xmit (struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t rio_interrupt (int irq, void *dev_instance);
@@ -644,7 +644,7 @@ static int rio_open(struct net_device *dev)
 		return i;
 	}
 
-	setup_timer(&np->timer, rio_timer, (unsigned long)dev);
+	timer_setup(&np->timer, rio_timer, 0);
 	np->timer.expires = jiffies + 1 * HZ;
 	add_timer(&np->timer);
 
@@ -655,10 +655,10 @@ static int rio_open(struct net_device *dev)
 }
 
 static void
-rio_timer (unsigned long data)
+rio_timer (struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *)data;
-	struct netdev_private *np = netdev_priv(dev);
+	struct netdev_private *np = from_timer(np, t, timer);
+	struct net_device *dev = pci_get_drvdata(np->pdev);
 	unsigned int entry;
 	int next_tick = 1*HZ;
 	unsigned long flags;
-- 
2.7.4


-- 
Kees Cook
Pixel Security
