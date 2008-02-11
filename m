From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: Re: [PATCH][RFC] race in generic address resolution
Date: Mon, 11 Feb 2008 10:01:20 +0100
Message-ID: <47B00EE0.4040109@linux.vnet.ibm.com>
References: <20080204142717.GA11020@tuxmaker.boeblingen.de.ibm.com> <20080205.205154.153345843.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:25856 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874AbYBKJA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 04:00:58 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m1B90vWc096510
	for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 09:00:57 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1B90vr8803010
	for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 09:00:57 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1B90sCD021983
	for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 09:00:54 GMT
In-Reply-To: <20080205.205154.153345843.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller schrieb:
> From: Blaschka <frank.blaschka@de.ibm.com>
> Date: Mon, 4 Feb 2008 15:27:17 +0100
> 
>> I'm running a SMP maschine (2 CPUs) configured as a router. During heavy
>> traffic kernel dies with following message: 
>>
>>     <2>kernel BUG at /home/autobuild/BUILD/linux-2.6.23-20080125/net/core/skbuff.c:648!
>  ...
>> Following patch fixes the problem but I do not know if it is a good sollution.
>>
>> From: Frank Blaschka <frank.blaschka@de.ibm.com>
>>
>> neigh_update sends skb from neigh->arp_queue while
>> neigh_timer_handler has increased skbs refcount and calls
>> solicit with the skb. Do not send neighbour skbs
>> marked for solicit (skb_shared).
>>
>> Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
> 
> Thanks for finding this bug.
> 
> I'm fine with your approach as a temporary fix, but there is a slight
> problem with your patch.  If the skb is shared we have to free it if
> we don't pass it on to ->output(), otherwise this creates a leak.
> 
> In the longer term, this is an unfortunate limitation.  The
> ->solicit() code just wants to look at a few header fields to
> determine how to construct the solicitation request.
> 
> What's funny is that we added these skb_get() calls for
> the solications exactly to deal with this race condition.
> 
> I considered various ways to fix this.  The simplest is probably just
> to skb_copy() in the ->solicit() case.  Solicitation is a rare event
> so it's not big deal to copy the packet until the neighbour is
> resolved.
> 
> The other option is holding the write lock on neigh->lock during the
> ->solicit() call.  I looked at all of the ndisc_ops implementations
> and this seems workable.  The only case that needs special care is the
> IPV4 ARP implementation of arp_solicit().  It wants to take
> neigh->lock as a reader to protect the header entry in neigh->ha
> during the emission of the soliciation.  We can simply remove the read
> lock calls to take care of that since holding the lock as a writer at
> the caller providers a superset of the protection afforded by the
> existing read locking.
> 
> The rest of the ->solicit() implementations don't care whether
> the neigh is locked or not.
> 
> Can you see if this version of the patch fixes your problem?
> 
> Thanks!
> 
> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> index a16cf1e..7bb6a9a 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -834,18 +834,12 @@ static void neigh_timer_handler(unsigned long arg)
>  	}
>  	if (neigh->nud_state & (NUD_INCOMPLETE | NUD_PROBE)) {
>  		struct sk_buff *skb = skb_peek(&neigh->arp_queue);
> -		/* keep skb alive even if arp_queue overflows */
> -		if (skb)
> -			skb_get(skb);
> -		write_unlock(&neigh->lock);
> +
>  		neigh->ops->solicit(neigh, skb);
>  		atomic_inc(&neigh->probes);
> -		if (skb)
> -			kfree_skb(skb);
> -	} else {
> -out:
> -		write_unlock(&neigh->lock);
>  	}
> +out:
> +	write_unlock(&neigh->lock);
> 
>  	if (notify)
>  		neigh_update_notify(neigh);
> diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
> index 8e17f65..c663fa5 100644
> --- a/net/ipv4/arp.c
> +++ b/net/ipv4/arp.c
> @@ -368,7 +368,6 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
>  		if (!(neigh->nud_state&NUD_VALID))
>  			printk(KERN_DEBUG "trying to ucast probe in NUD_INVALID\n");
>  		dst_ha = neigh->ha;
> -		read_lock_bh(&neigh->lock);
>  	} else if ((probes -= neigh->parms->app_probes) < 0) {
>  #ifdef CONFIG_ARPD
>  		neigh_app_ns(neigh);
> @@ -378,8 +377,6 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
> 
>  	arp_send(ARPOP_REQUEST, ETH_P_ARP, target, dev, saddr,
>  		 dst_ha, dev->dev_addr, NULL);
> -	if (dst_ha)
> -		read_unlock_bh(&neigh->lock);
>  }
> 
>  static int arp_ignore(struct in_device *in_dev, __be32 sip, __be32 tip)
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

Hi Dave,

we run your patch during the weekend on single CPU and SMP machines. We do not
see any problems. Thanks for providing the fix.

Best regards,
		Frank 

