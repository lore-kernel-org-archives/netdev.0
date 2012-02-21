From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v8 6/8] ptrace,seccomp: Add PTRACE_SECCOMP support
Date: Tue, 21 Feb 2012 11:31:02 -0600
Message-ID: <CABqD9hYaz1QtZ3+3B0ob+d4Dhrc67=mqh9-PHpNtjC_kgbXC1A@mail.gmail.com>
References: <1329422549-16407-1-git-send-email-wad@chromium.org>
	<1329422549-16407-6-git-send-email-wad@chromium.org>
	<a3cc7e306f0ad79f3d49921d8586d18c.squirrel@webmail.greenhost.nl>
	<CABqD9hbAQ8dwwAf0Cpk4+dwgWjCYh1Fwg92=Vaq1XNqFQ3VVqw@mail.gmail.com>
	<c4735bf45ba385828bead276931cc75c.squirrel@webmail.greenhost.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.org,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
	markus@chromium.org, keescook@chromium.org
To: Indan Zupancic <indan@nul.nu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c4735bf45ba385828bead276931cc75c.squirrel@webmail.greenhost.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 17, 2012 at 4:55 PM, Indan Zupancic <indan@nul.nu> wrote:
> Hello,
>
> On Fri, February 17, 2012 17:23, Will Drewry wrote:
>> On Thu, Feb 16, 2012 at 11:08 PM, Indan Zupancic <indan@nul.nu> wrot=
e:
>>>> +/* Indicates if a tracer is attached. */
>>>> +#define SECCOMP_FLAGS_TRACED 0
>>>
>>> That's not the best way to check if a tracer is attached, and if yo=
u did use
>>> it for that, you don't need to toggle it all the time.
>>
>> It's logically no different than task->ptrace. =A0If it is less
>> desirable, that's fine, but it is functionally equivalent.
>
> Except that when using task->ptrace the ptrace code keeps track of it=
 and
> clears it when the ptracer goes away. And you're toggling SECCOMP_FLA=
GS_TRACED
> all the time.

Yep, the code is gone in the coming version. It was ugly to need to
change it everywhere TIF_SYSCALL_TRACE was toggled.

