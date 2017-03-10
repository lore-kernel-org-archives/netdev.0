From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 1/2] mpls: allow TTL propagation to IP packets
 to be configured
Date: Thu, 9 Mar 2017 19:00:41 -0700
Message-ID: <4711aeb8-5da5-4a2b-7304-6b9696e8c1cb@cumulusnetworks.com>
References: <1485808575-16852-1-git-send-email-rshearma@brocade.com>
 <1488933990-14490-1-git-send-email-rshearma@brocade.com>
 <1488933990-14490-2-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        roopa <roopa@cumulusnetworks.com>
To: Robert Shearman <rshearma@brocade.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:36040 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754956AbdCJCAz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 21:00:55 -0500
Received: by mail-pf0-f171.google.com with SMTP id o126so35667721pfb.3
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 18:00:44 -0800 (PST)
In-Reply-To: <1488933990-14490-2-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/7/17 5:46 PM, Robert Shearman wrote:
> @@ -244,24 +245,33 @@ static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
>  		payload_type = ip_hdr(skb)->version;
>  
>  	switch (payload_type) {
> -	case MPT_IPV4: {
> -		struct iphdr *hdr4 = ip_hdr(skb);
> +	case MPT_IPV4:
> +		if (rt->rt_ttl_propagate == MPLS_TTL_PROP_ENABLED ||
> +		    (rt->rt_ttl_propagate == MPLS_TTL_PROP_DEFAULT &&
> +		     net->mpls.ip_ttl_propagate)) {
> +			struct iphdr *hdr4 = ip_hdr(skb);
> +
> +			csum_replace2(&hdr4->check,
> +				      htons(hdr4->ttl << 8),
> +				      htons(dec.ttl << 8));
> +			hdr4->ttl = dec.ttl;
> +		}
>  		skb->protocol = htons(ETH_P_IP);
> -		csum_replace2(&hdr4->check,
> -			      htons(hdr4->ttl << 8),
> -			      htons(dec.ttl << 8));
> -		hdr4->ttl = dec.ttl;
>  		success = true;
>  		break;
> -	}
> -	case MPT_IPV6: {
> -		struct ipv6hdr *hdr6 = ipv6_hdr(skb);
> +	case MPT_IPV6:
> +		if (rt->rt_ttl_propagate == MPLS_TTL_PROP_ENABLED ||
> +		    (rt->rt_ttl_propagate == MPLS_TTL_PROP_DEFAULT &&
> +		     net->mpls.ip_ttl_propagate)) {
> +			struct ipv6hdr *hdr6 = ipv6_hdr(skb);
> +
> +			hdr6->hop_limit = dec.ttl;
> +		}
>  		skb->protocol = htons(ETH_P_IPV6);
> -		hdr6->hop_limit = dec.ttl;
>  		success = true;
>  		break;
> -	}

What decrements the TTL if it is not propagated from MPLS to IP?
