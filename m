From: Jason Wang <jasowang@redhat.com>
Subject: Re: TUN problems (regression?)
Date: Fri, 28 Dec 2012 13:43:54 +0800
Message-ID: <50DD319A.5000708@redhat.com>
References: <4151394.nMo40zlg68@sifl> <1356046697.21834.3606.camel@edumazet-glaptop> <20121220155001.538bbdb0@nehalam.linuxnetplumber.net> <50D3D85B.1070605@redhat.com> <1356061179.21834.4515.camel@edumazet-glaptop> <50D3E510.6020008@redhat.com> <20121227164106.078604a8@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <erdnetdev@gmail.com>, Paul Moore <pmoore@redhat.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25148 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750892Ab2L1FoA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Dec 2012 00:44:00 -0500
In-Reply-To: <20121227164106.078604a8@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/28/2012 08:41 AM, Stephen Hemminger wrote:
> On Fri, 21 Dec 2012 12:26:56 +0800
> Jason Wang <jasowang@redhat.com> wrote:
>
>> On 12/21/2012 11:39 AM, Eric Dumazet wrote:
>>> On Fri, 2012-12-21 at 11:32 +0800, Jason Wang wrote:
>>>> On 12/21/2012 07:50 AM, Stephen Hemminger wrote:
>>>>> On Thu, 20 Dec 2012 15:38:17 -0800
>>>>> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>>>>
>>>>>> On Thu, 2012-12-20 at 18:16 -0500, Paul Moore wrote:
>>>>>>> [CC'ing netdev in case this is a known problem I just missed ...]
>>>>>>>
>>>>>>> Hi Jason,
>>>>>>>
>>>>>>> I started doing some more testing with the multiqueue TUN changes and I ran 
>>>>>>> into a problem when running tunctl: running it once w/o arguments works as 
>>>>>>> expected, but running it a second time results in failure and a 
>>>>>>> kmem_cache_sanity_check() failure.  The problem appears to be very repeatable 
>>>>>>> on my test VM and happens independent of the LSM/SELinux fixup patches.
>>>>>>>
>>>>>>> Have you seen this before?
>>>>>>>
>>>>>> Obviously code in tun_flow_init() is wrong...
>>>>>>
>>>>>> static int tun_flow_init(struct tun_struct *tun)
>>>>>> {
>>>>>>         int i;
>>>>>>
>>>>>>         tun->flow_cache = kmem_cache_create("tun_flow_cache",
>>>>>>                                             sizeof(struct tun_flow_entry), 0, 0,
>>>>>>                                             NULL);
>>>>>>         if (!tun->flow_cache)
>>>>>>                 return -ENOMEM;
>>>>>> ...
>>>>>> }
>>>>>>
>>>>>>
>>>>>> I have no idea why we would need a kmem_cache per tun_struct,
>>>>>> and why we even need a kmem_cache.
>>>>> Normally flow malloc/free should be good enough.
>>>>> It might make sense to use private kmem_cache if doing hlist_nulls.
>>>>>
>>>>>
>>>>> Acked-by: Stephen Hemminger <shemminger@vyatta.com>
>>>> Should be at least a global cache, I thought I can get some speed-up by
>>>> using kmem_cache.
>>>>
>>>> Acked-by: Jason Wang <jasowang@redhat.com>
>>> Was it with SLUB or SLAB ?
>>>
>>> Using generic kmalloc-64 is better than a dedicated kmem_cache of 48
>>> bytes per object, as we guarantee each object is on a single cache line.
>>>
>>>
>> Right, thanks for the explanation.
>>
> I wonder if TUN would be better if it used a array to translate
> receive hash to receive queue. This is how real hardware works with the
> indirection table, and it would allow RFS acceleration. The current flow
> cache stuff is prone to DoS attack and scaling problems with lots of
> short lived flows.

The problem of indirection table is hash collision which may even happen
when few flows existed.

For the RFS, we can open a API/ioctl for userspace to add or remove a
flow cache.

For the DoS/scaling issue, I have an idea of:
- limit the total number of flow entries in tun/tap
- only update the flow entry every N (say 20 like ixgbe) packets or the
the tcp packet has sync flag
- I'm not sure skb_get_rxhash() is lightweight enough, or change to more
lightweight one?

Any suggestions?

Thanks
