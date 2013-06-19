From: Jim Baxter <jim_baxter@mentor.com>
Subject: Re: VLAN driver question
Date: Wed, 19 Jun 2013 16:57:11 +0100
Message-ID: <51C1D4D7.1000904@mentor.com>
References: <51BF5F81.2040207@mentor.com> <1371566484.1956.16.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:53938 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756651Ab3FSP5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 11:57:16 -0400
In-Reply-To: <1371566484.1956.16.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you Ben, that is very helpful.

On 18/06/13 15:41, Ben Hutchings wrote:
> On Mon, 2013-06-17 at 20:12 +0100, Jim Baxter wrote:
>> I have a network card that has a single flag to indicate if a received
>> packet contains a vlan packet.
>>
>> Can I use this to accelerate the kernels handling of the packet with
>> something like the following?
>>
>> /* Handle received VLAN packets */
>> if ((ndev->features & NETIF_F_HW_VLAN_CTAG_RX) && ebdp &&
>> 					(ebdp->cbd_esc &
>> 					BD_ENET_RX_VLAN)) {
>> 	/* Push and remove the vlan tag */
>> 	struct vlan_hdr *vlan_header;
>> 	u16 vlan_tag;
>> 	vlan_header = (struct vlan_hdr *) skb->data;
>> 	vlan_tag = ntohs(vlan_header->h_vlan_TCI);
>> 	__vlan_hwaccel_put_tag(skb, vlan_tag);
>> 	skb->len -= VLAN_HLEN;
>> 	skb->data += VLAN_HLEN;
>> 	vlan_set_encap_proto(skb, vlan_header);
> 
> You have to move the Ethernet addresses forward as well.  Imagine this
> device is being bridged - the Ethernet header won't be regenerated, so
> it has to be immediately before the network header.
> 
Unless I have misunderstood, the Ethernet header is already copied
across to the skb by the Driver I am editing with the lines:
	skb_reserve(skb, NET_IP_ALIGN);
	skb_put(skb, pkt_len - 4);	/* Make room */
	skb_copy_to_linear_data(skb, data, pkt_len - 4);
	skb->protocol = eth_type_trans(skb, ndev);


Thinking about it though I should actually use the flag from the driver
to create an skb of the size (pkt_len - 4 - VLAN_HLEN) and extract the
vlan header from data so it is not copied to the skb, does this sound
sensible?

>> }
>>
>> napi_gro_receive(&fep->napi, skb);
> 
> I've been meaning to add a core function to do
> pull-out-VLAN-tag-and-GRO, although I'm more interested in
> napi_gro_frags().  Perhaps you could add the generic wrapper for
> napi_gro_receive()?
>
>> Also I cannot find any documentation stating what the difference is
>> between NETIF_F_HW_VLAN_CTAG_RX and NETIF_F_HW_VLAN_CTAG_FILTER, can
>> anyone define it?
>> The FILTER word on NETIF_F_HW_VLAN_CTAG_FILTER suggests it may be
>> applicable to received packets.
> 
> NETIF_F_HW_VLAN_CTAG_RX means the device will extract VLAN tags so they
> aren't received inline.
> 
> NETIF_F_HW_VLAN_CTAG_FILTER means the device can filter by VID.  The
> driver's ndo_vlan_rx_{add,kill}_vid operations will be called to update
> the filter.
> 
> Ben.
> 
Jim
