From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] sparc64: eBPF JIT
Date: Tue, 18 Apr 2017 22:27:03 -0400 (EDT)
Message-ID: <20170418.222703.574792250384665834.davem@davemloft.net>
References: <20170418054444.GA36377@ast-mbp.thefacebook.com>
        <20170418.143732.1494140903085244508.davem@davemloft.net>
        <20170418225707.GA65449@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sparclinux@vger.kernel.org, netdev@vger.kernel.org, ast@kernel.org,
        daniel@iogearbox.net
To: alexei.starovoitov@gmail.com
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <20170418225707.GA65449@ast-mbp.thefacebook.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Tue, 18 Apr 2017 15:57:09 -0700

> On Tue, Apr 18, 2017 at 02:37:32PM -0400, David Miller wrote:
>> From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
>> Date: Mon, 17 Apr 2017 22:44:47 -0700
>> 
>> > The way llvm generates stack access is:
>> > rX = r10
>> > rX += imm
>> > and that's the only thing verifier recognizes as valid ptr_to_stack.
>> > Like rX -= imm will not be recognized as proper stack offset,
>> > since llvm never does it.
>> 
>> That simplifies things significantly for me.
>> 
>> I only allow moves from the frame pointer to another register,
>> and when I see that I rewrite it to "add FP, STACK_BIAS, DST_REG"
> 
> Sounds good to me. Alternative idea: can the above
> 'add FP, STACK_BIAS, one_of_local_regs' be done once in prologue
> and that register used as substitue for R10 ?
> (assuming non-leaf function)
> I completely forgot by now how 2047 magic works.

Well, I'm trying to understand what that would buy us.

If I'm always going to see that kind of sequence:

	rX = r10
	rx += offset

then I always have that "r10" move available to deal with the bias.
It comes for free.

Right now the current version of the sparc64 JIT will emit:

	add	%fp, 2047, bpf2sparc[rX]
	add	bpf2sparc[rX], offset, bpf2sparc[rX]

for that BPF sequence.

Anyways, thanks to your and Daniel's feedback I'm very confident
with the code now.  All that's really left is tail calls, and I'll
set up a BPF compilation and test environment for that.
