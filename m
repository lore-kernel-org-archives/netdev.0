From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: conntrack: fix clash resolution in nat
Date: Thu, 29 Jun 2017 18:45:34 +0200
Message-ID: <20170629164534.GA7271@salvia>
References: <1497427883-3771-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1497427883-3771-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Wed, Jun 14, 2017 at 04:11:23PM +0800, Haishuang Yan wrote:
> In our openstack environment, slow dns lookup for hostname when
> parallel dns requests for IPv4 and IPv6 addresses from VM, the
> second IPv6 request(AAAA record) is dropped on its way in compute
> node.
> 
> We found many similar related links:
> https://bbs.archlinux.org/viewtopic.php?id=75770
> http://www.spinics.net/lists/netfilter-devel/msg15860.html
> https://www.spinics.net/lists/netfilter-devel/msg37565.html
> 
> After the commit 71d8c47fc653 ("netfilter: conntrack: introduce clash
> resolution on insertion race") can fix packet drop, the second IPv6
> request packet would be forwarded by compute node, but the udp source
> port is bogus, start from 1024:
> 14:52:10.868485 IP 10.136.5.132.55785 > 10.136.5.1.domain: 3957+ A?
> www.baidu.com. (31)
> 14:52:10.868544 IP 10.136.5.132.1024 > 10.136.5.1.domain: 13826+ AAAA?
> www.baidu.com. (31)
> 
> And after the commit 590b52e10d41 ("netfilter: conntrack: skip clash
> resolution if nat is in place") , it exclude nat situation, but the
> packet drops issue come back again.
> 
> This patch revert the last commit. If l4proto allow clash but the tuple is
> used by the conntrack that wins race, the original tuple can be reused.
> 
> Fixes: 590b52e10d41 ("netfilter: conntrack: skip clash resolution if 25
> nat is in place")
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> ---
>  net/netfilter/nf_conntrack_core.c | 1 -
>  net/netfilter/nf_nat_core.c       | 4 +++-
>  2 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> index e847dba..7e16518 100644
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -699,7 +699,6 @@ static int nf_ct_resolve_clash(struct net *net, struct sk_buff *skb,
>  
>  	l4proto = __nf_ct_l4proto_find(nf_ct_l3num(ct), nf_ct_protonum(ct));
>  	if (l4proto->allow_clash &&
> -	    ((ct->status & IPS_NAT_DONE_MASK) == 0) &&
>  	    !nf_ct_is_dying(ct) &&
>  	    atomic_inc_not_zero(&ct->ct_general.use)) {
>  		enum ip_conntrack_info oldinfo;
> diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
> index 6c72922..9edfca2 100644
> --- a/net/netfilter/nf_nat_core.c
> +++ b/net/netfilter/nf_nat_core.c
> @@ -328,6 +328,7 @@ static int nf_nat_bysource_cmp(struct rhashtable_compare_arg *arg,
>  	const struct nf_conntrack_zone *zone;
>  	const struct nf_nat_l3proto *l3proto;
>  	const struct nf_nat_l4proto *l4proto;
> +	const struct nf_conntrack_l4proto *ct_l4proto;
>  	struct net *net = nf_ct_net(ct);
>  
>  	zone = nf_ct_zone(ct);
> @@ -336,6 +337,7 @@ static int nf_nat_bysource_cmp(struct rhashtable_compare_arg *arg,
>  	l3proto = __nf_nat_l3proto_find(orig_tuple->src.l3num);
>  	l4proto = __nf_nat_l4proto_find(orig_tuple->src.l3num,
>  					orig_tuple->dst.protonum);
> +	ct_l4proto = __nf_ct_l4proto_find(nf_ct_l3num(ct), nf_ct_protonum(ct));
>  
>  	/* 1) If this srcip/proto/src-proto-part is currently mapped,
>  	 * and that same mapping gives a unique tuple within the given
> @@ -349,7 +351,7 @@ static int nf_nat_bysource_cmp(struct rhashtable_compare_arg *arg,
>  	    !(range->flags & NF_NAT_RANGE_PROTO_RANDOM_ALL)) {
>  		/* try the original tuple first */
>  		if (in_range(l3proto, l4proto, orig_tuple, range)) {
> -			if (!nf_nat_used_tuple(orig_tuple, ct)) {
> +			if (!nf_nat_used_tuple(orig_tuple, ct) || ct_l4proto->allow_clash) {


Hm, this is defeating clash resolution logic entirely. I mean, with
this this would not call nf_nat_l4proto_unique_tuple() so we get a
unique tuple.

My concern with this is that, although this is fixing the issue for
you, I suspect this is breaking SNAT/masquerade in case we get two
clients in the LAN if both flow have a tuple that matches this:

        *, srcport, dst-IP, dst-port

The problem that we have with this is a race condition, the problem is
that the second packet doesn't find a confirmed conntrack in the
hashes, so it gets its own one and NAT makes sure such tuple is
unique.

So far, the only way I see to fix this is to postpone packet mangling
that NAT performs after the clash resolution code in
nf_conntrack_confirm(). But that changes the behaviour in a way that
would break matching rules that assume the existing behaviour, that
is, nf_nat_setup() mangles the packet.

>  				*tuple = *orig_tuple;
>  				goto out;
>  			}
> -- 
> 1.8.3.1
> 
> 
> 
