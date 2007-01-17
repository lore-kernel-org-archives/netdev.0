From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: passthrough openswan connection not working with 2.6.19.2
Date: Wed, 17 Jan 2007 09:36:39 +0100
Message-ID: <BAY103-DAV990ED5FB84E3AB63ED719B2AB0@phx.gbl>
References: <E1H6vOb-0005Nr-00@gondolin.me.apana.org.au>
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc2-s13.bay0.hotmail.com ([65.54.246.149]:15063 "EHLO
	bay0-omc2-s13.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932067AbXAQIgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jan 2007 03:36:47 -0500
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

> Marco Berizzi <pupilla@hotmail.com> wrote:
> > Yesterday I have updated to linux 2.6.19.2
> > (from 2.6.19.1) and passthrough openswan
> > connection aren't working anymore.
> > This is the 'ip -s x s' output:
>
> I presume you mean ip -s x p :)

yes indeed ;-)

> Nasty.  This means that the policy list is no longer sorted by
priority.
> Can you please try this patch and let me know if it fixes the problem?

Yes, the patch below fixes the problem.
I have applied to 2.6.19.2:

root@Calimero:/usr/src/linux-2.6.19.2# patch -p1 < ../herbert
patching file net/xfrm/xfrm_policy.c
Hunk #1 succeeded at 615 (offset -35 lines).

Thanks a lot for the feedback.

> [IPSEC]: Policy list disorder
>
> The recent hashing introduced an off-by-one bug in policy list
insertion.
> Instead of adding after the last entry with a lesser or equal
priority,
> we're adding after the successor of that entry.
>
> This patch fixes this and also adds a warning if we detect a duplicate
> entry in the policy list.  This should never happen due to this if
clause.
>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>
> Thanks,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> --
> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index bebd40e..b7e537f 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -650,19 +650,18 @@ int xfrm_policy_insert(int dir, struct
xfrm_policy *policy, int excl)
>   struct xfrm_policy *pol;
>   struct xfrm_policy *delpol;
>   struct hlist_head *chain;
> - struct hlist_node *entry, *newpos, *last;
> + struct hlist_node *entry, *newpos;
>   struct dst_entry *gc_list;
>
>   write_lock_bh(&xfrm_policy_lock);
>   chain = policy_hash_bysel(&policy->selector, policy->family, dir);
>   delpol = NULL;
>   newpos = NULL;
> - last = NULL;
>   hlist_for_each_entry(pol, entry, chain, bydst) {
> - if (!delpol &&
> -     pol->type == policy->type &&
> + if (pol->type == policy->type &&
>       !selector_cmp(&pol->selector, &policy->selector) &&
> -     xfrm_sec_ctx_match(pol->security, policy->security)) {
> +     xfrm_sec_ctx_match(pol->security, policy->security) &&
> +     !WARN_ON(delpol)) {
>   if (excl) {
>   write_unlock_bh(&xfrm_policy_lock);
>   return -EEXIST;
> @@ -671,17 +670,12 @@ int xfrm_policy_insert(int dir, struct
xfrm_policy *policy, int excl)
>   if (policy->priority > pol->priority)
>   continue;
>   } else if (policy->priority >= pol->priority) {
> - last = &pol->bydst;
> + newpos = &pol->bydst;
>   continue;
>   }
> - if (!newpos)
> - newpos = &pol->bydst;
>   if (delpol)
>   break;
> - last = &pol->bydst;
>   }
> - if (!newpos)
> - newpos = last;
>   if (newpos)
>   hlist_add_after(newpos, &policy->bydst);
>   else
>


