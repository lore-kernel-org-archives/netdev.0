From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH] ebpf: verify the output of the JIT
Date: Tue, 4 Apr 2017 15:17:57 -0700
Message-ID: <CAGXu5jLAXDk1+kYTC60-sJ_SOa5s4+HZ26A0bj67335yAXYhvg@mail.gmail.com>
References: <20170404220810.14250-1-tycho@docker.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>
To: Tycho Andersen <tycho@docker.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170404220810.14250-1-tycho@docker.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 4, 2017 at 3:08 PM, Tycho Andersen <tycho@docker.com> wrote:
> The goal of this patch is to protect the JIT against an attacker with a
> write-in-memory primitive. The JIT allocates a buffer which will eventual=
ly
> be marked +x, so we need to make sure that what was written to this buffe=
r
> is what was intended.
>
> We acheive this by building a hash of the instruction buffer as
> instructions are emittted and then comparing that to a hash at the end of
> the JIT compile after the buffer has been marked read-only.
>
> Signed-off-by: Tycho Andersen <tycho@docker.com>
> CC: Daniel Borkmann <daniel@iogearbox.net>
> CC: Alexei Starovoitov <ast@kernel.org>
> CC: Kees Cook <keescook@chromium.org>
> CC: Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>

Cool! This closes the race condition on producing the JIT vs going
read-only. I wonder if it might be possible to make this a more
generic interface to the BPF which would be allocate the hash, provide
the update callback during emit, and then do the hash check itself at
the end of bpf_jit_binary_lock_ro()?

-Kees

