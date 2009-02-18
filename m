From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFT 1/4] iptables: lock free counters
Date: Wed, 18 Feb 2009 11:02:11 +0100
Message-ID: <499BDCA3.8020604@trash.net>
References: <20090218051906.174295181@vyatta.com> <20090218052747.321329022@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>,
	Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47717 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751420AbZBRKCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 05:02:14 -0500
In-Reply-To: <20090218052747.321329022@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:

> @@ -1148,13 +1206,14 @@ static int do_add_counters(struct net *n
>  		goto free;
>  	}
>  
> -	write_lock_bh(&t->lock);
> +	mutex_lock(&t->lock);
>  	private = t->private;
>  	if (private->number != num_counters) {
>  		ret = -EINVAL;
>  		goto unlock_up_free;
>  	}
>  
> +	preempt_disable();
>  	i = 0;
>  	/* Choose the copy that is on our node */
>  	loc_cpu_entry = private->entries[smp_processor_id()];
> @@ -1164,7 +1223,8 @@ static int do_add_counters(struct net *n
>  			   paddc,
>  			   &i);
>   unlock_up_free:
> -	write_unlock_bh(&t->lock);
> +	mutex_unlock(&t->lock);
> +
>  	xt_table_unlock(t);
>  	module_put(t->me);
>   free:

This part (arptables.c) seems to be missing a preempt_enable().

Other than this, the patch looks good to me, if you want I can
already apply this one.
