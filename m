From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH RFC 2/3] samples/bpf: Add define __EMITTING_BPF__ when
 building BPF
Date: Mon, 19 Jun 2017 10:37:47 -0400
Message-ID: <20170619143747.GA20370@C02RW35GFVH8.dhcp.broadcom.net>
References: <20170615223543.22867-3-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
        ralf@linux-mips.org, Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>,
        linux-arm-kernel@lists.infradead.org
To: David Daney <david.daney@cavium.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170615223543.22867-3-david.daney@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 15, 2017 at 03:35:42PM -0700, David Daney wrote:
> ... this allows gating of inline assembly code that causes llvm to
> fail when emitting BPF.

I floated essentially the same patch in Feb without much luck:

http://lists.infradead.org/pipermail/linux-arm-kernel/2017-March/492758.html

Many of the folks on the cc-list here had objections then and I suspect they
unfortunately still object.  I like the fact that this fix allowed
architectures that are currently problematic to move forward before there is a
possibly mythical "fix in llvm" to address this problem.

When talking about this in one of the IOVisor calls it was also discussed that
this needs to be fixed for tracing, so there are more than just the BPF
use-case where this is important.

I wasn't sure there was buy-in from the ARM developers, but my thought had been
that a cleaner solution to this would be to reorganize sysreg.h into multiple
files.  The inline assembly would be the only thing in sysreg-asm.h (that was
actually the only thing originally in sysreg.h) and the rest of the code would
be in sysreg.h.

That is not what Dave suggested, but it would be a good starting point for a
custom asm/ layer for BPF/tracing.  I'm with Dave and think a specialized set
of asm/ files for tracing/BPF to avoid these issues all-together and let arch
developers to do whatever they want in their code.

> Signed-off-by: David Daney <david.daney@cavium.com>
> ---
>  samples/bpf/Makefile | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
> index a0561dc762fe..4979e6b56662 100644
> --- a/samples/bpf/Makefile
> +++ b/samples/bpf/Makefile
> @@ -193,12 +193,12 @@ $(src)/*.c: verify_target_bpf
>  
>  $(obj)/tracex5_kern.o: $(obj)/syscall_nrs.h
>  
> -# asm/sysreg.h - inline assembly used by it is incompatible with llvm.
> -# But, there is no easy way to fix it, so just exclude it since it is
> -# useless for BPF samples.
> +# __EMITTING_BPF__ used to exclude inline assembly, which cannot be
> +# emitted in BPF code.
>  $(obj)/%.o: $(src)/%.c
>  	$(CLANG) $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) \
> -		-D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
> +		-D__KERNEL__ -D__EMITTING_BPF__ \
> +		-Wno-unused-value -Wno-pointer-sign \
>  		-Wno-compare-distinct-pointer-types \
>  		-Wno-gnu-variable-sized-type-not-at-end \
>  		-Wno-address-of-packed-member -Wno-tautological-compare \
