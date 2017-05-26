From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH 5/5] MIPS: Add support for eBPF JIT.
Date: Fri, 26 May 2017 09:10:06 -0700
Message-ID: <dc3e42b8-e2f6-c678-6658-9789934240fe@caviumnetworks.com>
References: <20170526003826.10834-1-david.daney@cavium.com>
 <20170526003826.10834-6-david.daney@cavium.com>
 <20170526022300.c4gtxhqt3tyiukz2@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
        ralf@linux-mips.org, Markos Chandras <markos.chandras@imgtec.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        David Daney <david.daney@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0057.outbound.protection.outlook.com ([104.47.33.57]:47716
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1948292AbdEZQKL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 26 May 2017 12:10:11 -0400
In-Reply-To: <20170526022300.c4gtxhqt3tyiukz2@ast-mbp>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/25/2017 07:23 PM, Alexei Starovoitov wrote:
> On Thu, May 25, 2017 at 05:38:26PM -0700, David Daney wrote:
>> Since the eBPF machine has 64-bit registers, we only support this in
>> 64-bit kernels.  As of the writing of this commit log test-bpf is showing:
>>
>>    test_bpf: Summary: 316 PASSED, 0 FAILED, [308/308 JIT'ed]
>>
>> All current test cases are successfully compiled.
>>
>> Signed-off-by: David Daney <david.daney@cavium.com>
>> ---
>>   arch/mips/Kconfig       |    1 +
>>   arch/mips/net/bpf_jit.c | 1627 ++++++++++++++++++++++++++++++++++++++++++++++-
>>   arch/mips/net/bpf_jit.h |    7 +
>>   3 files changed, 1633 insertions(+), 2 deletions(-)
> 
> Great stuff. I wonder what is the performance difference
> interpreter vs JIT

It depends if we are calling library code:

/proc/sys/net/core # echo 0 > bpf_jit_enable
/proc/sys/net/core # modprobe test-bpf test_id=275
test_bpf: #275 BPF_MAXINSNS: ld_abs+vlan_push/pop jited:0 131733 PASS
test_bpf: Summary: 1 PASSED, 0 FAILED, [0/1 JIT'ed]
/proc/sys/net/core # rmmod test-bpf
/proc/sys/net/core # echo 1 > bpf_jit_enable
/proc/sys/net/core # modprobe test-bpf test_id=275
test_bpf: #275 BPF_MAXINSNS: ld_abs+vlan_push/pop jited:1 85453 PASS
test_bpf: Summary: 1 PASSED, 0 FAILED, [1/1 JIT'ed]

About 1.5X faster.

Or doing atomic operations:

/proc/sys/net/core # rmmod test-bpf
/proc/sys/net/core # echo 0 > bpf_jit_enable
/proc/sys/net/core # modprobe test-bpf test_id=229
test_bpf: #229 STX_XADD_DW: X + 1 + 1 + 1 + ... jited:0 209020 PASS
test_bpf: Summary: 1 PASSED, 0 FAILED, [0/1 JIT'ed]
/proc/sys/net/core # rmmod test-bpf
/proc/sys/net/core # echo 1 > bpf_jit_enable
/proc/sys/net/core # modprobe test-bpf test_id=229
test_bpf: #229 STX_XADD_DW: X + 1 + 1 + 1 + ... jited:1 158004 PASS
test_bpf: Summary: 1 PASSED, 0 FAILED, [1/1 JIT'ed]

About 1.3X faster, probably limited by coherent memory system more than 
code quality.

Simple register operations not touching memory are best:
/proc/sys/net/core # rmmod test-bpf
/proc/sys/net/core # echo 0 > bpf_jit_enable
/proc/sys/net/core # modprobe test-bpf test_id=38
test_bpf: #38 INT: ADD 64-bit jited:0 1819 PASS
test_bpf: Summary: 1 PASSED, 0 FAILED, [0/1 JIT'ed]
/proc/sys/net/core # rmmod test-bpf
/proc/sys/net/core # echo 1 > bpf_jit_enable
/proc/sys/net/core # modprobe test-bpf test_id=38
test_bpf: #38 INT: ADD 64-bit jited:1 83 PASS
test_bpf: Summary: 1 PASSED, 0 FAILED, [1/1 JIT'ed]

This one is fairly good. 21X faster.


> 
>> + * eBPF stack frame will be something like:
>> + *
>> + *  Entry $sp ------>   +--------------------------------+
>> + *                      |   $ra  (optional)              |
>> + *                      +--------------------------------+
>> + *                      |   $s0  (optional)              |
>> + *                      +--------------------------------+
>> + *                      |   $s1  (optional)              |
>> + *                      +--------------------------------+
>> + *                      |   $s2  (optional)              |
>> + *                      +--------------------------------+
>> + *                      |   $s3  (optional)              |
>> + *                      +--------------------------------+
>> + *                      |   tmp-storage  (if $ra saved)  |
>> + * $sp + tmp_offset --> +--------------------------------+ <--BPF_REG_10
>> + *                      |   BPF_REG_10 relative storage  |
>> + *                      |    MAX_BPF_STACK (optional)    |
>> + *                      |      .                         |
>> + *                      |      .                         |
>> + *                      |      .                         |
>> + *     $sp -------->    +--------------------------------+
>> + *
>> + * If BPF_REG_10 is never referenced, then the MAX_BPF_STACK sized
>> + * area is not allocated.
>> + */
> 
> It's especially great to see that you've put the tmp storage
> above program stack and made the stack allocation optional.
> At the moment I'm working on reducing bpf program stack size,
> so that JIT and interpreter can use only the stack they need.
> Looking at this JIT code only minimal changes will be needed.
> 

I originally recorded the minimum and maximum offsets from BPF_REG_10 
seen, and generated a minimally sized stack frame.  Then I see things like:

	{
		"STX_XADD_DW: Test side-effects, r10: 0x12 + 0x10 = 0x22",
		.u.insns_int = {
			BPF_ALU64_REG(BPF_MOV, R1, R10),
			BPF_ALU32_IMM(BPF_MOV, R0, 0x12),
			BPF_ST_MEM(BPF_DW, R10, -40, 0x10),
			BPF_STX_XADD(BPF_DW, R10, R0, -40),
			BPF_ALU64_REG(BPF_MOV, R0, R10),
			BPF_ALU64_REG(BPF_SUB, R0, R1),
			BPF_EXIT_INSN(),
		},
		INTERNAL,
		{ },
		{ { 0, 0 } },
	},

Here we see that the value of BPF_REG_10 can escape, and be used for who 
knows what, and we must assume the worst case.

I guess we could see if the BPF_REG_10 value ever escapes, and if it 
doesn't, then use an optimally sized stack frame, and only fall back to 
MAX_BPF_STACK if we cannot prove it is safe to do this.
