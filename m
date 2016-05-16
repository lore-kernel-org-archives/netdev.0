From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next] tuntap: introduce tx skb ring
Date: Mon, 16 May 2016 15:51:48 +0800
Message-ID: <57397C14.1080701@redhat.com>
References: <1463361421-4397-1-git-send-email-jasowang@redhat.com>
 <1463370998.18194.74.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463370998.18194.74.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016=E5=B9=B405=E6=9C=8816=E6=97=A5 11:56, Eric Dumazet wrote:
> On Mon, 2016-05-16 at 09:17 +0800, Jason Wang wrote:
>> We used to queue tx packets in sk_receive_queue, this is less
>> efficient since it requires spinlocks to synchronize between produce=
r
>> and consumer.
> ...
>
>>   	struct tun_struct *detached;
>> +	/* reader lock */
>> +	spinlock_t rlock;
>> +	unsigned long tail;
>> +	struct tun_desc tx_descs[TUN_RING_SIZE];
>> +	/* writer lock */
>> +	spinlock_t wlock;
>> +	unsigned long head;
>>   };
>>  =20
> Ok, we had these kind of ideas floating around for many other cases,
> like qdisc, UDP or af_packet sockets...
>
> I believe we should have a common set of helpers, not hidden in
> drivers/net/tun.c but in net/core/skb_ring.c or something, with more
> flexibility (like the number of slots)
>

Yes, this sounds good.

> BTW, why are you using spin_lock_irqsave() in tun_net_xmit() and
> tun_peek() ?
>
> BH should be disabled already (in tun_next_xmit()), and we can not
> transmit from hard irq.
>
> Thanks.

Right, no need. But for tun_peek() we need spin_lock_bh() since it was=20
called by vhost-net.

Thanks
