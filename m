From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] bpf/verifier: improve disassembly of BPF_END
 instructions
Date: Thu, 21 Sep 2017 09:40:20 -0700
Message-ID: <20170921164018.xeos6z5cdghmtnti@ast-mbp>
References: <7013ee9d-a8e6-13fd-cc5f-86cf3d8bf4e0@solarflare.com>
 <20170921155215.jta52sesbiq54vri@ast-mbp>
 <4cfac985-4f99-cf85-fc15-c3ad1f8ff123@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33374 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751581AbdIUQkX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 12:40:23 -0400
Received: by mail-pg0-f65.google.com with SMTP id i130so3715508pgc.0
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 09:40:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4cfac985-4f99-cf85-fc15-c3ad1f8ff123@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 21, 2017 at 05:24:10PM +0100, Edward Cree wrote:
> On 21/09/17 16:52, Alexei Starovoitov wrote:
> > On Thu, Sep 21, 2017 at 04:09:34PM +0100, Edward Cree wrote:
> >> print_bpf_insn() was treating all BPF_ALU[64] the same, but BPF_END has a
> >>  different structure: it has a size in insn->imm (even if it's BPF_X) and
> >>  uses the BPF_SRC (X or K) to indicate which endianness to use.  So it
> >>  needs different code to print it.
> >>
> >> Signed-off-by: Edward Cree <ecree@solarflare.com>
> >> ---
> >> It's not the same format as the new LLVM asm uses, does that matter?
> >> AFAIK the LLVM format doesn't comprehend BPF_TO_LE, just assumes that all
> >>  endian ops are necessarily swaps (rather than sometimes nops).
> > that is being fixed and we will fix asm format too.
> > Let's pick good format first.
> Agreed.
> >>  kernel/bpf/verifier.c | 13 +++++++++++--
> >>  1 file changed, 11 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> >> index 799b245..e7657a4 100644
> >> --- a/kernel/bpf/verifier.c
> >> +++ b/kernel/bpf/verifier.c
> >> @@ -331,20 +331,29 @@ static void print_bpf_insn(const struct bpf_verifier_env *env,
> >>  	u8 class = BPF_CLASS(insn->code);
> >>  
> >>  	if (class == BPF_ALU || class == BPF_ALU64) {
> >> -		if (BPF_SRC(insn->code) == BPF_X)
> >> +		if (BPF_OP(insn->code) == BPF_END) {
> >> +			if (class == BPF_ALU64)
> >> +				verbose("BUG_alu64_%02x\n", insn->code);
> >> +			else
> >> +				verbose("(%02x) (u%d) r%d %s %s\n",
> >> +					insn->code, insn->imm, insn->dst_reg,
> >> +					bpf_alu_string[BPF_END >> 4],
> >> +					BPF_SRC(insn->code) == BPF_X ? "be" : "le");
> > yes the bit the same, but please use BPF_SRC(insn->code) == BPF_TO_BE.
> Good point.
> > imo
> > (u16) r4 endian be
> > isn't intuitive.
> > Can we come up with some better syntax?
> > Like
> > bswap16be r4
> > bswap32le r4
> Hmm, I don't like these, since bswapbe is a swap on *le* and a nop on be.
> > or
> >
> > to_be16 r4
> > to_le32 r4
> And the problem here is that it's not just to_be, it's also from_be.
>  Otherwise we could write `(be16) r4 = endian (u16) r4` and be much more
>  explicit about what's happening.
> Really the operation is something like `cpu_tofrom_be16 r4`, but that also
>  seems a bit clumsy and longwinded.  Also it's inconsistent with the other
>  ops that all indicate sizes with these (u16) etc casts.
> `endian (be16) r4`, perhaps?

How about:
r4 = (be16) (u16) r4 
r4 = (le64) (u64) r4 
most C like and most explicit ?
it should be easy to grasp that (be16) cast on big-endian arch is a nop and
swap on little.
