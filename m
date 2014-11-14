From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] icmp: Remove some spurious dropped packet
 profile hits from the ICMP path
Date: Thu, 13 Nov 2014 18:17:51 -0800
Message-ID: <1415931471.17262.27.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141113225457.A3E502900805@tardy>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Rick Jones <raj@tardy.usa.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:58295 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933518AbaKNCRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 21:17:53 -0500
Received: by mail-ie0-f171.google.com with SMTP id x19so17202992ier.30
        for <netdev@vger.kernel.org>; Thu, 13 Nov 2014 18:17:52 -0800 (PST)
In-Reply-To: <20141113225457.A3E502900805@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-11-13 at 14:54 -0800, Rick Jones wrote:
> From: Rick Jones <rick.jones2@hp.com>
> 
> If icmp_rcv() has successfully processed the incoming ICMP datagram, we
> should use consume_skb() rather than kfree_skb() because a hit on the likes
> of perf -e skb:kfree_skb is not called-for.
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>
> 
> ---
> 
> A test system hit with a flood ping hits on perf top -e ksb:kfre_skb before
> the change and none after for the normal/success path.  The IPv6 path would
> be somewhat more ugly.  For the time being, just deal with the overlap on
> ping_rcv() between the two to avoid a possible double free of an skb.
> 
> diff --git a/include/net/ping.h b/include/net/ping.h
> index 026479b..f074060 100644
> --- a/include/net/ping.h
> +++ b/include/net/ping.h
> @@ -82,7 +82,7 @@ int  ping_common_sendmsg(int family, struct msghdr *msg, size_t len,
>  int  ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
>  		     size_t len);
>  int  ping_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
> -void ping_rcv(struct sk_buff *skb);
> +bool ping_rcv(struct sk_buff *skb);
>  
>  #ifdef CONFIG_PROC_FS
>  struct ping_seq_afinfo {
> diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
> index 36b7bfa..b9f3653 100644
> --- a/net/ipv4/icmp.c
> +++ b/net/ipv4/icmp.c
> @@ -190,7 +190,7 @@ EXPORT_SYMBOL(icmp_err_convert);
>   */
>  
>  struct icmp_control {
> -	void (*handler)(struct sk_buff *skb);
> +	bool (*handler)(struct sk_buff *skb);
>  	short   error;		/* This ICMP is classed as an error message */
>  };
>  
> @@ -746,7 +746,7 @@ static bool icmp_tag_validation(int proto)
>   *	ICMP_PARAMETERPROB.
>   */
>  
> -static void icmp_unreach(struct sk_buff *skb)
> +static bool icmp_unreach(struct sk_buff *skb)
>  {
>  	const struct iphdr *iph;
>  	struct icmphdr *icmph;
> @@ -839,10 +839,11 @@ static void icmp_unreach(struct sk_buff *skb)
>  	icmp_socket_deliver(skb, info);
>  
>  out:
> -	return;
> +	return true;
>  out_err:
>  	ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
> -	goto out;
> +	kfree_skb(skb);
> +	return false;
>  }
>  
> 
> @@ -850,17 +851,22 @@ out_err:
>   *	Handle ICMP_REDIRECT.
>   */
>  
> -static void icmp_redirect(struct sk_buff *skb)
> +static bool icmp_redirect(struct sk_buff *skb)
>  {
>  	if (skb->len < sizeof(struct iphdr)) {
>  		ICMP_INC_STATS_BH(dev_net(skb->dev), ICMP_MIB_INERRORS);
> -		return;
> +		kfree_skb(skb);
> +		return false;
>  	}
>  
> -	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
> -		return;
> +	if (!pskb_may_pull(skb, sizeof(struct iphdr))) {
> +		/* there aught to be a stat */
> +		kfree_skb(skb);
> +		return false;
> +	}
>  
>  	icmp_socket_deliver(skb, icmp_hdr(skb)->un.gateway);
> +	return true;
>  }
>  
>  /*
> @@ -875,7 +881,7 @@ static void icmp_redirect(struct sk_buff *skb)
>   *	See also WRT handling of options once they are done and working.
>   */
>  
> -static void icmp_echo(struct sk_buff *skb)
> +static bool icmp_echo(struct sk_buff *skb)
>  {
>  	struct net *net;
>  
> @@ -891,6 +897,8 @@ static void icmp_echo(struct sk_buff *skb)
>  		icmp_param.head_len	   = sizeof(struct icmphdr);
>  		icmp_reply(&icmp_param, skb);
>  	}
> +	/* should there be an ICMP stat for ignored echos? */
> +	return true;
>  }
>  
>  /*
> @@ -900,7 +908,7 @@ static void icmp_echo(struct sk_buff *skb)
>   *		  MUST be accurate to a few minutes.
>   *		  MUST be updated at least at 15Hz.
>   */
> -static void icmp_timestamp(struct sk_buff *skb)
> +static bool icmp_timestamp(struct sk_buff *skb)
>  {
>  	struct timespec tv;
>  	struct icmp_bxm icmp_param;
> @@ -927,15 +935,18 @@ static void icmp_timestamp(struct sk_buff *skb)
>  	icmp_param.data_len	   = 0;
>  	icmp_param.head_len	   = sizeof(struct icmphdr) + 12;
>  	icmp_reply(&icmp_param, skb);
> -out:
> -	return;
> +	return true;
> +
>  out_err:
>  	ICMP_INC_STATS_BH(dev_net(skb_dst(skb)->dev), ICMP_MIB_INERRORS);
> -	goto out;
> +	kfree_skb(skb);
> +	return false;
>  }
>  
> -static void icmp_discard(struct sk_buff *skb)
> +static bool icmp_discard(struct sk_buff *skb)
>  {
> +	/* pretend it was a success */
> +	return true;
>  }
>  
>  /*
> @@ -946,6 +957,7 @@ int icmp_rcv(struct sk_buff *skb)
>  	struct icmphdr *icmph;
>  	struct rtable *rt = skb_rtable(skb);
>  	struct net *net = dev_net(rt->dst.dev);
> +	bool success;
>  
>  	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb)) {
>  		struct sec_path *sp = skb_sec_path(skb);
> @@ -1012,7 +1024,12 @@ int icmp_rcv(struct sk_buff *skb)
>  		}
>  	}
>  
> -	icmp_pointers[icmph->type].handler(skb);
> +	success = icmp_pointers[icmph->type].handler(skb);
> +
> +	if (success) 
> +		consume_skb(skb);
> +
> +	return 0;


This looks quite complicated to me.

Why are you adding kfree_skb() everywhere instead of :

	bool to_consume = icmp_pointers[icmph->type].handler(skb);
	if (ro_consume)
		consume_skb(skb);
	else
		kfree_skb(skb);

>  
>  drop:
>  	kfree_skb(skb);
