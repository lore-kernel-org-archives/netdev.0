From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] xps-mp: Transmit Packet Steering for multiqueue
Date: Wed, 13 Oct 2010 11:39:59 +0200
Message-ID: <1286962799.3876.132.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1010121705500.15786@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:58240 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750730Ab0JMJkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 05:40:06 -0400
Received: by wwj40 with SMTP id 40so6217548wwj.1
        for <netdev@vger.kernel.org>; Wed, 13 Oct 2010 02:40:05 -0700 (PDT)
In-Reply-To: <alpine.DEB.1.00.1010121705500.15786@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 12 octobre 2010 =C3=A0 17:20 -0700, Tom Herbert a =C3=A9crit :


+#define netdev_get_xps_maps(dev) ((dev)->_tx[0].xps_maps)

Why is xps_maps stored on all struct netdev_queue and not in net_device
itself ?

> +#define QUEUE_MASK_SIZE(dev) (BITS_TO_LONGS(dev->num_tx_queues))
> +#define XPS_MAP_SIZE(dev) (sizeof(struct xps_map) + (num_possible_cp=
us() * \
> +    QUEUE_MASK_SIZE(dev) * sizeof(unsigned long)))
> +#define XPS_ENTRY(map, offset, dev) \
> +    (&map->queues[offset * QUEUE_MASK_SIZE(dev)])
> +#define netdev_get_xps_maps(dev) ((dev)->_tx[0].xps_maps)
> +
> +

num_possible_cpus() is a bit too expensive on some machines
(NR_CPUS=3D4096), please find a way to cache its result in XPS structs.

+       queues =3D XPS_ENTRY(maps, cpu, dev);
+
+       if (queue_index >=3D 0) {
+               if (test_bit(queue_index, queues)) {
+                       rcu_read_unlock();
+                       return queue_index;
+               }
+       }
+
+       weight =3D bitmap_weight(queues, dev->real_num_tx_queues);


Same here : Cant you store bitmap_weight() somewhere ?

+               select =3D ((u64) hash * weight) >> 32;
+               queue_index =3D
+                   find_first_bit(queues, dev->real_num_tx_queues);
+               while (select--)
+                       queue_index =3D find_next_bit(queues,
+                           dev->real_num_tx_queues, queue_index + 1);
+               break;

Ouch, thats pretty expensive and not scalable (say device has 64 virtua=
l
queues, on a 1024 cores machine), I think an array would be better

	queue_index =3D array[select];



