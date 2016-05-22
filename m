From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v7 net-next 01/16] gso: Remove arbitrary checks for
 unsupported GSO
Date: Sun, 22 May 2016 10:44:53 +0300
Message-ID: <20160522104418-mutt-send-email-mst@redhat.com>
References: <1463587584-2315623-1-git-send-email-tom@herbertland.com>
 <1463587584-2315623-2-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56230 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751456AbcEVHo4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 May 2016 03:44:56 -0400
Content-Disposition: inline
In-Reply-To: <1463587584-2315623-2-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 18, 2016 at 09:06:09AM -0700, Tom Herbert wrote:
> In several gso_segment functions there are checks of gso_type against
> a seemingly arbitrary list of SKB_GSO_* flags. This seems like an
> attempt to identify unsupported GSO types, but since the stack is
> the one that set these GSO types in the first place this seems
> unnecessary to do. If a combination isn't valid in the first
> place that stack should not allow setting it.
> 
> This is a code simplication especially for add new GSO types.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>


I don't know of instances where gso_flags are passed in
from a VM, so FWIW

Acked-by: Michael S. Tsirkin <mst@redhat.com>


> ---
>  net/ipv4/af_inet.c     | 18 ------------------
>  net/ipv4/gre_offload.c | 14 --------------
>  net/ipv4/tcp_offload.c | 19 -------------------
>  net/ipv4/udp_offload.c | 10 ----------
>  net/ipv6/ip6_offload.c | 18 ------------------
>  net/ipv6/udp_offload.c | 13 -------------
>  net/mpls/mpls_gso.c    | 11 +----------
>  7 files changed, 1 insertion(+), 102 deletions(-)
> 
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 2e6e65f..7f08d45 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1205,24 +1205,6 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
>  	int ihl;
>  	int id;
>  
> -	if (unlikely(skb_shinfo(skb)->gso_type &
> -		     ~(SKB_GSO_TCPV4 |
> -		       SKB_GSO_UDP |
> -		       SKB_GSO_DODGY |
> -		       SKB_GSO_TCP_ECN |
> -		       SKB_GSO_GRE |
> -		       SKB_GSO_GRE_CSUM |
> -		       SKB_GSO_IPIP |
> -		       SKB_GSO_SIT |
> -		       SKB_GSO_TCPV6 |
> -		       SKB_GSO_UDP_TUNNEL |
> -		       SKB_GSO_UDP_TUNNEL_CSUM |
> -		       SKB_GSO_TCP_FIXEDID |
> -		       SKB_GSO_TUNNEL_REMCSUM |
> -		       SKB_GSO_PARTIAL |
> -		       0)))
> -		goto out;
> -
>  	skb_reset_network_header(skb);
>  	nhoff = skb_network_header(skb) - skb_mac_header(skb);
>  	if (unlikely(!pskb_may_pull(skb, sizeof(*iph))))
> diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
> index e88190a..ecd1e09 100644
> --- a/net/ipv4/gre_offload.c
> +++ b/net/ipv4/gre_offload.c
> @@ -26,20 +26,6 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
>  	int gre_offset, outer_hlen;
>  	bool need_csum, ufo;
>  
> -	if (unlikely(skb_shinfo(skb)->gso_type &
> -				~(SKB_GSO_TCPV4 |
> -				  SKB_GSO_TCPV6 |
> -				  SKB_GSO_UDP |
> -				  SKB_GSO_DODGY |
> -				  SKB_GSO_TCP_ECN |
> -				  SKB_GSO_TCP_FIXEDID |
> -				  SKB_GSO_GRE |
> -				  SKB_GSO_GRE_CSUM |
> -				  SKB_GSO_IPIP |
> -				  SKB_GSO_SIT |
> -				  SKB_GSO_PARTIAL)))
> -		goto out;
> -
>  	if (!skb->encapsulation)
>  		goto out;
>  
> diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
> index 02737b6..5c59649 100644
> --- a/net/ipv4/tcp_offload.c
> +++ b/net/ipv4/tcp_offload.c
> @@ -83,25 +83,6 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
>  
>  	if (skb_gso_ok(skb, features | NETIF_F_GSO_ROBUST)) {
>  		/* Packet is from an untrusted source, reset gso_segs. */
> -		int type = skb_shinfo(skb)->gso_type;
> -
> -		if (unlikely(type &
> -			     ~(SKB_GSO_TCPV4 |
> -			       SKB_GSO_DODGY |
> -			       SKB_GSO_TCP_ECN |
> -			       SKB_GSO_TCP_FIXEDID |
> -			       SKB_GSO_TCPV6 |
> -			       SKB_GSO_GRE |
> -			       SKB_GSO_GRE_CSUM |
> -			       SKB_GSO_IPIP |
> -			       SKB_GSO_SIT |
> -			       SKB_GSO_UDP_TUNNEL |
> -			       SKB_GSO_UDP_TUNNEL_CSUM |
> -			       SKB_GSO_TUNNEL_REMCSUM |
> -			       0) ||
> -			     !(type & (SKB_GSO_TCPV4 |
> -				       SKB_GSO_TCPV6))))
> -			goto out;
>  
>  		skb_shinfo(skb)->gso_segs = DIV_ROUND_UP(skb->len, mss);
>  
> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> index 6b7459c..81f253b 100644
> --- a/net/ipv4/udp_offload.c
> +++ b/net/ipv4/udp_offload.c
> @@ -209,16 +209,6 @@ static struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
>  
>  	if (skb_gso_ok(skb, features | NETIF_F_GSO_ROBUST)) {
>  		/* Packet is from an untrusted source, reset gso_segs. */
> -		int type = skb_shinfo(skb)->gso_type;
> -
> -		if (unlikely(type & ~(SKB_GSO_UDP | SKB_GSO_DODGY |
> -				      SKB_GSO_UDP_TUNNEL |
> -				      SKB_GSO_UDP_TUNNEL_CSUM |
> -				      SKB_GSO_TUNNEL_REMCSUM |
> -				      SKB_GSO_IPIP |
> -				      SKB_GSO_GRE | SKB_GSO_GRE_CSUM) ||
> -			     !(type & (SKB_GSO_UDP))))
> -			goto out;
>  
>  		skb_shinfo(skb)->gso_segs = DIV_ROUND_UP(skb->len, mss);
>  
> diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
> index f5eb184..9ad743b 100644
> --- a/net/ipv6/ip6_offload.c
> +++ b/net/ipv6/ip6_offload.c
> @@ -69,24 +69,6 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
>  	bool encap, udpfrag;
>  	int nhoff;
>  
> -	if (unlikely(skb_shinfo(skb)->gso_type &
> -		     ~(SKB_GSO_TCPV4 |
> -		       SKB_GSO_UDP |
> -		       SKB_GSO_DODGY |
> -		       SKB_GSO_TCP_ECN |
> -		       SKB_GSO_TCP_FIXEDID |
> -		       SKB_GSO_TCPV6 |
> -		       SKB_GSO_GRE |
> -		       SKB_GSO_GRE_CSUM |
> -		       SKB_GSO_IPIP |
> -		       SKB_GSO_SIT |
> -		       SKB_GSO_UDP_TUNNEL |
> -		       SKB_GSO_UDP_TUNNEL_CSUM |
> -		       SKB_GSO_TUNNEL_REMCSUM |
> -		       SKB_GSO_PARTIAL |
> -		       0)))
> -		goto out;
> -
>  	skb_reset_network_header(skb);
>  	nhoff = skb_network_header(skb) - skb_mac_header(skb);
>  	if (unlikely(!pskb_may_pull(skb, sizeof(*ipv6h))))
> diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
> index 5429f6b..ac858c4 100644
> --- a/net/ipv6/udp_offload.c
> +++ b/net/ipv6/udp_offload.c
> @@ -36,19 +36,6 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
>  
>  	if (skb_gso_ok(skb, features | NETIF_F_GSO_ROBUST)) {
>  		/* Packet is from an untrusted source, reset gso_segs. */
> -		int type = skb_shinfo(skb)->gso_type;
> -
> -		if (unlikely(type & ~(SKB_GSO_UDP |
> -				      SKB_GSO_DODGY |
> -				      SKB_GSO_UDP_TUNNEL |
> -				      SKB_GSO_UDP_TUNNEL_CSUM |
> -				      SKB_GSO_TUNNEL_REMCSUM |
> -				      SKB_GSO_GRE |
> -				      SKB_GSO_GRE_CSUM |
> -				      SKB_GSO_IPIP |
> -				      SKB_GSO_SIT) ||
> -			     !(type & (SKB_GSO_UDP))))
> -			goto out;
>  
>  		skb_shinfo(skb)->gso_segs = DIV_ROUND_UP(skb->len, mss);
>  
> diff --git a/net/mpls/mpls_gso.c b/net/mpls/mpls_gso.c
> index bbcf604..2055e57 100644
> --- a/net/mpls/mpls_gso.c
> +++ b/net/mpls/mpls_gso.c
> @@ -26,15 +26,6 @@ static struct sk_buff *mpls_gso_segment(struct sk_buff *skb,
>  	netdev_features_t mpls_features;
>  	__be16 mpls_protocol;
>  
> -	if (unlikely(skb_shinfo(skb)->gso_type &
> -				~(SKB_GSO_TCPV4 |
> -				  SKB_GSO_TCPV6 |
> -				  SKB_GSO_UDP |
> -				  SKB_GSO_DODGY |
> -				  SKB_GSO_TCP_FIXEDID |
> -				  SKB_GSO_TCP_ECN)))
> -		goto out;
> -
>  	/* Setup inner SKB. */
>  	mpls_protocol = skb->protocol;
>  	skb->protocol = skb->inner_protocol;
> @@ -57,7 +48,7 @@ static struct sk_buff *mpls_gso_segment(struct sk_buff *skb,
>  	 * skb_mac_gso_segment(), an indirect caller of this function.
>  	 */
>  	__skb_pull(skb, skb->data - skb_mac_header(skb));
> -out:
> +
>  	return segs;
>  }
>  
> -- 
> 2.8.0.rc2
