From: Gary Thomas <gary@mlbassoc.com>
Subject: Re: Marvell 88E609x switch?
Date: Tue, 10 Mar 2009 09:11:22 -0600
Message-ID: <49B6831A.4080506@mlbassoc.com>
References: <49AC5E6F.3010204@mlbassoc.com> <1236070372.30736.87.camel@localhost.localdomain> <49AD1C81.1020106@mlbassoc.com> <1236083560.30736.114.camel@localhost.localdomain> <49AD2FE1.60305@mlbassoc.com> <49AD30F7.4080006@mlbassoc.com> <49ADA697.3050400@mlbassoc.com> <49B145FF.5060208@mlbassoc.com> <20090310102805.GO4738@xi.wantstofly.org> <49B64CF5.9090508@mlbassoc.com> <20090310133635.GS4738@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jdb@comx.dk, Jesper Dangaard Brouer <hawk@diku.dk>,
	netdev <netdev@vger.kernel.org>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 137-67-76-76.skybeam.com ([76.76.67.137]:2329 "EHLO
	mail.chez-thomas.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751665AbZCJPMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 11:12:13 -0400
In-Reply-To: <20090310133635.GS4738@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennert Buytenhek wrote:
> On Tue, Mar 10, 2009 at 05:20:21AM -0600, Gary Thomas wrote:
> 
>>>> After much experimentation, I finally found out what was
>>>> wrong.  Basically, the trunk masks have 8 bits on the 6131,
>>>> but 11 bits on the 609x and this wasn't being handled.  Once
>>>> the trunk masks were reset by the init code, there was no
>>>> path to the CPU port from the LAN ports :-(  The attached
>>>> patch is what I've ended up with.  It works, at least for
>>>> a single switch.
>>> Cool.  How about the patch below then?
>> This looks fine to me - is this part safe on the smaller parts
>> (6131, etc)?  I wasn't sure about setting those "reserved" bits
>> on other chips.
> 
> It should be OK, but I'll test it to make sure.
> 
> 
>>> That's a bit trickier, but also not entirely hard:
>>> - Instead of the CPU port concept, we'll have to use the port number
>>>   that brings us one hop closer to the CPU (i.e. the upstream port).
>>> - Assign each chip a DSA device address (instead of always setting it
>>>   to zero).
>>> - Populate the 'DSA device address -> port' mapping table for each
>>>   switch.
>>> - Enable DSA tagging and flooding of unknown unicasts and multicasts
>>>   on all inter-switch links and not just on the CPU port on switch 0.
>>>
>>> I don't think it makes sense to implement Dijkstra in the kernel, so
>>> it's probably easiest to just pass in a precomputed NxN array of how
>>> to go from which switch to which switch via which port, along with a
>>> separate DSA port list for each switch chip.
>>>
>>> I don't have multi-switch chip setups myself, or I would have
>>> implemented this already.  But I can whip up some patches to try..
>> That would be great.  What I'd like to figure out is a
>> way to provide that mapping (static from the driver point
>> of view), much like the current "port_names[]" table now.
> 
> Something a la the attached patch should be enough from the
> data structure point of view, AFAICS.  And then you'd have:
> 
> 
>> For my particular setup, there are two cases (on the same
>> board):
>>   Switch 1 - ports 1..8
>>   Switch 2 - ports 9..16
>>     Switch 3 - ports 17..24 (cascaded off of Switch 2)
>> Thus, the only access to Switch 3 and its ports is indirect via
>> Switch 2.
>>
>> Presumably, one could have a multiple cascade, so this structure
>> should be considered from the start.
> 
> Switch 1 can correspond to its own DSA platform device as it is now.
> 
> And for switch 2/3 you'd then have something a la:
> 
> 
> struct dsa_switch_data switches[] = {
> 	{
> 		.mii_bus = &blah,
> 		.sw_addr = 2,
> 		.port_names[0] = "p9",
> 		.port_names[1] = "p10",
> 		.port_names[2] = "p11",
> 		.port_names[3] = "p12",
> 		.port_names[4] = "p13",
> 		.port_names[5] = "p14",
> 		.port_names[6] = "p15",
> 		.port_names[7] = "p16",
> 		.port_names[9] = "dsa",
> 		.port_names[10] = "cpu",
> 	}, {
> 		.mii_bus = &blah,
> 		.sw_addr = 3,
> 		.port_names[0] = "p17",
> 		.port_names[1] = "p18",
> 		.port_names[2] = "p19",
> 		.port_names[3] = "p20",
> 		.port_names[4] = "p21",
> 		.port_names[5] = "p22",
> 		.port_names[6] = "p23",
> 		.port_names[7] = "p24",
> 		.port_names[9] = "dsa",
> 	},
> };
> 
> struct dsa_platform_data switch23 = {
> 	.netdev = &blah,
> 	.nr_switches = 2,
> 	.sw = switches,
> 	.rtable = {
> 		{ -1,  9 },
> 		{  9, -1 },
> 	},
> };
> 
> Or something along those lines.
> 
> Thoughts?
> 

The setup looks good.  Let me know when you have the rest of
the patch ready to test (I'm all setup here)

-- 
------------------------------------------------------------
Gary Thomas                 |  Consulting for the
MLB Associates              |    Embedded world
------------------------------------------------------------
