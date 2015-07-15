From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH -next 5/6] netfilter: Per network namespace netfilter
 hooks.
Date: Wed, 15 Jul 2015 21:00:11 +0200
Message-ID: <20150715190011.GA1203@salvia>
References: <87616ppt3h.fsf@x220.int.ebiederm.org>
 <87r3pae5hn.fsf@x220.int.ebiederm.org>
 <878uansj4d.fsf_-_@x220.int.ebiederm.org>
 <87fv4vr4ed.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Juanjo Ciarlante <jjciarla@raiz.uncu.edu.ar>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87fv4vr4ed.fsf_-_@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 10, 2015 at 06:15:06PM -0500, Eric W. Biederman wrote:
> @@ -102,13 +112,35 @@ int nf_register_hook(struct nf_hook_ops *reg)
>  #endif
>  	return 0;
>  }
> -EXPORT_SYMBOL(nf_register_hook);
> +EXPORT_SYMBOL(nf_register_net_hook);
>  
> -void nf_unregister_hook(struct nf_hook_ops *reg)
> +void nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
>  {
> +	struct list_head *nf_hook_list;
> +	struct nf_hook_ops *elem;
> +
> +	nf_hook_list = find_nf_hook_list(net, reg);
> +	if (!nf_hook_list)
> +		return;
> +
>  	mutex_lock(&nf_hook_mutex);
> -	list_del_rcu(&reg->list);
> +	list_for_each_entry(elem, nf_hook_list, list) {
> +		if ((reg->hook     == elem->hook) &&
> +		    (reg->dev      == elem->dev) &&
> +		    (reg->owner    == elem->owner) &&
> +		    (reg->priv     == elem->priv) &&
> +		    (reg->pf       == elem->pf) &&
> +		    (reg->hooknum  == elem->hooknum) &&
> +		    (reg->priority == elem->priority)) {
> +			list_del_rcu(&elem->list);
> +			break;
> +		}
> +	}

I think I found a problem with this code above.

If we register two hooks from the same module using exactly the same
tuple that identifies this, we delete the hook that we don't want, eg.

        nft add table filter
        nft add chain filter test { type filter hook input priority 0\; }
        nft add chain filter test2 { type filter hook input priority 0\; }

then, you delete 'test':

        nft delete chain filter test

This will delete 'test2' hook instead of 'test' as it will find this
in first place on the list.

I think we should add a cookie field that stores the address of the
original hook object that is passed as parameter, so we are sure we
kill the right hook.
