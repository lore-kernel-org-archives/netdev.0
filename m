From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 3/6] macvtap: zerocopy: validate vector length before
 pinning user pages
Date: Mon, 16 Apr 2012 16:21:35 +0800
Message-ID: <4F8BD68F.7070708@redhat.com>
References: <20120416060749.14140.19433.stgit@intel-e5620-16-2.englab.nay.redhat.com>  <20120416060807.14140.96229.stgit@intel-e5620-16-2.englab.nay.redhat.com> <1334559183.28012.45.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xma@us.ibm.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, mst@redhat.com, ebiederm@xmission.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334559183.28012.45.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:
On 04/16/2012 02:53 PM, Eric Dumazet wrote:
> On Mon, 2012-04-16 at 14:08 +0800, Jason Wang wrote:
>> Currently we do not validate the vector length before calling
>> get_user_pages_fast(), host stack would be easily overflowed by
>> malicious guest driver who give us a descriptor with length greater
>> than MAX_SKB_FRAGS. Solve this problem by checking the free entries
>> before trying to pin user pages.
>>
>> Signed-off-by: Jason Wang<jasowang@redhat.com>
>> ---
>>   drivers/net/macvtap.c |    2 ++
>>   1 files changed, 2 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
>> index 7cb2684..d197a78 100644
>> --- a/drivers/net/macvtap.c
>> +++ b/drivers/net/macvtap.c
>> @@ -529,6 +529,8 @@ static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
>>   		}
>>   		base = (unsigned long)from->iov_base + offset;
>>   		size = ((base&  ~PAGE_MASK) + len + ~PAGE_MASK)>>  PAGE_SHIFT;
>> +		if (i + size>= MAX_SKB_FRAGS)
>> +			return -EFAULT;
>>   		num_pages = get_user_pages_fast(base, size, 0,&page[i]);
>>   		if ((num_pages != size) ||
>>   		    (num_pages>  MAX_SKB_FRAGS - skb_shinfo(skb)->nr_frags))
>>
> Hi Jason
>
> Why is -EFAULT the right error code ?

E2BIG or is there any error code you prefer?
>
> Also, why not removing the "(num_pages>  MAX_SKB_FRAGS -
> skb_shinfo(skb)->nr_frags)" test done few lines after ?

Yes, it can be removed.
>
> Also, if get_user_pages_fast() returns truncated result (size - 1 for
> example), we apparently dont free the references on pages.

It's a bug of this patch, thanks.
> The comment applies only on pages that were added in skb frags.
>
>
