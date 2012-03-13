From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v14 01/13] sk_run_filter: add BPF_S_ANC_SECCOMP_LD_W
Date: Tue, 13 Mar 2012 10:43:24 -0500
Message-ID: <CABqD9hY-vdfNwWKE7iZsJ_owQrHXUu6msbQJZ_ap4w+i8zSPYg@mail.gmail.com>
References: <1331587715-26069-1-git-send-email-wad@chromium.org>
	<0c55cb258e0b5bbd615923ee2a9f06b9.squirrel@webmail.greenhost.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
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
	keescook@chromium.org
To: Indan Zupancic <indan@nul.nu>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <0c55cb258e0b5bbd615923ee2a9f06b9.squirrel@webmail.greenhost.nl>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 13, 2012 at 5:04 AM, Indan Zupancic <indan@nul.nu> wrote:
> Hello,
>
> I made a quick pseudo-patch for BPF JIT support. As far as I can tell=
,
> the actual code itself is very simple, just:

Awesome - yet another reason this approach is nicer.  When I'm done
working up v15, I'll pull in this patch and see what explodes and/or
runs really fast.

cheers!
will

> case BPF_S_ANC_SECCOMP_LD_W:
> =A0 =A0 =A0 =A0/* SECCOMP doesn't use SKB, no need to preserve %rdi. =
*/
> =A0 =A0 =A0 =A0t_offset =3D seccomp_bpf_load - (image + addrs[i]);
> =A0 =A0 =A0 =A0EMIT1_off32(0xbf, K); /* mov imm32,%rdi */
> =A0 =A0 =A0 =A0EMIT1_off32(0xe8, t_offset); /* call */
> =A0 =A0 =A0 =A0break;
>
> EAX is set directly as it's the return register, EBX is preserved by =
the
> callee, RDI and other registers are unused by seccomp, so no need for
> trampoline code AFAIK.
>
> The rest of the patch just makes the JIT code suitable for sharing.
> Only real change is that after this patch unused insns memory is free=
d.
>
> The code is untested and even uncompiled, as I've only access to my 3=
2-bit
> laptop at the moment.
>
> Would be interesting to know if this actually works and what the perf=
ormance
> difference is for seccomp.
>
> Greetings,
>
> Indan
>
>
> =A0arch/x86/net/bpf_jit_comp.c | =A0 47 ++++++++++++++++++++---------=
-------------
> =A0include/linux/filter.h =A0 =A0 =A0| =A0 14 +++++++-----
> =A0net/core/filter.c =A0 =A0 =A0 =A0 =A0 | =A0 27 +++++++++++++++++++=
+++--
> =A03 files changed, 54 insertions(+), 34 deletions(-)
>
> ---
>
> diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.=
c
> index 7c1b765..3cd6626 100644
> --- a/arch/x86/net/bpf_jit_comp.c
> +++ b/arch/x86/net/bpf_jit_comp.c
> @@ -118,7 +118,7 @@ static inline void bpf_flush_icache(void *start, =
void *end)
> =A0}
>
>
> -void bpf_jit_compile(struct sk_filter *fp)
> +bpf_func_t bpf_jit_compile(const struct sock_filter* filter, int fle=
n, int use_skb)
> =A0{
> =A0 =A0 =A0 =A0u8 temp[64];
> =A0 =A0 =A0 =A0u8 *prog;
> @@ -131,15 +131,13 @@ void bpf_jit_compile(struct sk_filter *fp)
> =A0 =A0 =A0 =A0int pc_ret0 =3D -1; /* bpf index of first RET #0 instr=
uction (if any) */
> =A0 =A0 =A0 =A0unsigned int cleanup_addr; /* epilogue code offset */
> =A0 =A0 =A0 =A0unsigned int *addrs;
> - =A0 =A0 =A0 const struct sock_filter *filter =3D fp->insns;
> - =A0 =A0 =A0 int flen =3D fp->len;
>
> =A0 =A0 =A0 =A0if (!bpf_jit_enable)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>
> =A0 =A0 =A0 =A0addrs =3D kmalloc(flen * sizeof(*addrs), GFP_KERNEL);
> =A0 =A0 =A0 =A0if (addrs =3D=3D NULL)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>
> =A0 =A0 =A0 =A0/* Before first pass, make a rough estimation of addrs=
[]
> =A0 =A0 =A0 =A0 * each bpf instruction is translated to less than 64 =
bytes
> @@ -151,11 +149,16 @@ void bpf_jit_compile(struct sk_filter *fp)
> =A0 =A0 =A0 =A0cleanup_addr =3D proglen; /* epilogue address */
>
> =A0 =A0 =A0 =A0for (pass =3D 0; pass < 10; pass++) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 u8 seen_or_pass0 =3D (pass =3D=3D 0) ? =
(SEEN_XREG | SEEN_DATAREF | SEEN_MEM) : seen;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u8 seen_or_pass0 =3D seen;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* no prologue/epilogue for trivial fi=
lters (RET something) */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0proglen =3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0prog =3D temp;
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pass =3D=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 seen_or_pass0 =3D SEEN_=
XREG | SEEN_MEM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (use_skb)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 seen_or=
_pass0 |=3D SEEN_DATAREF;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (seen_or_pass0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0EMIT4(0x55, 0x48, 0x89=
, 0xe5); /* push %rbp; mov %rsp,%rbp */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0EMIT4(0x48, 0x83, 0xec=
, 96); =A0 =A0/* subq =A0$96,%rsp =A0 =A0 =A0 */
> @@ -472,6 +475,14 @@ void bpf_jit_compile(struct sk_filter *fp)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0CLEAR_=
A();
> =A0#endif
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> +#ifdef CONFIG_SECCOMP_FILTER
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_ANC_SECCOMP_=
LD_W:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* SECC=
OMP doesn't use SKB, no need to preserve %rdi. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 t_offse=
t =3D seccomp_bpf_load - (image + addrs[i]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 EMIT1_o=
ff32(0xbf, K); /* mov imm32,%rdi */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 EMIT1_o=
ff32(0xe8, t_offset); /* call */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +#endif
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_LD_W_ABS:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0func =3D=
 sk_load_word;
> =A0common_load: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 seen |=3D SEEN_DA=
TAREF;
> @@ -588,13 +599,14 @@ cond_branch: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0f_offset =3D addrs[i + filter[i].jf] - addrs[i];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* hmm=
, too complex filter, give up with jit compiler */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto o=
ut;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(!use_skb && (see=
n & SEEN_DATAREF));
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ilen =3D prog - temp;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (image) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (un=
likely(proglen + ilen > oldproglen)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0pr_err("bpb_jit_compile fatal error\n");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0kfree(addrs);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0module_free(NULL, image);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 return;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 return NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memcpy=
(image + proglen, temp, ilen);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> @@ -635,28 +647,13 @@ cond_branch: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0f_offset =3D addrs[i + filter[i].jf] - addrs[i];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 16, 1, image, proglen, false);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bpf_flush_icache(image, image + progle=
n);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 fp->bpf_func =3D (void *)image;
> =A0 =A0 =A0 =A0}
> =A0out:
> =A0 =A0 =A0 =A0kfree(addrs);
> - =A0 =A0 =A0 return;
> + =A0 =A0 =A0 return (void *)image;
> =A0}
>
> -static void jit_free_defer(struct work_struct *arg)
> +void bpf_jit_free(bpf_func_t image)
> =A0{
> - =A0 =A0 =A0 module_free(NULL, arg);
> -}
> -
> -/* run from softirq, we must use a work_struct to call
> - * module_free() from process context
> - */
> -void bpf_jit_free(struct sk_filter *fp)
> -{
> - =A0 =A0 =A0 if (fp->bpf_func !=3D sk_run_filter) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct work_struct *work =3D (struct wo=
rk_struct *)fp->bpf_func;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 INIT_WORK(work, jit_free_defer);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule_work(work);
> - =A0 =A0 =A0 }
> + =A0 =A0 =A0 module_free(NULL, image);
> =A0}
> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index 8eeb205..292ccca 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -135,12 +135,13 @@ struct sock_fprog { =A0 =A0 =A0 /* Required for=
 SO_ATTACH_FILTER. */
> =A0struct sk_buff;
> =A0struct sock;
>
> +typedef unsigned int (*bpf_func_t)(const struct sk_buff*, const stru=
ct sock_filter*);
> +
> =A0struct sk_filter
> =A0{
> =A0 =A0 =A0 =A0atomic_t =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0refcnt;
> =A0 =A0 =A0 =A0unsigned int =A0 =A0 =A0 =A0 =A0 =A0len; =A0 =A0/* Num=
ber of filter blocks */
> - =A0 =A0 =A0 unsigned int =A0 =A0 =A0 =A0 =A0 =A0(*bpf_func)(const s=
truct sk_buff *skb,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 const struct sock_filter *filter);
> + =A0 =A0 =A0 bpf_func_t =A0 =A0 =A0 =A0 =A0 =A0 =A0bpf_func;
> =A0 =A0 =A0 =A0struct rcu_head =A0 =A0 =A0 =A0 rcu;
> =A0 =A0 =A0 =A0struct sock_filter =A0 =A0 =A0insns[0];
> =A0};
> @@ -158,14 +159,15 @@ extern int sk_detach_filter(struct sock *sk);
> =A0extern int sk_chk_filter(struct sock_filter *filter, unsigned int =
flen);
>
> =A0#ifdef CONFIG_BPF_JIT
> -extern void bpf_jit_compile(struct sk_filter *fp);
> -extern void bpf_jit_free(struct sk_filter *fp);
> +extern bpf_func_t bpf_jit_compile(const struct sock_filter*, int fle=
n, int use_skb);
> +extern void bpf_jit_free(bpf_funct_t);
> =A0#define SK_RUN_FILTER(FILTER, SKB) (*FILTER->bpf_func)(SKB, FILTER=
->insns)
> =A0#else
> -static inline void bpf_jit_compile(struct sk_filter *fp)
> +static inline bpf_func_t bpf_jit_compile(const struct sock_filter*, =
int flen, int use_skb)
> =A0{
> + =A0 =A0 =A0 return NULL;
> =A0}
> -static inline void bpf_jit_free(struct sk_filter *fp)
> +static inline void bpf_jit_free(bpf_func_t)
> =A0{
> =A0}
> =A0#define SK_RUN_FILTER(FILTER, SKB) sk_run_filter(SKB, FILTER->insn=
s)
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 5dea452..03e3ea3 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -574,6 +574,14 @@ int sk_chk_filter(struct sock_filter *filter, un=
signed int flen)
> =A0}
> =A0EXPORT_SYMBOL(sk_chk_filter);
>
> +/* run from softirq, we must use a work_struct to call
> + * bpf_jit_free() from process context
> + */
> +static void jit_free_defer(struct work_struct *arg)
> +{
> + =A0 =A0 =A0 bpf_jit_free((bpf_func_t)arg);
> +}
> +
> =A0/**
> =A0* =A0 =A0 sk_filter_release_rcu - Release a socket filter by rcu_h=
ead
> =A0* =A0 =A0 @rcu: rcu_head that contains the sk_filter to free
> @@ -582,7 +590,12 @@ void sk_filter_release_rcu(struct rcu_head *rcu)
> =A0{
> =A0 =A0 =A0 =A0struct sk_filter *fp =3D container_of(rcu, struct sk_f=
ilter, rcu);
>
> - =A0 =A0 =A0 bpf_jit_free(fp);
> + =A0 =A0 =A0 if (fp->bpf_func !=3D sk_run_filter) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct work_struct *work =3D (struct wo=
rk_struct *)fp->bpf_func;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 INIT_WORK(work, jit_free_defer);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule_work(work);
> + =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0kfree(fp);
> =A0}
> =A0EXPORT_SYMBOL(sk_filter_release_rcu);
> @@ -599,9 +612,10 @@ EXPORT_SYMBOL(sk_filter_release_rcu);
> =A0*/
> =A0int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
> =A0{
> - =A0 =A0 =A0 struct sk_filter *fp, *old_fp;
> + =A0 =A0 =A0 struct sk_filter *fp, *old_fp, *new_fp;
> =A0 =A0 =A0 =A0unsigned int fsize =3D sizeof(struct sock_filter) * fp=
rog->len;
> =A0 =A0 =A0 =A0int err;
> + =A0 =A0 =A0 bpf_func_t jit;
>
> =A0 =A0 =A0 =A0/* Make sure new filter is there and in the right amou=
nts. */
> =A0 =A0 =A0 =A0if (fprog->filter =3D=3D NULL)
> @@ -625,7 +639,14 @@ int sk_attach_filter(struct sock_fprog *fprog, s=
truct sock *sk)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return err;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 bpf_jit_compile(fp);
> + =A0 =A0 =A0 jit =3D bpf_jit_compile(fp->insns, fp->len, 1);
> + =A0 =A0 =A0 if (jit) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 fp->bpf_func =3D jit;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Free unused insns memory */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 newfp =3D krealloc(fp, sizeof(*fp), GFP=
_KERNEL);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (newfp)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fp =3D newfp;
> + =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0old_fp =3D rcu_dereference_protected(sk->sk_filter,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 sock_owned_by_user(sk));
>
>
>
