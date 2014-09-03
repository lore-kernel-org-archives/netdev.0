From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] net: export pkt_type_offset() helper
Date: Wed, 03 Sep 2014 08:19:50 +0200
Message-ID: <5406B306.1050203@redhat.com>
References: <1409688238-3152-1-git-send-email-kda@linux-powerpc.org> <20140902225926.GA14635@its-macbook-pro.plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Denis Kirjanov <kda@linux-powerpc.org>, netdev@vger.kernel.org,
	Markos Chandras <markos.chandras@imgtec.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24005 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754601AbaICGUH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 02:20:07 -0400
In-Reply-To: <20140902225926.GA14635@its-macbook-pro.plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/03/2014 12:59 AM, Alexei Starovoitov wrote:
> On Wed, Sep 03, 2014 at 12:03:58AM +0400, Denis Kirjanov wrote:
>> Currently we have 2 pkt_type_offset functions doing
>> the same thing and spread across the architecture files.
>> Let's use the generic helper routine.
>
> that would be good cleanup.
> Please tag your subject as '[PATCH net-next]...'
>
>> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
>> Cc: Markos Chandras <markos.chandras@imgtec.com>
>> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
>> Cc: Daniel Borkmann <dborkman@redhat.com>
>> ---
>>   arch/mips/net/bpf_jit.c      | 21 ---------------------
>>   arch/s390/net/bpf_jit_comp.c | 38 ++++----------------------------------
>>   include/linux/filter.h       |  7 +++++++
>>   net/core/filter.c            |  7 +------
>>   4 files changed, 12 insertions(+), 61 deletions(-)
>>
>> diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
>> -#define PKT_TYPE_MAX 0xe0
>> -static int pkt_type_offset;
> ...
>> -}
>> -device_initcall(bpf_pkt_type_offset_init);
>
> may be make sense to optimize common case via initcall() as well
> instead of dropping it for s390?

I think that probably might not be a bad idea. pkt_type_offset
should be a __read_mostly candidate then. As we have things like
PTP classifier that is being loaded in core_initcall(), we might
need to initialize pkt_type_offset then via pure_initcall(),
for example. I think that should be doable, as it doesn't have
any dependencies elsewhere.

>> diff --git a/include/linux/filter.h b/include/linux/filter.h
>> index a5227ab..97e0549 100644
>> --- a/include/linux/filter.h
>> +++ b/include/linux/filter.h
>> @@ -424,6 +424,13 @@ static inline void *bpf_load_pointer(const struct sk_buff *skb, int k,
>>   	return bpf_internal_load_pointer_neg_helper(skb, k, size);
>>   }
>>
>> +#ifdef __BIG_ENDIAN_BITFIELD
>> +#define PKT_TYPE_MAX	(7 << 5)
>> +#else
>> +#define PKT_TYPE_MAX    7
>> +#endif
>
> these defines don't need to move. keep them in filter.c
>
