From: Alexei Starovoitov <ast@fb.com>
Subject: Re: hmmm...
Date: Tue, 25 Apr 2017 22:31:06 -0700
Message-ID: <133d8e46-c5c1-1e0e-86a1-a7b5a2737bff@fb.com>
References: <20170425.215232.727894789143301373.davem@davemloft.net>
 <af3781d2-f8af-1c6e-b3a0-163d8c1de75a@fb.com>
 <20170425.233820.1357836307906136732.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:38437 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1954043AbdDZFbR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 01:31:17 -0400
In-Reply-To: <20170425.233820.1357836307906136732.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/25/17 8:38 PM, David Miller wrote:
> From: Alexei Starovoitov <ast@fb.com>
> Date: Tue, 25 Apr 2017 19:56:06 -0700
>
>> On 4/25/17 6:52 PM, David Miller wrote:
>>>
>>> Alexei, I found something strange on my computer :-)
>>>
>>> [davem@localhost binutils]$ ./objdump -d x.o
>>
>> No way! :) I thought it will take weeks!
>> Ship it. Ship it. Ship it.
>> Cannot wait to pull.
>> This is awesome. Thanks a ton!
>
> Relax, it is in a very raw state still. :)

hehe, before replied i checked binutils repo...
hoping to find a miracle there :)

>> What is the mnemonic for 32-bit alu ?
>
> It is of the form "xxx32".  Here is opcodes table below.
>
> I think there are no formal mnenomics defined anywhere yet right?
> So just tell me what adjustments you want to make.
>
> const struct bpf_opcode bpf_opcodes[] = {
>   { "mov32",   BPF_OPC_ALU   | BPF_OPC_MOV  | BPF_OPC_X,     "1,2" },
>   { "mov",     BPF_OPC_ALU64 | BPF_OPC_MOV  | BPF_OPC_X,     "1,2" },
>   { "add32",   BPF_OPC_ALU   | BPF_OPC_ADD  | BPF_OPC_X,     "1,2" },

the very first bpf gen looked like canonical asm,
but then I found myself spending too much time
looking at ldb and ldd and thinking is it 8-byte
or 64-byte load?
jgt/jge/jsgt/sge was a stumbling block for me as well,
since it still takes me longer than necessary to disambiguate
into > vs >= and signed/unsigned
gcc bpf backend was done way before llvm and it had
quite confusing GT vs bpf GT vs x86 GT.
https://github.com/iovisor-obsolete/bpf_gcc/commit/ff47b3acd6d3c60900fab8cd93afd8106c49c8c3#diff-ee684c67b9329b734b7fb535d86a558dR452
gcc GTU == bpf GT == x86 GA
gcc GT == bpf SGT == x86 G
gcc GE == bpf SGE == x86 GE
I couldn't change bpf GT to GTU to match gcc, since it came
from classic bpf, so could only add SGT. S for Signed.
Through all this confusion I figured that the only output
not superhuman can quickly read is C-like output,
hence the final gcc output looked like:
https://github.com/iovisor-obsolete/bpf_gcc/commit/ff47b3acd6d3c60900fab8cd93afd8106c49c8c3#diff-0db71d60fd74b52befee102a27f0b4c4R292
+(define_insn "movdi_2mem"
+  [(set (match_operand:DI 0 "memory_operand" "=m,m")
+	(match_operand:DI 1 "int_reg_or_const_operand" "r,K"))]
+  ""
+  "@
+   BPF_INSN_ST(BPF_DW, %0, %1), // *(uint64*)(%0)=%1
+   BPF_INSN_ST_IMM(BPF_DW, %0, %1), // *(uint64*)(%0)=%1"
+[(set_attr "type" "store, store")])

yes, gcc was emitting C macros with C looking comments
into fake .s file that we #included into .c code to be loaded
into the kernel.
(that code is abandoned and probably doesn't compile anymore)

I made the verifier to emit C-like output to make it easier
for program writers to understand.

llvm asm until version 4.0 looked like:
         mov     r0, 1
         ldd     r4, 8(r1)
         ldd     r3, 0(r1)
         mov     r5, r3
         addi    r5, 14
         jgt     r5, r4 goto LBB0_3
which was causing confusion as well, so when I realized
that llvm can emit and parse any type of text, I switched
to emit verifier like asm code:
         r2 = *(u64 *)(r10 - 16)
         r5 = r2
         r5 += 34
         r0 = 2
         if r5 > r3 goto LBB0_1
which I think is way easier to read.

Though I think Daniel still prefers old classic bpf asm ;)

Anyway, back to the question...
since BFD and GCC are so much entrenched into canonical style
of asm code, I don't mind that gnu toolchain will be using it.

I like that you used 'dw' in 'ldxdw' instead of just 'd'
though 'x' can probably be dropped.

'x' should be added here instead:
  { "stb", BPF_OPC_ST    | BPF_OPC_MEM  | BPF_OPC_B, "[1+O],i" },
  { "stb", BPF_OPC_STX   | BPF_OPC_MEM  | BPF_OPC_B, "[1+O],2" },

I would use ld8/ld16/ld32/ld64 and st8/stx8/st16/stx16/...
but I spent too much time looking into asm and I'm biased.

Thanks again for working on it! This is major milestone.
