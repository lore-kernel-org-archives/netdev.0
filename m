From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v14 01/13] sk_run_filter: add BPF_S_ANC_SECCOMP_LD_W
Date: Tue, 13 Mar 2012 10:13:48 -0700
Message-ID: <1331658828.4449.16.camel@edumazet-glaptop>
References: <1331587715-26069-1-git-send-email-wad@chromium.org>
	 <0c55cb258e0b5bbd615923ee2a9f06b9.squirrel@webmail.greenhost.nl>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Will Drewry <wad@chromium.org>, linux-kernel@vger.kernel.org,  linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,  kernel-hardening@lists.openwall.com, netdev@vger.kernel.org, x86@kernel.org,  arnd@arndb.de, davem@davemloft.net, hpa@zytor.com, mingo@redhat.com, oleg@redhat.com,  peterz@infradead.org, rdunlap@xenotime.net, mcgrathr@chromium.org,  tglx@linutronix.de, luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,  djm@mindrot.org, scarybeasts@gmail.com, pmoore@redhat.com,  akpm@linux-foundation.org, corbet@lwn.net, markus@chromium.org,  coreyb@linux.vnet.ibm.com, keescook@chromium.org
To: Indan Zupancic <indan@nul.nu>
Return-path: <kernel-hardening-return-1109-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <0c55cb258e0b5bbd615923ee2a9f06b9.squirrel@webmail.greenhost.nl>
List-Id: netdev.vger.kernel.org

On Tue, 2012-03-13 at 11:04 +0100, Indan Zupancic wrote:
> Hello,
> 
> I made a quick pseudo-patch for BPF JIT support. As far as I can tell,
> the actual code itself is very simple, just:
> 

> -	bpf_jit_compile(fp);
> +	jit = bpf_jit_compile(fp->insns, fp->len, 1);
> +	if (jit) {
> +		fp->bpf_func = jit;
> +		/* Free unused insns memory */
> +		newfp = krealloc(fp, sizeof(*fp), GFP_KERNEL);
> +		if (newfp)
> +			fp = newfp;
> +	}
> 
>  	old_fp = rcu_dereference_protected(sk->sk_filter,
>  					   sock_owned_by_user(sk));

Dont mix unrelated changes in a single patch.

Current krealloc() doesnt alloc a new area if the current one is bigger
than 'new_size', but this might change in next kernel versions.

So this part of your patch does nothing.

If it did, this kind of 'optimization' can actually be not good, because
sizeof(*fp) is small enough (less than half cache line size) to trigger
a possible false sharing issue. (other part of the cache line could be
used to hold a often dirtied object)
