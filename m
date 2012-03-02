From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v12 01/13] sk_run_filter: add support for custom load_pointer
Date: Fri, 2 Mar 2012 12:47:51 -0600
Message-ID: <CABqD9hYjdv5LOUKkD7ydddCA0MwLv69rq+GWAEaPaG7=dgYoiQ@mail.gmail.com>
References: <1330559620-23543-1-git-send-email-wad@chromium.org>
	<26411fc25ada53b95e90b6a5fa85ad44.squirrel@webmail.greenhost.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	x86@kernel.org, arnd@arndb.de, davem@davemloft.net, hpa@zytor.com,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
	luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, pmoore@redhat.com,
	akpm@linux-foundation.org, corbet@lwn.net, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, keescook@chromium.org
To: Indan Zupancic <indan@nul.nu>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:39959 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754539Ab2CBSry convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2012 13:47:54 -0500
Received: by lahj13 with SMTP id j13so2359106lah.19
        for <netdev@vger.kernel.org>; Fri, 02 Mar 2012 10:47:53 -0800 (PST)
In-Reply-To: <26411fc25ada53b95e90b6a5fa85ad44.squirrel@webmail.greenhost.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 2, 2012 at 4:40 AM, Indan Zupancic <indan@nul.nu> wrote:
> Hello,
>
> On Thu, March 1, 2012 00:53, Will Drewry wrote:
>> =A0include/linux/filter.h | =A0 46 +++++++++++++++++++
>> =A0net/core/filter.c =A0 =A0 =A0| =A0117 +++++++++++++++++++++++++++=
++++++++++++++++++---
>> =A02 files changed, 157 insertions(+), 6 deletions(-)
>
> I propose a slightly different approach:
>
> Instead of more or less allowing generic load instructions, do the
> same as the ancillary data functions and only allow BPF_S_LD_W_ABS.
> In addition to that, rewrite and check the functions ourself after
> sk_chk_filter() has done its checks.
>
> Diff for filter.c:
>
> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index 8eeb205..63b728c 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -228,6 +228,7 @@ enum {
> =A0 =A0 =A0 =A0BPF_S_ANC_HATYPE,
> =A0 =A0 =A0 =A0BPF_S_ANC_RXHASH,
> =A0 =A0 =A0 =A0BPF_S_ANC_CPU,
> + =A0 =A0 =A0 BPF_S_LD_W_SECCOMP,
> =A0};
>
> =A0#endif /* __KERNEL__ */
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 5dea452..7e338d6 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -350,6 +350,9 @@ load_b:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0A =3D =
0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_LD_W_SECCOMP:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 A =3D seccomp_load(fent=
ry->k);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;

This is plenty nice as far as I'm concerned.  I wonder what the
networking people think?

I proposed a generic bpf interface, but if simply scoping it down to a
single additional seccomp instruction is okay, then we can address
additional instruction support or other generalizations later when
there is a motivating case.


> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0default:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0WARN_RATELIMIT(1, "Unk=
nown code:%u jt:%u tf:%u k:%u\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 fentry->code, fentry->jt,
> ---
>
> And in seccomp add something like:
>
> /*
> =A0* Does SECCOMP specific checks.
> =A0* Should be called after sk_chk_filter(), as it assumes all instru=
ctions
> =A0* are rewritten to the kernel enum format.
> =A0* No SKB touching instructions are allowed. Only data LD instructi=
on allowed
> =A0* is BPF_S_LD_W_ABS, which will be handled by seccomp_load().
> =A0*/
> int seccomp_check_filter(const struct sock_filter *filter, unsigned i=
nt flen)
> {
> =A0 =A0 =A0 =A0int pc;
>
> =A0 =A0 =A0 =A0/* Make sure there are no SKB using instructions */
> =A0 =A0 =A0 =A0for (pc =3D 0; pc < flen; pc++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0u16 code =3D filter->code;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned int k =3D filter->k;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (code <=3D BPF_S_ALU_NEG)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (code >=3D BPF_S_LDX_IMM && code < =
BPF_S_ANC_PROTOCOL)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0switch (code) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_LD_W_ABS:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0filter->code =3D BPF_S=
_LD_W_SECCOMP;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (k >=3D sizeof(stru=
ct seccomp_data) || k & 3)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return=
 -EINVAL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_LD_W_LEN:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0filter->code =3D BPF_S=
_LD_IMM;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0filter->k =3D sizeof(s=
truct seccomp_data);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_LD_IMM:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_LDX_W_LEN:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0filter->code =3D BPF_S=
_LDX_IMM;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0filter->k =3D sizeof(s=
truct seccomp_data);

Mapping to LD[X]_IMM is really nice.

> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0default:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0return 0;
> }
>
> u32 seccomp_load(int off)
> {
> =A0 =A0 =A0 =A0u32 A;
> =A0 =A0 =A0 =A0struct pt_regs *regs =3D task_pt_regs(current);
>
> =A0 =A0 =A0 =A0if (off >=3D BPF_DATA(args[0]) && off < BPF_DATA(args[=
6])) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int arg =3D (off - BPF_DATA(args[0])) =
/ sizeof(u64);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int index =3D (off % sizeof(u64)) ? 1 =
: 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0syscall_get_arguments(current, regs, a=
rg, 1, &value);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0A =3D get_u32(value, index);
> =A0 =A0 =A0 =A0} else if (off =3D=3D BPF_DATA(nr)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0A =3D syscall_get_nr(current, regs);
> =A0 =A0 =A0 =A0} else if (off =3D=3D BPF_DATA(arch)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0A =3D syscall_get_arch(current, regs);
> =A0 =A0 =A0 =A0} else if (off =3D=3D BPF_DATA(instruction_pointer)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0A =3D get_u32(KSTK_EIP(current), 0);
> =A0 =A0 =A0 =A0} else if (off =3D=3D BPF_DATA(instruction_pointer) + =
sizeof(u32)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0A =3D get_u32(KSTK_EIP(current), 1);
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0return A;
> }
>
> This way you can even add SECCOMP specific functions in the future by=
 using
> special offsets. (E.g. 64-bit compare between an arg and scratch memo=
ry.)

Yeah this would be a nice option if a more specialized (yet less
invasive) approach is appealing to the networking people.  Eric, Joe,
netdev, ... any opinions?  Would a standalone version be more useful?

Thanks!
will
