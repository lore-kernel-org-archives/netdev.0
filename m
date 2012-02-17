From: "Indan Zupancic" <indan@nul.nu>
Subject: Re: [PATCH v8 6/8] ptrace,seccomp: Add PTRACE_SECCOMP support
Date: Fri, 17 Feb 2012 23:55:13 +0100
Message-ID: <c4735bf45ba385828bead276931cc75c.squirrel@webmail.greenhost.nl>
References: <1329422549-16407-1-git-send-email-wad@chromium.org>
    <1329422549-16407-6-git-send-email-wad@chromium.org>
    <a3cc7e306f0ad79f3d49921d8586d18c.squirrel@webmail.greenhost.nl>
    <CABqD9hbAQ8dwwAf0Cpk4+dwgWjCYh1Fwg92=Vaq1XNqFQ3VVqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
To: "Will Drewry" <wad@chromium.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CABqD9hbAQ8dwwAf0Cpk4+dwgWjCYh1Fwg92=Vaq1XNqFQ3VVqw@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Fri, February 17, 2012 17:23, Will Drewry wrote:
> On Thu, Feb 16, 2012 at 11:08 PM, Indan Zupancic <indan@nul.nu> wrote=
:
>>> +/* Indicates if a tracer is attached. */
>>> +#define SECCOMP_FLAGS_TRACED 0
>>
>> That's not the best way to check if a tracer is attached, and if you=
 did use
>> it for that, you don't need to toggle it all the time.
>
> It's logically no different than task->ptrace.  If it is less
> desirable, that's fine, but it is functionally equivalent.

Except that when using task->ptrace the ptrace code keeps track of it a=
nd
clears it when the ptracer goes away. And you're toggling SECCOMP_FLAGS=
_TRACED
all the time.

>>> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
>>> index c75485c..f9d419f 100644
>>> --- a/kernel/seccomp.c
>>> +++ b/kernel/seccomp.c
>>> @@ -289,6 +289,8 @@ void copy_seccomp(struct seccomp *child,
>>> =C2=A0{
>>> =C2=A0 =C2=A0 =C2=A0 child->mode =3D prev->mode;
>>> =C2=A0 =C2=A0 =C2=A0 child->filter =3D get_seccomp_filter(prev->fil=
ter);
>>> + =C2=A0 =C2=A0 /* Note, this leaves seccomp tracing enabled across=
 fork. */
>>> + =C2=A0 =C2=A0 child->flags =3D prev->flags;
>>
>> What if the child isn't ptraced?
>
> Then falling through with TIF_SYSCALL_TRACE will result in the
> SECCOMP_RET_TRACE events to be allowed, but this comes back to the
> race.  If I can effectively "check" that ptrace did its job, then I
> think this becomes a non-issue.

Yes. But it would be still sloppy state tracking, which can lead to
all kind of unlikely but interesting scenario's. If the child is ever
attached to later on, that flag will be still set. Same is true for
any descendant, they all will have that flag copied.

>>> =C2=A0}
>>>
>>> =C2=A0/**
>>> @@ -363,6 +365,19 @@ int __secure_computing_int(int this_syscall)
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 syscall_rollback(current, task_pt_regs(current));
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 seccomp_send_sigtrap();
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 return -1;
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 case SECCOMP_RET_TRACE:
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 if (!seccomp_traced(&current->seccomp))
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -1;
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 /*
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0* Delegate to TIF_SYSCALL_TRACE. This allows fast-path
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0* seccomp calls to delegate to slow-path if needed.
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0* Since TIF_SYSCALL_TRACE will be unset on ptrace(2)
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0* continuation, there should be no direct side
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0* effects. =C2=A0If TIF_SYSCALL_TRACE is already set, this
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0* has no effect.
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0*/
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 set_tsk_thread_flag(current, TIF_SYSCALL_TRACE);
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 /* Falls through to allow. */
>>
>> This is nice and simple, but not race-free. You want to check if the=
 ptracer
>> handled the event or not. If the ptracer died before handling this t=
hen the
>> syscall should be denied and the task should be killed.
>
> Hrm. I think there's a way to do this without forcing seccomp to
> always go slow path.  I'll update the patch and see how it goes.

You only have to go through the slow path for the SECCOMP_RET_TRACE cas=
e.
But yeah, toggling TIF_SYSCALL_TRACE seems the only way to avoid the sl=
ow
path, sometimes. The downside is that it's unexpected behaviour which m=
ay
clash with arch entry code, so I'm not sure if that's a good idea. I th=
ink
always going through the slow path isn't too bad, compared to the ptrac=
e
alternative it's still a lot faster.

>> Many people would like a PTRACE_O_KILL_TRACEE_IF_DEBUGGER_DIES optio=
n,
>> Oleg was working on that, among other things. Perhaps re-use that to
>> handle this case too?
>
> Well, if you can inject initial code into the tracee, then it can cal=
l
> prctl(PR_SET_PDEATHSIG, SIGKILL).  Then when the tracer dies, the
> child dies.

That only works for child tracees, not descendants of the tracee.

> If the SIGKILL race in arch_ptrace_... is resolved, then
> a SIGKILL that arrives between seccomp and delegation to ptrace shoul=
d
> result in process death.  Though perhaps my proposal above will make
> seccomp's integration with ptrace less subject to ptrace behaviors.

Oleg fixed the SIGKILL problem (it wasn't a race), it should go upstrea=
m
in the next kernel version, I think.

>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 case SECCOMP_RET_A=
LLOW:
>>
>> For this and the ERRNO case you could check that PTRACE_O_SECCOMP op=
tion and
>> decide to do something or not in ptrace.
>
> For ERRNO, I'd prefer not to since it adds implicit behavior to the
> rules and, without pulling a ptrace_event()ish call into this code, i=
t
> would change the return flow and potentially open up errno, which
> should be solid, to races, etc.  For ALLOW, sure, but at that point,
> just use PTRACE_SYSCALL.  Perhaps this can all be ameliorated if I ca=
n
> get a useful ptrace_entry completed notification.

You don't want ptrace to be able to override the decision? Fair enough.
Or did you mean something else?

Greetings,

Indan


