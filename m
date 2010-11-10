From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-2.6 1/3] vlan: Add function to retrieve EtherType
 from vlan packets.
Date: Tue, 9 Nov 2010 21:54:12 -0800
Message-ID: <20101109215412.38412cff@nehalam>
References: <1289351344-14340-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Hao Zheng <hzheng@nicira.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47915 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751751Ab0KJFyO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Nov 2010 00:54:14 -0500
In-Reply-To: <1289351344-14340-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  9 Nov 2010 17:09:02 -0800
Jesse Gross <jesse@nicira.com> wrote:

> From: Hao Zheng <hzheng@nicira.com>
> 
> Depending on how a packet is vlan tagged (i.e. hardware accelerated or
> not), the encapsulated protocol is stored in different locations.  This
> provides a consistent method of accessing that protocol, which is needed
> by drivers, security checks, etc.
> 
> Signed-off-by: Hao Zheng <hzheng@nicira.com>
> Signed-off-by: Jesse Gross <jesse@nicira.com>
> ---
>  include/linux/if_vlan.h |   20 ++++++++++++++++++++
>  1 files changed, 20 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
> index c2f3a72..ee06c52 100644
> --- a/include/linux/if_vlan.h
> +++ b/include/linux/if_vlan.h
> @@ -339,6 +339,26 @@ static inline int vlan_get_tag(const struct sk_buff *skb, u16 *vlan_tci)
>  	}
>  }
>  
> +/**
> + * vlan_get_protocol - get protocol EtherType.
> + * @skb: skbuff to query
> + *
> + * Returns the EtherType of the packet, regardless of whether it is
> + * vlan encapsulated (normal or hardware accelerated) or not.
> + */
> +static inline __be16 vlan_get_protocol(struct sk_buff *skb)
> +{
> +	__be16 protocol = 0;
> +
> +	if (vlan_tx_tag_present(skb) ||
> +	     skb->protocol != cpu_to_be16(ETH_P_8021Q))
> +		protocol = skb->protocol;
> +	else if (likely(pskb_may_pull(skb, VLAN_ETH_HLEN)))
> +		protocol = ((const struct vlan_ethhdr *)skb->data)->
> +			   h_vlan_encapsulated_proto;
> +
> +	return protocol;
> +}

This this calls pskb_may_pull, which modifies the skb data
offsets and therefore could invalidate any callers pointers
to ip header or other fields.
Therefore you will need to audit all callers of this function!

Also, your code doesn't handle the case of too small a frame (VLAN header only).



-- 
