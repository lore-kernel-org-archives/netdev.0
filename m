From: Patrick McHardy <kaber@trash.net>
Subject: Re: Linux, tcpdump and vlan
Date: Thu, 19 Jul 2007 02:19:27 +0200
Message-ID: <469EAE0F.5090607@trash.net>
References: <878246.51044.qm@web56608.mail.re3.yahoo.com> <469E9AC8.3090603@trash.net> <469EA0D1.6020406@candelatech.com> <469EA370.8000103@trash.net> <469EA9BF.4040603@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: andrei radulescu-banu <iubica2@yahoo.com>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51668 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932791AbXGSAUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 20:20:08 -0400
In-Reply-To: <469EA9BF.4040603@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> Patrick McHardy wrote:
> 
>> Its actually more a problem on the RX path. VLAN acceleration
>> works (at least with some drivers) by enabling HW header striping
>> and using the VLAN ID for an immediate lookup in the VLAN devices
>> configured on that device. So if the VLAN is not configured on the
>> real device but something like macvlan, it will get the packet
>> without a header and without any indication that this was a VLAN
>> packet. This is also what causes the tcpdump problem.
>>   
> 
> This reminded me of something:
> 
> If we are using VLAN HW-Accel, then the skb hits the mac-vlan check with
> the skb->dev == vlan-device.
> So, in this case, we can put mac-vlans on top of 802.1Q VLANs.
> 
> But, if we are not using VLAN hw-accel, the skb hits the mac-vlan check
> with skb->dev == ethernet-device.
> In this case, we could NOT have the mac-vlan on top of the 802.1Q VLAN,
> but we can have a MAC-VLAN
> on the raw ethernet and we could add 802.1Q vlans on top of the
> mac-vlan.  This is because the
> .1Q vlan will only be found once we go into the protocol handler logic,
> which is necessarily after the
> MAC-VLAN check logic.
> 
> Unless I am confused in my conjecture above, this is likely to confuse
> others who try to mix and
> match MAC-VLANs and 802.1Q VLANs.


The current code doesn't use hardware acceleration and works fine
in all combinations where only vlan *or* macvlan devices are used
on the underlying device.

If you mix them macvlan won't get to see vlan headers anymore,
same as for tcpdump, bridge devices, or anything else that
might care. A bridge eating VLAN headers should be a clearer
indication of a bug than an inaccurate tcpdump ..

The real problem is that the device removes the header for all
vlans, not only for those that are configured on the device.
This is a result of how the hardware works. But since we don't
have the data available later, we can't even fix it up in
software.

