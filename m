From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v10 05/11] seccomp: add system call filtering using BPF
Date: Wed, 22 Feb 2012 13:47:16 -0600
Message-ID: <CABqD9hYTLNrQKzYiRV6yN-z_mYyfPR=3W1P6nC+VmYmFGE1vQg@mail.gmail.com>
References: <1329845435-2313-1-git-send-email-wad@chromium.org>
	<1329845435-2313-5-git-send-email-wad@chromium.org>
	<38d58caa17befe422065efe5dc451a34.squirrel@webmail.greenhost.nl>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de, davem@davemloft.net,
	hpa@zytor.com, mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, pmoore@redhat.com, akpm@linux-foundation.org,
	corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,
	keescook@chromium.org
To: Indan Zupancic <indan@nul.nu>
Return-path: <kernel-hardening-return-909-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <38d58caa17befe422065efe5dc451a34.squirrel@webmail.greenhost.nl>
List-Id: netdev.vger.kernel.org

On Wed, Feb 22, 2012 at 2:19 AM, Indan Zupancic <indan@nul.nu> wrote:
> Hello,
>
> On Tue, February 21, 2012 18:30, Will Drewry wrote:
>> [This patch depends on luto@mit.edu's no_new_privs patch:
>> https://lkml.org/lkml/2012/1/30/264
>> ]
>>
>> This patch adds support for seccomp mode 2. =A0Mode 2 introduces the
>> ability for unprivileged processes to install system call filtering
>> policy expressed in terms of a Berkeley Packet Filter (BPF) program.
>> This program will be evaluated in the kernel for each system call
>> the task makes and computes a result based on data in the format
>> of struct seccomp_data.
>>
>> A filter program may be installed by calling:
>> =A0struct sock_fprog fprog =3D { ... };
>> =A0...
>> =A0prctl(PR_SET_SECCOMP, SECCOMP_MODE_FILTER, &fprog);
>>
>> The return value of the filter program determines if the system call is
>> allowed to proceed or denied. =A0If the first filter program installed
>> allows prctl(2) calls, then the above call may be made repeatedly
>> by a task to further reduce its access to the kernel. =A0All attached
>> programs must be evaluated before a system call will be allowed to
>> proceed.
>>
>> Filter programs will be inherited across fork/clone and execve.
>> However, if the task attaching the filter is unprivileged
>> (!CAP_SYS_ADMIN) the no_new_privs bit will be set on the task. =A0This
>> ensures that unprivileged tasks cannot attach filters that affect
>> privileged tasks (e.g., setuid binary).
>>
>> There are a number of benefits to this approach. A few of which are
>> as follows:
>> - BPF has been exposed to userland for a long time
>> - BPF optimization (and JIT'ing) are well understood
>> - Userland already knows its ABI: system call numbers and desired
>> =A0arguments
>> - No time-of-check-time-of-use vulnerable data accesses are possible.
>> - system call arguments are loaded on access only to minimize copying
>> =A0required for system call policy decisions.
>>
>> Mode 2 support is restricted to architectures that enable
>> HAVE_ARCH_SECCOMP_FILTER. =A0In this patch, the primary dependency is on
>> syscall_get_arguments(). =A0The full desired scope of this feature will
>> add a few minor additional requirements expressed later in this series.
>> Based on discussion, SECCOMP_RET_ERRNO and SECCOMP_RET_TRACE seem to be
>> the desired additional functionality.
>>
>> No architectures are enabled in this patch.
>>
>> v10: - seccomp_data has changed again to be more aesthetically pleasing
>> =A0 =A0 =A0 (hpa@zytor.com)
>> =A0 =A0 - calling convention is noted in a new u32 field using syscall_g=
et_arch.
>> =A0 =A0 =A0 This allows for cross-calling convention tasks to use seccom=
p filters.
>> =A0 =A0 =A0 (hpa@zytor.com)
>
> I highly disagree with every filter having to check the mode: Filters tha=
t
> don't check the arch on e.g. x86 are buggy, so they have to check it, eve=
n
> if it's a 32-bit or 64-bit only system, the filters can't know that and
> needs to check the arch at every syscall entry. All other info in the dat=
a
> depends on the arch, because of this there isn't much code to share betwe=
en
> the two archs, so you can as well have one filter for each arch.
>
> Alternative approach: Tell the arch at filter install time and only run t=
he
> filters with the same arch as the current system call. If no filters are =
run,
> deny the systemcall.

This was roughly how I first implemented compat and non-compat
support.  It causes some implicit behavior across inheritance that is
not nice though.

> Advantages:
>
> - Filters don't have to check the arch every syscall entry.

This I like.

> - Secure by default. Filters don't have to do anything arch specific to
> =A0be secure, no surprises possible.

This is partially true, but it is exactly why I hid compat before.

> - If a new arch comes into existence, there is no chance of old filters
> =A0becoming buggy and insecure. This is especially true for archs that
> =A0had only one mode, but added another one later on: Old filters had no
> =A0need to check the mode at all.

Perhaps.  A buggy filter that works on x86-64 might be exposed on a
new x32 ABI.  It's hard to predict how audit_arch and the syscall abi
will develop with new platforms.

> - For kernels supporting only one arch, the check can be optimised away,
> =A0by not installing unsupported arch filters at all.

Somewhat.  Without having a dedicated arch helper, you'd have to guess
that arches only support one or two arches (if compat is supported),
but I don't know if that is a safe assumption to make.

> It's more secure, faster and simpler for the filters.
>
> If something like this is implemented it's fine to expose the arch info
> in the syscall data too, and have a way to install filters for all archs,
> for the few cases where that might be useful, although I can't think of
> any reason why people would like to do unnecessary work in the filters.

It seems to just add complexity to support both. I think we'll
probably end up with it in the filters for better or worse.  Possibly
JITing will be useful since at least a 32-bit load and je is pretty
cheap in native instructions.

> All that's needed is an extra argument to the prctl() call. I propose
> 0 for the current arch, -1 for all archs and anything else to specify
> the arch. Installing a filter for an unsupported arch could return
> ENOEXEC.

Without adding a per-arch call, there is no way to know all the
supported arches at install time.  Current arch, at least, can be
determined with a call to syscall_get_arch().

As is, I'm not sure it makes sense to try to reserve two extra input
types: 0 and -1.  0 would be sane to treat as either a wildcard or
current because it is unlikely to be used by AUDIT_ARCH_* ever since
EM_NONE is assigned to 0.  However, I have no such insight into
whether it will ever be possible to compose 0xffffffff as an
AUDIT_ARCH_.

> As far as the implementation goes, either have a list per supported arch
> or store the arch per filter and check that before running the filter.

You can't do it per arch without adding even more per-arch
dependencies.  Keeping them annotated in the same list is the clearest
way I've seen so far, but it comes with its own burdens.

>> =A0 =A0 - lots of clean up (thanks, Indan!)
>> v9: - n/a
>> v8: - use bpf_chk_filter, bpf_run_filter. update load_fns
>> =A0 =A0 - Lots of fixes courtesy of indan@nul.nu:
>> =A0 =A0 -- fix up load behavior, compat fixups, and merge alloc code,
>> =A0 =A0 -- renamed pc and dropped __packed, use bool compat.
>> =A0 =A0 -- Added a hidden CONFIG_SECCOMP_FILTER to synthesize non-arch
>> =A0 =A0 =A0 =A0dependencies
>> v7: =A0(massive overhaul thanks to Indan, others)
>> =A0 =A0 - added CONFIG_HAVE_ARCH_SECCOMP_FILTER
>> =A0 =A0 - merged into seccomp.c
>> =A0 =A0 - minimal seccomp_filter.h
>> =A0 =A0 - no config option (part of seccomp)
>> =A0 =A0 - no new prctl
>> =A0 =A0 - doesn't break seccomp on systems without asm/syscall.h
>> =A0 =A0 =A0 (works but arg access always fails)
>> =A0 =A0 - dropped seccomp_init_task, extra free functions, ...
>> =A0 =A0 - dropped the no-asm/syscall.h code paths
>> =A0 =A0 - merges with network sk_run_filter and sk_chk_filter
>> v6: - fix memory leak on attach compat check failure
>> =A0 =A0 - require no_new_privs || CAP_SYS_ADMIN prior to filter
>> =A0 =A0 =A0 installation. (luto@mit.edu)
>> =A0 =A0 - s/seccomp_struct_/seccomp_/ for macros/functions (amwang@redha=
t.com)
>> =A0 =A0 - cleaned up Kconfig (amwang@redhat.com)
>> =A0 =A0 - on block, note if the call was compat (so the # means somethin=
g)
>> v5: - uses syscall_get_arguments
>> =A0 =A0 =A0 (indan@nul.nu,oleg@redhat.com, mcgrathr@chromium.org)
>> =A0 =A0 =A0- uses union-based arg storage with hi/lo struct to
>> =A0 =A0 =A0 =A0handle endianness. =A0Compromises between the two alterna=
te
>> =A0 =A0 =A0 =A0proposals to minimize extra arg shuffling and account for
>> =A0 =A0 =A0 =A0endianness assuming userspace uses offsetof().
>> =A0 =A0 =A0 =A0(mcgrathr@chromium.org, indan@nul.nu)
>> =A0 =A0 =A0- update Kconfig description
>> =A0 =A0 =A0- add include/seccomp_filter.h and add its installation
>> =A0 =A0 =A0- (naive) on-demand syscall argument loading
>> =A0 =A0 =A0- drop seccomp_t (eparis@redhat.com)
>> v4: =A0- adjusted prctl to make room for PR_[SG]ET_NO_NEW_PRIVS
>> =A0 =A0 =A0- now uses current->no_new_privs
>> =A0 =A0 =A0 =A0(luto@mit.edu,torvalds@linux-foundation.com)
>> =A0 =A0 =A0- assign names to seccomp modes (rdunlap@xenotime.net)
>> =A0 =A0 =A0- fix style issues (rdunlap@xenotime.net)
>> =A0 =A0 =A0- reworded Kconfig entry (rdunlap@xenotime.net)
>> v3: =A0- macros to inline (oleg@redhat.com)
>> =A0 =A0 =A0- init_task behavior fixed (oleg@redhat.com)
>> =A0 =A0 =A0- drop creator entry and extra NULL check (oleg@redhat.com)
>> =A0 =A0 =A0- alloc returns -EINVAL on bad sizing (serge.hallyn@canonical=
.com)
>> =A0 =A0 =A0- adds tentative use of "always_unprivileged" as per
>> =A0 =A0 =A0 =A0torvalds@linux-foundation.org and luto@mit.edu
>> v2: =A0- (patch 2 only)
>>
>> Signed-off-by: Will Drewry <wad@chromium.org>
>> ---
>> arch/Kconfig =A0 =A0 =A0 =A0 =A0 =A0| =A0 18 +++
>> include/linux/Kbuild =A0 =A0| =A0 =A01 +
>> include/linux/seccomp.h | =A0 76 +++++++++++-
>> kernel/fork.c =A0 =A0 =A0 =A0 =A0 | =A0 =A03 +
>> kernel/seccomp.c =A0 =A0 =A0 =A0| =A0321 +++++++++++++++++++++++++++++++=
+++++++++++++---
>> kernel/sys.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +-
>> 6 files changed, 399 insertions(+), 22 deletions(-)
>>
>> diff --git a/arch/Kconfig b/arch/Kconfig
>> index 4f55c73..8150fa2 100644
>> --- a/arch/Kconfig
>> +++ b/arch/Kconfig
>> @@ -199,4 +199,22 @@ config HAVE_CMPXCHG_LOCAL
>> config HAVE_CMPXCHG_DOUBLE
>> =A0 =A0 =A0 bool
>>
>> +config HAVE_ARCH_SECCOMP_FILTER
>> + =A0 =A0 bool
>> + =A0 =A0 help
>> + =A0 =A0 =A0 This symbol should be selected by an architecure if it pro=
vides
>> + =A0 =A0 =A0 asm/syscall.h, specifically syscall_get_arguments() and
>> + =A0 =A0 =A0 syscall_get_arch().
>> +
>> +config SECCOMP_FILTER
>> + =A0 =A0 def_bool y
>> + =A0 =A0 depends on HAVE_ARCH_SECCOMP_FILTER && SECCOMP && NET
>> + =A0 =A0 help
>> + =A0 =A0 =A0 Enable tasks to build secure computing environments define=
d
>> + =A0 =A0 =A0 in terms of Berkeley Packet Filter programs which implemen=
t
>> + =A0 =A0 =A0 task-defined system call filtering polices.
>> +
>> + =A0 =A0 =A0 See Documentation/prctl/seccomp_filter.txt for more
>> + =A0 =A0 =A0 information on the topic of seccomp filtering.
>
> The last part is redundant, the topic is clear.

I'll drop it.

>> +
>> source "kernel/gcov/Kconfig"
>> diff --git a/include/linux/Kbuild b/include/linux/Kbuild
>> index c94e717..d41ba12 100644
>> --- a/include/linux/Kbuild
>> +++ b/include/linux/Kbuild
>> @@ -330,6 +330,7 @@ header-y +=3D scc.h
>> header-y +=3D sched.h
>> header-y +=3D screen_info.h
>> header-y +=3D sdla.h
>> +header-y +=3D seccomp.h
>> header-y +=3D securebits.h
>> header-y +=3D selinux_netlink.h
>> header-y +=3D sem.h
>> diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
>> index d61f27f..001f883 100644
>> --- a/include/linux/seccomp.h
>> +++ b/include/linux/seccomp.h
>> @@ -1,14 +1,67 @@
>> #ifndef _LINUX_SECCOMP_H
>> #define _LINUX_SECCOMP_H
>>
>> +#include <linux/compiler.h>
>> +#include <linux/types.h>
>> +
>> +
>> +/* Valid values for seccomp.mode and prctl(PR_SET_SECCOMP, <mode>) */
>> +#define SECCOMP_MODE_DISABLED =A0 =A0 =A0 =A00 /* seccomp is not in use=
. */
>> +#define SECCOMP_MODE_STRICT =A01 /* uses hard-coded filter. */
>> +#define SECCOMP_MODE_FILTER =A02 /* uses user-supplied filter. */
>> +
>> +/*
>> + * BPF programs may return a 32-bit value.
>
> They have to return a 32-bit value, no "may" about it.

True.

>> + * The bottom 16-bits are reserved for future use.
>> + * The upper 16-bits are ordered from least permissive values to most.
>> + *
>> + * The ordering ensures that a min_t() over composed return values alwa=
ys
>> + * selects the least permissive choice.
>> + */
>> +#define SECCOMP_RET_KILL =A0 =A0 0x00000000U /* kill the task immediate=
ly */
>> +#define SECCOMP_RET_ALLOW =A0 =A00x7fff0000U /* allow */
>> +
>> +/* Masks for the return value sections. */
>> +#define SECCOMP_RET_ACTION =A0 0xffff0000U
>> +#define SECCOMP_RET_DATA =A0 =A0 0x0000ffffU
>> +
>> +/**
>> + * struct seccomp_data - the format the BPF program executes over.
>> + * @args: up to 6 system call arguments. =A0When the calling convention=
 is
>> + * =A0 =A0 =A0 =A032-bit, the arguments will still be at each args[X] o=
ffset.
>
> What does this mean? Do you mean the data layout will always be "LE" for
> 32-bit archs? I hope not, because that would make it incompatible with
> the 64-bit code for BE archs, so it will be confusing. Except if the data
> layout is always LE, but then you should document that. If neither is the
> case, then the comment is just confusing. Just say that the data layout
> depends on the arch's endianness.

I'll rephrase.  I just wanted to call out that the argument values
will always be treated as a 64-bit value even if the calling
convention is 32-bit.  This doesn't matter for LE systems, except to
acknowledge the padding, but for BE systems they might load the wrong
half.

>> + * @instruction_pointer: at the time of the system call.
>> + * @arch: indicates system call convention as an AUDIT_ARCH_* value
>> + * =A0 =A0 =A0 =A0as defined in <linux/audit.h>.
>> + * @nr: the system call number
>> + */
>> +struct seccomp_data {
>> + =A0 =A0 __u64 args[6];
>> + =A0 =A0 __u64 instruction_pointer;
>> + =A0 =A0 __u32 arch;
>> + =A0 =A0 int nr;
>> +};
>
> I agree this looks a hell of a lot nicer. I just hope it's worth it.
> Oh well, a bit more ugliness in userspace to make the kernel code a
> bit nicer isn't too bad. Just document the endianness issue properly.
>
> What use is the instruction pointer considering it tells nothing about
> the call path?
>
>>
>> +#ifdef __KERNEL__
>> #ifdef CONFIG_SECCOMP
>>
>> #include <linux/thread_info.h>
>> #include <asm/seccomp.h>
>>
>> +struct seccomp_filter;
>> +/**
>> + * struct seccomp - the state of a seccomp'ed process
>> + *
>> + * @mode: =A0indicates one of the valid values above for controlled
>> + * =A0 =A0 =A0 =A0 system calls available to a process.
>> + * @filter: The metadata and ruleset for determining what system calls
>> + * =A0 =A0 =A0 =A0 =A0are allowed for a task.
>> + *
>> + * =A0 =A0 =A0 =A0 =A0@filter must only be accessed from the context of=
 current as there
>> + * =A0 =A0 =A0 =A0 =A0is no locking.
>> + */
>> struct seccomp {
>> =A0 =A0 =A0 int mode;
>> + =A0 =A0 struct seccomp_filter *filter;
>> };
>>
>> extern void __secure_computing(int);
>> @@ -19,7 +72,7 @@ static inline void secure_computing(int this_syscall)
>> }
>>
>> extern long prctl_get_seccomp(void);
>> -extern long prctl_set_seccomp(unsigned long);
>> +extern long prctl_set_seccomp(unsigned long, char __user *);
>>
>> static inline int seccomp_mode(struct seccomp *s)
>> {
>> @@ -31,15 +84,16 @@ static inline int seccomp_mode(struct seccomp *s)
>> #include <linux/errno.h>
>>
>> struct seccomp { };
>> +struct seccomp_filter { };
>>
>> -#define secure_computing(x) do { } while (0)
>> +#define secure_computing(x) 0
>>
>> static inline long prctl_get_seccomp(void)
>> {
>> =A0 =A0 =A0 return -EINVAL;
>> }
>>
>> -static inline long prctl_set_seccomp(unsigned long arg2)
>> +static inline long prctl_set_seccomp(unsigned long arg2, char __user *a=
rg3)
>> {
>> =A0 =A0 =A0 return -EINVAL;
>> }
>> @@ -48,7 +102,21 @@ static inline int seccomp_mode(struct seccomp *s)
>> {
>> =A0 =A0 =A0 return 0;
>> }
>> -
>> #endif /* CONFIG_SECCOMP */
>>
>> +#ifdef CONFIG_SECCOMP_FILTER
>> +extern void put_seccomp_filter(struct seccomp_filter *);
>> +extern void copy_seccomp(struct seccomp *child,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const struct seccomp *paren=
t);
>
> This is 80 chars long, why break it up? Please, stop your bad habit of
> breaking up (slightly too) long lines.
>
>> +#else =A0/* CONFIG_SECCOMP_FILTER */
>> +/* The macro consumes the ->filter reference. */
>> +#define put_seccomp_filter(_s) do { } while (0)
>> +
>> +static inline void copy_seccomp(struct seccomp *child,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const struct s=
eccomp *prev)
>> +{
>> + =A0 =A0 return;
>> +}
>> +#endif /* CONFIG_SECCOMP_FILTER */
>> +#endif /* __KERNEL__ */
>> #endif /* _LINUX_SECCOMP_H */
>> diff --git a/kernel/fork.c b/kernel/fork.c
>> index b77fd55..a5187b7 100644
>> --- a/kernel/fork.c
>> +++ b/kernel/fork.c
>> @@ -34,6 +34,7 @@
>> #include <linux/cgroup.h>
>> #include <linux/security.h>
>> #include <linux/hugetlb.h>
>> +#include <linux/seccomp.h>
>> #include <linux/swap.h>
>> #include <linux/syscalls.h>
>> #include <linux/jiffies.h>
>> @@ -169,6 +170,7 @@ void free_task(struct task_struct *tsk)
>> =A0 =A0 =A0 free_thread_info(tsk->stack);
>> =A0 =A0 =A0 rt_mutex_debug_task_free(tsk);
>> =A0 =A0 =A0 ftrace_graph_exit_task(tsk);
>> + =A0 =A0 put_seccomp_filter(tsk->seccomp.filter);
>
> So that's why you use macro's sometimes, to make it compile with
> CONFIG_SECCOMP disabled where there is no seccomp.filter.

Exactly!

>> =A0 =A0 =A0 free_task_struct(tsk);
>> }
>> EXPORT_SYMBOL(free_task);
>> @@ -1113,6 +1115,7 @@ static struct task_struct *copy_process(unsigned l=
ong clone_flags,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto fork_out;
>>
>> =A0 =A0 =A0 ftrace_graph_init_task(p);
>> + =A0 =A0 copy_seccomp(&p->seccomp, &current->seccomp);
>>
>> =A0 =A0 =A0 rt_mutex_init_task(p);
>>
>> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
>> index e8d76c5..0043b7e 100644
>> --- a/kernel/seccomp.c
>> +++ b/kernel/seccomp.c
>> @@ -3,16 +3,287 @@
>> =A0*
>> =A0* Copyright 2004-2005 =A0Andrea Arcangeli <andrea@cpushare.com>
>> =A0*
>> - * This defines a simple but solid secure-computing mode.
>> + * Copyright (C) 2012 Google, Inc.
>> + * Will Drewry <wad@chromium.org>
>> + *
>> + * This defines a simple but solid secure-computing facility.
>> + *
>> + * Mode 1 uses a fixed list of allowed system calls.
>> + * Mode 2 allows user-defined system call filters in the form
>> + * =A0 =A0 =A0 =A0of Berkeley Packet Filters/Linux Socket Filters.
>> =A0*/
>>
>> +#include <linux/atomic.h>
>> #include <linux/audit.h>
>> -#include <linux/seccomp.h>
>> -#include <linux/sched.h>
>> #include <linux/compat.h>
>> +#include <linux/filter.h>
>> +#include <linux/sched.h>
>> +#include <linux/seccomp.h>
>> +#include <linux/security.h>
>> +#include <linux/slab.h>
>> +#include <linux/uaccess.h>
>> +
>> +#include <linux/tracehook.h>
>> +#include <asm/syscall.h>
>>
>> /* #define SECCOMP_DEBUG 1 */
>> -#define NR_SECCOMP_MODES 1
>> +
>> +#ifdef CONFIG_SECCOMP_FILTER
>> +/**
>> + * struct seccomp_filter - container for seccomp BPF programs
>> + *
>> + * @usage: reference count to manage the object liftime.
>> + * =A0 =A0 =A0 =A0 get/put helpers should be used when accessing an ins=
tance
>> + * =A0 =A0 =A0 =A0 outside of a lifetime-guarded section. =A0In general=
, this
>> + * =A0 =A0 =A0 =A0 is only needed for handling filters shared across ta=
sks.
>> + * @prev: points to a previously installed, or inherited, filter
>> + * @compat: indicates the value of is_compat_task() at creation time
>
> You're not really using 'compat', except for logging.

Oops - I should've dropped it altogether!

> But you could use it to run only the filters with the right arch.

Well an int arch would do the trick.

>> + * @insns: the BPF program instructions to evaluate
>> + * @len: the number of instructions in the program
>> + *
>> + * seccomp_filter objects are organized in a tree linked via the @prev
>> + * pointer. =A0For any task, it appears to be a singly-linked list star=
ting
>> + * with current->seccomp.filter, the most recently attached or inherite=
d filter.
>> + * However, multiple filters may share a @prev node, by way of fork(), =
which
>> + * results in a unidirectional tree existing in memory. =A0This is simi=
lar to
>> + * how namespaces work.
>> + *
>> + * seccomp_filter objects should never be modified after being attached
>> + * to a task_struct (other than @usage).
>> + */
>> +struct seccomp_filter {
>> + =A0 =A0 atomic_t usage;
>> + =A0 =A0 struct seccomp_filter *prev;
>> + =A0 =A0 bool compat;
>> + =A0 =A0 unsigned short len; =A0/* Instruction count */
>> + =A0 =A0 struct sock_filter insns[];
>> +};
>> +
>> +static void seccomp_filter_log_failure(int syscall)
>> +{
>> + =A0 =A0 int compat =3D 0;
>> +#ifdef CONFIG_COMPAT
>> + =A0 =A0 compat =3D is_compat_task();
>> +#endif
>> + =A0 =A0 pr_info("%s[%d]: %ssystem call %d blocked at 0x%lx\n",
>> + =A0 =A0 =A0 =A0 =A0 =A0 current->comm, task_pid_nr(current),
>> + =A0 =A0 =A0 =A0 =A0 =A0 (compat ? "compat " : ""),
>> + =A0 =A0 =A0 =A0 =A0 =A0 syscall, KSTK_EIP(current));
>> +}
>> +
>> +/**
>> + * get_u32 - returns a u32 offset into data
>> + * @data: a unsigned 64 bit value
>> + * @index: 0 or 1 to return the first or second 32-bits
>> + *
>> + * This inline exists to hide the length of unsigned long.
>> + * If a 32-bit unsigned long is passed in, it will be extended
>> + * and the top 32-bits will be 0. If it is a 64-bit unsigned
>> + * long, then whatever data is resident will be properly returned.
>> + */
>> +static inline u32 get_u32(u64 data, int index)
>> +{
>> + =A0 =A0 return ((u32 *)&data)[index];
>> +}
>> +
>> +/* Helper for bpf_load below. */
>> +#define BPF_DATA(_name) offsetof(struct seccomp_data, _name)
>> +/**
>> + * bpf_load: checks and returns a pointer to the requested offset
>> + * @nr: int syscall passed as a void * to bpf_run_filter
>> + * @off: index into struct seccomp_data to load from
>> + * @size: load width requested
>> + * @buffer: temporary storage supplied by bpf_run_filter
>> + *
>> + * Returns a pointer to @buffer where the value was stored.
>> + * On failure, returns NULL.
>> + */
>> +static void *bpf_load(const void *nr, int off, unsigned int size, void =
*buf)
>> +{
>> + =A0 =A0 unsigned long value;
>> + =A0 =A0 u32 *A =3D buf;
>> +
>> + =A0 =A0 if (size !=3D sizeof(u32))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>> +
>> + =A0 =A0 if (off >=3D BPF_DATA(args[0]) && off < BPF_DATA(args[6])) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct pt_regs *regs =3D task_pt_regs(current)=
;
>> + =A0 =A0 =A0 =A0 =A0 =A0 int arg =3D off >> 3; =A0/* args[0] is at offs=
et 0. */
>
> Probably clearer if you just do off / 8, you can count on compilers to
> get that right and turn it into a shift.
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 int index =3D (off % sizeof(u64)) ? 1 : 0;
>
> Considering the previous line I expected to see (off & 4).
>
> Anyway, this code mostly ignores the lowest three bits and instead of
> either returning an error or the requested data, it returns the aligned
> value instead. Not good.

Hrm true - I got sloppy. I'll fix that up!

>> + =A0 =A0 =A0 =A0 =A0 =A0 syscall_get_arguments(current, regs, arg, 1, &=
value);
>> + =A0 =A0 =A0 =A0 =A0 =A0 *A =3D get_u32(value, index);
>> + =A0 =A0 } else if (off =3D=3D BPF_DATA(nr)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 *A =3D (u32)(uintptr_t)nr;
>> + =A0 =A0 } else if (off =3D=3D BPF_DATA(arch)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct pt_regs *regs =3D task_pt_regs(current)=
;
>> + =A0 =A0 =A0 =A0 =A0 =A0 *A =3D syscall_get_arch(current, regs);
>> + =A0 =A0 } else if (off =3D=3D BPF_DATA(instruction_pointer)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 *A =3D get_u32(KSTK_EIP(current), 0);
>> + =A0 =A0 } else if (off =3D=3D BPF_DATA(instruction_pointer) + sizeof(u=
32)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 *A =3D get_u32(KSTK_EIP(current), 1);
>> + =A0 =A0 } else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>> + =A0 =A0 }
>> + =A0 =A0 return buf;
>> +}
>> +
>> +/**
>> + * seccomp_run_filters - evaluates all seccomp filters against @syscall
>> + * @syscall: number of the current system call
>> + *
>> + * Returns valid seccomp BPF response codes.
>> + */
>> +static u32 seccomp_run_filters(int syscall)
>> +{
>> + =A0 =A0 struct seccomp_filter *f;
>> + =A0 =A0 u32 ret =3D SECCOMP_RET_KILL;
>> + =A0 =A0 static const struct bpf_load_fn fns =3D {
>> + =A0 =A0 =A0 =A0 =A0 =A0 bpf_load,
>> + =A0 =A0 =A0 =A0 =A0 =A0 sizeof(struct seccomp_data),
>
> I suppose this could be used to check for new fields if struct seccomp_da=
ta
> ever gets extended in the future.

Yeah since the only other indicator might be @arch.

>> + =A0 =A0 };
>> + =A0 =A0 const void *sc_ptr =3D (const void *)(uintptr_t)syscall;
>> +
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* All filters are evaluated in order of youngest to oldest.=
 The lowest
>> + =A0 =A0 =A0* BPF return value always takes priority.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 for (f =3D current->seccomp.filter; f; f =3D f->prev) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D bpf_run_filter(sc_ptr, f->insns, &fns)=
;
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (ret !=3D SECCOMP_RET_ALLOW)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 }
>> + =A0 =A0 return ret;
>> +}
>> +
>> +/**
>> + * seccomp_attach_filter: Attaches a seccomp filter to current.
>> + * @fprog: BPF program to install
>> + *
>> + * Returns 0 on success or an errno on failure.
>> + */
>> +static long seccomp_attach_filter(struct sock_fprog *fprog)
>> +{
>> + =A0 =A0 struct seccomp_filter *filter;
>> + =A0 =A0 unsigned long fp_size =3D fprog->len * sizeof(struct sock_filt=
er);
>> + =A0 =A0 long ret;
>> +
>> + =A0 =A0 if (fprog->len =3D=3D 0 || fprog->len > BPF_MAXINSNS)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
>> +
>> + =A0 =A0 /* Allocate a new seccomp_filter */
>> + =A0 =A0 filter =3D kzalloc(sizeof(struct seccomp_filter) + fp_size, GF=
P_KERNEL);
>> + =A0 =A0 if (!filter)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
>> + =A0 =A0 atomic_set(&filter->usage, 1);
>> + =A0 =A0 filter->len =3D fprog->len;
>> +
>> + =A0 =A0 /* Copy the instructions from fprog. */
>> + =A0 =A0 ret =3D -EFAULT;
>> + =A0 =A0 if (copy_from_user(filter->insns, fprog->filter, fp_size))
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> +
>> + =A0 =A0 /* Check the fprog */
>> + =A0 =A0 ret =3D bpf_chk_filter(filter->insns, filter->len, BPF_CHK_FLA=
GS_NO_SKB);
>> + =A0 =A0 if (ret)
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> +
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* Installing a seccomp filter requires that the task
>> + =A0 =A0 =A0* have CAP_SYS_ADMIN in its namespace or be running with
>> + =A0 =A0 =A0* no_new_privs. =A0This avoids scenarios where unprivileged
>> + =A0 =A0 =A0* tasks can affect the behavior of privileged children.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 ret =3D -EACCES;
>> + =A0 =A0 if (!current->no_new_privs &&
>> + =A0 =A0 =A0 =A0 security_capable_noaudit(current_cred(), current_user_=
ns(),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0CAP=
_SYS_ADMIN) !=3D 0)
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> +
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* If there is an existing filter, make it the prev
>> + =A0 =A0 =A0* and don't drop its task reference.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 filter->prev =3D current->seccomp.filter;
>> + =A0 =A0 current->seccomp.filter =3D filter;
>> + =A0 =A0 return 0;
>> +out:
>> + =A0 =A0 put_seccomp_filter(filter); =A0/* for get or task, on err */
>> + =A0 =A0 return ret;
>> +}
>> +
>> +/**
>> + * seccomp_attach_user_filter - attaches a user-supplied sock_fprog
>> + * @user_filter: pointer to the user data containing a sock_fprog.
>> + *
>> + * This function may be called repeatedly to install additional filters=
.
>> + * Every filter successfully installed will be evaluated (in reverse or=
der)
>> + * for each system call the task makes.
>> + *
>> + * Returns 0 on success and non-zero otherwise.
>> + */
>> +long seccomp_attach_user_filter(char __user *user_filter)
>> +{
>> + =A0 =A0 struct sock_fprog fprog;
>> + =A0 =A0 long ret =3D -EFAULT;
>> +
>> + =A0 =A0 if (!user_filter)
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> +#ifdef CONFIG_COMPAT
>> + =A0 =A0 if (is_compat_task()) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* XXX: Share with net/compat.c (compat_sock_f=
prog) */
>
> Then do so as part of your BPF sharing patch.

Makes sense. Queuing it up.

>> + =A0 =A0 =A0 =A0 =A0 =A0 struct {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u16 len;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 compat_uptr_t filter; =A0 /* s=
truct sock_filter */
>> + =A0 =A0 =A0 =A0 =A0 =A0 } fprog32;
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (copy_from_user(&fprog32, user_filter, size=
of(fprog32)))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> + =A0 =A0 =A0 =A0 =A0 =A0 fprog.len =3D fprog32.len;
>> + =A0 =A0 =A0 =A0 =A0 =A0 fprog.filter =3D compat_ptr(fprog32.filter);
>> + =A0 =A0 } else /* falls through to the if below. */
>> +#endif
>> + =A0 =A0 if (copy_from_user(&fprog, user_filter, sizeof(fprog)))
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> + =A0 =A0 ret =3D seccomp_attach_filter(&fprog);
>> +out:
>> + =A0 =A0 return ret;
>> +}
>> +
>> +/* get_seccomp_filter - increments the reference count of @orig. */
>> +static struct seccomp_filter *get_seccomp_filter(struct seccomp_filter =
*orig)
>> +{
>> + =A0 =A0 if (!orig)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>> + =A0 =A0 /* Reference count is bounded by the number of total processes=
. */
>> + =A0 =A0 atomic_inc(&orig->usage);
>> + =A0 =A0 return orig;
>> +}
>> +
>> +/* put_seccomp_filter - decrements the ref count of @orig and may free.=
 */
