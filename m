From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [RFC PATCH 01/29] fib_trie: Convert fib_alias to hlist from
 list
Date: Wed, 25 Feb 2015 00:47:59 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1502250005130.3125@ja.home.ssi.bg>
References: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20> <20150224204801.26106.10186.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:53323 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751866AbbBXWsI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 17:48:08 -0500
In-Reply-To: <20150224204801.26106.10186.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 24 Feb 2015, Alexander Duyck wrote:

> There isn't any advantage to having it as a list and by making it an hlist
> we make the fib_alias more compatible with the list_info in terms of the
> type of list used.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> ---
>  include/net/ip_fib.h     |    2 +
>  net/ipv4/fib_lookup.h    |    2 +
>  net/ipv4/fib_semantics.c |    4 +--
>  net/ipv4/fib_trie.c      |   72 ++++++++++++++++++++++++++--------------------
>  4 files changed, 44 insertions(+), 36 deletions(-)

> -static struct list_head *fib_insert_node(struct trie *t, u32 key, int plen)
> +static struct hlist_head *fib_insert_node(struct trie *t, u32 key, int plen)

> @@ -1276,8 +1276,17 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
>  	if (!plen)
>  		tb->tb_num_default++;
>  
> -	list_add_tail_rcu(&new_fa->fa_list,
> -			  (fa ? &fa->fa_list : fa_head));
> +	if (!fa) {
> +		struct fib_alias *last;
> +
> +		hlist_for_each_entry(last, fa_head, fa_list)
> +			fa = last;

	This should be changed to properly replace add_tail
because when fa is NULL we are adding new_fa with lowest
TOS value and it should be really added at tail. When
fa != NULL, new_fa should go before fa. Looks like this
comment is wrong:

         * If fa is NULL, we will need to allocate a new one and
         * insert to the head of f.

	It should be "to the tail of fa_head".

> +	}
> +
> +	if (fa)
> +		hlist_add_behind_rcu(&new_fa->fa_list, &fa->fa_list);

		hlist_add_before_rcu because list_add_tail_rcu
means add_before.

> +	else
> +		hlist_add_head_rcu(&new_fa->fa_list, fa_head);

		hlist_add_behind_rcu after last or
hlist_add_head_rcu if list is empty.

	What about:

	/* fa_last can come from fib_find_alias */
	struct fib_alias *fa_last = NULL;

	fa = fib_find_alias(fa_head, tos, fi->fib_priority, &fa_last);
	...

	if (fa)
		hlist_add_before_rcu(&new_fa->fa_list, &fa->fa_list);
	else if (!fa_last)
		hlist_add_head_rcu(&new_fa->fa_list, fa_head);
	else
		hlist_add_behind_rcu(&new_fa->fa_list, &fa_last->fa_list);

Regards

--
Julian Anastasov <ja@ssi.bg>
