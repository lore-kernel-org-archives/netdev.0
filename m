From: Will Drewry <wad@chromium.org>
Subject: Re: [kernel-hardening] Re: [PATCH v14 06/13] seccomp: add system call
 filtering using BPF
Date: Tue, 13 Mar 2012 10:57:28 -0500
Message-ID: <CABqD9hYSxiw7OAAwxfwDCE+jDQfDfMi59Fx-H7JGw28u0fsDtA@mail.gmail.com>
References: <1331587715-26069-1-git-send-email-wad@chromium.org>
	<1331587715-26069-6-git-send-email-wad@chromium.org>
	<a7d249196cbd1f85b94ed7246ab0beda.squirrel@webmail.greenhost.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, netdev@vger.kernel.org, x86@kernel.org,
	arnd@arndb.de, davem@davemloft.net, hpa@zytor.com,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
	luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, eric.dumazet@gmail.com,
	markus@chromium.org, coreyb@linux.vnet.ibm.com,
	keescook@chromium.org
To: kernel-hardening@lists.openwall.com
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <a7d249196cbd1f85b94ed7246ab0beda.squirrel@webmail.greenhost.nl>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 12, 2012 at 10:33 PM, Indan Zupancic <indan@nul.nu> wrote:
> Hello,
>
> Could you send a 00/13 patch with a diffstat summary of all patches
> combined and also some code size diffs? That would be very nice.

No problem.  I'll do that for v15 integrating these tweaks.

> I assume the BPF performance for networking doesn't change with this
> version.

Not that I could see given normal jitter, but I can post numbers if
it's preferable.

>> +/* Limit any path through the tree to 1 megabytes worth of instruct=
ions. */
>> +#define MAX_INSNS_PER_PATH ((1 << 20) / sizeof(struct sock_filter))
>
> This still makes me feel uneasy. It's also easier to increase the lim=
it
> in the future if necessary than to reduce it. So I would go for a low=
er
> initial limit, like 256kB or 512Kb. 1 megabyte are 32 max size filter=
s,
> that seems like a lot. And in practise it's more likely that the more
> filters there are, the smaller they usually are.

I'll drop it, but next tweak will result in a sysctl :)

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
> If you keep this, at least make it rate limited?

It goes away with the last patch in the series.  Maybe in the next
rev, I'll pull in Kees's changes so I can further expand
audit_seccomp().

