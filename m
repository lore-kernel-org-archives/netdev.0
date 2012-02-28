From: "Indan Zupancic" <indan@nul.nu>
Subject: Re: [PATCH v11 06/12] seccomp: add system call filtering using BPF
Date: Tue, 28 Feb 2012 07:51:57 +0100
Message-ID: <b983ece9dc6209269876869188303518.squirrel@webmail.greenhost.nl>
References: <1330140111-17201-1-git-send-email-wad@chromium.org>
    <1330140111-17201-6-git-send-email-wad@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain;charset=UTF-8
Content-Transfer-Encoding: 8bit
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
	keescook@chromium.org, "Will Drewry" <wad@chromium.org>
To: "Will Drewry" <wad@chromium.org>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1330140111-17201-6-git-send-email-wad@chromium.org>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Sat, February 25, 2012 04:21, Will Drewry wrote:
> @@ -169,6 +170,7 @@ void free_task(struct task_struct *tsk)
> 	free_thread_info(tsk->stack);
> 	rt_mutex_debug_task_free(tsk);
> 	ftrace_graph_exit_task(tsk);
> +	put_seccomp_filter(tsk->seccomp.filter);
> 	free_task_struct(tsk);
> }
> EXPORT_SYMBOL(free_task);
> @@ -1113,6 +1115,7 @@ static struct task_struct *copy_process(unsigned long clone_flags,
> 		goto fork_out;
>
> 	ftrace_graph_init_task(p);
> +	copy_seccomp(&p->seccomp, &current->seccomp);

I agree it's more symmetrical when get_seccomp_filter() is used here
directly instead of copy_seccomp(). That should put Kees at ease.

> +static void seccomp_filter_log_failure(int syscall)
> +{
> +	int compat = 0;
> +#ifdef CONFIG_COMPAT
> +	compat = is_compat_task();
> +#endif
> +	pr_info("%s[%d]: %ssystem call %d blocked at 0x%lx\n",
> +		current->comm, task_pid_nr(current),
> +		(compat ? "compat " : ""),
> +		syscall, KSTK_EIP(current));
> +}

This should be at least rate limited, but could be dropped altogether,
as it's mostly useful for debugging filters. There is no kernel message
when a process is killed because it exceeds a ulimit either. The death
by SIGSYS is hopefully clear enough for users, and filter writers can
return different errno values when debugging where it goes wrong.

> +/**
> + * bpf_load: checks and returns a pointer to the requested offset
> + * @nr: int syscall passed as a void * to bpf_run_filter
> + * @off: offset into struct seccomp_data to load from

Must be aligned, that's worth mentioning.

> + * @size: number of bytes to load (must be 4)
> + * @buffer: temporary storage supplied by bpf_run_filter (4 bytes)

'@buf'.

> +/**
> + * copy_seccomp: manages inheritance on fork
> + * @child: forkee's seccomp
> + * @parent: forker's seccomp
> + *
> + * Ensures that @child inherits filters if in use.
> + */
> +void copy_seccomp(struct seccomp *child, const struct seccomp *parent)
> +{
> +	/* Other fields are handled by dup_task_struct. */
> +	child->filter = get_seccomp_filter(parent->filter);
> +}
> +#endif	/* CONFIG_SECCOMP_FILTER */

Yeah, just get rid of this and use get_seccomp_filter directly, and make
it return void instead of a pointer.

>
> /*
>  * Secure computing mode 1 allows only read/write/exit/sigreturn.
> @@ -34,10 +293,11 @@ static int mode1_syscalls_32[] = {
> void __secure_computing(int this_syscall)
> {
> 	int mode = current->seccomp.mode;
> -	int * syscall;
> +	int exit_code = SIGKILL;
> +	int *syscall;
>
> 	switch (mode) {
> -	case 1:
> +	case SECCOMP_MODE_STRICT:
> 		syscall = mode1_syscalls;
> #ifdef CONFIG_COMPAT
> 		if (is_compat_task())
> @@ -48,6 +308,14 @@ void __secure_computing(int this_syscall)
> 				return;
> 		} while (*++syscall);
> 		break;
> +#ifdef CONFIG_SECCOMP_FILTER
> +	case SECCOMP_MODE_FILTER:
> +		if (seccomp_run_filters(this_syscall) == SECCOMP_RET_ALLOW)
> +			return;
> +		seccomp_filter_log_failure(this_syscall);
> +		exit_code = SIGSYS;

Wouldn't it make more sense to always kill with SIGSYS, also for mode 1?
I suppose it's too late for that now.

> +/**
> + * prctl_set_seccomp: configures current->seccomp.mode
> + * @seccomp_mode: requested mode to use
> + * @filter: optional struct sock_fprog for use with SECCOMP_MODE_FILTER
> + *
> + * This function may be called repeatedly with a @seccomp_mode of
> + * SECCOMP_MODE_FILTER to install additional filters.  Every filter
> + * successfully installed will be evaluated (in reverse order) for each system
> + * call the task makes.
> + *
> + * It is not possible to transition change the current->seccomp.mode after
> + * one has been set on a task.

That reads awkwardly, do you mean the mode can't be changed once it's set?

---

Reviewed-by: Indan Zupancic <indan@nul.nu>

All in all I'm quite happy with how the code is now, at least this bit.
I'm still unsure about the networking patch and the 32-bit BPF on 64-bit
archs mismatch.

As for the unlimited filter count, I'm not sure how to fix that.
The problem is that filters are inherited and shared. Limiting the
list length (tree depth) helps a bit, then the total memory usage
is limited by max number of processes. It may make sense to limit
the total instruction count instead of the number of filters.

Greetings,

Indan
