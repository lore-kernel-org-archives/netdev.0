From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2 v7] xps: Transmit Packet Steering
Date: Mon, 22 Nov 2010 14:33:56 +0100
Message-ID: <1290432836.2811.44.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1011211501430.14906@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60862 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754156Ab0KVNeP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Nov 2010 08:34:15 -0500
Received: by wyb28 with SMTP id 28so7019037wyb.19
        for <netdev@vger.kernel.org>; Mon, 22 Nov 2010 05:34:14 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1011211501430.14906@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 21 novembre 2010 =C3=A0 15:17 -0800, Tom Herbert a =C3=A9cr=
it :

=2E..

> +
> +static DEFINE_MUTEX(xps_map_mutex);
> +
> +static ssize_t store_xps_map(struct netdev_queue *queue,
> +		      struct netdev_queue_attribute *attribute,
> +		      const char *buf, size_t len)
> +{
> +	struct net_device *dev =3D queue->dev;
> +	cpumask_var_t mask;
> +	int err, i, cpu, pos, map_len, alloc_len, need_set;
> +	unsigned long index;
> +	struct xps_map *map, *new_map;
> +	struct xps_dev_maps *dev_maps, *new_dev_maps;
> +	int nonempty =3D 0;
> +
> +	if (!capable(CAP_NET_ADMIN))
> +		return -EPERM;
> +
> +	if (!alloc_cpumask_var(&mask, GFP_KERNEL))
> +		return -ENOMEM;
> +
> +	index =3D get_netdev_queue_index(queue);
> +
> +	err =3D bitmap_parse(buf, len, cpumask_bits(mask), nr_cpumask_bits)=
;
> +	if (err) {
> +		free_cpumask_var(mask);
> +		return err;
> +	}
> +
> +	new_dev_maps =3D kzalloc(max_t(unsigned,
> +	    XPS_DEV_MAPS_SIZE, L1_CACHE_BYTES), GFP_KERNEL);
> +	if (!new_dev_maps) {
> +		free_cpumask_var(mask);
> +		return -ENOMEM;
> +	}
> +
> +	mutex_lock(&xps_map_mutex);
> +
> +	dev_maps =3D dev->xps_maps;
> +
> +	for_each_possible_cpu(cpu) {
> +		new_map =3D map =3D dev_maps ? dev_maps->cpu_map[cpu] : NULL;
> +
> +		if (map) {
> +			for (pos =3D 0; pos < map->len; pos++)
> +				if (map->queues[pos] =3D=3D index)
> +					break;
> +			map_len =3D map->len;
> +			alloc_len =3D map->alloc_len;
> +		} else
> +			pos =3D map_len =3D alloc_len =3D 0;
> +
> +		need_set =3D cpu_isset(cpu, *mask) && cpu_online(cpu);
> +
> +		if (need_set && pos >=3D map_len) {
> +			/* Need to add queue to this CPU's map */
> +			if (map_len >=3D alloc_len) {
> +				alloc_len =3D alloc_len ?
> +				    2 * alloc_len : XPS_MIN_MAP_ALLOC;
> +				new_map =3D kzalloc(XPS_MAP_SIZE(alloc_len),
> +				    GFP_KERNEL);

		kzalloc_node(size, GFP_KERNEL, cpu_to_node(cpu))=20

to get memory close to the cpu ?

> +				if (!new_map)
> +					goto error;
> +				new_map->alloc_len =3D alloc_len;
> +				for (i =3D 0; i < map_len; i++)
> +					new_map->queues[i] =3D map->queues[i];
> +				new_map->len =3D map_len;
> +			}
> +			new_map->queues[new_map->len++] =3D index;
> +		} else if (!need_set && pos < map_len) {
> +			/* Need to remove queue from this CPU's map */
> +			if (map_len > 1)
> +				new_map->queues[pos] =3D
> +				    new_map->queues[--new_map->len];
> +			else
> +				new_map =3D NULL;
> +		}
> +		new_dev_maps->cpu_map[cpu] =3D new_map;
> +	}
> +
> +	/* Cleanup old maps */
> +	for_each_possible_cpu(cpu) {
> +		map =3D dev_maps ? dev_maps->cpu_map[cpu] : NULL;
> +		if (map && new_dev_maps->cpu_map[cpu] !=3D map)
> +			call_rcu(&map->rcu, xps_map_release);
> +		if (new_dev_maps->cpu_map[cpu])
> +			nonempty =3D 1;
> +	}
> +

