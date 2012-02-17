From: Will Drewry <wad@chromium.org>
Subject: Re: [kernel-hardening] Re: [PATCH v8 3/8] seccomp: add system call
 filtering using BPF
Date: Thu, 16 Feb 2012 21:38:26 -0600
Message-ID: <CABqD9ha=TOs2w3GhnpYJ+vbt=Lwzn447hFdODpNgf5gQY4fgvg@mail.gmail.com>
References: <1329422549-16407-1-git-send-email-wad@chromium.org>
	<1329422549-16407-3-git-send-email-wad@chromium.org>
	<a69a2094a5b5bcbd1f042563197382f8.squirrel@webmail.greenhost.nl>
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
	markus@chromium.org, keescook@chromium.org
To: kernel-hardening@lists.openwall.com
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <a69a2094a5b5bcbd1f042563197382f8.squirrel@webmail.greenhost.nl>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 16, 2012 at 8:44 PM, Indan Zupancic <indan@nul.nu> wrote:
> On Thu, February 16, 2012 21:02, Will Drewry wrote:
>> [This patch depends on luto@mit.edu's no_new_privs patch:
>> =A0https://lkml.org/lkml/2012/1/30/264
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
>> =A0 struct sock_fprog fprog =3D { ... };
>> =A0 ...
>> =A0 prctl(PR_SET_SECCOMP, 2, &fprog);
>
> Please add an arg to tell the filter mode.

Hrm? Do you mean SECCOMP_MODE_FILTER?  I'll update the changelog to
include that.

>>
>> The return value of the filter program determines if the system call=
 is
>> allowed to proceed or denied. =A0If the first filter program install=
ed
>> allows prctl(2) calls, then the above call may be made repeatedly
>> by a task to further reduce its access to the kernel. =A0All attache=
d
>> programs must be evaluated before a system call will be allowed to
>> proceed.
>>
>> To avoid CONFIG_COMPAT related landmines, once a filter program is
>> installed using specific is_compat_task() value, it is not allowed t=
o
>> make system calls using the alternate entry point.
>
> Just allow paths with a filter and deny paths without a filter instal=
led.

Not sure what that means, but given the feedback today, I'm just
adding a calling convention u32 so this code all disappears.

>> Filter programs will be inherited across fork/clone and execve.
>> However, if the task attaching the filter is unprivileged
>> (!CAP_SYS_ADMIN) the no_new_privs bit will be set on the task. =A0Th=
is
>> ensures that unprivileged tasks cannot attach filters that affect
>> privileged tasks (e.g., setuid binary).
>>
>> There are a number of benefits to this approach. A few of which are
>> as follows:
>> - BPF has been exposed to userland for a long time
>> - BPF optimization (and JIT'ing) are well understood
>> - Userland already knows its ABI: system call numbers and desired
>> =A0 arguments
>> - No time-of-check-time-of-use vulnerable data accesses are possible=
=2E
>> - system call arguments are loaded on access only to minimize copyin=
g
>> =A0 required for system call policy decisions.
>>
>> Mode 2 support is restricted to architectures that enable
>> HAVE_ARCH_SECCOMP_FILTER. =A0In this patch, the primary dependency i=
s on
>> syscall_get_arguments(). =A0The full desired scope of this feature w=
ill
>> add a few minor additional requirements expressed later in this seri=
es.
>> Based on discussion, SECCOMP_RET_ERRNO and SECCOMP_RET_TRACE seem to=
 be
>> the desired additional functionality.
>>
>> No architectures are enabled in this patch.
>>
>> =A0v8: - use bpf_chk_filter, bpf_run_filter. update load_fns
>> =A0 =A0 =A0- Lots of fixes courtesy of indan@nul.nu:
>> =A0 =A0 =A0-- fix up load behavior, compat fixups, and merge alloc c=
ode,
>> =A0 =A0 =A0-- renamed pc and dropped __packed, use bool compat.
>> =A0 =A0 =A0-- Added a hidden CONFIG_SECCOMP_FILTER to synthesize non=
-arch
>> =A0 =A0 =A0 =A0 dependencies
>> =A0v7: =A0(massive overhaul thanks to Indan, others)
>> =A0 =A0 =A0- added CONFIG_HAVE_ARCH_SECCOMP_FILTER
>> =A0 =A0 =A0- merged into seccomp.c
>> =A0 =A0 =A0- minimal seccomp_filter.h
>> =A0 =A0 =A0- no config option (part of seccomp)
>> =A0 =A0 =A0- no new prctl
>> =A0 =A0 =A0- doesn't break seccomp on systems without asm/syscall.h
>> =A0 =A0 =A0 =A0(works but arg access always fails)
>> =A0 =A0 =A0- dropped seccomp_init_task, extra free functions, ...
>> =A0 =A0 =A0- dropped the no-asm/syscall.h code paths
>> =A0 =A0 =A0- merges with network sk_run_filter and sk_chk_filter
>> =A0v6: - fix memory leak on attach compat check failure
>> =A0 =A0 =A0- require no_new_privs || CAP_SYS_ADMIN prior to filter
>> =A0 =A0 =A0 =A0installation. (luto@mit.edu)
>> =A0 =A0 =A0- s/seccomp_struct_/seccomp_/ for macros/functions (amwan=
g@redhat.com)
>> =A0 =A0 =A0- cleaned up Kconfig (amwang@redhat.com)
>> =A0 =A0 =A0- on block, note if the call was compat (so the # means s=
omething)
>> =A0v5: - uses syscall_get_arguments
>> =A0 =A0 =A0 =A0(indan@nul.nu,oleg@redhat.com, mcgrathr@chromium.org)
>> =A0 =A0 =A0 - uses union-based arg storage with hi/lo struct to
>> =A0 =A0 =A0 =A0 handle endianness. =A0Compromises between the two al=
ternate
>> =A0 =A0 =A0 =A0 proposals to minimize extra arg shuffling and accoun=
t for
>> =A0 =A0 =A0 =A0 endianness assuming userspace uses offsetof().
>> =A0 =A0 =A0 =A0 (mcgrathr@chromium.org, indan@nul.nu)
>> =A0 =A0 =A0 - update Kconfig description
>> =A0 =A0 =A0 - add include/seccomp_filter.h and add its installation
>> =A0 =A0 =A0 - (naive) on-demand syscall argument loading
>> =A0 =A0 =A0 - drop seccomp_t (eparis@redhat.com)
>> =A0v4: =A0- adjusted prctl to make room for PR_[SG]ET_NO_NEW_PRIVS
>> =A0 =A0 =A0 - now uses current->no_new_privs
>> =A0 =A0 =A0 =A0 (luto@mit.edu,torvalds@linux-foundation.com)
>> =A0 =A0 =A0 - assign names to seccomp modes (rdunlap@xenotime.net)
>> =A0 =A0 =A0 - fix style issues (rdunlap@xenotime.net)
>> =A0 =A0 =A0 - reworded Kconfig entry (rdunlap@xenotime.net)
>> =A0v3: =A0- macros to inline (oleg@redhat.com)
>> =A0 =A0 =A0 - init_task behavior fixed (oleg@redhat.com)
>> =A0 =A0 =A0 - drop creator entry and extra NULL check (oleg@redhat.c=
om)
>> =A0 =A0 =A0 - alloc returns -EINVAL on bad sizing (serge.hallyn@cano=
nical.com)
>> =A0 =A0 =A0 - adds tentative use of "always_unprivileged" as per
>> =A0 =A0 =A0 =A0 torvalds@linux-foundation.org and luto@mit.edu
>> =A0v2: =A0- (patch 2 only)
>>
>> Signed-off-by: Will Drewry <wad@chromium.org>
>> ---
>> =A0arch/Kconfig =A0 =A0 =A0 =A0 =A0 =A0| =A0 17 +++
>> =A0include/linux/Kbuild =A0 =A0| =A0 =A01 +
>> =A0include/linux/seccomp.h | =A0 69 ++++++++++-
>> =A0kernel/fork.c =A0 =A0 =A0 =A0 =A0 | =A0 =A03 +
>> =A0kernel/seccomp.c =A0 =A0 =A0 =A0| =A0327 ++++++++++++++++++++++++=
++++++++++++++++++++--
>> =A0kernel/sys.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +-
>> =A06 files changed, 399 insertions(+), 20 deletions(-)
>>
>> diff --git a/arch/Kconfig b/arch/Kconfig
>> index 4f55c73..c6ba1db 100644
>> --- a/arch/Kconfig
>> +++ b/arch/Kconfig
>> @@ -199,4 +199,21 @@ config HAVE_CMPXCHG_LOCAL
>> =A0config HAVE_CMPXCHG_DOUBLE
>> =A0 =A0 =A0 bool
>>
>> +config HAVE_ARCH_SECCOMP_FILTER
>> + =A0 =A0 bool
>> + =A0 =A0 help
>> + =A0 =A0 =A0 This symbol should be selected by an architecure if it=
 provides
>> + =A0 =A0 =A0 asm/syscall.h, specifically syscall_get_arguments().
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
>> + =A0 =A0 =A0 See Documentation/prctl/seccomp_filter.txt for more
>> + =A0 =A0 =A0 information on the topic of seccomp filtering.
>> +
>> =A0source "kernel/gcov/Kconfig"
>> diff --git a/include/linux/Kbuild b/include/linux/Kbuild
>> index c94e717..d41ba12 100644
>> --- a/include/linux/Kbuild
>> +++ b/include/linux/Kbuild
>> @@ -330,6 +330,7 @@ header-y +=3D scc.h
>> =A0header-y +=3D sched.h
>> =A0header-y +=3D screen_info.h
>> =A0header-y +=3D sdla.h
>> +header-y +=3D seccomp.h
>> =A0header-y +=3D securebits.h
>> =A0header-y +=3D selinux_netlink.h
>> =A0header-y +=3D sem.h
>> diff --git a/include/linux/seccomp.h b/include/linux/seccomp.h
>> index d61f27f..2bee1f7 100644
>> --- a/include/linux/seccomp.h
>> +++ b/include/linux/seccomp.h
>> @@ -1,14 +1,60 @@
>> =A0#ifndef _LINUX_SECCOMP_H
>> =A0#define _LINUX_SECCOMP_H
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
>> +
>> +/*
>> + * BPF programs may return a 32-bit value.
>> + * The bottom 16-bits are reserved for future use.
>> + * The upper 16-bits are ordered from least permissive values to mo=
st.
>> + *
>> + * The ordering ensures that a min_t() over composed return values =
always
>> + * selects the least permissive choice.
>> + */
>> +#define SECCOMP_RET_MASK =A0 =A0 0xffff0000U
>> +#define SECCOMP_RET_KILL =A0 =A0 0x00000000U /* kill the task immed=
iately */
>> +#define SECCOMP_RET_ALLOW =A0 =A00x7fff0000U /* allow */
>> +
>> +/* Format of the data the BPF program executes over. */
>> +struct seccomp_data {
>> + =A0 =A0 int nr;
>> + =A0 =A0 __u32 __reserved[3];
>> + =A0 =A0 struct {
>> + =A0 =A0 =A0 =A0 =A0 =A0 __u32 =A0 lo;
>> + =A0 =A0 =A0 =A0 =A0 =A0 __u32 =A0 hi;
>> + =A0 =A0 } instruction_pointer;
>> + =A0 =A0 __u32 lo32[6];
>> + =A0 =A0 __u32 hi32[6];
>> +};
>
> I wouldn't use a struct for the IP. And I'd move the args to the fron=
t.

I'd left it at the end for future expansion, but I think that that
will have to be dealt with differently when it comes, so I'll reorder.

> Why not call it something with "arg" in the names?

Changing this related to the comments on the thread, but however it
ends up, I'll add some mention of args!

>>
>> +#ifdef __KERNEL__
>> =A0#ifdef CONFIG_SECCOMP
>>
>> =A0#include <linux/thread_info.h>
>> =A0#include <asm/seccomp.h>
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
>> + * =A0 =A0 =A0 =A0 =A0is no locking.
>> + */
>> =A0struct seccomp {
>> =A0 =A0 =A0 int mode;
>> + =A0 =A0 struct seccomp_filter *filter;
>> =A0};
>>
>> =A0extern void __secure_computing(int);
>> @@ -19,7 +65,7 @@ static inline void secure_computing(int this_sysca=
ll)
>> =A0}
>>
>> =A0extern long prctl_get_seccomp(void);
>> -extern long prctl_set_seccomp(unsigned long);
>> +extern long prctl_set_seccomp(unsigned long, char __user *);
>>
>> =A0static inline int seccomp_mode(struct seccomp *s)
>> =A0{
>> @@ -31,15 +77,16 @@ static inline int seccomp_mode(struct seccomp *s=
)
>> =A0#include <linux/errno.h>
>>
>> =A0struct seccomp { };
>> +struct seccomp_filter { };
>>
>> -#define secure_computing(x) do { } while (0)
>> +#define secure_computing(x) 0
>>
>> =A0static inline long prctl_get_seccomp(void)
>> =A0{
>> =A0 =A0 =A0 return -EINVAL;
>> =A0}
>>
>> -static inline long prctl_set_seccomp(unsigned long arg2)
>> +static inline long prctl_set_seccomp(unsigned long arg2, char __use=
r *arg3)
>> =A0{
>> =A0 =A0 =A0 return -EINVAL;
>> =A0}
>> @@ -48,7 +95,21 @@ static inline int seccomp_mode(struct seccomp *s)
>> =A0{
>> =A0 =A0 =A0 return 0;
>> =A0}
>> -
>> =A0#endif /* CONFIG_SECCOMP */
>>
>> +#ifdef CONFIG_SECCOMP_FILTER
>> +extern void put_seccomp_filter(struct seccomp_filter *);
>> +extern void copy_seccomp(struct seccomp *child,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const struct seccomp *p=
arent);
>> +#else =A0/* CONFIG_SECCOMP_FILTER */
>> +/* The macro consumes the ->filter reference. */
>> +#define put_seccomp_filter(_s) do { } while (0)
>> +
>> +static inline void copy_seccomp(struct seccomp *child,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const stru=
ct seccomp *prev)
>> +{
>> + =A0 =A0 return;
>> +}
>
> Why a macro for one but an empty inline for the other?

As the comment mentions, it consumes the reference.
put_seccomp_filter operates on current->seccomp.filter, but filter
doesn't exist if !CONFIG_SECCOMP_FILTER. So the macro eats it if not
defined.  However, inlines are preferred style, so I used one for
copy_seccomp.

>> +#endif /* CONFIG_SECCOMP_FILTER */
>> +#endif /* __KERNEL__ */
>> =A0#endif /* _LINUX_SECCOMP_H */
>> diff --git a/kernel/fork.c b/kernel/fork.c
>> index b77fd55..a5187b7 100644
>> --- a/kernel/fork.c
>> +++ b/kernel/fork.c
>> @@ -34,6 +34,7 @@
>> =A0#include <linux/cgroup.h>
>> =A0#include <linux/security.h>
>> =A0#include <linux/hugetlb.h>
>> +#include <linux/seccomp.h>
>> =A0#include <linux/swap.h>
>> =A0#include <linux/syscalls.h>
>> =A0#include <linux/jiffies.h>
>> @@ -169,6 +170,7 @@ void free_task(struct task_struct *tsk)
>> =A0 =A0 =A0 free_thread_info(tsk->stack);
>> =A0 =A0 =A0 rt_mutex_debug_task_free(tsk);
>> =A0 =A0 =A0 ftrace_graph_exit_task(tsk);
>> + =A0 =A0 put_seccomp_filter(tsk->seccomp.filter);
>> =A0 =A0 =A0 free_task_struct(tsk);
>> =A0}
>> =A0EXPORT_SYMBOL(free_task);
>> @@ -1113,6 +1115,7 @@ static struct task_struct *copy_process(unsign=
ed long clone_flags,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto fork_out;
>>
>> =A0 =A0 =A0 ftrace_graph_init_task(p);
>> + =A0 =A0 copy_seccomp(&p->seccomp, &current->seccomp);
>>
>> =A0 =A0 =A0 rt_mutex_init_task(p);
>>
>> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
>> index e8d76c5..14d1869 100644
>> --- a/kernel/seccomp.c
>> +++ b/kernel/seccomp.c
>> @@ -3,16 +3,297 @@
>> =A0 *
>> =A0 * Copyright 2004-2005 =A0Andrea Arcangeli <andrea@cpushare.com>
>> =A0 *
>> - * This defines a simple but solid secure-computing mode.
>> + * Copyright (C) 2012 Google, Inc.
>> + * Will Drewry <wad@chromium.org>
>> + *
>> + * This defines a simple but solid secure-computing facility.
>> + *
>> + * Mode 1 uses a fixed list of allowed system calls.
>> + * Mode 2 allows user-defined system call filters in the form
>> + * =A0 =A0 =A0 =A0of Berkeley Packet Filters/Linux Socket Filters.
>> =A0 */
>>
>> =A0#include <linux/audit.h>
>> +#include <linux/filter.h>
>> =A0#include <linux/seccomp.h>
>> =A0#include <linux/sched.h>
>> =A0#include <linux/compat.h>
>>
>> +#include <linux/atomic.h>
>> +#include <linux/security.h>
>> +
>> +#include <linux/slab.h>
>> +#include <linux/uaccess.h>
>> +#include <linux/user.h>
>
> Are those still needed since you got rid of that manual user-copying =
stuff?

Nice catch - probably not. I'll remove what I can.

>> +
>> +#include <linux/tracehook.h>
>> +#include <asm/syscall.h>
>> +
>> =A0/* #define SECCOMP_DEBUG 1 */
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
>> + * @compat: indicates the value of is_compat_task() at creation tim=
e
>> + * @insns: the BPF program instructions to evaluate
>> + * @count: the number of instructions in the program
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
>> + =A0 =A0 bool compat;
>> + =A0 =A0 unsigned short count; =A0/* Instruction count */
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
>> +static inline u32 get_high_bits(unsigned long value)
>> +{
>> + =A0 =A0 int bits =3D 32;
>> + =A0 =A0 return value >> bits;
>> +}
>> +
>> +static inline u32 bpf_length(const void *data)
>> +{
>> + =A0 =A0 return sizeof(struct seccomp_data);
>> +}
>
> This doesn't change, so why not pass in the length directly instead o=
f
> getting it via a function?

True - since it's passed in at bpf_run_filters time, there's no reason
to make it a function!

> And stop adding inline to functions that are
> used for function pointers, it's misleading.

Only a little misleading :)

>> +
>> +/**
>> + * bpf_pointer: checks and returns a pointer to the requested offse=
t
>> + * @nr: int syscall passed as a void * to bpf_run_filter
>> + * @off: index to load a from in @data
>

Oops - I'll fix that.

>
>> + * @size: load width requested
>> + * @buffer: temporary storage supplied by bpf_run_filter
>> + *
>> + * Returns a pointer to @buffer where the value was stored.
>> + * On failure, returns NULL.
>> + */
>> +static void *bpf_pointer(const void *nr, int off, unsigned int size=
, void *buf)
>> +{
>> + =A0 =A0 unsigned long value;
>> + =A0 =A0 u32 *A =3D (u32 *)buf;
>
> No need to cast a void pointer. That's the whole point of void pointe=
rs.

True.

>> +
>> + =A0 =A0 if (size !=3D sizeof(u32))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>> +
>> +#define BPF_DATA(_name) offsetof(struct seccomp_data, _name)
>
> I'd move this outside of the function and don't bother with the undef=
=2E
> Undeffing is important in header files. But here, if it's needed, it'=
s
> just plain confusing.

Will do.

>> + =A0 =A0 /* Index by entry instead of by byte. */
>> + =A0 =A0 if (off =3D=3D BPF_DATA(nr)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 *A =3D (u32)(uintptr_t)nr;
>
> Why the double cast? Once should be enough. Or is it a special Sparse=
 thing?

It's a gcc thing when you cast an int to a pointer of a different
size. I just chose uintptr_t as my intermediary type.

>> + =A0 =A0 } else if (off =3D=3D BPF_DATA(instruction_pointer.lo)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 *A =3D KSTK_EIP(current);
>> + =A0 =A0 } else if (off =3D=3D BPF_DATA(instruction_pointer.hi)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 *A =3D get_high_bits(KSTK_EIP(current));
>> + =A0 =A0 } else if (off >=3D BPF_DATA(lo32[0]) && off <=3D BPF_DATA=
(lo32[5])) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct pt_regs *regs =3D task_pt_regs(curr=
ent);
>> + =A0 =A0 =A0 =A0 =A0 =A0 int arg =3D (off - BPF_DATA(lo32[0])) >> 2=
;
>> + =A0 =A0 =A0 =A0 =A0 =A0 syscall_get_arguments(current, regs, arg, =
1, &value);
>> + =A0 =A0 =A0 =A0 =A0 =A0 *A =3D value;
>> + =A0 =A0 } else if (off >=3D BPF_DATA(hi32[0]) && off <=3D BPF_DATA=
(hi32[5])) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct pt_regs *regs =3D task_pt_regs(curr=
ent);
>> + =A0 =A0 =A0 =A0 =A0 =A0 int arg =3D (off - BPF_DATA(hi32[0])) >> 2=
;
>> + =A0 =A0 =A0 =A0 =A0 =A0 syscall_get_arguments(current, regs, arg, =
1, &value);
>> + =A0 =A0 =A0 =A0 =A0 =A0 *A =3D get_high_bits(value);
>> + =A0 =A0 } else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>> + =A0 =A0 }
>> +#undef BPF_DATA
>> + =A0 =A0 return buf;
>> +}
>> +
>> +/**
>> + * seccomp_run_filters - run 'current' against the given syscall
>> + * @syscall: number of the current system call
>
> Strange comments.

Weird. I'll fix it.

>> + *
>> + * Returns valid seccomp BPF response codes.
>> + */
>> +static u32 seccomp_run_filters(int syscall)
>> +{
>> + =A0 =A0 struct seccomp_filter *f;
>> + =A0 =A0 const struct bpf_load_fns loaders =3D { bpf_pointer, bpf_l=
ength };
>
> I don't see the point of this.
>
> The return values for seccomp filters are different than the networki=
ng
> ones, so there is never a need to get bpf_length from the filter code
> as it's known at compile time. So just declare BPF_S_LD_W_LEN and
> S_LDX_W_LEN networking-only instructions and don't bother with all th=
is.

Since I was proposing bpf_* as generic bpf interfaces, it seemed weird
to make data length socket specific. I can see cases where length may
matter for other (non-existent) users of BPF or if the length of the
seccomp_data changes in the future.  Of course, the calling convention
index may be the way to handle that without the filter program
checking the length.  I'm fine dropping it, but for this one, I'll do
whatever makes sense to the networking people.


>> + =A0 =A0 u32 ret =3D SECCOMP_RET_KILL;
>> + =A0 =A0 const void *sc_ptr =3D (const void *)(uintptr_t)syscall;
>> +
>> + =A0 =A0 /* It's not possible for the filter to be NULL here. */
>> +#ifdef CONFIG_COMPAT
>> + =A0 =A0 if (current->seccomp.filter->compat !=3D !!(is_compat_task=
()))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return ret;
>> +#endif
>> +
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* All filters are evaluated in order of youngest to old=
est. The lowest
>> + =A0 =A0 =A0* BPF return value always takes priority.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 for (f =3D current->seccomp.filter; f; f =3D f->prev) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D bpf_run_filter(sc_ptr, f->insns, &=
loaders);
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
>> + =A0 =A0 struct seccomp_filter *filter =3D NULL;
>
> Don't initialize it to NULL, next time 'filter' is used it's set
> by kzalloc's return value.
>
>> + =A0 =A0 unsigned long fp_size =3D fprog->len * sizeof(struct sock_=
filter);
>> + =A0 =A0 long ret =3D -EINVAL;
>> +
>> + =A0 =A0 if (fprog->len =3D=3D 0 || fprog->len > BPF_MAXINSNS)
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>
> Oh wait, you need the NULL because you can call put_filter() via out.
> Well, just return EINVAL directly instead here I'd say.
>
>> +
>> + =A0 =A0 /* Allocate a new seccomp_filter */
>> + =A0 =A0 ret =3D -ENOMEM;
>> + =A0 =A0 filter =3D kzalloc(sizeof(struct seccomp_filter) + fp_size=
, GFP_KERNEL);
>> + =A0 =A0 if (!filter)
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>
> Same here, just return ENOMEM.

Done.

>> + =A0 =A0 atomic_set(&filter->usage, 1);
>> + =A0 =A0 filter->count =3D fprog->len;
>
> Why is it called count in one place and len in the other? Isn't it cl=
earer
> when always using len?

Sure - changed!

>> +
>> + =A0 =A0 /* Copy the instructions from fprog. */
>> + =A0 =A0 ret =3D -EFAULT;
>> + =A0 =A0 if (copy_from_user(filter->insns, fprog->filter, fp_size))
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> +
>> + =A0 =A0 /* Check the fprog */
>> + =A0 =A0 ret =3D bpf_chk_filter(filter->insns, filter->count, BPF_C=
HK_FLAGS_NO_SKB);
>> + =A0 =A0 if (ret)
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> +
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* Installing a seccomp filter requires that the task
>> + =A0 =A0 =A0* have CAP_SYS_ADMIN in its namespace or be running wit=
h
>> + =A0 =A0 =A0* no_new_privs. =A0This avoids scenarios where unprivil=
eged
>> + =A0 =A0 =A0* tasks can affect the behavior of privileged children.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 ret =3D -EACCES;
>> + =A0 =A0 if (!current->no_new_privs &&
>> + =A0 =A0 =A0 =A0 security_capable_noaudit(current_cred(), current_u=
ser_ns(),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
CAP_SYS_ADMIN) !=3D 0)
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> +
>> + =A0 =A0 /* Lock the filter to the current calling convention. */
>> +#ifdef CONFIG_COMPAT
>> + =A0 =A0 filter->compat =3D !!(is_compat_task());
>> +#endif
>> +
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* If there is an existing filter, make it the prev
>> + =A0 =A0 =A0* and don't drop its task reference.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 filter->prev =3D current->seccomp.filter;
>> + =A0 =A0 current->seccomp.filter =3D filter;
>> + =A0 =A0 return 0;
>> +out:
>> + =A0 =A0 put_seccomp_filter(filter); =A0/* for get or task, on err =
*/
>> + =A0 =A0 return ret;
>> +}
>> +
>> +/**
>> + * seccomp_attach_user_filter - attaches a user-supplied sock_fprog
>> + * @user_filter: pointer to the user data containing a sock_fprog.
>> + *
>> + * This function may be called repeatedly to install additional fil=
ters.
>> + * Every filter successfully installed will be evaluated (in revers=
e order)
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
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* XXX: Share with net/compat.c */
>
> You can't share this with net/compat.c because they have to pass a __=
user
> pointer to a generic sock_setsockopt(). You could refactor their code=
 to
