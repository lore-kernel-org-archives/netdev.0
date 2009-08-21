From: Avi Kivity <avi@redhat.com>
Subject: Re: configfs/sysfs
Date: Fri, 21 Aug 2009 07:14:52 +0300
Message-ID: <4A8E1F3C.5000501__36298.7843262546$1250828176$gmane$org@redhat.com>
References: <4A89B08A.4010103@gmail.com> <4A8A674E.8070200@redhat.com> <4A8ABEC9.6090006@gmail.com> <4A8AD678.7050609@redhat.com> <4A8B9B79.9050004@gmail.com> <4A8BA5AE.3030308@redhat.com> <1250706227.27590.156.camel@haakon2.linux-iscsi.org> <4A8C5CBB.10605@redhat.com> <20090819221654.GA29503@mail.oracle.com> <4A8CE891.2010502@redhat.com> <20090820224828.GC10558@mail.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	Ingo Molnar <mingo@elte.hu>,
	Anthony Liguori <anthony@codemonkey.ws>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6669 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751184AbZHUEPE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Aug 2009 00:15:04 -0400
In-Reply-To: <20090820224828.GC10558@mail.oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/21/2009 01:48 AM, Joel Becker wrote:
> On Thu, Aug 20, 2009 at 09:09:21AM +0300, Avi Kivity wrote:
>    
>> On 08/20/2009 01:16 AM, Joel Becker wrote:
>>      
>>> 	With an ioctl() that isn't (well) documented, you have to go
>>> read the structure and probably even read the code that uses the
>>> structure to be sure what you are doing.
>>>        
>> An ioctl structure and a configfs/sysfs readdir provide similar
>> information (the structure also provides the types of fields and
>> isn't able to hide some of these fields).
>>      
> 	With an ioctl structure, I can't take a look at what the values
> look like unless I read the code or write up a C program.  With a
> configfs file, I can just cat the thing.
>    

Unless it's system dependent like many sysfs files.  If you're coding 
something that's supposed to run on several boxes, coding by example is 
not a good idea.  Look up the documentation to find out what the values 
look like (unfortunately often there is no documentation).

Looking at the value on your box does not indicate the range of values 
on other boxes or even if the value will be present on other boxes (due 
to having older kernels or different configurations).

>
>    
>> "Looking at the values" is what I meant by discouraging
>> documentation.  That implies looking at a self-documenting live
>> system.  But that tells you nothing about which fields were added in
>> which versions, or fields which are hidden because your hardware
>> doesn't support them or because you didn't echo 1>  somewhere.
>>      
> 	Most ioctls don't tell you that either.  It certainly won't let
> you know that field foo_arg1 is ignored unless foo_arg2 is set to 2, or
> things like that.
>    

Correct.  What I mean is that discoverability is great for a sysadmin or 
kernel developers exploring the system, but pretty useless for a 
programmer writing code that will run on other systems.  The majority of 
lkml users will find *fs easy to use and useful, but that's not the 
majority of our users.

> 	The problem of versioning requires discipline either way.  It's
> not obvious from many ioctls.  Conversely, you can create versioned
> configfs items via attributes or directories (same for sysfs, etc).
>    

Sure.

>> The maintainer of the subsystem should provide a library that talks
>> to the binary interface and a CLI program that talks to the library.
>> Boring nonkernely work.  Alternatively a fuse filesystem to talk to
>> the library, or an IDL can replace the library.
>>      
> 	Again, that helps the user nothing.  I don't know it exists.  I
> don't have it installed.  Unless it ships with the kernel, I have no
> idea about it.
>    

That's true for the lkml reader downloading a kernel from kernel.org 
(use git already) and run it on a random system.  But again the majority 
of users will run a distro which is supposed to integrate the kernel and 
userspace.  The short term gratification of early adopters harms the 
integration that more mainstream users expect.

>> Many things start oriented at people and then, if they're useful,
>> cross the lines to machines.  You can convert a machine interface to
>> a human interface at the cost of some work, but it's difficult to
>> undo the deficiencies of a human oriented interface so it can be
>> used by a program.
>>      
> 	It's work to convert either way.  Outside of fast-path things,
> the time it takes to strtoll() is unimportant.  Don't use configfs/sysfs
> for fast-path things.
>    

Infrastructure must be careful not to code itself into a corner.  
Already udev takes quite a bit of time to run and I have some memories 
of problems on thousand-disk configurations.  What works reasonably well 
with one disk may not work as well with 1000.

No doubt some of the problem is with udev, but I'm sure sysfs 
contributes.  As a software development exercise reading a table of 1000 
objects each with a couple dozen attributes should take less that a 
millisecond.

>> I disagree.  If it's useful for a human, it's useful for a machine.
>>      
> 	And if it's useful for a machine, a human might want to peek at
> it by hand someday to debug it.
>    

We have strace and wireshark to decode binary syscall and wire streams.

>> Moreover, *fs+bash is a user interface.  It happens that bash is
>> good at processing files, and filesystems are easily discoverable,
>> so we code to that.  But we make it more difficult to provide other
>> interfaces to the same controls.
>>      
> 	Not really.  Writing a sane CLI to a binary interface takes
> about as much work as writing a sane API library to a text interface.
> The hard part is not the conversion, in either direction.  The hard part
> is defining the interface.
>    

A *fs interface limits what you can do, so it makes writing the API 
library harder.  I'm talking about the issues with atomicity and 
notifications.

>>> Configfs, as its name implies,
>>> really does exist for that second case.  It turns out that it's quite
>>> nice to use for the first case too, but if folks wanted to go the
>>> syscall route, no worries.
>>>        
>> Eventually everything is used in the first case.  For example in the
>> virtualization space it is common to have a zillion nodes running
>> virtual machine that are only accessed by a management node.
>>      
> 	Everything is eventually used in the second case, and admin or a
> developer debugging why the daemon is going wrong.  Much easier from a
> shell or other generic accessor.  Much faster than having to download
> your library's source, learn how to build it, add some printfs, discover
> you have the wrong printfs...
>    

As a kernel/user interface, any syscall replacement for *fs is exposed 
via strace.  It's true that debugging C code is harder than a bit of bash.

>> __u64 says everything about the type and space requirements of a
>> field.  It doesn't describe everything (like the name of the field
>> or what it means) but it does provide a bunch of boring information
>> that people rarely document in other ways.
>>
>> If my program reads a *fs field into a u32 and it later turns out
>> the field was a u64, I'll get an overflow.  It's a lot harder to get
>> that wrong with a typed interface.
>>      
> 	And if you send the wrong thing to configfs or sysfs you'll get
> an EINVAL or the like.
> 	It doesn't look like configfs and sysfs will work for you.
> Don't use 'em!  Write your interfaces with ioctls and syscalls.  Write
> your libraries and CLIs.  In the end, you're the one who has to maintain
> them.  I don't ever want anyone thinking I want to force configfs on
> them.  I wrote it because it solves its class of problem well, and many
> people find it fits them too.  So I'll use configfs, you'll use ioctl,
> and our users will be happy either way because we make it work!
>    

No, I have to use *fs (at least sysfs) since that's the current blessed 
interface.  Fragmenting the kernel/userspace is the wrong thing to do, I 
value a consistent interface more than fixing the *fs problems (which 
are all fixable or tolerable).

This is not a call to deprecate *fs and switch over to a yet another new 
thing.  Users (and programmers) need some ABI stability.  It just arose 
because I remarked that I'm not in love with *fs interfaces in an 
unrelated flamewar and someone asked me why.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

