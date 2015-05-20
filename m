From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH net-next 2/4] x86: bpf_jit: implement bpf_tail_call() helper
Date: Wed, 20 May 2015 09:05:24 -0700
Message-ID: <CALCETrV8CStuwvDXDPp5zsZw5FsSpYWBDXMYjLh6Qq703a=cgQ@mail.gmail.com>
References: <1432079946-9878-1-git-send-email-ast@plumgrid.com>
 <1432079946-9878-3-git-send-email-ast@plumgrid.com> <CALCETrVZyB+m8Oaad1JGwrLx1rTUoL0F6Afrvg_hQWiYyTTang@mail.gmail.com>
 <555BD1E9.5000000@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Michael Holzheu <holzheu-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Zi Shen Lim <zlim.lnx-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <555BD1E9.5000000-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 19, 2015 at 5:14 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
> On 5/19/15 5:11 PM, Andy Lutomirski wrote:
>>
>> On Tue, May 19, 2015 at 4:59 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
>> wrote:
>>>
>>> bpf_tail_call() arguments:
>>> ctx - context pointer
>>> jmp_table - one of BPF_MAP_TYPE_PROG_ARRAY maps used as the jump table
>>> index - index in the jump table
>>>
>>> In this implementation x64 JIT bypasses stack unwind and jumps into the
>>> callee program after prologue, so the callee program reuses the same
>>> stack.
>>>
>>> The logic can be roughly expressed in C like:
>>>
>>> u32 tail_call_cnt;
>>>
>>> void *jumptable[2] = { &&label1, &&label2 };
>>>
>>> int bpf_prog1(void *ctx)
>>> {
>>> label1:
>>>      ...
>>> }
>>>
>>> int bpf_prog2(void *ctx)
>>> {
>>> label2:
>>>      ...
>>> }
>>>
>>> int bpf_prog1(void *ctx)
>>> {
>>>      ...
>>>      if (tail_call_cnt++ < MAX_TAIL_CALL_CNT)
>>>          goto *jumptable[index]; ... and pass my 'ctx' to callee ...
>>>
>>>      ... fall through if no entry in jumptable ...
>>> }
>>>
>>
>> What causes the stack pointer to be right?  Is there some reason that
>> the stack pointer is the same no matter where you are in the generated
>> code?
>
>
> that's why I said 'it's _roughly_ expressed in C' this way.
> Stack pointer doesn't change. It uses the same stack frame.
>

I think the more relevant point is that (I think) eBPF never changes
the stack pointer after the prologue (i.e. the stack depth is truly
constant).

--Andy
