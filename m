From: "Indan Zupancic" <indan@nul.nu>
Subject: Re: [PATCH v14 06/13] seccomp: add system call filtering using BPF
Date: Tue, 13 Mar 2012 04:33:25 +0100
Message-ID: <a7d249196cbd1f85b94ed7246ab0beda.squirrel@webmail.greenhost.nl>
References: <1331587715-26069-1-git-send-email-wad@chromium.org>
    <1331587715-26069-6-git-send-email-wad@chromium.org>
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
In-Reply-To: <1331587715-26069-6-git-send-email-wad@chromium.org>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Could you send a 00/13 patch with a diffstat summary of all patches
combined and also some code size diffs? That would be very nice.

I assume the BPF performance for networking doesn't change with this
version.

> +/* Limit any path through the tree to 1 megabytes worth of instructions. */
> +#define MAX_INSNS_PER_PATH ((1 << 20) / sizeof(struct sock_filter))

This still makes me feel uneasy. It's also easier to increase the limit
in the future if necessary than to reduce it. So I would go for a lower
initial limit, like 256kB or 512Kb. 1 megabyte are 32 max size filters,
that seems like a lot. And in practise it's more likely that the more
filters there are, the smaller they usually are.

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

If you keep this, at least make it rate limited?

> +/**
> + * bpf_load: checks and returns a pointer to the requested offset
> + * @off: offset into struct seccomp_data to load from
> + *
> + * Returns the requested 32-bits of data.
> + * seccomp_chk_filter() should assure that @off is 32-bit aligned
> + * and not out of bounds.  Failure to do so is a BUG.
> + */
> +u32 seccomp_bpf_load(int off)
> +{
> +	struct pt_regs *regs = task_pt_regs(current);
> +
> +	if (off == BPF_DATA(nr))
> +		return syscall_get_nr(current, regs);
> +	if (off == BPF_DATA(arch))
> +		return syscall_get_arch(current, regs);
> +	if (off == BPF_DATA(instruction_pointer))
> +		return get_u32(KSTK_EIP(current), 0);
> +	if (off == BPF_DATA(instruction_pointer) + sizeof(u32))
> +		return get_u32(KSTK_EIP(current), 1);

I'd put the IP checks at the end, as it's the least likely case.
But maybe gcc is smart enough to detect a pattern.

> +	if (off >= BPF_DATA(args[0]) && off < BPF_DATA(args[6])) {
> +		unsigned long value;
> +		int arg = (off - BPF_DATA(args[0])) / sizeof(u64);
> +		int index = !!(off % sizeof(u64));
> +		syscall_get_arguments(current, regs, arg, 1, &value);
> +		return get_u32(value, index);
> +	}
> +	/* seccomp_chk_filter should make this impossible. */
> +	BUG();
> +}
> +
> +/**
> + *	seccomp_chk_filter - verify seccomp filter code
> + *	@filter: filter to verify
> + *	@flen: length of filter
> + *
> + * Takes a previously checked filter (by sk_chk_filter) and
> + * redirects all filter code that loads struct sk_buff data
> + * and related data through seccomp_bpf_load.  It also
> + * enforces length and alignment checking of those loads.
> + *
> + * Returns 0 if the rule set is legal or -EINVAL if not.
> + */
> +static int seccomp_chk_filter(struct sock_filter *filter, unsigned int flen)
> +{
> +	int pc;
> +	for (pc = 0; pc < flen; pc++) {
> +		struct sock_filter *ftest = &filter[pc];
> +		u16 code = ftest->code;
> +		u32 k = ftest->k;
> +		if (code <= BPF_S_ALU_NEG)
> +			continue;
> +		/* Do not allow ancillary codes (incl. BPF_S_ANC_SECCOMP_*) */
> +		if (code >= BPF_S_ANC_PROTOCOL)
> +			return -EINVAL;
> +		if (code >= BPF_S_LDX_IMM)
> +			continue;

I know I did the same in my code, but to avoid silly bugs when someone changes
the enum in filter.h without being aware of SECCOMP, it's much safer to check
all known good instructions explicitly in a big switch. And the compiler is
hopefully smart enough to generate pretty much the same code as now. Then if
new cases are added or existing ones swapped around, everything will still
work and we don't end up with a silent security hole.

The reason I didn't do that was laziness and because it looks ugly. But it's
more robust and I don't see a better way to get the same guarantees.

> +		switch (code) {
> +		case BPF_S_LD_W_ABS:
> +			ftest->code = BPF_S_ANC_SECCOMP_LD_W;
> +			/* 32-bit aligned and not out of bounds. */
> +			if (k >= sizeof(struct seccomp_data) || k & 3)
> +				return -EINVAL;
> +			continue;
> +		case BPF_S_LD_W_LEN:
> +			ftest->code = BPF_S_LD_IMM;
> +			ftest->k = sizeof(struct seccomp_data);
> +			continue;
> +		case BPF_S_LD_IMM:
> +			continue;
> +		case BPF_S_LDX_W_LEN:
> +			ftest->code = BPF_S_LDX_IMM;
> +			ftest->k = sizeof(struct seccomp_data);
> +			continue;
> +		case BPF_S_LD_W_IND:
> +			/* XXX: would runtime seccomp_bpf_load checking k */

Why? I checked your example code and haven't seen one case where you're
not using absolute loads. That said, I can think of situations where it's
nice to be able to store the syscall and argument numbers in MEM and use
an indirect load instead of changing the instructions themselves. But I
don't think it's worth the trouble supporting this, as it's only a minor
improvement while it adds more messy code just for this.

> +/**
> + * seccomp_attach_filter: Attaches a seccomp filter to current.
> + * @fprog: BPF program to install
> + *
> + * Returns 0 on success or an errno on failure.
> + */
> +static long seccomp_attach_filter(struct sock_fprog *fprog)
> +{
> +	struct seccomp_filter *filter;
> +	unsigned long fp_size = fprog->len * sizeof(struct sock_filter);
> +	unsigned long total_insns = 0;
> +	long ret;
> +
> +	if (fprog->len == 0 || fprog->len > BPF_MAXINSNS)
> +		return -EINVAL;
> +
> +	for (filter = current->seccomp.filter; filter; filter = filter->prev)
> +		total_insns += filter->len;

More accurate and better in case of one instruction filters:

		total_insns += filter->len + 4;

This to penalize tiny filters, otherwise a filter with one instruction will
use a lot more memory than just 8 bytes, so your effective max memory usage
would be much higher. It also depends on kzalloc's minimum allocation size
and rounding, so all in all 4 seems like a good number.

> +	if (total_insns > MAX_INSNS_PER_PATH - fprog->len)
> +		return -ENOSPC;

It seems more readable to me to initialize total_insns to fprog->len
instead of zero, and then drop the substraction. Overflows aren't
possible either way.

"No space left on device" isn't suitable either, I think. What's wrong
with just using ENOMEM?

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
> +	if (!user_filter)
> +		goto out;

This case should be handled by copy_from_user() already, so adding this
check doesn't add anything at all. Zero is only one out of many invalid
pointers, why check for 0 but not for e.g. 1, 2, 3, 4, 5, 6, 7, 8 or 9?

Reviewed-by: Indan Zupancic <indan@nul.nu>

Greetings,

Indan
