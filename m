From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 2/2] arm64: bpf: add BPF XADD instruction
Date: Wed, 11 Nov 2015 19:50:15 +0100
Message-ID: <56438DE7.4080300@iogearbox.net>
References: <56436420.9090401@iogearbox.net> <20151111162341.GN9562@arm.com> <20151111172659.GA86334@ast-mbp.thefacebook.com> <20151111.123548.1039494689070388545.davem@davemloft.net> <20151111175741.GR17308@twins.programming.kicks-ass.net> <20151111181132.GA90947@ast-mbp.thefacebook.com> <20151111183128.GS17308@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, will.deacon@arm.com,
	arnd@arndb.de, yang.shi@linaro.org, linaro-kernel@lists.linaro.org,
	eric.dumazet@gmail.com, zlim.lnx@gmail.com, ast@kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	xi.wang@gmail.com, catalin.marinas@arm.com,
	linux-arm-kernel@lists.infradead.org, yhs@plumgrid.com,
	bblanco@plumgrid.com
To: Peter Zijlstra <peterz@infradead.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151111183128.GS17308@twins.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/11/2015 07:31 PM, Peter Zijlstra wrote:
> On Wed, Nov 11, 2015 at 10:11:33AM -0800, Alexei Starovoitov wrote:
>> On Wed, Nov 11, 2015 at 06:57:41PM +0100, Peter Zijlstra wrote:
>>> On Wed, Nov 11, 2015 at 12:35:48PM -0500, David Miller wrote:
>>>> From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
>>>> Date: Wed, 11 Nov 2015 09:27:00 -0800
>>>>
>>>>> BPF_XADD == atomic_add() in kernel. period.
>>>>> we are not going to deprecate it or introduce something else.
>>>>
>>>> Agreed, it makes no sense to try and tie C99 or whatever atomic
>>>> semantics to something that is already clearly defined to have
>>>> exactly kernel atomic_add() semantics.
>>>
>>> Dave, this really doesn't make any sense to me. __sync primitives have
>>> well defined semantics and (e)BPF is violating this.
>>
>> bpf_xadd was never meant to be __sync_fetch_and_add equivalent.
>>  From the day one it meant to be atomic_add() as kernel does it.
>> I did piggy back on __sync in the llvm backend because it was the quick
>> and dirty way to move forward.
>> In retrospect I should have introduced a clean intrinstic for that instead,
>> but it's not too late to do it now. user space we can change at any time
>> unlike kernel.
>
> I would argue that breaking userspace (language in this case) is equally
> bad. Programs that used to work will now no longer work.

Well, on that note, it's not like you just change the target to bpf in your
Makefile and can compile (& load into the kernel) anything you want with it.
You do have to write small, restricted programs from scratch for a specific
use-case with the limited set of helper functions and intrinsics that are
available from the kernel. So I don't think that "Programs that used to work
will now no longer work." holds if you regard it as such.

>>> Furthermore, the fetch_and_add (or XADD) name has well defined
>>> semantics, which (e)BPF also violates.
>>
>> bpf_xadd also didn't meant to be 'fetch'. It was void return from the beginning.
>
> Then why the 'X'? The XADD name, does and always has meant: eXchange-ADD,
> this means it must have a return value.
>
> You using the XADD name for something that is not in fact XADD is just
> wrong.
>
>>> Atomicy is hard enough as it is, backends giving random interpretations
>>> to them isn't helping anybody.
>>
>> no randomness.
>
> You mean every other backend translating __sync_fetch_and_add()
> differently than you isn't random on your part?
>
>> bpf_xadd == atomic_add() in kernel.
>> imo that is the simplest and cleanest intepretantion one can have, no?
>
> Wrong though, if you'd named it BPF_ADD, sure, XADD, not so much. That
> is 'randomly' co-opting something that has well defined meaning and
> semantics with something else.
>
>>> It also baffles me that Alexei is seemingly unwilling to change/rev the
>>> (e)BPF instructions, which would be invisible to the regular user, he
>>> does want to change the language itself, which will impact all
>>> 'scripts'.
>>
>> well, we cannot change it in kernel because it's ABI.
>
> You can always rev it. Introduce a new set, and wait for users of the
> old set to die, then remove it. We do that all the time with Linux ABI.
>
>> I'm not against adding new insns. We definitely can, but let's figure out why?
>> Is anything broken? No.
>
> Yes, __sync_fetch_and_add() is broken when pulled through the eBPF
> backend.
>
>> So what new insns make sense?
>
> Depends a bit on how fancy you want to go. If you want to support weakly
> ordered architectures at full speed you'll need more (and more
> complexity) than if you decide to not go that way.
>
> The simplest option would be a fully ordered compare-and-swap operation.
> That is enough to implement everything else (at a cost). The other
> extreme is a weak ll/sc with an optimizer pass recognising various forms
> to translate into 'better' native instructions.
>
>> Add new one that does 'fetch_and_add' ? What is the real use case it
>> will be used for?
>
> Look at all the atomic_{add,dec}_return*() users in the kernel. A typical
> example would be a reader-writer lock implementations. See
> include/asm-generic/rwsem.h for examples.
>
>> Adding new intrinsic to llvm is not a big deal. I'll add it as soon
>> as I have time to work on it or if somebody beats me to it I would be
>> glad to test it and apply it.
>
> This isn't a speed coding contest. You want to think about this
> properly.
>
