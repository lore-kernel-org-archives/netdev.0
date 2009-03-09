From: Patrick McHardy <kaber@trash.net>
Subject: Re: MACVLANs really best solution? How about a bridge with multiple
 bridge virtual interfaces? (was Re: [PATCH] macvlan: Support creating macvlans
 from macvlans)
Date: Mon, 09 Mar 2009 16:02:11 +0100
Message-ID: <49B52F73.7010508@trash.net>
References: <20090307211527.6e76d0b9.nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>	<49B51A42.6050507@trash.net> <m11vt6d9t6.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark Smith
	<nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>,
	greearb@candelatech.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, shemminger@linux-foundation.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46689 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750941AbZCIPCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 11:02:16 -0400
In-Reply-To: <m11vt6d9t6.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> Patrick McHardy <kaber@trash.net> writes:
> 
>> I agree on most points. There is one fundamental operational difference
>> however. With macvlan, all MAC addresses are known are therefore can be
>> programmed as secondary unicast addresses, while a bridge always uses
>> promiscous mode and for unknown addresses needs to flood forward them.
>>
>> This could be changed in the bridging code of course for bridges
>> consisting purely of local devices. Most of the bridging stuff isn't
>> needed for macvlans though, so its probably easier to simply perform
>> a lookup for local devices in macvlan on transmit, similar to what
>> is done on reception.
> 
> What I haven't figured out is how you handle the transmit path for
> broadcast and multicast ethernet traffic.  How do you test to see if
> you have already preformed local transmission?

I'm not sure I understand the problem. Whats wrong with doing
the same as on transmit, i.e.:

- for multicast/broadcast, deliver everywhere (except self)

- for unicast, deliver to matching local macvlan device or
   underlying device

> +static int macvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	const struct macvlan_dev *vlan = netdev_priv(dev);
> +	const struct macvlan_port *port = vlan->port;
> +	const struct macvlan_dev *dest;
> +	const struct ethhdr *eth;
>  
> -	skb->dev = dev;
> -	skb->pkt_type = PACKET_HOST;
> +	skb->protocol = eth_type_trans(skb, dev);
> +	eth = eth_hdr(skb);
>  
> -	netif_rx(skb);
> -	return NULL;
> +	dst_release(skb->dst);
> +	skb->dst = NULL;
> +	skb->mark = 0;
> +	secpath_reset(skb);
> +	nf_reset(skb);
> +
> +	if (is_multicast_ether_addr(eth->h_dest)) {
> +		macvlan_broadcast(skb, port, dev);
> +		return macvlan_xmit_world(skb, dev);
> +	}
> +
> +	dest = macvlan_hash_lookup(port, eth->h_dest);
> +	if (dest)
> +		return macvlan_unicast(skb, dest);
> +			
> +	return macvlan_xmit_world(skb, dev);
>  }

Pretty much like this :)
