From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH v10 06/11] seccomp: add SECCOMP_RET_ERRNO
Date: Tue, 21 Feb 2012 14:41:28 -0800
Message-ID: <20120221224128.GJ3990@outflux.net>
References: <1329845435-2313-1-git-send-email-wad@chromium.org>
 <1329845435-2313-6-git-send-email-wad@chromium.org>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
        linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
        netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
        davem@davemloft.net, hpa@zytor.com, mingo@redhat.com, oleg@redhat.com,
        peterz@infradead.org, rdunlap@xenotime.net, mcgrathr@chromium.org,
        tglx@linutronix.de, luto@mit.edu, eparis@redhat.com,
        serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
        indan@nul.nu, pmoore@redhat.com, akpm@linux-foundation.org,
        corbet@lwn.net, eric.dumazet@gmail.com, markus@chromium.org
To: Will Drewry <wad@chromium.org>
Return-path: <kernel-hardening-return-894-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Content-Disposition: inline
In-Reply-To: <1329845435-2313-6-git-send-email-wad@chromium.org>
List-Id: netdev.vger.kernel.org

On Tue, Feb 21, 2012 at 11:30:30AM -0600, Will Drewry wrote:
> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
> index 0043b7e..23f1844 100644
> --- a/kernel/seccomp.c
> +++ b/kernel/seccomp.c
> @@ -136,22 +136,18 @@ static void *bpf_load(const void *nr, int off, unsigned int size, void *buf)
>  static u32 seccomp_run_filters(int syscall)
>  {
>  	struct seccomp_filter *f;
> -	u32 ret = SECCOMP_RET_KILL;
>  	static const struct bpf_load_fn fns = {
>  		bpf_load,
>  		sizeof(struct seccomp_data),
>  	};
> +	u32 ret = SECCOMP_RET_ALLOW;
>  	const void *sc_ptr = (const void *)(uintptr_t)syscall;
> -
>  	/*
>  	 * All filters are evaluated in order of youngest to oldest. The lowest
>  	 * BPF return value always takes priority.
>  	 */
> -	for (f = current->seccomp.filter; f; f = f->prev) {
> -		ret = bpf_run_filter(sc_ptr, f->insns, &fns);
> -		if (ret != SECCOMP_RET_ALLOW)
> -			break;
> -	}
> +	for (f = current->seccomp.filter; f; f = f->prev)
> +		ret = min_t(u32, ret, bpf_run_filter(sc_ptr, f->insns, &fns));
>  	return ret;
>  }

I'd like to see this fail closed in the (theoretically impossible, but
why risk it) case of there being no filters at all. Could do something
like this:

	u32 ret = current->seccomp.filter ? SECCOMP_RET_ALLOW : SECCOMP_RET_KILL;

Or, just this, to catch the misbehavior:

	if (unlikely(current->seccomp.filter == NULL))
		return SECCOMP_RET_KILL;

-Kees

-- 
Kees Cook
ChromeOS Security
