From: Daniel Mack <daniel@zonque.org>
Subject: Re: [PATCH v1 1/2] bpf: add a longest prefix match trie map
 implementation
Date: Thu, 5 Jan 2017 21:04:16 +0100
Message-ID: <91fbf150-4e97-7400-90cf-dbe7ea3e6597@zonque.org>
References: <20161229172855.14910-1-daniel@zonque.org>
 <20161229172855.14910-2-daniel@zonque.org> <586E7366.1010708@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: dh.herrmann@gmail.com, netdev@vger.kernel.org, davem@davemloft.net
To: Daniel Borkmann <daniel@iogearbox.net>, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:34906 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1033131AbdAEUET (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Jan 2017 15:04:19 -0500
In-Reply-To: <586E7366.1010708@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

Thanks for your feedback! I agree on all points. Two questions below.

On 01/05/2017 05:25 PM, Daniel Borkmann wrote:
> On 12/29/2016 06:28 PM, Daniel Mack wrote:

>> diff --git a/kernel/bpf/lpm_trie.c b/kernel/bpf/lpm_trie.c
>> new file mode 100644
>> index 0000000..8b6a61d
>> --- /dev/null
>> +++ b/kernel/bpf/lpm_trie.c

[..]

>> +static struct bpf_map *trie_alloc(union bpf_attr *attr)
>> +{
>> +	struct lpm_trie *trie;
>> +
>> +	/* check sanity of attributes */
>> +	if (attr->max_entries == 0 || attr->map_flags ||
>> +	    attr->key_size < sizeof(struct bpf_lpm_trie_key) + 1   ||
>> +	    attr->key_size > sizeof(struct bpf_lpm_trie_key) + 256 ||
>> +	    attr->value_size != sizeof(u64))
>> +		return ERR_PTR(-EINVAL);
> 
> The correct attr->map_flags test here would need to be ...
> 
>    attr->map_flags != BPF_F_NO_PREALLOC
> 
> ... since in this case we don't have any prealloc pool, and
> should that come one day that test could be relaxed again.
> 
>> +	trie = kzalloc(sizeof(*trie), GFP_USER | __GFP_NOWARN);
>> +	if (!trie)
>> +		return NULL;
>> +
>> +	/* copy mandatory map attributes */
>> +	trie->map.map_type = attr->map_type;
>> +	trie->map.key_size = attr->key_size;
>> +	trie->map.value_size = attr->value_size;
>> +	trie->map.max_entries = attr->max_entries;
> 
> You also need to fill in trie->map.pages as that is eventually
> used to charge memory against in bpf_map_charge_memlock(), right
> now that would remain as 0 meaning the map is not accounted for.

Hmm, okay. The nodes are, however, allocated dynamically at runtime in
this case. That means that we have trie->map.pages on each allocation,
right?

>> +static void trie_free(struct bpf_map *map)
>> +{
>> +	struct lpm_trie_node __rcu **slot;
>> +	struct lpm_trie_node *node;
>> +	struct lpm_trie *trie =
>> +		container_of(map, struct lpm_trie, map);
>> +
>> +	spin_lock(&trie->lock);
>> +
>> +	/*
>> +	 * Always start at the root and walk down to a node that has no
>> +	 * children. Then free that node, nullify its pointer in the parent,
>> +	 * then start over.
>> +	 */
>> +
>> +	for (;;) {
>> +		slot = &trie->root;
>> +
>> +		for (;;) {
>> +			node = rcu_dereference_protected(*slot,
>> +					lockdep_is_held(&trie->lock));
>> +			if (!node)
>> +				goto out;
>> +
>> +			if (node->child[0]) {
> 
> rcu_access_pointer(node->child[0]) (at least to keep sparse happy?)

Done, but sparse does not actually complain here.



Thanks,
Daniel
