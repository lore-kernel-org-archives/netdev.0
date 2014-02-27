From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net-next] consolidate duplicate code is
 skb_checksum_setup() helpers
Date: Thu, 27 Feb 2014 10:57:31 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD025D340@AMSPEX01CL01.citrite.net>
References: <530F0DBC020000780011FC30@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: Jan Beulich <JBeulich@suse.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([185.25.65.24]:57681 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751198AbaB0K5e convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 05:57:34 -0500
In-Reply-To: <530F0DBC020000780011FC30@nat28.tlf.novell.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Jan Beulich [mailto:JBeulich@suse.com]
> Sent: 27 February 2014 09:05
> To: netdev@vger.kernel.org
> Cc: Paul Durrant; davem@davemloft.net; Eric Dumazet
> Subject: [PATCH net-next] consolidate duplicate code is
> skb_checksum_setup() helpers
> 
> Realizing that the skb_maybe_pull_tail() calls in the IP-protocol
> specific portions of both helpers are terminal ones (i.e. no further
> pulls are expected), their maximum size to be pulled can be made match
> their minimal size needed, thus making the code identical and hence
> possible to be moved into another helper.

There is a difference in the case of an IPv4 TCP packet with options. With your patch it will only get pulled up as far as the base header so there may need to be another pull for options parsing. Still, removing the code duplication is clearly a good thing; passing the max pullup value in as an arg would avoid the semantic change.

  Paul

> 
> Signed-off-by: Jan Beulich <jbeulich@suse.com>
> Cc: Paul Durrant <paul.durrant@citrix.com>
> Cc: David Miller <davem@davemloft.net>
> Cc: Eric Dumazet <edumazet@google.com>
> ---
>  net/core/skbuff.c |  142 +++++++++++++++++++---------------------------------
> --
>  1 file changed, 50 insertions(+), 92 deletions(-)
> 
> --- 3.14-rc4/net/core/skbuff.c
> +++ 3.14-rc4-skb-checksum-setup-ip/net/core/skbuff.c
> @@ -3543,15 +3543,45 @@ static int skb_maybe_pull_tail(struct sk
>  	return 0;
>  }
> 
> +static __be16 *skb_checksum_setup_ip(struct sk_buff *skb,
> +				     typeof(IPPROTO_IP) proto,
> +				     unsigned int off)
> +{
> +	switch (proto) {
> +		int err;
> +
> +	case IPPROTO_TCP:
> +		err = skb_maybe_pull_tail(skb, off + sizeof(struct tcphdr),
> +					  off + sizeof(struct tcphdr));
> +		if (!err && !skb_partial_csum_set(skb, off,
> +						  offsetof(struct tcphdr,
> +							   check)))
> +			err = -EPROTO;
> +		return err ? ERR_PTR(err) : &tcp_hdr(skb)->check;
> +
> +	case IPPROTO_UDP:
> +		err = skb_maybe_pull_tail(skb, off + sizeof(struct udphdr),
> +					  off + sizeof(struct udphdr));
> +		if (!err && !skb_partial_csum_set(skb, off,
> +						  offsetof(struct udphdr,
> +							   check)))
> +			err = -EPROTO;
> +		return err ? ERR_PTR(err) : &udp_hdr(skb)->check;
> +	}
> +
> +	return ERR_PTR(-EPROTO);
> +}
> +
>  /* This value should be large enough to cover a tagged ethernet header plus
>   * maximally sized IP and TCP or UDP headers.
>   */
>  #define MAX_IP_HDR_LEN 128
> 
> -static int skb_checksum_setup_ip(struct sk_buff *skb, bool recalculate)
> +static int skb_checksum_setup_ipv4(struct sk_buff *skb, bool recalculate)
>  {
>  	unsigned int off;
>  	bool fragment;
> +	__be16 *csum;
>  	int err;
> 
>  	fragment = false;
> @@ -3572,51 +3602,15 @@ static int skb_checksum_setup_ip(struct
>  	if (fragment)
>  		goto out;
> 
> -	switch (ip_hdr(skb)->protocol) {
> -	case IPPROTO_TCP:
> -		err = skb_maybe_pull_tail(skb,
> -					  off + sizeof(struct tcphdr),
> -					  MAX_IP_HDR_LEN);
> -		if (err < 0)
> -			goto out;
> -
> -		if (!skb_partial_csum_set(skb, off,
> -					  offsetof(struct tcphdr, check))) {
> -			err = -EPROTO;
> -			goto out;
> -		}
> -
> -		if (recalculate)
> -			tcp_hdr(skb)->check =
> -				~csum_tcpudp_magic(ip_hdr(skb)->saddr,
> -						   ip_hdr(skb)->daddr,
> -						   skb->len - off,
> -						   IPPROTO_TCP, 0);
> -		break;
> -	case IPPROTO_UDP:
> -		err = skb_maybe_pull_tail(skb,
> -					  off + sizeof(struct udphdr),
> -					  MAX_IP_HDR_LEN);
> -		if (err < 0)
> -			goto out;
> -
> -		if (!skb_partial_csum_set(skb, off,
> -					  offsetof(struct udphdr, check))) {
> -			err = -EPROTO;
> -			goto out;
> -		}
> -
> -		if (recalculate)
> -			udp_hdr(skb)->check =
> -				~csum_tcpudp_magic(ip_hdr(skb)->saddr,
> -						   ip_hdr(skb)->daddr,
> -						   skb->len - off,
> -						   IPPROTO_UDP, 0);
> -		break;
> -	default:
> -		goto out;
> -	}
> -
> +	csum = skb_checksum_setup_ip(skb, ip_hdr(skb)->protocol, off);
> +	if (IS_ERR(csum))
> +		return PTR_ERR(csum);
> +
> +	if (recalculate)
> +		*csum = ~csum_tcpudp_magic(ip_hdr(skb)->saddr,
> +					   ip_hdr(skb)->daddr,
> +					   skb->len - off,
> +					   ip_hdr(skb)->protocol, 0);
>  	err = 0;
> 
>  out:
> @@ -3639,6 +3633,7 @@ static int skb_checksum_setup_ipv6(struc
>  	unsigned int len;
>  	bool fragment;
>  	bool done;
> +	__be16 *csum;
> 
>  	fragment = false;
>  	done = false;
> @@ -3716,51 +3711,14 @@ static int skb_checksum_setup_ipv6(struc
>  	if (!done || fragment)
>  		goto out;
> 
> -	switch (nexthdr) {
> -	case IPPROTO_TCP:
> -		err = skb_maybe_pull_tail(skb,
> -					  off + sizeof(struct tcphdr),
> -					  MAX_IPV6_HDR_LEN);
> -		if (err < 0)
> -			goto out;
> -
> -		if (!skb_partial_csum_set(skb, off,
> -					  offsetof(struct tcphdr, check))) {
> -			err = -EPROTO;
> -			goto out;
> -		}
> -
> -		if (recalculate)
> -			tcp_hdr(skb)->check =
> -				~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
> -						 &ipv6_hdr(skb)->daddr,
> -						 skb->len - off,
> -						 IPPROTO_TCP, 0);
> -		break;
> -	case IPPROTO_UDP:
> -		err = skb_maybe_pull_tail(skb,
> -					  off + sizeof(struct udphdr),
> -					  MAX_IPV6_HDR_LEN);
> -		if (err < 0)
> -			goto out;
> -
> -		if (!skb_partial_csum_set(skb, off,
> -					  offsetof(struct udphdr, check))) {
> -			err = -EPROTO;
> -			goto out;
> -		}
> -
> -		if (recalculate)
> -			udp_hdr(skb)->check =
> -				~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
> -						 &ipv6_hdr(skb)->daddr,
> -						 skb->len - off,
> -						 IPPROTO_UDP, 0);
> -		break;
> -	default:
> -		goto out;
> -	}
> -
> +	csum = skb_checksum_setup_ip(skb, nexthdr, off);
> +	if (IS_ERR(csum))
> +		return PTR_ERR(csum);
> +
> +	if (recalculate)
> +		*csum = ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
> +					 &ipv6_hdr(skb)->daddr,
> +					 skb->len - off, nexthdr, 0);
>  	err = 0;
> 
>  out:
> @@ -3778,7 +3736,7 @@ int skb_checksum_setup(struct sk_buff *s
> 
>  	switch (skb->protocol) {
>  	case htons(ETH_P_IP):
> -		err = skb_checksum_setup_ip(skb, recalculate);
> +		err = skb_checksum_setup_ipv4(skb, recalculate);
>  		break;
> 
>  	case htons(ETH_P_IPV6):
> 
