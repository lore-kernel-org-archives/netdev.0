From: Qin Chuanyu <qinchuanyu@huawei.com>
Subject: Re: [PATCH] tun: use netif_receive_skb instead of netif_rx_ni
Date: Wed, 12 Feb 2014 14:46:16 +0800
Message-ID: <52FB18B8.4070401@huawei.com>
References: <52FA32C5.9040601@huawei.com> <52FB066E.1020006@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Anthony Liguori <anthony@codemonkey.ws>,
	KVM list <kvm@vger.kernel.org>, <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Jason Wang <jasowang@redhat.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:36694 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711AbaBLGrS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 01:47:18 -0500
In-Reply-To: <52FB066E.1020006@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/2/12 13:28, Jason Wang wrote:

> A question: without NAPI weight, could this starve other net devices?
tap xmit skb use thread context=EF=BC=8Cthe poll func of physical nic d=
river
could be called in softirq context without change.

I had test it by binding vhost thread and physic nic interrupt on the=20
same vcpu, use netperf xmit udp, test model is VM1-Host1-Host2.

if only VM1 xmit skb, the top show as below :
Cpu1 :0.0%us, 95.0%sy, 0.0%ni, 0.0%id,  0.0%wa, 0.0%hi, 5.0%si,  0.0%st

then use host2 xmit skb to VM1, the top show as below :
Cpu1 :0.0%us, 41.0%sy, 0.0%ni, 0.0%id,  0.0%wa, 0.0%hi, 59.0%si, 0.0%st

so I think there is no problem with this change.

>>   drivers/net/tun.c |    4 +++-
>>   1 files changed, 3 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
>> index 44c4db8..90b4e58 100644
>> --- a/drivers/net/tun.c
>> +++ b/drivers/net/tun.c
>> @@ -1184,7 +1184,9 @@ static ssize_t tun_get_user(struct tun_struct
>> *tun, struct tun_file *tfile,
>>       skb_probe_transport_header(skb, 0);
>>
>>       rxhash =3D skb_get_hash(skb);
>> -    netif_rx_ni(skb);
>> +    rcu_read_lock_bh();
>> +    netif_receive_skb(skb);
>> +    rcu_read_unlock_bh();
>>
>>       tun->dev->stats.rx_packets++;
>>       tun->dev->stats.rx_bytes +=3D len;
>
>
> .
>
