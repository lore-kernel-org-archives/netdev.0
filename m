From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next v2 2/3] netfilter: call nf_hook_state_init with
 rcu_read_lock held
Date: Thu, 14 Jul 2016 19:19:20 +0200
Message-ID: <20160714171920.GA1274@salvia>
References: <1468337541-23930-1-git-send-email-aconole@bytheb.org>
 <1468337541-23930-3-git-send-email-aconole@bytheb.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Florian Westphal <fw@strlen.de>
To: Aaron Conole <aconole@bytheb.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43174 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751411AbcGNRTY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2016 13:19:24 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 3CCD32519C2
	for <netdev@vger.kernel.org>; Thu, 14 Jul 2016 19:19:23 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 2D9A99EBC7
	for <netdev@vger.kernel.org>; Thu, 14 Jul 2016 19:19:23 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 13A6C9EBB9
	for <netdev@vger.kernel.org>; Thu, 14 Jul 2016 19:19:21 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <1468337541-23930-3-git-send-email-aconole@bytheb.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 12, 2016 at 11:32:20AM -0400, Aaron Conole wrote:
> From: Florian Westphal <fw@strlen.de>
> 
> This makes things simpler because we can store the head of the list
> in the nf_state structure without worrying about concurrent add/delete
> of hook elements from the list.

This is something that you need for your follow up patch, right? Then
it would be good to document this here.

More comments below.

> diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
> index 9230f9a..ad444f0 100644
> --- a/include/linux/netfilter.h
> +++ b/include/linux/netfilter.h
> @@ -174,10 +174,16 @@ static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
>  
>  	if (!list_empty(hook_list)) {
>  		struct nf_hook_state state;
> +		int ret;
>  
> +		/* We may already have this, but read-locks nest anyway */
> +		rcu_read_lock();
>  		nf_hook_state_init(&state, hook_list, hook, thresh,
>  				   pf, indev, outdev, sk, net, okfn);
> -		return nf_hook_slow(skb, &state);
> +
> +		ret = nf_hook_slow(skb, &state);
> +		rcu_read_unlock();
> +		return ret;
>  	}
>  	return 1;
>  }
> diff --git a/include/linux/netfilter_ingress.h b/include/linux/netfilter_ingress.h
> index 5fcd375..6965ba0 100644
> --- a/include/linux/netfilter_ingress.h
> +++ b/include/linux/netfilter_ingress.h
> @@ -14,6 +14,7 @@ static inline bool nf_hook_ingress_active(const struct sk_buff *skb)
>  	return !list_empty(&skb->dev->nf_hooks_ingress);
>  }
>  
> +/* caller must hold rcu_read_lock */
>  static inline int nf_hook_ingress(struct sk_buff *skb)
>  {
>  	struct nf_hook_state state;
> diff --git a/net/bridge/netfilter/ebt_redirect.c b/net/bridge/netfilter/ebt_redirect.c
> index 20396499..2e7c4f9 100644
> --- a/net/bridge/netfilter/ebt_redirect.c
> +++ b/net/bridge/netfilter/ebt_redirect.c
> @@ -24,7 +24,7 @@ ebt_redirect_tg(struct sk_buff *skb, const struct xt_action_param *par)
>  		return EBT_DROP;
>  
>  	if (par->hooknum != NF_BR_BROUTING)
> -		/* rcu_read_lock()ed by nf_hook_slow */
> +		/* rcu_read_lock()ed by nf_hook_thresh */

Why are all these comments being renamed in this patch? This patch
description doesn't say anything about this.
