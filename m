From: david@lang.hm
Subject: Re: [PATCH 0/1] IPN: Inter Process Networking
Date: Mon, 17 Dec 2007 13:15:37 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0712171121290.13025@asgard.lang.hm>
References: <20071217092401.GC4356@cs.unibo.it> <Pine.LNX.4.64.0712170327410.4467@asgard>
 <20071217104706.GA10966@ripieno.somiere.org> <Pine.LNX.4.64.0712170359260.4467@asgard>
 <20071217115048.GA12906@ripieno.somiere.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Renzo Davoli <renzo@cs.unibo.it>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ludovico Gardenghi <garden@cs.unibo.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl081-033-126.lax1.dsl.speakeasy.net ([64.81.33.126]:41896
	"EHLO bifrost.lang.hm" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757195AbXLQUFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 15:05:09 -0500
In-Reply-To: <20071217115048.GA12906@ripieno.somiere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Dec 2007, Ludovico Gardenghi wrote:

> On Mon, Dec 17, 2007 at 04:10:19AM -0800, david@lang.hm wrote:
>
>> if you are talking network connections between virtual systems, then the
>> exiting tap interfaces would seem to do everything you are looking for. you
>> can add them to bridges, route between them, filter traffic between them
>> (at whatever layer you want with netfilter), use multicast, etc as you
>> would any real interface.
>>
>> if, however, you are talking about non-network communications (your example
>> of sending raw video frames across the interface), and want multiple
>> processes to receive them, this sounds like exactly the thing that splice
>> was designed to do, distribute data to multiple recipiants simultaniously
>> and efficiantly.
>
> I'll try to explain.
>
> Our first interest was to be able to interconnect virtual, real, and partial
> virtual machines. We developed VDE for this, it's a user-level L2
> switch. Specific as it may be, it's quite popular as a simple but
> flexible tool. It can interconnect UML, Qemu, UMView, slirp, everything that
> can be connected to a tap interface, etc.
>
> So, you say, it's a networking issue and we could live with tun/tap.
> There's a major point here: at present, dealing with tun/tap, bridges,
> routing is quite difficult if you are a *regular* user with *no*
> capabilites at all. You have tun/tap persistency and association to a
> specific user (or group, recently), at most. That's good - we don't want
> regular users to mess with global networking rules and settings.
>
> Think of a bunch of etherogeneous virtual machines, partial virtual
> machines (i.e. VMs where only a subset of system calls may be
> virtualized or not depending on the parameters - that's the case of
> View-OS) that must be interconnected and that may or may not have a
> connection to a real network interface (maybe via a tunnel towards a
> different machine). There's no need for administrator intervention here.
> Why should an user have to ask root to create lots of tap interfaces for
> him, bind them in a bridge and set up filtering/routing rules? What
> would the list of interfaces become when different users asked for the
> same thing at the same time?
>
> You could define a specific interconnecting bus, but we've already have
> it: ethernet. VDE comes in help as it allows regular users to build
> distributed ethernet networks.
>
> VDE works fine, but at present often results in a bottleneck because of
> the high number of user-processes involved and user-kernel-user switches
> needed in order to transfer a single ethernet frame. Moving the core
> inside the kernel would limit this problem and result in faster
> communication with still no need for root intervention or global
> namespace messing. (we're thinking if something can be done working with
> containers or similar structures, both for networking and partial
> virtualization, but that's another topic).

so it sounds like the real issue you are trying to deal with is that only 
root is allowed to make changes to the networking configuration, and you 
want to allow non-root users to make changes.

in doing this you started by duplicating the kernel networking 
functionality into userspace (your userspace L2 switch) and are running 
into performance problems so trying to push this into the kernel to reduce 
context switches.

besides your approach I see two other options on their way into the 
kernel.

1. no changes, run your switch in a VM and your users (with their group 
permissions) connect their VM interfaces to the interfaces of the VM 
running the switch/filtering. this allows them 'root' inside the VM where 
they can make all these changes.

this may have the same performance problems as your current userspace 
switch.

2. networking virtualization. there is work being done to be able to have 
what would be essentially multiple networking stacks on a machine to allow 
a VM/container to control some things without having to go through the 
tun/tap interface. This would allow a user to change the filtering rules 
without the changes being global.

however, note that if the VM's are more then just a test-bed and actually 
need to talk to the outside world, at some point they will need to connect 
to the real interfaces, and making that connection should still require 
superuser privilages on the master kernel.

besides, useing the standard networking stack has the advantage that if 
you end up needing to spread your VM's across multiple machines the 
support is already there, where adding a new IPC mechanism will require 
figuring out how to extend that mechanism across machines.

It also doesn't require the applications to be coded specificly for your 
mechanism. they just use standard networking API's and the virtual 
connections happen for them.

> So we started thinking how to use existing kernel structures, and we
> concluded that:
>
> - no existing kernel structures appeared to be optimal for this work;
> - if we've had to design a new structure, it would have been more
>   useful if we tried to be as more general as we could.
>
> At present we're still focused on networking and other applications are
> just examples, but we thought that adding a general extensible multipoint
> IPC family is quite better than adding the most specific solution to our
> current problem.
>
> Maybe people with experience in other fields may tell us if there are
> other problems that can be resolved, or optimized, or simply made
> simpler, with IPN. Maybe our proposal is not the best as for interface
> and semantics. But we feel that it may fill an "empty space" in the
> available IPC mechanisms with a quite simple but powerful approach.

I'm not the person to approve or disapprove adding this to the kernel, but 
when something similar was proposed a week or so ago, the reaction from 
many kernel developers was basicly the same as I articulated. While the 
explination this time is far more complete, I don't think it presents a 
compelling case for why this needs to be added instead of useing existing 
mechanisms.

the fact that the answers for "why not use splice" have been "it doesn't 
work for networking" and "why not use tun/tap" with "we may want to use it 
for non-networking things in the future" seems like you are playing both 
ends against the middle.

in this message you have articulated a new issue (the fact that tun/tap 
will do everything you want, you just want to be able to do this without 
needing to have superuser privilages). This is a valid issue, but there 
are other options on the way that may address this.

>> for a new family to be valuble, you need to show what it does that isn't
>> available in existing families.
>
> Is it "more acceptable" to add a new address family or to add features
> to existing ones? (my question is purely informative, I don't want to
> sound sarcastic or whatever) For instance, someone proposed "let's just
> add access control to the netlink family". It seems a though work.

useually it seems to be to add features to an existing family, especially 
if the features that need to be added are virtualization ones.

> You proposed splice, other have proposed multicast or netlink.

and the different answers have been to different problems.

if you need IP type routing and filtering then multicast over tun/tap is 
probably a far better answer.

if you are needing unstructured communication betwen processes then 
netlink or splice are the right answers (which one is right for your 
application depends on what you are trying to do)

> If I have
> understood correctly, splice helps in copying data to different
> destinations in a very fast way. But it needs a userspace program that
> receives data, iterates on fds and splices the data "out", calling a
> syscall for each destination.  syscall calling may have become very fast
> but we still notice slowdowns due to the reasons I've explained before.

but receiving data into a program from any source (pipe, kernel-space 
networking, userspace networking) all require system calls to transfer the 
data. so saying that receiving data from a pipe involes overhead on all 
receiving processes in a non-issue.

> --- (the following is not related to IPN but i wanted to answer this too)
<snipped discription of ptrace/utrace>
thanks for the explination.

David Lang
