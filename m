From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [net-next PATCH 4/4] fib_trie: Remove leaf_info
Date: Thu, 26 Feb 2015 00:29:21 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1502252341500.2970@ja.home.ssi.bg>
References: <20150225185658.1747.99188.stgit@ahduyck-vm-fedora20> <20150225190625.1747.49993.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:48556 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752925AbbBYW3c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2015 17:29:32 -0500
In-Reply-To: <20150225190625.1747.49993.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 25 Feb 2015, Alexander Duyck wrote:

> -static void insert_leaf_info(struct tnode *l, struct leaf_info *new)
> +static void fib_insert_alias(struct tnode *l, struct fib_alias *fa,
> +			     struct fib_alias *new)
>  {
> -	struct hlist_head *head = &l->list;
> -	struct leaf_info *li, *last = NULL;
> +	if (fa) {
> +		hlist_add_before_rcu(&new->fa_list, &fa->fa_list);
> +	} else {
> +		struct fib_alias *last;
>  
> -	hlist_for_each_entry(li, head, hlist) {
> -		if (new->slen < li->slen)
> -			break;
> -		last = li;
> -	}
> +		hlist_for_each_entry(last, &l->leaf, fa_list) {
> +			if (new->fa_slen < last->fa_slen)
> +				break;

	If there is some fa in list with higher fa_slen
fib_find_alias will always stop the loop and come with
fa != NULL, so above 'if...break' is not needed, we are
always going to add at tail when fa is NULL.

> +			fa = last;
> +		}
>  
> -	if (last)
> -		hlist_add_behind_rcu(&new->hlist, &last->hlist);
> -	else
> -		hlist_add_head_rcu(&new->hlist, head);
> +		if (fa)
> +			hlist_add_behind_rcu(&new->fa_list, &fa->fa_list);
> +		else
> +			hlist_add_head_rcu(&new->fa_list, &l->leaf);
> +	}
>  

> @@ -1187,7 +1127,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
>  		fa_match = NULL;
>  		fa_first = fa;
>  		hlist_for_each_entry_from(fa, fa_list) {
> -			if (fa->fa_tos != tos)
> +			if ((fa->fa_slen != slen) || (fa->fa_tos != tos))

	'fa->fa_slen == slen' check is also needed in the
above 'if' that is not present in the patch:

if (fa && fa->fa_slen == slen && fa->fa_tos == tos &&
    fa->fa_info->fib_priority == fi->fib_priority) {

	Without such check we may wrongly enter the 'if'
when fa->fa_slen > slen and to get some error, to
replace the wrong fa or to append after it.

> +	hlist_for_each_entry_rcu(fa, &n->leaf, fa_list) {
> +		struct fib_info *fi = fa->fa_info;
> +		int nhsel, err;
>  
> -			if (((key ^ n->key) >> fa->fa_slen) &&
> -			    ((BITS_PER_LONG > KEYLENGTH) ||
> -			     (fa->fa_slen != KEYLENGTH)))
> -				continue;
> -			if (fa->fa_tos && fa->fa_tos != flp->flowi4_tos)
> -				continue;
> -			if (fi->fib_dead)
> +		if (((key ^ n->key) >= (1ul << fa->fa_slen)) &&
> +		    ((BITS_PER_LONG > KEYLENGTH) || (fa->fa_slen != KEYLENGTH)))
>  				continue;

	lshift 32 for 32-bit int has the same side effects, so
BITS_PER_LONG is not needed.

	Both left and right shift get same result on 64-bit:

# ./a 32
7
7

#include <stdio.h>
#include <stdlib.h>

int main (int argc, char *argv[])
{
        unsigned int a = 7;

        printf("%u\n", a >> atoi(argv[1]));
        printf("%u\n", a << atoi(argv[1]));
        return 0;
}

Regards

--
Julian Anastasov <ja@ssi.bg>
