From: Ben Greear <greearb@candelatech.com>
Subject: Re: Linux, tcpdump and vlan
Date: Wed, 18 Jul 2007 17:01:03 -0700
Message-ID: <469EA9BF.4040603@candelatech.com>
References: <878246.51044.qm@web56608.mail.re3.yahoo.com> <469E9AC8.3090603@trash.net> <469EA0D1.6020406@candelatech.com> <469EA370.8000103@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: andrei radulescu-banu <iubica2@yahoo.com>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:47373 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762758AbXGSABM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2007 20:01:12 -0400
In-Reply-To: <469EA370.8000103@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Ben Greear wrote:
>   
>> Patrick McHardy wrote:
>>
>>     
>>> Put another way, once you enable VLAN header stripping, you
>>> won't see the headers for *any* VLAN, not only for those you're
>>> actually running locally. This is also a problem for devices
>>> like macvlan, where it would be desirable to make use of
>>> hardware VLAN accerlation. I was thinking about storing the
>>> information somewhere in the packets meta-data on both RX and
>>> TX paths, that would also allow tcpdump to properly display
>>> packets.
>>>   
>>>       
>> MAC-VLAN could gather this information based on it's parent
>> device (ie, if parent-dev has VID 7, then add VID 7 to the meta
>> data.  There would be no need for any driver changes I think.
>>     
>
>
> Its actually more a problem on the RX path. VLAN acceleration
> works (at least with some drivers) by enabling HW header striping
> and using the VLAN ID for an immediate lookup in the VLAN devices
> configured on that device. So if the VLAN is not configured on the
> real device but something like macvlan, it will get the packet
> without a header and without any indication that this was a VLAN
> packet. This is also what causes the tcpdump problem.
>   
This reminded me of something:

If we are using VLAN HW-Accel, then the skb hits the mac-vlan check with 
the skb->dev == vlan-device.
So, in this case, we can put mac-vlans on top of 802.1Q VLANs.

But, if we are not using VLAN hw-accel, the skb hits the mac-vlan check 
with skb->dev == ethernet-device.
In this case, we could NOT have the mac-vlan on top of the 802.1Q VLAN, 
but we can have a MAC-VLAN
on the raw ethernet and we could add 802.1Q vlans on top of the 
mac-vlan.  This is because the
.1Q vlan will only be found once we go into the protocol handler logic, 
which is necessarily after the
MAC-VLAN check logic.

Unless I am confused in my conjecture above, this is likely to confuse 
others who try to mix and
match MAC-VLANs and 802.1Q VLANs.

>>> I have planned to look into this when I find some time.
>>> Your suggestion of disabling VLAN acceleration in promiscous
>>> mode sounds like a reasonable solution until then ..
>>>   
>>>       
>> I think a better method would be to allow disabling VLAN HW accel for a
>> NIC with
>> ethtool.  Then, the packets will be received by the software stack with
>> the vlan
>> header intact.  Something sniffing on the physical dev will
>> automatically get the
>> VLAN header.
>>     
>
>
> That would also be fine. But considering that the TX path is
> problematic too, a clean solution for all of this would be
> to store the VLAN id in the skb. And we do have some holes
> to plug currently :)
>   

With VLAN HW accel disabled, the skb will have the VLAN header in it by 
the time it
hits the ethX interface, so sniffing there should still show the 
header.  It won't show
when sniffing the VLAN device, but I think that is OK.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


