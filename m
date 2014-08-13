From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH RFC v4 net-next 00/26] BPF syscall, maps, verifier,
 samples, llvm
Date: Wed, 13 Aug 2014 16:46:41 -0700
Message-ID: <CAMEtUuxp8_VJYUShxLGUOew5s0VNY_hH+w7QqqSehbFHKQwmvg@mail.gmail.com>
References: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
	<063D6719AE5E284EB5DD2968C1650D6D174760F3@AcuExch.aculab.com>
	<20140813.162516.1876660483788283579.davem@davemloft.net>
	<CALCETrV4u3jup3pRjEJiPcvccvH84bYykLYxCCU7ek7yprt+Fg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	David Laight <David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALCETrV4u3jup3pRjEJiPcvccvH84bYykLYxCCU7ek7yprt+Fg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 13, 2014 at 4:34 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
> On Wed, Aug 13, 2014 at 4:25 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
>> From: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
>> Date: Wed, 13 Aug 2014 08:52:30 +0000
>>
>>> From: Of Alexei Starovoitov
>>>> one more RFC...
>>>>
>>>> Major difference vs previous set is a new 'load 64-bit immediate' eBPF insn.
>>>> Which is first 16-byte instruction. It shows how eBPF ISA can be extended
>>>> while maintaining backward compatibility, but mainly it cleans up eBPF
>>>> program access to maps and improves run-time performance.
>>>
>>> Wouldn't it be more sensible to follow the scheme used by a lot of cpus
>>> and add a 'load high' instruction (follow with 'add' or 'or').
>>> It still takes 16 bytes to load a 64bit immediate value, but the instruction
>>> size remains constant.
>>> There is nothing to stop any JIT software detecting the instruction pair.
>>
>> The opposite argument is that JITs can expand the IMM64 load into whatever
>> sequence of instructions is most optimal.
>>
>> My only real gripe with IMM64 loads is that it's not mainly for
>> loading an immediate, it's for loading a pointer.  And this
>> distinction is important for some JITs.
>>
>> For example, on sparc64 all symbol based addresses are actually 32-bit
>> because of the code model we use to compile the kernel and all modules.
>> So if we knew this is a pointer load and it's to a symbol in a kernel
>> or module image, we could do a 32-bit load.
>
> This is true for x86_64 as well, I think.
>
> (Almost.  For x86_64 we have a choice between a sign-extended load of
> a value in the top 2GB of the address space and lea reg,offset(%rip).)

That would be an interesting optimization. I did movabsq just
because it was straightforward. JITs can play interesting tricks here.
Since it's really a constant value, there is no difference whether
it's a pointer or a constant. If JIT can use $rip trick on x64 or reduce
number of sethi insns on sparc, it should try to do it regardless of
how value in dst_reg will be used later on by the program.
JITs can also allocate some read-only area for constants and
do a relative load from there. Not sure that it will be faster though.
JITs can get more complex and smarter as time goes by. They can
even randomly do some ld_imm64 via movabsq and some via a
sequence of mov, shift, or. That will through away JIT spraying attacks.
If JITed code itself is random, that would be nice defense.