> ---
>  arch/x86/Kconfig            |  11 ++++
>  arch/x86/net/bpf_jit_comp.c | 147 ++++++++++++++++++++++++++++++++++++++=
++----
>  2 files changed, 147 insertions(+), 11 deletions(-)
>
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index cc98d5a..7b2db2c 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -2789,6 +2789,17 @@ config X86_DMA_REMAP
>
>  source "net/Kconfig"
>
> +config EBPF_JIT_HASH_OUTPUT
> +       def_bool y
> +       depends on HAVE_EBPF_JIT
> +       depends on BPF_JIT
> +       select CRYPTO_SHA256
> +       ---help---
> +         Enables a double check of the JIT's output after it is marked r=
ead-only to
> +         ensure that it matches what the JIT generated.
> +
> +         Note, only applies when /proc/sys/net/core/bpf_jit_harden > 0.
> +
>  source "drivers/Kconfig"
>
>  source "drivers/firmware/Kconfig"
> diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
> index 32322ce..be1271e 100644
> --- a/arch/x86/net/bpf_jit_comp.c
> +++ b/arch/x86/net/bpf_jit_comp.c
> @@ -13,9 +13,15 @@
>  #include <linux/if_vlan.h>
>  #include <asm/cacheflush.h>
>  #include <linux/bpf.h>
> +#include <linux/crypto.h>
> +#include <crypto/hash.h>
>
>  int bpf_jit_enable __read_mostly;
>
> +#ifdef CONFIG_EBPF_JIT_HASH_OUTPUT
> +struct crypto_shash *tfm __read_mostly;
> +#endif
> +
>  /*
>   * assembly code in arch/x86/net/bpf_jit.S
>   */
> @@ -25,7 +31,8 @@ extern u8 sk_load_byte_positive_offset[];
>  extern u8 sk_load_word_negative_offset[], sk_load_half_negative_offset[]=
;
>  extern u8 sk_load_byte_negative_offset[];
>
> -static u8 *emit_code(u8 *ptr, u32 bytes, unsigned int len)
> +static u8 *emit_code(u8 *ptr, u32 bytes, unsigned int len,
> +                    struct shash_desc *hash)
>  {
>         if (len =3D=3D 1)
>                 *ptr =3D bytes;
> @@ -35,11 +42,15 @@ static u8 *emit_code(u8 *ptr, u32 bytes, unsigned int=
 len)
>                 *(u32 *)ptr =3D bytes;
>                 barrier();
>         }
> +
> +       if (IS_ENABLED(CONFIG_EBPF_JIT_HASH_OUTPUT) && hash)
> +               crypto_shash_update(hash, (u8 *) &bytes, len);
> +
>         return ptr + len;
>  }
>
>  #define EMIT(bytes, len) \
> -       do { prog =3D emit_code(prog, bytes, len); cnt +=3D len; } while =
(0)
> +       do { prog =3D emit_code(prog, bytes, len, hash); cnt +=3D len; } =
while (0)
>
>  #define EMIT1(b1)              EMIT(b1, 1)
>  #define EMIT2(b1, b2)          EMIT((b1) + ((b2) << 8), 2)
> @@ -206,7 +217,7 @@ struct jit_context {
>  /* emit x64 prologue code for BPF program and check it's size.
>   * bpf_tail_call helper will skip it while jumping into another program
>   */
> -static void emit_prologue(u8 **pprog)
> +static void emit_prologue(u8 **pprog, struct shash_desc *hash)
>  {
>         u8 *prog =3D *pprog;
>         int cnt =3D 0;
> @@ -264,7 +275,7 @@ static void emit_prologue(u8 **pprog)
>   *   goto *(prog->bpf_func + prologue_size);
>   * out:
>   */
> -static void emit_bpf_tail_call(u8 **pprog)
> +static void emit_bpf_tail_call(u8 **pprog, struct shash_desc *hash)
>  {
>         u8 *prog =3D *pprog;
>         int label1, label2, label3;
> @@ -328,7 +339,7 @@ static void emit_bpf_tail_call(u8 **pprog)
>  }
>
>
> -static void emit_load_skb_data_hlen(u8 **pprog)
> +static void emit_load_skb_data_hlen(u8 **pprog, struct shash_desc *hash)
>  {
>         u8 *prog =3D *pprog;
>         int cnt =3D 0;
> @@ -348,7 +359,8 @@ static void emit_load_skb_data_hlen(u8 **pprog)
>  }
>
>  static int do_jit(struct bpf_prog *bpf_prog, int *addrs, u8 *image,
> -                 int oldproglen, struct jit_context *ctx)
> +                 int oldproglen, struct jit_context *ctx,
> +                 struct shash_desc *hash)
>  {
>         struct bpf_insn *insn =3D bpf_prog->insnsi;
>         int insn_cnt =3D bpf_prog->len;
> @@ -360,10 +372,10 @@ static int do_jit(struct bpf_prog *bpf_prog, int *a=
ddrs, u8 *image,
>         int proglen =3D 0;
>         u8 *prog =3D temp;
>
> -       emit_prologue(&prog);
> +       emit_prologue(&prog, hash);
>
>         if (seen_ld_abs)
> -               emit_load_skb_data_hlen(&prog);
> +               emit_load_skb_data_hlen(&prog, hash);
>
>         for (i =3D 0; i < insn_cnt; i++, insn++) {
>                 const s32 imm32 =3D insn->imm;
> @@ -875,7 +887,7 @@ xadd:                       if (is_imm8(insn->off))
>                         if (seen_ld_abs) {
>                                 if (reload_skb_data) {
>                                         EMIT1(0x5F); /* pop %rdi */
> -                                       emit_load_skb_data_hlen(&prog);
> +                                       emit_load_skb_data_hlen(&prog, ha=
sh);
>                                 } else {
>                                         EMIT2(0x41, 0x59); /* pop %r9 */
>                                         EMIT2(0x41, 0x5A); /* pop %r10 */
> @@ -884,7 +896,7 @@ xadd:                       if (is_imm8(insn->off))
>                         break;
>
>                 case BPF_JMP | BPF_CALL | BPF_X:
> -                       emit_bpf_tail_call(&prog);
> +                       emit_bpf_tail_call(&prog, hash);
>                         break;
>
>                         /* cond jump */
> @@ -1085,6 +1097,106 @@ xadd:                   if (is_imm8(insn->off))
>         return proglen;
>  }
>
> +#ifdef CONFIG_EBPF_JIT_HASH_OUTPUT
> +static struct shash_desc *bpf_alloc_hash_desc(void)
> +{
> +       struct shash_desc *hash;
> +       int sz =3D sizeof(struct shash_desc) + crypto_shash_descsize(tfm)=
;
> +
> +       hash =3D kzalloc(sz, GFP_KERNEL);
> +       if (hash)
> +               hash->tfm =3D tfm;
> +       return hash;
> +}
> +
> +static int init_hash(struct shash_desc **hash, u32 *nonce)
> +{
> +       if (!bpf_jit_harden)
> +               return 0;
> +
> +       *nonce =3D get_random_int();
> +
> +       if (!tfm) {
> +               tfm =3D crypto_alloc_shash("sha256", 0, 0);
> +               if (IS_ERR(tfm))
> +                       return PTR_ERR(tfm);
> +       }
> +
> +       if (!*hash) {
> +               *hash =3D bpf_alloc_hash_desc();
> +               if (!*hash)
> +                       return -ENOMEM;
> +       }
> +
> +       if (crypto_shash_init(*hash) < 0)
> +               return -1;
> +
> +       return crypto_shash_update(*hash, (u8 *) nonce, sizeof(*nonce));
> +}
> +
> +static bool check_jit_hash(u8 *buf, u32 len, struct shash_desc *out_d,
> +                          u32 nonce)
> +{
> +       struct shash_desc *check_d;
> +       void *out, *check;
> +       unsigned int sz;
> +       bool match =3D false;
> +
> +       if (!out_d)
> +               return 0;
> +
> +       BUG_ON(out_d->tfm !=3D tfm);
> +
> +       sz =3D crypto_shash_digestsize(out_d->tfm);
> +       out =3D kzalloc(2 * sz, GFP_KERNEL);
> +       if (!out)
> +               return false;
> +
> +       if (crypto_shash_final(out_d, out) < 0) {
> +               kfree(out);
> +               return false;
> +       }
> +
> +       check_d =3D bpf_alloc_hash_desc();
> +       if (!check_d) {
> +               kfree(out);
> +               return false;
> +       }
> +
> +       if (crypto_shash_init(check_d) < 0)
> +               goto out;
> +
> +       if (crypto_shash_update(check_d, (u8 *) &nonce, sizeof(nonce)) < =
0)
> +               goto out;
> +
> +       if (crypto_shash_update(check_d, buf, len) < 0)
> +               goto out;
> +
> +       check =3D out + sz;
> +       if (crypto_shash_final(check_d, check) < 0)
> +               goto out;
> +
> +       if (!memcmp(out, check, sz))
> +               match =3D true;
> +
> +out:
> +       kfree(out);
> +       kfree(check_d);
> +       return match;
> +}
> +#else
> +static int init_hash(struct shash_desc **hash, u32 *nonce)
> +{
> +       return 0;
> +}
> +
> +static bool check_jit_hash(u8 *buf, u32 len, struct shash_desc *out_d,
> +                          u32 nonce)
> +{
> +       return true;
> +}
> +#endif
> +
>  struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
>  {
>         struct bpf_binary_header *header =3D NULL;
> @@ -1096,6 +1208,8 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_pro=
g *prog)
>         int *addrs;
>         int pass;
>         int i;
> +       struct shash_desc *hash =3D NULL;
> +       u32 nonce;
>
>         if (!bpf_jit_enable)
>                 return orig_prog;
> @@ -1132,7 +1246,15 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_pr=
og *prog)
>          * pass to emit the final image
>          */
>         for (pass =3D 0; pass < 10 || image; pass++) {
> -               proglen =3D do_jit(prog, addrs, image, oldproglen, &ctx);
> +               if (init_hash(&hash, &nonce) < 0) {
> +                       image =3D NULL;
> +                       if (header)
> +                               bpf_jit_binary_free(header);
> +                       prog =3D orig_prog;
> +                       goto out_addrs;
> +               }
> +
> +               proglen =3D do_jit(prog, addrs, image, oldproglen, &ctx, =
hash);
>                 if (proglen <=3D 0) {
>                         image =3D NULL;
>                         if (header)
> @@ -1166,6 +1288,8 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_pro=
g *prog)
>         if (image) {
>                 bpf_flush_icache(header, image + proglen);
>                 bpf_jit_binary_lock_ro(header);
> +               if (!check_jit_hash(image, proglen, hash, nonce))
> +                       BUG();
>                 prog->bpf_func =3D (void *)image;
>                 prog->jited =3D 1;
>         } else {
> @@ -1174,6 +1298,7 @@ struct bpf_prog *bpf_int_jit_compile(struct bpf_pro=
g *prog)
>
>  out_addrs:
>         kfree(addrs);
> +       kfree(hash);
>  out:
>         if (tmp_blinded)
>                 bpf_jit_prog_release_other(prog, prog =3D=3D orig_prog ?
> --
> 2.9.3
>



--=20
Kees Cook
Pixel Security
