From: Jim Baxter <jim_baxter@mentor.com>
Subject: Re: VLAN driver question
Date: Thu, 20 Jun 2013 20:05:33 +0100
Message-ID: <51C3527D.1030304@mentor.com>
References: <51BF5F81.2040207@mentor.com>  <1371566484.1956.16.camel@bwh-desktop.uk.level5networks.com>  <51C1D4D7.1000904@mentor.com> <1371659635.1956.45.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:61068 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422731Ab3FTTFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 15:05:38 -0400
In-Reply-To: <1371659635.1956.45.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/06/13 17:33, Ben Hutchings wrote:
> On Wed, 2013-06-19 at 16:57 +0100, Jim Baxter wrote:
>> Thank you Ben, that is very helpful.
>>
>> On 18/06/13 15:41, Ben Hutchings wrote:
>>> On Mon, 2013-06-17 at 20:12 +0100, Jim Baxter wrote:
>>>> I have a network card that has a single flag to indicate if a received
>>>> packet contains a vlan packet.
>>>>
>>>> Can I use this to accelerate the kernels handling of the packet with
>>>> something like the following?
>>>>
>>>> /* Handle received VLAN packets */
>>>> if ((ndev->features & NETIF_F_HW_VLAN_CTAG_RX) && ebdp &&
>>>> 					(ebdp->cbd_esc &
>>>> 					BD_ENET_RX_VLAN)) {
>>>> 	/* Push and remove the vlan tag */
>>>> 	struct vlan_hdr *vlan_header;
>>>> 	u16 vlan_tag;
>>>> 	vlan_header = (struct vlan_hdr *) skb->data;
>>>> 	vlan_tag = ntohs(vlan_header->h_vlan_TCI);
>>>> 	__vlan_hwaccel_put_tag(skb, vlan_tag);
>>>> 	skb->len -= VLAN_HLEN;
>>>> 	skb->data += VLAN_HLEN;
>>>> 	vlan_set_encap_proto(skb, vlan_header);
>>>
>>> You have to move the Ethernet addresses forward as well.  Imagine this
>>> device is being bridged - the Ethernet header won't be regenerated, so
>>> it has to be immediately before the network header.
>>>
>> Unless I have misunderstood, the Ethernet header is already copied
>> across to the skb by the Driver I am editing with the lines:
>> 	skb_reserve(skb, NET_IP_ALIGN);
>> 	skb_put(skb, pkt_len - 4);	/* Make room */
>> 	skb_copy_to_linear_data(skb, data, pkt_len - 4);
>> 	skb->protocol = eth_type_trans(skb, ndev);
> 
> Right, but the copy and ether_type_trans() result in an skb like this:
> 
> -14 -8  -2   0   2    4
> |dst|src|8100|vid|type|payload...|
>              ^
> 
> After extracting the VLAN tag the skb looks like:
> 
> -18 -12 -6   -4  -2   0
> |dst|src|8100|vid|type|payload...|
>                       ^
> 
> If this packet is bridged, the 14 bytes before skb->data will be treated
> as the Ethernet header:
> 
> 0 2   8    10  12   14
> |x|src|8100|vid|type|payload...|
> ^
> 
> Then with the VLAN tag inserted;
> 
> 0 2   8    10  12   14  16   18
> |x|src|8100|vid|8100|vid|type|payload...|
> 
>> Thinking about it though I should actually use the flag from the driver
>> to create an skb of the size (pkt_len - 4 - VLAN_HLEN) and extract the
>> vlan header from data so it is not copied to the skb, does this sound
>> sensible?
> [...]
> 
> That would also work.
> 
> Ben.
> 

Thank you for that information, I have decided to extract the data
before copying the data into the skb->data structure.

This is the put of the packet showing my removal of the data correctly,
however the network is not receiving any data on the VLAN.

- data buffer from the Network card
ff ff ff ff ff ff 00 26 b9 d4 19 01 81 00 00 0a 08 06 00 01 08 00 06 04
00 01 00 26 b9 d4

- skb->data after I have only copied data to it and removed the vlan 4
octet header using skb_copy_to_linear_data and
skb_copy_to_linear_data_offset.
ff ff ff ff ff ff 00 26 b9 d4 19 01 08 06 00 01 08 00 06 04 00 01 00 26
b9 d4 19 01 c0 a8

- skb-data after eth_type_trans()
00 01 08 00 06 04 00 01 00 26 b9 d4 19 01 c0 a8 01 67 00 00 00 00 00 00
c0 a8 01 64 00 00

After this point I send the packet into the network stack with:
	__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_tag);

	napi_gro_receive(&fep->napi, skb);

Am I missing a kernel call or doing something wrong to cause the packet
to be rejected in the kernel?

Thank you for any help,
Jim
