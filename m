From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v8 1/8] sk_run_filter: add support for custom load_pointer
Date: Thu, 16 Feb 2012 14:08:54 -0600
Message-ID: <CABqD9hZp+bbe1=Y86cZKODAk_0wb1G98ugUusK7+eO=9eyeUUQ@mail.gmail.com>
References: <1329422549-16407-1-git-send-email-wad@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arch@vger.kernel.org, linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com, netdev@vger.kernel.org,
	x86@kernel.org, arnd@arndb.de, davem@davemloft.net, hpa@zytor.com,
	mingo@redhat.com, oleg@redhat.com, peterz@infradead.org,
	rdunlap@xenotime.net, mcgrathr@chromium.org, tglx@linutronix.de,
	luto@mit.edu, eparis@redhat.com, serge.hallyn@canonical.com,
	djm@mindrot.org, scarybeasts@gmail.com, indan@nul.nu,
	pmoore@redhat.com, akpm@linux-foundation.org, corbet@lwn.net,
	eric.dumazet@gmail.com, markus@chromium.org, keescook@chromium.org,
	Will Drewry <wad@chromium.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1329422549-16407-1-git-send-email-wad@chromium.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ouch. I cross-posted this whole series to
kernel-hardening@lists.openwall.org install of .com.  If you reply,
sorry for the extra bounce.

On Thu, Feb 16, 2012 at 2:02 PM, Will Drewry <wad@chromium.org> wrote:
> This change allows CONFIG_SECCOMP to make use of BPF programs for
> user-controlled system call filtering (as shown in this patch series)=
=2E
>
> To minimize the impact on existing BPF evaluation, function pointer
> use must be declared at sk_chk_filter-time. =A0This allows ancillary
> load instructions to be generated that use the function pointer rathe=
r
> than adding _any_ code to the existing LD_* instruction paths.
>
> Crude performance numbers using udpflood -l 10000000 against dummy0.
> 3 trials for baseline, 3 for with tcpdump. Averaged then differenced.
> Hard to believe trials were repeated at least a couple more times.
>
> * x86 32-bit (Atom N570 @ 1.66 GHz 2 core HT) [stackprot]:
> - Without: =A094.05s - 76.36s =3D 17.68s
> - With: =A0 =A0 86.22s - 73.30s =3D 12.92s
> - Slowdown per call: -476 nanoseconds
>
> * x86 32-bit (Atom N570 @ 1.66 GHz 2 core HT) [no stackprot]:
> - Without: =A092.06s - 77.81s =3D 14.25s
> - With: =A0 =A0 91.77s - 76.91s =3D 14.86s
> - Slowdown per call: +61 nanoseconds
>
> * x86 64-bit (Atom N570 @ 1.66 GHz 2 core HT) [stackprot]:
> - Without: 122.58s - 99.54s =3D 23.04s
> - With: =A0 =A0115.52s - 98.99s =3D 16.53s
> - Slowdown per call: =A0-651 nanoseconds
>
> * x86 64-bit (Atom N570 @ 1.66 GHz 2 core HT) [no stackprot]:
> - Without: 114.95s - 91.92s =3D 23.03s
> - With: =A0 =A0110.47s - 90.79s =3D 19.68s
> - Slowdown per call: -335 nanoseconds
>
> This makes the x86-32-nossp make sense. =A0Added register pressure al=
ways
> makes x86-32 sad. =A0If this is a concern, I could change the call
> approach to bpf_run_filter to see if I can alleviate it a bit.
>
> That said, the x86-*-ssp numbers show a marked increase in performanc=
e.
> I've tested and retested and I keep getting these results. I'm also
> suprised by the nossp speed up on 64-bit, but I dunno. I haven't look=
ed
> at the full disassembly of the call path. If that is required for the
> performance differences I'm seeing, please let me know. Or if I there=
 is
