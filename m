From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 2/2] arm64: bpf: add BPF XADD instruction
Date: Wed, 11 Nov 2015 09:27:00 -0800
Message-ID: <20151111172659.GA86334@ast-mbp.thefacebook.com>
References: <CABg9mcux0wEC5=nWuR9o8NwUTp73zqZ-N2e67_f7oS_mX1XGdg@mail.gmail.com>
 <4902833.k8y8bz0YLV@wuerfel>
 <20151111102406.GB9562@arm.com>
 <56431B83.5060500@iogearbox.net>
 <20151111115851.GE9562@arm.com>
 <564332B0.2090103@iogearbox.net>
 <20151111123831.GJ9562@arm.com>
 <20151111125807.GP17308@twins.programming.kicks-ass.net>
 <56436420.9090401@iogearbox.net>
 <20151111162341.GN9562@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Peter Zijlstra <peterz@infradead.org>,
	Arnd Bergmann <arnd@arndb.de>,
	"Shi, Yang" <yang.shi@linaro.org>, linaro-kernel@lists.linaro.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Z Lim <zlim.lnx@gmail.com>,
	Alexei Starovoitov <ast@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Xi Wang <xi.wang@gmail.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, yhs@plumgrid.com,
	bblanco@plumgrid.com
To: Will Deacon <will.deacon@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151111162341.GN9562@arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 11, 2015 at 04:23:41PM +0000, Will Deacon wrote:
> 
> If we're going to document it, a bug tracker might be a good place to
> start. The behaviour, as it stands, is broken wrt the definition of the
> __sync primitives. That is, there is no way to build __sync_fetch_and_add
> out of BPF_XADD without changing its semantics.

BPF_XADD == atomic_add() in kernel. period.
we are not going to deprecate it or introduce something else.
Semantics of __sync* or atomic in C standard and/or gcc/llvm has
nothing to do with this.
arm64 JIT needs to JIT bpf_xadd insn equivalent to the code
of atomic_add() which is 'stadd' in armv8.1.
The cpu check can be done by jit and for older cpus just fall back
to interpreter. trivial.

> We could fix this by either:
> 
> (1) Defining BPF_XADD to match __sync_fetch_and_add (including memory
>     barriers).

nope.

> (2) Introducing some new BPF_ atomics, that map to something like the
>     C11 __atomic builtins and deprecating BPF_XADD in favour of these.

nope.

> (3) Introducing new source-language intrinsics to match what BPF can do
>     (unlikely to be popular).

llvm's __sync intrinsic is used temporarily until we have time to do
new intrinsic in llvm that matches kernel's atomic_add() properly.
It will be done similar to llvm-bpf load_byte/word intrinsics.
Note that we've been hiding it under lock_xadd() wrapper, like here:
https://github.com/iovisor/bcc/blob/master/examples/networking/tunnel_monitor/monitor.c#L130
