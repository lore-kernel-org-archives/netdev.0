From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v4 1/3] bpf: add a longest prefix match trie map implementation
Date: Mon, 23 Jan 2017 17:39:42 +0100
Message-ID: <588631CE.9080402@iogearbox.net>
References: <20170121162613.4159-1-daniel@zonque.org> <20170121162613.4159-2-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dh.herrmann@gmail.com, netdev@vger.kernel.org, davem@davemloft.net
To: Daniel Mack <daniel@zonque.org>, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48285 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750705AbdAWQjq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 11:39:46 -0500
In-Reply-To: <20170121162613.4159-2-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/21/2017 05:26 PM, Daniel Mack wrote:
[...]
> +/* Called from syscall or from eBPF program */
> +static int trie_update_elem(struct bpf_map *map,
> +			    void *_key, void *value, u64 flags)
> +{
> +	struct lpm_trie *trie = container_of(map, struct lpm_trie, map);
> +	struct lpm_trie_node *node, *im_node, *new_node = NULL;

im_node is uninitialized here ...

> +	struct lpm_trie_node __rcu **slot;
> +	struct bpf_lpm_trie_key *key = _key;
> +	unsigned long irq_flags;
> +	unsigned int next_bit;
> +	size_t matchlen = 0;
> +	int ret = 0;
> +
> +	if (unlikely(flags > BPF_EXIST))
> +		return -EINVAL;
> +
> +	if (key->prefixlen > trie->max_prefixlen)
> +		return -EINVAL;
> +
> +	raw_spin_lock_irqsave(&trie->lock, irq_flags);
> +
> +	/* Allocate and fill a new node */
> +
> +	if (trie->n_entries == trie->map.max_entries) {
> +		ret = -ENOSPC;
> +		goto out;

... and here we go to out path with ret as non-zero ...

> +	}
> +
> +	new_node = lpm_trie_node_alloc(trie, value);
> +	if (!new_node) {
> +		ret = -ENOMEM;
> +		goto out;
> +	}
[...]
> +
> +out:
> +	if (ret) {
> +		if (new_node)
> +			trie->n_entries--;
> +
> +		kfree(new_node);
> +		kfree(im_node);

... which does kfree() in im_node here.

> +	}
> +
> +	raw_spin_unlock_irqrestore(&trie->lock, irq_flags);
> +
> +	return ret;
> +}
