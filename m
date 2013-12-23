From: Jason Wang <jasowang@redhat.com>
Subject: Re: [RFC PATCH] net, tun: remove the flow cache
Date: Mon, 23 Dec 2013 15:00:40 +0800
Message-ID: <52B7DF98.1020108@redhat.com>
References: <1387265182-27312-1-git-send-email-zwu.kernel@gmail.com>	<52B0100A.3030002@redhat.com>	<CAEH94LhM5WWLEETv-n0cYs4wv+Hw4pC7-c+b5cKqRxdx2XywNw@mail.gmail.com>	<52B02206.6030709@redhat.com> <CAEH94LjyVOopKUJ+yJV97UF6J8akohSbqqZN6g+m_1EyfWNTUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	linux-kernel mlist <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Zhi Yong Wu <zwu.kernel@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEH94LjyVOopKUJ+yJV97UF6J8akohSbqqZN6g+m_1EyfWNTUw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/18/2013 10:08 AM, Zhi Yong Wu wrote:
> On Tue, Dec 17, 2013 at 6:05 PM, Jason Wang <jasowang@redhat.com> wrote:
>> On 12/17/2013 05:13 PM, Zhi Yong Wu wrote:
>>> On Tue, Dec 17, 2013 at 4:49 PM, Jason Wang <jasowang@redhat.com> wrote:
>>>>> On 12/17/2013 03:26 PM, Zhi Yong Wu wrote:
>>>>>>> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>>>>>>>
>>>>>>> The flow cache is an extremely broken concept, and it usually brings up
>>>>>>> growth issues and DoS attacks, so this patch is trying to remove it from
>>>>>>> the tuntap driver, and insteadly use a simpler way for its flow control.
>>>>> NACK.
>>>>>
>>>>> This single function revert does not make sense to me. Since:
>>> IIRC, the tuntap flow cache is only used to save the mapping of skb
>>> packet <-> queue index. My idea only save the queue index in skb_buff
>>> early when skb buffer is filled, not in flow cache as the current
>>> code. This method is actually more simpler and completely doesn't need
>>> any flow cache.
>> Nope. Flow caches record the flow to queues mapping like what most
>> multiqueue nic does. The only difference is tun record it silently while
>> most nic needs driver to tell the mapping.
> Just check virtio specs, i seem to miss the fact that flow cache
> enable packet steering in mq mode, thanks for your comments. But i
> have some concerns about some of your comments.
>> What your patch does is:
>> - set the queue mapping of skb during tun_get_user(). But most drivers
>> using XPS or processor id to select the real tx queue. So the real txq
>> depends on the cpu that vhost or qemu is running. This setting does not
> Doesn't those drivers invoke netdev_pick_tx() or its counterpart to
> select real tx queue? e.g. tun_select_queue(). or can you say it with
> an example?

See __netdev_pick_tx() which will call get_xps_queues() to let XPS to
choose txq if there's no ndo_select_queue() method. Even if some driver
who has its own implementation, it will also call __netdev_pick_tx() for
ordinary traffic. Few drivers just using processor id to select txq. See
tile_net_select_queue(). Some drivers does this implicitly through XPS,
see ixgbe and virtio-net.

So the value you intend to "teach" the hardware nic may not work for
most of the cases.
> Moreover, how do those drivers know which cpu vhost or qemu is running on?

It does not know, but it can use processor id which is normally where
qemu/vhost is running.
>> have any effect in fact.
>> - the queue mapping of skb were fetched during tun_select_queue(). This
>> value is usually set by a multiqueue nic to record which hardware rxq
>> was this packet came.
> ah? Can you let me know where a mq nic controller set it?

Almost all multiqueue nic set this when it receives a packet. One
example is ixgbe_process_skb_fields().
>> Can you explain how your patch works exactly?
> You have understood it.
>>>>> - You in fact removes the flow steering function in tun. We definitely
>>>>> need something like this to unbreak the TCP performance in a multiqueue
>>> I don't think it will downgrade the TCP perf even in mq guest, but my
>>> idea maybe has better TCP perf, because it doesn't have any cache
>>> table lookup, etc.
>> Did you test and compare the performance numbers? Did you run profiler
>> to see how much does the lookup cost?
> No, As i jus said above, i miss that flow cache can enable packet
> steering. But Did you do related perf testing? To be honest, i am
> wondering how much perf the packet steering can improve. Actually it
> also injects a lot of cache lookup cost.

Not a lot unless there's a unbalance distribution of the hash bucket
which is very rare in the common case.

Without it, you may get a very huge regression even on a single stream
tcp netperf test. Flow caches guarantees packets of a single stream was
not processed by more than one vhost threads/vcpus which is very
important for TCP performance.
>>>>> guest. Please have a look at the virtio-net driver / virtio sepc for
>>>>> more information.
>>>>> - The total number of flow caches were limited to 4096, so there's no
>>>>> DoS or growth issue.
>>> Can you check why the ipv4 routing cache is removed? maybe i miss
>>> something, if yes, pls correct me. :)
>> The main differences is that the flow caches were best effort. Tun can
>> not store all flows to queue mapping, and even a hardware nic can not do
>> this. If a packet misses the flow cache, it's safe to distribute it
>> randomly or through another method. So the limitation just work.
> Exactly, we can know this from tun_select_queue().
>> Could you please explain the DoS or growth issue you meet here?
>>>>> - The only issue is scalability, but fixing this is not easy. We can
>>>>> just use arrays/indirection table like RSS instead of hash buckets, it
>>>>> saves some time in linear search but has other issues like collision
>>>>> - I've also had a RFC of using aRFS in the past, it also has several
>>>>> drawbacks such as busy looping in the networking hotspot.
>>>>>
>>>>> So in conclusion, we need flow steering in tun, just removing current
>>>>> method does not help. The proper way is to expose several different
>>>>> methods to user and let user to choose the preferable mechanism like
>>>>> packet.
>>> By the way, let us look at what other networking guys think of this,
>>> such as MST, dave, etc. :)
>>>
>> Of course.
>
>
