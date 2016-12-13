From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: bloat-o-meter +32832 (was: Re: bpf: add prog_digest and expose it via fdinfo/netlink)
Date: Tue, 13 Dec 2016 10:29:45 +0100
Message-ID: <CAMuHMdUoadaRw9dAOkpzn9MKV=3AQhmtfMu_zzoT6_VmFaePQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Daniel,

On Mon, Dec 12, 2016 at 6:08 PM, Linux Kernel Mailing List
<linux-kernel@vger.kernel.org> wrote:
> Web:        https://git.kernel.org/torvalds/c/7bd509e311f408f7a5132fcdde2069af65fa05ae
> Commit:     7bd509e311f408f7a5132fcdde2069af65fa05ae
> Parent:     8d829bdb97dc3a0c9c8090b9b168ca46ea99c8d8
> Refname:    refs/heads/master
> Author:     Daniel Borkmann <daniel@iogearbox.net>
> AuthorDate: Sun Dec 4 23:19:41 2016 +0100
> Committer:  David S. Miller <davem@davemloft.net>
> CommitDate: Mon Dec 5 15:33:11 2016 -0500
>
>     bpf: add prog_digest and expose it via fdinfo/netlink
>
>     When loading a BPF program via bpf(2), calculate the digest over
>     the program's instruction stream and store it in struct bpf_prog's
>     digest member. This is done at a point in time before any instructions
>     are rewritten by the verifier. Any unstable map file descriptor
>     number part of the imm field will be zeroed for the hash.
>
>     fdinfo example output for progs:
>
>       # cat /proc/1590/fdinfo/5
>       pos:          0
>       flags:        02000002
>       mnt_id:       11
>       prog_type:    1
>       prog_jited:   1
>       prog_digest:  b27e8b06da22707513aa97363dfb11c7c3675d28
>       memlock:      4096
>
>     When programs are pinned and retrieved by an ELF loader, the loader
>     can check the program's digest through fdinfo and compare it against
>     one that was generated over the ELF file's program section to see
>     if the program needs to be reloaded. Furthermore, this can also be
>     exposed through other means such as netlink in case of a tc cls/act
>     dump (or xdp in future), but also through tracepoints or other
>     facilities to identify the program. Other than that, the digest can
>     also serve as a base name for the work in progress kallsyms support
>     of programs. The digest doesn't depend/select the crypto layer, since
>     we need to keep dependencies to a minimum. iproute2 will get support
>     for this facility.
>
>     Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
>     Acked-by: Alexei Starovoitov <ast@kernel.org>
>     Signed-off-by: David S. Miller <davem@davemloft.net>

> --- a/kernel/bpf/core.c
> +++ b/kernel/bpf/core.c
> @@ -136,6 +136,71 @@ void __bpf_prog_free(struct bpf_prog *fp)
>         vfree(fp);
>  }
>
> +#define SHA_BPF_RAW_SIZE                                               \
> +       round_up(MAX_BPF_SIZE + sizeof(__be64) + 1, SHA_MESSAGE_BYTES)
> +
> +/* Called under verifier mutex. */
> +void bpf_prog_calc_digest(struct bpf_prog *fp)
> +{
> +       const u32 bits_offset = SHA_MESSAGE_BYTES - sizeof(__be64);
> +       static u32 ws[SHA_WORKSPACE_WORDS];
> +       static u8 raw[SHA_BPF_RAW_SIZE];

function                                     old     new   delta
raw                                            -   32832  +32832

Congratulations!
We've found the first nominee for the v4.10-rc1 bloat-o-meter contest! :-(

Can this please be allocated dynamically? Thanks!

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
