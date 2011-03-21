From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH][v3] dev : fix mtu check when TSO is enabled
Date: Mon, 21 Mar 2011 15:58:39 -0700
Message-ID: <m1pqpkf5cw.fsf@fess.ebiederm.org>
References: <1300135190-14093-1-git-send-email-daniel.lezcano@free.fr>
	<20110314.165929.232913682.davem@davemloft.net>
	<4D7F7054.70409@free.fr> <20110315111756.64b5f4b1@nehalam>
	<4D80C179.8000900@free.fr> <20110316083510.5b9d8c72@nehalam>
	<4D80E302.9010806@free.fr> <20110316094535.5ac6acd8@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Lezcano <daniel.lezcano@free.fr>,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	kaber@trash.net, nightnord@gmail.com, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:43756 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754792Ab1CUW6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 18:58:45 -0400
In-Reply-To: <20110316094535.5ac6acd8@nehalam> (Stephen Hemminger's message of
	"Wed, 16 Mar 2011 09:45:35 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> writes:

> On Wed, 16 Mar 2011 17:19:14 +0100
> Daniel Lezcano <daniel.lezcano@free.fr> wrote:
>
>> On 03/16/2011 04:35 PM, Stephen Hemminger wrote:
>> > On Wed, 16 Mar 2011 14:56:09 +0100
>> > Daniel Lezcano<daniel.lezcano@free.fr>  wrote:
>> >
>> >> On 03/15/2011 07:17 PM, Stephen Hemminger wrote:
>> >>> On Tue, 15 Mar 2011 14:57:40 +0100
>> >>> Daniel Lezcano<daniel.lezcano@free.fr>   wrote:
>> >>>
>> >>>> On 03/15/2011 12:59 AM, David Miller wrote:
>> >>>>> From: Daniel Lezcano<daniel.lezcano@free.fr>
>> >>>>> Date: Mon, 14 Mar 2011 21:39:50 +0100
>> >>>>>
>> >>>>>> +	len = dev->mtu + dev->hard_header_len + VLAN_HLEN;
>> >>>>>> +	if (skb->len<    len)
>> >>>>>> +		return true;
>> >>>>> This is not a correct translation of the original test:
>> >>>>>
>> >>>>>> -		     (skb->len>    (dev->mtu + dev->hard_header_len + VLAN_HLEN)))) {
>> >>>>> You need to use "<=" in your version, which currently rejects all
>> >>>>> full sized frames. :-)
>> >>>> Right, thanks.
>> >>>>
>> >>>>>> +
>> >>>>>> +	/* if TSO is enabled, we don't care about the length as the packet
>> >>>>>> +	 * could be forwarded without being segmented before
>> >>>>>> +	 */
>> >>>>>> +	if (skb->dev&&    skb->dev->features&    NETIF_F_TSO)
>> >>>>>> +		return true;
>> >>>>> I am trying to understand why you aren't simply checking also if this
>> >>>>> is a segmented frame?  Perhaps skb_is_gso()&&    device has NETIF_F_TSO
>> >>>>> set?
>> >>>> Maybe I am misunderstanding but the packet was forwarded by another device.
>> >>>> In our case from macvlan:
>> >>>>
>> >>>> macvlan_start_xmit
>> >>>>        macvlan_queue_xmit
>> >>>>            dest->forward
>> >>>>                dev_skb_forward
>> >>>>
>> >>>> When we reached dev_skb_forward, that means we passed through
>> >>>> dev_hard_start_xmit where the packet was already segmented so we should
>> >>>> exit at the first test (skb->len<   len). I don't see the point of adding
>> >>>> the skb_is_gso.
>> >>>> But maybe I am missing something, can you explain ?
>> >>> The macvlan device only has one downstream device (slave).
>> >>> If kernel is working properly, macvlan device should have a subset
>> >>> of the features of the underlying device
>> >> Right, dev->features = lowerdev->features&  MACVLAN_FEATURES
>> >>
>> >>> and macvlan device should
>> >>> have same MTU as underlying device.
>> >> Right,
>> >>
>> >> ...
>> >>
>> >>    if (!tb[IFLA_MTU])
>> >>           dev->mtu = lowerdev->mtu;
>> >>
>> >> ...
>> >>> If the feature/MTU flags
>> >>> were correct, then the path calling macvlan should be respecting
>> >>> the MTU.
>> >> But if the TSO is enabled on the macvlan (inherited from eg e1000), the
>> >> packet won't be fragmented to the mtu size no ?
>> > That is the responsiblity of the hardware that receives the packet.
>> > Macvlan should be passing it through to the lowerdev and since the hardware
>> > supports TSO, it will fragment it.
>> 
>> Ok, but in the case the macvlan is in bridge mode, the dev_skb_forward 
>> function will forward the packet (which is not fragmented) to to another 
>> macvlan port without going through the hardware driver. In this 
>> function, the packet length is checked against the mtu size and of 
>> course the packet is dropped in case the lower device support the TSO 
>> (if the packet is larger than the mtu size). Dave suggested to check 
>> skb_is_gso and against the TSO feature of the macvlan but I don't 
>> understand why we should check skb_is_gso too.
>> 
>> 	if (skb_is_gso(skb)&&  (skb->dev&&  skb->dev->features&  NETIF_F_TSO))
>> 		return true;
>> 
>> 
>
> Then it is up to macvlan to do the same thing as bridge code.
>
> static inline unsigned packet_length(const struct sk_buff *skb)
> {
> 	return skb->len - (skb->protocol == htons(ETH_P_8021Q) ? VLAN_HLEN : 0);
> }

Which is incorrect in this context.  skb->len at this point in the code
includes the ethernet header, as we are down below dev_queue_xmit.

The test really does need to be dev->mtu + dev->hard_header_len. 

As for conditionally include the VLAN_HLEN that is likely doable but I
think if we are being pedantic that case needs to deal with accelerated
vlan headers.

> int br_dev_queue_push_xmit(struct sk_buff *skb)
> {
> 	/* ip_fragment doesn't copy the MAC header */
> 	if (nf_bridge_maybe_copy_header(skb) ||
> 	    (packet_length(skb) > skb->dev->mtu && !skb_is_gso(skb))) {
> 		kfree_skb(skb);
> 	} else {
> 		skb_push(skb, ETH_HLEN);
> 		dev_queue_xmit(skb);
> 	}
e>
> 	return 0;
> }


> Ps: not sure adding macvlan bridge mode was a good idea, we already have
> a working bridge code. And there are too many missing pieces in the macvlan
> implementation of bridging

The macvlan is a trivial bridge that doesn't need to do learning as it
knows every mac address it can receive, so it doesn't need to implement
learning or stp.  Which makes it simple stupid and and fast.

Strictly speaking the problems we are running into are the problems of
hardware acceleration and software devices, not properly providing the
same interfaces as the hardware.  To not take a significant hit on
performance we do want hardware acceleration on the path to real
hardware from the transmitter.

To use the network bridge to cross network namespaces we would have to
add veth pairs and unless something has drastically changed we would
still need to emulate all of the hardware acceleration in so the
dev_forward_skb so that we don't provide a device to the bridge that
has lesser capabilities than the real hardware and downgrade the
capabilities of the entire bridge.

So I don't think there is much that would be gained by using bridges
instead of the macvlan driver.

Eric
