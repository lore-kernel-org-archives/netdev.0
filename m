From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 21/25] netns ct: per-netns event cache
Date: Thu, 04 Sep 2008 18:58:38 +0200
Message-ID: <48C013BE.3060800@trash.net>
References: <20080821220445.GU31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33681 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002AbYIDQ6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 12:58:39 -0400
In-Reply-To: <20080821220445.GU31136@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

adobriyan@gmail.com wrote:
>  static inline void
> -nf_conntrack_event_cache(enum ip_conntrack_events event,
> +nf_conntrack_event_cache(struct net *net, enum ip_conntrack_events event,
>  			 const struct sk_buff *skb)
>  {

Passing the conntrack instead of the struct net and the skb
would probably keep the callers cleaner.

>  	struct nf_conn *ct = (struct nf_conn *)skb->nfct;
>  	struct nf_conntrack_ecache *ecache;
>  
>  	local_bh_disable();
> -	ecache = &__get_cpu_var(nf_conntrack_ecache);
> +	ecache = per_cpu_ptr(net->ct.ecache, raw_smp_processor_id());
>  	if (ct != ecache->ct)
>  		__nf_ct_event_cache_init(ct);
>  	ecache->events |= event;
> @@ -60,16 +58,29 @@ nf_ct_expect_event(enum ip_conntrack_expect_events event,
>  	atomic_notifier_call_chain(&nf_ct_expect_chain, event, exp);
>  }
>  
