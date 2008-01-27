From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCHv2 2.6.24] fib: fix route replacement, fib_info is shared
Date: Mon, 28 Jan 2008 00:20:18 +0100
Message-ID: <20080127232018.GA2856@ami.dom.local>
References: <Pine.LNX.4.58.0801261439020.7864@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Joonwoo Park <joonwpark81@gmail.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:23191 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751540AbYA0XRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2008 18:17:51 -0500
Received: by fg-out-1718.google.com with SMTP id e21so1492800fga.17
        for <netdev@vger.kernel.org>; Sun, 27 Jan 2008 15:17:49 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0801261439020.7864@u.domain.uli>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi, I have a few questions below:

Julian Anastasov wrote, On 01/26/2008 01:41 PM:

> 	fib_info can be shared by many route prefixes but we don't
> want duplicate alternative routes for a prefix+tos+priority. Last
> change was not correct to check fib_treeref because it accounts usage
> from other prefixes. Additionally, avoid replacement without error
> if new route is same, as Joonwoo Park suggests.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
> 
> --- linux-2.6.24/net/ipv4/fib_hash.c_orig	2008-01-25 10:45:06.000000000 +0200
> +++ linux-2.6.24/net/ipv4/fib_hash.c	2008-01-26 14:11:34.000000000 +0200
> @@ -434,19 +434,43 @@ static int fn_hash_insert(struct fib_tab
>  
>  	if (fa && fa->fa_tos == tos &&
>  	    fa->fa_info->fib_priority == fi->fib_priority) {
> -		struct fib_alias *fa_orig;
> +		struct fib_alias *fa_first, *fa_match;
>  
>  		err = -EEXIST;
>  		if (cfg->fc_nlflags & NLM_F_EXCL)
>  			goto out;

BTW, the way "add" works wasn't questioned now, but it seems could be,
or man ip should call it e.g. "ip route add - add new destination",
and append "ip route append" (unless I have old man).

>  
> +		/* We have 2 goals:
> +		 * 1. Find exact match for type, scope, fib_info to avoid
> +		 * duplicate routes
> +		 * 2. Find next 'fa' (or head), NLM_F_APPEND inserts before it
> +		 */
> +		fa_match = NULL;
> +		fa_first = fa;
> +		fa = list_entry(fa->fa_list.prev, struct fib_alias, fa_list);
> +		list_for_each_entry_continue(fa, &f->fn_alias, fa_list) {
> +			if (fa->fa_tos != tos)
> +				break;
> +			if (fa->fa_info->fib_priority != fi->fib_priority)
> +				break;
> +			if (fa->fa_type == cfg->fc_type &&
> +			    fa->fa_scope == cfg->fc_scope &&
> +			    fa->fa_info == fi) {
> +				fa_match = fa;
> +				break;

Why can't we try goto out from here? (less reading...)

> +			}
> +		}
> +


>  		if (cfg->fc_nlflags & NLM_F_REPLACE) {
>  			struct fib_info *fi_drop;
>  			u8 state;
>  
> -			if (fi->fib_treeref > 1)
> +			fa = fa_first;
> +			if (fa_match) {
> +				if (fa == fa_match)
> +					err = 0;

Could you comment more why returning an error seems to depend on the
order of aliases here? But, IMHO there is no reason to change the old
behavior WRT this error, so probably this err = 0 should be always if
NLM_F_REPLACE is set.

>  				goto out;
> -
> +			}
>  			write_lock_bh(&fib_hash_lock);
>  			fi_drop = fa->fa_info;
>  			fa->fa_info = fi;
> @@ -469,20 +493,11 @@ static int fn_hash_insert(struct fib_tab
>  		 * uses the same scope, type, and nexthop
>  		 * information.
>  		 */
> -		fa_orig = fa;
> -		fa = list_entry(fa->fa_list.prev, struct fib_alias, fa_list);
> -		list_for_each_entry_continue(fa, &f->fn_alias, fa_list) {
> -			if (fa->fa_tos != tos)
> -				break;
> -			if (fa->fa_info->fib_priority != fi->fib_priority)
> -				break;
> -			if (fa->fa_type == cfg->fc_type &&
> -			    fa->fa_scope == cfg->fc_scope &&
> -			    fa->fa_info == fi)
> -				goto out;
> -		}
> +		if (fa_match)
> +			goto out;
> +
>  		if (!(cfg->fc_nlflags & NLM_F_APPEND))
> -			fa = fa_orig;
> +			fa = fa_first;
>  	}
>  
>  	err = -ENOENT;

Generally this patch looks OK to me.

Thanks,
Jarek P. 

PS: I think, this FIB info you sent earlier is just fine for
Documentation/networking without any changes! (Maybe one more patch?)
