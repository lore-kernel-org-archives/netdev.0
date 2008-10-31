From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pppoe: Add missing sock_put() in pppoe_rcv()
Date: Thu, 30 Oct 2008 23:11:59 -0700 (PDT)
Message-ID: <20081030.231159.155700598.davem@davemloft.net>
References: <20081030085725.GA15289@ff.dom.local>
	<20081031042920.GA6101@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, jeff@garzik.org, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48456
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752759AbYJaGMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 02:12:24 -0400
In-Reply-To: <20081031042920.GA6101@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 31 Oct 2008 12:29:20 +0800

> On Thu, Oct 30, 2008 at 08:57:25AM +0000, Jarek Poplawski wrote:
> >
> > diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
> > index fc6f4b8..c074276 100644
> > --- a/drivers/net/pppoe.c
> > +++ b/drivers/net/pppoe.c
> > @@ -403,8 +403,10 @@ static int pppoe_rcv(struct sk_buff *skb,
> >  	if (!po)
> >  		goto drop;
> >  
> > -	if (pskb_trim_rcsum(skb, len))
> > +	if (pskb_trim_rcsum(skb, len)) {
> > +		sock_put(sk_pppox(po));
> >  		goto drop;
> > +	}
> 
> Actually we might be better off moving the trim before the get_item
> call.

That sounds like a good idea, I'll commit the following:

commit fb764c5b742fdab5615f4a1bac9f43df73599ce3
Author: David S. Miller <davem@davemloft.net>
Date:   Thu Oct 30 23:11:44 2008 -0700

    pppoe: Fix socket leak.
    
    Move SKB trim before we lookup the socket so we don't have to
    put it on failure.
    
    Based upon an initial patch by Jarek Poplawski and suggestions
    from Herbert Xu.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index fc6f4b8..b646e92 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -399,11 +399,11 @@ static int pppoe_rcv(struct sk_buff *skb,
 	if (skb->len < len)
 		goto drop;
 
-	po = get_item(ph->sid, eth_hdr(skb)->h_source, dev->ifindex);
-	if (!po)
+	if (pskb_trim_rcsum(skb, len))
 		goto drop;
 
-	if (pskb_trim_rcsum(skb, len))
+	po = get_item(ph->sid, eth_hdr(skb)->h_source, dev->ifindex);
+	if (!po)
 		goto drop;
 
 	return sk_receive_skb(sk_pppox(po), skb, 0);
