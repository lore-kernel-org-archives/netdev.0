From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Tue, 12 Jun 2007 14:46:50 -0700
Message-ID: <466F144A.3070809@candelatech.com>
References: <20070612.140240.00078635.davem@davemloft.net>	<466F0C92.5080306@garzik.org>	<466F0D78.7090404@candelatech.com> <20070612.142658.45082832.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, kaber@trash.net,
	hadi@cyberus.ca, peter.p.waskiewicz.jr@intel.com,
	auke-jan.h.kok@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:50395 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751198AbXFLVrH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 17:47:07 -0400
In-Reply-To: <20070612.142658.45082832.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Ben Greear <greearb@candelatech.com>
> Date: Tue, 12 Jun 2007 14:17:44 -0700
> 
>> Jeff Garzik wrote:
>>> If hardware w/ multiple queues will the capability for different MAC 
>>> addresses, different RX filters, etc. does it make sense to add that 
>>> below the net_device level?
>>>
>>> We will have to add all the configuration machinery at the per-queue 
>>> level that already exists at the per-netdev level.
>> Perhaps the mac-vlan patch would be a good fit.  Currently it is all
>> software based, but if the hardware can filter on MAC, it can basically
>> do mac-vlan acceleration.  The mac-vlan devices are just like 'real' ethernet
>> devices, so they can be used with whatever schemes work with regular devices.
> 
> Interesting.
> 
> But to answer Jeff's question, that's not really the model being
> used to implement multiple queues.
> 
> The MAC is still very much centralized in most designs.
> 
> So one way they'll do it is to support assigning N MAC addresses,
> and you configure the input filters of the chip to push packets
> for each MAC to the proper receive queue.
> 
> So the MAC will accept any of those in the N MAC addresses as
> it's own, then you use the filtering facilities to steer
> frames to the correct RX queue.
> 
> The TX and RX queues can be so isolated as to be able to be exported
> to virtualization nodes.  You can give them full access to the DMA
> queues and assosciated mailboxes.  So instead of all of this bogus
> virtualized device overhead, you just give the guest access to the
> real device.
> 
> So you can use multiple queues either for better single node SMP
> performance, or better virtualization performance.

That sounds plausible for many uses, but it may also be useful to have
the virtual devices.  Having 802.1Q VLANs be 'real' devices has worked out
quite well, so I think there is a place for a 'mac-vlan' as well.

With your description above, the 'correct RX queue' could be the
only queue that the mac-vlan sees, so it would behave somewhat like
a vanilla ethernet driver.  When the mac-vlan transmits, it could
transmit directly into it's particular TX queue on the underlying device.

In a non guest environment, I believe the mac-vlan will act somewhat like
a more flexible form of an ip-alias.  When name-spaces are implemented,
the mac-vlan would very easily allow the different name-spaces to share the same physical
hardware.  The overhead should be minimal, and it's likely that using
a 'real' network device will be a lot easier to maintain than trying to directly
share separate queues on a single device that is somehow visible in multiple
namespaces.

And, since the mac-vlan can work as pure software on top of any NIC that
can go promisc and send with arbitrary source MAC, it will already work
with virtually all wired ethernet devices currently in existence.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

