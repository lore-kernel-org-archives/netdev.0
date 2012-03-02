From: Will Drewry <wad@chromium.org>
Subject: Re: [kernel-hardening] Re: [PATCH v12 06/13] seccomp: add system call
 filtering using BPF
Date: Fri, 2 Mar 2012 12:44:41 -0600
Message-ID: <CABqD9habOw0kWWRVLqfrOS_5UFn+yw9eohrAw3f=vmy-AbQfdQ@mail.gmail.com>
References: <1330559620-23543-1-git-send-email-wad@chromium.org>
	<1330559620-23543-6-git-send-email-wad@chromium.org>
	<a6fdbe9d1daf6864589c9affc7048965.squirrel@webmail.greenhost.nl>
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
Received: from mail-bk0-f46.google.com ([209.85.214.46]:50455 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754539Ab2CBSoo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2012 13:44:44 -0500
Received: by bkcik5 with SMTP id ik5so1772333bkc.19
        for <netdev@vger.kernel.org>; Fri, 02 Mar 2012 10:44:43 -0800 (PST)
In-Reply-To: <a6fdbe9d1daf6864589c9affc7048965.squirrel@webmail.greenhost.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 1, 2012 at 11:45 PM, Indan Zupancic <indan@nul.nu> wrote:
> Hello,
>
> Mostly minor nitpicks.

Thanks!

> On Thu, March 1, 2012 00:53, Will Drewry wrote:
>> diff --git a/arch/Kconfig b/arch/Kconfig
>> index e5d3778..7a696a9 100644
>> --- a/arch/Kconfig
>> +++ b/arch/Kconfig
>> @@ -233,4 +233,21 @@ config HAVE_CMPXCHG_DOUBLE
>> config ARCH_WANT_OLD_COMPAT_IPC
>> =A0 =A0 =A0 bool
>>
>> +config HAVE_ARCH_SECCOMP_FILTER
>> + =A0 =A0 bool
>> + =A0 =A0 help
>> + =A0 =A0 =A0 This symbol should be selected by an architecure if it=
 provides
>
> 'architecture'

Oops

>> + =A0 =A0 =A0 asm/syscall.h, specifically syscall_get_arguments() an=
d
>> + =A0 =A0 =A0 syscall_get_arch().
>> +
>> +config SECCOMP_FILTER
>> + =A0 =A0 def_bool y
>> + =A0 =A0 depends on HAVE_ARCH_SECCOMP_FILTER && SECCOMP && NET
>> + =A0 =A0 help
>> + =A0 =A0 =A0 Enable tasks to build secure computing environments de=
fined
>> + =A0 =A0 =A0 in terms of Berkeley Packet Filter programs which impl=
ement
>> + =A0 =A0 =A0 task-defined system call filtering polices.
>> +
>> + =A0 =A0 =A0 See Documentation/prctl/seccomp_filter.txt for details=
=2E
>> +
>> source "kernel/gcov/Kconfig"
>> diff --git a/include/linux/Kbuild b/include/linux/Kbuild
>> index ecd0afb..b1e6a74 100644
>> --- a/include/linux/Kbuild
>> +++ b/include/linux/Kbuild
>> @@ -332,6 +332,7 @@ header-y +=3D scc.h
>> header-y +=3D sched.h
>> header-y +=3D screen_info.h
>> header-y +=3D sdla.h
>> +header-y +=3D seccomp.h
>> header-y +=3D securebits.h
>> header-y +=3D selinux_netlink.h
>> header-y +=3D sem.h
>> diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
>> index d61f27f..6ef133c 100644
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
>> +/* Valid values for seccomp.mode and prctl(PR_SET_SECCOMP, <mode>) =
*/
>> +#define SECCOMP_MODE_DISABLED =A0 =A0 =A0 =A00 /* seccomp is not in=
 use. */
>> +#define SECCOMP_MODE_STRICT =A01 /* uses hard-coded filter. */
>> +#define SECCOMP_MODE_FILTER =A02 /* uses user-supplied filter. */
>
> I'd add a space or tab to align the numbers, or rename DISABLED to NO=
NE,
> but that's just me I guess.
>
>> +
>> +/*
>> + * All BPF programs must return a 32-bit value.
>> + * The bottom 16-bits are reserved for future use.
>> + * The upper 16-bits are ordered from least permissive values to mo=
st.
>> + *
>> + * The ordering ensures that a min_t() over composed return values =
always
>> + * selects the least permissive choice.
>> + */
>> +#define SECCOMP_RET_KILL =A0 =A0 0x00000000U /* kill the task immed=
iately */
>> +#define SECCOMP_RET_ALLOW =A0 =A00x7fff0000U /* allow */
>> +
>> +/* Masks for the return value sections. */
>> +#define SECCOMP_RET_ACTION =A0 0xffff0000U
>> +#define SECCOMP_RET_DATA =A0 =A0 0x0000ffffU
>> +
>> +/**
>> + * struct seccomp_data - the format the BPF program executes over.
>
> format?

I'll reword - I meant that this is the format, or layout, of the data.

>> + * @nr: the system call number
>> + * @arch: indicates system call convention as an AUDIT_ARCH_* value
>> + * =A0 =A0 =A0 =A0as defined in <linux/audit.h>.
>> + * @instruction_pointer: at the time of the system call.
>
> If the vDSO is used this will always be the same, so what good is thi=
s?
> I haven't gotten an answer to this yet.
>
> That said, it's eays enough to add, I just don't see the point of it.

[refers to rest of thread :]

>> + * @args: up to 6 system call arguments always stored as 64-bit val=
ues
>> + * =A0 =A0 =A0 =A0regardless of the architecture.
>> + */
>> +struct seccomp_data {
>> + =A0 =A0 int nr;
>> + =A0 =A0 __u32 arch;
>> + =A0 =A0 __u64 instruction_pointer;
>> + =A0 =A0 __u64 args[6];
>> +};
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
>> + * @filter: The metadata and ruleset for determining what system ca=
lls
>> + * =A0 =A0 =A0 =A0 =A0are allowed for a task.
>> + *
>> + * =A0 =A0 =A0 =A0 =A0@filter must only be accessed from the contex=
t of current as there
>
> I'd move 'as there' to the next line.

Done

>> + * =A0 =A0 =A0 =A0 =A0is no locking.
>> + */
>> struct seccomp {
>> =A0 =A0 =A0 int mode;
>> + =A0 =A0 struct seccomp_filter *filter;
>> };
>
> If the extra memory usage is a problem, a union could be used:
>
> union seccomp {
> =A0 =A0 =A0 =A0long mode;
> =A0 =A0 =A0 =A0struct seccomp_filter *filter;
> };
>
> That way mode is 0 when it's disabled, 1 for SECCOMP_MODE_STRICT and
> a pointer for SECCOMP_MODE_FILTER.

I haven't heard any specific complaints about the extra unsigned long,
but if so, we could do this.  It would make me a bit uneasy even
though it should be safe in practice.

>>
>> extern void __secure_computing(int);
>> @@ -19,7 +72,7 @@ static inline void secure_computing(int this_sysca=
ll)
>> }
>>
>> extern long prctl_get_seccomp(void);
>> -extern long prctl_set_seccomp(unsigned long);
>> +extern long prctl_set_seccomp(unsigned long, char __user *);
>>
>> static inline int seccomp_mode(struct seccomp *s)
>> {
>> @@ -31,15 +84,16 @@ static inline int seccomp_mode(struct seccomp *s=
)
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
>> +static inline long prctl_set_seccomp(unsigned long arg2, char __use=
r *arg3)
>> {
>> =A0 =A0 =A0 return -EINVAL;
>> }
>> @@ -48,7 +102,15 @@ static inline int seccomp_mode(struct seccomp *s=
)
>> {
>> =A0 =A0 =A0 return 0;
>> }
>> -
>> #endif /* CONFIG_SECCOMP */
>>
>> +#ifdef CONFIG_SECCOMP_FILTER
>> +extern void put_seccomp_filter(struct seccomp_filter *);
>> +extern void get_seccomp_filter(struct seccomp_filter *);
>> +#else =A0/* CONFIG_SECCOMP_FILTER */
>> +/* These macros consume the seccomp.filter reference. */
>
> I think it's cleaner to let put/get_seccomp_filter have struct task*
> as a parameter instead of the filter.
>
>> +#define put_seccomp_filter(_s) do { } while (0)
>> +#define get_seccomp_filter(_s) do { } while (0)
>> +#endif /* CONFIG_SECCOMP_FILTER */
>> +#endif /* __KERNEL__ */
>> #endif /* _LINUX_SECCOMP_H */
>> diff --git a/kernel/fork.c b/kernel/fork.c
>> index b18c107..da3e489 100644
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
>> @@ -171,6 +172,7 @@ void free_task(struct task_struct *tsk)
>> =A0 =A0 =A0 free_thread_info(tsk->stack);
>> =A0 =A0 =A0 rt_mutex_debug_task_free(tsk);
>> =A0 =A0 =A0 ftrace_graph_exit_task(tsk);
>> + =A0 =A0 put_seccomp_filter(tsk->seccomp.filter);
>> =A0 =A0 =A0 free_task_struct(tsk);
>> }
>> EXPORT_SYMBOL(free_task);
>> @@ -1166,6 +1168,7 @@ static struct task_struct *copy_process(unsign=
ed long clone_flags,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto fork_out;
>>
>> =A0 =A0 =A0 ftrace_graph_init_task(p);
>> + =A0 =A0 get_seccomp_filter(p->seccomp.filter);
>>
>> =A0 =A0 =A0 rt_mutex_init_task(p);
>>
>> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
>> index e8d76c5..71df324 100644
>> --- a/kernel/seccomp.c
>> +++ b/kernel/seccomp.c
>> @@ -3,16 +3,272 @@
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
>> + * =A0 =A0 =A0 =A0 get/put helpers should be used when accessing an=
 instance
>> + * =A0 =A0 =A0 =A0 outside of a lifetime-guarded section. =A0In gen=
eral, this
>> + * =A0 =A0 =A0 =A0 is only needed for handling filters shared acros=
s tasks.
>> + * @prev: points to a previously installed, or inherited, filter
>> + * @insns: the BPF program instructions to evaluate
>> + * @len: the number of instructions in the program
>> + *
>> + * seccomp_filter objects are organized in a tree linked via the @p=
rev
>> + * pointer. =A0For any task, it appears to be a singly-linked list =
starting
>> + * with current->seccomp.filter, the most recently attached or inhe=
rited filter.
>> + * However, multiple filters may share a @prev node, by way of fork=
(), which
>> + * results in a unidirectional tree existing in memory. =A0This is =
similar to
>> + * how namespaces work.
>> + *
>> + * seccomp_filter objects should never be modified after being atta=
ched
>> + * to a task_struct (other than @usage).
>> + */
>> +struct seccomp_filter {
>> + =A0 =A0 atomic_t usage;
>> + =A0 =A0 struct seccomp_filter *prev;
>> + =A0 =A0 unsigned short len; =A0/* Instruction count */
>
> To avoid 4 bytes of the padding on 64-bit, you could move len to just=
 after
> atomic_t, which is an int.

Good call.

>> + =A0 =A0 struct sock_filter insns[];
>> +};
>> +
>> +/* Limit any path through the tree to 5 megabytes worth of instruct=
ions. */
>> +#define MAX_INSNS_PER_PATH ((5 << 20) / sizeof(struct sock_filter))
>
> I think this is too high, that are 160 filters with max instruction l=
ength.
>
> I vote for a 1MB or lower limit, that's 32 filters with max size.

1MB is fine.  My goal is just to protect the system from total
resource exhaustion

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
>
> Hm, I thought everyone agreed this wasn't really necessary?

Yep - instead of just fixing it up, I included Kees's patch in the patc=
h series.

>> +
>> +/**
>> + * get_u32 - returns a u32 offset into data
>
> It doesn't return an offset.

True enough

>> + * @data: a unsigned 64 bit value
>
> Well, yes, it's a u64.

I'm glad we agree :)
>> + * @index: 0 or 1 to return the first or second 32-bits
>> + *
>> + * This inline exists to hide the length of unsigned long.
>
> and to get the upper half of it.
>
>> + * If a 32-bit unsigned long is passed in, it will be extended
>> + * and the top 32-bits will be 0. If it is a 64-bit unsigned
>> + * long, then whatever data is resident will be properly returned.
>> + */
>
> Personally I would leave out the whole comment, because reading the
> two lines of code is faster and gives the same info.

Sounds good.

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
>> + * @off: offset into struct seccomp_data to load from (must be u32 =
aligned)
>> + * @size: number of bytes to load (must be 4 bytes)
>> + * @buf: temporary storage supplied by bpf_run_filter (4 bytes)
>> + *
>> + * Returns a pointer to the loaded data (usually @buf).
>> + * On failure, returns NULL.
>> + */
>> +static void *bpf_load(const void *nr, int off, unsigned int size, v=
oid *buf)
>> +{
>> + =A0 =A0 unsigned long value;
>> + =A0 =A0 u32 *A =3D buf;
>> +
>> + =A0 =A0 if (size !=3D sizeof(u32) || off % sizeof(u32))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>> +
>> + =A0 =A0 if (off >=3D BPF_DATA(args[0]) && off < BPF_DATA(args[6]))=
 {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct pt_regs *regs =3D task_pt_regs(curr=
ent);
>> + =A0 =A0 =A0 =A0 =A0 =A0 int arg =3D (off - BPF_DATA(args[0])) / si=
zeof(u64);
>> + =A0 =A0 =A0 =A0 =A0 =A0 int index =3D (off % sizeof(u64)) ? 1 : 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 syscall_get_arguments(current, regs, arg, =
1, &value);
>> + =A0 =A0 =A0 =A0 =A0 =A0 *A =3D get_u32(value, index);
>> + =A0 =A0 } else if (off =3D=3D BPF_DATA(nr)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 *A =3D (u32)(uintptr_t)nr;
>> + =A0 =A0 } else if (off =3D=3D BPF_DATA(arch)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct pt_regs *regs =3D task_pt_regs(curr=
ent);
>> + =A0 =A0 =A0 =A0 =A0 =A0 *A =3D syscall_get_arch(current, regs);
>> + =A0 =A0 } else if (off =3D=3D BPF_DATA(instruction_pointer)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 *A =3D get_u32(KSTK_EIP(current), 0);
>> + =A0 =A0 } else if (off =3D=3D BPF_DATA(instruction_pointer) + size=
of(u32)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 *A =3D get_u32(KSTK_EIP(current), 1);
>> + =A0 =A0 } else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>> + =A0 =A0 }
>> + =A0 =A0 return buf;
>> +}
>
> The interface doesn't match, the alignment doesn't match, and the LD
> instructions couldn't be reused, with code size and even slowdowns in
> the networking filter code as a result. I have the impression this
> isn't the best approach after all.
>
> I'm going to take a look at implementing it as anscillary data access=
es
> instead of generic loads. That hopefully reduces the code churn in fi=
lter.c
> a lot.

