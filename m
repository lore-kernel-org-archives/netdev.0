From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 5/5] MIPS: Add support for eBPF JIT.
Date: Fri, 26 May 2017 21:09:37 +0200
Message-ID: <59287D71.6000307@iogearbox.net>
References: <20170526003826.10834-1-david.daney@cavium.com> <20170526003826.10834-6-david.daney@cavium.com> <5928463C.5000204@iogearbox.net> <e9c9348f-aa61-4384-e065-ba6bafc0bc13@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Markos Chandras <markos.chandras@imgtec.com>
To: David Daney <ddaney@caviumnetworks.com>,
        David Daney <david.daney@cavium.com>,
        Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
        ralf@linux-mips.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e9c9348f-aa61-4384-e065-ba6bafc0bc13@caviumnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/26/2017 05:39 PM, David Daney wrote:
> On 05/26/2017 08:14 AM, Daniel Borkmann wrote:
>> On 05/26/2017 02:38 AM, David Daney wrote:
>>> Since the eBPF machine has 64-bit registers, we only support this in
>>> 64-bit kernels.  As of the writing of this commit log test-bpf is showing:
>>>
>>>    test_bpf: Summary: 316 PASSED, 0 FAILED, [308/308 JIT'ed]
>>>
>>> All current test cases are successfully compiled.
>>>
>>> Signed-off-by: David Daney <david.daney@cavium.com>
>>
>> Awesome work!
>>
>> Did you also manage to run tools/testing/selftests/bpf/ fine with
>> the JIT enabled?
>
> I haven't done that yet, I will before the next revision.
>
>> [...]
>>> +struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
>>> +{
>>> +    struct jit_ctx ctx;
>>> +    unsigned int alloc_size;
>>> +
>>> +    /* Only 64-bit kernel supports eBPF */
>>> +    if (!IS_ENABLED(CONFIG_64BIT) || !bpf_jit_enable)
>>
>> Isn't this already reflected by the following?
>>
>>    select HAVE_EBPF_JIT if (64BIT && !CPU_MICROMIPS)
>
> Not exactly.  The eBPF JIT is in the same file as the classic-BPF JIT, so when HAVE_EBPF_JIT is false this will indeed never be called.  But the kernel would otherwise contain all the JIT code.
>
> By putting in !IS_ENABLED(CONFIG_64BIT) we allow gcc to eliminate all the dead code when compiling the JITs.

Side-effect would still be that for cBPF you go through the cBPF
JIT instead of letting the kernel convert all cBPF to eBPF and
later on go through your eBPF JIT. If you still prefer to have
everything in one single file and let gcc eliminate dead code
then you can just do single line change ...

void bpf_jit_compile(struct bpf_prog *fp)
{
         struct jit_ctx ctx;
         unsigned int alloc_size, tmp_idx;

         if (IS_ENABLED(CONFIG_HAVE_EBPF_JIT) || !bpf_jit_enable)
                 return;
         [...]
}

... and bpf_prog_ebpf_jited() et al wouldn't need to be changed
in the core, which are used in kallsyms, and kernel will then
also be able to automatically JIT all of seccomp-BPF and the
missing cBPF extensions we have through the eBPF JIT w/o extra
work.
