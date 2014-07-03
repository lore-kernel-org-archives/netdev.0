From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH RFC] arm64: eBPF JIT compiler
Date: Thu, 3 Jul 2014 10:14:50 +0100
Message-ID: <20140703091450.GB12958@arm.com>
References: <1404278424-31176-1-git-send-email-zlim.lnx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Catalin Marinas <Catalin.Marinas@arm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Chema Gonzalez <chema@google.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Zi Shen Lim <zlim.lnx@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1404278424-31176-1-git-send-email-zlim.lnx@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Wed, Jul 02, 2014 at 06:20:24AM +0100, Zi Shen Lim wrote:
> The JIT compiler emits A64 instructions. It supports eBPF only.
> Legacy BPF is supported thanks to conversion by BPF core.
> 
> JIT is enabled in the same way as for other architectures:
> 
>         echo 1 > /proc/sys/net/core/bpf_jit_enable
> 
> Or for additional compiler output:
> 
>         echo 2 > /proc/sys/net/core/bpf_jit_enable
> 
> See Documentation/networking/filter.txt for more information.
> 
> The implementation passes all 57 tests in lib/test_bpf.c
> on ARMv8 Foundation Model :)

First off, this is really cool. Thanks for putting in the effort to get this
supported on arm64! I'm happy to run tests on some real hardware if you tell
me how to run them :)

One general observation relates to your instruction encoding logic, e.g:

> +/* 5-bit Register Operand */
> +#define A64_R(x)       x               /* R0-R30: General purpose */
> +#define A64_FP         A64_R(29)       /* Frame pointer */
> +#define A64_LR         A64_R(30)       /* Link register */
> +#define A64_ZR         31              /* As source register operand */
> +#define A64_SP         31              /* As load/store base register */
> +
> +#define BITSMASK(bits) ((1 << (bits)) - 1)
> +
> +/* Compare & branch (immediate) */
> +static inline u32 A64_COMP_BRANCH_IMM(int sf, int op, int imm19, int Rt)
> +{
> +       sf &= BITSMASK(1);
> +       op &= BITSMASK(1);
> +       imm19 &= BITSMASK(19);
> +       Rt &= BITSMASK(5);
> +       return 0x34000000 | sf << 31 | op << 24 | imm19 << 5 | Rt;
> +}
> +#define A64_CBZ(sf, Rt, imm19)  A64_COMP_BRANCH_IMM(sf, 0, imm19, Rt)
> +#define A64_CBNZ(sf, Rt, imm19) A64_COMP_BRANCH_IMM(sf, 1, imm19, Rt)

We already have some some basic instruction manipulation code in
arch/arm64/kernel/insn.c and arch/arm64/include/asm/insn.h. Would you be
able to move some of this there please (but only the bits that aren't tied
to BPF?

The reason I ask, is because we're inevitebly going to need this stuff
for other subsystems (e.g. kprobes, dynamic code patching ("alternatives"))
and I'd like to avoid a proliferation of magic numbers across the codebase.

Does this sound remotely feasible?

Cheers,

Will
