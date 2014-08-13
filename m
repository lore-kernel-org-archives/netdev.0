From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH RFC v4 net-next 00/26] BPF syscall, maps, verifier,
 samples, llvm
Date: Wed, 13 Aug 2014 16:53:02 -0700
Message-ID: <CALCETrWOSwjXJ4Am-VCT48n8b=Miozj5vUejWck0twHODp5bOQ@mail.gmail.com>
References: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
 <063D6719AE5E284EB5DD2968C1650D6D174760F3@AcuExch.aculab.com>
 <20140813.162516.1876660483788283579.davem@davemloft.net> <CALCETrV4u3jup3pRjEJiPcvccvH84bYykLYxCCU7ek7yprt+Fg@mail.gmail.com>
 <CAMEtUuxp8_VJYUShxLGUOew5s0VNY_hH+w7QqqSehbFHKQwmvg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	David Laight <David.Laight@aculab.com>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuxp8_VJYUShxLGUOew5s0VNY_hH+w7QqqSehbFHKQwmvg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 13, 2014 at 4:46 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> On Wed, Aug 13, 2014 at 4:34 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>> On Wed, Aug 13, 2014 at 4:25 PM, David Miller <davem@davemloft.net> wrote:
>>> From: David Laight <David.Laight@ACULAB.COM>
>>> Date: Wed, 13 Aug 2014 08:52:30 +0000
>>>
>>>> From: Of Alexei Starovoitov
>>>>> one more RFC...
>>>>>
>>>>> Major difference vs previous set is a new 'load 64-bit immediate' eBPF insn.
>>>>> Which is first 16-byte instruction. It shows how eBPF ISA can be extended
>>>>> while maintaining backward compatibility, but mainly it cleans up eBPF
>>>>> program access to maps and improves run-time performance.
>>>>
>>>> Wouldn't it be more sensible to follow the scheme used by a lot of cpus
>>>> and add a 'load high' instruction (follow with 'add' or 'or').
>>>> It still takes 16 bytes to load a 64bit immediate value, but the instruction
>>>> size remains constant.
>>>> There is nothing to stop any JIT software detecting the instruction pair.
>>>
>>> The opposite argument is that JITs can expand the IMM64 load into whatever
>>> sequence of instructions is most optimal.
>>>
>>> My only real gripe with IMM64 loads is that it's not mainly for
>>> loading an immediate, it's for loading a pointer.  And this
>>> distinction is important for some JITs.
>>>
>>> For example, on sparc64 all symbol based addresses are actually 32-bit
>>> because of the code model we use to compile the kernel and all modules.
>>> So if we knew this is a pointer load and it's to a symbol in a kernel
>>> or module image, we could do a 32-bit load.
>>
>> This is true for x86_64 as well, I think.
>>
>> (Almost.  For x86_64 we have a choice between a sign-extended load of
>> a value in the top 2GB of the address space and lea reg,offset(%rip).)
>
> That would be an interesting optimization. I did movabsq just
> because it was straightforward. JITs can play interesting tricks here.
> Since it's really a constant value, there is no difference whether
> it's a pointer or a constant. If JIT can use $rip trick on x64 or reduce
> number of sethi insns on sparc, it should try to do it regardless of
> how value in dst_reg will be used later on by the program.
> JITs can also allocate some read-only area for constants and
> do a relative load from there. Not sure that it will be faster though.
> JITs can get more complex and smarter as time goes by. They can
> even randomly do some ld_imm64 via movabsq and some via a
> sequence of mov, shift, or. That will through away JIT spraying attacks.
> If JITed code itself is random, that would be nice defense.

You can be even fancier on x86_64: if the JIT code ends up being
allocated withing 2GB of the maps, then you can access kernel code
using absolute addresses and the maps using rip-relative addresses.

Depending on exactly what's going on, though, the best option may be
to use x86's fancy addressing modes for calls and loads.  That will be
harder.

--Andy
