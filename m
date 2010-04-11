From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] rps: add flow director support
Date: Sun, 11 Apr 2010 18:05:39 +0200
Message-ID: <1271001939.2078.61.camel@edumazet-laptop>
References: <1271022140-3917-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:33138 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752139Ab0DKQFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Apr 2010 12:05:44 -0400
Received: by bwz19 with SMTP id 19so45288bwz.21
        for <netdev@vger.kernel.org>; Sun, 11 Apr 2010 09:05:42 -0700 (PDT)
In-Reply-To: <1271022140-3917-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 12 avril 2010 =C3=A0 05:42 +0800, Changli Gao a =C3=A9crit :
> add rps flow director support
>=20
> with rps flow director, users can do weighted packet dispatching amon=
g CPUs.
> For example, CPU0:CPU1 is 1:3 for eth0's rx-0:
>=20
>  localhost linux # echo 4 > /sys/class/net/eth0/queues/rx-0/rps_flows=
 =20
>  localhost linux # echo 0 > /sys/class/net/eth0/queues/rx-0/rps_flow_=
0
>  localhost linux # echo 1 > /sys/class/net/eth0/queues/rx-0/rps_flow_=
1
>  localhost linux # echo 1 > /sys/class/net/eth0/queues/rx-0/rps_flow_=
2
>  localhost linux # echo 1 > /sys/class/net/eth0/queues/rx-0/rps_flow_=
3
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----

Changli

I am a bit disappointed to find so many bugs in your patch.

I believe this is over engineering at this stage, we yet have to get
some benches or real world results.

Plus it conflicts with the much more interesting upcoming stuff (RFS).
You name this patch 'flow director', to get our attention, but it's an
old idea of you, to get different weights on cpus, that RPS is not yet
able to perform.

Maybe this is the reason you forgot to CC Tom Herbert (and me) ?

Consider now :

1) echo 65000 >/sys/class/net/eth0/queues/rx-0/rps_flow_0
   possible crash, dereferencing a smaller cpumap.

2) echo 3000000000 >/sys/class/net/eth0/queues/rx-0/rps_flow_0
   probable crash, because of overflow in RPS_MAP_SIZE(flows)

3) How can rps_flow_attribute & rps_flow_attribute_size be static (one
instance for whole kernel), if your intent is to have a per rxqueue
attributes ? (/sys/class/net/eth0/queues/rx-0/ ...). Or the first lines
of update_rps_flow_files() are completely wrong...

echo 10 > /sys/class/net/eth0/queues/rx-0/rps_flows
echo 2 > /sys/class/net/eth1/queues/rx-0/rps_flows
cat /sys/class/net/eth0/queues/rx-0/rps_flow_9=20

4) Lack of atomic changes of the RPS flows -> many packet reordering ca=
n
occur.

5) Many possible memory leaks in update_rps_flow_files(), you obviously
were very lazy. We try to build a bug-free kernel, not only a 'cool
kernel', and if you are lazy, your patches wont be accepted.



