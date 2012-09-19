From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Oops with latest (netfilter) nf-next tree, when unloading
 iptable_nat
Date: Wed, 19 Sep 2012 21:14:52 +0200
Message-ID: <1348082092.2761.142.camel@localhost>
References: <1347357081.3928.32.camel@localhost>
	 <20120912213627.GJ14750@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@gnumonks.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, yongjun_wei@trendmicro.com.cn,
	kaber@trash.net
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120912213627.GJ14750@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-09-12 at 23:36 +0200, Florian Westphal wrote:

[...cut...]

> On module removal nf_nat_ipv4 calls nf_iterate_cleanup which invokes
> nf_nat_proto_clean() for each conntrack.  That will then call
> hlist_del_rcu(&nat->bysource) using eachs conntracks nat ext area.
> 
> Problem is that nf_nat_proto_clean() is called multiple times for the same
> conntrack:
> a) nf_ct_iterate_cleanup() returns each ct twice (origin, reply)
> b) we call it both for l3 and for l4 protocol ids
> 
> We barf in hlist_del_rcu the 2nd time because ->pprev is poisoned.
> 
> This was introduced with the ipv6 nat patches.
> 
> --- a/net/netfilter/nf_nat_core.c
> +++ b/net/netfilter/nf_nat_core.c
> @@ -487,7 +487,7 @@ static int nf_nat_proto_clean(struct nf_conn *i, void *data)
>  
>         if (clean->hash) {
>                 spin_lock_bh(&nf_nat_lock);
> -               hlist_del_rcu(&nat->bysource);
> +               hlist_del_init_rcu(&nat->bysource);
>                 spin_unlock_bh(&nf_nat_lock);
>         } else {
>
> Would probably avoid it.  I guess it would be nicer to only call this
> once for each ct.

Florian's patch fixes the Oops :-)



