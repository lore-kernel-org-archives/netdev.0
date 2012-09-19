From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: do not disable sg for AoE
Date: Wed, 19 Sep 2012 20:55:04 +0100
Message-ID: <1348084504.2636.41.camel@bwh-desktop.uk.solarflarecom.com>
References: <1348079358.4585@cat.he.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <akpm@linux-foundation.org>,
	<jesse@nicira.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Ed Cashin <ecashin@coraid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1348079358.4585@cat.he.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-09-18 at 20:20 -0400, Ed Cashin wrote:
> A change in a series of VLAN-related changes appears to have
> inadvertently disabled the use of the scatter gather feature of
> network cards for transmission of non-IP ethernet protocols like ATA
> over Ethernet (AoE).  Below is a reference to the commit that
> introduces a "harmonize_features" function that turns off scatter
> gather when the NIC does not support hardware checksumming for the
> ethernet protocol of an sk buff.
> 
>   commit f01a5236bd4b140198fbcc550f085e8361fd73fa
>   Author: Jesse Gross <jesse@nicira.com>
>   Date:   Sun Jan 9 06:23:31 2011 +0000
> 
>       net offloading: Generalize netif_get_vlan_features().
> 
> The can_checksum_protocol function is not equipped to consider a
> protocol that does not require checksumming.  Calling it for a
> protocol that requires no checksum is inappropriate.

Right, but...

[...]
> diff --git a/net/core/dev.c b/net/core/dev.c
> index d7fe32c..5531159 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2134,7 +2134,8 @@ static bool can_checksum_protocol(netdev_features_t features, __be16 protocol)
>  static netdev_features_t harmonize_features(struct sk_buff *skb,
>  	__be16 protocol, netdev_features_t features)
>  {
> -	if (!can_checksum_protocol(features, protocol)) {
> +	if (protocol != htons(ETH_P_AOE) &&

the generic way to check that would be skb->ip_summed != CHECKSUM_NONE.

Ben.

> +	    !can_checksum_protocol(features, protocol)) {
>  		features &= ~NETIF_F_ALL_CSUM;
>  		features &= ~NETIF_F_SG;
>  	} else if (illegal_highdma(skb->dev, skb)) {

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