Your alternative approach is nice. I guess it all depends on what
makes sense to netdev too.  Perhaps Eric Dumazet or someone from
netdev can weigh in on it.

>> +
>> +/**
>> + * seccomp_run_filters - evaluates all seccomp filters against @sys=
call
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
>> + =A0 =A0 };
>> + =A0 =A0 const void *sc_ptr =3D (const void *)(uintptr_t)syscall;
>> +
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* All filters are evaluated in order of youngest to old=
est. The lowest
>> + =A0 =A0 =A0* BPF return value always takes priority.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 for (f =3D current->seccomp.filter; f; f =3D f->prev) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D bpf_run_filter(sc_ptr, f->insns, &=
fns);
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
>> + =A0 =A0 unsigned long fp_size =3D fprog->len * sizeof(struct sock_=
filter);
>> + =A0 =A0 unsigned long total_insns =3D fprog->len;
>> + =A0 =A0 long ret;
>> +
>> + =A0 =A0 if (fprog->len =3D=3D 0 || fprog->len > BPF_MAXINSNS)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
>> +
>> + =A0 =A0 /* Walk the list to ensure the new instruction count is al=
lowed. */
>> + =A0 =A0 for (filter =3D current->seccomp.filter; filter; filter =3D=
 filter->prev) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (total_insns > MAX_INSNS_PER_PATH - fil=
ter->len)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -E2BIG;
>> + =A0 =A0 =A0 =A0 =A0 =A0 total_insns +=3D filter->len;
>> + =A0 =A0 }
>
> Now you go over the limit once before that if check is ever true, and=
 it can
