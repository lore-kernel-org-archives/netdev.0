From: Will Drewry <wad@chromium.org>
Subject: Re: [kernel-hardening] Re: [PATCH v14 10/13] ptrace,seccomp: Add
 PTRACE_SECCOMP support
Date: Wed, 14 Mar 2012 10:03:36 -0500
Message-ID: <CABqD9haMip5sKW92mDNXwsqL-U8NmUcuG9DN5202-V4xj0qz1g@mail.gmail.com>
References: <1331587715-26069-1-git-send-email-wad@chromium.org>
	<1331587715-26069-10-git-send-email-wad@chromium.org>
	<34b2e80343549454d6c026237f248c86.squirrel@webmail.greenhost.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, netdev@vger.kernel.org, x86@kernel.org,
	arnd@arndb.de, davem@davemloft.net, hpa@zytor.com,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
	luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
	markus@chromium.org, coreyb@linux.vnet.ibm.com,
	keescook@chromium.org
To: kernel-hardening@lists.openwall.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:61692 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752261Ab2CNPDi convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Mar 2012 11:03:38 -0400
Received: by lahj13 with SMTP id j13so1518215lah.19
        for <netdev@vger.kernel.org>; Wed, 14 Mar 2012 08:03:37 -0700 (PDT)
In-Reply-To: <34b2e80343549454d6c026237f248c86.squirrel@webmail.greenhost.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 14, 2012 at 2:31 AM, Indan Zupancic <indan@nul.nu> wrote:
> Hello,
>
> On Mon, March 12, 2012 22:28, Will Drewry wrote:
>> This change adds support for a new ptrace option, PTRACE_O_TRACESECC=
OMP,
>> and a new return value for seccomp BPF programs, SECCOMP_RET_TRACE.
>>
>> When a tracer specifies the PTRACE_O_TRACESECCOMP ptrace option, the
>> tracer will be notified for any syscall that results in a BPF progra=
m
>> returning SECCOMP_RET_TRACE. =A0The 16-bit SECCOMP_RET_DATA mask of =
the
>> BPF program return value will be passed as the ptrace_message and ma=
y be
>> retrieved using PTRACE_GETEVENTMSG.
>
> Maybe good to tell it gets notified with PTRACE_EVENT_SECCOMP.

Good call - I'll update it.

>>
>> If the subordinate process is not using seccomp filter, then no
>> system call notifications will occur even if the option is specified=
=2E
>>
>> If there is no attached tracer when SECCOMP_RET_TRACE is returned,
>> the system call will not be executed and an -ENOSYS errno will be
>> returned to userspace.
>
> When no tracer with PTRACE_O_TRACESECCOMP set is attached?
> (Because that's what the code is doing.)

That too :)

>>
>> This change adds a dependency on the system call slow path. =A0Any f=
uture
>> efforts to use the system call fast path for seccomp filter will nee=
d to
>> address this restriction.
>>
>> v14: - rebase/nochanges
>> v13: - rebase on to 88ebdda6159ffc15699f204c33feb3e431bf9bdc
>> =A0 =A0 =A0 (Brings back a change to ptrace.c and the masks.)
>> v12: - rebase to linux-next
>> =A0 =A0 - use ptrace_event and update arch/Kconfig to mention slow-p=
ath dependency
>> =A0 =A0 - drop all tracehook changes and inclusion (oleg@redhat.com)
>> v11: - invert the logic to just make it a PTRACE_SYSCALL accelerator
>> =A0 =A0 =A0 (indan@nul.nu)
>> v10: - moved to PTRACE_O_SECCOMP / PT_TRACE_SECCOMP
>> v9: =A0- n/a
>> v8: =A0- guarded PTRACE_SECCOMP use with an ifdef
>> v7: =A0- introduced
>>
>> Signed-off-by: Will Drewry <wad@chromium.org>
>> ---
>> arch/Kconfig =A0 =A0 =A0 =A0 =A0 =A0| =A0 11 ++++++-----
>> include/linux/ptrace.h =A0| =A0 =A07 +++++--
>> include/linux/seccomp.h | =A0 =A01 +
>> kernel/ptrace.c =A0 =A0 =A0 =A0 | =A0 =A03 +++
>> kernel/seccomp.c =A0 =A0 =A0 =A0| =A0 20 +++++++++++++++-----
>> 5 files changed, 30 insertions(+), 12 deletions(-)
>>
>> diff --git a/arch/Kconfig b/arch/Kconfig
>> index d92a78e..3f8132c 100644
>> --- a/arch/Kconfig
>> +++ b/arch/Kconfig
>> @@ -202,15 +202,16 @@ config HAVE_CMPXCHG_DOUBLE
>> config HAVE_ARCH_SECCOMP_FILTER
>> =A0 =A0 =A0 bool
>> =A0 =A0 =A0 help
>> - =A0 =A0 =A0 This symbol should be selected by an architecure if it=
 provides:
