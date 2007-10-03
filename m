From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] net: fix race in process_backlog
Date: Wed, 3 Oct 2007 15:05:19 -0700
Message-ID: <20071003150519.1fd206a8@freepuppy.rosehill>
References: <1191426293.5599.27.camel@lappy>
	<20071003.145807.111205634.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jdike@addtoit.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:47162 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754130AbXJCWFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2007 18:05:32 -0400
In-Reply-To: <20071003.145807.111205634.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 03 Oct 2007 14:58:07 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Date: Wed, 03 Oct 2007 17:44:53 +0200
> 
> > Index: linux-2.6/net/core/dev.c
> > ===================================================================
> > --- linux-2.6.orig/net/core/dev.c
> > +++ linux-2.6/net/core/dev.c
> > @@ -2095,11 +2095,11 @@ static int process_backlog(struct napi_s
> >  
> >  		local_irq_disable();
> >  		skb = __skb_dequeue(&queue->input_pkt_queue);
> > -		local_irq_enable();
> >  		if (!skb) {
> > -			napi_complete(napi);
> > +			__napi_complete(napi);
> >  			break;
> >  		}
> > +		local_irq_enable();
> 
> What re-enables interrupts in the !skb path?

This looks like a better fix. the irq_enable is needed in both cases.

--- a/net/core/dev.c	2007-09-27 07:19:10.000000000 -0700
+++ b/net/core/dev.c	2007-10-03 15:03:54.000000000 -0700
@@ -2077,12 +2077,14 @@ static int process_backlog(struct napi_s
 
 		local_irq_disable();
 		skb = __skb_dequeue(&queue->input_pkt_queue);
-		local_irq_enable();
 		if (!skb) {
-			napi_complete(napi);
+			__napi_complete(napi);
+			local_irq_enable();
 			break;
 		}
 
+		local_irq_enable();
+
 		dev = skb->dev;
 
 		netif_receive_skb(skb);


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
