From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/7] vlan: Introduce helper functions to check
 if skb is tagged
Date: Thu, 26 Mar 2015 04:53:38 -0700
Message-ID: <1427370818.25985.131.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1427346080-12086-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	 <1427346080-12086-3-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Amir Vadai <amirv@mellanox.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Dept-GELinuxNICDev@qlogic.com, Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Linux NICS <linux.nics@intel.com>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:36805 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751382AbbCZLxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 07:53:41 -0400
Received: by igbud6 with SMTP id ud6so127490520igb.1
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 04:53:40 -0700 (PDT)
In-Reply-To: <1427346080-12086-3-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-03-26 at 14:01 +0900, Toshiaki Makita wrote:
> Separate the two checks for single vlan and multiple vlans in
> netif_skb_features().  This allows us to move the check for multiple
> vlans to another function later.
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> ---
>  include/linux/if_vlan.h | 45 +++++++++++++++++++++++++++++++++++++++++++++
>  net/core/dev.c          | 24 ++++++++----------------
>  2 files changed, 53 insertions(+), 16 deletions(-)
> 
> diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
> index b11b28a..bc649dd 100644
> --- a/include/linux/if_vlan.h
> +++ b/include/linux/if_vlan.h
> @@ -561,4 +561,49 @@ static inline void vlan_set_encap_proto(struct sk_buff *skb,
>  		skb->protocol = htons(ETH_P_802_2);
>  }
>  
> +/**
> + * skb_vlan_tagged - check if skb is vlan tagged.
> + * @skb: skbuff to query
> + *
> + * Returns true if the skb is tagged, regardless of whether it is hardware
> + * accelerated or not.
> + */
> +static inline bool skb_vlan_tagged(struct sk_buff *skb)

const struct sk_buff *skb

> +{
> +	if (!skb_vlan_tag_present(skb) &&
> +	    likely(skb->protocol != htons(ETH_P_8021Q) &&
> +		   skb->protocol != htons(ETH_P_8021AD)))
> +		return false;
> +
> +	return true;
> +}
> +
> +/**
> + * skb_vlan_tagged_multi - check if skb is vlan tagged with multiple headers.
> + * @skb: skbuff to query
> + *
> + * Returns true if the skb is tagged with multiple vlan headers, regardless
> + * of whether it is hardware accelerated or not.
> + */
> +static inline bool skb_vlan_tagged_multi(struct sk_buff *skb)


const struct sk_buff *skb

> +{
> +	__be16 protocol = skb->protocol;
> +
> +	if (!skb_vlan_tag_present(skb)) {
> +		struct vlan_ethhdr *veh;
> +
> +		if (likely(protocol != htons(ETH_P_8021Q) &&
> +			   protocol != htons(ETH_P_8021AD)))
> +			return false;
> +
> +		veh = (struct vlan_ethhdr *)skb->data;
> +		protocol = veh->h_vlan_encapsulated_proto;
> +	}
> +
> +	if (protocol != htons(ETH_P_8021Q) && protocol != htons(ETH_P_8021AD))
> +		return false;
> +
> +	return true;
> +}
> +
