From: Nir Tzachar <nir.tzachar@gmail.com>
Subject: Re: [PATCH 1/1] net: Introduce recvmmsg socket syscall
Date: Mon, 12 Oct 2009 19:53:43 +0200
Message-ID: <9b2db90b0910121053h3c422beet487cc9a9b9be2894@mail.gmail.com>
References: <1255364440-23271-1-git-send-email-acme@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	Caitlin Bestler <caitlin.bestler@gmail.com>,
	Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Nivedita Singhvi <niv@us.ibm.com>,
	Paul Moore <paul.moore@hp.com>,
	=?ISO-8859-1?Q?R=E9mi_Denis=2DCourmont?=
	<remi.denis-courmont@nokia.com>,
	Steven Whitehouse <steve@chygwyn.com>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f210.google.com ([209.85.218.210]:53838 "EHLO
	mail-bw0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932672AbZJLRyW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 13:54:22 -0400
Received: by bwz6 with SMTP id 6so3301063bwz.37
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2009 10:53:44 -0700 (PDT)
In-Reply-To: <1255364440-23271-1-git-send-email-acme@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arnaldo.

Do you have any plans on how we can further investigate the delays I
have seen with the second part of the patch? I have tried to simply
unlock/lock the socket's mutex every couple of iterations inside the
loop (to allow the system to process some backlog), but this seems to
have little to no effect.

Also, a way to enable/disable the no_lock version at runtime will
greatly help in testing. Maybe by first introducing a second syscall,
recvmmsg_no_lock, for testing purposes??

Cheers,
Nir.

On Mon, Oct 12, 2009 at 6:20 PM, Arnaldo Carvalho de Melo
<acme@ghostprotocols.net> wrote:
> Meaning receive multiple messages, reducing the number of syscalls an=
d
> net stack entry/exit operations.
>
> Next patches will introduce mechanisms where protocols that want to
> optimize this operation will provide an unlocked_recvmsg operation.
>
> This takes into account comments made by:
>
> . Paul Moore: sock_recvmsg is called only for the first datagram,
> =A0sock_recvmsg_nosec is used for the rest.
>
> . Caitlin Bestler: recvmmsg now has a struct timespec timeout, that
> =A0works in the same fashion as the ppoll one.
>
> =A0If the underlying protocol returns a datagram with MSG_OOB set, th=
is
> =A0will make recvmmsg return right away with as many datagrams (+ the=
 OOB
> =A0one) it has received so far.
>
> . R=E9mi Denis-Courmont & Steven Whitehouse: If we receive N < vlen
> =A0datagrams and then recvmsg returns an error, recvmmsg will return
> =A0the successfully received datagrams, store the error and return it
> =A0in the next call.
>
> This paves the way for a subsequent optimization, sk_prot->unlocked_r=
ecvmsg,
> where we will be able to acquire the lock only at batch start and end=
, not at
> every underlying recvmsg call.
>
> Cc: Caitlin Bestler <caitlin.bestler@gmail.com>
> Cc: Chris Van Hoof <vanhoof@redhat.com>
> Cc: Clark Williams <williams@redhat.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Cc: Nir Tzachar <nir.tzachar@gmail.com>
> Cc: Nivedita Singhvi <niv@us.ibm.com>
> Cc: Paul Moore <paul.moore@hp.com>
> Cc: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
> Cc: Steven Whitehouse <steve@chygwyn.com>
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
> ---
> =A0arch/alpha/kernel/systbls.S =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A01 +
> =A0arch/arm/kernel/calls.S =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A01 =
+
> =A0arch/avr32/kernel/syscall_table.S =A0 =A0 =A0| =A0 =A01 +
> =A0arch/blackfin/mach-common/entry.S =A0 =A0 =A0| =A0 =A01 +
> =A0arch/ia64/kernel/entry.S =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A01 +
> =A0arch/microblaze/kernel/syscall_table.S | =A0 =A01 +
> =A0arch/mips/kernel/scall32-o32.S =A0 =A0 =A0 =A0 | =A0 =A01 +
> =A0arch/mips/kernel/scall64-64.S =A0 =A0 =A0 =A0 =A0| =A0 =A01 +
> =A0arch/mips/kernel/scall64-n32.S =A0 =A0 =A0 =A0 | =A0 =A01 +
> =A0arch/mips/kernel/scall64-o32.S =A0 =A0 =A0 =A0 | =A0 =A01 +
> =A0arch/sh/kernel/syscalls_64.S =A0 =A0 =A0 =A0 =A0 | =A0 =A01 +
> =A0arch/sparc/kernel/systbls_64.S =A0 =A0 =A0 =A0 | =A0 =A04 +-
> =A0arch/x86/ia32/ia32entry.S =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A01 +
> =A0arch/x86/include/asm/unistd_32.h =A0 =A0 =A0 | =A0 =A03 +-
> =A0arch/x86/include/asm/unistd_64.h =A0 =A0 =A0 | =A0 =A02 +
> =A0arch/x86/kernel/syscall_table_32.S =A0 =A0 | =A0 =A01 +
> =A0arch/xtensa/include/asm/unistd.h =A0 =A0 =A0 | =A0 =A04 +-
> =A0include/linux/net.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A0=
1 +
> =A0include/linux/socket.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 10 ++
> =A0include/linux/syscalls.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A04 +
> =A0include/net/compat.h =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A0=
8 +
> =A0kernel/sys_ni.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0=
 =A02 +
> =A0net/compat.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 |=
 =A0 33 +++++-
> =A0net/socket.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 |=
 =A0225 ++++++++++++++++++++++++++------
> =A024 files changed, 260 insertions(+), 49 deletions(-)
>
> diff --git a/arch/alpha/kernel/systbls.S b/arch/alpha/kernel/systbls.=
S
> index 95c9aef..cda6b8b 100644
> --- a/arch/alpha/kernel/systbls.S
> +++ b/arch/alpha/kernel/systbls.S
> @@ -497,6 +497,7 @@ sys_call_table:
> =A0 =A0 =A0 =A0.quad sys_signalfd
> =A0 =A0 =A0 =A0.quad sys_ni_syscall
> =A0 =A0 =A0 =A0.quad sys_eventfd
> + =A0 =A0 =A0 .quad sys_recvmmsg
>
> =A0 =A0 =A0 =A0.size sys_call_table, . - sys_call_table
> =A0 =A0 =A0 =A0.type sys_call_table, @object
> diff --git a/arch/arm/kernel/calls.S b/arch/arm/kernel/calls.S
> index fafce1b..f58c115 100644
> --- a/arch/arm/kernel/calls.S
> +++ b/arch/arm/kernel/calls.S
> @@ -374,6 +374,7 @@
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0CALL(sys_pwritev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0CALL(sys_rt_tgsigqueueinfo)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0CALL(sys_perf_event_open)
> +/* 365 */ =A0 =A0 =A0CALL(sys_recvmmsg)
> =A0#ifndef syscalls_counted
> =A0.equ syscalls_padding, ((NR_syscalls + 3) & ~3) - NR_syscalls
> =A0#define syscalls_counted
> diff --git a/arch/avr32/kernel/syscall_table.S b/arch/avr32/kernel/sy=
scall_table.S
> index 7ee0057..e76bad1 100644
> --- a/arch/avr32/kernel/syscall_table.S
> +++ b/arch/avr32/kernel/syscall_table.S
> @@ -295,4 +295,5 @@ sys_call_table:
> =A0 =A0 =A0 =A0.long =A0 sys_signalfd
> =A0 =A0 =A0 =A0.long =A0 sys_ni_syscall =A0 =A0 =A0 =A0 =A0/* 280, wa=
s sys_timerfd */
> =A0 =A0 =A0 =A0.long =A0 sys_eventfd
> + =A0 =A0 =A0 .long =A0 sys_recvmmsg
> =A0 =A0 =A0 =A0.long =A0 sys_ni_syscall =A0 =A0 =A0 =A0 =A0/* r8 is s=
aturated at nr_syscalls */
> diff --git a/arch/blackfin/mach-common/entry.S b/arch/blackfin/mach-c=
ommon/entry.S
> index 1e7cac2..4869272 100644
> --- a/arch/blackfin/mach-common/entry.S
> +++ b/arch/blackfin/mach-common/entry.S
> @@ -1621,6 +1621,7 @@ ENTRY(_sys_call_table)
> =A0 =A0 =A0 =A0.long _sys_pwritev
> =A0 =A0 =A0 =A0.long _sys_rt_tgsigqueueinfo
> =A0 =A0 =A0 =A0.long _sys_perf_event_open
> + =A0 =A0 =A0 .long _sys_recvmmsg =A0 =A0 =A0 =A0 =A0 =A0 /* 370 */
>
> =A0 =A0 =A0 =A0.rept NR_syscalls-(.-_sys_call_table)/4
> =A0 =A0 =A0 =A0.long _sys_ni_syscall
> diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
> index d0e7d37..d75b872 100644
> --- a/arch/ia64/kernel/entry.S
> +++ b/arch/ia64/kernel/entry.S
> @@ -1806,6 +1806,7 @@ sys_call_table:
> =A0 =A0 =A0 =A0data8 sys_preadv
> =A0 =A0 =A0 =A0data8 sys_pwritev =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 // 1320
> =A0 =A0 =A0 =A0data8 sys_rt_tgsigqueueinfo
> + =A0 =A0 =A0 data8 sys_recvmmsg
>
> =A0 =A0 =A0 =A0.org sys_call_table + 8*NR_syscalls =A0 =A0 // guard a=
gainst failures to increase NR_syscalls
> =A0#endif /* __IA64_ASM_PARAVIRTUALIZED_NATIVE */
> diff --git a/arch/microblaze/kernel/syscall_table.S b/arch/microblaze=
/kernel/syscall_table.S
> index ecec191..c1ab1dc 100644
> --- a/arch/microblaze/kernel/syscall_table.S
> +++ b/arch/microblaze/kernel/syscall_table.S
> @@ -371,3 +371,4 @@ ENTRY(sys_call_table)
> =A0 =A0 =A0 =A0.long sys_ni_syscall
> =A0 =A0 =A0 =A0.long sys_rt_tgsigqueueinfo =A0 =A0 /* 365 */
> =A0 =A0 =A0 =A0.long sys_perf_event_open
> + =A0 =A0 =A0 .long sys_recvmmsg
> diff --git a/arch/mips/kernel/scall32-o32.S b/arch/mips/kernel/scall3=
2-o32.S
> index fd2a9bb..17202bb 100644
> --- a/arch/mips/kernel/scall32-o32.S
> +++ b/arch/mips/kernel/scall32-o32.S
> @@ -583,6 +583,7 @@ einval: =A0 =A0 li =A0 =A0 =A0v0, -ENOSYS
> =A0 =A0 =A0 =A0sys =A0 =A0 sys_rt_tgsigqueueinfo =A0 4
> =A0 =A0 =A0 =A0sys =A0 =A0 sys_perf_event_open =A0 =A0 5
> =A0 =A0 =A0 =A0sys =A0 =A0 sys_accept4 =A0 =A0 =A0 =A0 =A0 =A0 4
> + =A0 =A0 =A0 sys =A0 =A0 sys_recvmmsg =A0 =A0 =A0 =A0 =A0 =A05
> =A0 =A0 =A0 =A0.endm
>
> =A0 =A0 =A0 =A0/* We pre-compute the number of _instruction_ bytes ne=
eded to
> diff --git a/arch/mips/kernel/scall64-64.S b/arch/mips/kernel/scall64=
-64.S
> index 18bf7f3..a8a6c59 100644
> --- a/arch/mips/kernel/scall64-64.S
> +++ b/arch/mips/kernel/scall64-64.S
> @@ -420,4 +420,5 @@ sys_call_table:
> =A0 =A0 =A0 =A0PTR =A0 =A0 sys_rt_tgsigqueueinfo
> =A0 =A0 =A0 =A0PTR =A0 =A0 sys_perf_event_open
> =A0 =A0 =A0 =A0PTR =A0 =A0 sys_accept4
> + =A0 =A0 =A0 PTR =A0 =A0 sys_recvmmsg
> =A0 =A0 =A0 =A0.size =A0 sys_call_table,.-sys_call_table
> diff --git a/arch/mips/kernel/scall64-n32.S b/arch/mips/kernel/scall6=
4-n32.S
> index 6ebc079..5154e64 100644
> --- a/arch/mips/kernel/scall64-n32.S
> +++ b/arch/mips/kernel/scall64-n32.S
> @@ -418,4 +418,5 @@ EXPORT(sysn32_call_table)
> =A0 =A0 =A0 =A0PTR =A0 =A0 compat_sys_rt_tgsigqueueinfo =A0 =A0/* 529=
5 */
> =A0 =A0 =A0 =A0PTR =A0 =A0 sys_perf_event_open
> =A0 =A0 =A0 =A0PTR =A0 =A0 sys_accept4
> + =A0 =A0 =A0 PTR =A0 =A0 compat_sys_recvmmsg
> =A0 =A0 =A0 =A0.size =A0 sysn32_call_table,.-sysn32_call_table
> diff --git a/arch/mips/kernel/scall64-o32.S b/arch/mips/kernel/scall6=
4-o32.S
> index 9bbf977..d0eff53 100644
> --- a/arch/mips/kernel/scall64-o32.S
> +++ b/arch/mips/kernel/scall64-o32.S
> @@ -538,4 +538,5 @@ sys_call_table:
> =A0 =A0 =A0 =A0PTR =A0 =A0 compat_sys_rt_tgsigqueueinfo
> =A0 =A0 =A0 =A0PTR =A0 =A0 sys_perf_event_open
> =A0 =A0 =A0 =A0PTR =A0 =A0 sys_accept4
> + =A0 =A0 =A0 PTR =A0 =A0 compat_sys_recvmmsg
> =A0 =A0 =A0 =A0.size =A0 sys_call_table,.-sys_call_table
> diff --git a/arch/sh/kernel/syscalls_64.S b/arch/sh/kernel/syscalls_6=
4.S
> index 5bfde6c..07d2aae 100644
> --- a/arch/sh/kernel/syscalls_64.S
> +++ b/arch/sh/kernel/syscalls_64.S
> @@ -391,3 +391,4 @@ sys_call_table:
> =A0 =A0 =A0 =A0.long sys_pwritev
> =A0 =A0 =A0 =A0.long sys_rt_tgsigqueueinfo
> =A0 =A0 =A0 =A0.long sys_perf_event_open
> + =A0 =A0 =A0 .long sys_recvmmsg =A0 =A0 =A0 =A0 =A0 =A0 =A0/* 365 */
> diff --git a/arch/sparc/kernel/systbls_64.S b/arch/sparc/kernel/systb=
ls_64.S
> index 009825f..f37bef7 100644
> --- a/arch/sparc/kernel/systbls_64.S
> +++ b/arch/sparc/kernel/systbls_64.S
> @@ -83,7 +83,7 @@ sys_call_table32:
> =A0/*310*/ =A0 =A0 =A0 =A0.word compat_sys_utimensat, compat_sys_sign=
alfd, sys_timerfd_create, sys_eventfd, compat_sys_fallocate
> =A0 =A0 =A0 =A0.word compat_sys_timerfd_settime, compat_sys_timerfd_g=
ettime, compat_sys_signalfd4, sys_eventfd2, sys_epoll_create1
> =A0/*320*/ =A0 =A0 =A0 =A0.word sys_dup3, sys_pipe2, sys_inotify_init=
1, sys_accept4, compat_sys_preadv
> - =A0 =A0 =A0 .word compat_sys_pwritev, compat_sys_rt_tgsigqueueinfo,=
 sys_perf_event_open
> + =A0 =A0 =A0 .word compat_sys_pwritev, compat_sys_rt_tgsigqueueinfo,=
 sys_perf_event_open, compat_sys_recvmmsg
>
> =A0#endif /* CONFIG_COMPAT */
>
> @@ -158,4 +158,4 @@ sys_call_table:
> =A0/*310*/ =A0 =A0 =A0 =A0.word sys_utimensat, sys_signalfd, sys_time=
rfd_create, sys_eventfd, sys_fallocate
> =A0 =A0 =A0 =A0.word sys_timerfd_settime, sys_timerfd_gettime, sys_si=
gnalfd4, sys_eventfd2, sys_epoll_create1
> =A0/*320*/ =A0 =A0 =A0 =A0.word sys_dup3, sys_pipe2, sys_inotify_init=
1, sys_accept4, sys_preadv
> - =A0 =A0 =A0 .word sys_pwritev, sys_rt_tgsigqueueinfo, sys_perf_even=
t_open
> + =A0 =A0 =A0 .word sys_pwritev, sys_rt_tgsigqueueinfo, sys_perf_even=
t_open, sys_recvmmsg
> diff --git a/arch/x86/ia32/ia32entry.S b/arch/x86/ia32/ia32entry.S
> index 74619c4..11a6c79 100644
> --- a/arch/x86/ia32/ia32entry.S
> +++ b/arch/x86/ia32/ia32entry.S
> @@ -832,4 +832,5 @@ ia32_sys_call_table:
> =A0 =A0 =A0 =A0.quad compat_sys_pwritev
> =A0 =A0 =A0 =A0.quad compat_sys_rt_tgsigqueueinfo =A0 =A0 =A0/* 335 *=
/
> =A0 =A0 =A0 =A0.quad sys_perf_event_open
> + =A0 =A0 =A0 .quad compat_sys_recvmmsg
> =A0ia32_syscall_end:
> diff --git a/arch/x86/include/asm/unistd_32.h b/arch/x86/include/asm/=
unistd_32.h
> index 6fb3c20..3baf379 100644
> --- a/arch/x86/include/asm/unistd_32.h
> +++ b/arch/x86/include/asm/unistd_32.h
> @@ -342,10 +342,11 @@
> =A0#define __NR_pwritev =A0 =A0 =A0 =A0 =A0 334
> =A0#define __NR_rt_tgsigqueueinfo 335
> =A0#define __NR_perf_event_open =A0 336
> +#define __NR_recvmmsg =A0 =A0 =A0 =A0 =A0337
>
> =A0#ifdef __KERNEL__
>
> -#define NR_syscalls 337
> +#define NR_syscalls 338
>
> =A0#define __ARCH_WANT_IPC_PARSE_VERSION
> =A0#define __ARCH_WANT_OLD_READDIR
> diff --git a/arch/x86/include/asm/unistd_64.h b/arch/x86/include/asm/=
unistd_64.h
> index 8d3ad0a..4843f7b 100644
> --- a/arch/x86/include/asm/unistd_64.h
> +++ b/arch/x86/include/asm/unistd_64.h
> @@ -661,6 +661,8 @@ __SYSCALL(__NR_pwritev, sys_pwritev)
> =A0__SYSCALL(__NR_rt_tgsigqueueinfo, sys_rt_tgsigqueueinfo)
> =A0#define __NR_perf_event_open =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 2=
98
> =A0__SYSCALL(__NR_perf_event_open, sys_perf_event_open)
> +#define __NR_recvmmsg =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0299
> +__SYSCALL(__NR_recvmmsg, sys_recvmmsg)
>
> =A0#ifndef __NO_STUBS
> =A0#define __ARCH_WANT_OLD_READDIR
> diff --git a/arch/x86/kernel/syscall_table_32.S b/arch/x86/kernel/sys=
call_table_32.S
> index 0157cd2..70c2125 100644
> --- a/arch/x86/kernel/syscall_table_32.S
> +++ b/arch/x86/kernel/syscall_table_32.S
> @@ -336,3 +336,4 @@ ENTRY(sys_call_table)
> =A0 =A0 =A0 =A0.long sys_pwritev
> =A0 =A0 =A0 =A0.long sys_rt_tgsigqueueinfo =A0 =A0 /* 335 */
> =A0 =A0 =A0 =A0.long sys_perf_event_open
> + =A0 =A0 =A0 .long sys_recvmmsg
> diff --git a/arch/xtensa/include/asm/unistd.h b/arch/xtensa/include/a=
sm/unistd.h
> index c092c8f..4e55dc7 100644
> --- a/arch/xtensa/include/asm/unistd.h
> +++ b/arch/xtensa/include/asm/unistd.h
> @@ -681,8 +681,10 @@ __SYSCALL(304, sys_signalfd, 3)
> =A0__SYSCALL(305, sys_ni_syscall, 0)
> =A0#define __NR_eventfd =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 306
> =A0__SYSCALL(306, sys_eventfd, 1)
> +#define __NR_recvmmsg =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0307
> +__SYSCALL(307, sys_recvmmsg, 5)
>
> -#define __NR_syscall_count =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 3=
07
> +#define __NR_syscall_count =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 3=
08
>
> =A0/*
> =A0* sysxtensa syscall handler
> diff --git a/include/linux/net.h b/include/linux/net.h
> index 529a093..b42bb60 100644
> --- a/include/linux/net.h
> +++ b/include/linux/net.h
> @@ -41,6 +41,7 @@
> =A0#define SYS_SENDMSG =A0 =A016 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* sys_se=
ndmsg(2) =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0#define SYS_RECVMSG =A0 =A017 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* sys_re=
cvmsg(2) =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0#define SYS_ACCEPT4 =A0 =A018 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* sys_ac=
cept4(2) =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> +#define SYS_RECVMMSG =A0 19 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* sys_recvmm=
sg(2) =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>
> =A0typedef enum {
> =A0 =A0 =A0 =A0SS_FREE =3D 0, =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
/* not allocated =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> diff --git a/include/linux/socket.h b/include/linux/socket.h
> index 3273a0c..59966f1 100644
> --- a/include/linux/socket.h
> +++ b/include/linux/socket.h
> @@ -65,6 +65,12 @@ struct msghdr {
> =A0 =A0 =A0 =A0unsigned =A0 =A0 =A0 =A0msg_flags;
> =A0};
>
> +/* For recvmmsg/sendmmsg */
> +struct mmsghdr {
> + =A0 =A0 =A0 struct msghdr =A0 msg_hdr;
> + =A0 =A0 =A0 unsigned =A0 =A0 =A0 =A0msg_len;
> +};
> +
> =A0/*
> =A0* =A0 =A0 POSIX 1003.1g - ancillary data object information
> =A0* =A0 =A0 Ancillary data consits of a sequence of pairs of
> @@ -312,6 +318,10 @@ extern int move_addr_to_user(struct sockaddr *ka=
ddr, int klen, void __user *uadd
> =A0extern int move_addr_to_kernel(void __user *uaddr, int ulen, struc=
t sockaddr *kaddr);
> =A0extern int put_cmsg(struct msghdr*, int level, int type, int len, =
void *data);
>
> +struct timespec;
> +
> +extern int __sys_recvmmsg(int fd, struct mmsghdr __user *mmsg, unsig=
ned int vlen,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned int flags,=
 struct timespec *timeout);
> =A0#endif
> =A0#endif /* not kernel and not glibc */
> =A0#endif /* _LINUX_SOCKET_H */
> diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
> index a990ace..714f063 100644
> --- a/include/linux/syscalls.h
> +++ b/include/linux/syscalls.h
> @@ -25,6 +25,7 @@ struct linux_dirent64;
> =A0struct list_head;
> =A0struct msgbuf;
> =A0struct msghdr;
> +struct mmsghdr;
> =A0struct msqid_ds;
> =A0struct new_utsname;
> =A0struct nfsctl_arg;
> @@ -677,6 +678,9 @@ asmlinkage long sys_recv(int, void __user *, size=
_t, unsigned);
> =A0asmlinkage long sys_recvfrom(int, void __user *, size_t, unsigned,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct=
 sockaddr __user *, int __user *);
> =A0asmlinkage long sys_recvmsg(int fd, struct msghdr __user *msg, uns=
igned flags);
> +asmlinkage long sys_recvmmsg(int fd, struct mmsghdr __user *msg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned int=
 vlen, unsigned flags,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct times=
pec __user *timeout);
> =A0asmlinkage long sys_socket(int, int, int);
> =A0asmlinkage long sys_socketpair(int, int, int, int __user *);
> =A0asmlinkage long sys_socketcall(int call, unsigned long __user *arg=
s);
> diff --git a/include/net/compat.h b/include/net/compat.h
> index 7c30028..9679f05 100644
> --- a/include/net/compat.h
> +++ b/include/net/compat.h
> @@ -18,6 +18,11 @@ struct compat_msghdr {
> =A0 =A0 =A0 =A0compat_uint_t =A0 msg_flags;
> =A0};
>
> +struct compat_mmsghdr {
> + =A0 =A0 =A0 struct compat_msghdr msg_hdr;
> + =A0 =A0 =A0 compat_uint_t =A0 =A0 =A0 =A0msg_len;
> +};
> +
> =A0struct compat_cmsghdr {
> =A0 =A0 =A0 =A0compat_size_t =A0 cmsg_len;
> =A0 =A0 =A0 =A0compat_int_t =A0 =A0cmsg_level;
> @@ -35,6 +40,9 @@ extern int get_compat_msghdr(struct msghdr *, struc=
t compat_msghdr __user *);
> =A0extern int verify_compat_iovec(struct msghdr *, struct iovec *, st=
ruct sockaddr *, int);
> =A0extern asmlinkage long compat_sys_sendmsg(int,struct compat_msghdr=
 __user *,unsigned);
> =A0extern asmlinkage long compat_sys_recvmsg(int,struct compat_msghdr=
 __user *,unsigned);
> +extern asmlinkage long compat_sys_recvmmsg(int, struct compat_mmsghd=
r __user *,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0unsigned, unsigned,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0struct timespec __user *);
> =A0extern asmlinkage long compat_sys_getsockopt(int, int, int, char _=
_user *, int __user *);
> =A0extern int put_cmsg_compat(struct msghdr*, int, int, int, void *);
>
> diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
> index e06d0b8..f050ba8 100644
> --- a/kernel/sys_ni.c
> +++ b/kernel/sys_ni.c
> @@ -48,8 +48,10 @@ cond_syscall(sys_shutdown);
> =A0cond_syscall(sys_sendmsg);
> =A0cond_syscall(compat_sys_sendmsg);
> =A0cond_syscall(sys_recvmsg);
> +cond_syscall(sys_recvmmsg);
> =A0cond_syscall(compat_sys_recvmsg);
> =A0cond_syscall(compat_sys_recvfrom);
> +cond_syscall(compat_sys_recvmmsg);
> =A0cond_syscall(sys_socketcall);
> =A0cond_syscall(sys_futex);
> =A0cond_syscall(compat_sys_futex);
> diff --git a/net/compat.c b/net/compat.c
> index a407c3a..e13f525 100644
> --- a/net/compat.c
> +++ b/net/compat.c
> @@ -727,10 +727,10 @@ EXPORT_SYMBOL(compat_mc_getsockopt);
>
> =A0/* Argument list sizes for compat_sys_socketcall */
> =A0#define AL(x) ((x) * sizeof(u32))
> -static unsigned char nas[19]=3D{AL(0),AL(3),AL(3),AL(3),AL(2),AL(3),
> +static unsigned char nas[20]=3D{AL(0),AL(3),AL(3),AL(3),AL(2),AL(3),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0AL(3),=
AL(3),AL(4),AL(4),AL(4),AL(6),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0AL(6),=
AL(2),AL(5),AL(5),AL(3),AL(3),
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 AL(4)};
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 AL(4),A=
L(5)};
> =A0#undef AL
>
> =A0asmlinkage long compat_sys_sendmsg(int fd, struct compat_msghdr __=
user *msg, unsigned flags)
> @@ -755,13 +755,36 @@ asmlinkage long compat_sys_recvfrom(int fd, voi=
d __user *buf, size_t len,
> =A0 =A0 =A0 =A0return sys_recvfrom(fd, buf, len, flags | MSG_CMSG_COM=
PAT, addr, addrlen);
> =A0}
>
> +asmlinkage long compat_sys_recvmmsg(int fd, struct compat_mmsghdr __=
user *mmsg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 unsigned vlen, unsigned int flags,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 struct timespec __user *timeout)
> +{
> + =A0 =A0 =A0 int datagrams;
> + =A0 =A0 =A0 struct timespec ktspec;
> + =A0 =A0 =A0 struct compat_timespec __user *utspec =3D
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (struct compat_timespec=
 __user *)timeout;
> +
> + =A0 =A0 =A0 if (get_user(ktspec.tv_sec, &utspec->tv_sec) ||
> + =A0 =A0 =A0 =A0 =A0 get_user(ktspec.tv_nsec, &utspec->tv_nsec))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EFAULT;
> +
> + =A0 =A0 =A0 datagrams =3D __sys_recvmmsg(fd, (struct mmsghdr __user=
 *)mmsg, vlen,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
flags | MSG_CMSG_COMPAT, &ktspec);
> + =A0 =A0 =A0 if (datagrams > 0 &&
> + =A0 =A0 =A0 =A0 =A0 (put_user(ktspec.tv_sec, &utspec->tv_sec) ||
> + =A0 =A0 =A0 =A0 =A0 =A0put_user(ktspec.tv_nsec, &utspec->tv_nsec)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 datagrams =3D -EFAULT;
> +
> + =A0 =A0 =A0 return datagrams;
> +}
> +
> =A0asmlinkage long compat_sys_socketcall(int call, u32 __user *args)
> =A0{
> =A0 =A0 =A0 =A0int ret;
> =A0 =A0 =A0 =A0u32 a[6];
> =A0 =A0 =A0 =A0u32 a0, a1;
>
> - =A0 =A0 =A0 if (call < SYS_SOCKET || call > SYS_ACCEPT4)
> + =A0 =A0 =A0 if (call < SYS_SOCKET || call > SYS_RECVMMSG)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
> =A0 =A0 =A0 =A0if (copy_from_user(a, args, nas[call]))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EFAULT;
> @@ -823,6 +846,10 @@ asmlinkage long compat_sys_socketcall(int call, =
u32 __user *args)
> =A0 =A0 =A0 =A0case SYS_RECVMSG:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D compat_sys_recvmsg(a0, compat_=
ptr(a1), a[2]);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> + =A0 =A0 =A0 case SYS_RECVMMSG:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D compat_sys_recvmmsg(a0, compat_=
ptr(a1), a[2], a[3],
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 compat_ptr(a[4]));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> =A0 =A0 =A0 =A0case SYS_ACCEPT4:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D sys_accept4(a0, compat_ptr(a1)=
, compat_ptr(a[2]), a[3]);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> diff --git a/net/socket.c b/net/socket.c
> index 954f338..3dd03df 100644
> --- a/net/socket.c
> +++ b/net/socket.c
> @@ -668,10 +668,9 @@ void __sock_recv_timestamp(struct msghdr *msg, s=
truct sock *sk,
>
> =A0EXPORT_SYMBOL_GPL(__sock_recv_timestamp);
>
> -static inline int __sock_recvmsg(struct kiocb *iocb, struct socket *=
sock,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stru=
ct msghdr *msg, size_t size, int flags)
> +static inline int __sock_recvmsg_nosec(struct kiocb *iocb, struct so=
cket *sock,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0struct msghdr *msg, size_t size, int flags)
> =A0{
> - =A0 =A0 =A0 int err;
> =A0 =A0 =A0 =A0struct sock_iocb *si =3D kiocb_to_siocb(iocb);
>
> =A0 =A0 =A0 =A0si->sock =3D sock;
> @@ -680,13 +679,17 @@ static inline int __sock_recvmsg(struct kiocb *=
iocb, struct socket *sock,
> =A0 =A0 =A0 =A0si->size =3D size;
> =A0 =A0 =A0 =A0si->flags =3D flags;
>
> - =A0 =A0 =A0 err =3D security_socket_recvmsg(sock, msg, size, flags)=
;
> - =A0 =A0 =A0 if (err)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
> -
> =A0 =A0 =A0 =A0return sock->ops->recvmsg(iocb, sock, msg, size, flags=
);
> =A0}
>
> +static inline int __sock_recvmsg(struct kiocb *iocb, struct socket *=
sock,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stru=
ct msghdr *msg, size_t size, int flags)
> +{
> + =A0 =A0 =A0 int err =3D security_socket_recvmsg(sock, msg, size, fl=
ags);
> +
> + =A0 =A0 =A0 return err ?: __sock_recvmsg_nosec(iocb, sock, msg, siz=
e, flags);
> +}
> +
> =A0int sock_recvmsg(struct socket *sock, struct msghdr *msg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size_t size, int flags)
> =A0{
> @@ -702,6 +705,21 @@ int sock_recvmsg(struct socket *sock, struct msg=
hdr *msg,
> =A0 =A0 =A0 =A0return ret;
> =A0}
>
> +static int sock_recvmsg_nosec(struct socket *sock, struct msghdr *ms=
g,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size_t size=
, int flags)
> +{
> + =A0 =A0 =A0 struct kiocb iocb;
> + =A0 =A0 =A0 struct sock_iocb siocb;
> + =A0 =A0 =A0 int ret;
> +
> + =A0 =A0 =A0 init_sync_kiocb(&iocb, NULL);
> + =A0 =A0 =A0 iocb.private =3D &siocb;
> + =A0 =A0 =A0 ret =3D __sock_recvmsg_nosec(&iocb, sock, msg, size, fl=
ags);
> + =A0 =A0 =A0 if (-EIOCBQUEUED =3D=3D ret)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D wait_on_sync_kiocb(&iocb);
> + =A0 =A0 =A0 return ret;
> +}
> +
> =A0int kernel_recvmsg(struct socket *sock, struct msghdr *msg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct kvec *vec, size_t num, siz=
e_t size, int flags)
> =A0{
> @@ -1968,22 +1986,15 @@ out:
> =A0 =A0 =A0 =A0return err;
> =A0}
>
> -/*
> - * =A0 =A0 BSD recvmsg interface
> - */
> -
> -SYSCALL_DEFINE3(recvmsg, int, fd, struct msghdr __user *, msg,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned int, flags)
> +static int __sys_recvmsg(struct socket *sock, struct msghdr __user *=
msg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct msghdr *msg_s=
ys, unsigned flags, int nosec)
> =A0{
> =A0 =A0 =A0 =A0struct compat_msghdr __user *msg_compat =3D
> =A0 =A0 =A0 =A0 =A0 =A0(struct compat_msghdr __user *)msg;
> - =A0 =A0 =A0 struct socket *sock;
> =A0 =A0 =A0 =A0struct iovec iovstack[UIO_FASTIOV];
> =A0 =A0 =A0 =A0struct iovec *iov =3D iovstack;
> - =A0 =A0 =A0 struct msghdr msg_sys;
> =A0 =A0 =A0 =A0unsigned long cmsg_ptr;
> =A0 =A0 =A0 =A0int err, iov_size, total_len, len;
> - =A0 =A0 =A0 int fput_needed;
>
> =A0 =A0 =A0 =A0/* kernel mode address */
> =A0 =A0 =A0 =A0struct sockaddr_storage addr;
> @@ -1993,27 +2004,23 @@ SYSCALL_DEFINE3(recvmsg, int, fd, struct msgh=
dr __user *, msg,
> =A0 =A0 =A0 =A0int __user *uaddr_len;
>
> =A0 =A0 =A0 =A0if (MSG_CMSG_COMPAT & flags) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (get_compat_msghdr(&msg_sys, msg_com=
pat))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (get_compat_msghdr(msg_sys, msg_comp=
at))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EFAULT;
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 else if (copy_from_user(&msg_sys, msg, sizeof(struct ms=
ghdr)))
> + =A0 =A0 =A0 else if (copy_from_user(msg_sys, msg, sizeof(struct msg=
hdr)))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EFAULT;
>
> - =A0 =A0 =A0 sock =3D sockfd_lookup_light(fd, &err, &fput_needed);
> - =A0 =A0 =A0 if (!sock)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> -
> =A0 =A0 =A0 =A0err =3D -EMSGSIZE;
> - =A0 =A0 =A0 if (msg_sys.msg_iovlen > UIO_MAXIOV)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_put;
> + =A0 =A0 =A0 if (msg_sys->msg_iovlen > UIO_MAXIOV)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>
> =A0 =A0 =A0 =A0/* Check whether to allocate the iovec area */
> =A0 =A0 =A0 =A0err =3D -ENOMEM;
> - =A0 =A0 =A0 iov_size =3D msg_sys.msg_iovlen * sizeof(struct iovec);
> - =A0 =A0 =A0 if (msg_sys.msg_iovlen > UIO_FASTIOV) {
> + =A0 =A0 =A0 iov_size =3D msg_sys->msg_iovlen * sizeof(struct iovec)=
;
> + =A0 =A0 =A0 if (msg_sys->msg_iovlen > UIO_FASTIOV) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0iov =3D sock_kmalloc(sock->sk, iov_siz=
e, GFP_KERNEL);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!iov)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_put;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0/*
> @@ -2021,46 +2028,47 @@ SYSCALL_DEFINE3(recvmsg, int, fd, struct msgh=
dr __user *, msg,
> =A0 =A0 =A0 =A0 * =A0 =A0 =A0kernel msghdr to use the kernel address =
space)
> =A0 =A0 =A0 =A0 */
>
> - =A0 =A0 =A0 uaddr =3D (__force void __user *)msg_sys.msg_name;
> + =A0 =A0 =A0 uaddr =3D (__force void __user *)msg_sys->msg_name;
> =A0 =A0 =A0 =A0uaddr_len =3D COMPAT_NAMELEN(msg);
> =A0 =A0 =A0 =A0if (MSG_CMSG_COMPAT & flags) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D verify_compat_iovec(&msg_sys, i=
ov,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D verify_compat_iovec(msg_sys, io=
v,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0(struct sockaddr *)&addr,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0VERIFY_WRITE);
> =A0 =A0 =A0 =A0} else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D verify_iovec(&msg_sys, iov,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D verify_iovec(msg_sys, iov,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (=
struct sockaddr *)&addr,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 V=
ERIFY_WRITE);
> =A0 =A0 =A0 =A0if (err < 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_freeiov;
> =A0 =A0 =A0 =A0total_len =3D err;
>
> - =A0 =A0 =A0 cmsg_ptr =3D (unsigned long)msg_sys.msg_control;
> - =A0 =A0 =A0 msg_sys.msg_flags =3D flags & (MSG_CMSG_CLOEXEC|MSG_CMS=
G_COMPAT);
> + =A0 =A0 =A0 cmsg_ptr =3D (unsigned long)msg_sys->msg_control;
> + =A0 =A0 =A0 msg_sys->msg_flags =3D flags & (MSG_CMSG_CLOEXEC|MSG_CM=
SG_COMPAT);
>
> =A0 =A0 =A0 =A0if (sock->file->f_flags & O_NONBLOCK)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0flags |=3D MSG_DONTWAIT;
> - =A0 =A0 =A0 err =3D sock_recvmsg(sock, &msg_sys, total_len, flags);
> + =A0 =A0 =A0 err =3D (nosec ? sock_recvmsg_nosec : sock_recvmsg)(soc=
k, msg_sys,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total_len, flags);
> =A0 =A0 =A0 =A0if (err < 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_freeiov;
> =A0 =A0 =A0 =A0len =3D err;
>
> =A0 =A0 =A0 =A0if (uaddr !=3D NULL) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D move_addr_to_user((struct sock=
addr *)&addr,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 msg_sys.msg_namelen, uaddr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 msg_sys->msg_namelen, uaddr,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0uaddr_len);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (err < 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_freeiov;
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 err =3D __put_user((msg_sys.msg_flags & ~MSG_CMSG_COMPA=
T),
> + =A0 =A0 =A0 err =3D __put_user((msg_sys->msg_flags & ~MSG_CMSG_COMP=
AT),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 COMPAT_FLAGS(msg));
> =A0 =A0 =A0 =A0if (err)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_freeiov;
> =A0 =A0 =A0 =A0if (MSG_CMSG_COMPAT & flags)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D __put_user((unsigned long)msg_s=
ys.msg_control - cmsg_ptr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D __put_user((unsigned long)msg_s=
ys->msg_control - cmsg_ptr,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &msg_=
compat->msg_controllen);
> =A0 =A0 =A0 =A0else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D __put_user((unsigned long)msg_s=
ys.msg_control - cmsg_ptr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D __put_user((unsigned long)msg_s=
ys->msg_control - cmsg_ptr,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &msg-=
>msg_controllen);
> =A0 =A0 =A0 =A0if (err)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_freeiov;
> @@ -2069,21 +2077,150 @@ SYSCALL_DEFINE3(recvmsg, int, fd, struct msg=
hdr __user *, msg,
> =A0out_freeiov:
> =A0 =A0 =A0 =A0if (iov !=3D iovstack)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sock_kfree_s(sock->sk, iov, iov_size);
> -out_put:
> +out:
> + =A0 =A0 =A0 return err;
> +}
> +
> +/*
> + * =A0 =A0 BSD recvmsg interface
> + */
> +
> +SYSCALL_DEFINE3(recvmsg, int, fd, struct msghdr __user *, msg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned int, flags)
> +{
> + =A0 =A0 =A0 int fput_needed, err;
> + =A0 =A0 =A0 struct msghdr msg_sys;
> + =A0 =A0 =A0 struct socket *sock =3D sockfd_lookup_light(fd, &err, &=
fput_needed);
> +
> + =A0 =A0 =A0 if (!sock)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> +
> + =A0 =A0 =A0 err =3D __sys_recvmsg(sock, msg, &msg_sys, flags, 0);
> +
> =A0 =A0 =A0 =A0fput_light(sock->file, fput_needed);
> =A0out:
> =A0 =A0 =A0 =A0return err;
> =A0}
>
> -#ifdef __ARCH_WANT_SYS_SOCKETCALL
> +/*
> + * =A0 =A0 Linux recvmmsg interface
> + */
> +
> +int __sys_recvmmsg(int fd, struct mmsghdr __user *mmsg, unsigned int=
 vlen,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned int flags, struct times=
pec *timeout)
> +{
> + =A0 =A0 =A0 int fput_needed, err, datagrams;
> + =A0 =A0 =A0 struct socket *sock;
> + =A0 =A0 =A0 struct mmsghdr __user *entry;
> + =A0 =A0 =A0 struct msghdr msg_sys;
> + =A0 =A0 =A0 struct timespec end_time;
> +
> + =A0 =A0 =A0 if (timeout &&
> + =A0 =A0 =A0 =A0 =A0 poll_select_set_timeout(&end_time, timeout->tv_=
sec,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 timeout->tv_nsec))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> +
> + =A0 =A0 =A0 datagrams =3D 0;
> +
> + =A0 =A0 =A0 sock =3D sockfd_lookup_light(fd, &err, &fput_needed);
> + =A0 =A0 =A0 if (!sock)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
> +
> + =A0 =A0 =A0 err =3D sock_error(sock->sk);
> + =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_put;
> +
> + =A0 =A0 =A0 entry =3D mmsg;
> +
> + =A0 =A0 =A0 while (datagrams < vlen) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* No need to ask LSM for more than t=
he first datagram.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D __sys_recvmsg(sock, (struct msg=
hdr __user *)entry,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 &msg_sys, flags, datagrams);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D put_user(err, &entry->msg_len);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ++entry;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ++datagrams;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (timeout) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ktime_get_ts(timeout);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *timeout =3D timespec_s=
ub(end_time, *timeout);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (timeout->tv_sec < 0=
) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 timeout=
->tv_sec =3D timeout->tv_nsec =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Timeout, return less=
 than vlen datagrams */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (timeout->tv_nsec =3D=
=3D 0 && timeout->tv_sec =3D=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Out of band data, return right away =
*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (msg_sys.msg_flags & MSG_OOB)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 }
> +
> +out_put:
> + =A0 =A0 =A0 fput_light(sock->file, fput_needed);
>
> + =A0 =A0 =A0 if (err =3D=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return datagrams;
> +
> + =A0 =A0 =A0 if (datagrams !=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* We may return less entries than re=
quested (vlen) if the
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* sock is non block and there aren't=
 enough datagrams...
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err !=3D -EAGAIN) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* ... or =A0if recvm=
sg returns an error after we
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* received some data=
grams, where we record the
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* error to return on=
 the next call or if the
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* app asks about it =
using getsockopt(SO_ERROR).
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sock->sk->sk_err =3D -e=
rr;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return datagrams;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return err;
> +}
> +
> +SYSCALL_DEFINE5(recvmmsg, int, fd, struct mmsghdr __user *, mmsg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned int, vlen, unsigned int, flags=
,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct timespec __user *, timeout)
> +{
> + =A0 =A0 =A0 int datagrams;
> + =A0 =A0 =A0 struct timespec timeout_sys;
> +
> + =A0 =A0 =A0 if (!timeout)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return __sys_recvmmsg(fd, mmsg, vlen, f=
lags, NULL);
> +
> + =A0 =A0 =A0 if (copy_from_user(&timeout_sys, timeout, sizeof(timeou=
t_sys)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EFAULT;
> +
> + =A0 =A0 =A0 datagrams =3D __sys_recvmmsg(fd, mmsg, vlen, flags, &ti=
meout_sys);
> +
> + =A0 =A0 =A0 if (datagrams > 0 &&
> + =A0 =A0 =A0 =A0 =A0 copy_to_user(timeout, &timeout_sys, sizeof(time=
out_sys)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 datagrams =3D -EFAULT;
> +
> + =A0 =A0 =A0 return datagrams;
> +}
> +
> +#ifdef __ARCH_WANT_SYS_SOCKETCALL
> =A0/* Argument list sizes for sys_socketcall */
> =A0#define AL(x) ((x) * sizeof(unsigned long))
> -static const unsigned char nargs[19]=3D{
> +static const unsigned char nargs[20] =3D {
> =A0 =A0 =A0 =A0AL(0),AL(3),AL(3),AL(3),AL(2),AL(3),
> =A0 =A0 =A0 =A0AL(3),AL(3),AL(4),AL(4),AL(4),AL(6),
> =A0 =A0 =A0 =A0AL(6),AL(2),AL(5),AL(5),AL(3),AL(3),
> - =A0 =A0 =A0 AL(4)
> + =A0 =A0 =A0 AL(4),AL(5)
> =A0};
>
> =A0#undef AL
> @@ -2103,7 +2240,7 @@ SYSCALL_DEFINE2(socketcall, int, call, unsigned=
 long __user *, args)
> =A0 =A0 =A0 =A0int err;
> =A0 =A0 =A0 =A0unsigned int len;
>
> - =A0 =A0 =A0 if (call < 1 || call > SYS_ACCEPT4)
> + =A0 =A0 =A0 if (call < 1 || call > SYS_RECVMMSG)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
>
> =A0 =A0 =A0 =A0len =3D nargs[call];
> @@ -2181,6 +2318,10 @@ SYSCALL_DEFINE2(socketcall, int, call, unsigne=
d long __user *, args)
> =A0 =A0 =A0 =A0case SYS_RECVMSG:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D sys_recvmsg(a0, (struct msghdr=
 __user *)a1, a[2]);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> + =A0 =A0 =A0 case SYS_RECVMMSG:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D sys_recvmmsg(a0, (struct mmsghd=
r __user *)a1, a[2], a[3],
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
(struct timespec __user *)a[4]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> =A0 =A0 =A0 =A0case SYS_ACCEPT4:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D sys_accept4(a0, (struct sockad=
dr __user *)a1,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(i=
nt __user *)a[2], a[3]);
> --
> 1.5.5.1
>
>
