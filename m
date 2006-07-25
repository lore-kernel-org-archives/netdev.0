From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH Round 4 2/3] Core network changes to support network event notification.
Date: Tue, 25 Jul 2006 17:39:45 +1000
Message-ID: <E1G5HW5-0005xn-00@gondolin.me.apana.org.au>
References: <20060718184907.25455.8174.stgit@dell3.ogc.int>
Cc: davem@davemloft.net, rdreier@cisco.com, openib-general@openib.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45326 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751398AbWGYHn3
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 03:43:29 -0400
To: swise@opengridcomputing.com (Steve Wise)
In-Reply-To: <20060718184907.25455.8174.stgit@dell3.ogc.int>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steve Wise <swise@opengridcomputing.com> wrote:
> 
> Routing redirect events are broadcast as a pair of rtmsgs, RTM_DELROUTE
> and RTM_NEWROUTE.

This may confuse existing rtnetlink users since you're generating an
RTM_DELROUTE message that's identical to one triggered by something
like 'ip route del'.

As you're introducing a completely new RTM_ROUTEUPD type, it might
be better to attach any information from the existing route that you
need to the ROUTEUPD message.

Actually, what was the reason you need the existing route here?

> diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
> index 5f87533..33d8a83 100644
> --- a/net/ipv4/fib_semantics.c
> +++ b/net/ipv4/fib_semantics.c
> @@ -44,6 +44,7 @@ #include <net/tcp.h>
> #include <net/sock.h>
> #include <net/ip_fib.h>
> #include <net/ip_mp_alg.h>
> +#include <net/netevent.h>
> 
> #include "fib_lookup.h"
> 
> @@ -279,6 +280,14 @@ void rtmsg_fib(int event, u32 key, struc
>        struct sk_buff *skb;
>        u32 pid = req ? req->pid : n->nlmsg_pid;
>        int size = NLMSG_SPACE(sizeof(struct rtmsg)+256);
> +       struct netevent_route_info nri;
> +       int netevent;
> +
> +       nri.family = AF_INET;
> +       nri.data = &fa->fa_info;
> +       netevent = event == RTM_NEWROUTE ? NETEVENT_ROUTE_ADD 
> +                                        : NETEVENT_ROUTE_DEL;
> +       call_netevent_notifiers(netevent, &nri);

Hmm, this is broken.  These route events are meaningless without the
corresponding IP rule events.  Are you sure you really want to make
your hardware/driver grok multiple routing tables?

Perhaps you should simply stick to dst entries and flush all your
tables when the routes are changed.  This is what the Linux IP stack
does.

> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 2dc6dbb..18879e6 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1117,6 +1120,52 @@ static void rt_del(unsigned hash, struct
>        spin_unlock_bh(rt_hash_lock_addr(hash));
> }
> 
> +static void rtm_redirect(struct rtable *old, struct rtable *new)
> +{
> +       struct netevent_redirect netevent;
> +       struct sk_buff *skb;
> +       int err;
> +
> +       netevent.old = &old->u.dst;
> +       netevent.new = &new->u.dst;
> +
> +       /* notify netevent subscribers */
> +       call_netevent_notifiers(NETEVENT_REDIRECT, &netevent);
> +
> +       /* Post NETLINK messages:  RTM_DELROUTE for old route, 
> +                                  RTM_NEWROUTE for new route */
> +       skb = alloc_skb(NLMSG_GOODSIZE, GFP_ATOMIC);

Please use a better size estimate rather than NLMSG_GOODSIZE here since
you're doing GFP_ATOMIC.

> @@ -1442,6 +1493,32 @@ unsigned short ip_rt_frag_needed(struct 
>        return est_mtu ? : new_mtu;
> }
> 
> +static void rtm_pmtu_update(struct rtable *rt)
> +{
> +       struct sk_buff *skb;
> +       int err;
> +
> +       call_netevent_notifiers(NETEVENT_PMTU_UPDATE, &rt->u.dst);
> +
> +       skb = alloc_skb(NLMSG_GOODSIZE, GFP_ATOMIC);

Ditto.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