>> - =A0 =A0 =A0 asm/syscall.h:
>> + =A0 =A0 =A0 An arch should select this symbol if it provides all o=
f these things:
>> =A0 =A0 =A0 =A0 - syscall_get_arch()
>> =A0 =A0 =A0 =A0 - syscall_get_arguments()
>> =A0 =A0 =A0 =A0 - syscall_rollback()
>> =A0 =A0 =A0 =A0 - syscall_set_return_value()
>> - =A0 =A0 =A0 SIGSYS siginfo_t support must be implemented.
>> - =A0 =A0 =A0 __secure_computing_int()/secure_computing()'s return v=
alue must be
>> - =A0 =A0 =A0 checked, with -1 resulting in the syscall being skippe=
d.
>> + =A0 =A0 =A0 - SIGSYS siginfo_t support
>> + =A0 =A0 =A0 - uses __secure_computing_int() or secure_computing()
>> + =A0 =A0 =A0 - secure_computing is called from a ptrace_event()-saf=
e context
>> + =A0 =A0 =A0 - secure_computing return value is checked and a retur=
n value of -1
>> + =A0 =A0 =A0 =A0 results in the system call being skipped immediate=
ly.
>>
>> config SECCOMP_FILTER
>> =A0 =A0 =A0 def_bool y
>> diff --git a/include/linux/ptrace.h b/include/linux/ptrace.h
>> index c2f1f6a..84b3418 100644
>> --- a/include/linux/ptrace.h
>> +++ b/include/linux/ptrace.h
>> @@ -62,8 +62,9 @@
>> #define PTRACE_O_TRACEEXEC =A0 =A00x00000010
>> #define PTRACE_O_TRACEVFORKDONE =A0 =A0 =A0 0x00000020
>> #define PTRACE_O_TRACEEXIT =A0 =A00x00000040
>> +#define PTRACE_O_TRACESECCOMP =A0 =A0 =A0 =A00x00000080
>>
>> -#define PTRACE_O_MASK =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x0000007f
>> +#define PTRACE_O_MASK =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00x000000ff
>>
>> /* Wait extended result codes for the above trace options. =A0*/
>> #define PTRACE_EVENT_FORK =A0 =A0 1
>> @@ -73,6 +74,7 @@
>> #define PTRACE_EVENT_VFORK_DONE =A0 =A0 =A0 5
>> #define PTRACE_EVENT_EXIT =A0 =A0 6
>> #define PTRACE_EVENT_STOP =A0 =A0 7
>> +#define PTRACE_EVENT_SECCOMP 8
>
> I think PTRACE_EVENT_STOP is supposed to be hidden, it's never direct=
ly
> seen by user space. Instead of doing the obvious thing, they went the
> crazy PTRACE_INTERRUPT + PTRACE_LISTEN way.
>
> So it's better to add PTRACE_EVENT_SECCOMP as 8 and bump STOP one up.
> But if PTRACE_EVENT_STOP is really hidden then it shouldn't show up i=
n
> the user space header at all, it should be after the ifdef KERNEL.

yeah that's in the -next branch so it will be fixed on merge resolve.

>>
>> #include <asm/ptrace.h>
>>
>> @@ -101,8 +103,9 @@
>> #define PT_TRACE_EXEC =A0 =A0 =A0 =A0 PT_EVENT_FLAG(PTRACE_EVENT_EXE=
C)
>> #define PT_TRACE_VFORK_DONE =A0 PT_EVENT_FLAG(PTRACE_EVENT_VFORK_DON=
E)
>> #define PT_TRACE_EXIT =A0 =A0 =A0 =A0 PT_EVENT_FLAG(PTRACE_EVENT_EXI=
T)
>> +#define PT_TRACE_SECCOMP =A0 =A0 PT_EVENT_FLAG(PTRACE_EVENT_SECCOMP=
)
>>
>> -#define PT_TRACE_MASK =A0 =A0 =A0 =A00x000003f4
>> +#define PT_TRACE_MASK =A0 =A0 =A0 =A00x00000ff4
>
> This is wrong. Shouldn't it be 0xbf4? (0x7f4 if you bump STOP up.)

If I bump stop up, but in the resolved version the masks simplify.

>
>>
>> /* single stepping state bits (used on ARM and PA-RISC) */
>> #define PT_SINGLESTEP_BIT =A0 =A0 31
>> diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
>> index e6d4b56..f4c1774 100644
>> --- a/include/linux/seccomp.h
>> +++ b/include/linux/seccomp.h
>> @@ -21,6 +21,7 @@
>> #define SECCOMP_RET_KILL =A0 =A0 =A00x00000000U /* kill the task imm=
ediately */
>> #define SECCOMP_RET_TRAP =A0 =A0 =A00x00020000U /* disallow and forc=
e a SIGSYS */
>> #define SECCOMP_RET_ERRNO =A0 =A0 0x00030000U /* returns an errno */
>> +#define SECCOMP_RET_TRACE =A0 =A00x7ffe0000U /* pass to a tracer or=
 disallow */
