From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [PATCH net-next-2.6] IFix IPv6 GSO type checks in Intel ethernet
 drivers
Date: Tue, 19 Jan 2010 13:11:00 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.1001191306450.5776@jbrandeb-desk1.amr.corp.intel.com>
References: <1263934927.1635.24.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:65056 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755687Ab0ASVLF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jan 2010 16:11:05 -0500
In-Reply-To: <1263934927.1635.24.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 19 Jan 2010, Sridhar Samudrala wrote:

> Found this problem when testing IPv6 from a KVM guest to a remote
> host via e1000e device on the host.
> The following patch fixes the check for IPv6 GSO packet in Intel
> ethernet drivers to use skb_is_gso_v6(). SKB_GSO_DODGY is also set
> when packets are forwarded from a guest.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com

Looks fine, thanks!  The current code in net-next and 2.6.32 both have 
exactly the same condition in skb_is_gso_v6, so I'm not sure that this 
patch alone will fix any issues, FYI.  If this patch is part of another 
set or dependent upon another for the actual change in behavior mentioned 
in the comment, I think it should be noted or sent in a series.

Ack-ed by: Jesse Brandeburg <jesse.brandeburg@intel.com>

> 
> diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
> index 3d57ca5..2353e95 100644
> --- a/drivers/net/e1000e/netdev.c
> +++ b/drivers/net/e1000e/netdev.c
> @@ -3771,7 +3771,7 @@ static int e1000_tso(struct e1000_adapter *adapter,
>  		                                         0, IPPROTO_TCP, 0);
>  		cmd_length = E1000_TXD_CMD_IP;
>  		ipcse = skb_transport_offset(skb) - 1;
> -	} else if (skb_shinfo(skb)->gso_type == SKB_GSO_TCPV6) {
> +	} else if (skb_is_gso_v6(skb)) {
>  		ipv6_hdr(skb)->payload_len = 0;
>  		tcp_hdr(skb)->check = ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
>  		                                       &ipv6_hdr(skb)->daddr,
> diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
> index d967949..d4bbdf0 100644
> --- a/drivers/net/igb/igb_main.c
> +++ b/drivers/net/igb/igb_main.c
> @@ -3422,7 +3422,7 @@ static inline int igb_tso_adv(struct igb_ring *tx_ring,
>  							 iph->daddr, 0,
>  							 IPPROTO_TCP,
>  							 0);
> -	} else if (skb_shinfo(skb)->gso_type == SKB_GSO_TCPV6) {
> +	} else if (skb_is_gso_v6(skb)) {
>  		ipv6_hdr(skb)->payload_len = 0;
>  		tcp_hdr(skb)->check = ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
>  						       &ipv6_hdr(skb)->daddr,
> diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
> index a6c3920..ce33671 100644
> --- a/drivers/net/igbvf/netdev.c
> +++ b/drivers/net/igbvf/netdev.c
> @@ -1963,7 +1963,7 @@ static int igbvf_tso(struct igbvf_adapter *adapter,
>  		                                         iph->daddr, 0,
>  		                                         IPPROTO_TCP,
>  		                                         0);
> -	} else if (skb_shinfo(skb)->gso_type == SKB_GSO_TCPV6) {
> +	} else if (skb_is_gso_v6(skb)) {
>  		ipv6_hdr(skb)->payload_len = 0;
>  		tcp_hdr(skb)->check = ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
>  		                                       &ipv6_hdr(skb)->daddr,
> diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
> index 81971ed..b2c0025 100644
> --- a/drivers/net/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ixgbe/ixgbe_main.c
> @@ -5113,7 +5113,7 @@ static int ixgbe_tso(struct ixgbe_adapter *adapter,
>  			                                         iph->daddr, 0,
>  			                                         IPPROTO_TCP,
>  			                                         0);
> -		} else if (skb_shinfo(skb)->gso_type == SKB_GSO_TCPV6) {
> +		} else if (skb_is_gso_v6(skb)) {
>  			ipv6_hdr(skb)->payload_len = 0;
>  			tcp_hdr(skb)->check =
>  			    ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
> diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
> index 39544af..652b6f4 100644
> --- a/drivers/net/ixgbevf/ixgbevf_main.c
> +++ b/drivers/net/ixgbevf/ixgbevf_main.c
> @@ -2756,7 +2756,7 @@ static int ixgbevf_tso(struct ixgbevf_adapter *adapter,
>  								 IPPROTO_TCP,
>  								 0);
>  			adapter->hw_tso_ctxt++;
> -		} else if (skb_shinfo(skb)->gso_type == SKB_GSO_TCPV6) {
> +		} else if (skb_is_gso_v6(skb)) {
>  			ipv6_hdr(skb)->payload_len = 0;
>  			tcp_hdr(skb)->check =
>  			    ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
> 
> 
> 
