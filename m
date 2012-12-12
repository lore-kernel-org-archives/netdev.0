From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] net: filter: return -EINVAL if BPF_S_ANC* operation is
 not supported
Date: Wed, 12 Dec 2012 17:25:44 +0100
Message-ID: <50C8B008.2000804@redhat.com>
References: <1355304701-22228-1-git-send-email-dborkman@redhat.com> <1355314964.9139.173.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ani Sinha <ani@aristanetworks.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65348 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754143Ab2LLQZu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2012 11:25:50 -0500
In-Reply-To: <1355314964.9139.173.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/12/2012 01:22 PM, Eric Dumazet wrote:
> On Wed, 2012-12-12 at 10:31 +0100, Daniel Borkmann wrote:
>> Currently, we return -EINVAL for malicious or wrong BPF filters.
>> However, this is not done for BPF_S_ANC* operations, which makes it
>> more difficult to detect if it's actually supported or not by the
>> BPF machine. Therefore, we should also return -EINVAL if K is within
>> the SKF_AD_OFF universe and the ancillary operation did not match.
>>
>> Cc: Ani Sinha <ani@aristanetworks.com>
>> Cc: Eric Dumazet <eric.dumazet@gmail.com>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> ---
>>   net/core/filter.c | 8 +++++++-
>>   1 file changed, 7 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/core/filter.c b/net/core/filter.c
>> index c23543c..de9bed4 100644
>> --- a/net/core/filter.c
>> +++ b/net/core/filter.c
>> @@ -531,7 +531,7 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
>>   		[BPF_JMP|BPF_JSET|BPF_K] = BPF_S_JMP_JSET_K,
>>   		[BPF_JMP|BPF_JSET|BPF_X] = BPF_S_JMP_JSET_X,
>>   	};
>> -	int pc;
>> +	int pc, anc_found;
>>
>>   	if (flen == 0 || flen > BPF_MAXINSNS)
>>   		return -EINVAL;
>> @@ -592,8 +592,10 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
>>   		case BPF_S_LD_W_ABS:
>>   		case BPF_S_LD_H_ABS:
>>   		case BPF_S_LD_B_ABS:
>> +			anc_found = 0;
>>   #define ANCILLARY(CODE) case SKF_AD_OFF + SKF_AD_##CODE:	\
>>   				code = BPF_S_ANC_##CODE;	\
>> +				anc_found = 1;			\
>>   				break
>>   			switch (ftest->k) {
>>   			ANCILLARY(PROTOCOL);
>> @@ -610,6 +612,10 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
>>   			ANCILLARY(VLAN_TAG);
>>   			ANCILLARY(VLAN_TAG_PRESENT);
>>   			}
>> +
>> +			/* ancillary operation unkown or unsupported */
>> +			if (anc_found == 0 && ftest->k >= SKF_AD_OFF)
>> +				return -EINVAL;
>>   		}
>>   		ftest->code = code;
>>   	}
>
> Several points :
>
> 1) This might break a userland filter that was previously working, by
> returning 0 when load_pointer() returns NULL.
>
> Specifying an offset bigger than skb->len is not _invalid_, it only
> makes a filter returns 0, because load_pointer() returns NULL.

I think it will not break for code, that calls load_pointer() in such a
circumstance which passed the sk_chk_filter() test. However, it will
"break" for code that calls ...

   { BPF_LD | BPF_(W|H|B) | BPF_ABS, 0, 0, <K> },

... where <K> is in [0xfffff000, 0xffffffff] _and_ <K> is not an ancillary.

But ...

Assuming some old code will have such an instruction where <K> is between
[0xfffff000, 0xffffffff] and it doesn't know ancillary operations, then
this will give a non-expected/unwanted behavior as well (since we do not
return the BPF machine with 0 as it probably was the case before anc.ops,
but load sth. into the accumulator instead and continue with the next
instruction, for instance), right? Thus, following this argumentation, user
space code would already have been broken by introducing ancillary
operations into the BPF machine per se.

This is probably just an assumption, but code that does such a direct load,
e.g. "load word at packet offset 0xffffffff into accumulator" ("ld [0xffffffff]")
is quite broken, isn't it? Isn't the whole assumption of ancillary operations
that no-one intentionally calls things like "ld [0xffffffff]" and expect this
word to be loaded from the packet offset?

> 2) This wont help applications running on old kernels where your patch
> wont be applied, as already mentioned yesterday.

Agreed, but leaving old kernels aside, it would be nice if newer kernels
could validate that, so at least from kernel <xyz> onwards it could be
checked _for sure_ if anc.op <abc> is present and can be used.

> 3) Misses a "Reported-by" tag
>
> 4) anc_found is a boolean

3 + 4 agreed, sorry for that. I could do a v2 of the patch with 3 + 4 fixed
and resubmit it, if there's interest ...

> To be truly portable, userland should not rely on kernel doing a full
> validation of ancillaries.
