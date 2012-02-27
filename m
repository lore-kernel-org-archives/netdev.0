From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v11 06/12] seccomp: add system call filtering using BPF
Date: Mon, 27 Feb 2012 18:09:22 +0100
Message-ID: <20120227170922.GA10608@redhat.com>
References: <1330140111-17201-1-git-send-email-wad@chromium.org> <1330140111-17201-6-git-send-email-wad@chromium.org>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
        linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
        netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
        davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
        peterz@infradead.org, rdunlap@xenotime.net, mcgrathr@chromium.org,
        tglx@linutronix.de, luto@mit.edu, eparis@redhat.com,
        serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
        indan@nul.nu, pmoore@redhat.com, akpm@linux-foundation.org,
        corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org,
        coreyb@linux.vnet.ibm.com, keescook@chromium.org
To: Will Drewry <wad@chromium.org>
Return-path: <kernel-hardening-return-970-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Content-Disposition: inline
In-Reply-To: <1330140111-17201-6-git-send-email-wad@chromium.org>
List-Id: netdev.vger.kernel.org

Hello Will.

I missed the previous discussions, and I don't think I can read
all these emails now. So I apologize in advance if this was already
discussed.

On 02/24, Will Drewry wrote:
>
>  struct seccomp {
>  	int mode;
> +	struct seccomp_filter *filter;
>  };

Minor nit, it seems that the new member can be "ifdef CONFIG_SECCOMP_FILTER"

> +static long seccomp_attach_filter(struct sock_fprog *fprog)
> +{
> +	struct seccomp_filter *filter;
> +	unsigned long fp_size = fprog->len * sizeof(struct sock_filter);
> +	long ret;
> +
> +	if (fprog->len == 0 || fprog->len > BPF_MAXINSNS)
> +		return -EINVAL;

OK, this limits the memory PR_SET_SECCOMP can use.

But,

> +	/*
> +	 * If there is an existing filter, make it the prev and don't drop its
> +	 * task reference.
> +	 */
> +	filter->prev = current->seccomp.filter;
> +	current->seccomp.filter = filter;
> +	return 0;

this doesn't limit the number of filters, looks like a DoS.

What if the application simply does prctl(PR_SET_SECCOMP, dummy_filter)
in an endless loop?



> +static struct seccomp_filter *get_seccomp_filter(struct seccomp_filter *orig)
> +{
> +	if (!orig)
> +		return NULL;
> +	/* Reference count is bounded by the number of total processes. */
> +	atomic_inc(&orig->usage);
> +	return orig;
> +}
> ...
> +void copy_seccomp(struct seccomp *child, const struct seccomp *parent)
> +{
> +	/* Other fields are handled by dup_task_struct. */
> +	child->filter = get_seccomp_filter(parent->filter);
> +}

This is purely cosmetic, but imho looks a bit confusing.

We do not copy seccomp->mode and this is correct, it was already copied
implicitely. So why do we copy ->filter? This is not "symmetrical", afaics
you can simply do

	void copy_seccomp(struct seccomp *child)
	{
		if (child->filter)
			atomic_inc(child->filter->usage);

But once again, this is cosmetic, feel free to ignore.

Oleg.
