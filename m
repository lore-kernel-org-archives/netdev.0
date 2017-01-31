From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] mpls: allow TTL propagation to/from IP packets
 to be configured
Date: Mon, 30 Jan 2017 18:09:36 -0700
Message-ID: <8e29e6cc-c612-976a-b819-c9ddb8d5c27a@cumulusnetworks.com>
References: <1485808575-16852-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa <roopa@cumulusnetworks.com>,
        ebiederm@xmission.com
To: Robert Shearman <rshearma@brocade.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33709 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932182AbdAaBJj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 20:09:39 -0500
Received: by mail-pf0-f181.google.com with SMTP id y143so96352209pfb.0
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 17:09:38 -0800 (PST)
In-Reply-To: <1485808575-16852-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/30/17 1:36 PM, Robert Shearman wrote:
> @@ -243,24 +245,29 @@ static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
>  		payload_type = ip_hdr(skb)->version;
>  
>  	switch (payload_type) {
> -	case MPT_IPV4: {
> -		struct iphdr *hdr4 = ip_hdr(skb);
> -		skb->protocol = htons(ETH_P_IP);
> -		csum_replace2(&hdr4->check,
> -			      htons(hdr4->ttl << 8),
> -			      htons(dec.ttl << 8));
> -		hdr4->ttl = dec.ttl;
> +	case MPT_IPV4:
> +		if (net->mpls.ip_ttl_propagate) {
> +			struct iphdr *hdr4 = ip_hdr(skb);
> +
> +			skb->protocol = htons(ETH_P_IP);

The protocol setting here and ...

> +			csum_replace2(&hdr4->check,
> +				      htons(hdr4->ttl << 8),
> +				      htons(dec.ttl << 8));
> +			hdr4->ttl = dec.ttl;
> +		}
>  		success = true;
>  		break;
> -	}
> -	case MPT_IPV6: {
> -		struct ipv6hdr *hdr6 = ipv6_hdr(skb);
> -		skb->protocol = htons(ETH_P_IPV6);
> -		hdr6->hop_limit = dec.ttl;
> +	case MPT_IPV6:
> +		if (net->mpls.ip_ttl_propagate) {
> +			struct ipv6hdr *hdr6 = ipv6_hdr(skb);
> +
> +			skb->protocol = htons(ETH_P_IPV6);

here need to be done outside of net->mpls.ip_ttl_propagate otherwise ...

> +			hdr6->hop_limit = dec.ttl;
> +		}
>  		success = true;
>  		break;
> -	}
>  	case MPT_UNSPEC:
> +		/* Should have decided which protocol it is by now */
>  		break;
>  	}
>  

disabling ip_ttl_propagate causes a corrupted packet to show up at the end host (after the LSP):

IP4:
16:54:08.895372 46:a9:1c:9f:30:ba > fa:61:57:d6:1a:7d, ethertype MPLS unicast (0x8847), length 98: MPLS (label 282624, exp 0, ttl 84)
	(label 433380, exp 0, ttl 0)
	(label 262160, exp 7, [S], ttl 182)
	0x0000:  ac10 0101 0a0a 0a0a 0800 1677 05d3 0001  ...........w....
	0x0010:  30e0 8f58 0000 0000 4fa9 0d00 0000 0000  0..X....O.......
	0x0020:  1011 1213 1415 1617 1819 1a1b 1c1d 1e1f  ................
	0x0030:  2021 2223 2425 2627 2829 2a2b 2c2d 2e2f  .!"#$%&'()*+,-./
	0x0040:  3031 3233 3435 3637                      01234567


IPv6:
16:57:40.517520 46:a9:1c:9f:30:ba > fa:61:57:d6:1a:7d, ethertype MPLS unicast (0x8847), length 118: MPLS (label 393290, exp 5, ttl 240)
	(label 1027, exp 5, ttl 64)
	(label 131072, exp 0, ttl 1)
	(label 0 (IPv4 explicit NULL), exp 0, ttl 0)
	(label 0 (IPv4 explicit NULL), exp 0, ttl 0)
	(label 0 (IPv4 explicit NULL), exp 0, ttl 1)
	(label 196608, exp 0, ttl 1)
	(label 0 (IPv4 explicit NULL), exp 0, ttl 0)
	(label 0 (IPv4 explicit NULL), exp 0, ttl 0)
	(label 0 (IPv4 explicit NULL), exp 0, ttl 1)
	(label 524297, exp 1, [S], ttl 102)
	0x0000:  0628 0001 04e1 8f58 0000 0000 3be5 0700  .(.....X....;...
	0x0010:  0000 0000 1011 1213 1415 1617 1819 1a1b  ................
	0x0020:  1c1d 1e1f 2021 2223 2425 2627 2829 2a2b  .....!"#$%&'()*+
	0x0030:  2c2d 2e2f 3031 3233 3435 3637            ,-./01234567
