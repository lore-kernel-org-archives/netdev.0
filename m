From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: 2.6.23 WARNING: at kernel/softirq.c:139 local_bh_enable()
Date: Fri, 23 Nov 2007 21:59:06 +0300
Message-ID: <20071123185906.GA23710@2ka.mipt.ru>
References: <4745DCD7.8070805@simon.arlott.org.uk> <20071123002157.cb27f4a1.akpm@linux-foundation.org> <20071123105518.GA22062@2ka.mipt.ru> <20071123170756.GV19691@waste.org> <20071123175757.GA23991@2ka.mipt.ru> <20071123184851.GA14415@2ka.mipt.ru> <20071123185101.GA17582@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Simon Arlott <simon@fire.lp0.eu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Ingo Molnar <mingo@redhat.com>
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:34328 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752877AbXKWS7u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2007 13:59:50 -0500
Content-Disposition: inline
In-Reply-To: <20071123185101.GA17582@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 23, 2007 at 09:51:01PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> On Fri, Nov 23, 2007 at 09:48:51PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > Stop, we are trying to free skb without destructor and catch connection
> > tracking, so it is not a solution. To fix the problem we need to check
> > if it is not netfilter related, kind of this (not tested), Simon please
> > give it a try:
> 
> And to be really cool we need to bypass skbs with xfrm attached, since
> its freeing also assumes BH context.

What about compile options?

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 758dafe..adb3c54 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -196,10 +196,25 @@ static void zap_completion_queue(void)
 		while (clist != NULL) {
 			struct sk_buff *skb = clist;
 			clist = clist->next;
-			if (skb->destructor)
+			if (skb->destructor) {
 				dev_kfree_skb_any(skb); /* put this one back */
-			else
-				__kfree_skb(skb);
+				continue;
+			}
+
+#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+			if (skb->nfct || skb->nfct_reasm) {
+				dev_kfree_skb_any(skb); /* put this one back */
+				continue;
+			}
+#endif
+
+#ifdef CONFIG_XFRM
+			if (skb->sp) {
+				dev_kfree_skb_any(skb); /* put this one back */
+				continue;
+			}
+#endif
+			__kfree_skb(skb);
 		}
 	}
 

-- 
	Evgeniy Polyakov
