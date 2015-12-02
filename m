From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next 13/15] ixgbe: Handle extended IPv6 headers in tx path
Date: Wed, 2 Dec 2015 08:21:02 -0800
Message-ID: <565F1A6E.5010305@gmail.com>
References: <1449059468-87025-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1449059468-87025-14-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33273 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758745AbbLBQVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 11:21:05 -0500
Received: by pabfh17 with SMTP id fh17so46253549pab.0
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 08:21:04 -0800 (PST)
In-Reply-To: <1449059468-87025-14-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/02/2015 04:31 AM, Jeff Kirsher wrote:
> From: Mark Rustad <mark.d.rustad@intel.com>
>
> Check for and handle IPv6 extended headers so that Tx checksum
> offload can be done. Thanks to Tom Herbert for noticing this
> problem. Note that the goto back to process the final protocol
> value can never result in a loop, because it cannot be yet
> another extended header. Handling them in this manner avoids
> adding further checks to the non-extended header hot path.
>
> Reported-by: Tom Herbert <tom@herbertland.com>
> Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 19 ++++++++++++++++++-
>   1 file changed, 18 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index a10a0fa..b7f1133 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -7095,6 +7095,7 @@ static void ixgbe_tx_csum(struct ixgbe_ring *tx_ring,
>   			}
>   		}
>
> +again:
>   		switch (l4_hdr) {
>   		case IPPROTO_TCP:
>   			type_tucmd |= IXGBE_ADVTXD_TUCMD_L4T_TCP;
> @@ -7111,7 +7112,23 @@ static void ixgbe_tx_csum(struct ixgbe_ring *tx_ring,
>   					IXGBE_ADVTXD_L4LEN_SHIFT;
>   			break;
>   		default:
> -			if (unlikely(net_ratelimit())) {
> +			if (network_hdr.ipv4->version == 6 &&
> +			    ipv6_ext_hdr(l4_hdr)) {
> +				unsigned int offset = 0;
> +				int ret;
> +
> +				ret = ipv6_find_hdr(skb, &offset, -1, NULL,
> +						    NULL);
> +				if (ret > 0) {
> +					l4_hdr = ret;
> +					goto again;
> +				}
> +				if (unlikely(net_ratelimit())) {
> +					dev_warn(tx_ring->dev,
> +						 "ipv6_find_hdr returned %d\n",
> +						 ret);
> +				}
> +			} else if (unlikely(net_ratelimit())) {
>   				dev_warn(tx_ring->dev,
>   				 "partial checksum but l4 proto=%x!\n",
>   				 l4_hdr);
>

This doesn't look right.  How come this doesn't match the implementation 
you did for the ixgbevf driver?  If I am not mistaken this approach had 
issues where it could spin forever didn't it?

- Alex
