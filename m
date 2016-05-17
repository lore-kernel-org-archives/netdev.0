From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH v9 net-next 4/7] openvswitch: add layer 3 flow/port
 support
Date: Tue, 17 May 2016 16:32:50 +0200
Message-ID: <20160517163250.7ead555e@griffin>
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
Received: from mx1.redhat.com ([209.132.183.28]:35758 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932188AbcEQOcy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 May 2016 10:32:54 -0400
In-Reply-To: <1462347393-22354-5-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looking through the patchset again, this time more deeply. Sorry for
the delay.

On Wed,  4 May 2016 16:36:30 +0900, Simon Horman wrote:
> +struct ovs_action_push_eth {
> +	struct ovs_key_ethernet addresses;
> +	__be16   eth_type;

Extra spaces.

> +static int pop_eth(struct sk_buff *skb, struct sw_flow_key *key)
> +{
> +	skb_pull_rcsum(skb, ETH_HLEN);
> +	skb_reset_mac_header(skb);
> +	skb->mac_len -= ETH_HLEN;
> +
> +	invalidate_flow_key(key);
> +	return 0;
> +}

There's a fundamental question here: how should pop_eth behave when
vlan tag is present?

There are two options: either vlan is considered part of the Ethernet
header and pop_eth means implicitly resetting vlan tag, or packet can
have vlan tag even if it's not Ethernet.

This patch seems to implement the first option; however, skb->vlan_tci
should be reset and pop_eth should check whether the vlan tag is
present in the frame (deaccelerated) and remove it if it is. Otherwise,
the behavior of pop_eth would be inconsistent.

However, I'm not sure whether the second option does not make more
sense. It may, in fact, be needed - ARPHRD_NONE tunnel port could not
be set as an access port otherwise (unless I'm missing something).

In that case, pop_eth will need to put the vlan tag to skb->vlan_tci if
it's in the frame itself. Also, push_vlan and pop_vlan would need to be
modified to work with is_layer3 packets.

> +static int push_eth(struct sk_buff *skb, struct sw_flow_key *key,
> +		    const struct ovs_action_push_eth *ethh)
> +{
> +	int err;
> +
> +	/* De-accelerate any hardware accelerated VLAN tag added to a previous
> +	 * Ethernet header */
> +	err = skb_vlan_deaccel(skb);

Why? Just keep it in skb->vlan_tci.

> --- a/net/openvswitch/flow.c
> +++ b/net/openvswitch/flow.c
> @@ -468,28 +468,31 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
>  
>  	skb_reset_mac_header(skb);
>  
> -	/* Link layer.  We are guaranteed to have at least the 14 byte Ethernet
> -	 * header in the linear data area.
> -	 */
> -	eth = eth_hdr(skb);
> -	ether_addr_copy(key->eth.src, eth->h_source);
> -	ether_addr_copy(key->eth.dst, eth->h_dest);
> +	/* Link layer. */
> +	if (key->phy.is_layer3) {
> +		key->eth.tci = 0;

Could make sense to use skb->vlan_tci, see above.

Thanks,

 Jiri
