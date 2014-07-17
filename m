From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFCv3 01/14] arm64: introduce aarch64_insn_gen_comp_branch_imm()
Date: Thu, 17 Jul 2014 08:59:10 -0700
Message-ID: <CAMEtUux1NRqz-Bqi_H8kJe8x9u+1Q12Sg4a-92cE6OsePEBLxg@mail.gmail.com>
References: <1405405512-4423-1-git-send-email-zlim.lnx@gmail.com>
	<1405405512-4423-2-git-send-email-zlim.lnx@gmail.com>
	<20140716160450.GT29414@arm.com>
	<20140716211931.GA18109@gup76>
	<20140717091931.GC21153@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Zi Shen Lim <zlim.lnx@gmail.com>,
	Catalin Marinas <Catalin.Marinas@arm.com>,
	Jiang Liu <liuj97@gmail.com>,
	AKASHI Takahiro <takahiro.akashi@linaro.org>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Will Deacon <will.deacon@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140717091931.GC21153@arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 17, 2014 at 2:19 AM, Will Deacon <will.deacon@arm.com> wrote:
> On Wed, Jul 16, 2014 at 10:19:31PM +0100, Zi Shen Lim wrote:
>> >
>> > Is a BUG_ON justifiable here? Is there not a nicer way to fail?
>>
>> In general, it'd be nice if we returned something like -EINVAL and
>> have all callers handle failures. Today all code gen functions return
>> the u32 instruction and there's no error handling by callers.
>> I think following the precedence (aarch64_insn_gen_branch_imm())
>> of failing with BUG_ON is a reasonable tradeoff.
>
> Well, I don't necessarily agree with that BUG_ON, either :)
> I take it eBPF doesn't have a `trap' instruction or similar? Otherwise, we
> could generate that and avoid having to propagate errors directly to the
> caller.
>
>> In this case here, when we hit the default (failure) case, that means
>> there's a serious error of attempting to use an unsupported
>> variant. I think we're better off failing hard here than trying to
>> arbitrarily "fallback" on a default choice.
>
> It might be a serious error for BPF, but a BUG_ON brings down the entire
> machine, which I think is unfortunate.

There is some misunderstanding here. Here BUG_ON will trigger
only on actual bug in JIT implementation, it cannot be triggered by user.
eBPF program is verified before it reaches JIT, so all instructions are
valid and input to JIT is proper. Two instruction are not yet
implemented in this JIT and they trigger pr_.._once().
So I don't see any issue with this usage of BUG_ON
imo living with silent bugs in JIT is more dangerous.

For the same reason there is no 'trap' instruction in eBPF.
Static verifier checks that program is valid. If there was a 'trap'
insn the program would be rejected. Like programs with
'div by zero' are rejected. There is normal 'bpf_exit' insn to
return from the program.
