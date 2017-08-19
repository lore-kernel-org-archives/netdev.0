From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next v3] arm: eBPF JIT compiler
Date: Sat, 19 Aug 2017 12:04:31 -0700
Message-ID: <c2f4c796-0cb0-7eca-6cab-fed6b25020d5@fb.com>
References: <1503134429-29063-1-git-send-email-illusionist.neo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, keescook@chromium.org, daniel@iogearbox.net,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: Shubham Bansal <illusionist.neo@gmail.com>, <linux@armlinux.org.uk>,
 <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1503134429-29063-1-git-send-email-illusionist.neo@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 8/19/17 2:20 AM, Shubham Bansal wrote:
> The JIT compiler emits ARM 32 bit instructions. Currently, It supports
> eBPF only. Classic BPF is supported because of the conversion by BPF core.
>
> This patch is essentially changing the current implementation of JIT compiler
> of Berkeley Packet Filter from classic to internal with almost all
> instructions from eBPF ISA supported except the following
> 	BPF_ALU64 | BPF_DIV | BPF_K
> 	BPF_ALU64 | BPF_DIV | BPF_X
> 	BPF_ALU64 | BPF_MOD | BPF_K
> 	BPF_ALU64 | BPF_MOD | BPF_X
> 	BPF_STX | BPF_XADD | BPF_W
> 	BPF_STX | BPF_XADD | BPF_DW
>
> Implementation is using scratch space to emulate 64 bit eBPF ISA on 32 bit
> ARM because of deficiency of general purpose registers on ARM. Currently,
> only LITTLE ENDIAN machines are supported in this eBPF JIT Compiler.
>
> This patch needs to be applied after the fix from Daniel Borkmann, that is
> "[net-next,v2,1/2] bpf: make htab inlining more robust wrt assumptions"
>
> with message ID:
> 03f4e86a029058d0f674fd9bf288e55a5ec07df3.1503104831.git.daniel@iogearbox.net
>
> Tested on ARMv7 with QEMU by me (Shubham Bansal).
>
> Testing results on ARMv7:
>
> 1) test_bpf: Summary: 341 PASSED, 0 FAILED, [312/333 JIT'ed]
> 2) test_tag: OK (40945 tests)
> 3) test_progs: Summary: 30 PASSED, 0 FAILED
> 4) test_lpm: OK
> 5) test_lru_map: OK
>
> Above tests are all done with following flags enabled discreatly.
>
> 1) bpf_jit_enable=1
> 	a) CONFIG_FRAME_POINTER enabled
> 	b) CONFIG_FRAME_POINTER disabled
> 2) bpf_jit_enable=1 and bpf_jit_harden=2
> 	a) CONFIG_FRAME_POINTER enabled
> 	b) CONFIG_FRAME_POINTER disabled
>
> See Documentation/networking/filter.txt for more information.
>
> Signed-off-by: Shubham Bansal <illusionist.neo@gmail.com>

impressive work.
Acked-by: Alexei Starovoitov <ast@kernel.org>

Any performance numbers with vs without JIT ?

> +static const u8 bpf2a32[][2] = {
> +	/* return value from in-kernel function, and exit value from eBPF */
> +	[BPF_REG_0] = {ARM_R1, ARM_R0},
> +	/* arguments from eBPF program to in-kernel function */
> +	[BPF_REG_1] = {ARM_R3, ARM_R2},

as far as i understand arm32 calling convention the mapping makes sense
to me. Hard to come up with anything better than the above.

> +	/* function call */
> +	case BPF_JMP | BPF_CALL:
> +	{
> +		const u8 *r0 = bpf2a32[BPF_REG_0];
> +		const u8 *r1 = bpf2a32[BPF_REG_1];
> +		const u8 *r2 = bpf2a32[BPF_REG_2];
> +		const u8 *r3 = bpf2a32[BPF_REG_3];
> +		const u8 *r4 = bpf2a32[BPF_REG_4];
> +		const u8 *r5 = bpf2a32[BPF_REG_5];
> +		const u32 func = (u32)__bpf_call_base + (u32)imm;
> +
> +		emit_a32_mov_r64(true, r0, r1, false, false, ctx);
> +		emit_a32_mov_r64(true, r1, r2, false, true, ctx);
> +		emit_push_r64(r5, 0, ctx);
> +		emit_push_r64(r4, 8, ctx);
> +		emit_push_r64(r3, 16, ctx);
> +
> +		emit_a32_mov_i(tmp[1], func, false, ctx);
> +		emit_blx_r(tmp[1], ctx);

to improve the cost of call we can teach verifier to mark the registers
actually used to pass arguments, so not all pushes would be needed.
But it may be drop in the bucket comparing to the cost of compound
64-bit alu ops.
There was some work on llvm side to use 32-bit subregisters which
should help 32-bit architectures and JITs, but it didn't go far.
So if you're interested further improving bpf program speeds on arm32
you may take a look at llvm side. I can certainly provide the tips.
