From: Kyle Moffett <mrmacman_g4@mac.com>
Subject: Re: [BUG][debian-2.6.20-1-686] bridging + vlans + "vconfig rem" == stuck kernel
Date: Sat, 12 May 2007 08:13:56 -0400
Message-ID: <7CD8681B-DC79-458A-91E4-81717AF26906@mac.com>
References: <2638DE26-D672-4245-BE88-D13B7F0F34A9@mac.com> <46429ED2.10809@candelatech.com> <EE6715FC-176D-4DA3-A0B3-6BDCC16122A6@mac.com> <ECE5C33E-2B09-4231-BEC3-4F0D7C677449@mac.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LKML Kernel <linux-kernel@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	OSDL Linux Bridging <bridge@osdl.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout.mac.com ([17.250.248.183]:51520 "EHLO smtpout.mac.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754285AbXELMOG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 May 2007 08:14:06 -0400
In-Reply-To: <ECE5C33E-2B09-4231-BEC3-4F0D7C677449@mac.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On May 11, 2007, at 01:49:27, Kyle Moffett wrote:
> On May 10, 2007, at 00:34:11, Kyle Moffett wrote:
>> On May 10, 2007, at 00:25:54, Ben Greear wrote:
>>> Looks like a deadlock in the vlan code.  Any chance you can run  
>>> this test with lockdep enabled?
>>>
>>> You could also add a printk in vlan_device_event() to check which  
>>> event it is hanging on, and the netdevice that is passed in.
>>
>> Ok, I'll try building a 2.6.21 kernel with lockdep and some  
>> debugging printk()s in the vlan_device_event() function and get  
>> back to you tomorrow.  Thanks for the quick response!

[snip]

> ifup -a brings up the interfaces in this order (See previous email  
> for configuration details):
> lo net0 wfi0 world0 lan lan:0 world
>
> ifdown -a appears to bring them down in the same order (at least,  
> until it gets stuck).

Hmm, turns out that it always hung downing this entry in my  
interfaces file, independent of ordering:

iface world0 inet manual
	mac-address 8b:8d:cb:91:e2:4c
	minimally-up yes
	vlan-dev net0
	vlan-id 4094

By commenting out the MAC address line it worked.  Yes, I realize the  
MAC address specified there is bogus, I managed to {think,type}o that  
one somehow.  I had been intending to specify a locally-allocated  
virtual MAC address on world0 but instead I managed to somehow assign  
one with the MAC multicast bit set (01:00:00:00:00:00)
If I change the above garbage MAC to 02:00:00:00:00:01 (first 02 is  
the locally-administrated bit) then it seems to work perfectly fine,   
My guess that the bridging code doesn't properly drop all references  
to world0 when it has that garbage MAC address on it (since the  
problem only shows up when both the invalid mac-address is present  
*AND* I start the "world" bridge).  I suppose this isn't really a big  
problem, but it would be nice if things didn't leak refcounts on  
invalid input.

Cheers,
Kyle Moffett

