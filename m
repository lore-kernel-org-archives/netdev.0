From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [PATCH] AF_VMCHANNEL address family for guest<->host	communication.
Date: Mon, 15 Dec 2008 12:45:52 -0600
Message-ID: <4946A5E0.5080303@codemonkey.ws>
References: <20081214115054.4066.14557.stgit@dhcp-1-237.tlv.redhat.com>	<20081214.224436.55256593.davem@davemloft.net> <4946717F.2090809@codemonkey.ws> <494697D4.6080300@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <494697D4.6080300@goop.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeremy Fitzhardinge wrote:
>> Each of these sockets are going to be connected to a backend (to 
>> implement guest<=>copy/paste for instance).  We want to implement 
>> those backends in userspace and preferably in QEMU.
>>
>> Using some raw protocol over ethernet means you don't have 
>> reliability.  If you use a protocol to get reliability (like TCP), 
>> you now have to implement a full TCP/IP stack in userspace or get the 
>> host kernel involved.  I'd rather not get the host kernel involved 
>> from a security perspective.
>>   
>
> There's nothing wrong with user-mode TCP, or you could run your TCP 
> stack in a special-purpose guest if you're really paranoid.

That seems unnecessarily complex.

>> An inherently reliable socket transport solves the above problem 
>> while keeping things simple.  Note, this is not a new concept.  There 
>> is already an AF_IUCV for s390.  VMware is also developing an AF_VMCI 
>> socket family.
>>   
>
> The trouble is that it presumes that the host and guest (or whoever 
> the endpoints are) are on the same physical machine and will remain 
> that way.  Given that live migration is a feature that people seem to 
> like, then you'd end up needing to transport this protocol over a real 
> network anyway - and at that point you may as well use proper 
> TCP/IP.   The alternative is to say either "if you use this feature 
> you can't migrate, and you can only resume on the same host", or "you 
> can use this feature, and we'll work out a global namespace and proxy 
> it over TCP for you".  Neither seems very satisfactory.

This is why I've been pushing for the backends to be implemented in 
QEMU.  Then QEMU can marshal the backend-specific state and transfer it 
during live migration.  For something like copy/paste, this is obvious 
(the clipboard state).  A general command interface is probably 
stateless so it's a nop.

I'm not a fan of having external backends to QEMU for the very reasons 
you outline above.  You cannot marshal the state of a channel we know 
nothing about.  We're really just talking about extending virtio in a 
guest down to userspace so that we can implement paravirtual device 
drivers in guest userspace.  This may be an X graphics driver, a mouse 
driver, copy/paste, remote shutdown, etc.

A socket seems like a natural choice.  If that's wrong, then we can 
explore other options (like a char device, virtual fs, etc.).  This 
shouldn't be confused with networking though and all the talk of doing 
silly things like streaming fence traffic through it just encourages the 
confusion.

Regards,

Anthony Liguori

>    J

