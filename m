From: Joseph Glanville <joseph.glanville@orionvm.com.au>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Tue, 7 Aug 2012 13:37:09 +1000
Message-ID: <CAOzFzEjE9g5XxzSakn=HwT58ojZUuHLDrGausi4sULWSJV3mkA@mail.gmail.com>
References: <501C3527.6060809@mellanox.com>
	<20120803.143315.151094375569109262.davem@davemloft.net>
	<501C5328.4060301@mellanox.com>
	<20120803.163627.1867181085116225405.davem@davemloft.net>
	<50205DE0.7080706@mellanox.com>
	<87obmnfs4p.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ali Ayoub <ali@mellanox.com>, David Miller <davem@davemloft.net>,
	ogerlitz@mellanox.com, roland@kernel.org, netdev@vger.kernel.org,
	sean.hefty@intel.com, erezsh@mellanox.co.il, dledford@redhat.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:64350 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757217Ab2HGDhK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 23:37:10 -0400
Received: by obbuo13 with SMTP id uo13so6872813obb.19
        for <netdev@vger.kernel.org>; Mon, 06 Aug 2012 20:37:09 -0700 (PDT)
In-Reply-To: <87obmnfs4p.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7 August 2012 10:44, Eric W. Biederman <ebiederm@xmission.com> wrote:
> Ali Ayoub <ali@mellanox.com> writes:
>
>> Among other things, the main benefit we're targeting is to allow IPoE
>> traffic within the VM to go through the (Ethernet) vBridge down to the
>> eIPoIB PIF, and eventually to IPoIB and to the IB network.
>
> That works today without code changes.  It is called routing.
>
>> In Para virtualized environment, the VM emulator sends/receives packets
>> with Ethernet header, and the vBridge also performs L2 switching based
>> on the Ethernet header, in addition to other tools that expect an
>> Ethernet link layer. We'd like to support them on top of IPoIB.
>
> See routing.  The code is already done.
>
>> I don't see in other alternatives a solution for the problem we're
>> trying to solve. If there are changes/suggestions to improve eIPoIB
>> netdev driver to avoid "messing with the link layer" and make it
>> acceptable, we can discuss and apply them.
>
> Nothing needs to be applied the code is done.  Routing from
> IPoE to IPoIB works.
>
> There is nothing in what anyone has posted as requirements that needs
> work to implement.
>
> I totally fail to see how getting packets of of the VM as ethernet
> frames, and then  IP layer routing those packets over IP is not an
> option.  What requirement am I missing.
>
> All VMs should suport that mode of operation, and certainly the kernel
> does.
>
> Implementations involving bridges like macvlan and macvtap are
> performance optimizations, and the optimizations don't even apply in
> areas like 802.11, where only one mac address is supported per adapter.
>
> Bridging can ocassionally also be an administrative simplification as
> well, but you should be able to achieve the a similar simplification
> with a dhcprelay and proxy arp.
>
> Eric
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Hi,

While I agree this driver doesn't offer an adequate solution to the
problem I think the problem still very much exists.

Ultimately if you have an Infiniband fabric and you want to use it for
inter-guest communication across hosts you are left with 2 options,
tunneling and routing.
Routing can be ok sometimes but it's not a great solution for the vast
majority of people, it requires considerable edge intelligence in the
hypervisor and ISIS routing setups.
The biggest issue is that it's just not L2, guest applications on
guest operating systems expect to have access to fully fledged
Ethernet devices.
This is especially an issue for hosting providers etc where they have
little to no control over what applications their customers want to
use.

Tunnelling solves some of these problems, generally done over L3 and
using existing IP fabric to transport Ethernet L2 frames to the
destination hypervisors.
Better because now you have true L2 encapsulation but to be honest
it's slow and chews alot of cycles and generally has poor PPS
performance.

IMO this driver doesn't make sense compared to a true Ethernet over IB
encapsulation, which isn't actually all that much extra work. (If I am
right you already have a driver that does just this)
The point about retaining compatibility with existing IPoIB boggles my
mind a little.
It means little if no benefit is really added because only IP and ARP
will work.. no other L2 protocol will work correctly as others have
noted.

With full encapsulation you can make use of all the existing
infrastructure, linux bridge, OpenvSwitch, ebtables/netfilter etc.

Joseph.

-- 
CTO | Orion Virtualisation Solutions | www.orionvm.com.au
Phone: 1300 56 99 52 | Mobile: 0428 754 846
