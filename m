From: Jason Wang <jasowang@redhat.com>
Subject: Re: [RFC PATCH] net, tun: remove the flow cache
Date: Tue, 17 Dec 2013 18:05:58 +0800
Message-ID: <52B02206.6030709@redhat.com>
References: <1387265182-27312-1-git-send-email-zwu.kernel@gmail.com>	<52B0100A.3030002@redhat.com> <CAEH94LhM5WWLEETv-n0cYs4wv+Hw4pC7-c+b5cKqRxdx2XywNw@mail.gmail.com>
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
In-Reply-To: <CAEH94LhM5WWLEETv-n0cYs4wv+Hw4pC7-c+b5cKqRxdx2XywNw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/17/2013 05:13 PM, Zhi Yong Wu wrote:
> On Tue, Dec 17, 2013 at 4:49 PM, Jason Wang <jasowang@redhat.com> wrote:
>> > On 12/17/2013 03:26 PM, Zhi Yong Wu wrote:
>>> >> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>>> >>
>>> >> The flow cache is an extremely broken concept, and it usually brings up
>>> >> growth issues and DoS attacks, so this patch is trying to remove it from
>>> >> the tuntap driver, and insteadly use a simpler way for its flow control.
>> >
>> > NACK.
>> >
>> > This single function revert does not make sense to me. Since:
> IIRC, the tuntap flow cache is only used to save the mapping of skb
> packet <-> queue index. My idea only save the queue index in skb_buff
> early when skb buffer is filled, not in flow cache as the current
> code. This method is actually more simpler and completely doesn't need
> any flow cache.

Nope. Flow caches record the flow to queues mapping like what most
multiqueue nic does. The only difference is tun record it silently while
most nic needs driver to tell the mapping.

What your patch does is:
- set the queue mapping of skb during tun_get_user(). But most drivers
using XPS or processor id to select the real tx queue. So the real txq
depends on the cpu that vhost or qemu is running. This setting does not
have any effect in fact.
- the queue mapping of skb were fetched during tun_select_queue(). This
value is usually set by a multiqueue nic to record which hardware rxq
was this packet came.

Can you explain how your patch works exactly?
>> >
>> > - You in fact removes the flow steering function in tun. We definitely
>> > need something like this to unbreak the TCP performance in a multiqueue
> I don't think it will downgrade the TCP perf even in mq guest, but my
> idea maybe has better TCP perf, because it doesn't have any cache
> table lookup, etc.

Did you test and compare the performance numbers? Did you run profiler
to see how much does the lookup cost?
>> > guest. Please have a look at the virtio-net driver / virtio sepc for
>> > more information.
>> > - The total number of flow caches were limited to 4096, so there's no
>> > DoS or growth issue.
> Can you check why the ipv4 routing cache is removed? maybe i miss
> something, if yes, pls correct me. :)

The main differences is that the flow caches were best effort. Tun can
not store all flows to queue mapping, and even a hardware nic can not do
this. If a packet misses the flow cache, it's safe to distribute it
randomly or through another method. So the limitation just work.

Could you please explain the DoS or growth issue you meet here?
>> > - The only issue is scalability, but fixing this is not easy. We can
>> > just use arrays/indirection table like RSS instead of hash buckets, it
>> > saves some time in linear search but has other issues like collision
>> > - I've also had a RFC of using aRFS in the past, it also has several
>> > drawbacks such as busy looping in the networking hotspot.
>> >
>> > So in conclusion, we need flow steering in tun, just removing current
>> > method does not help. The proper way is to expose several different
>> > methods to user and let user to choose the preferable mechanism like
>> > packet.
> By the way, let us look at what other networking guys think of this,
> such as MST, dave, etc. :)
>

Of course.
