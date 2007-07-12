From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [2.6.23 PATCH 14/18] dm: netlink add to core
Date: Thu, 12 Jul 2007 13:37:43 -0600
Message-ID: <m1wsx5e7lk.fsf@ebiederm.dsl.xmission.com>
References: <20070711210159.GF24114@agk.fab.redhat.com>
	<20070711143423.36722a41.akpm@linux-foundation.org>
	<m1bqehfyp0.fsf@ebiederm.dsl.xmission.com>
	<20070712173410.GA2505@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Alasdair G Kergon <agk@redhat.com>, dm-devel@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Mike Anderson <andmike@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:39981 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754455AbXGLTq2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 15:46:28 -0400
In-Reply-To: <20070712173410.GA2505@us.ibm.com> (Mike Anderson's message of
	"Thu, 12 Jul 2007 10:34:10 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mike Anderson <andmike@us.ibm.com> writes:

> Eric W. Biederman <ebiederm@xmission.com> wrote:
>> I may be a little off but looking at the events types defined.
>> device down, device up.  Defining a completely new interface for this
>> looks absolutely absurd.
>> 
>> 
>> This is device hotplug isn't it?   As such we should be using the
>> hotplug infrastructure and not reinventing the wheel here.
>> 
>
> I assume device hotplug means kobject_uevent and KOBJ_* events. The
> original intent was to have a little more structure in the data format the
> env strings. I also wanted to reduce the number of allocations that where
> happening with GFP_KERNEL to send an event. 
>
> Currently the patch is only supporting a couple of events with the intent of
> adding more over time. I see that I could map most events to KOBJ_CHANGE,
> previously it did not seem like the correct fit.  

Yes.  kobject_uevent is what I was thinking of.

Even if it means it makes sense to add a few more types to handle
the situation at first glance it seems to fit well.

I know if I was looking for a notification that a something was added
or removed from a raid array I would look at the generic hotplug
events first.

Possibly KOBJ_CHANGE isn't the proper fit, possibly you have something
that is sufficient unique that it needs it's own enumeration type.
If so we can fix the generic code.

At the moment though KOBJ_CHANGE does seem to describe what you are
doing and the event data you have don't look like they are actually a
problem to fit into a user space environment.

As for worry about kmallocs do these events happen often?  I would
not expect any of them in the normal course of operation for a system.
Worst case you handle extra kmallocs with a library function.
It's not like you are using GFP_ATOMIC.

Plus there are other little bonuses if these events are reported
with kobject_uevent such as an already existing user space tools
to look at them and do something, and a scripting infrastructure
to take action when things happen.


>> If it isn't hotplug it looks like something that inotify should
>> handle.
>> 
>> If that isn't the case I am fairly certain that md already has a
>> mechanism to handle this, and those two should stay in sync
>> if at all possible on this kind of thing.
>> 
>
> Device mapper does have a "event happened" interface today, but post the
> event the user must determine the context of the event (dm also sends a
> kobject_uevent KOBJ_CHANGE only for a resume event). This patch was only
> effecting dm, but I know the md has similar infrastructure. This patch
> was passing out the event context through netlink that already existed but
> was lost through the current generic event interface.
>
> The existing event interfaces was left in place to not effect existing users
> allowing migration over to a netlink interface over time.

I know sending some of the context with an event is important so
that you can filter out events you don't need.  Is the lack of context
actually a problem today?

>> So this appears to be a gratuitous user interface addition.
>> Why do we need a new user interface for this?
>
> While I understand Evgeniy and Davids comment about utilizing the
> genetlink interface, I guess I am not seeing that utilizing a netlink
> channel for a subsystem as a gratuitous user interface addition vs.
> running everything through kobject_uevent.

Gratuitous in the sense that if we already have a mechanism for performing a
function we should not invent a new mechanism for doing that same function
for each different subsystem.

The fewer unique types of user interfaces we have the easier it to
maintain the kernel, the easier it is to write programs that work
with several kernel subsystems, and the easier it is for other
developers to understand and use the kernel.

This of course assumes things are a good fit or the other pieces
can be made to be a good fit.  Currently I don't see the what makes
device mapper's events not fit the existing models, and I don't
see it in the description for this patch why we need to invent
something new.


Eric
