From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 5/6] bpf: hash: avoid to call kmalloc() in eBPF prog
Date: Wed, 16 Dec 2015 01:12:12 +0100
Message-ID: <5670AC5C.20009@iogearbox.net>
References: <1450178464-27721-1-git-send-email-tom.leiming@gmail.com> <1450178464-27721-6-git-send-email-tom.leiming@gmail.com> <5670A3C0.3080209@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Ming Lei <tom.leiming@gmail.com>, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42042 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751406AbbLPAMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 19:12:22 -0500
In-Reply-To: <5670A3C0.3080209@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/16/2015 12:35 AM, Daniel Borkmann wrote:
> On 12/15/2015 12:21 PM, Ming Lei wrote:
> ...
>> +static int htab_init_elems_allocator(struct bpf_htab *htab)
>> +{
>> +    int ret = htab_pre_alloc_elems(htab);
>> +
>> +    if (ret)
>> +        return ret;
>> +
>> +    ret = percpu_ida_init(&htab->elems_pool, htab->map.max_entries);
>> +    if (ret)
>> +        htab_destroy_elems(htab);
>> +    return ret;
>> +}
>> +
>> +static void htab_deinit_elems_allocator(struct bpf_htab *htab)
>> +{
>> +    htab_destroy_elems(htab);
>> +    percpu_ida_destroy(&htab->elems_pool);
>> +}
>> +
>> +static struct htab_elem *htab_alloc_elem(struct bpf_htab *htab)
>> +{
>> +    int tag = percpu_ida_alloc(&htab->elems_pool, TASK_RUNNING);
>> +    struct htab_elem *elem;
>> +
>> +    if (tag < 0)
>> +        return NULL;
>> +
>> +    elem = htab->elems[tag];
>> +    elem->tag = tag;
>> +    return elem;
>> +}
> ....
>> @@ -285,12 +424,8 @@ static int htab_map_update_elem(struct bpf_map *map, void *key, void *value,
>>        * search will find it before old elem
>>        */
>>       hlist_add_head_rcu_lock(&l_new->hash_node, head);
>> -    if (l_old) {
>> -        hlist_del_rcu_lock(&l_old->hash_node);
>> -        kfree_rcu(l_old, rcu);
>> -    } else {
>> -        atomic_inc(&htab->count);
>> -    }
>> +    if (l_old)
>> +        htab_free_elem_rcu(htab, l_old);
>>       bit_spin_unlock(HLIST_LOCK_BIT, (unsigned long *)&head->first);
>>       raw_local_irq_restore(flags);
>
> On a quick look, you are using the ida to keep track of elements, right? What happens
> if you have a hash-table of max_entry size 1, fill that one slot and later on try to
> replace it with a different element.
>
> Old behaviour (htab->count) doesn't increase htab count and would allow the replacement
> of that element to happen.
>
> Looks like in your case, we'd get -E2BIG from htab_alloc_elem(), no? ... as preallocated
> pool is already used up then?

Btw, if you take that further where htab elem replacements in parallel (e.g. from one
or multiple user space applications via bpf(2) and/or one or multiple eBPF programs)
could occur on the same shared map, current behavior allows setup of new elements to
happen (outside of htab lock) first and then replacement serialized via lock.

So there would probably need to be overcommit beyond max_entries pool preallocs for
such map type.