> only be true for the last filter. So take it out of the loop, that ma=
kes the
> code clearer, faster and more correct.

I'll make it clearer.  Correctness should be maintained in either case.

> I'm not sure E2BIG ("Argument list too long") is the best return valu=
e.
> ENOMEM seems more fitting, because it's not this filter's instruction
> length that's too long, it's the combined filters that are taking too
> much memory.

Ah yeah - wrong one.  What about ENOSPC?  It'd be nice to
differentiate this from an actual out of memory condition even though
there is no seccomp filter "device".  (Alternatively EACCES, EBUSY,
EFBIG, ?)

>> +
>> + =A0 =A0 /* Allocate a new seccomp_filter */
>> + =A0 =A0 filter =3D kzalloc(sizeof(struct seccomp_filter) + fp_size=
, GFP_KERNEL);
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
>> + =A0 =A0 ret =3D bpf_chk_filter(filter->insns, filter->len, BPF_CHK=
_FLAGS_NO_SKB);
>> + =A0 =A0 if (ret)
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> +
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* Installing a seccomp filter requires that the task ha=
ve
>> + =A0 =A0 =A0* CAP_SYS_ADMIN in its namespace or be running with no_=
new_privs.
>> + =A0 =A0 =A0* This avoids scenarios where unprivileged tasks can af=
fect the
>> + =A0 =A0 =A0* behavior of privileged children.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 ret =3D -EACCES;
>> + =A0 =A0 if (!current->no_new_privs &&
>> + =A0 =A0 =A0 =A0 security_capable_noaudit(current_cred(), current_u=
ser_ns(),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
CAP_SYS_ADMIN) !=3D 0)
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>
> I think this check should be done first, before allocating any memory=
=2E

