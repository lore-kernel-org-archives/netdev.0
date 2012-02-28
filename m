From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v11 10/12] ptrace,seccomp: Add PTRACE_SECCOMP support
Date: Tue, 28 Feb 2012 11:04:01 -0600
Message-ID: <CABqD9hY7=DpxWzf3+WNsK=LuLrabf=oHxyy+CQgu0JLxZ80zPQ@mail.gmail.com>
References: <1330140111-17201-1-git-send-email-wad@chromium.org>
	<1330140111-17201-10-git-send-email-wad@chromium.org>
	<20120227175407.GD10608@redhat.com>
	<CABqD9hY1P7LfmBwQwSG7jDZmw6d_pZH4q2cZq_4ssjQUKRA32w@mail.gmail.com>
	<20120228164335.GC3664@redhat.com>
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
In-Reply-To: <20120228164335.GC3664@redhat.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 28, 2012 at 10:43 AM, Oleg Nesterov <oleg@redhat.com> wrote=
:
> On 02/27, Will Drewry wrote:
>> On Mon, Feb 27, 2012 at 11:54 AM, Oleg Nesterov <oleg@redhat.com> wr=
ote:
>> > On 02/24, Will Drewry wrote:
>> >>
>> >> =A0arch/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A01 +
>> >> =A0include/linux/ptrace.h =A0 =A0| =A0 =A07 +++++--
>> >> =A0include/linux/seccomp.h =A0 | =A0 =A04 +++-
>> >> =A0include/linux/tracehook.h | =A0 =A06 ++++++
>> >> =A0kernel/ptrace.c =A0 =A0 =A0 =A0 =A0 | =A0 =A04 ++++
>> >> =A0kernel/seccomp.c =A0 =A0 =A0 =A0 =A0| =A0 18 +++++++++++++++++=
+
>> >
>> > FYI, this conflicts with the changes -mm tree.
>> >
>> > The changes in ptrace.* confict with Denys's
>> > "ptrace: simplify PTRACE_foo constants and PTRACE_SETOPTIONS code"
>> >
>> > The change in tracehook.h conflicts with
>> > "ptrace: the killed tracee should not enter the syscall"
>>
>> What's the best way to reconcile this in this day and age?
>
> Of course I'd prefer if you make this change on top of Denys's patch =
;)
>
> Besides, if you agree with PTRACE_EVENT_SECCOMP/PTRACE_O_SECCOMP you
> need only one trivial change in ptrace.h.

I think that works quite well :)

>> I don't see
>> these in kernel-next yet and I can't tell if there is a public -mm
>> anywhere anymore.
>
> Strange... I didn't check, but every patch in
> http://marc.info/?l=3Dlinux-mm-commits has this note:
>
> =A0 =A0 =A0 =A0The -mm tree is included into linux-next and is update=
d
> =A0 =A0 =A0 =A0there every 3-4 working days

It appears to have been pulled in ~8 hours ago.  I'm rebasing to next n=
ow.

>> >> --- a/kernel/seccomp.c
>> >> +++ b/kernel/seccomp.c
>> >> @@ -354,6 +354,24 @@ int __secure_computing_int(int this_syscall)
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 seccomp_send_sigsys(t=
his_syscall, reason_code);
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 case SECCOMP_RET_TRACE: {
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int ret;
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct pt_regs *regs =3D=
 task_pt_regs(current);
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!(test_tsk_thread_f=
lag(current, TIF_SYSCALL_TRACE)) ||
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !(current->ptra=
ce & PT_TRACE_SECCOMP))
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return =
-1;
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* PT_TRACE_SECCOMP a=
nd seccomp.trace indicate whether
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* tracehook_report_s=
yscall_entry needs to signal the
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* tracer. =A0This av=
oids race conditions in hand off and
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* the requirement fo=
r TIF_SYSCALL_TRACE ensures that
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* we are in the sysc=
all slow path.
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 current->seccomp.trace =
=3D 1;
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D tracehook_repor=
t_syscall_entry(regs);
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 current->seccomp.trace =
=3D 0;
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
>> >
>> > To be honest, this interface looks a bit strange to me...
>> >
>> > Once again, sorry if this was already discussed. But perhaps it wo=
uld
>> > be better to introduce PTRACE_EVENT_SECCOMP/PTRACE_O_SECCOMP inste=
ad?
>> >
>> > SECCOMP_RET_TRACE: could simply do ptrace_event(PTRACE_EVENT_SECCO=
MP)
>> > unconditionaly. The tracer can set the option and do PTRACE_CONT i=
f it
>> > doesn't want the system call notifications.
>>
>> Works for me - this also gets rid of the extra int for brief state
>> tracking. I'll switch over to that in the next rev.
>
> Great. In this case this patch becomes really trivial. Just 2 defines
> in ptrace.h and the unconditional ptrace_event() under SECCOMP_RET_TR=
ACE.
>
> But probably you should check fatal_signal_pending(current) after
> ptrace_event() returns, ptrace_event() returns void.

Ah yeah - I don't want to reintroduce that issue :)

Thanks!
