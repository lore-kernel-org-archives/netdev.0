From: Daniel Mack <daniel@zonque.org>
Subject: Re: [PATCH net-next] bpf: Optimize lpm trie delete
Date: Wed, 20 Sep 2017 18:51:53 +0200
Message-ID: <47e47f0d-d04d-b52b-647a-7883aa5f3268@zonque.org>
References: <20170920162247.63787-1-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Craig Gallek <kraigatgoog@gmail.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bugwerft.de ([46.23.86.59]:56758 "EHLO mail.bugwerft.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751548AbdITQvz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 20 Sep 2017 12:51:55 -0400
In-Reply-To: <20170920162247.63787-1-kraigatgoog@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Craig,

Thanks, this looks much cleaner already :)

On 09/20/2017 06:22 PM, Craig Gallek wrote:
> diff --git a/kernel/bpf/lpm_trie.c b/kernel/bpf/lpm_trie.c
> index 9d58a576b2ae..b5a7d70ec8b5 100644
> --- a/kernel/bpf/lpm_trie.c
> +++ b/kernel/bpf/lpm_trie.c
> @@ -397,7 +397,7 @@ static int trie_delete_elem(struct bpf_map *map, void *_key)
>  	struct lpm_trie_node __rcu **trim;
>  	struct lpm_trie_node *node;
>  	unsigned long irq_flags;
> -	unsigned int next_bit;
> +	unsigned int next_bit = 0;

This default assignment seems wrong, and I guess you only added it to
squelch a compiler warning?

[...]

> +	/* If the node has one child, we may be able to collapse the tree
> +	 * while removing this node if the node's child is in the same
> +	 * 'next bit' slot as this node was in its parent or if the node
> +	 * itself is the root.
> +	 */
> +	if (trim == &trie->root) {
> +		next_bit = node->child[0] ? 0 : 1;
> +		rcu_assign_pointer(trie->root, node->child[next_bit]);
> +		kfree_rcu(node, rcu);

I don't think you should treat this 'root' case special.

Instead, move the 'next_bit' assignment outside of the condition ...

> +	} else if (rcu_access_pointer(node->child[next_bit])) {
> +		rcu_assign_pointer(*trim, node->child[next_bit]);
> +		kfree_rcu(node, rcu);

... and then this branch would handle the case just fine. Correct?

Otherwise, looks good to me!



Thanks,
Daniel
