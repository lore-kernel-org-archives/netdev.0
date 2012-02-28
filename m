From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v11 06/12] seccomp: add system call filtering using BPF
Date: Tue, 28 Feb 2012 11:17:59 -0600
Message-ID: <CABqD9haZpe-i8kyHJDj4umCLyZ3E877aobabvW8_+aXeC+kTbg@mail.gmail.com>
References: <1330140111-17201-1-git-send-email-wad@chromium.org>
	<1330140111-17201-6-git-send-email-wad@chromium.org>
	<b983ece9dc6209269876869188303518.squirrel@webmail.greenhost.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
	markus@chromium.org, coreyb@linux.vnet.ibm.com,
	keescook@chromium.org
To: Indan Zupancic <indan@nul.nu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:52067 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755423Ab2B1RSC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2012 12:18:02 -0500
Received: by bkcik5 with SMTP id ik5so1473658bkc.19
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2012 09:18:01 -0800 (PST)
In-Reply-To: <b983ece9dc6209269876869188303518.squirrel@webmail.greenhost.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 28, 2012 at 12:51 AM, Indan Zupancic <indan@nul.nu> wrote:
> Hello,
>
> On Sat, February 25, 2012 04:21, Will Drewry wrote:
>> @@ -169,6 +170,7 @@ void free_task(struct task_struct *tsk)
>> =A0 =A0 =A0 free_thread_info(tsk->stack);
>> =A0 =A0 =A0 rt_mutex_debug_task_free(tsk);
>> =A0 =A0 =A0 ftrace_graph_exit_task(tsk);
>> + =A0 =A0 put_seccomp_filter(tsk->seccomp.filter);
>> =A0 =A0 =A0 free_task_struct(tsk);
>> }
>> EXPORT_SYMBOL(free_task);
>> @@ -1113,6 +1115,7 @@ static struct task_struct *copy_process(unsign=
ed long clone_flags,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto fork_out;
>>
>> =A0 =A0 =A0 ftrace_graph_init_task(p);
>> + =A0 =A0 copy_seccomp(&p->seccomp, &current->seccomp);
>
> I agree it's more symmetrical when get_seccomp_filter() is used here
> directly instead of copy_seccomp(). That should put Kees at ease.

Makes sense to me too. Once I'd dropped the other bits, it seemed
silly to keep copy_seccomp.

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
> This should be at least rate limited, but could be dropped altogether=
,
> as it's mostly useful for debugging filters. There is no kernel messa=
ge
> when a process is killed because it exceeds a ulimit either. The deat=
h
> by SIGSYS is hopefully clear enough for users, and filter writers can
> return different errno values when debugging where it goes wrong.

I'll pull Kees's patch into the series this next go-round.

>> +/**
>> + * bpf_load: checks and returns a pointer to the requested offset
>> + * @nr: int syscall passed as a void * to bpf_run_filter
>> + * @off: offset into struct seccomp_data to load from
>
> Must be aligned, that's worth mentioning.

True - thanks!

>> + * @size: number of bytes to load (must be 4)
>> + * @buffer: temporary storage supplied by bpf_run_filter (4 bytes)
>
> '@buf'.

Oops - fixed.

>> +/**
>> + * copy_seccomp: manages inheritance on fork
>> + * @child: forkee's seccomp
>> + * @parent: forker's seccomp
>> + *
>> + * Ensures that @child inherits filters if in use.
>> + */
>> +void copy_seccomp(struct seccomp *child, const struct seccomp *pare=
nt)
>> +{
>> + =A0 =A0 /* Other fields are handled by dup_task_struct. */
>> + =A0 =A0 child->filter =3D get_seccomp_filter(parent->filter);
>> +}
>> +#endif =A0 =A0 =A0 /* CONFIG_SECCOMP_FILTER */
>
> Yeah, just get rid of this and use get_seccomp_filter directly, and m=
ake
> it return void instead of a pointer.

It'll be updated.

>>
>> /*
>> =A0* Secure computing mode 1 allows only read/write/exit/sigreturn.
>> @@ -34,10 +293,11 @@ static int mode1_syscalls_32[] =3D {
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
>> @@ -48,6 +308,14 @@ void __secure_computing(int this_syscall)
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
>
> Wouldn't it make more sense to always kill with SIGSYS, also for mode=
 1?
> I suppose it's too late for that now.

It would but I don't want to go and change existing ABI.

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
>> + * call the task makes.
>> + *
>> + * It is not possible to transition change the current->seccomp.mod=
e after
>> + * one has been set on a task.
>
> That reads awkwardly, do you mean the mode can't be changed once it's=
 set?

Yup - I will fix that.  It doesn't even make sense :)

> ---
>
> Reviewed-by: Indan Zupancic <indan@nul.nu>

Thanks!

> All in all I'm quite happy with how the code is now, at least this bi=
t.
> I'm still unsure about the networking patch and the 32-bit BPF on 64-=
bit
> archs mismatch.

Yeah - that is really the most challenging set of compromises, but I
think they are the right ones.

> As for the unlimited filter count, I'm not sure how to fix that.
> The problem is that filters are inherited and shared. Limiting the
> list length (tree depth) helps a bit, then the total memory usage
> is limited by max number of processes. It may make sense to limit
> the total instruction count instead of the number of filters.

I'll take a stab at tree path size for starters and hopefully we can
encourage consumers of the API to check for errors on return.

Thanks for the continued review and feedback!
will
