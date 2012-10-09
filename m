From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 4/6] VXLAN bases source UDP port based on flow to help
 the receiver to be able to load balance based on outer header flow.
Date: Tue, 9 Oct 2012 19:38:32 +0100
Message-ID: <1349807912.2800.33.camel@bwh-desktop.uk.solarflarecom.com>
References: <20121009175637.048993312@vyatta.com>
	 <20121009175714.682992341@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:22981 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751686Ab2JISif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 14:38:35 -0400
In-Reply-To: <20121009175714.682992341@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-09 at 10:56 -0700, Stephen Hemminger wrote:
> This patch restricts the port range to the normal UDP local
> ports, and allows overriding via configruation.
> 
> It also uses jhash of Ethernet header when looking at flows
> with out know L3 header.
[...]
> +/* Compute source port for outgoing packet
> + *   first choice to use L4 flow hash since it will spread
> + *     better and maybe available from hardware
> + *   secondary choice is to use jhash on the Ethernet header
> + */
> +static u16 vxlan_src_port(const struct vxlan_dev *vxlan, struct sk_buff *skb)
> +{
> +	unsigned int range = (vxlan->port_max - vxlan->port_min) + 1;
> +	u32 hash;
> +
> +	hash = skb_get_rxhash(skb);
> +	if (!hash)
> +		hash = jhash(skb->data, 2 * ETH_ALEN,
> +			     (__force u32) skb->protocol);
> +
> +	return (((u64) hash * range) >> 32) + vxlan->port_min;
> +}
[...]
> @@ -1021,6 +1046,18 @@ static int vxlan_validate(struct nlattr
>  			return -EADDRNOTAVAIL;
>  		}
>  	}
> +
> +	if (data[IFLA_VXLAN_PORT_RANGE]) {
> +		const struct ifla_vxlan_port_range *p
> +			= nla_data(data[IFLA_VXLAN_PORT_RANGE]);
> +
> +		if ((int)(ntohs(p->high) - ntohs(p->low)) < 1) {
[...]

This seems to be off-by-one - both bounds are inclusive so they can be
equal.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
