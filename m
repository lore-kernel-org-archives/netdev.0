From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 02/17] fib_trie: Make leaf and tnode more uniform
Date: Mon, 22 Dec 2014 13:33:53 -0500 (EST)
Message-ID: <20141222.133353.2244861758408916536.davem@davemloft.net>
References: <20141222172632.1119.51469.stgit@ahduyck-vm-fedora20>
	<20141222174105.1119.71598.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41989 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754233AbaLVSd4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2014 13:33:56 -0500
In-Reply-To: <20141222174105.1119.71598.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Mon, 22 Dec 2014 09:41:05 -0800

> -#define IS_TNODE(n) (!(n->parent & T_LEAF))
> -#define IS_LEAF(n) (n->parent & T_LEAF)
> +struct tnode {
> +	t_key key;
> +	unsigned char bits;		/* 2log(KEYLENGTH) bits needed */
> +	unsigned char pos;		/* 2log(KEYLENGTH) bits needed */
> +	struct tnode __rcu *parent;
> +	union {
> +		struct rcu_head rcu;
> +		struct tnode *tnode_free;
> +	};
> +	unsigned int full_children;	/* KEYLENGTH bits needed */
> +	unsigned int empty_children;	/* KEYLENGTH bits needed */
> +	struct rt_trie_node __rcu *child[0];
> +};

I wonder if we can compress this even further.

The full_children and empty_children can probably both be a u16, right?
If so, you can stick at least one of them after 'bits' and 'pos' and
thus save 4 bytes on 32b.
