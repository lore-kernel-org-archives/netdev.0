From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: switchdev and VLAN ranges
Date: Sat, 10 Oct 2015 11:10:01 -0700
Message-ID: <CAGVrzcbXW=GRdq+Ftp=vefOPK-RYV5cYRCuBg2-YUui3iE3keA@mail.gmail.com>
References: <493168159.229458.1444433451493.JavaMail.zimbra@savoirfairelinux.com>
 <CAE4R7bBRySJZxq4HKfSkyLNHiC0oMUqb95E=fCHjKX6MpNUGBw@mail.gmail.com> <20151010163300.GC14572@ketchup>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Scott Feldman <sfeldma@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	netdev <netdev@vger.kernel.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Andrew Lunn <andrew@lunn.ch>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:33489 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751513AbbJJSKl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2015 14:10:41 -0400
Received: by iodv82 with SMTP id v82so19608580iod.0
        for <netdev@vger.kernel.org>; Sat, 10 Oct 2015 11:10:41 -0700 (PDT)
In-Reply-To: <20151010163300.GC14572@ketchup>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-10-10 9:33 GMT-07:00 Vivien Didelot <vivien.didelot@savoirfairelinux.com>:
> On Oct. Friday 09 (41) 09:22 PM, Scott Feldman wrote:
>> On Fri, Oct 9, 2015 at 4:30 PM, Vivien Didelot
>> <vivien.didelot@savoirfairelinux.com> wrote:
>> > Hi All,
>> >
>> > I understand that specifying a VLAN range on the command line is nice
>> > for the user, and it makes no big deal for software implementation.
>>
>> [Adding Roopa, since she did the original vlan range support in the
>> kernel/iproute2]
>>
>> > However, AFAICT a VLAN range does not make sense at all for hardware
>> > such as Ethernet switch chips. Am I wrong?
>> >
>> > I would suggest to make switchdev directly answer to a bridge request
>> > that the operation is not supported when the user asks for a VLAN range.
>> >
>> > That way, we can simply use a single "vid" member in struct
>> > switchdev_obj_port_vlan instead of "vid_begin" and "vid_end" and thus
>> > avoid making drivers heavier with iteration loops on such range.
>> >
>> > I have two concerns in mind:
>> >
>> > a) if we imagine that drivers like Rocker allocate memory in the prepare
>> > phase for each VID, preparing a range like 100-4000 would definitely not
>> > be recommended.
>>
>> This call should be in process context so it doesn't seem to terrible
>> for the driver to take its time to reserve/allocate resources in
>> prepare phase, even for a vlan range.  I think I'm missing your point.
>
> I'll try to give a concrete example. If I want to use the prepare phase
> in the mv88e6xxx driver, I will allocate a struct mv88e6xxx_vtu_entry
> (basically a row in the hardware VLAN table) in the prepare phase before
> programming it in the commit phase.
>
> With this VLAN range, the driver will allocate 3900 struct. This seems
> pointless for drivers and error-prone.

We could amortize this allocation cost by having a way to tell the
bridge VLAN filtering code, once associated with a switchdev driver,
that this driver needs X amount of bytes for its private VLAN entry,
but that sounds overkill. If the switch driver needs to maintain
bookeeping information about VLANs, we would have to allocate this
data somewhere, so we might as well have the switch driver do it?

>
>> > b) imagine that you have two Linux bridges on a switch, one using the
>> > hardware VLAN 100. If you request the VLAN range 99-101 for the other
>> > bridge members, it is not possible for the driver to say "I can
>> > accelerate VLAN 99 and 101, but not 100". It must return OPNOTSUPP for
>> > the whole range.
>>
>> Well, it probably should return -ERANGE to indicate the range can't be
>> added, but that's an aside.
>>
>> The reason why vlan ranges need to work down to the switchdev driver
>> is, from the user's perspective, it's an all-or-nothing request from
>> the user to add the vlan range to the device.  So we need to ask the
>> driver in the prepare phase, "can you support this range,
>> completely?", and if yes, then commit it as a whole.  The netlink
>> response back to the user isn't equipped to describe what subset of
>> the range was added, and what subset was not.
>
> I understand the all-or-nothing request, and I don't want to re-train
> the user. I am basically suggesting that switchdev returns -ERANGE in
> its code, if the device is a switch port and a VLAN range is requested.

