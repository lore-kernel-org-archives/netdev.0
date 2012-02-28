From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v11 10/12] ptrace,seccomp: Add PTRACE_SECCOMP support
Date: Tue, 28 Feb 2012 12:34:43 -0600
Message-ID: <CABqD9hZ3apFGi+BmX5UNgz=NJUbTigj6acDKG=wu9rrL0wN1Ww@mail.gmail.com>
References: <1330140111-17201-1-git-send-email-wad@chromium.org>
	<1330140111-17201-10-git-send-email-wad@chromium.org>
	<20120227175407.GD10608@redhat.com>
	<CABqD9hY1P7LfmBwQwSG7jDZmw6d_pZH4q2cZq_4ssjQUKRA32w@mail.gmail.com>
	<20120228164335.GC3664@redhat.com>
	<CABqD9hY7=DpxWzf3+WNsK=LuLrabf=oHxyy+CQgu0JLxZ80zPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	peterz@infradead.org, rdunlap@xenotime.net, mcgrathr@chromium.org,
	tglx@linutronix.de, luto@mit.edu, eparis@redhat.com,
	serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
	indan@nul.nu, pmoore@redhat.com, akpm@linux-foundation.org,
	corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org,
	Denys Vlasenko <dvlasenk@redhat.com>
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CABqD9hY7=DpxWzf3+WNsK=LuLrabf=oHxyy+CQgu0JLxZ80zPQ@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 28, 2012 at 11:04 AM, Will Drewry <wad@chromium.org> wrote:
> On Tue, Feb 28, 2012 at 10:43 AM, Oleg Nesterov <oleg@redhat.com> wro=
te:
>> On 02/27, Will Drewry wrote:
>>> On Mon, Feb 27, 2012 at 11:54 AM, Oleg Nesterov <oleg@redhat.com> w=
rote:
>>> > On 02/24, Will Drewry wrote:
>>> >>
>>> >> =A0arch/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A01 +
>>> >> =A0include/linux/ptrace.h =A0 =A0| =A0 =A07 +++++--
>>> >> =A0include/linux/seccomp.h =A0 | =A0 =A04 +++-
>>> >> =A0include/linux/tracehook.h | =A0 =A06 ++++++
>>> >> =A0kernel/ptrace.c =A0 =A0 =A0 =A0 =A0 | =A0 =A04 ++++
>>> >> =A0kernel/seccomp.c =A0 =A0 =A0 =A0 =A0| =A0 18 ++++++++++++++++=
++
>>> >
>>> > FYI, this conflicts with the changes -mm tree.
>>> >
>>> > The changes in ptrace.* confict with Denys's
>>> > "ptrace: simplify PTRACE_foo constants and PTRACE_SETOPTIONS code=
"
>>> >
>>> > The change in tracehook.h conflicts with
>>> > "ptrace: the killed tracee should not enter the syscall"
>>>
>>> What's the best way to reconcile this in this day and age?
>>
>> Of course I'd prefer if you make this change on top of Denys's patch=
 ;)
>>
>> Besides, if you agree with PTRACE_EVENT_SECCOMP/PTRACE_O_SECCOMP you
>> need only one trivial change in ptrace.h.
>
> I think that works quite well :)
>
>>> I don't see
>>> these in kernel-next yet and I can't tell if there is a public -mm
>>> anywhere anymore.
>>
>> Strange... I didn't check, but every patch in
>> http://marc.info/?l=3Dlinux-mm-commits has this note:
>>
>> =A0 =A0 =A0 =A0The -mm tree is included into linux-next and is updat=
ed
>> =A0 =A0 =A0 =A0there every 3-4 working days
>
> It appears to have been pulled in ~8 hours ago. =A0I'm rebasing to ne=
xt now.
>
>>> >> --- a/kernel/seccomp.c
>>> >> +++ b/kernel/seccomp.c
>>> >> @@ -354,6 +354,24 @@ int __secure_computing_int(int this_syscall=
)
>>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 seccomp_send_sigsys(=
this_syscall, reason_code);
>>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
>>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>> >> + =A0 =A0 =A0 =A0 =A0 =A0 case SECCOMP_RET_TRACE: {
>>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int ret;
>>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct pt_regs *regs =3D=
 task_pt_regs(current);
>>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!(test_tsk_thread_=
flag(current, TIF_SYSCALL_TRACE)) ||
>>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !(current->ptr=
ace & PT_TRACE_SECCOMP))
>>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return=
 -1;
>>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* PT_TRACE_SECCOMP =
and seccomp.trace indicate whether
>>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* tracehook_report_=
syscall_entry needs to signal the
>>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* tracer. =A0This a=
voids race conditions in hand off and
>>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* the requirement f=
or TIF_SYSCALL_TRACE ensures that
>>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* we are in the sys=
call slow path.
>>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 current->seccomp.trace=
 =3D 1;
>>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D tracehook_repo=
rt_syscall_entry(regs);
>>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 current->seccomp.trace=
 =3D 0;
>>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
>>> >
>>> > To be honest, this interface looks a bit strange to me...
>>> >
>>> > Once again, sorry if this was already discussed. But perhaps it w=
ould
>>> > be better to introduce PTRACE_EVENT_SECCOMP/PTRACE_O_SECCOMP inst=
ead?
>>> >
>>> > SECCOMP_RET_TRACE: could simply do ptrace_event(PTRACE_EVENT_SECC=
OMP)
>>> > unconditionaly. The tracer can set the option and do PTRACE_CONT =
if it
>>> > doesn't want the system call notifications.
>>>
>>> Works for me - this also gets rid of the extra int for brief state
>>> tracking. I'll switch over to that in the next rev.
>>
>> Great. In this case this patch becomes really trivial. Just 2 define=
s
>> in ptrace.h and the unconditional ptrace_event() under SECCOMP_RET_T=
RACE.

hrm the only snag is that I can't then rely on TIF_SYSCALL_TRACE to
ensure seccomp is in the slow-path.  Right now, on x86, seccomp is
slow-path, but it doesn't have to be to have the syscall and args.
However, for ptrace to behavior properly, I believed it did need to be
in the slow path.  If SECCOMP_RET_TRACE doesn't rely on
PTRACE_SYSCALL, then it introduces a need for seccomp to always be in
the slow path or to flag (somehow) when it needs slow path.

Any suggestions there?

Thanks!
will
