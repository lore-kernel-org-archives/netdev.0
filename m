From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 2/2] arm64: bpf: add BPF XADD instruction
Date: Wed, 11 Nov 2015 16:52:00 +0100
Message-ID: <56436420.9090401@iogearbox.net>
References: <1447195301-16757-1-git-send-email-yang.shi@linaro.org> <20151111004208.GA47378@ast-mbp.thefacebook.com> <CABg9mcux0wEC5=nWuR9o8NwUTp73zqZ-N2e67_f7oS_mX1XGdg@mail.gmail.com> <4902833.k8y8bz0YLV@wuerfel> <20151111102406.GB9562@arm.com> <56431B83.5060500@iogearbox.net> <20151111115851.GE9562@arm.com> <564332B0.2090103@iogearbox.net> <20151111123831.GJ9562@arm.com> <20151111125807.GP17308@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, "Shi, Yang" <yang.shi@linaro.org>,
	linaro-kernel@lists.linaro.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Z Lim <zlim.lnx@gmail.com>,
	Alexei Starovoitov <ast@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Xi Wang <xi.wang@gmail.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, yhs@plumgrid.com,
	bblanco@plumgrid.com
To: Peter Zijlstra <peterz@infradead.org>,
	Will Deacon <will.deacon@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151111125807.GP17308@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/11/2015 01:58 PM, Peter Zijlstra wrote:
> On Wed, Nov 11, 2015 at 12:38:31PM +0000, Will Deacon wrote:
>>> Hmm, gcc doesn't have an eBPF compiler backend, so this won't work on
>>> gcc at all. The eBPF backend in LLVM recognizes the __sync_fetch_and_add()
>>> keyword and maps that to a BPF_XADD version (BPF_W or BPF_DW). In the
>>> interpreter (__bpf_prog_run()), as Eric mentioned, this maps to atomic_add()
>>> and atomic64_add(), respectively. So the struct bpf_insn prog[] you saw
>>> from sock_example.c can be regarded as one possible equivalent program
>>> section output from the compiler.
>>
>> Ok, so if I understand you correctly, then __sync_fetch_and_add() has
>> different semantics depending on the backend target. That seems counter
>> to the LLVM atomics Documentation:
>>
>>    http://llvm.org/docs/Atomics.html
>>
>> which specifically calls out the __sync_* primitives as being
>> sequentially-consistent and requiring barriers on ARM (which isn't the
>> case for atomic[64]_add in the kernel).
>>
>> If we re-use the __sync_* naming scheme in the source language, I don't
>> think we can overlay our own semantics in the backend. The
>> __sync_fetch_and_add primitive is also expected to return the old value,
>> which doesn't appear to be the case for BPF_XADD.
>
> Yikes. That's double fail. Please don't do this.
>
> If you use the __sync stuff (and I agree with Will, you should not) it
> really _SHOULD_ be sequentially consistent, which means full barriers
> all over the place.
>
> And if you name something XADD (exchange and add, or fetch-add) then it
> had better return the previous value.
>
> atomic*_add() does neither.

unsigned int ui;
unsigned long long ull;

void foo(void)
{
   (void) __sync_fetch_and_add(&ui, 1);
   (void) __sync_fetch_and_add(&ull, 1);
}

So clang front-end translates this snippet into intermediate
representation of ...

clang test.c -S -emit-llvm -o -
[...]
define void @foo() #0 {
   %1 = atomicrmw add i32* @ui, i32 1 seq_cst
   %2 = atomicrmw add i64* @ull, i64 1 seq_cst
   ret void
}
[...]

... which, if I see this correctly, then maps atomicrmw add {i32,i64}
in the BPF target into BPF_XADD as mentioned:

// Atomics
class XADD<bits<2> SizeOp, string OpcodeStr, PatFrag OpNode>
     : InstBPF<(outs GPR:$dst), (ins MEMri:$addr, GPR:$val),
               !strconcat(OpcodeStr, "\t$dst, $addr, $val"),
               [(set GPR:$dst, (OpNode ADDRri:$addr, GPR:$val))]> {
   bits<3> mode;
   bits<2> size;
   bits<4> src;
   bits<20> addr;

   let Inst{63-61} = mode;
   let Inst{60-59} = size;
   let Inst{51-48} = addr{19-16}; // base reg
   let Inst{55-52} = src;
   let Inst{47-32} = addr{15-0}; // offset

   let mode = 6;     // BPF_XADD
   let size = SizeOp;
   let BPFClass = 3; // BPF_STX
}

let Constraints = "$dst = $val" in {
def XADD32 : XADD<0, "xadd32", atomic_load_add_32>;
def XADD64 : XADD<3, "xadd64", atomic_load_add_64>;
// undefined def XADD16 : XADD<1, "xadd16", atomic_load_add_16>;
// undefined def XADD8  : XADD<2, "xadd8", atomic_load_add_8>;
}

I played a bit around with eBPF code to assign the __sync_fetch_and_add()
return value to a var and dump it to trace pipe, or use it as return code.
llvm compiles it (with the result assignment) and it looks like:

[...]
206: (b7) r3 = 3
207: (db) lock *(u64 *)(r0 +0) += r3
208: (bf) r1 = r10
209: (07) r1 += -16
210: (b7) r2 = 10
211: (85) call 6 // r3 dumped here
[...]

[...]
206: (b7) r5 = 3
207: (db) lock *(u64 *)(r0 +0) += r5
208: (bf) r1 = r10
209: (07) r1 += -16
210: (b7) r2 = 10
211: (b7) r3 = 43
212: (b7) r4 = 42
213: (85) call 6 // r5 dumped here
[...]

[...]
11: (b7) r0 = 3
12: (db) lock *(u64 *)(r1 +0) += r0
13: (95) exit // r0 returned here
[...]

What it seems is that we 'get back' the value (== 3 here in r3, r5, r0)
that we're adding, at least that's what seems to be generated wrt
register assignments. Hmm, the semantic differences of bpf target
should be documented somewhere for people writing eBPF programs to
be aware of.

Best,
Daniel
