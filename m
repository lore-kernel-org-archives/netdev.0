From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next] rocker: check for BRIDGE_FLAGS_SELF in bridge
 setlink handler
Date: Wed, 18 Mar 2015 08:24:55 -0700
Message-ID: <550998C7.7080108@gmail.com>
References: <CAE4R7bDrhnK_a9dvyMqSJkGgod6AM=HDE6CAKkG_RnjuDxB2-Q@mail.gmail.com> <CAJieiUhHdXOZjWkb4s_GviLwzq5Gct-1o8xv8b-JeM46S4e-dg@mail.gmail.com> <20150309064043.GB2053@nanopsycho.orion> <E4CD12F19ABA0C4D8729E087A761DC35067E6A8D@ORSMSX101.amr.corp.intel.com> <20150309160754.GA2169@nanopsycho.lan> <E4CD12F19ABA0C4D8729E087A761DC35067E6EF0@ORSMSX101.amr.corp.intel.com> <20150310063926.GA1995@nanopsycho.orion> <E4CD12F19ABA0C4D8729E087A761DC35067E7016@ORSMSX101.amr.corp.intel.com> <20150310082817.GC1995@nanopsycho.orion> <550752BA.5040702@gmail.com> <20150317070046.GB2042@nanopsycho.orion> <55083AB6.4060003@intel.com> <55088E2C.5000405@cumulusnetworks.com> <5508C3EA.80009@intel.com> <55091B4C.7090507@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"Arad, Ronen" <ronen.arad@intel.com>,
	Netdev <netdev@vger.kernel.org>,
	Scott Feldman <sfeldma@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:36263 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750719AbbCRPZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 11:25:28 -0400
Received: by obdfc2 with SMTP id fc2so34438635obd.3
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2015 08:25:27 -0700 (PDT)
In-Reply-To: <55091B4C.7090507@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

>> So what about a vlan device?
> Our main focus has always been devices which use the in-kernel bridge
> driver. We have been testing this with mainly vlan
> filtering bridge. But yes, vlan and vxlan devices will need to be
> supported in the stacked netdevice case.
> And that's why the initial proposal was to transparently traverse the
> stacked netdevs and we are trying to bring that back in this thread.
>
>> In this case the software viewpoint is different then the hardware
>> viewpoint so is it correct to pass the configuration down like this?
>
> We just want bridge port config passed down to the switch driver.
>

Sure thought about it some more and I can't see any cases that break.
But it is a change in the model from the normal software case.

>> Also what if the bond device
>> is a LAG, is it correct to passthrough like this?
> hmm...I don't think it matters. We are just trying to get to the switch
> driver.

Came to the same conclusion, it doesn't seem to matter it is different
though.

>>
>> Thanks for the clarification I guess I need to work through some
>> examples to convince myself
>> this works. I'm guessing you (or someone) already did this and I'm
>> just late to the game.
>>
> For cases where we use the in-kernel bridge driver, yes it is tested for
> passing down bridge port attributes that is
> different than the in-kernel bridge attributes (example learning).

Yep, I've tested it here as well this is good.

>
> I am not sure how this would be and what other issues you will hit if
> you are planning to bypass the kernel and directly go to the switch
> driver for all l2 and l3 in the stacked netdevice case. For l3, its
> better to use the in-kernel route fib offload mechanism which was
> recently submitted by scott feldman.
>

Why? I saw the patched and liked it but noted that the existing policy
wont actually work for real networks. Its a good start. My proposal
is to add a flag to l3 to similarly fail to load a rule if it can't
be pushed at hardware same as l2.

I'm getting off the topic of this thread I guess but I'm not
bypassing anything IMO. I want to configure the hardware datapath and I
want to configure the software datapath. For devices with 10, 40,
100Gbps links dropping traffic into the software datapath is not a
viable option in many cases. Traffic will degrade, packets will be
dropped and with 100's or 1000's of these switches managing a network
that some times jumps into software or worse on a single path through
the network might be in software on one hop and in hardware in the next
is not manageable.

When a packet hits the software datapath it is the exception case I want
to handle it as an exception. It also got into the software datapath
because I had a "trap" action in hardware to send it up to software. So
having the software/hardware datapaths mirror each other isn't really
useful at least on the devices I work on. For small home routers and
other types of systems it makes some sense. Perhaps you can even manage
10Gpbs ports like this if you are careful but I really don't see how you
throw a set of 100Gbps links up to kernel datapath running on a
smallish CPU.

.John

-- 
John Fastabend         Intel Corporation
