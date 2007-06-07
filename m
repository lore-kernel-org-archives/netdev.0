From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC RTNETLINK 00/09]: Netlink link creation API
Date: Thu, 07 Jun 2007 02:06:23 -0600
Message-ID: <m1ps48rxxc.fsf@ebiederm.dsl.xmission.com>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
	<m1tztlvrsp.fsf@ebiederm.dsl.xmission.com>
	<46669FA0.3030405@trash.net>
	<m1d509umtp.fsf@ebiederm.dsl.xmission.com>
	<4666D426.2070606@trash.net> <20070606155634.GA15067@ms2.inr.ac.ru>
	<4666E1B2.1070109@trash.net> <20070606191409.GA2495@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	socketcan@hartkopp.net, hadi@cyberus.ca, xemul@sw.ru, tgraf@suug.ch
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:50312 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752113AbXFGIJu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 04:09:50 -0400
In-Reply-To: <20070606191409.GA2495@ms2.inr.ac.ru> (Alexey Kuznetsov's message
	of "Wed, 6 Jun 2007 23:14:09 +0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> writes:

> Hello!
>
>> Good point, I didn't think of that. Is there a version of this patch
>> that already uses different namespaces so I can look at it?
>
> Pavel does not like the idea. It looks "not exactly pretty", like you said. :-)
>
> The alternative is to create pair in main namespace and then move
> one end to another namespace renaming it and changing index.
> Why I do not like it? Because this makes RTM_NEWLINK just useless step,
> all its work is undone and real work is remade when the device moves,
> with all the unrettiness moved to another place.

- A move network device between namespaces operation is necessary.
- If we limit these devices to just communication between namespaces
  we severely limit their utility.  In particular there are know applications
  now that do not need this.
- Further I believe by using RTM_NEWLINK the ethernet tunnel driver
  will never need to have any code that knows about namespaces,
  all that is needed is for RTM_NEWLINK to have an appropriate default
  network namespace, (the network namespace of the netlink socket).

>>From another hand, some move operation is required in any case.
> Right now in openvz the problem is solved in tricky, but quite
> inerseting way: all the devices in main namespace are assigned
> with odd index, child devices get odd index. So that, when a device
> moves from main namespace to child, openvz does not need to change
> ifindex, conflict is impossible. Well, it is working approach.
> But it is not pretty either.

We can solve the ifindex change even more simply by simply using
a global ifindex sequence number for now.  In the context of migration
that is likely to prove insufficient for virtual devices but for now
it is simple, it already exists and it is good enough.

>> Are network namespace completely seperated or is there some hierarchy
>> with all lower namespaces visible above or something like that?
>
> Right now they are completely separate.
>
> It is possible to make child devices visible in parent namespace
> like it is done for process pids: i.e. there is an abstract identity
> which is seen under different names and indices in different namespaces.
> Sounds cool, but this add a lot of complexity, which has no meaning
> outside of context of device creation, I do not think it is worth to do.

I completely agree.  There is no advantage and a considerable
disadvantage in having network namespaces being other then completely
separate.

>> The identity of the main device has no meaning within a different
>> namespace, but are there other reasons for hiding it?
>
> Perhaps, security. It is not a good idea to leak information
> about parent namespace to child namespace.
>
> Also, people will want to see emulated ethernet inside namespace
> looking exactly like ethernet. No freaking additional attributes.

As long as we keep ourselves within the usual variation of ethernet
network devices we should be fine.  For someone who wants to know
we can't hide the fact we are a particular kind of ethernet device.

Eric

