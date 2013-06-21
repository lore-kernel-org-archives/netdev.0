From: Jim Baxter <jim_baxter@mentor.com>
Subject: Re: VLAN driver question
Date: Fri, 21 Jun 2013 18:02:42 +0100
Message-ID: <51C48732.7040601@mentor.com>
References: <51BF5F81.2040207@mentor.com>   <1371566484.1956.16.camel@bwh-desktop.uk.level5networks.com>   <51C1D4D7.1000904@mentor.com>  <1371659635.1956.45.camel@bwh-desktop.uk.level5networks.com>  <51C3527D.1030304@mentor.com> <1371829351.3570.48.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:60522 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423279Ab3FURCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 13:02:46 -0400
In-Reply-To: <1371829351.3570.48.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/06/13 16:42, Ben Hutchings wrote:
> On Thu, 2013-06-20 at 20:05 +0100, Jim Baxter wrote:
> [...]
>> Thank you for that information, I have decided to extract the data
>> before copying the data into the skb->data structure.
>>
>> This is the put of the packet showing my removal of the data correctly,
>> however the network is not receiving any data on the VLAN.
>>
>> - data buffer from the Network card
>> ff ff ff ff ff ff 00 26 b9 d4 19 01 81 00 00 0a 08 06 00 01 08 00 06 04
>> 00 01 00 26 b9 d4
>>
>> - skb->data after I have only copied data to it and removed the vlan 4
>> octet header using skb_copy_to_linear_data and
>> skb_copy_to_linear_data_offset.
>> ff ff ff ff ff ff 00 26 b9 d4 19 01 08 06 00 01 08 00 06 04 00 01 00 26
>> b9 d4 19 01 c0 a8
>>
>> - skb-data after eth_type_trans()
>> 00 01 08 00 06 04 00 01 00 26 b9 d4 19 01 c0 a8 01 67 00 00 00 00 00 00
>> c0 a8 01 64 00 00
>>
>> After this point I send the packet into the network stack with:
>> 	__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_tag);
>>
>> 	napi_gro_receive(&fep->napi, skb);
>>
>> Am I missing a kernel call or doing something wrong to cause the packet
>> to be rejected in the kernel?
> 
> That looks about right to me, but perhaps vlan_tag has the wrong byte
> order?  __vlan_hwaccel_put_tag() expects it in host byte order.
> 
> Ben.
> 

Hi, Thank you, I have got it working. The problem was that when I had
changed the code to remove the VLAN before putting the data into the
skb, I was not moving the pointer past the TPID.

It now all works with ping, ssh and scp'ing small files but when I scp a
large file it stalls. I suspect it is because it is not processing
packets that are at the MTU of 1518 bytes (1522 bytes with the VLAN
header) in size.

Jim
