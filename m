From: Colin Leroy <colin@colino.net>
Subject: Re: [PATCH] Prevent netpoll hanging when link is down
Date: Thu, 7 Oct 2004 16:05:32 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041007160532.60c3f26b@pirandello>
References: <20041006232544.53615761@jack.colino.net>
	<20041006214322.GG31237@waste.org>
	<20041007075319.6b31430d@jack.colino.net>
	<20041006234912.66bfbdcc.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20041006234912.66bfbdcc.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 06 Oct 2004 at 23h10, David S. Miller wrote:

Hi again, 

> Folks debugging this should verify that gp->hw_running is non-zero
> when the problematic case runs.

I looked a bit more at the code and found out a possible problem.
However it doesn't fix the hang, so either it's not what I found, or
there's something else.

First, my newbie question: is it possible to deadlock a spinlock on a
Uniprocessor kernel ? For example, there's something I find suspect in
netpoll/sungem interaction:

it starts in netpoll_send_skb(), where xmit_lock is acquired; then,
gem_start_xmit() is called. In gem_start_xmit(), if the TX ring is full,
we return 1, but previously log the error via printk(). 
In this condition, isn't netpoll_send_skb() called again (via the whole
console stuff), where it retries to get the lock on xmit_lock? Could
that cause a deadlock?

Also, at the end of netpoll_send_skb() is a check for the return status
of hard_start_xmit. If I understand correctly, hard_start_xmit functions
return 0 for success, -1 for "busy please retry" and 1 for "hard error".
Shouldn't netpoll free the skb and forget about it in case status is 1
(instead of goto'ing repeat) ?

Based on this, I've a new patch that I'm attaching. As said it doesn't
fix the problem, but if my I understood is valid, it may still be
useful ? 

Any insight will be greatly appreciated :)


Patch following:
--- a/net/core/netpoll.c	2004-10-05 21:09:49.000000000 +0200
+++ b/net/core/netpoll.c	2004-10-07 14:11:00.000000000 +0200
@@ -188,7 +188,10 @@
 		return;
 	}
 
-	spin_lock(&np->dev->xmit_lock);
+	if (!spin_trylock(&np->dev->xmit_lock)) {
+		/* looks like np->dev->hard_start_xmit did a printk */
+		goto bail_free;
+	}
 	np->dev->xmit_lock_owner = smp_processor_id();
 
 	/*
@@ -204,13 +207,18 @@
 	}
 
 	status = np->dev->hard_start_xmit(skb, np->dev);
+
 	np->dev->xmit_lock_owner = -1;
 	spin_unlock(&np->dev->xmit_lock);
 
-	/* transmit busy */
-	if(status) {
+	if(status == -1) {
+		/* transmit busy */
 		netpoll_poll(np);
 		goto repeat;
+	} else if (status == 1) {
+		/* hard error, drop this skb */
+bail_free:
+		__kfree_skb(skb);
 	}
 }
 
