From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: network namespace and kernel bind issue
Date: Mon, 01 Oct 2012 16:11:07 -0700
Message-ID: <87y5jpdbzo.fsf@xmission.com>
References: <20121001141609.14639bc0@nehalam.linuxnetplumber.net>
	<20121001145838.5eafef4c@nehalam.linuxnetplumber.net>
	<87fw5xeryf.fsf@xmission.com>
	<20121001155702.5b5e2188@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:57327 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758034Ab2JAXLP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 19:11:15 -0400
In-Reply-To: <20121001155702.5b5e2188@nehalam.linuxnetplumber.net> (Stephen
	Hemminger's message of "Mon, 1 Oct 2012 15:57:02 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> writes:

> On Mon, 01 Oct 2012 15:40:56 -0700
> ebiederm@xmission.com (Eric W. Biederman) wrote:
>
>> Stephen Hemminger <shemminger@vyatta.com> writes:
>> 
>> > On Mon, 1 Oct 2012 14:16:09 -0700
>> > Stephen Hemminger <shemminger@vyatta.com> wrote:
>> >
>> >> When testing VXLAN I noticed that the kernel bind seems to be a problem for
>> >> network tunnels. The init_net function is called repeatedly for the same
>> >> network namespace!
>> 
>> It definitely should not be.
>> 
>> >> 1. Create vxlan device:
>> >>  # ip li add vxlan0 type vxlan id 11 group 239.1.1.1 dev eth0
>> >>  # dmesg | tail
>> >> [11580.671016] vxlan: vxlan_init_net in net 1
>> 
>> Net 1?  What are you printing out?  It isn't the net_id by any chance?
>
> Yes it is the net_id which is passed to net_generic() to find the
> per-namespace data structure.

Yes.  net_id is just an index and is the same in all network namespaces.
net_id should only be different for different instances of per_net
operations.

>> >> 2. Start Chrome (or other application using namespaces)
>> >>  
>> >>   dmesg | tail
>> >> [11587.371195] vxlan: vxlan_init_net in net 1
>> >> [11587.371211] vxlan: bind for UDP socket 0.0.0.0:8472 (-98)
>> >> 
>> >> 
>> >> Isn't init_net supposed to be unique. The current semantics also break
>> >> L2TP.
>> 
>> The init method should be called exactly once per network namespace.
>> 
>> The timing of the init methods you report seems correct.
>> 
>> The vxlan code isn't in net-next or I would take a look.
>> 
>> I took a quick look at l2tp and the code is doing some weird things.
>> There are a bunch of references to &init_net that I would expect
>> to references to either sk_net() or dev_net().  
>> 
>> Adding support for multiple network namespaces and then reaching
>> out to the initial network namespace for things is definitely a recipe
>> for getting confused.
>> 
>> So my blind guess would be that someone half implemented network
>> namespace support for l2tp and vxlan copied the bugs.
>
> The vxlan driver has one UDP socket per namespace.
> There are no references to init_net in it.

Then my guess is that you have an ordering problem.  Attempting
to initialize a vxlan before ipv4 is initialized or some such.

> I think the problem is the call chain
>       copy_net_ns -> setup_net -> ops_init
> There is nothing that nothing increments the id after register_pernet_operations.
>
> Shouldn't there be an increment so each new namespace gets a unique id?

No.

There are some extra pointers at the end of struct net and the id is
which of those pointers your subsystem gets to use.  net_generic returns
your pointer value.

I can see the confusion but the id is definitely not a namespace id.

Eric
