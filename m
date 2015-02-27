From: Vaishali Thakkar <vthakkar1994@gmail.com>
Subject: [PATCH] isdn: Use setup_timer and mod_timer
Date: Fri, 27 Feb 2015 14:33:46 +0530
Message-ID: <20150227090346.GA16058@vaishali-Ideapad-Z570>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use timer API functions setup_timer and mod_timer instead
of structure assignments as they are standard way to set
the timer and to update the expire field of an active timer
respectively.

This is done using Coccinelle and semantic patch used for
this is as follows:

// <smpl>
@@
expression x,y,z,a,b;
@@

-init_timer (&x);
+setup_timer (&x, y, z);
+mod_timer (&a, b);
-x.function = y;
-x.data = z;
-x.expires = b;
-add_timer(&a);
// </smpl>

Signed-off-by: Vaishali Thakkar <vthakkar1994@gmail.com>
---
 drivers/isdn/pcbit/drv.c    | 8 +++-----
 drivers/isdn/pcbit/edss1.c  | 7 ++-----
 drivers/isdn/pcbit/layer2.c | 8 +++-----
 3 files changed, 8 insertions(+), 15 deletions(-)

diff --git a/drivers/isdn/pcbit/drv.c b/drivers/isdn/pcbit/drv.c
index 4172e22..dc7df95 100644
--- a/drivers/isdn/pcbit/drv.c
+++ b/drivers/isdn/pcbit/drv.c
@@ -359,11 +359,9 @@ static int pcbit_xmit(int driver, int chnum, int ack, struct sk_buff *skb)
 		 */
 #ifdef BLOCK_TIMER
 		if (chan->block_timer.function == NULL) {
-			init_timer(&chan->block_timer);
-			chan->block_timer.function =  &pcbit_block_timer;
-			chan->block_timer.data = (long) chan;
-			chan->block_timer.expires = jiffies + 1 * HZ;
-			add_timer(&chan->block_timer);
+			setup_timer(&chan->block_timer, &pcbit_block_timer,
+				    (long)chan);
+			mod_timer(&chan->block_timer, jiffies + 1 * HZ);
 		}
 #endif
 		return 0;
diff --git a/drivers/isdn/pcbit/edss1.c b/drivers/isdn/pcbit/edss1.c
index b2262ba..af524c7 100644
--- a/drivers/isdn/pcbit/edss1.c
+++ b/drivers/isdn/pcbit/edss1.c
@@ -298,11 +298,8 @@ void pcbit_fsm_event(struct pcbit_dev *dev, struct pcbit_chan *chan,
 			break;
 
 	if (tentry->init != 0xff) {
-		init_timer(&chan->fsm_timer);
-		chan->fsm_timer.function = &pcbit_fsm_timer;
-		chan->fsm_timer.data = (ulong) chan;
-		chan->fsm_timer.expires = jiffies + tentry->timeout * HZ;
-		add_timer(&chan->fsm_timer);
+		setup_timer(&chan->fsm_timer, &pcbit_fsm_timer, (ulong)chan);
+		mod_timer(&chan->fsm_timer, jiffies + tentry->timeout * HZ);
 	}
 
 	spin_unlock_irqrestore(&dev->lock, flags);
diff --git a/drivers/isdn/pcbit/layer2.c b/drivers/isdn/pcbit/layer2.c
index 46e1240..a136c72 100644
--- a/drivers/isdn/pcbit/layer2.c
+++ b/drivers/isdn/pcbit/layer2.c
@@ -645,11 +645,9 @@ pcbit_l2_error(struct pcbit_dev *dev)
 
 		dev->l2_state = L2_DOWN;
 
-		init_timer(&dev->error_recover_timer);
-		dev->error_recover_timer.function = &pcbit_l2_err_recover;
-		dev->error_recover_timer.data = (ulong) dev;
-		dev->error_recover_timer.expires = jiffies + ERRTIME;
-		add_timer(&dev->error_recover_timer);
+		setup_timer(&dev->error_recover_timer, &pcbit_l2_err_recover,
+			    (ulong)dev);
+		mod_timer(&dev->error_recover_timer, jiffies + ERRTIME);
 	}
 }
 
-- 
1.9.1
