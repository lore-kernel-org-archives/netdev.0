From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next] [RFC] netns: enable cross-ve Unix sockets
Date: Thu, 02 Oct 2008 13:03:04 -0700
Message-ID: <m1r66yvk7b.fsf@frodo.ebiederm.org>
References: <1222858454-7843-1-git-send-email-den@openvz.org>
	<48E35B4C.1040303@fr.ibm.com> <1222860776.23573.49.camel@iris.sw.ru>
	<48E3653C.1070701@fr.ibm.com> <1222862583.23573.54.camel@iris.sw.ru>
	<48E36ABF.8030908@fr.ibm.com> <48E36BFA.3040904@openvz.org>
	<48E36DA0.9080400@fr.ibm.com> <1222866717.23573.58.camel@iris.sw.ru>
	<48E37F1B.20601@fr.ibm.com> <1222872885.23573.64.camel@iris.sw.ru>
	<48E394D2.5090709@fr.ibm.com> <48E397C1.6050407@openvz.org>
	<48E3998D.4040709@fr.ibm.com> <48E39A7A.8090800@openvz.org>
	<48E3A21E.3060504@fr.ibm.com> <1222942883.6327.13.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org, benjamin.thery@bull.net
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:33296 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752427AbYJBUFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 16:05:51 -0400
In-Reply-To: <1222942883.6327.13.camel@iris.sw.ru> (Denis V. Lunev's message
	of "Thu, 02 Oct 2008 14:21:23 +0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I do not believe we have yet met the burden of proof necessary to make the proposed
semantic change.

"Denis V. Lunev" <den@openvz.org> writes:

> On Wed, 2008-10-01 at 18:15 +0200, Daniel Lezcano wrote:
>> 
>>   1 - the current behaviour is full isolation. Shall we/can we change 
>> that without taking into account there are perhaps some people using 
>> this today ? I don't know.
> We have a direct request from people using to remove this state of
> isolation.

Users of a brittle but convenient hack not application developers.

Which means there is demand for this class of communication but it
doesn't mean that the suggested way is the right way.

>>   2 - I wish to launch a non chrooted application inside a namespace, 
>> sharing the file system without sharing the af_unix sockets, because I 
>> don't want the application running inside the container overlap with the 
>> socket af_unix of another container. I prefer to detect a collision with 
>> a strong isolation and handle it manually (remount some part of the fs 
>> for example).
> with common filesystem you have to detect collisions at least for FIFOs.
> This situation is the same. Basically, if we'll treat named Unix sockets
> as an improved FIFO - it's better to use the same approach

There are two aspects to this.

1) Looking up the proxy object in the filesystem.

   With that I agree that the file system access rules are sufficient.
   If we don't want the possibility of proxy objects you simply configure
   the system so that there are no shared files between namespaces.

2) How we interpret the proxy object.

   Currently the shared filesystem aka NFS precedent is that you can see
   the unix domain socket but not use it.  Just what we have implemented now.

As for FIFO you are be right that there is a potential bug there.  Likely those
fall in the yet to be implemented device namespace.  It is certainly an area
of the code we have not audited and thought about, so there is no precedent
set.

>>   3 - I would like to be able to reduce this isolation (your point) to 
>> share the af_unix socket for example to use /dev/klog or something else.
>> 
>> I don't know how much we can consider the point 1, 2 pertinent, but 
>> disabling 3 lines of code via a sysctl with strong isolation as default 
>> and having a process unsharing the namespace in userspace and changing 
>> this value to less isolation is not a big challenge IMHO :)
> the real questions is _who_ is responsible for this kind of staff ->
> node (parent container) administrator or container administrator. I
> strongly vote for first.
>
> Also if we are talking about such kind of staff, I dislike global
> kludge. This should be a property of two concrete VEs and better two
> concrete sockets. Unfortunately, setsockopt is not an option :(


We support sockets from different namespaces in a single process.

I agree that to keep the hack working we can not use setsockopt.
I don't agree that we want to keep the hack working.

- The code needs an audit to think about what it means to exchange packets
  between unix domain sockets in different network namespaces.  There is
  surprising a lot of code in veth to accommodate that.

  If we have too many places where we need to do something strange it is
  going to make code maintenance difficult.

- The semantics get stranger with respect to interpreting unix domain socket
  proxy objects.   Sometimes we can connect to someplace non-local and sometimes
  we can't.

- We can do this without changing the semantics of how socket proxy objects
  are interpreted, as it is possible for a process to use sockets in two different
  network namespaces.  That requires application level changes.

- It is prohibitively difficult to implement unix domain sockets that talk between
  different kernels (file descriptors sharing offsets and garbage collection of in
  flight sockets ouch!).  This means that encouraging the use of unix domain sockets
  to transparently connect applications in different containers is probably a bad
  idea.  This is completely different from FIFO's that are simple enough it is not
  hard to relay data between machines and get it right.

- I don't know how much using unix domain sockets to talk between different domains
  transparently will confuse applications, and increase the risk of security exploits.
  I don't think it will be much though as we already have unix permissions checking
  from the proxy object, and we should be handling the namespace transitions of passed
  objects in the code that sends credentials and file descriptors.

Eric
