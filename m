From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v6 3/3] ipv6: tcp_ipv6 policy route issue
Date: Thu, 10 Apr 2014 23:57:08 +0200
Message-ID: <20140410215708.GJ27255@order.stressinduktion.org>
References: <1396056451-5600-1-git-send-email-wangyufen@huawei.com> <1396056451-5600-4-git-send-email-wangyufen@huawei.com> <CAKD1Yr1Qkc6OP_6Oj7x1S0u9QWS5HP17rDAo=_kT8kHm_qPf5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Wangyufen <wangyufen@huawei.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:36132 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753657AbaDJV5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 17:57:09 -0400
Content-Disposition: inline
In-Reply-To: <CAKD1Yr1Qkc6OP_6Oj7x1S0u9QWS5HP17rDAo=_kT8kHm_qPf5Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Lorenzo!

On Thu, Apr 10, 2014 at 06:23:35PM +0900, Lorenzo Colitti wrote:
> On Sat, Mar 29, 2014 at 10:27 AM, Wangyufen <wangyufen@huawei.com> wrote:
> > The issue raises when adding policy route, specify a particular
> > NIC as oif, the policy route did not take effect. The reason is
> > that fl6.oif is not set and route map failed. From the
> > tcp_v6_send_response function, if the binding address is linklocal,
> > fl6.oif is set, but not for global address.
> >
> > [...]
> >
> >         fl6.flowi6_proto = IPPROTO_TCP;
> > -       if (ipv6_addr_type(&fl6.daddr) & IPV6_ADDR_LINKLOCAL)
> > +       if (rt6_need_strict(&fl6.daddr) || !oif)
> >                 fl6.flowi6_oif = inet6_iif(skb);
> 
> > +       else
> > +               fl6.flowi6_oif = oif;
> 
> Shouldn't this be && !oif instead of || !oif? It seems to me that the
> logic should be:
> 
> 1. If sk->sk_bound_dev_if is set, use that interface.
> 2. Otherwise, if the connection came from a link-local address, use
> the incoming interface.
> 3. Otherwise, use whatever route the system happens to have without
> special regard to the incoming interface.
> 
> If so, then I think the code now does the wrong thing in two cases:
> 
> 1. If the SYN comes from a global address, and sk->sk_bound_dev_if is
> not set, the SYNACK is forced onto/prefers the interface the SYN came
> in on instead of just doing a routing lookup with no interface.

First a rule lookup is done on the oif (if needed). After that a address
lookup is done in the fib and only if rt6_need_strict evaluates to
true in routing code we take flowi6_oif match as mandatory (we may
evaluate sk_bound_dev_if!=0 there to make sure we really only use the
bounded interface for global addresses but keep the interface id which
is set in above code).

So we still would send out the syn packet on the path the global address
dictates in most cases (or in case of multipath routes, prefer the
incoming interface).  We differ if bound_dev is set or policy routes
are in place.

So it depends on what we give precedence and I have to agree, I would
prefer sk_bound_dev_if as we do in other output paths. I misjudged that
when I proposed the code snippet. Thanks for the heads-up.

> 2. If the SYN comes from a link-local address, and sk->sk_bound_dev_if
> is set, then the SYNACK is forced onto/prefers the incoming interface
> instead of the one specified by sk->sk_bound_dev_if.
> 
> If I am correct, then I'm happy to send out the trivial patch to fix
> this. (Against what? net? net-next when the tree reopens?)

-net tree is always open and I would welcome a patch very much.

Thank you,

  Hannes
