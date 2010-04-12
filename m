From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] rps: add flow director support
Date: Mon, 12 Apr 2010 06:34:20 -0700
Message-ID: <z2o65634d661004120634h8336409er33af1fb75c2a9d1b@mail.gmail.com>
References: <1271022140-3917-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:21391 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740Ab0DLNeW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Apr 2010 09:34:22 -0400
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id o3CDYLfA018758
	for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 06:34:22 -0700
Received: from pvg16 (pvg16.prod.google.com [10.241.210.144])
	by kpbe16.cbf.corp.google.com with ESMTP id o3CDYKjv027116
	for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 06:34:20 -0700
Received: by pvg16 with SMTP id 16so2799651pvg.40
        for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 06:34:20 -0700 (PDT)
In-Reply-To: <1271022140-3917-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 11, 2010 at 2:42 PM, Changli Gao <xiaosuo@gmail.com> wrote:
> add rps flow director support
>
> with rps flow director, users can do weighted packet dispatching amon=
g CPUs.
> For example, CPU0:CPU1 is 1:3 for eth0's rx-0:
>
"Flow director" is a misnomer here in that it has no per flow
awareness, that is what RFS provides.  Please use a different name.

> =A0localhost linux # echo 4 > /sys/class/net/eth0/queues/rx-0/rps_flo=
ws
> =A0localhost linux # echo 0 > /sys/class/net/eth0/queues/rx-0/rps_flo=
w_0
> =A0localhost linux # echo 1 > /sys/class/net/eth0/queues/rx-0/rps_flo=
w_1
> =A0localhost linux # echo 1 > /sys/class/net/eth0/queues/rx-0/rps_flo=
w_2
> =A0localhost linux # echo 1 > /sys/class/net/eth0/queues/rx-0/rps_flo=
w_3
>
It might be better to put this in its own directory and also do it per
CPU instead of hash entry.  This should result in a lot fewer entries
and I'm not sure how you would deal with holes in the hash table for
unspecified entries.  Also, it would be nice not to have to specify a
number of entries.  Maybe something like:

localhost linux # echo 1 > /sys/class/net/eth0/queues/rx-0/rps_cpu_map/=
0
localhost linux # echo 3 > /sys/class/net/eth0/queues/rx-0/rps_cpu_map/=
1

To specify CPU 0 with weight 1, CPU 1 with weight 3.

> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----
> =A0net/core/net-sysfs.c | =A0176 ++++++++++++++++++++++++++++++++++++=
+++++++++++++--
> =A01 file changed, 172 insertions(+), 4 deletions(-)
> diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
> index 1e7fdd6..d904610 100644
> --- a/net/core/net-sysfs.c
> +++ b/net/core/net-sysfs.c
> @@ -511,6 +511,109 @@ static struct sysfs_ops rx_queue_sysfs_ops =3D =
{
> =A0 =A0 =A0 =A0.store =3D rx_queue_attr_store,
> =A0};
>
> +static DEFINE_MUTEX(rps_map_lock);
> +
> +static ssize_t show_rps_flow(struct netdev_rx_queue *queue,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct rx_qu=
eue_attribute *attribute, char *buf)
> +{
> + =A0 =A0 =A0 unsigned long flowid;
> + =A0 =A0 =A0 struct rps_map *map;
> + =A0 =A0 =A0 u16 cpu;
> +
> + =A0 =A0 =A0 strict_strtoul(attribute->attr.name + strlen("rps_flow_=
"), 10, &flowid);
> + =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 map =3D rcu_dereference(queue->rps_map);
> + =A0 =A0 =A0 if (map && flowid < map->len)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpu =3D map->cpus[flowid];
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpu =3D 0;
> + =A0 =A0 =A0 rcu_read_unlock();
> + =A0 =A0 =A0 return sprintf(buf, "%hu\n", cpu);
> +}
> +
> +static ssize_t store_rps_flow(struct netdev_rx_queue *queue,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct rx_q=
ueue_attribute *attribute,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const char =
*buf, size_t len)
> +{
> + =A0 =A0 =A0 unsigned long flowid, cpu;
> + =A0 =A0 =A0 struct rps_map *map;
> +
> + =A0 =A0 =A0 if (!capable(CAP_NET_ADMIN))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EPERM;
> +
> + =A0 =A0 =A0 if (strict_strtoul(buf, 0, &cpu))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 strict_strtoul(attribute->attr.name + strlen("rps_flow_=
"), 10, &flowid);
> +
> + =A0 =A0 =A0 mutex_lock(&rps_map_lock);
> + =A0 =A0 =A0 map =3D queue->rps_map;
> + =A0 =A0 =A0 if (map && flowid < map->len)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 map->cpus[flowid] =3D cpu;
> + =A0 =A0 =A0 mutex_unlock(&rps_map_lock);
> +
> + =A0 =A0 =A0 return len;
> +}
> +
> +static struct rx_queue_attribute **rps_flow_attribute;
> +static int rps_flow_attribute_size;
> +
> +/* must be called with rps_map_lock locked */
> +static int update_rps_flow_files(struct kobject *kobj,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stru=
ct rps_map *old_map, struct rps_map *map)
> +{
> + =A0 =A0 =A0 int i;
> + =A0 =A0 =A0 int old_map_len =3D old_map ? old_map->len : 0;
> + =A0 =A0 =A0 int map_len =3D map ? map->len : 0;
> +
> + =A0 =A0 =A0 if (old_map_len >=3D map_len) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D map_len; i < old_map_len; i+=
+)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sysfs_remove_file(kobj,=
 &rps_flow_attribute[i]->attr);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (map_len > rps_flow_attribute_size) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct rx_queue_attribute **attrs;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 char name[sizeof("rps_flow_4294967295")=
];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 char *pname;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 attrs =3D krealloc(rps_flow_attribute, =
map_len * sizeof(void *),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0GFP_=
KERNEL);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (attrs =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rps_flow_attribute =3D attrs;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D rps_flow_attribute_size; i <=
 map_len; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rps_flow_attribute[i] =3D=
 kmalloc(sizeof(**attrs),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 GFP_KERNEL);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (rps_flow_attribute[=
i] =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sprintf(name, "rps_flow=
_%d", i);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pname =3D kstrdup(name,=
 GFP_KERNEL);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pname =3D=3D NULL) =
{
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(r=
ps_flow_attribute[i]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rps_flow_attribute[i]->=
attr.name =3D pname;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rps_flow_attribute[i]->=
attr.mode =3D S_IRUGO | S_IWUSR;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rps_flow_attribute[i]->=
show =3D show_rps_flow;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rps_flow_attribute[i]->=
store =3D store_rps_flow;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rps_flow_attribute_size =3D i;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (i !=3D map_len)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 for (i =3D old_map_len; i < map_len; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sysfs_create_file(kobj, &rps_flow_a=
ttribute[i]->attr)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 while (--i >=3D old_map=
_len)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sysfs_r=
emove_file(kobj,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 &rps_flow_attribute[i]->attr);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return 0;
> +}
> +
> =A0static ssize_t show_rps_map(struct netdev_rx_queue *queue,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct rx_queu=
e_attribute *attribute, char *buf)
> =A0{
> @@ -555,7 +658,6 @@ ssize_t store_rps_map(struct netdev_rx_queue *que=
ue,
> =A0 =A0 =A0 =A0struct rps_map *old_map, *map;
> =A0 =A0 =A0 =A0cpumask_var_t mask;
> =A0 =A0 =A0 =A0int err, cpu, i;
> - =A0 =A0 =A0 static DEFINE_SPINLOCK(rps_map_lock);
>
> =A0 =A0 =A0 =A0if (!capable(CAP_NET_ADMIN))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EPERM;
> @@ -588,10 +690,15 @@ ssize_t store_rps_map(struct netdev_rx_queue *q=
ueue,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0map =3D NULL;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 spin_lock(&rps_map_lock);
> + =A0 =A0 =A0 mutex_lock(&rps_map_lock);
> =A0 =A0 =A0 =A0old_map =3D queue->rps_map;
> - =A0 =A0 =A0 rcu_assign_pointer(queue->rps_map, map);
> - =A0 =A0 =A0 spin_unlock(&rps_map_lock);
> + =A0 =A0 =A0 err =3D update_rps_flow_files(&queue->kobj, old_map, ma=
p);
> + =A0 =A0 =A0 if (!err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_assign_pointer(queue->rps_map, map)=
;
> + =A0 =A0 =A0 mutex_unlock(&rps_map_lock);
> +
> + =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
>
> =A0 =A0 =A0 =A0if (old_map)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0call_rcu(&old_map->rcu, rps_map_releas=
e);
> @@ -603,8 +710,69 @@ ssize_t store_rps_map(struct netdev_rx_queue *qu=
eue,
> =A0static struct rx_queue_attribute rps_cpus_attribute =3D
> =A0 =A0 =A0 =A0__ATTR(rps_cpus, S_IRUGO | S_IWUSR, show_rps_map, stor=
e_rps_map);
>
> +static ssize_t show_rps_flows(struct netdev_rx_queue *queue,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct rx_queue_attribute *attribute, c=
har *buf)
> +{
> + =A0 =A0 =A0 struct rps_map *map;
> + =A0 =A0 =A0 unsigned int len;
> +
> + =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 map =3D rcu_dereference(queue->rps_map);
> + =A0 =A0 =A0 len =3D map ? map->len : 0;
> + =A0 =A0 =A0 rcu_read_unlock();
> + =A0 =A0 =A0 return sprintf(buf, "%u\n", len);
> +}
> +
> +static ssize_t store_rps_flows(struct netdev_rx_queue *queue,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct r=
x_queue_attribute *attribute,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const ch=
ar *buf, size_t len)
> +{
> + =A0 =A0 =A0 struct rps_map *old_map, *map;
> + =A0 =A0 =A0 unsigned long flows;
> + =A0 =A0 =A0 int err;
> +
> + =A0 =A0 =A0 if (!capable(CAP_NET_ADMIN))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EPERM;
> +
> + =A0 =A0 =A0 if (strict_strtoul(buf, 0, &flows))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 if (flows !=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 map =3D kzalloc(max_t(unsigned, RPS_MAP=
_SIZE(flows),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 L1_CACHE_BYTES), GFP_KERNEL);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (map =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 map->len =3D flows;
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 map =3D NULL;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 mutex_lock(&rps_map_lock);
> + =A0 =A0 =A0 old_map =3D queue->rps_map;
> + =A0 =A0 =A0 err =3D update_rps_flow_files(&queue->kobj, old_map, ma=
p);
> + =A0 =A0 =A0 if (!err) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (old_map && map)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcpy(map->cpus, old_m=
ap->cpus,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sizeof(m=
ap->cpus[0]) *
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0min_t(un=
signed int, flows, old_map->len));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_assign_pointer(queue->rps_map, map)=
;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 mutex_unlock(&rps_map_lock);
> +
> + =A0 =A0 =A0 if (err)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
> +
> + =A0 =A0 =A0 if (old_map)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 call_rcu(&old_map->rcu, rps_map_release=
);
> +
> + =A0 =A0 =A0 return len;
> +}
> +
> +static struct rx_queue_attribute rps_flows_attribute =3D
> + =A0 =A0 =A0 __ATTR(rps_flows, S_IRUGO | S_IWUSR, show_rps_flows, st=
ore_rps_flows);
> +
> =A0static struct attribute *rx_queue_default_attrs[] =3D {
> =A0 =A0 =A0 =A0&rps_cpus_attribute.attr,
> + =A0 =A0 =A0 &rps_flows_attribute.attr,
> =A0 =A0 =A0 =A0NULL
> =A0};
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
