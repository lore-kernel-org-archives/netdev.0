From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 2/2] arm64: bpf: add BPF XADD instruction
Date: Wed, 11 Nov 2015 13:21:04 +0100
Message-ID: <564332B0.2090103@iogearbox.net>
References: <1447195301-16757-1-git-send-email-yang.shi@linaro.org> <20151111004208.GA47378@ast-mbp.thefacebook.com> <CABg9mcux0wEC5=nWuR9o8NwUTp73zqZ-N2e67_f7oS_mX1XGdg@mail.gmail.com> <4902833.k8y8bz0YLV@wuerfel> <20151111102406.GB9562@arm.com> <56431B83.5060500@iogearbox.net> <20151111115851.GE9562@arm.com>
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
	<linux-arm-kernel@lists.infradead.org>, peterz@infradead.org
To: Will Deacon <will.deacon@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34158 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752165AbbKKMVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2015 07:21:14 -0500
In-Reply-To: <20151111115851.GE9562@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/11/2015 12:58 PM, Will Deacon wrote:
> On Wed, Nov 11, 2015 at 11:42:11AM +0100, Daniel Borkmann wrote:
>> On 11/11/2015 11:24 AM, Will Deacon wrote:
>>> On Wed, Nov 11, 2015 at 09:49:48AM +0100, Arnd Bergmann wrote:
>>>> On Tuesday 10 November 2015 18:52:45 Z Lim wrote:
>>>>> On Tue, Nov 10, 2015 at 4:42 PM, Alexei Starovoitov
>>>>> <alexei.starovoitov@gmail.com> wrote:
>>>>>> On Tue, Nov 10, 2015 at 04:26:02PM -0800, Shi, Yang wrote:
>>>>>>> On 11/10/2015 4:08 PM, Eric Dumazet wrote:
>>>>>>>> On Tue, 2015-11-10 at 14:41 -0800, Yang Shi wrote:
>>>>>>>>> aarch64 doesn't have native support for XADD instruction, implement it by
>>>>>>>>> the below instruction sequence:
>>>>>
>>>>> aarch64 supports atomic add in ARMv8.1.
>>>>> For ARMv8(.0), please consider using LDXR/STXR sequence.
>>>>
>>>> Is it worth optimizing for the 8.1 case? It would add a bit of complexity
>>>> to make the code depend on the CPU feature, but it's certainly doable.
>>>
>>> What's the atomicity required for? Put another way, what are we racing
>>> with (I thought bpf was single-threaded)? Do we need to worry about
>>> memory barriers?
>>>
>>> Apologies if these are stupid questions, but all I could find was
>>> samples/bpf/sock_example.c and it didn't help much :(
>>
>> The equivalent code more readable in restricted C syntax (that can be
>> compiled by llvm) can be found in samples/bpf/sockex1_kern.c. So the
>> built-in __sync_fetch_and_add() will be translated into a BPF_XADD
>> insn variant.
>
> Yikes, so the memory-model for BPF is based around the deprecated GCC
> __sync builtins, that inherit their semantics from ia64? Any reason not
> to use the C11-compatible __atomic builtins[1] as a base?

Hmm, gcc doesn't have an eBPF compiler backend, so this won't work on
gcc at all. The eBPF backend in LLVM recognizes the __sync_fetch_and_add()
keyword and maps that to a BPF_XADD version (BPF_W or BPF_DW). In the
interpreter (__bpf_prog_run()), as Eric mentioned, this maps to atomic_add()
and atomic64_add(), respectively. So the struct bpf_insn prog[] you saw
from sock_example.c can be regarded as one possible equivalent program
section output from the compiler.

>> What you can race against is that an eBPF map can be _shared_ by
>> multiple eBPF programs that are attached somewhere in the system, and
>> they could all update a particular entry/counter from the map at the
>> same time.
>
> Ok, so it does sound like eBPF needs to define/choose a memory-model and
> I worry that riding on the back of __sync isn't necessarily the right
> thing to do, particularly as its fallen out of favour with the compiler
> folks. On weakly-ordered architectures, it's also going to result in
> heavy-weight barriers for all atomic operations.
>
> Will
>
> [1] https://gcc.gnu.org/onlinedocs/gcc/_005f_005fatomic-Builtins.html
