From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net: filter: constify detection of pkt_type_offset
Date: Fri, 12 Sep 2014 13:32:09 +0200
Message-ID: <5412D9B9.2020300@redhat.com>
References: <09acea1aba100a62551605ba52ae8541e816d1e6.1410517225.git.hannes@stressinduktion.org>  <5412D113.6000700@redhat.com> <1410520696.2793.1.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Markos Chandras <markos.chandras@imgtec.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Denis Kirjanov <kda@linux-powerpc.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64655 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753087AbaILLca (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Sep 2014 07:32:30 -0400
In-Reply-To: <1410520696.2793.1.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/12/2014 01:18 PM, Hannes Frederic Sowa wrote:
> On Fr, 2014-09-12 at 12:55 +0200, Daniel Borkmann wrote:
>> On 09/12/2014 12:22 PM, Hannes Frederic Sowa wrote:
>>> Currently we have 2 pkt_type_offset functions doing the same thing and
>>> spread across the architecture files. Remove those and replace them
>>> with a PKT_TYPE_OFFSET macro helper which gets the constant value from a
>>> zero sized sk_buff member right in front of the bitfield with offsetof.
>>> This new offset marker does not change size of struct sk_buff.
>>>
>>> Cc: Eric Dumazet <eric.dumazet@gmail.com>
>>> Cc: Markos Chandras <markos.chandras@imgtec.com>
>>> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
>>> Cc: Daniel Borkmann <dborkman@redhat.com>
>>> Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>
>>> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
>>> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>>
>> Thanks for doing this, Hannes!
>> ...
>>>    static u64 __skb_get_pay_offset(u64 ctx, u64 a, u64 x, u64 r4, u64 r5)
>>>    {
>>>    	return skb_get_poff((struct sk_buff *)(unsigned long) ctx);
>>> @@ -191,7 +167,7 @@ static bool convert_bpf_extensions(struct sock_filter *fp,
>>>
>>>    	case SKF_AD_OFF + SKF_AD_PKTTYPE:
>>>    		*insn = BPF_LDX_MEM(BPF_B, BPF_REG_A, BPF_REG_CTX,
>>> -				    pkt_type_offset());
>>> +				    PKT_TYPE_OFFSET());
>>>    		if (insn->off < 0)
>>>    			return false;
>>>    		insn++;
>>
>> I think this can now be rewritten as ...
>>
>> 	case SKF_AD_OFF + SKF_AD_PKTTYPE:
>> 		*insn++ = BPF_LDX_MEM(BPF_B, BPF_REG_A, BPF_REG_CTX,
>> 				      PKT_TYPE_OFFSET());
>> 		*insn = BPF_ALU32_IMM(BPF_AND, BPF_REG_A, PKT_TYPE_MAX);
>>
>> ... since we are guaranteed to have always >0 insn->off and despite the
>> __s16 type in off we might be able to safely assume that sk_buff will
>> never get extended so far w/o fist fights first, where this could wrap
>> around. ;) Alternatively, perhaps a BUILD_BUG_ON() for really being
>> paranoid?
>
> Ok, but in a follow-up patch?

I'm fine if you want to propose that in a follow-up, sure.