>  net/core/net-sysfs.c |  176 ++++++++++++++++++++++++++++++++++++++++=
+++++++++--
>  1 file changed, 172 insertions(+), 4 deletions(-)
> diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
> index 1e7fdd6..d904610 100644
> --- a/net/core/net-sysfs.c
> +++ b/net/core/net-sysfs.c
> @@ -511,6 +511,109 @@ static struct sysfs_ops rx_queue_sysfs_ops =3D =
{
>  	.store =3D rx_queue_attr_store,
>  };
> =20
> +static DEFINE_MUTEX(rps_map_lock);
> +
> +static ssize_t show_rps_flow(struct netdev_rx_queue *queue,
> +			     struct rx_queue_attribute *attribute, char *buf)
> +{
> +	unsigned long flowid;
> +	struct rps_map *map;
> +	u16 cpu;
> +
> +	strict_strtoul(attribute->attr.name + strlen("rps_flow_"), 10, &flo=
wid);
> +	rcu_read_lock();
> +	map =3D rcu_dereference(queue->rps_map);
> +	if (map && flowid < map->len)
> +		cpu =3D map->cpus[flowid];
> +	else
> +		cpu =3D 0;
> +	rcu_read_unlock();
> +	return sprintf(buf, "%hu\n", cpu);
> +}
> +
> +static ssize_t store_rps_flow(struct netdev_rx_queue *queue,
> +			      struct rx_queue_attribute *attribute,
> +			      const char *buf, size_t len)
> +{
> +	unsigned long flowid, cpu;
> +	struct rps_map *map;
> +
> +	if (!capable(CAP_NET_ADMIN))
> +		return -EPERM;
> +
> +	if (strict_strtoul(buf, 0, &cpu))
> +		return -EINVAL;
> +	strict_strtoul(attribute->attr.name + strlen("rps_flow_"), 10, &flo=
wid);
> +
> +	mutex_lock(&rps_map_lock);
> +	map =3D queue->rps_map;
> +	if (map && flowid < map->len)
> +		map->cpus[flowid] =3D cpu;

what can happen is cpu=3D65000, and NR_CPUS=3D32 ?

> +	mutex_unlock(&rps_map_lock);
> +
> +	return len;
> +}
> +
> +static struct rx_queue_attribute **rps_flow_attribute;
> +static int rps_flow_attribute_size;
> +
> +/* must be called with rps_map_lock locked */
> +static int update_rps_flow_files(struct kobject *kobj,
> +				 struct rps_map *old_map, struct rps_map *map)
> +{
> +	int i;
> +	int old_map_len =3D old_map ? old_map->len : 0;
> +	int map_len =3D map ? map->len : 0;
> +
> +	if (old_map_len >=3D map_len) {
> +		for (i =3D map_len; i < old_map_len; i++)
> +			sysfs_remove_file(kobj, &rps_flow_attribute[i]->attr);
	Removing attributes for this rxqueue, while anothe might need them ?

> +		return 0;
> +	}
> +
> +	if (map_len > rps_flow_attribute_size) {
> +		struct rx_queue_attribute **attrs;
> +		char name[sizeof("rps_flow_4294967295")];
> +		char *pname;
> +
> +		attrs =3D krealloc(rps_flow_attribute, map_len * sizeof(void *),
> +				 GFP_KERNEL);
> +		if (attrs =3D=3D NULL)
> +			return -ENOMEM;
> +		rps_flow_attribute =3D attrs;
> +		for (i =3D rps_flow_attribute_size; i < map_len; i++) {
> +			rps_flow_attribute[i] =3D kmalloc(sizeof(**attrs),
> +							GFP_KERNEL);
> +			if (rps_flow_attribute[i] =3D=3D NULL)
> +				break;
> +			sprintf(name, "rps_flow_%d", i);
> +			pname =3D kstrdup(name, GFP_KERNEL);
> +			if (pname =3D=3D NULL) {
> +				kfree(rps_flow_attribute[i]);
> +				break;
> +			}
> +			rps_flow_attribute[i]->attr.name =3D pname;
> +			rps_flow_attribute[i]->attr.mode =3D S_IRUGO | S_IWUSR;
> +			rps_flow_attribute[i]->show =3D show_rps_flow;
> +			rps_flow_attribute[i]->store =3D store_rps_flow;
> +		}
> +		rps_flow_attribute_size =3D i;
> +		if (i !=3D map_len)
> +			return -ENOMEM;
> +	}
> +
> +	for (i =3D old_map_len; i < map_len; i++) {
> +		if (sysfs_create_file(kobj, &rps_flow_attribute[i]->attr)) {
> +			while (--i >=3D old_map_len)
> +				sysfs_remove_file(kobj,
> +						  &rps_flow_attribute[i]->attr);

			No changes to rps_flow_atribute_size ?

> +			return -ENOMEM;
> +		}
> +	}
> +
> +	return 0;
> +}
> +
>  static ssize_t show_rps_map(struct netdev_rx_queue *queue,
>  			    struct rx_queue_attribute *attribute, char *buf)
>  {
> @@ -555,7 +658,6 @@ ssize_t store_rps_map(struct netdev_rx_queue *que=
ue,
>  	struct rps_map *old_map, *map;
>  	cpumask_var_t mask;
>  	int err, cpu, i;
> -	static DEFINE_SPINLOCK(rps_map_lock);
> =20
>  	if (!capable(CAP_NET_ADMIN))
>  		return -EPERM;
> @@ -588,10 +690,15 @@ ssize_t store_rps_map(struct netdev_rx_queue *q=
ueue,
>  		map =3D NULL;
>  	}
> =20
> -	spin_lock(&rps_map_lock);
> +	mutex_lock(&rps_map_lock);
>  	old_map =3D queue->rps_map;
> -	rcu_assign_pointer(queue->rps_map, map);
> -	spin_unlock(&rps_map_lock);
> +	err =3D update_rps_flow_files(&queue->kobj, old_map, map);
> +	if (!err)
> +		rcu_assign_pointer(queue->rps_map, map);
> +	mutex_unlock(&rps_map_lock);
> +
> +	if (err)
> +		return err;
> =20
>  	if (old_map)
>  		call_rcu(&old_map->rcu, rps_map_release);
> @@ -603,8 +710,69 @@ ssize_t store_rps_map(struct netdev_rx_queue *qu=
eue,
>  static struct rx_queue_attribute rps_cpus_attribute =3D
>  	__ATTR(rps_cpus, S_IRUGO | S_IWUSR, show_rps_map, store_rps_map);
> =20
> +static ssize_t show_rps_flows(struct netdev_rx_queue *queue,
> +		struct rx_queue_attribute *attribute, char *buf)
> +{
> +	struct rps_map *map;
> +	unsigned int len;
> +
> +	rcu_read_lock();
> +	map =3D rcu_dereference(queue->rps_map);
> +	len =3D map ? map->len : 0;
> +	rcu_read_unlock();
> +	return sprintf(buf, "%u\n", len);
> +}
> +
> +static ssize_t store_rps_flows(struct netdev_rx_queue *queue,
> +			       struct rx_queue_attribute *attribute,
> +			       const char *buf, size_t len)
> +{
> +	struct rps_map *old_map, *map;
> +	unsigned long flows;
> +	int err;
> +
> +	if (!capable(CAP_NET_ADMIN))
> +		return -EPERM;
> +
> +	if (strict_strtoul(buf, 0, &flows))
> +		return -EINVAL;

Are you aware RPS_MAP_SIZE(0x80000000) can overflow ?

> +	if (flows !=3D 0) {
> +		map =3D kzalloc(max_t(unsigned, RPS_MAP_SIZE(flows),
> +				    L1_CACHE_BYTES), GFP_KERNEL);
> +		if (map =3D=3D NULL)
> +			return -ENOMEM;
> +		map->len =3D flows;
> +	} else {
> +		map =3D NULL;
> +	}
> +
> +	mutex_lock(&rps_map_lock);
> +	old_map =3D queue->rps_map;
> +	err =3D update_rps_flow_files(&queue->kobj, old_map, map);
> +	if (!err) {
> +		if (old_map && map)
> +			memcpy(map->cpus, old_map->cpus,
> +			       sizeof(map->cpus[0]) *
> +			       min_t(unsigned int, flows, old_map->len));
> +		rcu_assign_pointer(queue->rps_map, map);
> +	}
> +	mutex_unlock(&rps_map_lock);
> +
> +	if (err)
> +		return err;
> +
> +	if (old_map)
> +		call_rcu(&old_map->rcu, rps_map_release);
> +
> +	return len;
> +}
> +
> +static struct rx_queue_attribute rps_flows_attribute =3D
> +	__ATTR(rps_flows, S_IRUGO | S_IWUSR, show_rps_flows, store_rps_flow=
s);
> +
>  static struct attribute *rx_queue_default_attrs[] =3D {
>  	&rps_cpus_attribute.attr,
> +	&rps_flows_attribute.attr,
>  	NULL
>  };
> =20
> --



