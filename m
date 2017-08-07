From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH v4 net-next 01/13] bpf/verifier: rework value tracking
Date: Mon, 7 Aug 2017 13:39:08 +0100
Message-ID: <fb278f0f-56e4-9324-4189-913ed198619a@solarflare.com>
References: <22441d84-0a11-5c00-2d2a-25e7dbafa6c2@solarflare.com>
 <8a5e37eb-2397-c986-79c5-02908fbbdee0@solarflare.com>
 <5987A7DF.6080203@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        iovisor-dev <iovisor-dev@lists.iovisor.org>
To: Daniel Borkmann <daniel@iogearbox.net>, <davem@davemloft.net>,
        "Alexei Starovoitov" <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5987A7DF.6080203@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/08/17 00:35, Daniel Borkmann wrote:
> On 08/03/2017 06:11 PM, Edward Cree wrote:
>> Unifies adjusted and unadjusted register value types (e.g. FRAME_POINTER is
>>   now just a PTR_TO_STACK with zero offset).
>> Tracks value alignment by means of tracking known & unknown bits.  This
>>   also replaces the 'reg->imm' (leading zero bits) calculations for (what
>>   were) UNKNOWN_VALUEs.
>> If pointer leaks are allowed, and adjust_ptr_min_max_vals returns -EACCES,
>>   treat the pointer as an unknown scalar and try again, because we might be
>>   able to conclude something about the result (e.g. pointer & 0x40 is either
>>   0 or 0x40).
>>
>> Signed-off-by: Edward Cree <ecree@solarflare.com>
> [...]
>> -            dst_reg->max_value = BPF_REGISTER_MAX_RANGE;
>> +    if (BPF_CLASS(insn->code) != BPF_ALU64) {
>> +        /* 32-bit ALU ops are (32,32)->64 */
>> +        coerce_reg_to_32(dst_reg);
>> +        coerce_reg_to_32(src_reg);
>>       }
>
> Looks like the same check was added twice here right after
> the first one?
Yes, it must've gotten duplicated when I rebased.  Thanks for spotting it!
> Shouldn't we just temporarily coerce the src
> reg to 32 bit here given in the actual op the src reg is not
> being modified?
You're quite right, I need to make a copy of the src_reg state and use
 that, at least in the case where it's a real register.  Probably the
 place to do it is at the call sites in adjust_reg_min_max_vals().
I'll sprinkle a few consts around as well, to catch that sort of thing.

-Ed
