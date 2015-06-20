From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net] netfilter: nf_qeueue: Drop queue entries on nf_unregister_hook
Date: Sat, 20 Jun 2015 09:03:12 -0500
Message-ID: <871th6bhpb.fsf@x220.int.ebiederm.org>
References: <878ubffron.fsf@x220.int.ebiederm.org>
	<871th7frlg.fsf@x220.int.ebiederm.org> <20150620105738.GA3439@salvia>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:37168 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753017AbbFTOIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jun 2015 10:08:34 -0400
In-Reply-To: <20150620105738.GA3439@salvia> (Pablo Neira Ayuso's message of
	"Sat, 20 Jun 2015 12:57:38 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Neira Ayuso <pablo@netfilter.org> writes:

> On Fri, Jun 19, 2015 at 02:03:39PM -0500, Eric W. Biederman wrote:
>> 
>> Add code to nf_unregister_hook to flush the nf_queue when a hook is
>> unregistered.  This guarantees that the pointer that the nf_queue code
>> retains into the nf_hook list will remain valid while a packet is
>> queued.
>
> I think the real problem is that struct nf_queue_entry holds a pointer
> to struct nf_hook_ops, which will be gone after removal.

Yes that is what I meant, when I was talking about the pointer that
the nf_queue code holds into the nf_hook list.  That list is threaded
through nf_hook_ops, and is used to retain the place in the nf_hook list
for when the packet returns through nf_reinject.

> So you
> uncovered a long standing problem that will amplify by when pernet
> hooks are in place.

Yes.  This will apply to more than just nftables when the pernet hooks
are in place.  The try_module_get prevents this for everything except
for nftables today.  So in practice this problem has existed since the
merge of nftables.  The try_module_get shows this problem has existed
in some form longer than git.

> Regarding the pointer to nf_hook_list, now that new netdevice variant
> doesn't support nf_queue yet, so that nf_hook_list will be always
> valid since it will point to the global nf_hooks in the core.

>
>> I tested what would happen if we do not flush queued packets and was
>> trivially able to obtain the oops below.  All that was required was
>> to stop the nf_queue listening process, to delete all of the nf_tables,
>> and to awaken the nf_queue listening process.
> [...]
>
> Please, route netfilter patches through the netfilter trees, ie. nf
> and nf-next.

Whatever works. I just see this as a bug in the networking stack that
needs to be fixed.  I don't care who I send it to as long as Linus gets
it.

>> Cc: stable@vger.kernel.org
>
> I guess this is a leftover since there is no Cc to stable. Anyway,
> we have to wait until this hits master before we ask for -stable
> inclusion.

This is a marker that this should be backported to stable, and the
typicall way this is remembered outside of the network trees.  The stable
folks grep the git log for Cc: stable...  

> More comments below. Thanks for this fix BTW.
>
>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>> ---
>> 
>> Apologies for the duplicate send but I forgot to include the appropriate
>> mailing lists.
>> 
>>  include/net/netfilter/nf_queue.h     |  2 ++
>>  net/netfilter/core.c                 |  1 +
>>  net/netfilter/nf_internals.h         |  1 +
>>  net/netfilter/nf_queue.c             | 17 +++++++++++++++++
>>  net/netfilter/nfnetlink_queue_core.c | 24 +++++++++++++++++++++++-
>>  5 files changed, 44 insertions(+), 1 deletion(-)
>> 
>> diff --git a/include/net/netfilter/nf_queue.h b/include/net/netfilter/nf_queue.h
>> index d81d584157e1..e8635854a55b 100644
>> --- a/include/net/netfilter/nf_queue.h
>> +++ b/include/net/netfilter/nf_queue.h
>> @@ -24,6 +24,8 @@ struct nf_queue_entry {
>>  struct nf_queue_handler {
>>  	int			(*outfn)(struct nf_queue_entry *entry,
>>  					 unsigned int queuenum);
>> +	void			(*nf_hook_drop)(struct net *net,
>> +						struct nf_hook_ops *ops);
>>  };
>>  
>>  void nf_register_queue_handler(const struct nf_queue_handler *qh);
>> diff --git a/net/netfilter/core.c b/net/netfilter/core.c
>> index 653e32eac08c..a0e54974e2c9 100644
>> --- a/net/netfilter/core.c
>> +++ b/net/netfilter/core.c
>> @@ -118,6 +118,7 @@ void nf_unregister_hook(struct nf_hook_ops *reg)
>>  	static_key_slow_dec(&nf_hooks_needed[reg->pf][reg->hooknum]);
>>  #endif
>>  	synchronize_net();
>> +	nf_queue_nf_hook_drop(reg);
>>  }
>>  EXPORT_SYMBOL(nf_unregister_hook);
>>  
>> diff --git a/net/netfilter/nf_internals.h b/net/netfilter/nf_internals.h
>> index ea7f36784b3d..399210693c2a 100644
>> --- a/net/netfilter/nf_internals.h
>> +++ b/net/netfilter/nf_internals.h
>> @@ -19,6 +19,7 @@ unsigned int nf_iterate(struct list_head *head, struct sk_buff *skb,
>>  /* nf_queue.c */
>>  int nf_queue(struct sk_buff *skb, struct nf_hook_ops *elem,
>>  	     struct nf_hook_state *state, unsigned int queuenum);
>> +void nf_queue_nf_hook_drop(struct nf_hook_ops *ops);
>>  int __init netfilter_queue_init(void);
>>  
>>  /* nf_log.c */
>> diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
>> index 2e88032cd5ad..cd60d397fe05 100644
>> --- a/net/netfilter/nf_queue.c
>> +++ b/net/netfilter/nf_queue.c
>> @@ -105,6 +105,23 @@ bool nf_queue_entry_get_refs(struct nf_queue_entry *entry)
>>  }
>>  EXPORT_SYMBOL_GPL(nf_queue_entry_get_refs);
>>  
>> +void nf_queue_nf_hook_drop(struct nf_hook_ops *ops)
>
> I'd suggest you rename all these 'nf_hook_drop' to 'flush'.

The functions in nfnetfilter_queue_core.c are also named drop,
and I am not in a mood to change the convention.

>> +{
>> +	const struct nf_queue_handler *qh;
>> +	struct net *net;
>> +
>> +	rtnl_lock();
>
> Why rtnl_lock() here?

Because we need a race free way to visit all of the network namespaces.
I would perform the for_each_net on the other side of nf_hook_drop but
the rcu locking would not allow that.

>> +	rcu_read_lock();
>> +	qh = rcu_dereference(queue_handler);
>> +	if (qh) {
>> +		for_each_net(net) {
>> +			qh->nf_hook_drop(net, ops);
>> +		}
>> +	}
>> +	rcu_read_unlock();
>> +	rtnl_unlock();
>> +}
>> +
>>  /*
>>   * Any packet that leaves via this function must come back
>>   * through nf_reinject().