> a preferred cpu to run this against - atoms can be a little weird.
>
> v8: - fixed variable positioning and bad cast (eric.dumazet@gmail.com=
)
> =A0 =A0- no longer passes A as a pointer (inspection of x86 asm shows=
 A is
> =A0 =A0 =A0%ebx again; thanks eric.dumazet@gmail.com)
> =A0 =A0- cleaned up switch macros and expanded use
> =A0 =A0 =A0(joe@perches.com, indan@nul.nu)
> =A0 =A0- added length fn pointer and handled LD_W_LEN/LDX_W_LEN
> =A0 =A0- moved from a wrapping struct to a typedef for the function
> =A0 =A0 =A0pointer. (matches existing function pointer style)
> =A0 =A0- added comprehensive comment above the typedef.
> =A0 =A0- benchmarks
> v7: - first cut
>
> Signed-off-by: Will Drewry <wad@chromium.org>
> ---
> =A0include/linux/filter.h | =A0 69 +++++++++++++++++++++-
> =A0net/core/filter.c =A0 =A0 =A0| =A0152 ++++++++++++++++++++++++++++=
+++++++++----------
> =A02 files changed, 185 insertions(+), 36 deletions(-)
>
> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index 8eeb205..d22ad46 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -110,6 +110,9 @@ struct sock_fprog { /* Required for SO_ATTACH_FIL=
TER. */
> =A0*/
> =A0#define BPF_MEMWORDS 16
>
> +/* BPF program (checking) flags */
> +#define BPF_CHK_FLAGS_NO_SKB =A0 1
> +
> =A0/* RATIONALE. Negative offsets are invalid in BPF.
> =A0 =A0We use them to reference ancillary data.
> =A0 =A0Unlike introduction new instructions, it does not break
> @@ -145,17 +148,67 @@ struct sk_filter
> =A0 =A0 =A0 =A0struct sock_filter =A0 =A0 =A0insns[0];
> =A0};
>
> +/**
> + * struct bpf_load_fns - callbacks for bpf_run_filter
> + * These functions are called by bpf_run_filter if bpf_chk_filter
> + * was invoked with BPF_CHK_FLAGS_NO_SKB.
> + *
> + * pointer:
> + * @data: const pointer to the data passed into bpf_run_filter
> + * @k: offset into @skb's data
> + * @size: the size of the requested data in bytes: 1, 2, or 4.
> + * @buffer: If non-NULL, a 32-bit buffer for staging data.
> + *
> + * Returns a pointer to the requested data.
> + *
> + * This function operates similarly to load_pointer in net/core/filt=
er.c
> + * except that the pointer to the returned data must already be
> + * byteswapped as appropriate to the source data and endianness.
> + * @buffer may be used if the data needs to be staged.
> + *
> + * length:
> + * @data: const pointer to the data passed into bpf_fun_filter
> + *
> + * Returns the length of the data.
> + */
> +struct bpf_load_fns {
> + =A0 =A0 =A0 void *(*pointer)(const void *data, int k, unsigned int =
size,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0void *buffer);
> + =A0 =A0 =A0 u32 (*length)(const void *data);
> +};
> +
> =A0static inline unsigned int sk_filter_len(const struct sk_filter *f=
p)
> =A0{
> =A0 =A0 =A0 =A0return fp->len * sizeof(struct sock_filter) + sizeof(*=
fp);
> =A0}
>
> +extern unsigned int bpf_run_filter(const void *data,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
const struct sock_filter *filter,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
const struct bpf_load_fns *load_fn);
> +
> +/**
> + * =A0 =A0 sk_run_filter - run a filter on a socket
> + * =A0 =A0 @skb: buffer to run the filter on
> + * =A0 =A0 @fentry: filter to apply
> + *
> + * Runs bpf_run_filter with the struct sk_buff-specific data
> + * accessor behavior.
> + */
> +static inline unsigned int sk_run_filter(const struct sk_buff *skb,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0const struct sock_filter *filter)
> +{
> + =A0 =A0 =A0 return bpf_run_filter(skb, filter, NULL);
> +}
> +
> =A0extern int sk_filter(struct sock *sk, struct sk_buff *skb);
> -extern unsigned int sk_run_filter(const struct sk_buff *skb,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 con=
st struct sock_filter *filter);
> =A0extern int sk_attach_filter(struct sock_fprog *fprog, struct sock =
*sk);
> =A0extern int sk_detach_filter(struct sock *sk);
> -extern int sk_chk_filter(struct sock_filter *filter, unsigned int fl=
en);
> +extern int bpf_chk_filter(struct sock_filter *filter, unsigned int f=
len, u32 flags);
> +
> +static inline int sk_chk_filter(struct sock_filter *filter, unsigned=
 int flen)
> +{
> + =A0 =A0 =A0 return bpf_chk_filter(filter, flen, 0);
> +}
>
> =A0#ifdef CONFIG_BPF_JIT
> =A0extern void bpf_jit_compile(struct sk_filter *fp);
> @@ -228,6 +281,16 @@ enum {
> =A0 =A0 =A0 =A0BPF_S_ANC_HATYPE,
> =A0 =A0 =A0 =A0BPF_S_ANC_RXHASH,
> =A0 =A0 =A0 =A0BPF_S_ANC_CPU,
> + =A0 =A0 =A0 /* Used to differentiate SKB data and generic data */
> + =A0 =A0 =A0 BPF_S_ANC_LD_W_ABS,
> + =A0 =A0 =A0 BPF_S_ANC_LD_H_ABS,
> + =A0 =A0 =A0 BPF_S_ANC_LD_B_ABS,
> + =A0 =A0 =A0 BPF_S_ANC_LD_W_LEN,
> + =A0 =A0 =A0 BPF_S_ANC_LD_W_IND,
> + =A0 =A0 =A0 BPF_S_ANC_LD_H_IND,
> + =A0 =A0 =A0 BPF_S_ANC_LD_B_IND,
> + =A0 =A0 =A0 BPF_S_ANC_LDX_W_LEN,
> + =A0 =A0 =A0 BPF_S_ANC_LDX_B_MSH,
> =A0};
>
> =A0#endif /* __KERNEL__ */
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 5dea452..a5c98a9 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -98,9 +98,10 @@ int sk_filter(struct sock *sk, struct sk_buff *skb=
)
> =A0EXPORT_SYMBOL(sk_filter);
>
> =A0/**
> - * =A0 =A0 sk_run_filter - run a filter on a socket
> - * =A0 =A0 @skb: buffer to run the filter on
> + * =A0 =A0 bpf_run_filter - run a filter on a BPF program
> + * =A0 =A0 @data: buffer to run the filter on
> =A0* =A0 =A0 @fentry: filter to apply
> + * =A0 =A0 @load_fns: custom data accessor functions
> =A0*
> =A0* Decode and apply filter instructions to the skb->data.
> =A0* Return length to keep, 0 for none. @skb is the data we are
> @@ -108,9 +109,13 @@ EXPORT_SYMBOL(sk_filter);
> =A0* Because all jumps are guaranteed to be before last instruction,
> =A0* and last instruction guaranteed to be a RET, we dont need to che=
ck
> =A0* flen. (We used to pass to this function the length of filter)
> + *
> + * load_fn is only used if SKF_FLAGS_USE_LOAD_FNS was specified
> + * to sk_chk_generic_filter.
> =A0*/
> -unsigned int sk_run_filter(const struct sk_buff *skb,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const struct soc=
k_filter *fentry)
> +unsigned int bpf_run_filter(const void *data,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const struct so=
ck_filter *fentry,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const struct bp=
f_load_fns *load_fns)
> =A0{
> =A0 =A0 =A0 =A0void *ptr;
> =A0 =A0 =A0 =A0u32 A =3D 0; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
/* Accumulator */
> @@ -128,6 +133,7 @@ unsigned int sk_run_filter(const struct sk_buff *=
skb,
> =A0#else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const u32 K =3D fentry->k;
> =A0#endif
> +#define SKB(_data) ((const struct sk_buff *)(_data))
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0switch (fentry->code) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_ALU_ADD_X:
> @@ -213,7 +219,7 @@ unsigned int sk_run_filter(const struct sk_buff *=
skb,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_LD_W_ABS:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0k =3D K;
> =A0load_w:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptr =3D load_pointer(sk=
b, k, 4, &tmp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptr =3D load_pointer(da=
ta, k, 4, &tmp);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ptr !=3D NULL) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0A =3D =
get_unaligned_be32(ptr);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0contin=
ue;
> @@ -222,7 +228,7 @@ load_w:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_LD_H_ABS:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0k =3D K;
> =A0load_h:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptr =3D load_pointer(sk=
b, k, 2, &tmp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptr =3D load_pointer(da=
ta, k, 2, &tmp);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ptr !=3D NULL) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0A =3D =
get_unaligned_be16(ptr);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0contin=
ue;
> @@ -231,17 +237,17 @@ load_h:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_LD_B_ABS:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0k =3D K;
> =A0load_b:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptr =3D load_pointer(sk=
b, k, 1, &tmp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptr =3D load_pointer(da=
ta, k, 1, &tmp);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ptr !=3D NULL) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0A =3D =
*(u8 *)ptr;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0contin=
ue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_LD_W_LEN:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 A =3D skb->len;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 A =3D SKB(data)->len;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_LDX_W_LEN:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 X =3D skb->len;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 X =3D SKB(data)->len;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_LD_W_IND:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0k =3D X + K;
> @@ -253,7 +259,7 @@ load_b:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0k =3D X + K;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto load_b;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_LDX_B_MSH:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptr =3D load_pointer(sk=
b, K, 1, &tmp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptr =3D load_pointer(da=
ta, K, 1, &tmp);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ptr !=3D NULL) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0X =3D =
(*(u8 *)ptr & 0xf) << 2;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0contin=
ue;
> @@ -288,29 +294,29 @@ load_b:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem[K] =3D X;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_ANC_PROTOCOL:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 A =3D ntohs(skb->protoc=
ol);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 A =3D ntohs(SKB(data)->=
protocol);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_ANC_PKTTYPE:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 A =3D skb->pkt_type;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 A =3D SKB(data)->pkt_ty=
pe;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_ANC_IFINDEX:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!skb->dev)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!SKB(data)->dev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return=
 0;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 A =3D skb->dev->ifindex=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 A =3D SKB(data)->dev->i=
findex;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_ANC_MARK:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 A =3D skb->mark;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 A =3D SKB(data)->mark;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_ANC_QUEUE:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 A =3D skb->queue_mappin=
g;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 A =3D SKB(data)->queue_=
mapping;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_ANC_HATYPE:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!skb->dev)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!SKB(data)->dev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return=
 0;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 A =3D skb->dev->type;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 A =3D SKB(data)->dev->t=
ype;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_ANC_RXHASH:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 A =3D skb->rxhash;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 A =3D SKB(data)->rxhash=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_ANC_CPU:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0A =3D raw_smp_processo=
r_id();
> @@ -318,15 +324,15 @@ load_b:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_ANC_NLATTR: {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct nlattr *nla;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb_is_nonlinear(sk=
b))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb_is_nonlinear(SK=
B(data)))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return=
 0;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (A > skb->len - size=
of(struct nlattr))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (A > SKB(data)->len =
- sizeof(struct nlattr))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return=
 0;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nla =3D nla_find((struc=
t nlattr *)&skb->data[A],
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0skb->len - A, X);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nla =3D nla_find((struc=
t nlattr *)&SKB(data)->data[A],
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0SKB(data)->len - A, X);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (nla)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 A =3D (=
void *)nla - (void *)skb->data;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 A =3D (=
void *)nla - (void *)SKB(data)->data;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0A =3D =
0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> @@ -334,22 +340,71 @@ load_b:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_ANC_NLATTR_NEST: {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct nlattr *nla;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb_is_nonlinear(sk=
b))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb_is_nonlinear(SK=
B(data)))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return=
 0;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (A > skb->len - size=
of(struct nlattr))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (A > SKB(data)->len =
- sizeof(struct nlattr))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return=
 0;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nla =3D (struct nlattr =
*)&skb->data[A];
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nla->nla_len > A - =
skb->len)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nla =3D (struct nlattr =
*)&SKB(data)->data[A];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nla->nla_len > A - =
SKB(data)->len)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return=
 0;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nla =3D nla_find_neste=
