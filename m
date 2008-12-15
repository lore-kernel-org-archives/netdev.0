From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [PATCH] AF_VMCHANNEL address family for	guest<->host	communication.
Date: Mon, 15 Dec 2008 15:44:22 -0800
Message-ID: <4946EBD6.9080201@goop.org>
References: <20081214115054.4066.14557.stgit@dhcp-1-237.tlv.redhat.com>	<20081214.224436.55256593.davem@davemloft.net>	<4946717F.2090809@codemonkey.ws> <494697D4.6080300@goop.org> <4946A5E0.5080303@codemonkey.ws> <4946DF97.7070600@goop.org> <4946E36D.8060503@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:38908 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752422AbYLOXoY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Dec 2008 18:44:24 -0500
In-Reply-To: <4946E36D.8060503@codemonkey.ws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anthony Liguori wrote:
> Jeremy Fitzhardinge wrote:
>> Anthony Liguori wrote:
>>>
>>> That seems unnecessarily complex.
>>>   
>>
>> Well, the simplest thing is to let the host TCP stack do TCP.  Could 
>> you go into more detail about why you'd want to avoid that?
>
> The KVM model is that a guest is a process.  Any IO operations 
> original from the process (QEMU).  The advantage to this is that you 
> get very good security because you can use things like SELinux and 
> simply treat the QEMU process as you would the guest.  In fact, in 
> general, I think we want to assume that QEMU is guest code from a 
> security perspective.
>
> By passing up the network traffic to the host kernel, we now face a 
> problem when we try to get the data back.  We could setup a tun device 
> to send traffic to the kernel but then the rest of the system can see 
> that traffic too.  If that traffic is sensitive, it's potentially unsafe.

Well, one could come up with a mechanism to bind an interface to be only 
visible to a particular context/container/something.

> You can use iptables to restrict who can receive traffic and possibly 
> use SELinux packet tagging or whatever.  This gets extremely complex 
> though.

Well, if you can just tag everything based on interface its relatively 
simple.

> It's far easier to avoid the host kernel entirely and implement the 
> backends in QEMU.  Then any actions the backend takes will be on 
> behalf of the guest.  You never have to worry about transport data 
> leakage.

Well, a stream-like protocol layered over a reliable packet transport 
would get you there without the complexity of tcp.  Or just do a 
usermode tcp; its not that complex if you really think it simplifies the 
other aspects.

>
>>> This is why I've been pushing for the backends to be implemented in 
>>> QEMU.  Then QEMU can marshal the backend-specific state and transfer 
>>> it during live migration.  For something like copy/paste, this is 
>>> obvious (the clipboard state).  A general command interface is 
>>> probably stateless so it's a nop.
>>>   
>>
>> Copy/paste seems like a particularly bogus example.  Surely this 
>> isn't a sensible way to implement it?
>
> I think it's the most sensible way to implement it.  Would you suggest 
> something different?

Well, off the top of my head I'm assuming the requirements are:

    * the goal is to unify the user's actual desktop session with a
      virtual session within a vm
    * a given user may have multiple VMs running on their desktop
    * a VM may be serving multiple user sessions
    * the VMs are not necessarily hosted by the user's desktop machine
    * the VMs can migrate at any moment

To me that looks like a daemon running within the context of each of the 
user's virtual sessions monitoring clipboard events, talking over a TCP 
connection to a corresponding daemon in their desktop session, which is 
responsible for reconciling cuts and pastes in all the various sessions.

I guess you'd say that each VM would multiplex all its cut/paste events 
via its AF_VMCHANNEL/cut+paste channel to its qemu, which would then 
demultiplex them off to the user's real desktops.  And that since the VM 
itself may have no networking, it needs to be a special magic connection.

And my counter argument to this nicely placed straw man is that the 
VM<->qemu connection can still be TCP, even if its a private network 
with no outside access.

>
>>> I'm not a fan of having external backends to QEMU for the very 
>>> reasons you outline above.  You cannot marshal the state of a 
>>> channel we know nothing about.  We're really just talking about 
>>> extending virtio in a guest down to userspace so that we can 
>>> implement paravirtual device drivers in guest userspace.  This may 
>>> be an X graphics driver, a mouse driver, copy/paste, remote 
>>> shutdown, etc.
>>>   A socket seems like a natural choice.  If that's wrong, then we 
>>> can explore other options (like a char device, virtual fs, etc.).
>>
>> I think a socket is a pretty poor choice.  It's too low level, and it 
>> only really makes sense for streaming data, not for data storage 
>> (name/value pairs).  It means that everyone ends up making up their 
>> own serializations.  A filesystem view with notifications seems to be 
>> a better match for the use-cases you mention (aside from cut/paste), 
>> with a single well-defined way to serialize onto any given channel.  
>> Each "file" may well have an application-specific content, but in 
>> general that's going to be something pretty simple.
>
> I had suggested a virtual file system at first and was thoroughly 
> ridiculed for it :-)  There is a 9p virtio transport already so we 
> could even just use that.

You mean 9p directly over a virtio ringbuffer rather than via the 
network stack?  You could do that, but I'd still argue that using the 
network stack is a better approach.

> The main issue with a virtual file system is that it does map well to 
> other guests.  It's actually easier to implement a socket interface 
> for Windows than it is to implement a new file system.

There's no need to put the "filesystem" into the kernel unless something 
else in the kernel needs to access it.  A usermode implementation 
talking over some stream interface would be fine.

> But we could find ways around this with libraries.  If we used 9p as a 
> transport, we could just provide a char device in Windows that 
> received it in userspace.

Or just use a tcp connection, and do it all with no kernel mods.

(Is 9p a good choice?  You need to be able to subscribe to events 
happening to files, and you'd need some kind of atomicity guarantee.  I 
dunno, maybe 9p already has this or can be cleanly adapted.)

    J
