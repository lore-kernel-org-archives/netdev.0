From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Procfs race condition bug
Date: Wed, 09 Jul 2014 21:40:07 -0700
Message-ID: <87fvi925eg.fsf@x220.int.ebiederm.org>
References: <CACVxJT8U-E+vYjGPbiop-7Fqcwt0sWhMtmuCRQHLAnALU+5AgQ@mail.gmail.com>
	<CACVxJT8+9oJa5r2acCdNe5+PjDxYVmASMY2Pcb=FyzB4x+0Naw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Mike Cardwell <mike.cardwell@grepular.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pavel Emelianov <xemul@parallels.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACVxJT8+9oJa5r2acCdNe5+PjDxYVmASMY2Pcb=FyzB4x+0Naw@mail.gmail.com>
	(Alexey Dobriyan's message of "Wed, 9 Jul 2014 15:20:53 +0300")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan <adobriyan@gmail.com> writes:

> [broken email]
>
> On Wed, Jul 9, 2014 at 3:17 PM, Alexey Dobriyan <adobriyan@gmail.com> wrote:
>>> I originally posted this two years ago (*) but received no response.
>>> I just had a look and the problem still exists on the 3.14 kernel
>>> I am currently running.
>>>
>>> I *think* I've uncovered a race condition bug in procfs.
>>> If I attempt to open a file in /proc/net, eg "/proc/net/tcp"
>>> it works fine, but if I spawn a POSIX thread and attempt to do it
>>> from there, it *usually* fails with a "No such file or directory",
>>> but some times succeeds. If I do a system call inside the thread
>>> to look up the thread ID and then open "/proc/THREADID/net/tcp"
>>> instead, it works fine.
>>>
>>> There are more details and some example code
>>> so you can replicate the problem on a stack overflow question
>>> I asked previously here:
>>> http://stackoverflow.com/questions/11580020/opening-proc-net-tcp-in-c-from-a-posix-thread-fails-most-of-the-time
>>>
>>> (*) https://lkml.org/lkml/2012/7/20/331
>>
>> Mike,
>>
>> as was correctly notes on SO, what's happening is that original thread exits
>> before spawned thread does open().
>>
>> ->lookup
>> proc_tgid_net_lookup
>> get_proc_task_net
>> nsproxy = NULL          <== thread is dead
>> ENOENT
>>
>> This was probably broken when /proc/net became symlink:
>>
>> commit e9720acd728a46cb40daa52c99a979f7c4ff195c
>> Author: Pavel Emelyanov <xemul@openvz.org>
>> Date:   Fri Mar 7 11:08:40 2008 -0800
>>
>>     [NET]: Make /proc/net a symlink on /proc/self/net (v3)
>>
>>
>> So, userspace has two solutions:
>> 1) original thread doesn't exit too early
>> 2) spawned thread uses /proc/$TID
>>
>>
>> So,
>> we definitely broke /proc/net/tcp somewhere after netns concept was introduced.
>>
>> But,
>> you'd have very same problem with other /proc files (anything under
>> /proc/$PID/).


Agreed it is a /proc/$TGID vs /proc/$TID issue.

In principle this is fixable by creating a /proc/current symlink that
always points to the proc directory for the current thread and then
pointing /proc/net and /proc/mounts at it.

This is one of those weird cases it so that /proc/net or /proc/mounts
resolves may actually break an existing userspace application, because
different threads can point at different values.  (I very much dislike
what the linux pthread support did to /proc/self).

I tilted at that windmill once and ran out of steam.  While I can write
the patch I don't have the energy to test and see if there are any
pthread programs that will break if /proc/net points to
/proc/current/net instead of /proc/self/net.

Frankly new applications should be using netlink and not /proc/net so I
personally don't think this is worth fixing for the /proc/net case.  Are
there real world applications that are broken by the kernel change in
behavior?  The stackoverflow discussion sounds like it was just an
investigation into weird kernel behavior.

Eric
