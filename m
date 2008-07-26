From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [RFC] sctp/tcp: Question -- ICMPv4 length check (not) redundant?
Date: Fri, 25 Jul 2008 22:15:33 -0400
Message-ID: <488A88C5.1070105@hp.com>
References: <20080725152059.GA4656@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:4718 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752071AbYGZCPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 22:15:38 -0400
In-Reply-To: <20080725152059.GA4656@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gerrit Renker wrote:
> I wonder if the two pieces of code as marked by the patch below still
> serve a purpose. 
> 
> From grepping through the net/ code it seems they are both redundant.
> 
> This is on the basis that
> 
>  * the v6 counterparts of these handlers ({tcp,sctp}_v6_err) do not have
>    this payload-length check;
> 
>  * icmp_unreach() in net/ipv4/icmp.c already has this test:
> 
> 	/* Checkin full IP header plus 8 bytes of protocol to
> 	 * avoid additional coding at protocol handlers.
> 	 */
>         if (!pskb_may_pull(skb, iph->ihl * 4 + 8))
>                 goto out;
>  
>  * a similar test is implemented by icmpv6_notify() in net/ipv6/icmp.c;
> 
>  * this type of test seems to be absent in all of the following handlers:
>    - tcp_v6_err()		- sctp_v6_err() 
>    - __udp4_lib_err()		- __udp6_lib_err()
>    - ah4_err()			- ah6_err()
>    - esp4_err()			- esp6_err()
>    - xfrm_tunnel_err()		- xfrm6_tunnel_err()
>    - tunnel4_err()		- tunnel6_err()		- tunnel64_err()
>    - ipip_err()			- ipip6_err()
>    - ip4ip6_err()		- ip6ip6_err() 
>    - ipcomp4_err()		- ipcomp6_err()
> 
> ---------------------------------------------------------------------------
>  The following two are the exceptions in question.
>  The question is whether there is a reason for the code marked below.
> ---------------------------------------------------------------------------
> 
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -344,11 +344,6 @@ void tcp_v4_err(struct sk_buff *skb, u32 info)
>  	int err;
>  	struct net *net = dev_net(skb->dev);
>  
> -	if (skb->len < (iph->ihl << 2) + 8) {
> -		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
> -		return;
> -	}
> -
>  	sk = inet_lookup(net, &tcp_hashinfo, iph->daddr, th->dest,
>  			iph->saddr, th->source, inet_iif(skb));
>  	if (!sk) {
> --- a/net/sctp/input.c
> +++ b/net/sctp/input.c
> @@ -534,11 +534,6 @@ void sctp_v4_err(struct sk_buff *skb, __u32 info)
>  	sk_buff_data_t saveip, savesctp;
>  	int err;
>  
> -	if (skb->len < ihlen + 8) {
> -		ICMP_INC_STATS_BH(&init_net, ICMP_MIB_INERRORS);
> -		return;
> -	}
> -
>  	/* Fix up skb to look at the embedded net header. */
>  	saveip = skb->network_header;
>  	savesctp = skb->transport_header;

This one looks useless.  Thanks for noticing.  I'll remove it.

-vlad

> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

