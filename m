From: "Grumbach, Emmanuel" <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v2 3/3] iwlwifi: mvm: transfer the truesize to the last
 TSO segment
Date: Thu, 20 Aug 2015 07:40:08 +0000
Message-ID: <0BA3FCBA62E2DC44AF3030971E174FB32E825C41@hasmsx107.ger.corp.intel.com>
References: <1439989181-4444-1-git-send-email-emmanuel.grumbach@intel.com>
	 <1439989181-4444-4-git-send-email-emmanuel.grumbach@intel.com>
	 <1439994266.6610.14.camel@edumazet-glaptop2.roam.corp.google.com>
	 <0BA3FCBA62E2DC44AF3030971E174FB32E8253CF@hasmsx107.ger.corp.intel.com>
 <1440016762.6610.33.camel@edumazet-glaptop2.roam.corp.google.com>
 <0BA3FCBA62E2DC44AF3030971E174FB32E825B80@hasmsx107.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"ido-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org" <ido-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 08/20/2015 10:21 AM, Grumbach, Emmanuel wrote:
> 
> 
> On 08/19/2015 11:39 PM, Eric Dumazet wrote:
>> On Wed, 2015-08-19 at 19:17 +0000, Grumbach, Emmanuel wrote:
>>
>>> Hm.. how would net/core/tso.c avoid this?
>>
>> Because a driver using these helpers keep around the original LSO packet
>> and frees it normally at TX completion time.
>>
>>> I can't see anything related to truesize there.
>>> Note that this work since it is guaranteed that we release the skbs in
>>> order.
>>>
>>>>
>>>> (BTW TCP packets do not have sock_wfree as destructor but tcp_wfree(),
>>>> yet we want backpressure mostly for TCP stack (TCP Small Queues))
>>>>
>>>>
>>>
>>> I am not sure I follow here.
>>> You want me to test:
>>> if (skb_gso->destructor == tcp_wfree) ?
>>
>>
>> Yes.
>>
>> Look for example at tcp_gso_segment() (called from skb_gso_segment())
>>
>> copy_destructor = gso_skb->destructor == tcp_wfree;
>> ...
>>         /* Following permits TCP Small Queues to work well with GSO :
>>          * The callback to TCP stack will be called at the time last frag
>>          * is freed at TX completion, and not right now when gso_skb
>>          * is freed by GSO engine
>>          */
>>         if (copy_destructor) {
>>                 swap(gso_skb->sk, skb->sk);
>>                 swap(gso_skb->destructor, skb->destructor);
>>                 sum_truesize += skb->truesize;
>>                 atomic_add(sum_truesize - gso_skb->truesize,
>>                            &skb->sk->sk_wmem_alloc);
>>         }
>>
>>
>>>
>>> I checked that code using iperf and saw that I don't get into this if,
>>> but I (probably wrongly) assumed that other applications would set a
>>> flag on the socket (forgive my ignorance) that would make this if be taken.
>>
>> If you do not see skb->destructor == tcp_wfree, then something is
>> definitely wrong on your setup.
>>
> 
> tcp_wfree isn't exported. I can change that. It will be a challenge for
> backport though. Hm....
> 

But you seem to say that gso_skb->destructor *should* point to
tcp_wfree, so maybe testing gso_skb->destructor isn't NULL is good enough?
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
