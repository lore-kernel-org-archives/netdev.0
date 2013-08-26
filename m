From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2 nf-next] netfilter: conntrack: remove the central
 spinlock
Date: Tue, 27 Aug 2013 00:28:45 +0200
Message-ID: <20130826222844.GA19478@localhost>
References: <1368068665.13473.81.camel@edumazet-glaptop>
 <1369244868.3301.343.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Patrick McHardy <kaber@trash.net>,
	Jesper Dangaard Brouer <jbrouer@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1369244868.3301.343.camel@edumazet-glaptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

Several comments on the expectation side.

On Wed, May 22, 2013 at 10:47:48AM -0700, Eric Dumazet wrote:
[...]
>diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
>index 0283bae..c0823b9 100644
>--- a/net/netfilter/nf_conntrack_core.c
>+++ b/net/netfilter/nf_conntrack_core.c
[...]
> @@ -196,6 +247,47 @@ clean_from_lists(struct nf_conn *ct)
>        nf_ct_remove_expectations(ct);

With this patch, we hold the conntrack lock when calling
clean_from_lists but I think that's not enough.
nf_conntrack_expect_lock spinlock protection is missing here.

> }
[...]
> @@ -820,39 +930,41 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
>  				 ecache ? ecache->expmask : 0,
>  			     GFP_ATOMIC);
>  
> -	spin_lock_bh(&nf_conntrack_lock);
> -	exp = nf_ct_find_expectation(net, zone, tuple);
> -	if (exp) {
> -		pr_debug("conntrack: expectation arrives ct=%p exp=%p\n",
> -			 ct, exp);
> -		/* Welcome, Mr. Bond.  We've been expecting you... */
> -		__set_bit(IPS_EXPECTED_BIT, &ct->status);
> -		ct->master = exp->master;
> -		if (exp->helper) {
> -			help = nf_ct_helper_ext_add(ct, exp->helper,
> -						    GFP_ATOMIC);
> -			if (help)
> -				rcu_assign_pointer(help->helper, exp->helper);
> -		}
> +	local_bh_disable();
> +	if (net->ct.expect_count) {
> +		spin_lock(&nf_conntrack_expect_lock);

I also think we have a possible race for expected conntracks. The
problem is that expectations don't bump the refcount of the master
conntrack.

> +		exp = nf_ct_find_expectation(net, zone, tuple);

... Now that we have independent locks for conntrack and expectation
lists, a packet may match an expectation while another CPU is walking
through the nf_ct_delete_from_lists bits using exp->master as input.

> +		if (exp) {
> +			pr_debug("conntrack: expectation arrives ct=%p exp=%p\n",
> +				 ct, exp);
> +			/* Welcome, Mr. Bond.  We've been expecting you... */
> +			__set_bit(IPS_EXPECTED_BIT, &ct->status);
> +			ct->master = exp->master;

Then, ct->master points to the (vanished) conntrack.

> +			if (exp->helper) {
> +				help = nf_ct_helper_ext_add(ct, exp->helper,
> +							    GFP_ATOMIC);
> +				if (help)
> +					rcu_assign_pointer(help->helper, exp->helper);
> +			}
>  
>  #ifdef CONFIG_NF_CONNTRACK_MARK
> -		ct->mark = exp->master->mark;
> +			ct->mark = exp->master->mark;
>  #endif
>  #ifdef CONFIG_NF_CONNTRACK_SECMARK
> -		ct->secmark = exp->master->secmark;
> +			ct->secmark = exp->master->secmark;
>  #endif
> -		nf_conntrack_get(&ct->master->ct_general);
> -		NF_CT_STAT_INC(net, expect_new);
> -	} else {
> +			nf_conntrack_get(&ct->master->ct_general);

So this needs to adjust the refcounting logic for expectations, to
bump it earlier, during the expectation insertion.

Regards.
