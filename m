From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 2/2] arm64: bpf: add BPF XADD instruction
Date: Wed, 11 Nov 2015 13:58:07 +0100
Message-ID: <20151111125807.GP17308@twins.programming.kicks-ass.net>
References: <1447195301-16757-1-git-send-email-yang.shi@linaro.org>
 <20151111004208.GA47378@ast-mbp.thefacebook.com>
 <CABg9mcux0wEC5=nWuR9o8NwUTp73zqZ-N2e67_f7oS_mX1XGdg@mail.gmail.com>
 <4902833.k8y8bz0YLV@wuerfel>
 <20151111102406.GB9562@arm.com>
 <56431B83.5060500@iogearbox.net>
 <20151111115851.GE9562@arm.com>
 <564332B0.2090103@iogearbox.net>
 <20151111123831.GJ9562@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Arnd Bergmann <arnd@arndb.de>,
	"Shi, Yang" <yang.shi@linaro.org>, linaro-kernel@lists.linaro.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Z Lim <zlim.lnx@gmail.com>,
	Alexei Starovoitov <ast@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Xi Wang <xi.wang@gmail.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Will Deacon <will.deacon@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151111123831.GJ9562@arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 11, 2015 at 12:38:31PM +0000, Will Deacon wrote:
> > Hmm, gcc doesn't have an eBPF compiler backend, so this won't work on
> > gcc at all. The eBPF backend in LLVM recognizes the __sync_fetch_and_add()
> > keyword and maps that to a BPF_XADD version (BPF_W or BPF_DW). In the
> > interpreter (__bpf_prog_run()), as Eric mentioned, this maps to atomic_add()
> > and atomic64_add(), respectively. So the struct bpf_insn prog[] you saw
> > from sock_example.c can be regarded as one possible equivalent program
> > section output from the compiler.
> 
> Ok, so if I understand you correctly, then __sync_fetch_and_add() has
> different semantics depending on the backend target. That seems counter
> to the LLVM atomics Documentation:
> 
>   http://llvm.org/docs/Atomics.html
> 
> which specifically calls out the __sync_* primitives as being
> sequentially-consistent and requiring barriers on ARM (which isn't the
> case for atomic[64]_add in the kernel).
> 
> If we re-use the __sync_* naming scheme in the source language, I don't
> think we can overlay our own semantics in the backend. The
> __sync_fetch_and_add primitive is also expected to return the old value,
> which doesn't appear to be the case for BPF_XADD.

Yikes. That's double fail. Please don't do this.

If you use the __sync stuff (and I agree with Will, you should not) it
really _SHOULD_ be sequentially consistent, which means full barriers
all over the place.

And if you name something XADD (exchange and add, or fetch-add) then it
had better return the previous value.

atomic*_add() does neither.
