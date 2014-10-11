From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net] x86: bpf_jit: fix two bugs in eBPF JIT compiler
Date: Fri, 10 Oct 2014 20:16:50 -0700
Message-ID: <CAMEtUuxsMsd75XXgeF5EyJHK8qm6FWWbaQTp0V7K6uvu8SKWuA@mail.gmail.com>
References: <1412995493-16100-1-git-send-email-ast@plumgrid.com>
	<1412997161.9362.34.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	"Darrick J. Wong" <darrick.wong@oracle.com>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412997161.9362.34.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 10, 2014 at 8:12 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2014-10-10 at 19:44 -0700, Alexei Starovoitov wrote:
>
>> 2.
>> while staring at the code realized that 64-byte buffer may not be enough
>> when 1st insn is large, so increase it to 128 to avoid buffer overflow
>> (theoretical maximum size of prologue+div is 109) and add runtime check.
>>
>
>
>> diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
>> index d56cd1f..8266896 100644
>> --- a/arch/x86/net/bpf_jit_comp.c
>> +++ b/arch/x86/net/bpf_jit_comp.c
>> @@ -187,7 +187,8 @@ static int do_jit(struct bpf_prog *bpf_prog, int *addrs, u8 *image,
>>  {
>>       struct bpf_insn *insn = bpf_prog->insnsi;
>>       int insn_cnt = bpf_prog->len;
>> -     u8 temp[64];
>> +     bool seen_ld_abs = ctx->seen_ld_abs | (oldproglen == 0);
>> +     u8 temp[128];
>
> Hmmm. I would use some guard like :
>
> #define BPF_MAX_INSN_SIZE 128
> #define BPF_INSN_SAFETY   64
>
>         u8 temp[MAX_INSN_SIZE + BPF_INSN_SAFETY];
>
>
>> +             if (ilen >= sizeof(temp)) {
>
>         if (ilen > BPF_MAX_INSN_SIZE) {
> ...
>
>> +                     pr_err("bpf_jit_compile fatal insn size error\n");
>> +                     return -EFAULT;
>> +             }
>> +
>
> Otherwise, we might have corrupted stack and panic anyway.

well, it only reduces the chances of stack corruption.. but yeah,
let's reduce them. will respin.
