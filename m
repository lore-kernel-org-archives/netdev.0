From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v17 08/15] seccomp: add system call filtering using BPF
Date: Tue, 10 Apr 2012 12:54:43 -0700
Message-ID: <20120410125443.3ab1a277.akpm@linux-foundation.org>
References: <1333051320-30872-1-git-send-email-wad@chromium.org>
	<1333051320-30872-9-git-send-email-wad@chromium.org>
	<20120406132330.457a05cf.akpm@linux-foundation.org>
	<67e30a0c8655fc53a92e8138bba9de66.squirrel@webmail.greenhost.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Will Drewry" <wad@chromium.org>, linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	eparis@redhat.com, serge.hallyn@canonical.com, djm@mindrot.org,
	scarybeasts@gmail.com, pmoore@redhat.com, corbet@lwn.net,
	eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org, jmorris@namei.org
To: "Indan Zupancic" <indan@nul.nu>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <67e30a0c8655fc53a92e8138bba9de66.squirrel@webmail.greenhost.nl>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 9 Apr 2012 04:22:40 +1000
"Indan Zupancic" <indan@nul.nu> wrote:

> On Sat, April 7, 2012 06:23, Andrew Morton wrote:
> > hm, I'm surprised that we don't have a zero-returning implementation of
> > is_compat_task() when CONFIG_COMPAT=n.  Seems silly.  Blames Arnd.
> 
> It's sneakily hidden at the end of compat.h.
> 
> >> +/**
> >> + * get_u32 - returns a u32 offset into data
> >> + * @data: a unsigned 64 bit value
> >> + * @index: 0 or 1 to return the first or second 32-bits
> >> + *
> >> + * This inline exists to hide the length of unsigned long.
> >> + * If a 32-bit unsigned long is passed in, it will be extended
> >> + * and the top 32-bits will be 0. If it is a 64-bit unsigned
> >> + * long, then whatever data is resident will be properly returned.
> >> + */
> >> +static inline u32 get_u32(u64 data, int index)
> >> +{
> >> +	return ((u32 *)&data)[index];
> >> +}
> >
> > This seems utterly broken on big-endian machines.  If so: fix.  If not:
> > add comment explaining why?
> 
> It's not a bug, it's intentional.

Well it looks like a bug, which is why I suggest that it be clearly
commented.

> >
> >> +	if (total_insns > MAX_INSNS_PER_PATH)
> >> +		return -ENOMEM;
> >> +
> >> +	/*
> >> +	 * Installing a seccomp filter requires that the task have
> >> +	 * CAP_SYS_ADMIN in its namespace or be running with no_new_privs.
> >> +	 * This avoids scenarios where unprivileged tasks can affect the
> >> +	 * behavior of privileged children.
> >> +	 */
> >> +	if (!current->no_new_privs &&
> >> +	    security_capable_noaudit(current_cred(), current_user_ns(),
> >> +				     CAP_SYS_ADMIN) != 0)
> >> +		return -EACCES;
> >> +
> >> +	/* Allocate a new seccomp_filter */
> >> +	filter = kzalloc(sizeof(struct seccomp_filter) + fp_size, GFP_KERNEL);
> >
> > I think this gives userspace an easy way of causing page allocation
> > failure warnings, by permitting large kmalloc() attempts.  Add
> > __GFP_NOWARN?
> 
> Max is 32kb. sk_attach_filter() in net/core/filter.c is worse,
> it allocates up to 512kb before even checking the length.

An order-3 allocation attempt is pretty fragile.  This will sometimes
fail.

> What about using GFP_USER (and adding __GFP_NOWARN to GFP_USER) instead?

Let's be conventional and use the open-coded __GFP_NOWARN. 
__GFP_NOWARN says "this is a big allocation which will sometimes fail
and I have carefully reviewed the failure paths and runtime tested
them".

Please carefully review the failure paths and runtime test them ;)

> >> +	/* Check and rewrite the fprog via the skb checker */
> >> +	ret = sk_chk_filter(filter->insns, filter->len);
> >> +	if (ret)
> >> +		goto fail;
> >> +
> >> +	/* Check and rewrite the fprog for seccomp use */
> >> +	ret = seccomp_chk_filter(filter->insns, filter->len);
> >
> > "check" is spelled "check"!
> 
> Yes, it is and he did spell "check" as "Check".
> 
> seccomp_chk_filter() mirrors sk_chk_filter(). So it refers to
> "chk", not "check".

bah.  Two poor identifiers isn't better than one.  Whatever.
