From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: MACVLANs really best solution? How about a bridge with multiple bridge virtual interfaces?
Date: Mon, 09 Mar 2009 08:48:03 -0700
Message-ID: <m13admbsuk.fsf@fess.ebiederm.org>
References: <20090307211527.6e76d0b9.nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>
	<49B51A42.6050507@trash.net> <m11vt6d9t6.fsf@fess.ebiederm.org>
	<49B52F73.7010508@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Smith
	<nanog@85d5b20a518b8f6864949bd940457dc124746ddc.nosense.org>,
	greearb@candelatech.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, shemminger@linux-foundation.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:35294 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793AbZCIPsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 11:48:09 -0400
In-Reply-To: <49B52F73.7010508@trash.net> (Patrick McHardy's message of "Mon\, 09 Mar 2009 16\:02\:11 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy <kaber@trash.net> writes:

> Eric W. Biederman wrote:
>> Patrick McHardy <kaber@trash.net> writes:
>>
>>> I agree on most points. There is one fundamental operational difference
>>> however. With macvlan, all MAC addresses are known are therefore can be
>>> programmed as secondary unicast addresses, while a bridge always uses
>>> promiscous mode and for unknown addresses needs to flood forward them.
>>>
>>> This could be changed in the bridging code of course for bridges
>>> consisting purely of local devices. Most of the bridging stuff isn't
>>> needed for macvlans though, so its probably easier to simply perform
>>> a lookup for local devices in macvlan on transmit, similar to what
>>> is done on reception.
>>
>> What I haven't figured out is how you handle the transmit path for
>> broadcast and multicast ethernet traffic.  How do you test to see if
>> you have already preformed local transmission?
>
> I'm not sure I understand the problem. Whats wrong with doing
> the same as on transmit, i.e.:
>
> - for multicast/broadcast, deliver everywhere (except self)
>
> - for unicast, deliver to matching local macvlan device or
>   underlying device
>
>> +static int macvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
>> +{
>> +	const struct macvlan_dev *vlan = netdev_priv(dev);
>> +	const struct macvlan_port *port = vlan->port;
>> +	const struct macvlan_dev *dest;
>> +	const struct ethhdr *eth;
>>  -	skb->dev = dev;
>> -	skb->pkt_type = PACKET_HOST;
>> +	skb->protocol = eth_type_trans(skb, dev);
>> +	eth = eth_hdr(skb);
>>  -	netif_rx(skb);
>> -	return NULL;
>> +	dst_release(skb->dst);
>> +	skb->dst = NULL;
>> +	skb->mark = 0;
>> +	secpath_reset(skb);
>> +	nf_reset(skb);
>> +
>> +	if (is_multicast_ether_addr(eth->h_dest)) {
>> +		macvlan_broadcast(skb, port, dev);
>> +		return macvlan_xmit_world(skb, dev);
>> +	}
>> +
>> +	dest = macvlan_hash_lookup(port, eth->h_dest);
>> +	if (dest)
>> +		return macvlan_unicast(skb, dest);
>> +			
>> +	return macvlan_xmit_world(skb, dev);
>>  }
>
> Pretty much like this :)

Yes.

There are two tricky parts.

One problem is that macvlans and the primary hardware device share the
same transmit queue.  So when I have a broadcast packet on the primary
devices queue I don't know if I have already sent it out to the
macvlan devices or not.

The second problem is that when I transmit a multicast packet and I
have a local listener.  I believe replicating the packet both at the
ip layer and at the ethernet layer will result in receiving the packet
locally twice.

I'm not certain we need to solve the second problem as having two physical
interfaces plugged into a switch will have the same problem.

The first problem is all about how do we deliver packets everywhere except self.

Eric
