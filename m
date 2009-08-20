From: Avi Kivity <avi@redhat.com>
Subject: Re: configfs/sysfs
Date: Thu, 20 Aug 2009 09:09:21 +0300
Message-ID: <4A8CE891.2010502__16715.3685157702$1250748612$gmane$org@redhat.com>
References: <4A8971A8.2040102@gmail.com> <20090817150844.GA3307@elte.hu> <4A89B08A.4010103@gmail.com> <4A8A674E.8070200@redhat.com> <4A8ABEC9.6090006@gmail.com> <4A8AD678.7050609@redhat.com> <4A8B9B79.9050004@gmail.com> <4A8BA5AE.3030308@redhat.com> <1250706227.27590.156.camel@haakon2.linux-iscsi.org> <4A8C5CBB.10605@redhat.com> <20090819221654.GA29503@mail.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	Ingo Molnar <mingo@elte.hu>,
	Anthony Liguori <anthony@codemonkey.ws>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45745 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752949AbZHTGJc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Aug 2009 02:09:32 -0400
In-Reply-To: <20090819221654.GA29503@mail.oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/20/2009 01:16 AM, Joel Becker wrote:
>> My high level concern is that we're optimizing for the active
>> sysadmin, not for libraries and management programs.  configfs and
>> sysfs are easy to use from the shell, discoverable, and easily
>> scripted.  But they discourage documentation, the text format is
>> ambiguous, and they require a lot of boilerplate to use in code.
>>      
> 	I don't think they "discourage documentation" anymore than any
> ioctl we've ever had.  At least you can look at the names and values and
> take a good stab at it (configfs is better than sysfs at this, by virtue
> of what it does, but discoverability is certainly not as good as real
> documentation).
> 	With an ioctl() that isn't (well) documented, you have to go
> read the structure and probably even read the code that uses the
> structure to be sure what you are doing.
>    

An ioctl structure and a configfs/sysfs readdir provide similar 
information (the structure also provides the types of fields and isn't 
able to hide some of these fields).

"Looking at the values" is what I meant by discouraging documentation.  
That implies looking at a self-documenting live system.  But that tells 
you nothing about which fields were added in which versions, or fields 
which are hidden because your hardware doesn't support them or because 
you didn't echo 1 > somewhere.

>> You could argue that you can wrap *fs in a library that hides the
>> details of accessing it, but that's the wrong approach IMO.  We
>> should make the information easy to use and manipulate for programs;
>> one of these programs can be a fuse filesystem for the active
>> sysadmin if someone thinks it's important.
>>      
> 	You are absolutely correct that they are a boon to the sysadmin,
> where in theory programs can do better with binary interfaces.  Except
> what programs?  I can't do an ioctl or a syscall from a shell script
> (no, using bash's network capabilities to talk to netlink does not
> count).  Same with perl/python/whatever where you have to write
> boilerplate to create binary structures.
>    

The maintainer of the subsystem should provide a library that talks to 
the binary interface and a CLI program that talks to the library.  
Boring nonkernely work.  Alternatively a fuse filesystem to talk to the 
library, or an IDL can replace the library.

> 	These interfaces have two opposing forces acting on them.  They
> provide a reasonably nice way to cross the user<->kernel boundary, so
> people want to use them.  Programmatic things, like a power management
> daemon for example, don't want sysadmins touching anything.  It's just
> an interface for the daemon.

Many things start oriented at people and then, if they're useful, cross 
the lines to machines.  You can convert a machine interface to a human 
interface at the cost of some work, but it's difficult to undo the 
deficiencies of a human oriented interface so it can be used by a program.

> Conversely, some things are really knobs
> for the sysadmin.

I disagree.  If it's useful for a human, it's useful for a machine.

Moreover, *fs+bash is a user interface.  It happens that bash is good at 
processing files, and filesystems are easily discoverable, so we code to 
that.  But we make it more difficult to provide other interfaces to the 
same controls.


> There's nothing else to it.  Why should they have to
> code up a C program just to turn a knob?

