From: Toshiaki Makita <toshiaki.makita1@gmail.com>
Subject: Re: [PATCH v2 net-next] vlan: Add GRO support for non hardware accelerated
 vlan
Date: Tue, 02 Jun 2015 01:03:16 +0900
Message-ID: <556C8244.1090400@gmail.com>
References: <1433163307-9299-1-git-send-email-makita.toshiaki@lab.ntt.co.jp> <1433167957.1895.4.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S . Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35315 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751621AbbFAQDb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 12:03:31 -0400
Received: by padjw17 with SMTP id jw17so40116015pad.2
        for <netdev@vger.kernel.org>; Mon, 01 Jun 2015 09:03:30 -0700 (PDT)
In-Reply-To: <1433167957.1895.4.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/06/01 (=E6=9C=88) 23:12, Eric Dumazet wrote:
> On Mon, 2015-06-01 at 21:55 +0900, Toshiaki Makita wrote:
>
>> @@ -668,6 +753,9 @@ static int __init vlan_proto_init(void)
>>   	if (err < 0)
>>   		goto err5;
>>
>> +	for (i =3D 0; i < ARRAY_SIZE(vlan_packet_offloads); i++)
>> +		dev_add_offload(&vlan_packet_offloads[i]);
>> +
>>   	vlan_ioctl_set(vlan_ioctl_handler);
>>   	return 0;
>
> My concern about this is :
>
> This might slow down GRO stack for other traffic, if dev_add_offload(=
)
> for vlan offloads is called after
> dev_add_offload(&ip_packet_offload) /
> dev_add_offload(&ipv6_packet_offload)

I didn't have that concern because there are already other similar=20
offloads (eth, mpls_uc, mpls_mc). But indeed, they and this could slow=20
down GRO stack.

>
>
> This is because list_add_rcu is used and this inserts in front of the
> offload_base list.
>
> void dev_add_offload(struct packet_offload *po)
> {
>          struct list_head *head =3D &offload_base;
>
>          spin_lock(&offload_lock);
>          list_add_rcu(&po->list, head);
>          spin_unlock(&offload_lock);
> }
>
> Can we ensure offload_base contains a sensible order of expected type=
s ?

Add priority to packet_offload like nf_hook_ops?
Or have dev_add_offload() prioritize IP > IPV6 > others?

Toshiaki Makita
