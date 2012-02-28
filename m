From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH v11 06/12] seccomp: add system call filtering using BPF
Date: Mon, 27 Feb 2012 23:52:28 -0800
Message-ID: <CAGXu5j+ZsP1q97=-DKxbyteNtX6zcw1LLWnKbTSKW90LN-_FHQ@mail.gmail.com>
References: <1330140111-17201-1-git-send-email-wad@chromium.org>
	<1330140111-17201-6-git-send-email-wad@chromium.org>
	<b983ece9dc6209269876869188303518.squirrel@webmail.greenhost.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Will Drewry <wad@chromium.org>, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
	x86@kernel.org, arnd@arndb.de, davem@davemloft.net, hpa@zytor.com,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
	luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
	markus@chromium.org, coreyb@linux.vnet.ibm.com
To: Indan Zupancic <indan@nul.nu>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <b983ece9dc6209269876869188303518.squirrel@webmail.greenhost.nl>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 27, 2012 at 10:51 PM, Indan Zupancic <indan@nul.nu> wrote:
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

Yeah, that does feel more symmetrical.

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

I've already sent a patch to take care of this. It was redundant with
the later call to audit_seccomp() on the exit path.
https://lkml.org/lkml/2012/2/26/70
https://lkml.org/lkml/2012/2/27/369

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

Right, this should (somewhat unfortunately) stay SIGKILL for mode 1.

-Kees

--=20
Kees Cook
ChromeOS Security