> push the compat check later, but I think they prefer to keep all the =
compat
> stuff in one place.

struct compat_sock_fprog is identical to what I have below - I just
can't share the rest of the code.

>> + =A0 =A0 =A0 =A0 =A0 =A0 struct {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 u16 len;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 compat_uptr_t filter; =A0 =
/* struct sock_filter */
>> + =A0 =A0 =A0 =A0 =A0 =A0 } fprog32;
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (copy_from_user(&fprog32, user_filter, =
sizeof(fprog32)))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> + =A0 =A0 =A0 =A0 =A0 =A0 fprog.len =3D fprog32.len;
>> + =A0 =A0 =A0 =A0 =A0 =A0 fprog.filter =3D compat_ptr(fprog32.filter=
);
>> + =A0 =A0 } else
>> +#endif
>> + =A0 =A0 if (copy_from_user(&fprog, user_filter, sizeof(fprog)))
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>
> Probably a good idea to intend the else if one more time to make it m=
ore
> obvious. Or add a comment after the else.

Added a comment after the else.

>> + =A0 =A0 ret =3D seccomp_attach_filter(&fprog);
>> +out:
>> + =A0 =A0 return ret;
>> +}
>> +
>> +/* get_seccomp_filter - increments the reference count of @orig. */
>> +static struct seccomp_filter *get_seccomp_filter(struct seccomp_fil=
ter *orig)
>> +{
>> + =A0 =A0 if (!orig)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>> + =A0 =A0 /* Reference count is bounded by the number of total proce=
sses. */
>> + =A0 =A0 atomic_inc(&orig->usage);
>> + =A0 =A0 return orig;
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
>> +{
>> + =A0 =A0 child->mode =3D prev->mode;
>> + =A0 =A0 child->filter =3D get_seccomp_filter(prev->filter);
>> +}
>> +#endif =A0 =A0 =A0 /* CONFIG_SECCOMP_FILTER */
>>
>> =A0/*
>> =A0 * Secure computing mode 1 allows only read/write/exit/sigreturn.
>> @@ -34,10 +315,10 @@ static int mode1_syscalls_32[] =3D {
>> =A0void __secure_computing(int this_syscall)
>> =A0{
>> =A0 =A0 =A0 int mode =3D current->seccomp.mode;
>> - =A0 =A0 int * syscall;
>> + =A0 =A0 int *syscall;
>>
>> =A0 =A0 =A0 switch (mode) {
>> - =A0 =A0 case 1:
>> + =A0 =A0 case SECCOMP_MODE_STRICT:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 syscall =3D mode1_syscalls;
>> =A0#ifdef CONFIG_COMPAT
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (is_compat_task())
>> @@ -48,6 +329,13 @@ void __secure_computing(int this_syscall)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 } while (*++syscall);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> +#ifdef CONFIG_SECCOMP_FILTER
>> + =A0 =A0 case SECCOMP_MODE_FILTER:
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (seccomp_run_filters(this_syscall) =3D=3D=
 SECCOMP_RET_ALLOW)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>> + =A0 =A0 =A0 =A0 =A0 =A0 seccomp_filter_log_failure(this_syscall);
>> + =A0 =A0 =A0 =A0 =A0 =A0 break;
>> +#endif
>> =A0 =A0 =A0 default:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG();
>> =A0 =A0 =A0 }
>> @@ -64,25 +352,34 @@ long prctl_get_seccomp(void)
>> =A0 =A0 =A0 return current->seccomp.mode;
>> =A0}
>>
>> -long prctl_set_seccomp(unsigned long seccomp_mode)
>> +long prctl_set_seccomp(unsigned long seccomp_mode, char __user *fil=
ter)
>> =A0{
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
>> =A0#ifdef TIF_NOTSC
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 disable_TSC();
>> =A0#endif
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
>> =A0}
>> diff --git a/kernel/sys.c b/kernel/sys.c
>> index 4070153..905031e 100644
>> --- a/kernel/sys.c
>> +++ b/kernel/sys.c
>> @@ -1899,7 +1899,7 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned l=
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
>> 1.7.5.4
>>
>>
>
> Greetings,

Thanks!
will
