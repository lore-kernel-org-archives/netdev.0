From: Colin Leroy <colin@colino.net>
Subject: Re: [PATCH] Prevent netpoll hanging when link is down
Date: Thu, 7 Oct 2004 22:44:22 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041007224422.1c1bea95@jack.colino.net>
References: <20041006232544.53615761@jack.colino.net>
	<20041006214322.GG31237@waste.org>
	<20041007075319.6b31430d@jack.colino.net>
	<20041006234912.66bfbdcc.davem@davemloft.net>
	<20041007160532.60c3f26b@pirandello>
	<20041007112846.5c85b2d9.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041007112846.5c85b2d9.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 07 Oct 2004 at 11h10, David S. Miller wrote:

Hi again, 

> So, netpoll needs to have the NETIF_F_LLTX stuff added to it.

This patch should do that. It works OK for me, but I'd like it checked
before sent upstream...

However, it doesn't fix the hang. it looks like this hang is really
coming from sungem.

--- a/net/core/netpoll.c	2004-10-05 21:09:49.000000000 +0200
+++ b/net/core/netpoll.c	2004-10-07 22:48:58.000000000 +0200
@@ -181,6 +181,7 @@
 void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
 {
 	int status;
+	unsigned must_lock;
 
 repeat:
 	if(!np || !np->dev || !netif_running(np->dev)) {
@@ -188,29 +189,51 @@
 		return;
 	}
 
-	spin_lock(&np->dev->xmit_lock);
-	np->dev->xmit_lock_owner = smp_processor_id();
+	must_lock = !(np->dev->features & NETIF_F_LLTX);
+	
+	if (must_lock) {
+		if (!spin_trylock(&np->dev->xmit_lock)) {
+			if (np->dev->xmit_lock_owner ==
smp_processor_id()) {
+				__kfree_skb(skb);
+				return;
+			}
 
+			goto repeat;
+		}
+		np->dev->xmit_lock_owner = smp_processor_id();
+	}
+	
 	/*
 	 * network drivers do not expect to be called if the queue is
 	 * stopped.
 	 */
 	if (netif_queue_stopped(np->dev)) {
 		np->dev->xmit_lock_owner = -1;
-		spin_unlock(&np->dev->xmit_lock);
+		
+		if (must_lock)
+			spin_unlock(&np->dev->xmit_lock);
 
 		netpoll_poll(np);
 		goto repeat;
 	}
 
 	status = np->dev->hard_start_xmit(skb, np->dev);
-	np->dev->xmit_lock_owner = -1;
-	spin_unlock(&np->dev->xmit_lock);
+
+	if (must_lock) {
+		np->dev->xmit_lock_owner = -1;
+		spin_unlock(&np->dev->xmit_lock);
+	}
 
 	/* transmit busy */
-	if(status) {
+	if (status == NETDEV_TX_LOCKED) {
 		netpoll_poll(np);
 		goto repeat;
+	} 
+	
+	/* hard error */
+	if (status == NETDEV_TX_BUSY) {
+		__kfree_skb(skb);
+		return;
 	}
 }
 