d(nla, X);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (nla)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 A =3D (=
void *)nla - (void *)skb->data;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 A =3D (=
void *)nla - (void *)SKB(data)->data;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0A =3D =
0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_ANC_LD_W_ABS:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 k =3D K;
> +load_fn_w:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptr =3D load_fns->point=
er(data, k, 4, &tmp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ptr) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 A =3D *=
(u32 *)ptr;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continu=
e;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_ANC_LD_H_ABS:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 k =3D K;
> +load_fn_h:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptr =3D load_fns->point=
er(data, k, 2, &tmp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ptr) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 A =3D *=
(u16 *)ptr;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continu=
e;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_ANC_LD_B_ABS:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 k =3D K;
> +load_fn_b:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptr =3D load_fns->point=
er(data, k, 1, &tmp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ptr) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 A =3D *=
(u8 *)ptr;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continu=
e;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_ANC_LDX_B_MSH:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ptr =3D load_fns->point=
er(data, K, 1, &tmp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ptr) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 X =3D (=
*(u8 *)ptr & 0xf) << 2;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continu=
e;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_ANC_LD_W_IND:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 k =3D X + K;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto load_fn_w;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_ANC_LD_H_IND:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 k =3D X + K;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto load_fn_h;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_ANC_LD_B_IND:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 k =3D X + K;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto load_fn_b;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_ANC_LD_W_LEN:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 A =3D load_fns->length(=
data);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_ANC_LDX_W_LEN:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 X =3D load_fns->length(=
data);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0default:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0WARN_RATELIMIT(1, "Unk=
nown code:%u jt:%u tf:%u k:%u\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 fentry->code, fentry->jt,
> @@ -360,7 +415,7 @@ load_b:
>
> =A0 =A0 =A0 =A0return 0;
> =A0}
> -EXPORT_SYMBOL(sk_run_filter);
> +EXPORT_SYMBOL(bpf_run_filter);
>
> =A0/*
> =A0* Security :
> @@ -423,9 +478,10 @@ error:
> =A0}
>
> =A0/**
> - * =A0 =A0 sk_chk_filter - verify socket filter code
> + * =A0 =A0 bpf_chk_filter - verify socket filter BPF code
> =A0* =A0 =A0 @filter: filter to verify
> =A0* =A0 =A0 @flen: length of filter
> + * =A0 =A0 @flags: May be BPF_CHK_FLAGS_NO_SKB or 0
> =A0*
> =A0* Check the user's filter code. If we let some ugly
> =A0* filter code slip through kaboom! The filter must contain
> @@ -434,9 +490,13 @@ error:
> =A0*
> =A0* All jumps are forward as they are not signed.
> =A0*
> + * If BPF_CHK_FLAGS_NO_SKB is set in flags, any SKB-specific
> + * rules become illegal and a custom set of bpf_load_fns will
> + * be expected by bpf_run_filter.
> + *
> =A0* Returns 0 if the rule set is legal or -EINVAL if not.
> =A0*/
> -int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
> +int bpf_chk_filter(struct sock_filter *filter, unsigned int flen, u3=
2 flags)
> =A0{
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Valid instructions are initialized to non-0.
> @@ -542,9 +602,35 @@ int sk_chk_filter(struct sock_filter *filter, un=
signed int flen)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pc + ftest->jf=
 + 1 >=3D flen)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return=
 -EINVAL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> +#define MAYBE_USE_LOAD_FN(CODE) \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (flags & BPF_CHK_FLA=
