From: Qin Chuanyu <qinchuanyu@huawei.com>
Subject: Re: 8% performance improved by change tap interact with kernel stack
Date: Wed, 29 Jan 2014 15:12:49 +0800
Message-ID: <52E8A9F1.3000700@huawei.com>
References: <52E766D4.4070901@huawei.com> <1390920560.28432.8.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <jasowang@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>,
	"Anthony Liguori" <anthony@codemonkey.ws>,
	KVM list <kvm@vger.kernel.org>, <netdev@vger.kernel.org>,
	Peter Klausler <pmk@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:42638 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750805AbaA2HNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jan 2014 02:13:49 -0500
In-Reply-To: <1390920560.28432.8.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/1/28 22:49, Eric Dumazet wrote:
> On Tue, 2014-01-28 at 16:14 +0800, Qin Chuanyu wrote:
>> according perf test result=EF=BC=8CI found that there are 5%-8% cpu =
cost on
>> softirq by use netif_rx_ni called in tun_get_user.
>>
>> so I changed the function which cause skb transmitted more quickly.
>> from
>> 	tun_get_user	->
>> 		 netif_rx_ni(skb);
>> to
>> 	tun_get_user	->
>> 		rcu_read_lock_bh();
>> 		netif_receive_skb(skb);
>> 		rcu_read_unlock_bh();
>
> No idea why you use rcu here ?

In my first version, I forgot to add lock when called netif_receive_skb
then I met a dad spinlock when using tcpdump.

tcpdump receive skb in netif_receive_skb but also in dev_queue_xmit.
and I have notice dev_queue_xmit add rcu_read_lock_bh before=20
transmitting skb, and this lock avoid race between softirq and transmit=
=20
thread.
	/* Disable soft irqs for various locks below. Also
	 * stops preemption for RCU.
	 */
	rcu_read_lock_bh();
Now I try to xmit skb in vhost thread, so I did the same thing.
