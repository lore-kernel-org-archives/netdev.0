From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 2/4] x86: bpf_jit: implement bpf_tail_call()
 helper
Date: Tue, 19 May 2015 17:14:33 -0700
Message-ID: <555BD1E9.5000000@plumgrid.com>
References: <1432079946-9878-1-git-send-email-ast@plumgrid.com> <1432079946-9878-3-git-send-email-ast@plumgrid.com> <CALCETrVZyB+m8Oaad1JGwrLx1rTUoL0F6Afrvg_hQWiYyTTang@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	Zi Shen Lim <zlim.lnx@gmail.com>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALCETrVZyB+m8Oaad1JGwrLx1rTUoL0F6Afrvg_hQWiYyTTang@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/19/15 5:11 PM, Andy Lutomirski wrote:
> On Tue, May 19, 2015 at 4:59 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>> bpf_tail_call() arguments:
>> ctx - context pointer
>> jmp_table - one of BPF_MAP_TYPE_PROG_ARRAY maps used as the jump table
>> index - index in the jump table
>>
>> In this implementation x64 JIT bypasses stack unwind and jumps into the
>> callee program after prologue, so the callee program reuses the same stack.
>>
>> The logic can be roughly expressed in C like:
>>
>> u32 tail_call_cnt;
>>
>> void *jumptable[2] = { &&label1, &&label2 };
>>
>> int bpf_prog1(void *ctx)
>> {
>> label1:
>>      ...
>> }
>>
>> int bpf_prog2(void *ctx)
>> {
>> label2:
>>      ...
>> }
>>
>> int bpf_prog1(void *ctx)
>> {
>>      ...
>>      if (tail_call_cnt++ < MAX_TAIL_CALL_CNT)
>>          goto *jumptable[index]; ... and pass my 'ctx' to callee ...
>>
>>      ... fall through if no entry in jumptable ...
>> }
>>
>
> What causes the stack pointer to be right?  Is there some reason that
> the stack pointer is the same no matter where you are in the generated
> code?

that's why I said 'it's _roughly_ expressed in C' this way.
Stack pointer doesn't change. It uses the same stack frame.
