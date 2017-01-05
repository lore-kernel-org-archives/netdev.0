From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v1 1/2] bpf: add a longest prefix match trie map implementation
Date: Thu, 05 Jan 2017 17:25:10 +0100
Message-ID: <586E7366.1010708@iogearbox.net>
References: <20161229172855.14910-1-daniel@zonque.org> <20161229172855.14910-2-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dh.herrmann@gmail.com, netdev@vger.kernel.org, davem@davemloft.net
To: Daniel Mack <daniel@zonque.org>, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58068 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031348AbdAEQZQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 11:25:16 -0500
In-Reply-To: <20161229172855.14910-2-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/29/2016 06:28 PM, Daniel Mack wrote:
> This trie implements a longest prefix match algorithm that can be used
> to match IP addresses to a stored set of ranges.
>
> Internally, data is stored in an unbalanced trie of nodes that has a
> maximum height of n, where n is the prefixlen the trie was created
> with.
>
> Tries may be created with prefix lengths that are multiples of 8, in
> the range from 8 to 2048. The key used for lookup and update operations
> is a struct bpf_lpm_trie_key, and the value is a uint64_t.
>
> The code carries more information about the internal implementation.
>
> Signed-off-by: Daniel Mack <daniel@zonque.org>
> Reviewed-by: David Herrmann <dh.herrmann@gmail.com>

Thanks for working on it, and sorry for late reply. In addition to
Alexei's earlier comments on the cover letter, a few comments inline:

[...]
> diff --git a/kernel/bpf/lpm_trie.c b/kernel/bpf/lpm_trie.c
> new file mode 100644
> index 0000000..8b6a61d
> --- /dev/null
> +++ b/kernel/bpf/lpm_trie.c
> @@ -0,0 +1,468 @@
> +/*
> + * Longest prefix match list implementation
> + *
> + * Copyright (c) 2016 Daniel Mack
> + * Copyright (c) 2016 David Herrmann
> + *
> + * This file is subject to the terms and conditions of version 2 of the GNU
> + * General Public License.  See the file COPYING in the main directory of the
> + * Linux distribution for more details.
> + */
> +
> +#include <linux/bpf.h>
> +#include <linux/err.h>
> +#include <linux/slab.h>
> +#include <linux/spinlock.h>
> +#include <linux/vmalloc.h>
> +#include <net/ipv6.h>
> +
> +/* Intermediate node */
> +#define LPM_TREE_NODE_FLAG_IM BIT(0)
> +
> +struct lpm_trie_node;
> +
> +struct lpm_trie_node {
> +	struct rcu_head rcu;
> +	struct lpm_trie_node __rcu	*child[2];
> +	u32				prefixlen;
> +	u32				flags;
> +	u64				value;
> +	u8				data[0];
> +};
> +
> +struct lpm_trie {
> +	struct bpf_map			map;
> +	struct lpm_trie_node __rcu	*root;
> +	size_t				n_entries;
> +	size_t				max_prefixlen;
> +	size_t				data_size;
> +	spinlock_t			lock;
> +};
> +
[...]
> +
> +static inline int extract_bit(const u8 *data, size_t index)
> +{
> +	return !!(data[index / 8] & (1 << (7 - (index % 8))));
> +}
> +
[...]
> +
> +static struct lpm_trie_node *lpm_trie_node_alloc(size_t data_size)
> +{
> +	return kmalloc(sizeof(struct lpm_trie_node) + data_size,
> +		       GFP_ATOMIC | __GFP_NOWARN);
> +}
> +
> +/* Called from syscall or from eBPF program */
> +static int trie_update_elem(struct bpf_map *map,
> +			    void *_key, void *value, u64 flags)
> +{
> +	struct lpm_trie *trie = container_of(map, struct lpm_trie, map);
> +	struct lpm_trie_node *node, *im_node, *new_node = NULL;
> +	struct lpm_trie_node __rcu **slot;
> +	struct bpf_lpm_trie_key *key = _key;
> +	unsigned int next_bit;
> +	size_t matchlen = 0;
> +	int ret = 0;

We should guard for future map flags here:

	if (unlikely(flags > BPF_EXIST))
		return -EINVAL;

And further below we'd need to check for BPF_{NO,}EXIST when replacing
resp. adding the node?

> +	if (key->prefixlen > trie->max_prefixlen)
> +		return -EINVAL;
> +
> +	spin_lock(&trie->lock);

That spin lock would need to be converted to a raw lock, see commit
ac00881f9221 ("bpf: convert hashtab lock to raw lock"). The comment
in htab also mentions that bpf_map_update_elem() can be called in
irq context (I assume as a map from tracing side?), so we'd need to
use the *_irqsave variants here as well.

> +	/* Allocate and fill a new node */
> +
> +	if (trie->n_entries == trie->map.max_entries) {
> +		ret = -ENOSPC;
> +		goto out;
> +	}
> +
> +	new_node = lpm_trie_node_alloc(trie->data_size);
> +	if (!new_node) {
> +		ret = -ENOMEM;
> +		goto out;
> +	}
> +
> +	trie->n_entries++;
> +	new_node->value = *(u64 *) value;
> +	new_node->prefixlen = key->prefixlen;
> +	new_node->flags = 0;
> +	new_node->child[0] = NULL;
> +	new_node->child[1] = NULL;

Should this be ...

RCU_INIT_POINTER(new_node->child[0], NULL);
RCU_INIT_POINTER(new_node->child[1], NULL);

> +	memcpy(new_node->data, key->data, trie->data_size);
> +
> +	/*
> +	 * Now find a slot to attach the new node. To do that, walk the tree
> +	 * from the root match as many bits as possible for each node until we
> +	 * either find an empty slot or a slot that needs to be replaced by an
> +	 * intermediate node.
> +	 */
> +	slot = &trie->root;
> +
> +	while ((node = rcu_dereference_protected(*slot,
> +					lockdep_is_held(&trie->lock)))) {
> +		matchlen = longest_prefix_match(trie, node, key);
> +
> +		if (node->prefixlen != matchlen ||
> +		    node->prefixlen == key->prefixlen ||
> +		    node->prefixlen == trie->max_prefixlen)
> +			break;
> +
> +		next_bit = extract_bit(key->data, node->prefixlen);
> +		slot = &node->child[next_bit];
> +	}
> +
> +	/*
> +	 * If the slot is empty (a free child pointer or an empty root),
> +	 * simply assign the @new_node to that slot and be done.
> +	 */
> +	if (!node) {
> +		rcu_assign_pointer(*slot, new_node);
> +		goto out;
> +	}
> +
> +	/*
> +	 * If the slot we picked already exists, replace it with @new_node
> +	 * which already has the correct data array and value set.
> +	 */
> +	if (node->prefixlen == matchlen) {
> +		new_node->child[0] = node->child[0];
> +		new_node->child[1] = node->child[1];
> +
> +		if (!(node->flags & LPM_TREE_NODE_FLAG_IM))
> +			trie->n_entries--;
> +
> +		rcu_assign_pointer(*slot, new_node);
> +		kfree_rcu(node, rcu);
> +
> +		goto out;
> +	}
> +
> +	/*
> +	 * If the new node matches the prefix completely, it must be an
> +	 * inserted as an ancestor. Simply insert it between @node and @*slot.
> +	 */
> +	if (matchlen == key->prefixlen) {
> +		next_bit = extract_bit(node->data, matchlen);
> +		rcu_assign_pointer(new_node->child[next_bit], node);
> +		rcu_assign_pointer(*slot, new_node);
> +		goto out;
> +	}
> +
> +	im_node = lpm_trie_node_alloc(trie->data_size);
> +	if (!im_node) {
> +		ret = -ENOMEM;
> +		goto out;
> +	}
> +
> +	im_node->prefixlen = matchlen;
> +	im_node->flags |= LPM_TREE_NODE_FLAG_IM;
> +	memcpy(im_node->data, node->data, trie->data_size);
> +
> +	/* Now determine which child to install in which slot */
> +	if (extract_bit(key->data, matchlen)) {
> +		rcu_assign_pointer(im_node->child[0], node);
> +		rcu_assign_pointer(im_node->child[1], new_node);
> +	} else {
> +		rcu_assign_pointer(im_node->child[0], new_node);
> +		rcu_assign_pointer(im_node->child[1], node);
> +	}
> +
> +	/* Finally, assign the intermediate node to the determined spot */
> +	rcu_assign_pointer(*slot, im_node);
> +
> +out:
> +	if (ret) {
> +		if (new_node)
> +			trie->n_entries--;
> +
> +		kfree(new_node);
> +		kfree(im_node);
> +	}
> +
> +	spin_unlock(&trie->lock);
> +
> +	return ret;
> +}
> +
> +static struct bpf_map *trie_alloc(union bpf_attr *attr)
> +{
> +	struct lpm_trie *trie;
> +
> +	/* check sanity of attributes */
> +	if (attr->max_entries == 0 || attr->map_flags ||
> +	    attr->key_size < sizeof(struct bpf_lpm_trie_key) + 1   ||
> +	    attr->key_size > sizeof(struct bpf_lpm_trie_key) + 256 ||
> +	    attr->value_size != sizeof(u64))
> +		return ERR_PTR(-EINVAL);

The correct attr->map_flags test here would need to be ...

   attr->map_flags != BPF_F_NO_PREALLOC

... since in this case we don't have any prealloc pool, and
should that come one day that test could be relaxed again.

> +	trie = kzalloc(sizeof(*trie), GFP_USER | __GFP_NOWARN);
> +	if (!trie)
> +		return NULL;
> +
> +	/* copy mandatory map attributes */
> +	trie->map.map_type = attr->map_type;
> +	trie->map.key_size = attr->key_size;
> +	trie->map.value_size = attr->value_size;
> +	trie->map.max_entries = attr->max_entries;

You also need to fill in trie->map.pages as that is eventually
used to charge memory against in bpf_map_charge_memlock(), right
now that would remain as 0 meaning the map is not accounted for.

> +	trie->data_size = attr->key_size -
> +				offsetof(struct bpf_lpm_trie_key, data);
> +	trie->max_prefixlen = trie->data_size * 8;
> +
> +	spin_lock_init(&trie->lock);
> +
> +	return &trie->map;
> +}
> +
> +static void trie_free(struct bpf_map *map)
> +{
> +	struct lpm_trie_node __rcu **slot;
> +	struct lpm_trie_node *node;
> +	struct lpm_trie *trie =
> +		container_of(map, struct lpm_trie, map);
> +
> +	spin_lock(&trie->lock);
> +
> +	/*
> +	 * Always start at the root and walk down to a node that has no
> +	 * children. Then free that node, nullify its pointer in the parent,
> +	 * then start over.
> +	 */
> +
> +	for (;;) {
> +		slot = &trie->root;
> +
> +		for (;;) {
> +			node = rcu_dereference_protected(*slot,
> +					lockdep_is_held(&trie->lock));
> +			if (!node)
> +				goto out;
> +
> +			if (node->child[0]) {

rcu_access_pointer(node->child[0]) (at least to keep sparse happy?)

> +				slot = &node->child[0];
> +				continue;
> +			}
> +
> +			if (node->child[1]) {

Here too?

> +				slot = &node->child[1];
> +				continue;
> +			}
> +
> +			kfree(node);
> +			rcu_assign_pointer(*slot, NULL);

RCU_INIT_POINTER(*slot, NULL)

> +			break;
> +		}
> +	}
> +
> +out:
> +	spin_unlock(&trie->lock);
> +}
> +
> +static const struct bpf_map_ops trie_ops = {
> +	.map_alloc = trie_alloc,
> +	.map_free = trie_free,
> +	.map_lookup_elem = trie_lookup_elem,
> +	.map_update_elem = trie_update_elem,

delete ops still planned to add?

> +};
> +
> +static struct bpf_map_type_list trie_type __read_mostly = {
> +	.ops = &trie_ops,
> +	.type = BPF_MAP_TYPE_LPM_TRIE,
> +};
> +
> +static int __init register_trie_map(void)
> +{
> +	bpf_register_map_type(&trie_type);
> +	return 0;
> +}
> +late_initcall(register_trie_map);

Thanks,
Daniel
