From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: e1000e max frame calculation
Date: Mon, 06 Apr 2015 16:17:57 -0700
Message-ID: <55231425.4010405@redhat.com>
References: <5522B685.2030104@cchtml.com> <5522FE84.6030104@cchtml.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Michael Cronenworth <mike@cchtml.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55910 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751130AbbDFXR6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Apr 2015 19:17:58 -0400
In-Reply-To: <5522FE84.6030104@cchtml.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 04/06/2015 02:45 PM, Michael Cronenworth wrote:
> Preface: I am not here to start a discussion about header sizes or 
> hardware limits. This is solely about the calculation used to limit a 
> user when they pass a MTU to a driver.
>
> On 04/06/2015 11:38 AM, Michael Cronenworth wrote:
>> Other drivers appear to be using the "old" maximum frame calculation 
>> and can
>> continue to use 9000.
>>
>> Can a standard be decided upon that all drivers use or is it 
>> acceptable that one
>> driver "does its own thing?"
>
> To be specific here are some examples of maximum MTU calculation and 
> their tests:
>
> sky2: user_mtu > ETH_JUMBO_MTU
>
> r8169: user_mtu < ETH_ZLEN || user_mtu > (ETH_DATA_LEN||x*1024 - 
> ETH_HLEN - 2)
>
> igb:   user_mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN > 
> MAX_JUMBO_FRAME_SIZE
>
> e1000e <3.15:  user_mtu + ETH_HLEN + ETH_FCS_LEN > 
> adapter->max_hw_frame_size;
>
> e1000e >=3.15: user_mtu + VLAN_HLEN + ETH_HLEN + ETH_FCS_LEN >
>                   adapter->max_hw_frame_size;
>
> Let's say the hardware has a limit of 4096 bytes. The user wishes to 
> set an MTU of 4078 bytes.
>
> sky2: false, mtu is set
>
> r8169: false, mtu is set
>
> igb: true, mtu is not set
>
> e1000e <3.15: false, mtu is set
>
> e1000e <3.15: true, mtu is not set
>
> So some drivers work with the 4078 MTU and some do not. They all had 
> the same hardware limit, but their driver's software calculated limit 
> was different. Am I crazy?

That isn't really a fair comparison and gets back to my original response.

If the hardware limit was 4096 bytes many of those static defines in the 
other drivers would likely be very different.  For example in the case 
if igb I think the hardware limit is somewhere around 9.5K, but the fact 
is 9K(9216, not 9000) is used as there isn't much demand for jumbo frame 
sizes over 9000 and things can be kept pretty simple since you can drop 
a bunch of VLAN headers in with all that wiggle room left over.  Another 
thing to check would be how many of these parts support the option of 
toggling VLAN tag stripping and RXFCS stripping.  That is the reason why 
these sizes were changed as these impact the resultant buffer size.

The e1000e pch parts seem very limited in terms of their jumbo frames 
support.  It looks like the first pch part only supported 4K, and in the 
case of the later generations I only see support for a 9018 jumbo frame 
listed in the datasheet.  I suspect this is why that is set as the limit 
in the driver.  The question at this point is if 9018 is the limit, why 
is it the limit and is there any wiggle room to it.

- Alex
