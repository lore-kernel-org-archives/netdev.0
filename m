From: Ben Greear <greearb@candelatech.com>
Subject: Re: Stackable devices.
Date: Wed, 02 Aug 2006 10:50:08 -0700
Message-ID: <44D0E5D0.6030409@candelatech.com>
References: <44CA34D0.1070507@candelatech.com>	<20060801170329.GG29208@tuxdriver.com>	<44CF8D8A.5080101@candelatech.com>	<200608021102.20604.Christophe.Devriese@eurid.eu> <20060802103728.0b2fa46b@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christophe Devriese <Christophe.Devriese@eurid.eu>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:58048 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S932113AbWHBRuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2006 13:50:21 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060802103728.0b2fa46b@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Wed, 2 Aug 2006 11:02:20 +0200
> Christophe Devriese <Christophe.Devriese@eurid.eu> wrote:
> 
> 
>>On Tuesday 01 August 2006 19:21, you wrote:
>>
>>>John W. Linville wrote:
>>>
>>>>>>I'm just not sure that cleverness is worth the headache, especially
>>>>>>since the most clever things usually only work by accident...
>>>>>
>>>>>Or, work by solid, modular design and small tweaks!
>>>>
>>>>Point taken.  But stashing little hacks in the networking core for
>>>>specific virtual drivers isn't totally modular either.  And even if
>>>>it were, "modular design" probably belongs on the list of "things
>>>>that can be taken too far", like "everything in userland", "never
>>>>use ioctl", and "microkernels are superior". :-)
>>>
>>>To be honest, I'm not over-joyed to see bridging hooks included
>>>in the VLAN code..but if that is what it takes to get bridging
>>>and VLANs to play well and be flexible, I think it is a fair price.
>>>
>>>It certainly wouldn't hurt to have someone take a holistic view of the
>>>various L2 device interactions.  Just documenting current functionality
>>>on, say, the netdev wiki would be a good first step.
>>
>>Ultimate flexibility could be provided by making the netif_rx routine (and the 
>>others, including vlan etc), a "virtual" routine.
>>
>>That way a list of "filters" could be defined that allow any processing to be 
>>done on the packet before it is handed of to the linux kernel's higher 
>>layers, including not delivering it on that interface, or delivering it on 
>>another interface.
>>
>>This would allow very complex implementations including stuff like a 
>>high-level l2 bridge, with vlan support, and a number of protocols like rstp, 
>>pvst+, ... with relatively simple code, that could be isolated from the main 
>>kernel.
>>
>>Would anyone be interested in signing off on such a patch ? (which basically 
>>creates netif_rx and vlan_acc_netif_rx lists in the net_device structure, and 
>>then modify bridging and bonding drivers to just use this) 
> 
> 
> I have thought about this, but you end up reinventing System V streams.
> The problem is for simple up/down call, the stacking model works fine but
> once you add flow-control and multiplexing issues the problem becomes complex.
> It is hard to think of a good general solution where the performance wouldn't
> end up sucking.

Currently, the bridge hook logic is something like:

if (bridge-consumed-pkt) {
	return
}

// drop through to other layers


There are several other hooks I'd like to see added (pktgen receive processing,
mac-vlans, etc).  Each of these hooks are logically similar to the bridge hook,
ie if it consumes the pkt, return, else, drop through to the next hook untill
we get to the regular protocol processing logic.

I would like to be able to chain layer-2 handlers, such as bridge, mac-vlan,
pktgen such that if one consumed, you break out of the handling, else, you
try the next handler.  The handlers can be dynamically registered and inserted
in any order, controllable by user-space and/or module load/unload.

For many of the handlers, the logic will re-insert the packet by re-calling the
netif-rx logic, so there would need to be some protection to keep loops from
occurring that would recurse too much and overflow the stack.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