Makes sense.

>> +
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* If there is an existing filter, make it the prev and =
don't drop its
>> + =A0 =A0 =A0* task reference.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 filter->prev =3D current->seccomp.filter;
>> + =A0 =A0 current->seccomp.filter =3D filter;
>> + =A0 =A0 return 0;
>> +out:
>> + =A0 =A0 put_seccomp_filter(filter); =A0/* for get or task, on err =
*/
>
> Let put_seccomp_filter() take a struct task* as argument and instead =
of
> calling it here, just do a kfree() directly. That's more symmetrical =
too.

That'll let them be static inlines instead of macros then, so that's go=
od.

>> + =A0 =A0 return ret;
>> +}
>> +
>> +/**
>> + * seccomp_attach_user_filter - attaches a user-supplied sock_fprog
>> + * @user_filter: pointer to the user data containing a sock_fprog.
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
>
> Isn't this checked by copy_from_user() already?

Not explicitly. I think it's safer to check before calling copy_from_us=
er.

>> +#ifdef CONFIG_COMPAT
>> + =A0 =A0 if (is_compat_task()) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct compat_sock_fprog fprog32;
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (copy_from_user(&fprog32, user_filter, =
sizeof(fprog32)))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> + =A0 =A0 =A0 =A0 =A0 =A0 fprog.len =3D fprog32.len;
>> + =A0 =A0 =A0 =A0 =A0 =A0 fprog.filter =3D compat_ptr(fprog32.filter=
);
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
>> +void get_seccomp_filter(struct seccomp_filter *orig)
>> +{
>> + =A0 =A0 if (!orig)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return;
>> + =A0 =A0 /* Reference count is bounded by the number of total proce=
sses. */
>> + =A0 =A0 atomic_inc(&orig->usage);
>> +}
>> +
>> +/* put_seccomp_filter - decrements the ref count of @orig and may f=
ree. */
>> +void put_seccomp_filter(struct seccomp_filter *orig)
>> +{
>> + =A0 =A0 /* Clean up single-reference branches iteratively. */
>> + =A0 =A0 while (orig && atomic_dec_and_test(&orig->usage)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct seccomp_filter *freeme =3D orig;
>> + =A0 =A0 =A0 =A0 =A0 =A0 orig =3D orig->prev;
>> + =A0 =A0 =A0 =A0 =A0 =A0 kfree(freeme);
>> + =A0 =A0 }
>> +}
>> +#endif =A0 =A0 =A0 /* CONFIG_SECCOMP_FILTER */
>>
>> /*
>> =A0* Secure computing mode 1 allows only read/write/exit/sigreturn.
>> @@ -34,10 +290,11 @@ static int mode1_syscalls_32[] =3D {
>> void __secure_computing(int this_syscall)
>> {
>> =A0 =A0 =A0 int mode =3D current->seccomp.mode;
>> - =A0 =A0 int * syscall;
>> + =A0 =A0 int exit_code =3D SIGKILL;
>> + =A0 =A0 int *syscall;
>>
>> =A0 =A0 =A0 switch (mode) {
>> - =A0 =A0 case 1:
>> + =A0 =A0 case SECCOMP_MODE_STRICT:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 syscall =3D mode1_syscalls;
>> #ifdef CONFIG_COMPAT
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (is_compat_task())
>> @@ -48,6 +305,14 @@ void __secure_computing(int this_syscall)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 } while (*++syscall);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> +#ifdef CONFIG_SECCOMP_FILTER
>> + =A0 =A0 case SECCOMP_MODE_FILTER:
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (seccomp_run_filters(this_syscall) =3D=3D=
 SECCOMP_RET_ALLOW)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>> + =A0 =A0 =A0 =A0 =A0 =A0 seccomp_filter_log_failure(this_syscall);
>> + =A0 =A0 =A0 =A0 =A0 =A0 exit_code =3D SIGSYS;
>> + =A0 =A0 =A0 =A0 =A0 =A0 break;
>> +#endif
>> =A0 =A0 =A0 default:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG();
>> =A0 =A0 =A0 }
>> @@ -56,7 +321,7 @@ void __secure_computing(int this_syscall)
>> =A0 =A0 =A0 dump_stack();
>> #endif
>> =A0 =A0 =A0 audit_seccomp(this_syscall);
>> - =A0 =A0 do_exit(SIGKILL);
>> + =A0 =A0 do_exit(exit_code);
>> }
>>
>> long prctl_get_seccomp(void)
>> @@ -64,25 +329,48 @@ long prctl_get_seccomp(void)
>> =A0 =A0 =A0 return current->seccomp.mode;
>> }
>>
>> -long prctl_set_seccomp(unsigned long seccomp_mode)
>> +/**
>> + * prctl_set_seccomp: configures current->seccomp.mode
>> + * @seccomp_mode: requested mode to use
>> + * @filter: optional struct sock_fprog for use with SECCOMP_MODE_FI=
LTER
>> + *
>> + * This function may be called repeatedly with a @seccomp_mode of
>> + * SECCOMP_MODE_FILTER to install additional filters. =A0Every filt=
er
>> + * successfully installed will be evaluated (in reverse order) for =
each system
>
> I'd move the 'each system' to the next line.
>
>> + * call the task makes.
>> + *
>> + * Once current->seccomp.mode is non-zero, it may not be changed.
>> + *
>> + * Returns 0 on success or -EINVAL on failure.
>> + */
>> +long prctl_set_seccomp(unsigned long seccomp_mode, char __user *fil=
ter)
>> {
>> - =A0 =A0 long ret;
>> + =A0 =A0 long ret =3D -EINVAL;
>>
>> - =A0 =A0 /* can set it only once to be even more secure */
>> - =A0 =A0 ret =3D -EPERM;
>> - =A0 =A0 if (unlikely(current->seccomp.mode))
>> + =A0 =A0 if (current->seccomp.mode &&
>> + =A0 =A0 =A0 =A0 current->seccomp.mode !=3D seccomp_mode)
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
>> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D seccomp_attach_user_filter(filter)=
;
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
>> index 4686119..0addc11 100644
>> --- a/kernel/sys.c
>> +++ b/kernel/sys.c
>> @@ -1955,7 +1955,7 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned l=
ong, arg2,
> unsigned long, arg3,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 error =3D prctl_get_secc=
omp();
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 case PR_SET_SECCOMP:
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 error =3D prctl_set_seccom=
p(arg2);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 error =3D prctl_set_seccom=
p(arg2, (char __user *)arg3);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 case PR_GET_TSC:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 error =3D GET_TSC_CTL(ar=
g2);
>> --
>
> Reviewed-by: Indan Zupancic <indan@nul.nu>

Thanks!
will
