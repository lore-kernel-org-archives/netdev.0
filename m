From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: bonding and SR-IOV -- do we need arp_validation for loadbalancing
 too?
Date: Tue, 24 Jul 2012 15:38:11 -0600
Message-ID: <500F15C3.4090906@genband.com>
References: <500EC5CF.3080400@genband.com> <20120724164220.GA1721@minipsycho.orion> <21683.1343153629@death.nxdomain> <500F032D.3070104@genband.com> <24104.1343162975@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>,
	andy@greyhouse.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og107.obsmtp.com ([64.18.2.167]:46160 "EHLO
	exprod7og107.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753382Ab2GXVih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 17:38:37 -0400
In-Reply-To: <24104.1343162975@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/24/2012 02:49 PM, Jay Vosburgh wrote:
> Chris Friesen<chris.friesen@genband.com>  wrote:
>
>> In loadbalance mode wouldn't it just work similar to active-backup?  If
>> it's a reply then verify that it came from the arp target, if it's a
>> request then check to see if it came from one of the other slaves.
>
> 	The problem isn't verifying the requests or replies, it's that
> the ARP packets are not distributed across all slaves (because the
> switch ports are in a channel group / aggregator), so some slaves do not
> receive any ARPs.

Yeah, okay.  And if we turn on arp validation then we ignore all the 
other packets and so they looks dead.  Got it.

In our environment (ATCA shelf) the switches have been customized to 
handle some of this stuff so arpmon does work reliably with xor.

In the general case it sounds like the "PF bonding ignores packets from 
VFs" is a better bet then.


>> On 07/24/2012 02:18 PM, Chris Friesen wrote:
>>> A more general solution might be to have the device driver also track
>>> the time of the last incoming packet that came from the external network
>>> (rather than a VF) and having the bond driver ignore those packets for
>>> the purpose of link health.  Doing this efficiently would likely require
>>> some kind of hardware support though--as an example the 82599 seems to
>>> support this with the "LB" bit in the rx descriptor.
>>
>> That should of course be reversed.  We want the bond driver to only use
>> the packets from the external network for the purpose of link health.
>>
>> Does anyone other than bonding actually care about dev->last_rx?  If not
>> then we could just change the drivers to only set it for external packets.
> That should of course be reversed.  We want the bond driver to only use
>> the packets from the external network for the purpose of link health.
>>
> 	I believe bonding is the main user of last_rx (a search shows a
> couple of drivers using it internally).  For bonding use, in current
> mainline last_rx is set by bonding itself, not in the network device
> driver.

Right, I was looking at older code.  In that case presumably the driver 
could set an skb flag (external vs VF loopback) that the bonding code 
could check?

Chris
