From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net-next] rocker: check for BRIDGE_FLAGS_SELF in bridge
 setlink handler
Date: Tue, 17 Mar 2015 17:16:42 -0700
Message-ID: <5508C3EA.80009@intel.com>
References: <CAE4R7bDrhnK_a9dvyMqSJkGgod6AM=HDE6CAKkG_RnjuDxB2-Q@mail.gmail.com> <CAJieiUhHdXOZjWkb4s_GviLwzq5Gct-1o8xv8b-JeM46S4e-dg@mail.gmail.com> <20150309064043.GB2053@nanopsycho.orion> <E4CD12F19ABA0C4D8729E087A761DC35067E6A8D@ORSMSX101.amr.corp.intel.com> <20150309160754.GA2169@nanopsycho.lan> <E4CD12F19ABA0C4D8729E087A761DC35067E6EF0@ORSMSX101.amr.corp.intel.com> <20150310063926.GA1995@nanopsycho.orion> <E4CD12F19ABA0C4D8729E087A761DC35067E7016@ORSMSX101.amr.corp.intel.com> <20150310082817.GC1995@nanopsycho.orion> <550752BA.5040702@gmail.com> <20150317070046.GB2042@nanopsycho.orion> <55083AB6.4060003@intel.com> <55088E2C.5000405@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>,
	John Fastabend <john.fastabend@gmail.com>,
	"Arad, Ronen" <ronen.arad@intel.com>,
	Netdev <netdev@vger.kernel.org>,
	Scott Feldman <sfeldma@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:55206 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752963AbbCRAQn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Mar 2015 20:16:43 -0400
In-Reply-To: <55088E2C.5000405@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/17/2015 01:27 PM, roopa wrote:
> On 3/17/15, 7:31 AM, John Fastabend wrote:
>> On 03/17/2015 12:00 AM, Jiri Pirko wrote:
>>> Mon, Mar 16, 2015 at 11:01:30PM CET, john.fastabend@gmail.com wrote:
>>>> [...]
>>>>
>>>>>> If this position is accepted, it would be best to enforce it, possibly in
>>>>>> rtnl_bridge_setlink().
>>>>>> My recollection is that others asked to preserve use-cases where SELF flag
>>>>>> is used for targeting port devices directly without using a bridge device.
>>>>> I know it is possible, and it is incorrect and hacky. But it is part of
>>>>> user api :/ I think we should not abuse this more in the future and
>>>>> rather make the api correct and use that.
>>>>>
>>>> Working my way through my backlog of email sorry for the days delay.
>>>>
>>>> Jiri, are you suggesting it is incorrect to configure the hardware L2
>>>> independent of bridge device? There is absolutely use cases for this.
>>>>
>>>> The case being we want the hardware to do L2 learning via fdb and then
>>>> when flows get 'trapped' into software we want to handle them
>>>> differently. Possibly send them onto a specific application for logging.
>>> Yes, but that can be done in transparent way, exposing hw ports, having
>>> them in bridge/ovs/whatever. Same as we do with rocker.
>>>
>> My point is you don't want a bridge in software at all. So I don't
>> understand the "transparent" way. In this case you want to configure
>> the hardware to do l2 bridge and put the ports in some other objects
>> for simplicity consider a OVS instance in software. In this model
>> the ports are attached to the software OVS and we do not want to
>> "transparently" offload any of OVS to hardware.
>>
>> Also ports can not be in both an OVS instance and bridge instance.
>>
>>                    +----+----+
>>                    |   OVS   |      <- netdevs mapped to sw ovs, not offoaded
>>                    +----+----+
>>                       |    |
>>                     sw0p1 sw0p2     <- netdev representing hardware ports
>>                       |    |
>>               +----+----+----+---+
>>               |    L2 hw bridge  |  <- l2 hardware bridge managed via netlink
>>               +----+----+----+---+
>>
>> In many cases it doesn't make any sense to fall back to software.
>> You can't have a 100Gbps links "falling" back onto the kernel datapath.
>> And in these environments having ports attached to a "transparent" bridge
>> breaks. Worse the management CPU is usually something light, its not
>> typically a quad socket top of line CPU where you might have a chance.
>>
>> Nothing is broke at the moment because we have the "self" flag. I'm
>> responding to you "incorrect and hacky" comment. Similarly we are
>> going to need a flag for L3 that puts the rule in hardware or fails.
>> Just like L2 we can't have L3 being sent into software its not a
>> viable fallback path in many use cases. And doing it "transparently"
>> so that the controlling agent is unaware it is offloaded makes it
>> difficult to manage the system. I think the "transparent" model only
>> works for smallish devices, home routers and the likes.
>>
> 
> I have not followed Jiri's and your exchange of comments fully yet.
> If it helps I just wanted to clarify the part where the word 'transparency' was introduced in this thread:
> 
> This is in the context of traversing lower devices to get to the switch port (example, a bond with switch ports as slaves and you want to reach the slaves via the bond).
> 
> Its was not in the context of whether the kernel bridge driver is used or not for l2 offload.
> Understand that there are l2 nics which are programmed today by directly going to the driver
> bypassing the bridge driver. and these are programmed with 'self' today.

Actually not just NICs but also switches will use this.

> 
> Even for offloads that use the in kernel bridge driver (switch devices eg rocker),
> user can use  'self' to go directly to the switch driver. And this is required in some cases
> where you want a bridge port attribute to be different than the in-kernel bridge port attribute.
> eg learning.
> 
> bridge link set dev swp1 learning off   (sets learning off in both in-kernel bridge and rocker)
> bridge link set dev swp1 learning on self   (sets learning on in rocker)

yep :) this is my use case. And I will need to add similar policy to l3 which I will
hopefully get to soon. I was just keying off the 

> 
> To describe the stacked netdev/bridge port case which is the context of this thread,
> a rocker port can be a slave of a bond and the bond can be a bridge port. In such cases you want
> to traverse the bond lowerdevs to get to the rocker port to call into the switch driver.
> 
> bridge link set dev bond0 learning off   (sets learning off in both in-kernel bridge and rocker)
> bridge link set dev bond0 learning on self   (sets learning on in rocker)
> 
> For the above to work, since rtnetlink.c calls the op on the port driver directly , bonding driver should implement
> the required op.

OK, but I'm not entirely sure this is correct. I'm trying to wrap my head around it. In this
case it can be _any_ type of stacked device correct?

So what about a vlan device? In this case the software viewpoint is different then the hardware
viewpoint so is it correct to pass the configuration down like this? Also what if the bond device
is a LAG, is it correct to passthrough like this?

Thanks for the clarification I guess I need to work through some examples to convince myself
this works. I'm guessing you (or someone) already did this and I'm just late to the game.

Thanks,
.John
