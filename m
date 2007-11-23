From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: 2.6.23 WARNING: at kernel/softirq.c:139 local_bh_enable()
Date: Fri, 23 Nov 2007 22:54:11 +0300
Message-ID: <20071123195410.GA11401@2ka.mipt.ru>
References: <20071123002157.cb27f4a1.akpm@linux-foundation.org> <20071123105518.GA22062@2ka.mipt.ru> <20071123170756.GV19691@waste.org> <20071123175757.GA23991@2ka.mipt.ru> <20071123184851.GA14415@2ka.mipt.ru> <20071123185101.GA17582@2ka.mipt.ru> <20071123185906.GA23710@2ka.mipt.ru> <20071123191120.GA19691@waste.org> <20071123193222.GA22168@2ka.mipt.ru> <20071123194139.GC19691@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Simon Arlott <simon@fire.lp0.eu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Ingo Molnar <mingo@redhat.com>
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:36854 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756912AbXKWTzA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2007 14:55:00 -0500
Content-Disposition: inline
In-Reply-To: <20071123194139.GC19691@waste.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 23, 2007 at 01:41:39PM -0600, Matt Mackall (mpm@selenic.com) wrote:
> Here's another thought: move all this logic into the networking core,
> unify it with current softirq zapper, then allow it to be called from
> various other places (like atomic allocators). Then it'll all be in
> central maintained place with more users.

This can be done quite easily - put a check into __kfree_skb() if
netpoll is compiled-in and we are in hardirq context, then put skb
into softirq freeing queue. Then zap_completion_queue() can free
anything without ever knowing about nature of the packet, since this
will be checked in __kfree_skb() anyway.

Kind of this:

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 758dafe..88f8ea9 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -196,10 +196,7 @@ static void zap_completion_queue(void)
 		while (clist != NULL) {
 			struct sk_buff *skb = clist;
 			clist = clist->next;
-			if (skb->destructor)
-				dev_kfree_skb_any(skb); /* put this one back */
-			else
-				__kfree_skb(skb);
+			__kfree_skb(skb);
 		}
 	}
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 27cfe5f..f720685 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -318,6 +318,12 @@ void kfree_skbmem(struct sk_buff *skb)
 
 void __kfree_skb(struct sk_buff *skb)
 {
+#if defined(CONFIG_NETPOLL) || defined(CONFIG_NETPOLL_TRAP)
+	if (in_irq() || irqs_disabled()) {
+		dev_kfree_skb_irq(skb);
+		return;
+	}
+#endif
 	dst_release(skb->dst);
 #ifdef CONFIG_XFRM
 	secpath_put(skb->sp);

-- 
	Evgeniy Polyakov
