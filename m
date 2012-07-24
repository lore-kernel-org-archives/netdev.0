From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: bonding and SR-IOV -- do we need arp_validation for loadbalancing
 too?
Date: Tue, 24 Jul 2012 14:18:53 -0600
Message-ID: <500F032D.3070104@genband.com>
References: <500EC5CF.3080400@genband.com> <20120724164220.GA1721@minipsycho.orion> <21683.1343153629@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>,
	andy@greyhouse.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og112.obsmtp.com ([64.18.2.177]:60914 "EHLO
	exprod7og112.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755068Ab2GXUVA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 16:21:00 -0400
In-Reply-To: <21683.1343153629@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/24/2012 12:13 PM, Jay Vosburgh wrote:
> Jiri Pirko<jiri@resnulli.us>  wrote:
>
>> Tue, Jul 24, 2012 at 05:57:03PM CEST, chris.friesen@genband.com wrote:
>>> Hi all,
>>>
>>> We've been starting to look at bonding VFs from separate physical
>>> devices in a guest, but we've run into a problem.
>>>
>>> The host is bonding the corresponding PFs, and it uses arp
>>> monitoring.  What we have found is that any broadcast traffic from
>>> the guest (if they enable arp monitoring, for example) will be seen
>>> by the internal L2 switch of the NIC and sent up into the host, where
>>> the bonding driver will count it as incoming packets and use it to
>>> mark the link as good.
>>>
>>> The only solutions I've been able to come up with are:
>>> 1) add arp validation for load balancing modes as well as active-backup.
>> This is my favourite.... No reason to not to turn arp validation on.
>> TEAM device (teamd arpping linkwatch) does arp or NSNA validation
>> always.
> 	How does that operate for a load balancing mode?
>
> 	For arp validate to function (as it's implemented in bonding),
> the arp requests (broadcasts) or the arp replies (unicasts) must be seen
> by each slave at regular intervals.  Most load balance systems
> (etherchannel or 802.3ad, for example) don't flood the broadcast
> requests to all members of a channel group, and the unicast replies only
> go to one member.
>
> 	This generally results in either only one slave staying up, or
> slaves going up and down at odd intervals.  The arp monitor for the load
> balance modes is already dependent upon there being a steady stream of
> traffic to all slaves, and can be unreliable in low traffic conditions
> (because not all slaves receive traffic with sufficient frequency).

In loadbalance mode wouldn't it just work similar to active-backup?  If 
it's a reply then verify that it came from the arp target, if it's a 
request then check to see if it came from one of the other slaves.

In our case we have control over the L2 switches involved so we ensure 
that the broadcast arp request is sent to all the other slaves, while 
the reply comes back to the sender.  I think we still have a window 
where you could have a device with a faulty tx but functional rx and 
never detect the problem in the monitor.

A more general solution might be to have the device driver also track 
the time of the last incoming packet that came from the external network 
(rather than a VF) and having the bond driver ignore those packets for 
the purpose of link health.  Doing this efficiently would likely require 
some kind of hardware support though--as an example the 82599 seems to 
support this with the "LB" bit in the rx descriptor.

Chris
