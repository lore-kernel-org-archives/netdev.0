From: Matt Mackall <mpm@selenic.com>
Subject: Re: 2.6.23 WARNING: at kernel/softirq.c:139 local_bh_enable()
Date: Fri, 23 Nov 2007 13:11:20 -0600
Message-ID: <20071123191120.GA19691@waste.org>
References: <4745DCD7.8070805@simon.arlott.org.uk> <20071123002157.cb27f4a1.akpm@linux-foundation.org> <20071123105518.GA22062@2ka.mipt.ru> <20071123170756.GV19691@waste.org> <20071123175757.GA23991@2ka.mipt.ru> <20071123184851.GA14415@2ka.mipt.ru> <20071123185101.GA17582@2ka.mipt.ru> <20071123185906.GA23710@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Simon Arlott <simon@fire.lp0.eu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Ingo Molnar <mingo@redhat.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:50241 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755267AbXKWTQ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2007 14:16:28 -0500
Content-Disposition: inline
In-Reply-To: <20071123185906.GA23710@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 23, 2007 at 09:59:06PM +0300, Evgeniy Polyakov wrote:
> On Fri, Nov 23, 2007 at 09:51:01PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > On Fri, Nov 23, 2007 at 09:48:51PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > > Stop, we are trying to free skb without destructor and catch connection
> > > tracking, so it is not a solution. To fix the problem we need to check
> > > if it is not netfilter related, kind of this (not tested), Simon please
> > > give it a try:
> > 
> > And to be really cool we need to bypass skbs with xfrm attached, since
> > its freeing also assumes BH context.
> 
> What about compile options?

What about my original suggestion that we mark skbs owned by netpoll
and free only those. Much safer, no? Untested:

diff -r c60016ba6237 net/core/netpoll.c
--- a/net/core/netpoll.c	Tue Nov 13 09:09:36 2007 -0800
+++ b/net/core/netpoll.c	Fri Nov 23 13:10:28 2007 -0600
@@ -203,6 +203,12 @@ static void refill_skbs(void)
 	spin_unlock_irqrestore(&skb_pool.lock, flags);
 }
 
+/* used to mark an skb as owned by netpoll */
+static void netpoll_skb_destroy(struct sk_buff *skb)
+{
+	return;
+}
+
 static void zap_completion_queue(void)
 {
 	unsigned long flags;
@@ -219,10 +225,12 @@ static void zap_completion_queue(void)
 		while (clist != NULL) {
 			struct sk_buff *skb = clist;
 			clist = clist->next;
-			if (skb->destructor)
+			if (skb->destructor == netpoll_skb_destroy) {
+				skb->destructor = NULL;
+				__kfree_skb(skb);
+			}
+			else
 				dev_kfree_skb_any(skb); /* put this one back */
-			else
-				__kfree_skb(skb);
 		}
 	}
 
@@ -252,6 +260,7 @@ repeat:
 
 	atomic_set(&skb->users, 1);
 	skb_reserve(skb, reserve);
+	skb->destructor = netpoll_skb_destroy;
 	return skb;
 }
 

-- 
Mathematics is the supreme nostalgia of our time.
