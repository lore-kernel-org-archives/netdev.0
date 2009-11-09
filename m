From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] check the return value of ndo_select_queue()
Date: Mon, 9 Nov 2009 19:29:00 +0800
Message-ID: <412e6f7f0911090329w4bdee21fn189e32f2f1bde743@mail.gmail.com>
References: <4AF7E221.2040901@gmail.com> <4AF7E5F1.6080608@gmail.com>
	 <4AF7E8C2.90707@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f188.google.com ([209.85.222.188]:48641 "EHLO
	mail-pz0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750991AbZKIL2z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 06:28:55 -0500
Received: by pzk26 with SMTP id 26so2035699pzk.4
        for <netdev@vger.kernel.org>; Mon, 09 Nov 2009 03:29:00 -0800 (PST)
In-Reply-To: <4AF7E8C2.90707@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/11/9 Eric Dumazet <eric.dumazet@gmail.com>:
> Eric Dumazet a =A8=A6crit :
>>
>> Yes, but this is a _very_ unlikely condition (a bug IMHO), so you co=
uld use :
>>
>> if (unlikely(queue_index >=3D dev->real_num_tx_queues)) {
>>       ...
>> }
>>
>> (This unlikely() clause is implied in WARN... macros)
>>
>
> Also, you want to trigger this message only once, or ratelimit it at =
least
>
>

How about this version:

        u16 queue_index;
        u16 (*ndo_select_queue)(struct net_device*, struct sk_buff*);
        unsigned int real_num_tx_queues =3D dev->real_num_tx_queues;

        if (real_num_tx_queues =3D=3D 1) {
                queue_index =3D 0;
        } else if ((ndo_select_queue =3D dev->netdev_ops->ndo_select_qu=
eue)) {
                queue_index =3D ndo_select_queue(dev, skb);
                if (unlikely(queue_index >=3D real_num_tx_queues)) {
                        if (net_ratelimit())
                                WARN(1, "%s selects TX queue %d, "
                                     "but real number of TX queues is %=
d\n",
                                     dev->name, queue_index,
                                     real_num_tx_queues);
                        queue_index =3D 0;
                }
        } else {
                queue_index =3D skb_tx_hash(dev, skb);
        }

        skb_set_queue_mapping(skb, queue_index);
        return netdev_get_tx_queue(dev, queue_index);


--=20
Regards=A3=AC
Changli Gao(xiaosuo@gmail.com)
