From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next 2/4] x86: bpf_jit: implement bpf_tail_call()
 helper
Date: Wed, 20 May 2015 09:29:28 -0700
Message-ID: <555CB668.2090901@plumgrid.com>
References: <1432079946-9878-1-git-send-email-ast@plumgrid.com> <1432079946-9878-3-git-send-email-ast@plumgrid.com> <CALCETrVZyB+m8Oaad1JGwrLx1rTUoL0F6Afrvg_hQWiYyTTang@mail.gmail.com> <555BD1E9.5000000@plumgrid.com> <CALCETrV8CStuwvDXDPp5zsZw5FsSpYWBDXMYjLh6Qq703a=cgQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Michael Holzheu <holzheu-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Zi Shen Lim <zlim.lnx-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALCETrV8CStuwvDXDPp5zsZw5FsSpYWBDXMYjLh6Qq703a=cgQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 5/20/15 9:05 AM, Andy Lutomirski wrote:
>>>
>>> What causes the stack pointer to be right?  Is there some reason that
>>> the stack pointer is the same no matter where you are in the generated
>>> code?
>>
>>
>> that's why I said 'it's _roughly_ expressed in C' this way.
>> Stack pointer doesn't change. It uses the same stack frame.
>>
>
> I think the more relevant point is that (I think) eBPF never changes
> the stack pointer after the prologue (i.e. the stack depth is truly
> constant).

ahh, that's what you were referring to.
Yes, there is no alloca(). stack cannot grow and always fixed.
That's critical for safety verification.
On a JIT side though, x64 has ugly div/mod, so JIT is doing
push/pop rax/rdx to compile 'dst_reg /= src_reg' bpf insn.
But that doesn't change 'same stack depth' rule at the time
of bpf_tail_call.
Note, s390 JIT can generate different prologue/epilogue
for every program, so it will likely be doing stack unwind
and jump. Like I was doing in my tail_call_v2 version of x64 jit:
https://git.kernel.org/cgit/linux/kernel/git/ast/bpf.git/diff/arch/x86/net/bpf_jit_comp.c?h=tail_call_v2&id=bfd60c3135c8f010a6497dfc5e7d3070e26ca4d1

In case of interrupt happens sometime during this jumping process
it's also fine. no-red-zone business is very dear to my heart :)
I always keep it in mind when doing assembler/jit changes.