>> +void put_seccomp_filter(struct seccomp_filter *orig)
>> +{
>> + =A0 =A0 /* Clean up single-reference branches iteratively. */
>> + =A0 =A0 while (orig && atomic_dec_and_test(&orig->usage)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct seccomp_filter *freeme =3D orig;
>> + =A0 =A0 =A0 =A0 =A0 =A0 orig =3D orig->prev;
>> + =A0 =A0 =A0 =A0 =A0 =A0 kfree(freeme);
>> + =A0 =A0 }
>> +}
>> +
>> +/**
>> + * copy_seccomp: manages inheritance on fork
>> + * @child: forkee's seccomp
>> + * @prev: forker's seccomp
>> + *
>> + * Ensures that @child inherits seccomp mode and state if
>> + * seccomp filtering is in use.
>> + */
>> +void copy_seccomp(struct seccomp *child,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 const struct seccomp *prev)
>
> One line please.

Alright :)

>> +{
>> + =A0 =A0 child->mode =3D prev->mode;
>> + =A0 =A0 child->filter =3D get_seccomp_filter(prev->filter);
>> +}
>> +#endif =A0 =A0 =A0 /* CONFIG_SECCOMP_FILTER */
>>
>> /*
>> =A0* Secure computing mode 1 allows only read/write/exit/sigreturn.
>> @@ -34,10 +305,10 @@ static int mode1_syscalls_32[] =3D {
>> void __secure_computing(int this_syscall)
>> {
>> =A0 =A0 =A0 int mode =3D current->seccomp.mode;
>> - =A0 =A0 int * syscall;
>> + =A0 =A0 int *syscall;
>>
>> =A0 =A0 =A0 switch (mode) {
>> - =A0 =A0 case 1:
>> + =A0 =A0 case SECCOMP_MODE_STRICT:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 syscall =3D mode1_syscalls;
>> #ifdef CONFIG_COMPAT
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (is_compat_task())
>> @@ -48,6 +319,13 @@ void __secure_computing(int this_syscall)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 } while (*++syscall);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> +#ifdef CONFIG_SECCOMP_FILTER
>> + =A0 =A0 case SECCOMP_MODE_FILTER:
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (seccomp_run_filters(this_syscall) =3D=3D S=
ECCOMP_RET_ALLOW)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>> + =A0 =A0 =A0 =A0 =A0 =A0 seccomp_filter_log_failure(this_syscall);
>> + =A0 =A0 =A0 =A0 =A0 =A0 break;
>> +#endif
>> =A0 =A0 =A0 default:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG();
>> =A0 =A0 =A0 }
>> @@ -64,25 +342,34 @@ long prctl_get_seccomp(void)
>> =A0 =A0 =A0 return current->seccomp.mode;
>> }
>>
>> -long prctl_set_seccomp(unsigned long seccomp_mode)
>> +long prctl_set_seccomp(unsigned long seccomp_mode, char __user *filter)
>> {
>> - =A0 =A0 long ret;
>> + =A0 =A0 long ret =3D -EINVAL;
>>
>> - =A0 =A0 /* can set it only once to be even more secure */
>> - =A0 =A0 ret =3D -EPERM;
>> - =A0 =A0 if (unlikely(current->seccomp.mode))
>> + =A0 =A0 if (current->seccomp.mode &&
>> + =A0 =A0 =A0 =A0 current->seccomp.mode !=3D seccomp_mode)
>
> Wouldn't it make sense to allow going from mode 2 to 1?
> After all, the filter could have blocked it if it didn't
> want to permit it, and mode 1 is more restrictive than
> mode 2.

