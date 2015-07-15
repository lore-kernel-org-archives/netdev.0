From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH -next 5/6] netfilter: Per network namespace netfilter hooks.
Date: Wed, 15 Jul 2015 15:22:09 -0500
Message-ID: <87twt5i32m.fsf@x220.int.ebiederm.org>
References: <87616ppt3h.fsf@x220.int.ebiederm.org>
	<87r3pae5hn.fsf@x220.int.ebiederm.org>
	<878uansj4d.fsf_-_@x220.int.ebiederm.org>
	<87fv4vr4ed.fsf_-_@x220.int.ebiederm.org>
	<20150715190011.GA1203@salvia>
Mime-Version: 1.0
Content-Type: text/plain
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
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150715190011.GA1203@salvia> (Pablo Neira Ayuso's message of
	"Wed, 15 Jul 2015 21:00:11 +0200")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pablo Neira Ayuso <pablo@netfilter.org> writes:

> On Fri, Jul 10, 2015 at 06:15:06PM -0500, Eric W. Biederman wrote:
>> @@ -102,13 +112,35 @@ int nf_register_hook(struct nf_hook_ops *reg)
>>  #endif
>>  	return 0;
>>  }
>> -EXPORT_SYMBOL(nf_register_hook);
>> +EXPORT_SYMBOL(nf_register_net_hook);
>>  
>> -void nf_unregister_hook(struct nf_hook_ops *reg)
>> +void nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
>>  {
>> +	struct list_head *nf_hook_list;
>> +	struct nf_hook_ops *elem;
>> +
>> +	nf_hook_list = find_nf_hook_list(net, reg);
>> +	if (!nf_hook_list)
>> +		return;
>> +
>>  	mutex_lock(&nf_hook_mutex);
>> -	list_del_rcu(&reg->list);
>> +	list_for_each_entry(elem, nf_hook_list, list) {
>> +		if ((reg->hook     == elem->hook) &&
>> +		    (reg->dev      == elem->dev) &&
>> +		    (reg->owner    == elem->owner) &&
>> +		    (reg->priv     == elem->priv) &&
>> +		    (reg->pf       == elem->pf) &&
>> +		    (reg->hooknum  == elem->hooknum) &&
>> +		    (reg->priority == elem->priority)) {
>> +			list_del_rcu(&elem->list);
>> +			break;
>> +		}
>> +	}
>
> I think I found a problem with this code above.
>
> If we register two hooks from the same module using exactly the same
> tuple that identifies this, we delete the hook that we don't want, eg.
>
>         nft add table filter
>         nft add chain filter test { type filter hook input priority 0\; }
>         nft add chain filter test2 { type filter hook input priority 0\; }
>
> then, you delete 'test':
>
>         nft delete chain filter test
>
> This will delete 'test2' hook instead of 'test' as it will find this
> in first place on the list.

So we have two adjacent entries on the same chain that perform the exact
same action.  We delete one of them.

I do not see how that is noticable.  Registration order plays a small
role but especially with the priority bit we don't strongly honor
registration order.

In your example above we will distinguish between the two chains
as nf_hook_ops->priv will point the nf tables chain.   So that specific
case is at least safe.

> I think we should add a cookie field that stores the address of the
> original hook object that is passed as parameter, so we are sure we
> kill the right hook.

I don't believe that is necessary.  To the best of my knowledge for a
registration to be meaningful we must always change at least one of
those fields I am comparing.  Typically either priv or hook.

It is a real change from what we have been doing but there is a lot
of freedom in not needing to keep the original structure around.

Eric

