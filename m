From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] drivers/net: appletalk/cops: Convert timers to use
 timer_setup()
Date: Thu, 26 Oct 2017 22:54:45 -0700
Message-ID: <20171027055445.GA96228@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Allen Pais <allen.lkml@gmail.com>,
        David Howells <dhowells@redhat.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Allen Pais <allen.lkml@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: David Howells <dhowells@redhat.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/appletalk/cops.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/appletalk/cops.c b/drivers/net/appletalk/cops.c
index caf04284711a..bb49f6e40a19 100644
--- a/drivers/net/appletalk/cops.c
+++ b/drivers/net/appletalk/cops.c
@@ -155,6 +155,7 @@ static int cops_irqlist[] = {
 };
 
 static struct timer_list cops_timer;
+static struct net_device *cops_timer_dev;
 
 /* use 0 for production, 1 for verification, 2 for debug, 3 for verbose debug */
 #ifndef COPS_DEBUG
@@ -187,7 +188,7 @@ static void cops_load (struct net_device *dev);
 static int  cops_nodeid (struct net_device *dev, int nodeid);
 
 static irqreturn_t cops_interrupt (int irq, void *dev_id);
-static void cops_poll (unsigned long ltdev);
+static void cops_poll(struct timer_list *t);
 static void cops_timeout(struct net_device *dev);
 static void cops_rx (struct net_device *dev);
 static netdev_tx_t  cops_send_packet (struct sk_buff *skb,
@@ -424,7 +425,8 @@ static int cops_open(struct net_device *dev)
 		 */
 		if(lp->board==TANGENT)	/* Poll 20 times per second */
 		{
-		    setup_timer(&cops_timer, cops_poll, (unsigned long)dev);
+		    cops_timer_dev = dev;
+		    timer_setup(&cops_timer, cops_poll, 0);
 		    cops_timer.expires 	= jiffies + HZ/20;
 		    add_timer(&cops_timer);
 		} 
@@ -671,12 +673,11 @@ static int cops_nodeid (struct net_device *dev, int nodeid)
  *	Poll the Tangent type cards to see if we have work.
  */
  
-static void cops_poll(unsigned long ltdev)
+static void cops_poll(struct timer_list *unused)
 {
 	int ioaddr, status;
 	int boguscount = 0;
-
-	struct net_device *dev = (struct net_device *)ltdev;
+	struct net_device *dev = cops_timer_dev;
 
 	del_timer(&cops_timer);
 
-- 
2.7.4


-- 
Kees Cook
Pixel Security
