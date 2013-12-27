From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next 2/3] virtio-net: use per-receive queue page frag
	alloc for mergeable bufs
Date: Fri, 27 Dec 2013 14:12:41 +0800
Message-ID: <52BD1A59.9090706@redhat.com>
References: <1387239389-13216-1-git-send-email-mwdalton@google.com>		
	<1387239389-13216-2-git-send-email-mwdalton@google.com>		
	<52B7F065.3010707@redhat.com>		
	<1387819627.12212.4.camel@edumazet-glaptop2.roam.corp.google.com>		
	<20131223193704.GC1582@redhat.com>		
	<CANJ5vPLEV_Z-D-0tThwhWXbHVaRWOLv566Xk1eD4TNYqNvknHw@mail.gmail.com>	
	<1388094991.12212.34.camel@edumazet-glaptop2.roam.corp.google.com>	
	<52BD084F.5040301@redhat.com>
	<1388123210.12212.44.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Dalton <mwdalton@google.com>, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org,
	lf-virt <virtualization@lists.linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1388123210.12212.44.camel@edumazet-glaptop2.roam.corp.google.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 12/27/2013 01:46 PM, Eric Dumazet wrote:
> On Fri, 2013-12-27 at 12:55 +0800, Jason Wang wrote:
>> On 12/27/2013 05:56 AM, Eric Dumazet wrote:
>>> On Thu, 2013-12-26 at 13:28 -0800, Michael Dalton wrote:
>>>> On Mon, Dec 23, 2013 at 11:37 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
>>>>> So there isn't a conflict with respect to locking.
>>>>>
>>>>> Is it problematic to use same page_frag with both GFP_ATOMIC and with
>>>>> GFP_KERNEL? If yes why?
>>>> I believe it is safe to use the same page_frag and I will send out a
>>>> followup patchset using just the per-receive page_frags. For future
>>>> consideration, Eric noted that disabling NAPI before GFP_KERNEL
>>>> allocs can potentially inhibit virtio-net network processing for some
>>>> time (e.g., during a blocking memory allocation or preemption).
>>> Yep, using napi_disable() in the refill process looks quite inefficient
>>> to me, it not buggy.
>>>
>>> napi_disable() is a big hammer, while whole idea of having a process to
>>> block on GFP_KERNEL allocations is to allow some asynchronous behavior.
>>>
>>> I have hard time to convince myself virtio_net is safe anyway with this
>>> work queue thing.
>>>
>>> virtnet_open() seems racy for example :
>>>
>>>         for (i = 0; i < vi->max_queue_pairs; i++) {
>>>                 if (i < vi->curr_queue_pairs)
>>>                         /* Make sure we have some buffers: if oom use wq. */
>>>                         if (!try_fill_recv(&vi->rq[i], GFP_KERNEL))
>>>                                 schedule_delayed_work(&vi->refill, 0);
>>>                 virtnet_napi_enable(&vi->rq[i]);
>>>
>>>
>>> What if the workqueue is scheduled _before_ the call to virtnet_napi_enable(&vi->rq[i]) ?
>> Then napi_disable() in refill_work() will busy wait until napi is
>> enabled by virtnet_napi_enable() which looks safe. Looks like the real
>> issue is in virtnet_restore() who calls try_fill_recv() in neither napi
>> context nor napi disabled context.
> I think you don't really get the race.
>
> The issue is the following :
>
> CPU0                                                        CPU1
>
> schedule_delayed_work()
>                                           napi_disable(&rq->napi);
>                                           try_fill_recv(rq, GFP_KERNEL);

If I didn't miss anything. In this case, for a specific rq,
napi_disable() won't return immediately since NAPI_STATE_SCHED bit was
still set. It will busy wait until NAPI_STATE_SCHED bit was clear by
virtnet_napi_enable(), and then reset the bit. So try_fill_recv() should
be called after its napi was enabled by virtnet_napi_enable() in CPU0.

So the following order were guaranteed:
- try_fill_recv(rq, GFP_ATOMIC) in CPU0
- virtnet_napi_enable(&vi->rq[i]) in CPU0
- napi_disable(&rq->napi) returned in CPU1
- try_fill_recv(rq) in CPU1
...
>
> virtnet_napi_enable(&vi->rq[i]);
> ...
> try_fill_recv(rq, GFP_ATOMIC);
>
>                                          napi_enable();// crash on :
>                                            BUG_ON(!test_bit(NAPI_STATE_SCHED, &n->state)); 
>
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
