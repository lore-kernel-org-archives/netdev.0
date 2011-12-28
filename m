From: Tim Hartrick <tim@edgecast.com>
Subject: Re: Crash in ip_expire/icmp_send - 2.6.38.2 (Ubuntu 11.04 natty)
Date: Tue, 27 Dec 2011 21:41:07 -0700
Message-ID: <1325047267.4354.21.camel@boudreau>
References: <1325043141.4354.20.camel@boudreau>
	 <20111227.224853.1945641698257880843.davem@davemloft.net>
Reply-To: tim@edgecast.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:52988 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753253Ab1L1ElR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 23:41:17 -0500
Received: by iaeh11 with SMTP id h11so21418726iae.19
        for <netdev@vger.kernel.org>; Tue, 27 Dec 2011 20:41:17 -0800 (PST)
In-Reply-To: <20111227.224853.1945641698257880843.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


David,

Thanks for the pointer to the patch.

I will endeavor to obey the protocol in the future.


Tim Hartrick

On Tue, 2011-12-27 at 22:48 -0500, David Miller wrote:
> Well known and fixed a long time ago, see the patch below.
> 
> Please reproduce bugs against current upstream kernels before
> reporting the problem here, if it only occurs in the vendor's
> kernel then the appropriate thing to do is to report it to
> the vendor.
> 
> --------------------
> commit 64f3b9e203bd06855072e295557dca1485a2ecba
> Author: Eric Dumazet <eric.dumazet@gmail.com>
> Date:   Wed May 4 10:02:26 2011 +0000
> 
>     net: ip_expire() must revalidate route
>     
>     Commit 4a94445c9a5c (net: Use ip_route_input_noref() in input path)
>     added a bug in IP defragmentation handling, in case timeout is fired.
>     
>     When a frame is defragmented, we use last skb dst field when building
>     final skb. Its dst is valid, since we are in rcu read section.
>     
>     But if a timeout occurs, we take first queued fragment to build one ICMP
>     TIME EXCEEDED message. Problem is all queued skb have weak dst pointers,
>     since we escaped RCU critical section after their queueing. icmp_send()
>     might dereference a now freed (and possibly reused) part of memory.
>     
>     Calling skb_dst_drop() and ip_route_input_noref() to revalidate route is
>     the only possible choice.
>     
>     Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>
>     Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
> index a1151b8..b1d282f 100644
> --- a/net/ipv4/ip_fragment.c
> +++ b/net/ipv4/ip_fragment.c
> @@ -223,31 +223,30 @@ static void ip_expire(unsigned long arg)
>  
>  	if ((qp->q.last_in & INET_FRAG_FIRST_IN) && qp->q.fragments != NULL) {
>  		struct sk_buff *head = qp->q.fragments;
> +		const struct iphdr *iph;
> +		int err;
>  
>  		rcu_read_lock();
>  		head->dev = dev_get_by_index_rcu(net, qp->iif);
>  		if (!head->dev)
>  			goto out_rcu_unlock;
>  
> +		/* skb dst is stale, drop it, and perform route lookup again */
> +		skb_dst_drop(head);
> +		iph = ip_hdr(head);
> +		err = ip_route_input_noref(head, iph->daddr, iph->saddr,
> +					   iph->tos, head->dev);
> +		if (err)
> +			goto out_rcu_unlock;
> +
>  		/*
> -		 * Only search router table for the head fragment,
> -		 * when defraging timeout at PRE_ROUTING HOOK.
> +		 * Only an end host needs to send an ICMP
> +		 * "Fragment Reassembly Timeout" message, per RFC792.
>  		 */
> -		if (qp->user == IP_DEFRAG_CONNTRACK_IN && !skb_dst(head)) {
> -			const struct iphdr *iph = ip_hdr(head);
> -			int err = ip_route_input(head, iph->daddr, iph->saddr,
> -						 iph->tos, head->dev);
> -			if (unlikely(err))
> -				goto out_rcu_unlock;
> -
> -			/*
> -			 * Only an end host needs to send an ICMP
> -			 * "Fragment Reassembly Timeout" message, per RFC792.
> -			 */
> -			if (skb_rtable(head)->rt_type != RTN_LOCAL)
> -				goto out_rcu_unlock;
> +		if (qp->user == IP_DEFRAG_CONNTRACK_IN &&
> +		    skb_rtable(head)->rt_type != RTN_LOCAL)
> +			goto out_rcu_unlock;
>  
> -		}
>  
>  		/* Send an ICMP "Fragment Reassembly Timeout" message. */
>  		icmp_send(head, ICMP_TIME_EXCEEDED, ICMP_EXC_FRAGTIME, 0);
