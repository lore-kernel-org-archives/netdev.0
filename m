From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH v9 net-next 4/7] openvswitch: add layer 3 flow/port
 support
Date: Fri, 6 May 2016 11:35:04 +0200
Message-ID: <20160506113504.77a9504e@griffin>
References: <1462347393-22354-1-git-send-email-simon.horman@netronome.com>
	<1462347393-22354-5-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Lorand Jakab <lojakab@cisco.com>,
	Thomas Morin <thomas.morin@orange.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45004 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751522AbcEFJfI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 May 2016 05:35:08 -0400
In-Reply-To: <1462347393-22354-5-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  4 May 2016 16:36:30 +0900, Simon Horman wrote:
> +static int push_eth(struct sk_buff *skb, struct sw_flow_key *key,
> +		    const struct ovs_action_push_eth *ethh)
> +{
> +	int err;
> +
> +	/* De-accelerate any hardware accelerated VLAN tag added to a previous
> +	 * Ethernet header */
> +	err = skb_vlan_deaccel(skb);
> +	if (unlikely(err))
> +		return err;
> +
> +	/* Add the new Ethernet header */
> +	if (skb_cow_head(skb, ETH_HLEN) < 0)
> +		return -ENOMEM;
> +
> +	skb_push(skb, ETH_HLEN);
> +	skb_reset_mac_header(skb);
> +	skb_reset_mac_len(skb);
> +
> +	ether_addr_copy(eth_hdr(skb)->h_source, ethh->addresses.eth_src);
> +	ether_addr_copy(eth_hdr(skb)->h_dest, ethh->addresses.eth_dst);
> +	eth_hdr(skb)->h_proto = ethh->eth_type;

This doesn't seem right. We know the packet type, it's skb->protocol.
We should fill in that.

In addition, we should check whether mac_len > 0 and in such case,
change skb->protocol to ETH_P_TEB first (and store that value in the
pushed eth header).

Similarly on pop_eth, we need to check skb->protocol and if it is
ETH_P_TEB, call eth_type_trans on the modified frame to set the new
skb->protocol correctly. It's probably not that simple, as we'd need a
version of eth_type_trans that doesn't need a net device.

 Jiri
