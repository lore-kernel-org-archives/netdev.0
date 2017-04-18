From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH RFC] sparc64: eBPF JIT
Date: Mon, 17 Apr 2017 22:44:47 -0700
Message-ID: <20170418054444.GA36377@ast-mbp.thefacebook.com>
References: <20170416.233825.1748421481008153466.davem@davemloft.net>
 <20170417232740.GB96258@ast-mbp.thefacebook.com>
 <20170417.181245.1402412750148031248.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sparclinux@vger.kernel.org, netdev@vger.kernel.org, ast@kernel.org,
        daniel@iogearbox.net
To: David Miller <davem@davemloft.net>
Return-path: <sparclinux-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170417.181245.1402412750148031248.davem@davemloft.net>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 17, 2017 at 06:12:45PM -0700, David Miller wrote:
> > 
> >> +	if (insn->src_reg == BPF_REG_FP || insn->dst_reg == BPF_REG_FP) {
> >> +		ctx->saw_frame_pointer = true;
> >> +		if (BPF_CLASS(code) == BPF_ALU ||
> >> +		    BPF_CLASS(code) == BPF_ALU64) {
> >> +			pr_err_once("ALU op on FP not supported by JIT\n");
> >> +			return -EINVAL;
> > 
> > That should be fine. The verifier checks for that:
> >   /* check whether register used as dest operand can be written to */
> >   if (regno == BPF_REG_FP) {
> >           verbose("frame pointer is read only\n");
> >           return -EACCES;
> >   }
> 
> I need to trap it as a source as well, because if that is allowed then
> I have to add special handling to every ALU operation we allow.
> 
> The reason is that the sparc64 stack is biased by 2047 bytes.  So
> I have to adjust every FP relative reference to include that 2047
> bias.
> 
> Can LLVM and CLANG emit arithmetic operations with FP as source?

The way llvm generates stack access is:
rX = r10
rX += imm
and that's the only thing verifier recognizes as valid ptr_to_stack.
Like rX -= imm will not be recognized as proper stack offset,
since llvm never does it.
I guess that counts as ALU on FP ?
Looks like we don't have such tests in test_bpf.ko. Hmm.
Pretty much all compiled C code should have such stack access.
The easiest test is tools/testing/selftests/bpf/test_progs

> >> +	/* dst = imm64 */
> >> +	case BPF_LD | BPF_IMM | BPF_DW:
> >> +	{
> >> +		const struct bpf_insn insn1 = insn[1];
> >> +		u64 imm64;
> >> +
> >> +		if (insn1.code != 0 || insn1.src_reg != 0 ||
> >> +		    insn1.dst_reg != 0 || insn1.off != 0) {
> >> +			/* Note: verifier in BPF core must catch invalid
> >> +			 * instructions.
> >> +			 */
> >> +			pr_err_once("Invalid BPF_LD_IMM64 instruction\n");
> >> +			return -EINVAL;
> > 
> > verifier should catch that too, but extra check doesn't hurt.
> 
> I just copied from anoter JIT, I can remove it.

That check was added to x64 JIT, because JIT patches were submitted
before eBPF was known to user space. There was no verifier at that time.
So JIT had do some checking, just for sanity.
It's probably ok to remove it now... or leave it as-is as historical artifact.

