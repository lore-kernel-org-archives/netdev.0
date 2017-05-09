From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net v2] driver: vrf: Fix one possible use-after-free issue
Date: Tue, 9 May 2017 19:11:42 +0200
Message-ID: <20170509171142.GC16263@breakpoint.cc>
References: <1494325653-39885-1-git-send-email-gfree.wind@vip.163.com>
 <43be9c0c-2cee-5d05-0908-53b81b4ebbba@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gfree.wind@vip.163.com, shm@cumulusnetworks.com,
        davem@davemloft.net, fw@strlen.de, netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:45082 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753460AbdEIRMP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 13:12:15 -0400
Content-Disposition: inline
In-Reply-To: <43be9c0c-2cee-5d05-0908-53b81b4ebbba@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ahern <dsahern@gmail.com> wrote:
> On 5/9/17 3:27 AM, gfree.wind@vip.163.com wrote:
> > diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
> > index ceda586..db88249 100644
> > --- a/drivers/net/vrf.c
> > +++ b/drivers/net/vrf.c
> > @@ -989,6 +989,7 @@ static u32 vrf_fib_table(const struct net_device *dev)
> >  
> >  static int vrf_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
> >  {
> > +	kfree_skb(skb);
> >  	return 0;
> >  }
> >  
> > @@ -998,7 +999,7 @@ static struct sk_buff *vrf_rcv_nfhook(u8 pf, unsigned int hook,
> >  {
> >  	struct net *net = dev_net(dev);
> >  
> > -	if (NF_HOOK(pf, hook, net, NULL, skb, dev, NULL, vrf_rcv_finish) < 0)
> > +	if (nf_hook(pf, hook, net, NULL, skb, dev, NULL, vrf_rcv_finish) != 1)
> >  		skb = NULL;    /* kfree_skb(skb) handled by nf code */
> >  
> >  	return skb;
> > 
> 
> I'm clearly misunderstanding something ...
> 
> With the current code:
> - nf_hook returns 1, NF_HOOK invokes vrf_rcv_finish as the okfn, it
> returns 0, skb passes on.
> 
> - nf_hook returns 0, vrf_rcv_finish has been called by the nf_hook tree,
> vrf_rcv_finish returns 0, skb passes on

Yes, thats a bug. The skb could be have been queued to userspace, or
stolen by a hook.

It is illegal to use the skb after NF_HOOK() no matter the return value.
The okfn has to do further processing.

If nf_hook() is used instead, only a return value of 1 means the skb is
still valid.

In < 0 case it was free'd, in 0 case its in unknown state (usually queued
or free'd).

As for the patch, it avoids skb leak on userspace reinject but nfqueue
still won't work as no reinject is possible (vrf_rcv_finish is a sink that
doesn't do anyting).

Hope this clarifies things.
