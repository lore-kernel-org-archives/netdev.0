From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net] netfilter: nf_conntrack: fix rt_gateway checks for
 h323
Date: Wed, 17 Oct 2012 01:55:34 +0200
Message-ID: <20121016235534.GA2805@1984>
References: <1349823647-2166-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1349823647-2166-1-git-send-email-ja@ssi.bg>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Julian,

On Wed, Oct 10, 2012 at 02:00:47AM +0300, Julian Anastasov wrote:
> 	After the change "Adjust semantics of rt->rt_gateway"
> (commit f8126f1d51) we should properly match the nexthop when
> destinations are directly connected because rt_gateway can be 0.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
> 
> 	This patch needs a closer look from the Netfilter team.
> 
> 	It restores the check as it was committed originally,
> i.e. to compare nexthops. I'm not sure what is the desired logic,
> it can depend on the following:
> 
> - two directly connected hosts (rt_gateway=0) can be from different
> subnets or not
> 
> - one party A is the gateway (rt_gateway=0), another party uses
> this gateway (rt_gateway=A)
> 
> 	May be someone that knows this code better can comment
> if the check should be different.

Your patch gets it working like before David's change in the
rt_gateway semantics.

I think the H.323 helper is doing "its best" to handle the following
call-forwarding scenario:

1) A calls B.
2) B replies to A that the alternate address is C.
3) A calls C.

Now assume that:

1) all traffic between A and B goes through the firewall.

and

2) all traffic between A and C don't go through the firewall.

If you want a picture, see section 5.2 of this site:

http://people.netfilter.org/zhaojingmin/h323_conntrack_nat_helper/#_Toc133598073

That code below is trying to detect if A and C don't go through the
firewall, just to skip the creation of one useless expectation (since
they can communicate without going through the firewall).

With the code below (function callforward_do_filter):

a) if A and C are on-link, then:
rt_nexthop(rt1, fl1.daddr) != rt_nexthop(rt2, fl2.daddr)

Bad luck, we create the expectation even if we don't need it.

b) if A and C are behind the same next hop:
rt_nexthop(rt1, fl1.daddr) == rt_nexthop(rt2, fl2.daddr)
We don't create the expectation.

c) if A is on-link and C is behind next hop:
rt_nexthop(rt1, fl1.daddr) != rt_nexthop(rt2, fl2.daddr)

Bad luck again, we create the expectation again.

This seems documented. We could make it better if we would have a way
to guess that A and C do not need to communicate through the firewall.

I'll take your patch, it leaves things just like it was before (which
was not really good).

Please, let me know if I'm missing anything. Thanks.

>  net/netfilter/nf_conntrack_h323_main.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
> index 1b30b0d..962795e 100644
> --- a/net/netfilter/nf_conntrack_h323_main.c
> +++ b/net/netfilter/nf_conntrack_h323_main.c
> @@ -753,7 +753,8 @@ static int callforward_do_filter(const union nf_inet_addr *src,
>  				   flowi4_to_flowi(&fl1), false)) {
>  			if (!afinfo->route(&init_net, (struct dst_entry **)&rt2,
>  					   flowi4_to_flowi(&fl2), false)) {
> -				if (rt1->rt_gateway == rt2->rt_gateway &&
> +				if (rt_nexthop(rt1, fl1.daddr) ==
> +				    rt_nexthop(rt2, fl2.daddr) &&
>  				    rt1->dst.dev  == rt2->dst.dev)
>  					ret = 1;
>  				dst_release(&rt2->dst);
> -- 
> 1.7.3.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
