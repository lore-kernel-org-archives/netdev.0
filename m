From: Vladimir Murzin <murzin.v@gmail.com>
Subject: Re: [PATCH v17 08/15] seccomp: add system call filtering using BPF
Date: Sat, 31 Mar 2012 08:40:33 +0400
Message-ID: <20120331044030.GB3077@pinguin>
References: <1333051320-30872-1-git-send-email-wad@chromium.org>
 <1333051320-30872-9-git-send-email-wad@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, indan@nul.nu, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
	markus@chromium.org, coreyb@linux.vnet.ibm.com,
	keescook@chromium.org, jmorris@namei.org
To: Will Drewry <wad@chromium.org>
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1333051320-30872-9-git-send-email-wad@chromium.org>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Will,

On Thu, Mar 29, 2012 at 03:01:53PM -0500, Will Drewry wrote:

snipped

> +
> +/* Limit any path through the tree to 256KB worth of instructions. */
> +#define MAX_INSNS_PER_PATH ((1 << 18) / sizeof(struct sock_filter))
> +
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

snipped

> +/**
> + * seccomp_attach_user_filter - attaches a user-supplied sock_fprog
> + * @user_filter: pointer to the user data containing a sock_fprog.
> + *
> + * Returns 0 on success and non-zero otherwise.
> + */
> +long seccomp_attach_user_filter(char __user *user_filter)
> +{
> +	struct sock_fprog fprog;
> +	long ret = -EFAULT;
> +
> +#ifdef CONFIG_COMPAT
> +	if (is_compat_task()) {
> +		struct compat_sock_fprog fprog32;
> +		if (copy_from_user(&fprog32, user_filter, sizeof(fprog32)))
> +			goto out;
> +		fprog.len = fprog32.len;
> +		fprog.filter = compat_ptr(fprog32.filter);
> +	} else /* falls through to the if below. */
> +#endif
> +	if (copy_from_user(&fprog, user_filter, sizeof(fprog)))
> +		goto out;
> +	ret = seccomp_attach_filter(&fprog);
> +out:
> +	return ret;
> +}

Do we really need to surround is_compat_task() with CNFIG_COMPAT?
It seems that this case has already handled in compat.h [1]

[1] http://lxr.linux.no/#linux+v3.3/include/linux/compat.h#L566

Best wishes
Vladimir Murzin
