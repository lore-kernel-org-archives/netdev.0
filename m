From: Samir Bellabes <sam@synack.fr>
Subject: Re: [PATCH v2 0/2] RFC, aiding pid/network correlation
Date: Sat, 02 Aug 2014 02:30:54 +0200
Message-ID: <87lhr77mwx.fsf@synack.fr>
References: <1406856100-21674-1-git-send-email-pmoody@google.com>
	<87y4v876bs.fsf@synack.fr>
	<r3noaw4m8g6.fsf@perdido.sfo.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org, brandon.carpenter@pnnl.gov,
	casey@schaufler-ca.com, netdev@vger.kernel.org
To: Peter Moody <pmoody@google.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <r3noaw4m8g6.fsf@perdido.sfo.corp.google.com> (Peter Moody's
	message of "Fri, 01 Aug 2014 10:22:01 -0700")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Moody <pmoody@google.com> writes:

> Hi Samir,
>
>>>  * Is there already an existing mechanism to do this?
>>
>> Hi Peter,
>> I have built a such subsystem, for years now.
>> Please, you can access latest public patchset here :
>>
>> https://lkml.org/lkml/2011/5/5/132
>
> Interesting, thanks! I hadn't know about snet.

Peter,

After taking a look at your patchset, I understand that you want to make
a link between network packets and applications, by keeping
system-related informations inside a memory structure (this process
tree).

I started snet because of this. Packet filtering is not enough
powerfull to be "easily" used by users. By "users", it includes network
specialists too, because of this missing link to informations related to
"system" (pid, process, memory, syscall, etc), and not only "network"
related (procotol, port, etc.)

I think indeed that LSM hooks are the perfect place to understand the
behavior of applications.

> The patches don't apply cleanly, and while the merge wasn't difficult,
> it looks like the code has gotten out of sync with mainline and doesn't
> build (at least when applied to security-next). Did anything ever happen
> with snet?

sure, this public release is out of sync with current kernels (it's 3
years old). I can release a up to date patchset.

> From looking at the code, it looks kind of like a 'little-snitch' for
> linux, is that right?

Indeed, snet is including this kind of "control application", which is
missing to the linux world, as packet filter is the "only way" to go.

Main goal is to build a framework for having a kind of "LSM userspace
subsystem", pushing the decision to userspace, and to other related OS
in the network. 

Why this ?
- LSM are monolithic : applying a system policy on one isolated OS is
no more valuable with our connected world.
- network filtering tools are not system related : what is more easiest
than this network related analysis : "ok, so that's chromium which is
connecting to .." ? But this sentence is only build this system related
information (process, syscall "connect"), not on some "packet
inspection".
- build new kind of security models, not only related to a isolated OS,
but seeing the network as a global system. We are only sharing policy
between hosts.. which is pretty inefficent nowsdays.

>A process tries to open a socket/etc and snet
> requests that the user accept/reject the connection,

indeed, this is one of the possible application of snet.
but by "user", it's not only the physical user. It may be a process from
userspace, or a decision from a central server in the network. So to
fully agree on this, I may say : "snet requets userspace to
accept/reject the connection". Decision comes from user in real time
(click) or a security process built on a (local or distributed) formal
model.

> and presumably
> while the user is being queried one could dig through /proc to find the
> exe/cmdline of the process making the request.

we don't have dig /proc, and I think it's a bad idea.
In fact, we don't need it at all.
Indeed, LSM hooks are occuring in the process context, so at the time of
the syscall, system information is related to the application.

So, pid information is already part of the message sent
from kernel subsystem to userspace. see snet_nl_send_event()
exe/cmdline is in the same way sent from snet kernel subsystem (but it
wasn't in the 2011 patches series)

but I think you get it right on the fact that extracting information
*related* to the syscall is the most valuable part.

In the same time, current behavior is to put the process to a wait
queue, until a verdict from userspace is coming back. (process context
allow to sleep here)

a look at "genetlink attributes" in snet.h will give you access to all
possible kind of available informations (at the time of this patch 3
years ago, now the list is more powerfull, and not only related to
network) 

> One thing that Hone does which snet doesn't seem to do (apologies if
> this is incorrect but I can't test) is that it provides a full process
> tree for a given pid back to init.

snet is more like a framework now.
you can interactively register which syscall you want to monitor.
then kernel substem will sent you informations.
unregister, and the kernel subsystem is going quiet.

in order to build your process tree, you just use the userspace lib (I
don't think it is yet publicly available, I have to put this up-to-date
too) 

the lib is build on the same libpcap callback mecanism : you register a
syscall with a callback function. your callback function is called to
manage the informations every time the related syscall occured.
Here you can build your process tree, or do whatever you want. 

Now, kernel subsystem doesn't required always a userspace verdict, as
there is a "monitor mode", which is exactly what you will use if you
decide to use snet.

As I said, snet is more like a framework to push this valuable
informations to userspace, do whatever you want, and send back your
policy decision (if it needs one) 

> When doing an investigation into a
> system compromise, knowing what started the process making the
> suspicious connection(s) (and what started *that* process) is often just
> as important as knowing that there's a compromise to begin with.

this is exaclty one exemple of informations which is truly valuable by
users or admins, and not direcly/interactively available on ours systems.

for me, best way to do that is building a simple and generic framework
which will help you/admins/users to build simple scenarios from
userspace to get what you want. 

> Cheers,

Peter, thank you for pushing this discussion on the list, I think this
kind of usability is missing, now for years, from our systems.

cheers,

sam
