From: David Daney <ddaney.cavm@gmail.com>
Subject: Re: [PATCH] MIPS: BPF: Add support for SKF_AD_HATYPE
Date: Mon, 13 Mar 2017 09:45:26 -0700
Message-ID: <9da6cebb-b991-e89f-bc88-a2ec530e32ec@gmail.com>
References: <20170310221405.30648-1-david.daney@cavium.com>
 <20170313105659.GJ996@jhogan-linux.le.imgtec.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, ralf@linux-mips.org,
        linux-kernel@vger.kernel.org,
        "Steven J. Hill" <steven.hill@cavium.com>,
        Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org
To: James Hogan <james.hogan@imgtec.com>,
        David Daney <david.daney@cavium.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170313105659.GJ996@jhogan-linux.le.imgtec.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/13/2017 03:56 AM, James Hogan wrote:
> On Fri, Mar 10, 2017 at 02:14:05PM -0800, David Daney wrote:
>> This let's us pass some additional "modprobe test-bpf" tests.
>>
>> Reuse the code for SKF_AD_IFINDEX, but substitute the offset and size
>> of the "type" field.
>>
>> Signed-off-by: David Daney <david.daney@cavium.com>
>
> I think the BPF maintainers should probably be Cc'd on this patch.
> Cc'ing now.
>

Good point.

Since there are some corrections needed, I will send another version and 
CC the proper people.


>> ---
>>  arch/mips/net/bpf_jit.c | 14 ++++++++++----
>>  1 file changed, 10 insertions(+), 4 deletions(-)
>>
>> diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
>> index 49a2e22..f613708 100644
>> --- a/arch/mips/net/bpf_jit.c
>> +++ b/arch/mips/net/bpf_jit.c
>> @@ -1111,6 +1111,7 @@ static int build_body(struct jit_ctx *ctx)
>>  			emit_load(r_A, 28, off, ctx);
>>  			break;
>>  		case BPF_ANC | SKF_AD_IFINDEX:
>> +		case BPF_ANC | SKF_AD_HATYPE:
>>  			/* A = skb->dev->ifindex */
>
> this comment should probably be updated.

Right.

>
>>  			ctx->flags |= SEEN_SKB | SEEN_A;
>>  			off = offsetof(struct sk_buff, dev);
>> @@ -1120,10 +1121,15 @@ static int build_body(struct jit_ctx *ctx)
>>  			emit_bcond(MIPS_COND_EQ, r_s0, r_zero,
>>  				   b_imm(prog->len, ctx), ctx);
>>  			emit_reg_move(r_ret, r_zero, ctx);
>> -			BUILD_BUG_ON(FIELD_SIZEOF(struct net_device,
>> -						  ifindex) != 4);
>> -			off = offsetof(struct net_device, ifindex);
>> -			emit_load(r_A, r_s0, off, ctx);
>> +			if (code == (BPF_ANC | SKF_AD_IFINDEX)) {
>> +				BUILD_BUG_ON(FIELD_SIZEOF(struct net_device, ifindex) != 4);
>> +				off = offsetof(struct net_device, ifindex);
>> +				emit_load(r_A, r_s0, off, ctx);
>> +			} else { /* (code == (BPF_ANC | SKF_AD_HATYPE) */
>> +				BUILD_BUG_ON(FIELD_SIZEOF(struct net_device, type) != 2);
>> +				off = offsetof(struct net_device, type);
>> +				emit_half_load(r_A, r_s0, off, ctx);
>
> Technically net_device::type is unsigned, and emit_half_load uses LH
> which sign extends. Does that matter in practice.

The next version will use LHU.


>
> Cheers
> James
>