>> #define SECCOMP_RET_ALLOW =A0 =A0 0x7fff0000U /* allow */
>
> Maybe a good idea to leave more gaps between all the return codes, in
> case new return codes are added in the future that fall between exist=
ing
> ones? E.g:
>
> #define SECCOMP_RET_KILL =A0 =A0 =A0 =A00x00000000U /* kill the task =
immediately */
> #define SECCOMP_RET_TRAP =A0 =A0 =A0 =A00x00100000U /* disallow and f=
orce a SIGSYS */
> #define SECCOMP_RET_ERRNO =A0 =A0 =A0 0x00200000U /* returns an errno=
 */
> #define SECCOMP_RET_TRACE =A0 =A0 =A0 0x00300000U /* pass to a tracer=
 or disallow */
> #define SECCOMP_RET_ALLOW =A0 =A0 =A0 0x00400000U /* allow */

The gaps are intentional.  Priority is from least permissive (0) to
most permissive (0x7fff).  So the gaps are
there for things between errno and trace. I could add more gaps on
those sides, but I don't think there is much need to given the scope
of what is possible in the middle.  I certainly wouldn't push ALLOW
down to the bottom.

>>
>> /* Masks for the return value sections. */
>> diff --git a/kernel/ptrace.c b/kernel/ptrace.c
>> index 00ab2ca..8cf6da1 100644
>> --- a/kernel/ptrace.c
>> +++ b/kernel/ptrace.c
>> @@ -551,6 +551,9 @@ static int ptrace_setoptions(struct task_struct =
*child, unsigned
> long data)
>> =A0 =A0 =A0 if (data & PTRACE_O_TRACEEXIT)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 child->ptrace |=3D PT_TRACE_EXIT;
>>
>> + =A0 =A0 if (data & PTRACE_O_TRACESECCOMP)
>> + =A0 =A0 =A0 =A0 =A0 =A0 child->ptrace |=3D PT_TRACE_SECCOMP;
>> +
>> =A0 =A0 =A0 return (data & ~PTRACE_O_MASK) ? -EINVAL : 0;
>> }
>>
>> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
>> index 140490a..ddacc68 100644
>> --- a/kernel/seccomp.c
>> +++ b/kernel/seccomp.c
>> @@ -17,13 +17,13 @@
>> #include <linux/audit.h>
>> #include <linux/compat.h>
>> #include <linux/filter.h>
>> +#include <linux/ptrace.h>
>> #include <linux/sched.h>
>> #include <linux/seccomp.h>
>> #include <linux/security.h>
>> #include <linux/slab.h>
>> #include <linux/uaccess.h>
>>
>> -#include <linux/tracehook.h>
>> #include <asm/syscall.h>
>>
>> /* #define SECCOMP_DEBUG 1 */
>> @@ -389,14 +389,24 @@ int __secure_computing_int(int this_syscall)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0-(action & SECCOMP_RET_DATA),
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A00);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
>> - =A0 =A0 =A0 =A0 =A0 =A0 case SECCOMP_RET_TRAP: {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 int reason_code =3D action=
 & SECCOMP_RET_DATA;
>> + =A0 =A0 =A0 =A0 =A0 =A0 case SECCOMP_RET_TRAP:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Show the handler the =
original registers. */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 syscall_rollback(current=
, task_pt_regs(current));
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Let the filter pass b=
ack 16 bits of data. */
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 seccomp_send_sigsys(this_s=
yscall, reason_code);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 seccomp_send_sigsys(this_s=
yscall,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 action & SECCOMP_RET_DATA);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
>> - =A0 =A0 =A0 =A0 =A0 =A0 }
>
> These are unrelated changes and probably shouldn't be here. It just m=
akes
> it harder to review the code if you change it in a later patch for no
> apparent reason.
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 case SECCOMP_RET_TRACE:
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Skip these calls if the=
re is no tracer. */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!ptrace_event_enabled(=
current,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 PTRACE_EVENT_SECCOMP))
>
> One line please, it's 81 chars.

Ok :)

>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Allow the BPF to provid=
e the event message */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptrace_event(PTRACE_EVENT_=
SECCOMP,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
action & SECCOMP_RET_DATA);
>
> Why not move "int reason_code =3D action & SECCOMP_RET_DATA;" to the =
start
> of the function out of the if checks, instead of duplicating the code=
?

Yeah I am cleaning this all up in the next rev. This was just ugly.

>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (fatal_signal_pending(c=
urrent))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 case SECCOMP_RET_ALLOW:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 case SECCOMP_RET_KILL:
>

Thanks!
will
