From: Qin Chuanyu <qinchuanyu@huawei.com>
Subject: Re: 8% performance improved by change tap interact with kernel stack
Date: Tue, 11 Feb 2014 21:21:55 +0800
Message-ID: <52FA23F3.7040404@huawei.com>
References: <52E766D4.4070901@huawei.com> <1390920560.28432.8.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <jasowang@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>,
	"Anthony Liguori" <anthony@codemonkey.ws>,
	KVM list <kvm@vger.kernel.org>, <netdev@vger.kernel.org>,
	Peter Klausler <pmk@google.com>, <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1390920560.28432.8.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
>
>>
>> The test result is as below:
>> 	CPU: Intel(R) Xeon(R) CPU E5620  @ 2.40GHz
>> 	NIC: intel 82599
>> 	Host OS/Guest OS:suse11sp3
>> 	Qemu-1.6
>> 	netperf udp 512(VM tx)
>> 	test model: VM->host->host
>>
>> 	modified before : 2.00Gbps 461146pps
>> 	modified after  : 2.16Gbps 498782pps
>>
>> 8% performance gained from this change,
>> Is there any problem for this patch ?
>
> http://patchwork.ozlabs.org/patch/52963/
the problem list above show that:

   Since the cgroup classifier has this check:
     if (softirq_count() !=3D SOFTIRQ_OFFSET))
	   return -1;
   We still fail to classify the frame.

but the source in the recently version has changed as below:
	if (in_serving_softirq()) {
		/* If there is an sk_classid we'll use that. */
		if (!skb->sk)
			return -1;
		classid =3D skb->sk->sk_classid;
	}

skb is allocated by tun_alloc_skb, so skb->sk is not NULL.
I think the problem is not existed anymore.