Denying VLAN ranges in switchdev would at best, be something that
should be negotiated with the underlying switch driver. There could be
cases where it is desirable to push VLAN ranges to batch expensive HW
operations for instance, or just because you can do it and this maps
nicely to your HW is nice to have.  Do you have something else in
mind?

>
> I mean, I like the per-port paradigm of Linux, but an infrastructure
> such as switchdev should not just forward user request to the device,
> but also protect it and push consistent calls to the hardware.
>
>> > That's why I think that avoiding VLAN range at the switchdev level would
>> > be a good idea.
>>
>> As a general rule with switchdev, we've tried to keep the user's
>> experience the same when using {Linux} as a soft switch/router vs.
>> using {Linux + offload device} as a hard switch/router.  So if native
>> Linux supports some operation, for example vlan ranges, then we should
>> try to extend that to the offload model.  In other words, we don't
>> want to re-train the user when moving from soft switch to hard switch!
>>  But there are physical limitations when dealing with an offload
>> device....
>>
>> Anyway, with your vlan range example, we've got a case where each soft
>> bridge has an independent vlan set, and the vlan sets between soft
>> bridges can overlap.  For the (typical) hard switch, there is one vlan
>> set for the whole switch, and trying to overlay the soft bridges'
>> (overlapping) vlan sets on the hard switch fails.  That failure is
>> reported to the user.  We tried, but due to offload device
>> limitations, we can't support that operation.  Of course, if the vlan
>> sets didn't overlap, then we don't have a problem.
>>
>> This will not be the only case where something we can do on a soft
>> Linux switch/router can't be offloaded to some physical offload
>> device.  But I think the philosophy has been to try offload what we
>> can, up to the point of failure.  In some cases, we can mask that
>> failure from the user by falling back to soft-switch only, but in
>> other cases the failure will pop up right in the user's face, like in
>> your example.
>>
>> One idea to help mitigate the user's confusion would be to limit the
>> number of bridges overlaid on the device to just one.  Our drivers
>> know when ports are enslaved to bridges, so is there something we can
>> do there to fail the enslave on a second bridge?  Exercise left to the
>> reader.  If we had that, now vlan ranges work 1:1 with soft Linux
>> because both soft bridge and device have single vlan set.
>>
>> Sorry for the long-winded response.
>
> I'm fine with the multiple software bridges on top of hardware switches.
> IIRC, Andrew is actually using this feature. The user should be able to
> request mixing of any ports like (s)he wants.
>
> A use case I can imagine is a bridge on a router between a WAN interface
> and a few switch ports, and an isolated group of ports (e.g. sandbox).

That use case can be solved by having a single bridge entity spanning
an entire switch device, and configuring different PVIDs on e.g: ports
2-3-4 (WAN) and ports 0-1 (sandbox).

>
> What I have done in net/dsa/slave.c:dsa_bridge_check_vlan_range() should
> ideally be moved up to switchdev (this code prevents overlapping of VLAN
> between bridges in DSA switches).

As we discussed before over IRC, checking for overlapping VLANs is
something that may have to be switch driver specific at some point.

For instance, some switches do a double tag VLAN tag normalization
whenever a packet is ingressed, which means that as long as your are
not doing double VLAN tagging (that would be fun to support, but even
there), you could dedicate an outer VLAN tag per bridge instance, and
still allow the same inner VLAN tags to be configured by an user. The
switch would still guarantee proper isolation/switching/individual or
shared FDBs for these logical domains.
-- 
Florian
