From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH V2] tipc: Use bsearch library function
Date: Sat, 16 Sep 2017 17:36:33 +0800
Message-ID: <64ee51ce-eb7e-ac1c-56a9-9481f6f80b35@windriver.com>
References: <20170911.143025.555018840006192902.davem@davemloft.net>
 <20170916075036.28676-1-thomas@m3y3r.de>
 <16128f5e-66ff-b6ec-c0e1-74ea08c212b0@windriver.com>
 <1505553970.16316.1.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Joe Perches <joe@perches.com>, Thomas Meyer <thomas@m3y3r.de>,
        <jon.maloy@ericsson.com>, <netdev@vger.kernel.org>,
        <tipc-discussion@lists.sourceforge.net>,
        <linux-kernel@vger.kernel.org>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505553970.16316.1.camel@perches.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/16/2017 05:26 PM, Joe Perches wrote:
> On Sat, 2017-09-16 at 17:02 +0800, Ying Xue wrote:
>> On 09/16/2017 03:50 PM, Thomas Meyer wrote:
>>> Use common library function rather than explicitly coding
>>> some variant of it yourself.
>>>
>>> Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
>>
>> Acked-by: Ying Xue <ying.xue@windriver.com>
> 
> Are you sure you want to do this?
> 
> Note the comment above nameseq_find_subseq
> 
>  * Very time-critical, so binary searches through sub-sequence array.
> 
> What impact does this change have on performance?

Sorry, I couldn't see any essential difference between this new
implementation and the original one except that the former tries to use
the library function - bsearch() to replace the original binary search
algorithm implemented in TIPC itself. Therefore, I don't think the
change will have a big impact on performance.

If I miss something, please let me know.

Thanks,
Ying

> 
>>> diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
>>> index bd0aac87b41a..eeb4d7a13de2 100644
>>> --- a/net/tipc/name_table.c
>>> +++ b/net/tipc/name_table.c
>>> @@ -44,6 +44,7 @@
>>>  #include "addr.h"
>>>  #include "node.h"
>>>  #include <net/genetlink.h>
>>> +#include <linux/bsearch.h>
>>>  
>>>  #define TIPC_NAMETBL_SIZE 1024		/* must be a power of 2 */
>>>  
>>> @@ -168,6 +169,18 @@ static struct name_seq *tipc_nameseq_create(u32 type, struct hlist_head *seq_hea
>>>  	return nseq;
>>>  }
>>>  
>>> +static int nameseq_find_subseq_cmp(const void *key, const void *elt)
>>> +{
>>> +	struct sub_seq *sseq = (struct sub_seq *)elt;
>>> +	u32 instance = *(u32 *)key;
>>> +
>>> +	if (instance < sseq->lower)
>>> +		return -1;
>>> +	else if (instance > sseq->upper)
>>> +		return 1;
>>> +	return 0;
>>> +}
>>> +
>>>  /**
>>>   * nameseq_find_subseq - find sub-sequence (if any) matching a name instance
>>>   *
>>> @@ -176,21 +189,8 @@ static struct name_seq *tipc_nameseq_create(u32 type, struct hlist_head *seq_hea
>>>  static struct sub_seq *nameseq_find_subseq(struct name_seq *nseq,
>>>  					   u32 instance)
>>>  {
>>> -	struct sub_seq *sseqs = nseq->sseqs;
>>> -	int low = 0;
>>> -	int high = nseq->first_free - 1;
>>> -	int mid;
>>> -
>>> -	while (low <= high) {
>>> -		mid = (low + high) / 2;
>>> -		if (instance < sseqs[mid].lower)
>>> -			high = mid - 1;
>>> -		else if (instance > sseqs[mid].upper)
>>> -			low = mid + 1;
>>> -		else
>>> -			return &sseqs[mid];
>>> -	}
>>> -	return NULL;
>>> +	return bsearch(&instance, nseq->sseqs, nseq->first_free,
>>> +		       sizeof(struct sub_seq), nameseq_find_subseq_cmp);
>>>  }
>>>  
>>>  /**
>>>
> 