>> +/**
>> + * bpf_load: checks and returns a pointer to the requested offset
>> + * @off: offset into struct seccomp_data to load from
>> + *
>> + * Returns the requested 32-bits of data.
>> + * seccomp_chk_filter() should assure that @off is 32-bit aligned
>> + * and not out of bounds. =A0Failure to do so is a BUG.
>> + */
>> +u32 seccomp_bpf_load(int off)
>> +{
>> + =A0 =A0 struct pt_regs *regs =3D task_pt_regs(current);
>> +
>> + =A0 =A0 if (off =3D=3D BPF_DATA(nr))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return syscall_get_nr(current, regs);
>> + =A0 =A0 if (off =3D=3D BPF_DATA(arch))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return syscall_get_arch(current, regs);
>> + =A0 =A0 if (off =3D=3D BPF_DATA(instruction_pointer))
>> + =A0 =A0 =A0 =A0 =A0 =A0 return get_u32(KSTK_EIP(current), 0);
>> + =A0 =A0 if (off =3D=3D BPF_DATA(instruction_pointer) + sizeof(u32)=
)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return get_u32(KSTK_EIP(current), 1);
>
> I'd put the IP checks at the end, as it's the least likely case.
> But maybe gcc is smart enough to detect a pattern.

Will do

>> + =A0 =A0 if (off >=3D BPF_DATA(args[0]) && off < BPF_DATA(args[6]))=
 {
>> + =A0 =A0 =A0 =A0 =A0 =A0 unsigned long value;
>> + =A0 =A0 =A0 =A0 =A0 =A0 int arg =3D (off - BPF_DATA(args[0])) / si=
zeof(u64);
>> + =A0 =A0 =A0 =A0 =A0 =A0 int index =3D !!(off % sizeof(u64));
>> + =A0 =A0 =A0 =A0 =A0 =A0 syscall_get_arguments(current, regs, arg, =
1, &value);
>> + =A0 =A0 =A0 =A0 =A0 =A0 return get_u32(value, index);
>> + =A0 =A0 }
>> + =A0 =A0 /* seccomp_chk_filter should make this impossible. */
>> + =A0 =A0 BUG();
>> +}
>> +
>> +/**
>> + * =A0 seccomp_chk_filter - verify seccomp filter code
>> + * =A0 @filter: filter to verify
>> + * =A0 @flen: length of filter
>> + *
>> + * Takes a previously checked filter (by sk_chk_filter) and
>> + * redirects all filter code that loads struct sk_buff data
>> + * and related data through seccomp_bpf_load. =A0It also
>> + * enforces length and alignment checking of those loads.
>> + *
>> + * Returns 0 if the rule set is legal or -EINVAL if not.
>> + */
>> +static int seccomp_chk_filter(struct sock_filter *filter, unsigned =
int flen)
>> +{
>> + =A0 =A0 int pc;
>> + =A0 =A0 for (pc =3D 0; pc < flen; pc++) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct sock_filter *ftest =3D &filter[pc];
>> + =A0 =A0 =A0 =A0 =A0 =A0 u16 code =3D ftest->code;
>> + =A0 =A0 =A0 =A0 =A0 =A0 u32 k =3D ftest->k;
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (code <=3D BPF_S_ALU_NEG)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* Do not allow ancillary codes (incl. BPF=
_S_ANC_SECCOMP_*) */
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (code >=3D BPF_S_ANC_PROTOCOL)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (code >=3D BPF_S_LDX_IMM)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>
> I know I did the same in my code, but to avoid silly bugs when someon=
e changes
> the enum in filter.h without being aware of SECCOMP, it's much safer =
to check
> all known good instructions explicitly in a big switch. And the compi=
ler is
> hopefully smart enough to generate pretty much the same code as now. =
Then if
> new cases are added or existing ones swapped around, everything will =
still
> work and we don't end up with a silent security hole.

Anything before BPF_S_ANC_* is unlikely to change, and anything after
BPF_S_ANC_* is blacklisted.  However, you're right, if someone changes
the enum and array tables unexpectedly, this would be a problem.  Ew.
I'll push bits around and see what comes out.  I would almost prefer a
comment in filter.h than enumerating all the ALU instructions, etc
here.  Ah well.

> The reason I didn't do that was laziness and because it looks ugly. B=
ut it's
> more robust and I don't see a better way to get the same guarantees.

True, though the changes to make it a problem would be severe.

>> + =A0 =A0 =A0 =A0 =A0 =A0 switch (code) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_LD_W_ABS:
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_ANC_=
SECCOMP_LD_W;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* 32-bit aligned and not =
out of bounds. */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (k >=3D sizeof(struct s=
eccomp_data) || k & 3)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EI=
NVAL;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> + =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_LD_W_LEN:
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_LD_I=
MM;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->k =3D sizeof(struct=
 seccomp_data);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> + =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_LD_IMM:
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> + =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_LDX_W_LEN:
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->code =3D BPF_S_LDX_=
IMM;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ftest->k =3D sizeof(struct=
 seccomp_data);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> + =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_LD_W_IND:
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* XXX: would runtime secc=
omp_bpf_load checking k */
>
> Why? I checked your example code and haven't seen one case where you'=
re
> not using absolute loads. That said, I can think of situations where =
it's
> nice to be able to store the syscall and argument numbers in MEM and =
use
> an indirect load instead of changing the instructions themselves. But=
 I
> don't think it's worth the trouble supporting this, as it's only a mi=
nor
> improvement while it adds more messy code just for this.

LD_W_IND is for using a index into the data stored in X.  It is pretty
unlikely that a system call argument will supply a value that
determines where to index into the data again.  (e.g., seccomp_data[X
+ k]).  If it turns out it is needed, then someone can change the
seccomp_bpf_load() prototype to allow returning an error and checking
if k is outside of a sane bounds.

>> +/**
>> + * seccomp_attach_filter: Attaches a seccomp filter to current.
>> + * @fprog: BPF program to install
>> + *
>> + * Returns 0 on success or an errno on failure.
>> + */
>> +static long seccomp_attach_filter(struct sock_fprog *fprog)
>> +{
>> + =A0 =A0 struct seccomp_filter *filter;
>> + =A0 =A0 unsigned long fp_size =3D fprog->len * sizeof(struct sock_=
filter);
>> + =A0 =A0 unsigned long total_insns =3D 0;
>> + =A0 =A0 long ret;
>> +
>> + =A0 =A0 if (fprog->len =3D=3D 0 || fprog->len > BPF_MAXINSNS)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
>> +
>> + =A0 =A0 for (filter =3D current->seccomp.filter; filter; filter =3D=
 filter->prev)
>> + =A0 =A0 =A0 =A0 =A0 =A0 total_insns +=3D filter->len;
>
> More accurate and better in case of one instruction filters:
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0total_insns +=3D filter->len + 4;
>
> This to penalize tiny filters, otherwise a filter with one instructio=
n will
> use a lot more memory than just 8 bytes, so your effective max memory=
 usage
> would be much higher. It also depends on kzalloc's minimum allocation=
 size
> and rounding, so all in all 4 seems like a good number.

Well I'd prefer sizeof(struct seccomp_filter), but then the size
bounding would vary based on arch pointer size.  Perhaps something
larger would be better: 16 or 32.  That or just further decrease the
total allowed instructions.

>> + =A0 =A0 if (total_insns > MAX_INSNS_PER_PATH - fprog->len)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return -ENOSPC;
>
> It seems more readable to me to initialize total_insns to fprog->len
> instead of zero, and then drop the substraction. Overflows aren't
> possible either way.

Ok

> "No space left on device" isn't suitable either, I think. What's wron=
g
> with just using ENOMEM?

It's not really ENOMEM either.  It's more like EPERM or EACCES given
that the upper bounds has been hit and it is an administrative policy,
even if hard-coded.  It's just that we end up with overlapping errnos
for disparate failure modes, so I was hoping it would make sense to
use one logically applied (assuming BPF programs live in a bpf device
:).

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
>> + =A0 =A0 if (!user_filter)
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>
> This case should be handled by copy_from_user() already, so adding th=
is
> check doesn't add anything at all. Zero is only one out of many inval=
id
> pointers, why check for 0 but not for e.g. 1, 2, 3, 4, 5, 6, 7, 8 or =
9?

I guess so. This cause in the access_ok checks and not just a simple
cmp.  I think this is cleaner, but I'll drop it.

> Reviewed-by: Indan Zupancic <indan@nul.nu>

Thanks!  Next rev underway soonish.
will
