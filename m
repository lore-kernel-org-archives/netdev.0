From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: Question regarding MAC address configuraton with VLAN devices
Date: Tue, 07 Apr 2015 08:44:09 -0700
Message-ID: <5523FB49.9010107@redhat.com>
References: <31AFFC7280259C4184970ABA9AFE8B93E0930C40@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: Manish Chopra <manish.chopra@qlogic.com>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45644 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754837AbbDGPoL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Apr 2015 11:44:11 -0400
In-Reply-To: <31AFFC7280259C4184970ABA9AFE8B93E0930C40@avmb3.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 04/01/2015 12:15 PM, Manish Chopra wrote:
> Hello Patrick,
>
> I have a question regarding MAC address configuration of network devices specially
> when VLANs are configured on that. Can you please help to address?
>
> When user changes MAC address of a base network device [e.g., via ifconfig]
> why existing VLAN device on top of that would add it's previous MAC address to
> unicast list of base device instead of adapting the new MAC address
> in it's own net device?
>
> What we are trying to achieve here is that -
>
> For a VF, if Hypervisor/Administrator has forced a MAC [e.g., via iproute2] then as a part of
> "learning process [of the new hypervisor forced mac] done by VF driver", it will simply call
> "call_netdevice_notifiers(NETDEV_CHANGEADDR, dev)", which would notify the address change
> to VLAN interfaces configured on top of VF device and they will adapt the hypervisor forced MAC too.
> But that's not seems to be the behavior here, instead VLAN device on top of the VF device seems to be adding
> It's previous MAC address to unicast list of base VF device. This configuration will not take effect
> [since PF is blocking the VF's additional unicast MACs, if once a MAC has been forced to the VF], thus
> effectively the VLAN interface will never receive traffic with it's configured MAC.
>
>
> Regards,
> Manish

What you are proposing would likely require significant changes to more 
than just VLANs.  It would have an impact on all stacked devices since 
normally the assumption is that we push addresses down, not up.  That is 
why the vlan_sync_address is simply checking to see if its current 
address is supported before pushing the address down.

Maybe we should look into adding some sort of flag to indicate that the 
address table is locked, like a IFF_L2_ADDR_LOCKED in order to indicate 
that the device only supports one L2 address and cannot be changed.  
Then you could probably pass that up to higher levels to force things 
like the address change you want in VLAN, and things like MACVLAN would 
simply fail if that flag is set.

- Alex
