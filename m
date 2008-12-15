From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [PATCH] AF_VMCHANNEL address family for	guest<->host	communication.
Date: Mon, 15 Dec 2008 14:52:07 -0800
Message-ID: <4946DF97.7070600@goop.org>
References: <20081214115054.4066.14557.stgit@dhcp-1-237.tlv.redhat.com>	<20081214.224436.55256593.davem@davemloft.net>	<4946717F.2090809@codemonkey.ws> <494697D4.6080300@goop.org> <4946A5E0.5080303@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4946A5E0.5080303@codemonkey.ws>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Anthony Liguori wrote:
> Jeremy Fitzhardinge wrote:
>   
>>> Each of these sockets are going to be connected to a backend (to 
>>> implement guest<=>copy/paste for instance).  We want to implement 
>>> those backends in userspace and preferably in QEMU.
>>>
>>> Using some raw protocol over ethernet means you don't have 
>>> reliability.  If you use a protocol to get reliability (like TCP), 
>>> you now have to implement a full TCP/IP stack in userspace or get the 
>>> host kernel involved.  I'd rather not get the host kernel involved 
>>> from a security perspective.
>>>   
>>>       
>> There's nothing wrong with user-mode TCP, or you could run your TCP 
>> stack in a special-purpose guest if you're really paranoid.
>>     
>
> That seems unnecessarily complex.
>   

Well, the simplest thing is to let the host TCP stack do TCP.  Could you 
go into more detail about why you'd want to avoid that?

> This is why I've been pushing for the backends to be implemented in 
> QEMU.  Then QEMU can marshal the backend-specific state and transfer it 
> during live migration.  For something like copy/paste, this is obvious 
> (the clipboard state).  A general command interface is probably 
> stateless so it's a nop.
>   

Copy/paste seems like a particularly bogus example.  Surely this isn't a 
sensible way to implement it?

> I'm not a fan of having external backends to QEMU for the very reasons 
> you outline above.  You cannot marshal the state of a channel we know 
> nothing about.  We're really just talking about extending virtio in a 
> guest down to userspace so that we can implement paravirtual device 
> drivers in guest userspace.  This may be an X graphics driver, a mouse 
> driver, copy/paste, remote shutdown, etc.
>   
> A socket seems like a natural choice.  If that's wrong, then we can 
> explore other options (like a char device, virtual fs, etc.).

I think a socket is a pretty poor choice.  It's too low level, and it 
only really makes sense for streaming data, not for data storage 
(name/value pairs).  It means that everyone ends up making up their own 
serializations.  A filesystem view with notifications seems to be a 
better match for the use-cases you mention (aside from cut/paste), with 
a single well-defined way to serialize onto any given channel.  Each 
"file" may well have an application-specific content, but in general 
that's going to be something pretty simple.

>   This 
> shouldn't be confused with networking though and all the talk of doing 
> silly things like streaming fence traffic through it just encourages the 
> confusion.

I'm not sure what you're referring to here.

    J
