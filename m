From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [net-next 08/14] ixgbe: Add support for generic Tx checksums
Date: Mon, 04 Apr 2016 15:32:37 -0700
Message-ID: <5702EB85.5080307@intel.com>
References: <1459808097-26409-1-git-send-email-jeffrey.t.kirsher@intel.com> <1459808097-26409-9-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:8993 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755610AbcDDWci (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2016 18:32:38 -0400
In-Reply-To: <1459808097-26409-9-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/4/2016 3:14 PM, Jeff Kirsher wrote:
> From: Alexander Duyck <aduyck@mirantis.com>
>
> This patch adds support for generic Tx checksums to the ixgbe driver.  It
> turns out this is actually pretty easy after going over the datasheet as we
> were doing a number of steps we didn't need to.
>
> In order to perform a Tx checksum for an L4 header we need to fill in the
> following fields in the Tx descriptor:
>    MACLEN (maximum of 127), retrieved from:
> 		skb_network_offset()
>    IPLEN  (maximum of 511), retrieved from:
> 		skb_checksum_start_offset() - skb_network_offset()
>    TUCMD.L4T indicates offset and if checksum or crc32c, based on:
> 		skb->csum_offset
>
> The added advantage to doing this is that we can support inner checksum
> offloads for tunnels and MPLS while still being able to transparently
> insert VLAN tags.
>
> I also took the opportunity to clean-up many of the feature flag
> configuration bits to make them a bit more consistent between drivers.
>
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 164 +++++++++-----------------
>   1 file changed, 59 insertions(+), 105 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index bce5737..8d248c8 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -7202,103 +7202,61 @@ static int ixgbe_tso(struct ixgbe_ring *tx_ring,
>   	return 1;
>   }
>   

<snip>


> @@ -9190,41 +9148,37 @@ skip_sriov:
>   
>   #endif
>   	netdev->features = NETIF_F_SG |
> -			   NETIF_F_IP_CSUM |
> -			   NETIF_F_IPV6_CSUM |
> -			   NETIF_F_HW_VLAN_CTAG_TX |
> -			   NETIF_F_HW_VLAN_CTAG_RX |
>   			   NETIF_F_TSO |
>   			   NETIF_F_TSO6 |
>   			   NETIF_F_RXHASH |
> -			   NETIF_F_RXCSUM;
> -
> -	netdev->hw_features = netdev->features | NETIF_F_HW_L2FW_DOFFLOAD;
> +			   NETIF_F_RXCSUM |
> +			   NETIF_F_HW_CSUM |
> +			   NETIF_F_SCTP_CRC |
> +			   NETIF_F_HW_VLAN_CTAG_TX |
> +			   NETIF_F_HW_VLAN_CTAG_RX;
>   
> -	switch (adapter->hw.mac.type) {
> -	case ixgbe_mac_82599EB:
> -	case ixgbe_mac_X540:
> -	case ixgbe_mac_X550:
> -	case ixgbe_mac_X550EM_x:
> +	if (hw->mac.type >= ixgbe_mac_82599EB)
>   		netdev->features |= NETIF_F_SCTP_CRC;
> -		netdev->hw_features |= NETIF_F_SCTP_CRC |
> -				       NETIF_F_NTUPLE |
> -				       NETIF_F_HW_TC;
> -		break;
> -	default:
> -		break;
> -	}
>   
> -	netdev->hw_features |= NETIF_F_RXALL;
> +	/* copy netdev features into list of user selectable features */
> +	netdev->hw_features |= netdev->features;
> +	netdev->hw_features |= NETIF_F_RXALL |
> +			       NETIF_F_HW_L2FW_DOFFLOAD;
> +
> +	if (hw->mac.type >= ixgbe_mac_82599EB)
> +		netdev->hw_features |= NETIF_F_NTUPLE;

looks like the cleanup missed moving NETIF_F_HW_TC flag here that 
enables cls_u32 offloads via TC.

> +
> +	/* set this bit last since it cannot be part of hw_features */
>   	netdev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
>   
> -	netdev->vlan_features |= NETIF_F_TSO;
> -	netdev->vlan_features |= NETIF_F_TSO6;
> -	netdev->vlan_features |= NETIF_F_IP_CSUM;
> -	netdev->vlan_features |= NETIF_F_IPV6_CSUM;
> -	netdev->vlan_features |= NETIF_F_SG;
> +	netdev->vlan_features |= NETIF_F_SG |
> +				 NETIF_F_TSO |
> +				 NETIF_F_TSO6 |
> +				 NETIF_F_HW_CSUM |
> +				 NETIF_F_SCTP_CRC;
>   
> -	netdev->hw_enc_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
> +	netdev->mpls_features |= NETIF_F_HW_CSUM;
> +	netdev->hw_enc_features |= NETIF_F_HW_CSUM;
>   
>   	netdev->priv_flags |= IFF_UNICAST_FLT;
>   	netdev->priv_flags |= IFF_SUPP_NOFCS;
