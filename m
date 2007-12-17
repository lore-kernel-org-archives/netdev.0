From: Ludovico Gardenghi <garden@cs.unibo.it>
Subject: Re: [PATCH 0/1] IPN: Inter Process Networking
Date: Mon, 17 Dec 2007 12:50:48 +0100
Message-ID: <20071217115048.GA12906@ripieno.somiere.org>
References: <20071217092401.GC4356@cs.unibo.it> <Pine.LNX.4.64.0712170327410.4467@asgard> <20071217104706.GA10966@ripieno.somiere.org> <Pine.LNX.4.64.0712170359260.4467@asgard>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Renzo Davoli <renzo@cs.unibo.it>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: david@lang.hm
Return-path: <netdev-owner@vger.kernel.org>
Received: from host253-196-149-62.serverdedicati.aruba.it ([62.149.196.253]:34895
	"EHLO styx.acheronte.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933295AbXLQLuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 06:50:51 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0712170359260.4467@asgard>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 17, 2007 at 04:10:19AM -0800, david@lang.hm wrote:

> if you are talking network connections between virtual systems, then the 
> exiting tap interfaces would seem to do everything you are looking for. you 
> can add them to bridges, route between them, filter traffic between them 
> (at whatever layer you want with netfilter), use multicast, etc as you 
> would any real interface.
>
> if, however, you are talking about non-network communications (your example 
> of sending raw video frames across the interface), and want multiple 
> processes to receive them, this sounds like exactly the thing that splice 
> was designed to do, distribute data to multiple recipiants simultaniously 
> and efficiantly.

I'll try to explain.

Our first interest was to be able to interconnect virtual, real, and partial
virtual machines. We developed VDE for this, it's a user-level L2
switch. Specific as it may be, it's quite popular as a simple but
flexible tool. It can interconnect UML, Qemu, UMView, slirp, everything that
can be connected to a tap interface, etc.

So, you say, it's a networking issue and we could live with tun/tap.
There's a major point here: at present, dealing with tun/tap, bridges,
routing is quite difficult if you are a *regular* user with *no*
capabilites at all. You have tun/tap persistency and association to a
specific user (or group, recently), at most. That's good - we don't want
regular users to mess with global networking rules and settings.

Think of a bunch of etherogeneous virtual machines, partial virtual
machines (i.e. VMs where only a subset of system calls may be
virtualized or not depending on the parameters - that's the case of
View-OS) that must be interconnected and that may or may not have a
connection to a real network interface (maybe via a tunnel towards a
different machine). There's no need for administrator intervention here.
Why should an user have to ask root to create lots of tap interfaces for
him, bind them in a bridge and set up filtering/routing rules? What
would the list of interfaces become when different users asked for the
same thing at the same time?

You could define a specific interconnecting bus, but we've already have
it: ethernet. VDE comes in help as it allows regular users to build
distributed ethernet networks.

VDE works fine, but at present often results in a bottleneck because of
the high number of user-processes involved and user-kernel-user switches
needed in order to transfer a single ethernet frame. Moving the core
inside the kernel would limit this problem and result in faster
communication with still no need for root intervention or global
namespace messing. (we're thinking if something can be done working with
containers or similar structures, both for networking and partial
virtualization, but that's another topic).

So we started thinking how to use existing kernel structures, and we
concluded that:

 - no existing kernel structures appeared to be optimal for this work;
 - if we've had to design a new structure, it would have been more
   useful if we tried to be as more general as we could.

At present we're still focused on networking and other applications are
just examples, but we thought that adding a general extensible multipoint
IPC family is quite better than adding the most specific solution to our
current problem.

Maybe people with experience in other fields may tell us if there are
other problems that can be resolved, or optimized, or simply made
simpler, with IPN. Maybe our proposal is not the best as for interface
and semantics. But we feel that it may fill an "empty space" in the
available IPC mechanisms with a quite simple but powerful approach.

> for a new family to be valuble, you need to show what it does that isn't 
> available in existing families.

Is it "more acceptable" to add a new address family or to add features
to existing ones? (my question is purely informative, I don't want to
sound sarcastic or whatever) For instance, someone proposed "let's just
add access control to the netlink family". It seems a though work. 

You proposed splice, other have proposed multicast or netlink. If I have
understood correctly, splice helps in copying data to different
destinations in a very fast way. But it needs a userspace program that
receives data, iterates on fds and splices the data "out", calling a
syscall for each destination.  syscall calling may have become very fast
but we still notice slowdowns due to the reasons I've explained before.

--- (the following is not related to IPN but i wanted to answer this too)

> I'm not familiar enough with ptrace vs utrace to know this argument. but I 
> haven't heard any of the virtualization people complaining about the 
> existing interfaces. They seem to have been happily useing them for a 
> number of years.

ptrace has a number of drawbacks that have been partially addressed
adding flags and parameters for "cheating" and obtaining better
performances. It's *slow* expecially if you want to copy data to/from the
process' memory (you need a system call for each word of memory). It
cannot be used in an efficient way to trace only a subset of system
calls. All or none. It has problems with signal management.
User-Mode Linux works because it's a very specific and "simple" case of
virtualization. If you want to do coarse-grained virtualization it may
be ok, but as soon as you want to add fine tuning while keeping
efficiency it becomes a hell.

We're developing tools intended to let a *regular* user (no root
intervention, again) to "build" a personal view of the system resources
(network, filesystem, etc) starting from what "he can do/see" as that
users and adding, removing, changing things. We'd like to let a user
live in a "potentially virtual" world exactly identical to the "real"
one. When he wants to change something he can. Mounting remote
filesystems, creating new virtual network interfaces, editing global
configuration files. No security issues here, there are no privileged
processes running. Nothing gets really mounted. The virtualizing layer
takes care of "building" the view around the user's processes.

We've done this with ptrace. It works but it surely cannot be used as a
"everyday" shell around every user process. We've done this with utrace.
The syscall-capturing functions have shrunk of an order of magnitude and
everything is more efficient, functional and cleaner.

Ludovico
-- 
<garden@acheronte.it>        #acheronte (irc.freenode.net) ICQ: 64483080
GPG ID: 07F89BB8          Jabber: gardengl@gmail.com Yahoo: gardenghelle
-- This is signature nr. 3558
