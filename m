From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [PATCH]  802.1Q VLAN
Date: Sat, 30 Oct 2004 01:37:50 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4182D44E.7070507@tpack.net>
References: <41797696.9070905@candelatech.com>	 <20041022214611.GA4948@electric-eye.fr.zoreil.com>	 <41798506.1030909@candelatech.com> <417D675F.3000909@candelatech.com>	 <4181838B.6040002@tpack.net>  <41818D99.9020300@candelatech.com> <1099038566.1813.99.camel@cyan.cph.tpack.net> <418281C1.9080707@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>,
        "Linux 802.1Q VLAN" <vlan@candelatech.com>,
        Francois Romieu <romieu@fr.zoreil.com>,
        "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <418281C1.9080707@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> Tommy Christensen wrote:
> 
>> On Fri, 2004-10-29 at 02:23, Ben Greear wrote:
>>
>>>> o It is considered an error if a queue-less device returns anything 
>>>> but zero from its
>>>>   hard_start_xmit() function (see dev_queue_xmit()).
>>>
>>>
>>> This certainly was not clear to me.  The comments in dev_queue_xmit are
>>> wrong about the return value (failure cases can be > zero too).  Are
>>> there other errors or ommissions there?
>>
>>
>> A return value > zero doesn't mean failure. It indicates congestion.
> 
> 
> Ok, but the skb is always deleted by the net_queue_xmit code if the
> return is not zero?  The difference between a hard-start-xmit failure
> on eth0 when the hardware-queue is full and having a rate-limiting
> queue drop a packet is virtually identical to me....

For a virtual device: yes, dev_queue_xmit() drops the skb. What else
could it do with it? The semantic is that dev_queue_xmit always consumes
skb's given to it.

A physical device will have a qdisc attached to it, so you don't get to
see that the hardware queue is full. qdisc handles this case for you by
retrying the transmission later. This is not (yet) congestion.
OTOH if qdisc doesn't have room for a new skb in its *software* queue,
the skb is dropped and congestion is reported upwards the stack.

>>> What sorts of things go wrong if you do return an error here when you 
>>> don't
>>> have a queue?
>>
>>
>> It is interpreted as a tx failure rather than congestion. So it doesn't
>> help the upper layers like you wanted it to.
>> And it spews out an error message.
> 
> 
> The e1000 and probably other NICs have failed hard_start_xmit for a long
> time, and they are some of the most stable and high-performance NICs.
> So, the upper layers must be handling it OK some how or another.

Yes, this is perfectly valid for real devices. It is handled by the
qdisc system - specifically qdisc_restart().

> Can you point me to some code that takes a different action based on the
> return values of dev_queue_xmit?  That may help me understand better.

This is hard to track due to indirect function calls, but take a look
at tcp_transmit_skb(). It ultimately calls dev_queue_xmit().

>>>> o So, lets add a tx queue to it. Sure, that would be nice. Now we 
>>>> can even do shaping
>>>>   and other fancy stuff. But then how do we manage 
>>>> netif_queue_stopped? Especially
>>>>   restarting the queue could be tricky.
>>>
>>>
>>> Right... it would probably be an O(N) thing to wake the queues for 
>>> all virtual
>>> devices on a physical device, and we certainly don't want to do that
>>> often.  Maybe if you only tried to wake the blocked queues (ie, kept 
>>> a list
>>> of just blocked queues), then that would be less painful on average,
>>> but the worst-case is still bad.
>>
>>
>> Yeah, we probably would need some sort of notification from the
>> qdisc of the underlying device when it can accept packets again.
> 
> 
> I did something like this for my non-busy-spin pktgen re-write and it
> works fine with both VLANs and physical devices.  I just hooked
> directly into this code in netdevice.h:
> 
> static inline void netif_wake_queue(struct net_device *dev)
> {
> #ifdef CONFIG_NETPOLL_TRAP
>     if (netpoll_trap())
>         return;
> #endif
>     if (test_and_clear_bit(__LINK_STATE_XOFF, &dev->state)) {
>         __netif_schedule(dev);
> 
>                 if (dev->notify_queue_woken) {
>                    dev->notify_queue_woken(dev);
>                 }
>         }
> }
> 
> pktgen registers this hook on the physical device when it starts 
> generating on
> the physical device or any VLANs attached to it.  To make a scheme like 
> this work
> in general, we'd probably need a chain of callbacks instead of a single 
> method
> pointer...

Nice. This idea is definitely worth persuing. However, ideally we
would want to be notified when the *qdisc* queue opens up - this
is our "tx ring buffer".

>>>> o But couldn't we skip netif_stop_queue() and just return 
>>>> NETDEV_TX_BUSY when congested?
>>>>   No, that would make the qdisc system "busy-retry" untill it 
>>>> succeeds. BAD.
>>>>
>>>> o It is unsafe to pass a shared skb to dev_queue_xmit() unless you 
>>>> control all the
>>>>   references yourself. (It will likely be enqueued on a list.)
>>>
>>>
>>> Since we either free the duplicate copy, or pass it to the queue and 
>>> forget
>>> about it, this last point does not matter in the patch I submitted, 
>>> right?
>>
>>
>>
>> Yes. This is the right way to do it. *Unless* the skb is already shared
>> when you receive it (e.g. from pktgen).
> 
> 
> You can't send shared skbs regardless, because the vlan Xmit changes the 
> skb->dev at least, so
> you just have to set the multi-skb setting in pktgen to 0 so that it 
> does not
> share when using VLANs.

By sheer accident, this would actually work! Nevertheless, the code
should obviously handle this correctly (whatever that means?!).


-Tommy