GS_NO_SKB) { \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 code =3D=
 BPF_S_ANC_##CODE; \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break; =
\
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_LD_W_LEN:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MAYBE_USE_LOAD_FN(LD_W_=
LEN);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_LDX_W_LEN:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MAYBE_USE_LOAD_FN(LDX_W=
_LEN);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_LD_W_IND:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MAYBE_USE_LOAD_FN(LD_W_=
IND);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_LD_H_IND:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MAYBE_USE_LOAD_FN(LD_H_=
IND);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_LD_B_IND:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MAYBE_USE_LOAD_FN(LD_B_=
IND);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case BPF_S_LDX_B_MSH:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MAYBE_USE_LOAD_FN(LDX_B=
_MSH);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_LD_W_ABS:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MAYBE_USE_LOAD_FN(LD_W_=
ABS);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_LD_H_ABS:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MAYBE_USE_LOAD_FN(LD_H_=
ABS);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case BPF_S_LD_B_ABS:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MAYBE_USE_LOAD_FN(LD_B_=
ABS);
> =A0#define ANCILLARY(CODE) case SKF_AD_OFF + SKF_AD_##CODE: =A0 =A0 =A0=
 \
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0code =3D=
 BPF_S_ANC_##CODE; =A0 =A0 =A0 =A0\
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break
> @@ -572,7 +658,7 @@ int sk_chk_filter(struct sock_filter *filter, uns=
igned int flen)
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0return -EINVAL;
> =A0}
> -EXPORT_SYMBOL(sk_chk_filter);
> +EXPORT_SYMBOL(bpf_chk_filter);
>
> =A0/**
> =A0* =A0 =A0 sk_filter_release_rcu - Release a socket filter by rcu_h=
ead
> --
> 1.7.5.4
>
