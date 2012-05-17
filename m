From: Jason Wang <jasowang@redhat.com>
Subject: Re: [V2 PATCH 2/9] macvtap: zerocopy: fix truesize underestimation
Date: Thu, 17 May 2012 10:59:45 +0800
Message-ID: <4FB469A1.3040507@redhat.com>
References: <20120502033901.11782.13157.stgit@amd-6168-8-1.englab.nay.redhat.com>  <20120502034144.11782.88947.stgit@amd-6168-8-1.englab.nay.redhat.com>  <1337102809.8220.10.camel@oc3660625478.ibm.com>  <4FB3192E.4030803@redhat.com> <1337180585.10741.6.camel@oc3660625478.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ebiederm@xmission.com,
	davem@davemloft.net
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337180585.10741.6.camel@oc3660625478.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/16/2012 11:03 PM, Shirley Ma wrote:
> On Wed, 2012-05-16 at 11:04 +0800, Jason Wang wrote:
>>>> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
>>>> index bd4a70d..7cb2684 100644
>>>> --- a/drivers/net/macvtap.c
>>>> +++ b/drivers/net/macvtap.c
>>>> @@ -519,6 +519,7 @@ static int zerocopy_sg_from_iovec(struct
>> sk_buff
>>>> *skb, const struct iovec *from,
>>>>                   struct page *page[MAX_SKB_FRAGS];
>>>>                   int num_pages;
>>>>                   unsigned long base;
>>>> +               unsigned long truesize;
>>>>
>>>>                   len = from->iov_len - offset;
>>>>                   if (!len) {
>>>> @@ -533,10 +534,11 @@ static int zerocopy_sg_from_iovec(struct
>> sk_buff
>>>> *skb, const struct iovec *from,
>>>>                       (num_pages>   MAX_SKB_FRAGS -
>>>> skb_shinfo(skb)->nr_frags))
>>>>                           /* put_page is in skb free */
>>>>                           return -EFAULT;
>>>> +               truesize = size * PAGE_SIZE;
>>> Here should be truesize = size * PAGE_SIZE - offset, right?
>>>
>> We get the whole user page, so need to account them all. Also this is
>> aligned with skb_copy_ubufs().
> Then this would double count the size of "first" offset left from
> previous copy, both skb->len and truesize.
>
> Thanks
> Shirley
>

Didn't see how this affact skb->len. And for truesize, I think they are 
different, when the offset were not zero, the data in this vector were 
divided into two parts. First part is copied into skb directly, and the 
second were pinned from a whole userspace page by get_user_pages_fast(), 
so we need count the whole page to the socket limit to prevent evil 
application.

Thanks
