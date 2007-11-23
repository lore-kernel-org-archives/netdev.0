From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: 2.6.23 WARNING: at kernel/softirq.c:139 local_bh_enable()
Date: Fri, 23 Nov 2007 21:48:51 +0300
Message-ID: <20071123184851.GA14415@2ka.mipt.ru>
References: <4745DCD7.8070805@simon.arlott.org.uk> <20071123002157.cb27f4a1.akpm@linux-foundation.org> <20071123105518.GA22062@2ka.mipt.ru> <20071123170756.GV19691@waste.org> <20071123175757.GA23991@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Simon Arlott <simon@fire.lp0.eu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Ingo Molnar <mingo@redhat.com>
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:60648 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752429AbXKWStl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2007 13:49:41 -0500
Content-Disposition: inline
In-Reply-To: <20071123175757.GA23991@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 23, 2007 at 08:57:57PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > My memory here is hazy, but I think this exists to rescue netconsole
> > in low-memory situations. This bit originated with Ingo, so maybe he
> > can recall.
> > 
> > Netpoll can process an arbitrary number of skbs inside a single
> > interrupt. Think sysrq-t at one packet per line or kgdboe where the
> > entire trace session can happen inside one very long interrupt.
> > 
> > Perhaps we can refine this to mark netpoll's skbs (perhaps with
> > ->destructor?) and delete only skbs we own. As these are never passed
> > through any of the other route/xfrm/filter code, they should be safe
> > to delete even in irq context, yes?
> > 
> > > Removing zap_completion_queue() from find_skb() will fix the warning,
> > > but I'm not sure this is a correct fix. I've added Matt to the Cc list.
> > 
> > Care to try the sysrq-t or OOM message tests?
> 
> We basically can not free skbs there - if it is interrupt context and
> we are freeing some skb with destructor we will catch the warning anyway.
> 
> No matter if we are under memory pressure or whatever - it is not
> allowed - a lot of skbs are supposed to be freed in softirq context,
> that is why dev_kfree_skb_any() exists.
> 
> I think we can drop skbs _without_ destructor from the queue though in
> that conditions given that we actually need only one.

Stop, we are trying to free skb without destructor and catch connection
tracking, so it is not a solution. To fix the problem we need to check
if it is not netfilter related, kind of this (not tested), Simon please
give it a try:

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 758dafe..855bb3f 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -196,7 +196,7 @@ static void zap_completion_queue(void)
 		while (clist != NULL) {
 			struct sk_buff *skb = clist;
 			clist = clist->next;
-			if (skb->destructor)
+			if (skb->destructor || skb->nfct || skb->nfct_reasm)
 				dev_kfree_skb_any(skb); /* put this one back */
 			else
 				__kfree_skb(skb);


-- 
	Evgeniy Polyakov