>>>> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
>>>> index c75485c..f9d419f 100644
>>>> --- a/kernel/seccomp.c
>>>> +++ b/kernel/seccomp.c
>>>> @@ -289,6 +289,8 @@ void copy_seccomp(struct seccomp *child,
>>>> =A0{
>>>> =A0 =A0 =A0 child->mode =3D prev->mode;
>>>> =A0 =A0 =A0 child->filter =3D get_seccomp_filter(prev->filter);
>>>> + =A0 =A0 /* Note, this leaves seccomp tracing enabled across fork=
=2E */
>>>> + =A0 =A0 child->flags =3D prev->flags;
>>>
>>> What if the child isn't ptraced?
>>
>> Then falling through with TIF_SYSCALL_TRACE will result in the
>> SECCOMP_RET_TRACE events to be allowed, but this comes back to the
>> race. =A0If I can effectively "check" that ptrace did its job, then =
I
>> think this becomes a non-issue.
>
> Yes. But it would be still sloppy state tracking, which can lead to
> all kind of unlikely but interesting scenario's. If the child is ever
> attached to later on, that flag will be still set. Same is true for
> any descendant, they all will have that flag copied.

Yup - it'd lead to tracehook fall through and an implicit allow.  Not
ideal at all.

>>>> =A0}
>>>>
>>>> =A0/**
>>>> @@ -363,6 +365,19 @@ int __secure_computing_int(int this_syscall)
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 syscall_rollback(curre=
nt, task_pt_regs(current));
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 seccomp_send_sigtrap()=
;
>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 case SECCOMP_RET_TRACE:
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!seccomp_traced(&cur=
rent->seccomp))
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -=
1;
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Delegate to TIF_SYS=
CALL_TRACE. This allows fast-path
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* seccomp calls to de=
legate to slow-path if needed.
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Since TIF_SYSCALL_T=
RACE will be unset on ptrace(2)
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* continuation, there=
 should be no direct side
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* effects. =A0If TIF_=
SYSCALL_TRACE is already set, this
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* has no effect.
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_tsk_thread_flag(curr=
ent, TIF_SYSCALL_TRACE);
>>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Falls through to allo=
w. */
>>>
>>> This is nice and simple, but not race-free. You want to check if th=
e ptracer
>>> handled the event or not. If the ptracer died before handling this =
then the
>>> syscall should be denied and the task should be killed.
>>
>> Hrm. I think there's a way to do this without forcing seccomp to
>> always go slow path. =A0I'll update the patch and see how it goes.
>
> You only have to go through the slow path for the SECCOMP_RET_TRACE c=
ase.

You'd have to know at syscall entry time to decide or pre-scan the bpf
filter to see if SECCOMP_RET_TRACE is returned non-programmatically,
then add a TIF flag for slow pathing, but that seems crazy bad.

> But yeah, toggling TIF_SYSCALL_TRACE seems the only way to avoid the =
slow
> path, sometimes. The downside is that it's unexpected behaviour which=
 may
> clash with arch entry code, so I'm not sure if that's a good idea. I =
think
> always going through the slow path isn't too bad, compared to the ptr=
ace
> alternative it's still a lot faster.

Since supporting that behavior is documented as a prerequisite for
adding HAVE_ARCH_SECCOMP_FILTER, I don't see how it could be
unexpected behavior.  On systems, like x86, where seccomp is always
slowpath, it has no impact.  However, it means that if a fast path is
added (like audit), then it will need to know to re-check the
threadinfo flags.  I don't want to try to optimize in advance, but
it'd be nice to not close off any options for later.  If an explicit
ptrace_event(SECCOMP) call was being made, then we'd be stuck in the
slow path or stuck making the ptrace code have more ifs for
determining if the source was a normal ptrace event or special
seccomp-triggered one.  That might be okay as a long-term-thing,
though, since the other option (which the incoming patchset does) is
to add a post-trace callback into seccomp.  I'm not sure which is
truly preferable.

>>> Many people would like a PTRACE_O_KILL_TRACEE_IF_DEBUGGER_DIES opti=
on,
>>> Oleg was working on that, among other things. Perhaps re-use that t=
o
>>> handle this case too?
>>
>> Well, if you can inject initial code into the tracee, then it can ca=
ll
>> prctl(PR_SET_PDEATHSIG, SIGKILL). =A0Then when the tracer dies, the
>> child dies.
>
> That only works for child tracees, not descendants of the tracee.

True enough.

>> If the SIGKILL race in arch_ptrace_... is resolved, then
>> a SIGKILL that arrives between seccomp and delegation to ptrace shou=
ld
>> result in process death. =A0Though perhaps my proposal above will ma=
ke
>> seccomp's integration with ptrace less subject to ptrace behaviors.
>
> Oleg fixed the SIGKILL problem (it wasn't a race), it should go upstr=
eam
> in the next kernel version, I think.

Pick your own name for it then, I guess.  The signal lock was held in
ptrace_notify.  Then, in order to hand off to the arch_ptrace_notify
code, it releases the lock, then claims it again after.  If SIGKILL
was delivered in that time window, then the post-arch-handoff code
would see it, skip notification of the tracer, and allow the syscall
to run prior to terminating the task.  I'm excited to see it fixed :)

>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 case SECCOMP_RET_ALLOW:
>>>
>>> For this and the ERRNO case you could check that PTRACE_O_SECCOMP o=
ption and
>>> decide to do something or not in ptrace.
>>
>> For ERRNO, I'd prefer not to since it adds implicit behavior to the
>> rules and, without pulling a ptrace_event()ish call into this code, =
it
>> would change the return flow and potentially open up errno, which
>> should be solid, to races, etc. =A0For ALLOW, sure, but at that poin=
t,
>> just use PTRACE_SYSCALL. =A0Perhaps this can all be ameliorated if I=
 can
>> get a useful ptrace_entry completed notification.
>
> You don't want ptrace to be able to override the decision? Fair enoug=
h.
> Or did you mean something else?

Exactly. The first time I went down this path, I let a tracer pick up
any denied syscalls, but that complicated the interactions and
security model quite a bit.  I also don't want to add an implicit
dependency on the syscall slow-path for any other return values --
just in case the proposed TIF_SYSCALL_TRACE approach isn't acceptable.

thanks!
will
