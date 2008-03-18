From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 1/8] e1000: Convert boolean_t to bool
Date: Tue, 18 Mar 2008 10:04:55 -0700
Message-ID: <47DFF637.9080903@intel.com>
References: <20080317162939.4861.91040.stgit@localhost.localdomain>	 <1205772403.26361.8.camel@localhost>  <47DEA67F.9050205@intel.com> <1205858476.26361.34.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53088 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754667AbYCSThU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Mar 2008 15:37:20 -0400
In-Reply-To: <1205858476.26361.34.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches wrote:
> On Mon, 2008-03-17 at 10:12 -0700, Kok, Auke wrote:
>> Joe Perches wrote:
>>> On Mon, 2008-03-17 at 09:29 -0700, Auke Kok wrote:
>>>> On Thu, 2008-03-06 at 10:07 -0800, Kok, Auke wrote:
>>>>> send me a patch for e1000 and for ixgb and I'll happily apply those :)
>>> I gather you didn't run the little script to convert
>>> the u[_]*int\(8|16|32|64\) to u\1 uses? (u_int8_t -> u8, etc)
>>> Did you need or want actual patches to do that?
>> I'll take a patch for that and yes, I was too busy to do this myself just now :)
> 
> I just sent you a bunch of patches to do this conversion.
> 
> I started on doing a kind-of checkpatch/Lindent pass on e1000.
> 
> Some of the functions in e1000 are heavily indented
> and could be neatened with a little bit of rewrite.
> 
> For instance, here's a function in e1000_main.c
> 
> It's a little bit hard to understand with the indenting
> and breakup of the lines.  I think the rewrite below it
> is shorter and easier to read.
> 
> Do you want these sorts of changes too?

yeah absolutely

maybe this is a bit premature since we're going to have much more fun taking out
all the pci express code after 2.6.26 but we might as well start to queue this
stuff up now - at least I can keep it in a branch locally and this is exactly what
we need to do anyway

> static int
> e1000_transfer_dhcp_info(struct e1000_adapter *adapter, struct sk_buff *skb)
> {
> 	struct e1000_hw *hw =  &adapter->hw;
> 	u16 length, offset;
> 
> 	if (vlan_tx_tag_present(skb)) {
> 		if (!((vlan_tx_tag_get(skb) == adapter->hw.mng_cookie.vlan_id) &&
> 			( adapter->hw.mng_cookie.status &
> 			  E1000_MNG_DHCP_COOKIE_STATUS_VLAN_SUPPORT)) )
> 			return 0;
> 	}
> 	if (skb->len > MINIMUM_DHCP_PACKET_SIZE) {
> 		struct ethhdr *eth = (struct ethhdr *) skb->data;
> 		if ((htons(ETH_P_IP) == eth->h_proto)) {
> 			const struct iphdr *ip =
> 				(struct iphdr *)((u8 *)skb->data+14);
> 			if (IPPROTO_UDP == ip->protocol) {
> 				struct udphdr *udp =
> 					(struct udphdr *)((u8 *)ip +
> 						(ip->ihl << 2));
> 				if (ntohs(udp->dest) == 67) {
> 					offset = (u8 *)udp + 8 - skb->data;
> 					length = skb->len - offset;
> 
> 					return e1000_mng_write_dhcp_info(hw,
> 							(u8 *)udp + 8,
> 							length);
> 				}
> 			}
> 		}
> 	}
> 	return 0;
> }
> 
> could be:
> 
> static int e1000_transfer_dhcp_info(struct e1000_adapter *adapter,
> 				    struct sk_buff *skb)
> {
> 	struct e1000_hw *hw = &adapter->hw;
> 	struct ethhdr *eth;
> 	const struct iphdr *ip;
> 	struct udphdr *udp;
> 	u16 length, offset;
> 
> 	if (vlan_tx_tag_present(skb) &&
> 	    (!((vlan_tx_tag_get(skb) == adapter->hw.mng_cookie.vlan_id)
> 	       && (adapter->hw.mng_cookie.status
> 		   & E1000_MNG_DHCP_COOKIE_STATUS_VLAN_SUPPORT))))
> 		return 0;
> 	if (skb->len <= MINIMUM_DHCP_PACKET_SIZE)
> 		return 0;
> 	eth = (struct ethhdr *)skb->data;
> 	if (eth->h_proto != htons(ETH_P_IP))
> 		return 0;
> 	ip = (struct iphdr *)((u8 *)skb->data + 14);
> 	if (ip->protocol != IPPROTO_UDP)
> 		return 0;
> 	udp = (struct udphdr *)((u8 *)ip + (ip->ihl << 2));
> 	if (ntohs(udp->dest) != 67)
> 		return 0;
> 
> 	offset = (u8 *)udp + 8 - skb->data;
> 	length = skb->len - offset;
> 
> 	return e1000_mng_write_dhcp_info(hw, (u8 *)udp + 8, length);
> }

yeah, much better :)

