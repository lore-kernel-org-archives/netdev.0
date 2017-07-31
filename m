From: Shaohua Li <shli@kernel.org>
Subject: Re: [PATCH V4 net 2/2] net: fix tcp reset packet flowlabel for ipv6
Date: Mon, 31 Jul 2017 16:00:02 -0700
Message-ID: <20170731230002.ercfotm7qhfubbbv@kernel.org>
References: <cover.1501539150.git.shli@fb.com>
 <373e23f5295ee4cb725109a9e58152451a9fb4cc.1501539150.git.shli@fb.com>
 <CAM_iQpXOaP4JmGW4-AcL6JYbzKq_Co_Z4pWiSh1B1i=4MsakEQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>, Shaohua Li <shli@fb.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Florent Fourcot <flo@fourcot.fr>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:52820 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751794AbdGaXAE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Jul 2017 19:00:04 -0400
Content-Disposition: inline
In-Reply-To: <CAM_iQpXOaP4JmGW4-AcL6JYbzKq_Co_Z4pWiSh1B1i=4MsakEQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 31, 2017 at 03:35:02PM -0700, Cong Wang wrote:
> On Mon, Jul 31, 2017 at 3:19 PM, Shaohua Li <shli@kernel.org> wrote:
> >  static inline __be32 ip6_make_flowlabel(struct net *net, struct sk_buff *skb,
> >                                         __be32 flowlabel, bool autolabel,
> > -                                       struct flowi6 *fl6)
> > +                                       struct flowi6 *fl6, u32 hash)
> >  {
> > -       u32 hash;
> > -
> >         /* @flowlabel may include more than a flow label, eg, the traffic class.
> >          * Here we want only the flow label value.
> >          */
> > @@ -788,7 +786,8 @@ static inline __be32 ip6_make_flowlabel(struct net *net, struct sk_buff *skb,
> >              net->ipv6.sysctl.auto_flowlabels != IP6_AUTO_FLOW_LABEL_FORCED))
> >                 return flowlabel;
> >
> > -       hash = skb_get_hash_flowi6(skb, fl6);
> > +       if (skb)
> > +               hash = skb_get_hash_flowi6(skb, fl6);
> 
> 
> Why not just move skb_get_hash_flowi6() to its caller?
> This check is not necessary. If you don't want to touch
> existing callers, you can just introduce a wrapper:
> 
> 
> static inline __be32 ip6_make_flowlabel(struct net *net, struct sk_buff *skb,
>                                         __be32 flowlabel, bool autolabel,
>                                         struct flowi6 *fl6)
> {
>   u32 hash = skb_get_hash_flowi6(skb, fl6);
>   return __ip6_make_flowlabel(net, flowlabel, autolabel, hash);
> }

this will always call skb_get_hash_flowi6 for the fast path even auto flowlabel
is disabled. I thought we should avoid this.

> 
> And your code can just call:
> 
> __ip6_make_flowlabel(net, flowlabel, autolabel, sk->sk_txhash);
