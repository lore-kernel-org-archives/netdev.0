From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 01/10] net: Use cached copy of pfmemalloc to avoid accessing
 page
Date: Sun, 10 May 2015 17:01:15 -0700
Message-ID: <554FF14B.4050901@gmail.com>
References: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>	<20150507041140.1873.58533.stgit@ahduyck-vm-fedora22> <20150510.191851.414324528131774160.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>, alexander.h.duyck@redhat.com
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20150510.191851.414324528131774160.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 05/10/2015 04:18 PM, David Miller wrote:
> From: Alexander Duyck <alexander.h.duyck@redhat.com>
> Date: Wed, 06 May 2015 21:11:40 -0700
>
>> +	/* use OR instead of assignment to avoid clearing of bits in mask */
>> +	if (pfmemalloc)
>> +		skb->pfmemalloc = 1;
>> +	skb->head_frag = 1;
>   ...
>> +	/* use OR instead of assignment to avoid clearing of bits in mask */
>> +	if (nc->pfmemalloc)
>> +		skb->pfmemalloc = 1;
>> +	skb->head_frag = 1;
> Maybe make these two cases more consistent by either accessing
> nc->pfmemalloc or using a local variable in both cases.

The only option would be to use a local variable in both cases, but then 
I am still stuck with the differences in when I can access the caches.

The reason for the difference between the two is that in the case of 
netdev_alloc_skb/frag the netdev_alloc_cache can only be accessed with 
IRQs disabled, whereas in the napi_alloc_skb case we can access the 
napi_alloc_cache at any point in the function.  Either way I am going to 
be stuck with differences because of the local_irq_save/restore that 
must be called when accessing the page frag cache that doesn't exist in 
the napi case.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
