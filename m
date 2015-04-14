From: Sebastian Poehn <sebastian.poehn@gmail.com>
Subject: Re: [PATCH] ip_forward: Drop frames with attached skb->sk
Date: Tue, 14 Apr 2015 08:40:08 +0200
Message-ID: <1428993608.6812.24.camel@googlemail.com>
References: <1428990724.6812.8.camel@googlemail.com>
	 <552CB4BC.9000207@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sebastian Poehn <sebastian.poehn@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	fw@strlen.de, eric.dumazet@gmail.com
To: yzhu1 <Yanjun.Zhu@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:35565 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752965AbbDNGkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 02:40:10 -0400
Received: by wgyo15 with SMTP id o15so581064wgy.2
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 23:40:09 -0700 (PDT)
In-Reply-To: <552CB4BC.9000207@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-04-14 at 14:33 +0800, yzhu1 wrote:
> On 04/14/2015 01:52 PM, Sebastian Poehn wrote:
> > Initial discussion was:
> > [FYI] xfrm: Don't lookup sk_policy for timewait sockets
> >
> > Forwarded frames should not have a socket attached. Especially
> > tw sockets will lead to panics later-on in the stack.
> >
> > This was observed with TPROXY assigning a tw socket and broken
> > policy routing (misconfigured). As a result frame enters
> > forwarding path instead of input. We cannot solve this in
> > TPROXY as it cannot know that policy routing is broken.
> >
> > Signed-off-by: Sebastian Poehn <sebastian.poehn@gmail.com>
> > ---
> > diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
> > index 939992c..2fc3b3e 100644
> > --- a/net/ipv4/ip_forward.c
> > +++ b/net/ipv4/ip_forward.c
> > @@ -82,6 +82,10 @@ int ip_forward(struct sk_buff *skb)
> >   	if (skb->pkt_type != PACKET_HOST)
> >   		goto drop;
> >   
> > +	/* this should happen neither */
> Sorry. "neither" should be "either"?

        /* that should never happen */
        if (skb->pkt_type != PACKET_HOST)
                goto drop;

        /* this should happen neither */
        if (unlikely(skb->sk))
                goto drop;

Both of them should never happen.

> 
> Zhu Yanjun
> > +	if (unlikely(skb->sk))
> > +		goto drop;
> > +
> >   	if (skb_warn_if_lro(skb))
> >   		goto drop;
> > --
> >
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> 
