From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH 2/2] arm64: bpf: add BPF XADD instruction
Date: Wed, 11 Nov 2015 15:40:15 -0800
Message-ID: <20151111234014.GA17014@ast-mbp.thefacebook.com>
References: <20151111162341.GN9562@arm.com>
 <20151111172659.GA86334@ast-mbp.thefacebook.com>
 <20151111.123548.1039494689070388545.davem@davemloft.net>
 <20151111175741.GR17308@twins.programming.kicks-ass.net>
 <20151111181132.GA90947@ast-mbp.thefacebook.com>
 <20151111183128.GS17308@twins.programming.kicks-ass.net>
 <20151111184427.GH11639@twins.programming.kicks-ass.net>
 <20151111185415.GI11639@twins.programming.kicks-ass.net>
 <20151111195558.GA4173@ast-mbp.thefacebook.com>
 <20151111222135.GU17308@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: yang.shi@linaro.org, yhs@plumgrid.com, linaro-kernel@lists.linaro.org,
 catalin.marinas@arm.com, daniel@iogearbox.net, arnd@arndb.de,
 zlim.lnx@gmail.com, bblanco@plumgrid.com, will.deacon@arm.com, ast@kernel.org,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 netdev@vger.kernel.org, eric.dumazet@gmail.com,
 David Miller <davem@davemloft.net>, xi.wang@gmail.com
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20151111222135.GU17308@twins.programming.kicks-ass.net>
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

On Wed, Nov 11, 2015 at 11:21:35PM +0100, Peter Zijlstra wrote:
> On Wed, Nov 11, 2015 at 11:55:59AM -0800, Alexei Starovoitov wrote:
> > Therefore things like memory barriers, full set of atomics are not applicable
> > in bpf world.
> 
> There are still plenty of wait-free constructs one can make using them.

yes, but all such lock-free algos are typically based on cmpxchg8b and
tight loop, so it would be very hard for verifier to proof termination
of such loops. I think when we'd need to add something like this, we'll
add new bpf insn that will be membarrier+cmpxhg8b+check+loop as
a single insn, so it cannot be misused.
I don't know of any concrete use case yet. All possible though.

> Say a barrier/rendezvous construct for knowing when an event has
> happened on all CPUs.
> 
> But if you really do not want any of that, I suppose that is a valid
> choice.

I do want it :) and I think in the future we'll add a bunch
of interesting stuff. May be including things like above. I just
don't want to rush things in just because x86 has such insn
or because gcc has a builtin for it.
Like we discussed adding popcnt insn. It can be useful in some cases,
but doesn't seem to worth the pain of adding it to interpreter, JITs
and llvm backends... as of today... May be tomorrow it will be must have.

> Is even privileged (e)BPF not allowed things like this? I was thinking
> the strict no loops stuff was for unpriv (e)BPF only.

the only difference between unpriv and priv is the ability to send
all values (including kernel addresses) to user space (like tracing
needs to see all registers). The rest is the same.
root should never crash the kernel as well. If we relax even little bit
for root then the whole bpf stuff is no better than kernel module.

btw, support for mini loops was requested many times in the past.
I guess we'd have to add something like this, but it's tricky.
Mainly because control flow graph analysis becomes much more complicated.
