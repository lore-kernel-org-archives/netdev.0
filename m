From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [PATCH net] xen-netback: make sure skb linear
 area covers checksum field
Date: Wed, 11 Dec 2013 16:47:55 +0000
Message-ID: <52A8A54B020000780010C607@nat28.tlf.novell.com>
References: <1386779860-19338-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "David Vrabel" <david.vrabel@citrix.com>,
	"Ian Campbell" <ian.campbell@citrix.com>,
	"Wei Liu" <wei.liu2@citrix.com>, <xen-devel@lists.xen.org>,
	<netdev@vger.kernel.org>
To: "Paul Durrant" <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:52878 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750904Ab3LKQr6 convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:3:1>);
	Wed, 11 Dec 2013 11:47:58 -0500
In-Reply-To: <1386779860-19338-1-git-send-email-paul.durrant@citrix.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 11.12.13 at 17:37, Paul Durrant <paul.durrant@citrix.com> wrote:
> skb_partial_csum_set requires that the linear area of the skb covers the
> checksum field. The checksum setup code in netback was only doing that
> pullup in the case when the pseudo header checksum was being recalculated
> though. This patch makes that pullup unconditional. (I pullup the whole
> transport header just for simplicity; the requirement is only for the check
> field but in the case of UDP this is the last field in the header and in the
> case of TCP it's the last but one).
> 
> The lack of pullup manifested as failures running Microsoft HCK network
> tests on a pair of Windows 8 VMs and it has been verified that this patch
> fixes the problem.
> 

Suggested-by: Jan Beulich <jbeulich@suse.com>
(or Reported-by, whatever you like better)

> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>

Reviewed-by: Jan Beulich <jbeulich@suse.com>

> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: David Vrabel <david.vrabel@citrix.com>
> ---
>  drivers/net/xen-netback/netback.c |   60 +++++++++++++++++--------------------
>  1 file changed, 28 insertions(+), 32 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c 
> b/drivers/net/xen-netback/netback.c
> index acf1392..56c3e5a 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1199,42 +1199,40 @@ static int checksum_setup_ip(struct xenvif *vif, 
> struct sk_buff *skb,
>  
>  	switch (ip_hdr(skb)->protocol) {
>  	case IPPROTO_TCP:
> +		err = maybe_pull_tail(skb,
> +				      off + sizeof(struct tcphdr),
> +				      MAX_IP_HDR_LEN);
> +		if (err < 0)
> +			goto out;
> +
>  		if (!skb_partial_csum_set(skb, off,
>  					  offsetof(struct tcphdr, check)))
>  			goto out;
>  
> -		if (recalculate_partial_csum) {
> -			err = maybe_pull_tail(skb,
> -					      off + sizeof(struct tcphdr),
> -					      MAX_IP_HDR_LEN);
> -			if (err < 0)
> -				goto out;
> -
> +		if (recalculate_partial_csum)
>  			tcp_hdr(skb)->check =
>  				~csum_tcpudp_magic(ip_hdr(skb)->saddr,
>  						   ip_hdr(skb)->daddr,
>  						   skb->len - off,
>  						   IPPROTO_TCP, 0);
> -		}
>  		break;
>  	case IPPROTO_UDP:
> +		err = maybe_pull_tail(skb,
> +				      off + sizeof(struct udphdr),
> +				      MAX_IP_HDR_LEN);
> +		if (err < 0)
> +			goto out;
> +
>  		if (!skb_partial_csum_set(skb, off,
>  					  offsetof(struct udphdr, check)))
>  			goto out;
>  
> -		if (recalculate_partial_csum) {
> -			err = maybe_pull_tail(skb,
> -					      off + sizeof(struct udphdr),
> -					      MAX_IP_HDR_LEN);
> -			if (err < 0)
> -				goto out;
> -
> +		if (recalculate_partial_csum)
>  			udp_hdr(skb)->check =
>  				~csum_tcpudp_magic(ip_hdr(skb)->saddr,
>  						   ip_hdr(skb)->daddr,
>  						   skb->len - off,
>  						   IPPROTO_UDP, 0);
> -		}
>  		break;
>  	default:
>  		goto out;
> @@ -1342,42 +1340,40 @@ static int checksum_setup_ipv6(struct xenvif *vif, 
> struct sk_buff *skb,
>  
>  	switch (nexthdr) {
>  	case IPPROTO_TCP:
> +		err = maybe_pull_tail(skb,
> +				      off + sizeof(struct tcphdr),
> +				      MAX_IPV6_HDR_LEN);
> +		if (err < 0)
> +			goto out;
> + 
>  		if (!skb_partial_csum_set(skb, off,
>  					  offsetof(struct tcphdr, check)))
>  			goto out;
>  
> -		if (recalculate_partial_csum) {
> -			err = maybe_pull_tail(skb,
> -					      off + sizeof(struct tcphdr),
> -					      MAX_IPV6_HDR_LEN);
> -			if (err < 0)
> -				goto out;
> -
> +		if (recalculate_partial_csum)
>  			tcp_hdr(skb)->check =
>  				~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
>  						 &ipv6_hdr(skb)->daddr,
>  						 skb->len - off,
>  						 IPPROTO_TCP, 0);
> -		}
>  		break;
>  	case IPPROTO_UDP:
> +		err = maybe_pull_tail(skb,
> +				      off + sizeof(struct udphdr),
> +				      MAX_IPV6_HDR_LEN);
> +		if (err < 0)
> +			goto out;
> +
>  		if (!skb_partial_csum_set(skb, off,
>  					  offsetof(struct udphdr, check)))
>  			goto out;
>  
> -		if (recalculate_partial_csum) {
> -			err = maybe_pull_tail(skb,
> -					      off + sizeof(struct udphdr),
> -					      MAX_IPV6_HDR_LEN);
> -			if (err < 0)
> -				goto out;
> -
> +		if (recalculate_partial_csum)
>  			udp_hdr(skb)->check =
>  				~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
>  						 &ipv6_hdr(skb)->daddr,
>  						 skb->len - off,
>  						 IPPROTO_UDP, 0);
> -		}
>  		break;
>  	default:
>  		goto out;
> -- 
> 1.7.10.4
> 
> 
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org 
> http://lists.xen.org/xen-devel 