Nope - that might allow a downgrade that bypasses write/read
restrictions.  E.g., a filter could only allow a read to a certain buf
or of a certain size.  Allowing a downgrade would allow bypassing
those filters, whether they are the most sane things or not :)

>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>>
>> - =A0 =A0 ret =3D -EINVAL;
>> - =A0 =A0 if (seccomp_mode && seccomp_mode <=3D NR_SECCOMP_MODES) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 current->seccomp.mode =3D seccomp_mode;
>> - =A0 =A0 =A0 =A0 =A0 =A0 set_thread_flag(TIF_SECCOMP);
>> + =A0 =A0 switch (seccomp_mode) {
>> + =A0 =A0 case SECCOMP_MODE_STRICT:
>> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D 0;
>> #ifdef TIF_NOTSC
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 disable_TSC();
>> #endif
>> - =A0 =A0 =A0 =A0 =A0 =A0 ret =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 break;
>> +#ifdef CONFIG_SECCOMP_FILTER
>> + =A0 =A0 case SECCOMP_MODE_FILTER:
>> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D seccomp_attach_user_filter(filter);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (ret)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> + =A0 =A0 =A0 =A0 =A0 =A0 break;
>> +#endif
>> + =A0 =A0 default:
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> =A0 =A0 =A0 }
>>
>> - out:
>> + =A0 =A0 current->seccomp.mode =3D seccomp_mode;
>> + =A0 =A0 set_thread_flag(TIF_SECCOMP);
>> +out:
>> =A0 =A0 =A0 return ret;
>> }
>> diff --git a/kernel/sys.c b/kernel/sys.c
>> index 4070153..905031e 100644
>> --- a/kernel/sys.c
>> +++ b/kernel/sys.c
>> @@ -1899,7 +1899,7 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long,=
 arg2,
> unsigned long, arg3,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 error =3D prctl_get_seccomp(=
);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 case PR_SET_SECCOMP:
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 error =3D prctl_set_seccomp(ar=
g2);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 error =3D prctl_set_seccomp(ar=
g2, (char __user *)arg3);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 case PR_GET_TSC:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 error =3D GET_TSC_CTL(arg2);
>
> Out of curiosity, did you measure the kernel size differences before and
> after these patches? Would be sad if sharing it with the networking code
> didn't reduce the actual kernel size.

Oh yeah - it was a serious reduction.  Initially, seccomp_filter.o
added 8kb by itself.  With the merged seccomp.o, continued code
trimming (as suggested), and all the SECCOMP_RET_* variations, the
total kernel growth is 2972 bytes for the same kernel config.  This is
shared across ~2000 bytes in seccomp.o and ~800 bytes in filter.o.

Thanks!
will
