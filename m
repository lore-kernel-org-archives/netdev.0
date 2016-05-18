From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next] tuntap: introduce tx skb ring
Date: Wed, 18 May 2016 18:23:48 +0800
Message-ID: <573C42B4.6040708@redhat.com>
References: <1463361421-4397-1-git-send-email-jasowang@redhat.com>
 <1463370998.18194.74.camel@edumazet-glaptop3.roam.corp.google.com>
 <57397C14.1080701@redhat.com> <20160518101359.37f5343b@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160518101359.37f5343b@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016=E5=B9=B405=E6=9C=8818=E6=97=A5 16:13, Jesper Dangaard Brouer wr=
ote:
> On Mon, 16 May 2016 15:51:48 +0800
> Jason Wang <jasowang@redhat.com> wrote:
>
>> On 2016=E5=B9=B405=E6=9C=8816=E6=97=A5 11:56, Eric Dumazet wrote:
>>> On Mon, 2016-05-16 at 09:17 +0800, Jason Wang wrote:
>>>> We used to queue tx packets in sk_receive_queue, this is less
>>>> efficient since it requires spinlocks to synchronize between produ=
cer
>>>> and consumer.
>>> ...
>>>  =20
>>>>    	struct tun_struct *detached;
>>>> +	/* reader lock */
>>>> +	spinlock_t rlock;
>>>> +	unsigned long tail;
>>>> +	struct tun_desc tx_descs[TUN_RING_SIZE];
>>>> +	/* writer lock */
>>>> +	spinlock_t wlock;
>>>> +	unsigned long head;
>>>>    };
>>>>     =20
>>> Ok, we had these kind of ideas floating around for many other cases=
,
>>> like qdisc, UDP or af_packet sockets...
>>>
>>> I believe we should have a common set of helpers, not hidden in
>>> drivers/net/tun.c but in net/core/skb_ring.c or something, with mor=
e
>>> flexibility (like the number of slots)
>>>  =20
>> Yes, this sounds good.
> I agree. It is sad to see everybody is implementing the same thing,
> open coding an array/circular based ring buffer.  This kind of code i=
s
> hard to maintain and get right with barriers etc.  We can achieve the
> same performance with a generic implementation, by inlining the help
> function calls.
>
> I implemented an array based Lock-Free/cmpxchg based queue, that you
> could be inspired by, see:
>   https://github.com/netoptimizer/prototype-kernel/blob/master/kernel=
/include/linux/alf_queue.h

This looks really interesting, thanks.

>
> The main idea behind my implementation is bulking, to amortize the
> locked cmpxchg operation. You might not need it now, but I expect we
> need it in the future.

Right, we need change APIs which can read or write multiple buffers at=20
one time for tun (and for others). I agree this will be a good=20
optimization in the future.

>
> You cannot use my alf_queue directly as your "struct tun_desc" is
> larger than one-pointer (which the alf_queue works with).  But it
> should be possible to extend to handle larger "objects".

Yes, and for more generic usage, maybe one more void * is sufficient.

>
>
> Maybe Steven Rostedt have an even better ring queue implementation
> already avail in the kernel?
>

You mean ring buffer in tracing? Not sure, but it looks rather complex=20
at first glance.
