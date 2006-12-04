From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][XFRM] Optimize policy dumping
Date: Mon, 04 Dec 2006 13:24:38 +0100
Message-ID: <45741386.5070002@trash.net>
References: <1165158707.3517.92.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38826 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S936239AbWLDMVc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 07:21:32 -0500
To: hadi@cyberus.ca
In-Reply-To: <1165158707.3517.92.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index 64d3938..c8a98ca 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -860,57 +860,70 @@ EXPORT_SYMBOL(xfrm_policy_flush);
>  int xfrm_policy_walk(u8 type, int (*func)(struct xfrm_policy *, int, int, void*),
>  		     void *data)
>  {
> -	struct xfrm_policy *pol;
>  	struct hlist_node *entry;
> -	int dir, count, error;
> +	int dir = 0, last_dir = 0, count = 0, error = -ENOENT;
> +	struct xfrm_policy *pol = NULL, *send_pol = NULL, *last_pol = NULL;
>  
>  	read_lock_bh(&xfrm_policy_lock);
> -	count = 0;
> +
>  	for (dir = 0; dir < 2*XFRM_POLICY_MAX; dir++) {
>  		struct hlist_head *table = xfrm_policy_bydst[dir].table;
>  		int i;
>  
>  		hlist_for_each_entry(pol, entry,
>  				     &xfrm_policy_inexact[dir], bydst) {
> -			if (pol->type == type)
> -				count++;
> -		}
> -		for (i = xfrm_policy_bydst[dir].hmask; i >= 0; i--) {
> -			hlist_for_each_entry(pol, entry, table + i, bydst) {
> -				if (pol->type == type)
> -					count++;
> +			if (count && send_pol && send_pol != last_pol) {
> +				error = func(send_pol, dir % XFRM_POLICY_MAX, count, data);
> +				if (error)
> +					goto out;
> +				send_pol = NULL;
>  			}
> -		}
> -	}
> -
> -	if (count == 0) {
> -		error = -ENOENT;
> -		goto out;
> -	}
> -
> -	for (dir = 0; dir < 2*XFRM_POLICY_MAX; dir++) {
> -		struct hlist_head *table = xfrm_policy_bydst[dir].table;
> -		int i;
>  
> -		hlist_for_each_entry(pol, entry,
> -				     &xfrm_policy_inexact[dir], bydst) {
>  			if (pol->type != type)
>  				continue;
> -			error = func(pol, dir % XFRM_POLICY_MAX, --count, data);
> -			if (error)
> -				goto out;
> +
> +			if (!count) {
> +				last_pol = send_pol = pol;
> +			} else {
> +				send_pol = last_pol;
> +				last_pol = pol;
> +			}
> +
> +			last_dir = dir;
> +			count++;
>  		}
> +
>  		for (i = xfrm_policy_bydst[dir].hmask; i >= 0; i--) {
>  			hlist_for_each_entry(pol, entry, table + i, bydst) {
> +				if (count && send_pol && send_pol != last_pol) {
> +					error = func(send_pol, dir % XFRM_POLICY_MAX, count, data);
> +					send_pol = NULL;
> +					if (error)
> +						goto out;
> +				}
>  				if (pol->type != type)
>  					continue;
> -				error = func(pol, dir % XFRM_POLICY_MAX, --count, data);
> -				if (error)
> -					goto out;
> +				if (!count) {
> +					last_pol = send_pol = pol;
> +				} else {
> +					send_pol = last_pol;
> +					last_pol = pol;
> +				}
> +				last_dir = dir;
> +				count++;
>  			}
>  		}
>  	}
> -	error = 0;
> +
> +	if (send_pol && send_pol != last_pol) {
> +		error = func(send_pol, last_dir % XFRM_POLICY_MAX, count, data);
> +	}
> +
> +	if (count) {
> +		BUG_TRAP(last_pol == NULL);
> +		error = func(send_pol, last_dir % XFRM_POLICY_MAX, 0, data);
> +	}
> +
>  out:
>  	read_unlock_bh(&xfrm_policy_lock);
>  	return error;


A few cases that will behave incorrectly:

- two policies in xfrm_policy_inexact with the same direction:
  after the first iteration we have last_pol = send_pol = first policy
  and no messages sent, after the second iteration we have
  send_pol = first policy, last_pol = second policy and still no
  messages sent. Since send_pol && send_pol != last_pol, the
  second to last block will send send_pol with last_dir, since
  count > 0 the last block will send send_pol again. So we get
  two times the first policy and zero times the second one.

- same case as above, but policies in opposite directions. The
  first policy will again be sent twice, but with last_dir, which
  is the direction of the second policy.

- three policies in xfrm_policy_inexact, two with similar direction,
  one with opposite direction. The first two iterations look similar
  and no policies are dumped, during the third iteration we have
  count && send_pol && send_pol != last_pol. So send_pol (the
  first policy) is sent, but with direction dir, which is at that
  time the opposite direction of the policy.


I guess its easy to construct more cases. In general I don't see
how remebering only the last direction can work since two policies
with potentially different directions are remembered. Within the
loop you always use dir, which also look wrong.