Many kernel developers believe that userspace is burned into ROM and the 
only thing they can change is the kernel.  That turns out to be 
incorrect.  If you don't want users to write C programs to access your 
interface, write your own library+CLI.  That will have the added benefit 
of providing meaningful errors as well ("Invalid argument" vs "frob must 
be between 52 and 91").  The program can have a configuration file so 
you don't need to reecho the values on boot.  It can have a --daemon 
mode and do something when an event occurs.

> Configfs, as its name implies,
> really does exist for that second case.  It turns out that it's quite
> nice to use for the first case too, but if folks wanted to go the
> syscall route, no worries.
>    

Eventually everything is used in the first case.  For example in the 
virtualization space it is common to have a zillion nodes running 
virtual machine that are only accessed by a management node.

> 	I've said it many times.  We will never come up with one
> over-arching solution to all the disparate use cases.  Instead, we
> should use each facility - syscalls, ioctls, sysfs, configfs, etc - as
> appropriate.  Even in the same program or subsystem.
>    

configfs is optional, but sysfs is not.  Everything exposed via sysfs 
needs to continue to be exposed via sysfs, and new things as well for 
consistency.  So now if someone wants a syscall interface they must 
duplicate the syscall interface, not replace it.

>> - ambiguity
>>
>> What format is the attribute?  does it accept lowercase or uppercase
>> hex digits?  is there a newline at the end?  how many digits can it
>> take before the attribute overflows?  All of this has to be
>> documented and checked by the OS, otherwise we risk regressions
>> later.  In contrast, __u64 says everything in a binary interface.
>>      
> 	Um, is that __u64 a pointer to a userspace object?  A key to a
> lookup table?  A file descriptor that is padded out?  It's no less
> ambiguous.
>    

__u64 says everything about the type and space requirements of a field.  
It doesn't describe everything (like the name of the field or what it 
means) but it does provide a bunch of boring information that people 
rarely document in other ways.

If my program reads a *fs field into a u32 and it later turns out the 
field was a u64, I'll get an overflow.  It's a lot harder to get that 
wrong with a typed interface.

>> - lifetime and access control
>>
>> If a process brings an object into being (using mkdir) and then
>> dies, the object remains behind.  The syscall/ioctl approach ties
>> the object into an fd, which will be destroyed when the process
>> dies, and which can be passed around using SCM_RIGHTS, allowing a
>> server process to create and configure an object before passing it
>> to an unprivileged program
>>      
> 	Most things here do *not* want to be tied to the lifetime of one
> process.  We don't want our cpu_freq governor changing just because the
> power manager died.
>    

Using file descriptors doesn't force you to tie their lifetime to the 
fd; it only allows it.

>> You may argue, correctly, that syscalls and ioctls are not as
>> flexible.  But this is because no one has invested the effort in
>> making them so.  A struct passed as an argument to a syscall is not
>> extensible.  But if you pass the size of the structure, and also a
>> bitmap of which attributes are present, you gain extensibility and
>> retain the atomicity property of a syscall interface.  I don't think
>> a lot of effort is needed to make an extensible syscall interface
>> just as usable and a lot more efficient than configfs/sysfs.  It
>> should also be simple to bolt a fuse interface on top to expose it
>> to us commandline types.
>>      
> 	Your extensible syscall still needs to be known.  The
> flexibility provided by configfs and sysfs is of generic access to
> non-generic things.  It's different.
> 	The follow-ups regarding the perf_counter call are a good
> example.  If you know the perf_counter call, you can code up a C program
> that asks what attributes or things are there.  But if you don't, you've
> first got to find out that there's a perf_counter call, then learn how
> to use it.  With configfs/sysfs, you notice that there's now a
> perf_counter directory under a tree, and you can figure out what
> attributes and items are there.
>    

Right, that's the great allure of *fs, discoverability.  Everything is 
at your fingertips.  Except if you're writing a program to manage 
things.  The program can't explore *fs until it's run and usually does 
not want to present nongeneric things in a generic way.  Ultimately most 
of our users are behind programs.


>> configfs is more maintainable that a bunch of hand-maintained
>> ioctls.  But if we put some effort into an extendable syscall
>> infrastructure (perhaps to the point of using an IDL) I'm sure we
>> can improve on that without the problems pseudo filesystems
>> introduce.
>>      
> 	Oh, boy, IDL :-)  Seriously, if you can solve the "how do I just
> poke around without actually writing C code or installing a
> domain-specific binary" problem, you will probably get somewhere.
>    

IDL is very unpleasant to work with but it gets the work done.  I don't 
see an issue with domain specific binaries (except that you have to 
write them).  Some say there's the problem of distribution, but if the 
kernel distributed itself to the user somehow then the tool can be 
distributed just as well (maybe via tools/).

>> I can't really fault a project for using configfs; it's an accepted
>> and recommented (by the community) interface.  I'd much prefer it
>> though if there was an effort to create a usable fd/struct based
>> alternative.
>>      
> 	Oh, and configfs was explicitly designed to be interface
> agnostic to the client.  The filesystem portions, to the best of my
> ability, are not exposed to client drivers.  So you can replace the
> configfs filesystem interface with a system call set that does the same
> operations, and no configfs user will actually need to change their
> code (if you want to change from text values to non-text, that would
> require changing the show/store operation prototypes, but that's about
> it).
>
>
>    

But the user visible part is now ABI.  I have no issues with the kernel 
internals.


-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

