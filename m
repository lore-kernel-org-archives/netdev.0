From: Florian Westphal <fw@strlen.de>
Subject: Re: [FYI] xfrm: Don't lookup sk_policy for timewait sockets
Date: Thu, 9 Apr 2015 21:25:40 +0200
Message-ID: <20150409192540.GF20653@breakpoint.cc>
References: <1428566941.6875.7.camel@googlemail.com>
 <1428570461.25985.240.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150409.143727.1391401196320839634.davem@davemloft.net>
 <1428607284.25985.269.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, sebastian.poehn@gmail.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:56397 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755939AbbDITZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 15:25:43 -0400
Content-Disposition: inline
In-Reply-To: <1428607284.25985.269.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2015-04-09 at 14:37 -0400, David Miller wrote:
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Thu, 09 Apr 2015 02:07:41 -0700
> > 
> > > TCP stack never sends packets attached to a socket in timewait state.
> > 
> > TPROXY assigns timewait sockets to skb->sk, that's the bug.
> > 
> > In net/netfilter/xt_TPROXY.c:
> > 
> > 	tproxy_tg4()
> >  ...
> > 		sk = nf_tproxy_get_sock_v4(dev_net(skb->dev), iph->protocol,
> > 				   iph->saddr, iph->daddr,
> > 				   hp->source, hp->dest,
> > 				   skb->dev, NFT_LOOKUP_ESTABLISHED);
> > 	/* NOTE: assign_sock consumes our sk reference */
> > 	if (sk && tproxy_sk_is_transparent(sk)) {
> > 		/* This should be in a separate target, but we don't do multiple
> > 		   targets on the same rule yet */
> > 		skb->mark = (skb->mark & ~mark_mask) ^ mark_value;
> > 
> > 		pr_debug("redirecting: proto %hhu %pI4:%hu -> %pI4:%hu, mark: %x\n",
> > 			 iph->protocol, &iph->daddr, ntohs(hp->dest),
> > 			 &laddr, ntohs(lport), skb->mark);
> > 
> > 		nf_tproxy_assign_sock(skb, sk);
> >  ...
> >  /* assign a socket to the skb -- consumes sk */
> > static void
> > nf_tproxy_assign_sock(struct sk_buff *skb, struct sock *sk)
> > {
> > 	skb_orphan(skb);
> > 	skb->sk = sk;
> > 	skb->destructor = sock_edemux;
> > }
> 
> 
> Right, but stack trace shown by Sebastian seems to be an input frame,
> and we transmit a frame. This is the part I do not understand, yet.

Maybe policy routing is wedged so skb is erronously entering forward
path?

After all TPROXY depends on correct marking of skb + ip rule magic
to redirect skb to localhost.
