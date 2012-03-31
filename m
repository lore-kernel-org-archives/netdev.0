From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v17 08/15] seccomp: add system call filtering using BPF
Date: Sat, 31 Mar 2012 13:14:25 -0500
Message-ID: <CABqD9hZu+yVVPWqcrOTo0e2gKuPn-ZKP403WKUMCqVL9zHs4uA@mail.gmail.com>
References: <1333051320-30872-1-git-send-email-wad@chromium.org>
	<1333051320-30872-9-git-send-email-wad@chromium.org>
	<20120331044030.GB3077@pinguin>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org, x86@kernel.org,
	arnd@arndb.de, davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu, eparis@redhat.com,
	serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
	indan@nul.nu, pmoore@redhat.com, akpm@linux-foundation.org, corbet@lwn.net,
	eric.dumazet@gmail.com, markus@chromium.org, coreyb@linux.vnet.ibm.com,
	keescook@chromium.org, jmorris@namei.org
To: Vladimir Murzin <murzin.v@gmail.com>
Return-path: <kernel-hardening-return-1194-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20120331044030.GB3077@pinguin>
List-Id: netdev.vger.kernel.org

2012/3/30 Vladimir Murzin <murzin.v@gmail.com>:
> Hi Will,
>
> On Thu, Mar 29, 2012 at 03:01:53PM -0500, Will Drewry wrote:
>
> snipped
>
>> +
>> +/* Limit any path through the tree to 256KB worth of instructions. */
>> +#define MAX_INSNS_PER_PATH ((1 << 18) / sizeof(struct sock_filter))
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
> snipped
>
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
>> +#ifdef CONFIG_COMPAT
>> + =A0 =A0 if (is_compat_task()) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct compat_sock_fprog fprog32;
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
>
> Do we really need to surround is_compat_task() with CNFIG_COMPAT?
> It seems that this case has already handled in compat.h [1]
>
> [1] http://lxr.linux.no/#linux+v3.3/include/linux/compat.h#L566

In log_failure, it's not needed at all, but that function disappears
in a subsequent patch in the series that converts over to using the
auditing framework.  For the next use of CONFIG_COMPAT, it is more
important for guarding the compat_sock_fprog struct (which isn't
doubly defined) rather than the is_compat_task.

Thanks!
will
