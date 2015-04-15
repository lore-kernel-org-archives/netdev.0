From: Sebastian Poehn <sebastian.poehn@gmail.com>
Subject: Re: [PATCH] ip_forward: Drop frames with attached skb->sk
Date: Wed, 15 Apr 2015 09:32:32 +0200
Message-ID: <1429083152.6812.29.camel@googlemail.com>
References: <552CB4BC.9000207@windriver.com>
	 <1428993608.6812.24.camel@googlemail.com>
	 <1429012487.7346.3.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150414.142300.2298282114892493676.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, sebastian.poehn@gmail.com,
	Yanjun.Zhu@windriver.com, netdev@vger.kernel.org, fw@strlen.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:33192 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752896AbbDOHcf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 03:32:35 -0400
Received: by wgin8 with SMTP id n8so36862332wgi.0
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2015 00:32:34 -0700 (PDT)
In-Reply-To: <20150414.142300.2298282114892493676.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-04-14 at 14:23 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 14 Apr 2015 04:54:47 -0700
> 
> > On Tue, 2015-04-14 at 08:40 +0200, Sebastian Poehn wrote:
> >> On Tue, 2015-04-14 at 14:33 +0800, yzhu1 wrote:
> >> > On 04/14/2015 01:52 PM, Sebastian Poehn wrote:
> >> > > Initial discussion was:
> >> > > [FYI] xfrm: Don't lookup sk_policy for timewait sockets
> >> > >
> >> > > Forwarded frames should not have a socket attached. Especially
> >> > > tw sockets will lead to panics later-on in the stack.
> >> > >
> >> > > This was observed with TPROXY assigning a tw socket and broken
> >> > > policy routing (misconfigured). As a result frame enters
> >> > > forwarding path instead of input. We cannot solve this in
> >> > > TPROXY as it cannot know that policy routing is broken.
> >> > >
> >> > > Signed-off-by: Sebastian Poehn <sebastian.poehn@gmail.com>
> >> > > ---
> >> > > diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
> >> > > index 939992c..2fc3b3e 100644
> >> > > --- a/net/ipv4/ip_forward.c
> >> > > +++ b/net/ipv4/ip_forward.c
> >> > > @@ -82,6 +82,10 @@ int ip_forward(struct sk_buff *skb)
> >> > >   	if (skb->pkt_type != PACKET_HOST)
> >> > >   		goto drop;
> >> > >   
> >> > > +	/* this should happen neither */
> >> > Sorry. "neither" should be "either"?
> >> 
> >>         /* that should never happen */
> >>         if (skb->pkt_type != PACKET_HOST)
> >>                 goto drop;
> >> 
> >>         /* this should happen neither */
> >>         if (unlikely(skb->sk))
> >>                 goto drop;
> >> 
> >> Both of them should never happen.
> > 
> > I do not feel the comment is useful in this form.
> > 
> > I would prefer explicit TPROXY reference, maybe using this :
> > 
> > #if IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TPROXY)
> > 	if (skb->sk)
> > 		goto drop;
> > #endif
> > 
> > changelog will precisely describes the problem for the curious readers.
> 
> I suspect we really want this test unconditionally, because we are not able
> to safely operate past this point if skb->sk is NULL regardless of what made
> it that way.
> 
> At least, I'll sleep more soundly at night :)

I will send out a v2 patch like that when merge window has closed.
---
 		goto drop;
 
+	if (unlikely(skb->sk))
+		goto drop;
+
 	if (skb_warn_if_lro(skb))
 		goto drop;

---
