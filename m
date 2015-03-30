From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH 2/2] ipvlan: always allow the broadcast MAC address
Date: Mon, 30 Mar 2015 10:56:34 -0700
Message-ID: <CAF2d9jizXuauzahKsumi9R80JRe10TSGhbmsBG0CpONBbVCbbA@mail.gmail.com>
References: <1427409698.18540.11.camel@redhat.com> <1427409822.18540.13.camel@redhat.com>
 <CAF2d9jjxoKFoX7bvJ7+cA685iBT9fPgjvjTKe8ppE_J3oWJgrQ@mail.gmail.com>
 <CAF2d9jh_-DxxUMcTjFK3TUAJhC=B9ORrmH0=tVH1KBiWsYPpLg@mail.gmail.com>
 <20150328193254.6c79784d@griffin> <1427726230.1913.9.camel@redhat.com>
 <CAF2d9jj08R=60na9yeCdsensccYrd-an-7SUk0FuHiD7sN5K+A@mail.gmail.com> <1427737479.1913.20.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Benc <jbenc@redhat.com>, linux-netdev <netdev@vger.kernel.org>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:35052 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753544AbbC3R4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 13:56:55 -0400
Received: by obcjt1 with SMTP id jt1so131398541obc.2
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 10:56:54 -0700 (PDT)
In-Reply-To: <1427737479.1913.20.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 30, 2015 at 10:44 AM, Dan Williams <dcbw@redhat.com> wrote:
> On Mon, 2015-03-30 at 09:54 -0700, Mahesh Bandewar wrote:
>> On Mon, Mar 30, 2015 at 7:37 AM, Dan Williams <dcbw@redhat.com> wrote:
>> > On Sat, 2015-03-28 at 19:32 +0100, Jiri Benc wrote:
>> >> On Fri, 27 Mar 2015 22:56:15 -0700, Mahesh Bandewar wrote:
>> >> > The current logic disables broadcast by default and enables only when
>> >> > an IPv4 address is added. If this is inverted and -
>> >> > enables broadcast by default but disables it when only IPv6
>> >> > address(es) is / are added. These links can have multiple addresses
>> >> > and hence have to be careful if any one of those is IPv4 then
>> >> > broadcast bit has to be set.
>> >>
>> >> You'd have to be careful and ignore IPv6 link local addresses.
>> >> Those are added automatically whenever IPv6 is enabled and their
>> >> presence does not mean the network is not IPv4 only.
>> >>
>> >> But I don't like such magic behavior. It would lead to DHCP sometimes
>> >> working and sometimes not in mixed v4/v6 environment depending on
>> >> whether DHCPv4 or SLAAC was faster.
>> >>
>> >> Could we perhaps add a flag when creating ipvlan interface stating
>> >> whether IPv4 broadcast should be always enabled? Or, rather, the other
>> >> way round - whether it should be disabled by default. Call it "nodhcp"
>> >> or so.
>> >>
>> >> Btw, speaking about IPv6 link local addresses, these actually do not
>> >> work with ipvlan correctly. I'm getting DAD failures if I have more
>> >> than one ipvlan interface, which is no wonder. This means that ipvlan
>> >> cannot work with IPv6 reliably by default (unless you take care of ll
>> >> address assignment and ensure all ipvlan interfaces get a different
>> >> one).
>> >
>> > ipvlan doesn't set dev_id.  Once dev_id is set the kernel's IPv6LL
>> > address generation code will assign a different LL address to each
>> > ipvlan interface created from the same physical interface, despite that
>> > they have the same MAC address.
>> >
>> Yes, that was what my plan was but never got around fixing that
>>
>> > But of course you'd have to be careful to assign a *different* dev_id
>> > than any of that physical interface's non-ipvlan children too, and I
>> > have no idea how that would work since dev_id is currently done
>> > per-driver.  eg, if you have a physical interface with dev_id=1 which
>> > you then create an ipvlan from, that ipvlan must not use dev_id=1 or it
>> > will be assigned the same IPv6LL address as the parent.
>> >
>> The description is very clear for dev_id (in netdevice.h). So the idea
>> of using the subsequent numbers after master's id should be possible.
>> After all these logical devices are going to share the same link. Most
>> physical drivers don't assign dev-id so the beginning is 0x0 (for the
>> physical driver) and from 0x1 can be assigned to the logical links.
>> The definition is not clear in terms of what is the beginning (0x0 or
>> 0x1) but from the code that generates the IPv6LL it's common that it's
>> 0x0 hence logical links on top of these links can use 0x1 onward.
>> However a check to see if the master-link has dev-id and staying clear
>> of that should be sufficient.
>
> My point was that if you have a parent with a non-zero dev_id, there can
> be other siblings of the parent that have a different dev_id and share
> the same MAC address.  So creating an ipvlan with parent->dev_id + 1
> doesn't work, because the parent may have a sibling with parent->dev_id
> + 1 and the same MAC address already.
>
May be I'm missing something but is there a scenario where sibling
(physical / port) will be sharing the same LL-address? The definition
/ description in netdevice.h is  -

               *  @dev_id:        Used to differentiate devices that share
               *                          the same link layer address

So I's assuming the layered / stacked devices (children) rather than
ports etc (siblings). What am I missing?



> Dan
>
