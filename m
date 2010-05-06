From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: Consistent skb timestamping
Date: Thu, 06 May 2010 18:14:48 +0200
Message-ID: <1273162488.2853.43.camel@edumazet-laptop>
References: <1273147309.2357.59.camel@edumazet-laptop>
	 <AANLkTikLgHvtpCtBTKmJZBwixmZDHjRjGb1c59oAemli@mail.gmail.com>
	 <1273160276.2853.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:60370 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752057Ab0EFQOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 12:14:53 -0400
Received: by bwz19 with SMTP id 19so79226bwz.21
        for <netdev@vger.kernel.org>; Thu, 06 May 2010 09:14:51 -0700 (PDT)
In-Reply-To: <1273160276.2853.27.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 06 mai 2010 =C3=A0 17:37 +0200, Eric Dumazet a =C3=A9crit :

> Right now, timestamping is not meant for userland pleasure, but for
> sniffers and network diagnostics. (I mean with current API, not with =
a
> new one we could add later)
>=20
> Once we settle a per socket timestamping, not global, we can reconsid=
er
> the thing (or not reconsider it, since socket timestamping will be do=
ne
> after RPS dispatch)
>=20
> Its true our global variable to enable/disable timestamp sucks, but i=
ts
> a separate issue ;)
>=20
> We probably could have a sysctl to let admin chose the moment timesta=
mp
> takes place (before or after RPS)

Here is v2 of patch,
introducing /proc/sys/net/core/netdev_tstamp_prequeue

Thanks

[PATCH v2 net-next-2.6] net: Consistent skb timestamping

With RPS inclusion, skb timestamping is not consistent in RX path.

If netif_receive_skb() is used, its deferred after RPS dispatch.

If netif_rx() is used, its done before RPS dispatch.

This can give strange tcpdump timestamps results.

I think timestamping should be done as soon as possible in the receive
path, to get meaningful values (ie timestamps taken at the time packet
was delivered by NIC driver to our stack), even if NAPI already can
defer timestamping a bit (RPS can help to reduce the gap)

Tom Herbert prefer to sample timestamps after RPS dispatch. In case
sampling is expensive (HPET/acpi_pm on x86), this makes sense.

Let admins switch from one mode to another, using a new
sysctl, /proc/sys/net/core/netdev_tstamp_prequeue

Its default value (1), means timestamps are taken as soon as possible,
before backlog queueing, giving accurate timestamps.

Setting a 0 value permits to sample timestamps when processing backlog,
after RPS dispatch, to lower the load of the pre-RPS cpu.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 Documentation/sysctl/net.txt |   10 ++++++
 include/linux/netdevice.h    |    1=20
 net/core/dev.c               |   50 ++++++++++++++++++++-------------
 net/core/sysctl_net_core.c   |    7 ++++
 4 files changed, 49 insertions(+), 19 deletions(-)

diff --git a/Documentation/sysctl/net.txt b/Documentation/sysctl/net.tx=
t
index df38ef0..cbd05ff 100644
--- a/Documentation/sysctl/net.txt
+++ b/Documentation/sysctl/net.txt
@@ -84,6 +84,16 @@ netdev_max_backlog
 Maximum number  of  packets,  queued  on  the  INPUT  side, when the i=
nterface
 receives packets faster than kernel can process them.
=20
+netdev_tstamp_prequeue
+----------------------
+
+If set to 0, RX packet timestamps can be sampled after RPS processing,=
 when
+the target CPU processes packets. It might give some delay on timestam=
ps, but
+permit to distribute the load on several cpus.
+
+If set to 1 (default), timestamps are sampled as soon as possible, bef=
ore
+queueing.
+
 optmem_max
 ----------
=20
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 69022d4..c1b2341 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2100,6 +2100,7 @@ extern const struct net_device_stats *dev_get_sta=
ts(struct net_device *dev);
 extern void		dev_txq_stats_fold(const struct net_device *dev, struct n=
et_device_stats *stats);
=20
 extern int		netdev_max_backlog;
+extern int		netdev_tstamp_prequeue;
 extern int		weight_p;
 extern int		netdev_set_master(struct net_device *dev, struct net_devic=
e *master);
 extern int skb_checksum_help(struct sk_buff *skb);
diff --git a/net/core/dev.c b/net/core/dev.c
index 36d53be..1ca4de8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1454,7 +1454,7 @@ void net_disable_timestamp(void)
 }
 EXPORT_SYMBOL(net_disable_timestamp);
=20
-static inline void net_timestamp(struct sk_buff *skb)
+static inline void net_timestamp_set(struct sk_buff *skb)
 {
 	if (atomic_read(&netstamp_needed))
 		__net_timestamp(skb);
@@ -1462,6 +1462,12 @@ static inline void net_timestamp(struct sk_buff =
*skb)
 		skb->tstamp.tv64 =3D 0;
 }
=20
+static inline void net_timestamp_check(struct sk_buff *skb)
+{
+	if (!skb->tstamp.tv64 && atomic_read(&netstamp_needed))
+		__net_timestamp(skb);
+}
+
 /**
  * dev_forward_skb - loopback an skb to another netif
  *
@@ -1509,9 +1515,9 @@ static void dev_queue_xmit_nit(struct sk_buff *sk=
b, struct net_device *dev)
=20
 #ifdef CONFIG_NET_CLS_ACT
 	if (!(skb->tstamp.tv64 && (G_TC_FROM(skb->tc_verd) & AT_INGRESS)))
-		net_timestamp(skb);
+		net_timestamp_set(skb);
 #else
-	net_timestamp(skb);
+	net_timestamp_set(skb);
 #endif
=20
 	rcu_read_lock();
@@ -2202,6 +2208,7 @@ EXPORT_SYMBOL(dev_queue_xmit);
   =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
*/
=20
 int netdev_max_backlog __read_mostly =3D 1000;
+int netdev_tstamp_prequeue __read_mostly =3D 1;
 int netdev_budget __read_mostly =3D 300;
 int weight_p __read_mostly =3D 64;            /* old backlog weight */
=20
@@ -2458,8 +2465,8 @@ int netif_rx(struct sk_buff *skb)
 	if (netpoll_rx(skb))
 		return NET_RX_DROP;
=20
-	if (!skb->tstamp.tv64)
-		net_timestamp(skb);
+	if (netdev_tstamp_prequeue)
+		net_timestamp_check(skb);
=20
 #ifdef CONFIG_RPS
 	{
@@ -2780,8 +2787,8 @@ static int __netif_receive_skb(struct sk_buff *sk=
b)
 	int ret =3D NET_RX_DROP;
 	__be16 type;
=20
-	if (!skb->tstamp.tv64)
-		net_timestamp(skb);
+	if (!netdev_tstamp_prequeue)
+		net_timestamp_check(skb);
=20
 	if (vlan_tx_tag_present(skb) && vlan_hwaccel_do_receive(skb))
 		return NET_RX_SUCCESS;
@@ -2899,23 +2906,28 @@ out:
  */
 int netif_receive_skb(struct sk_buff *skb)
 {
+	if (netdev_tstamp_prequeue)
+		net_timestamp_check(skb);
+
 #ifdef CONFIG_RPS
-	struct rps_dev_flow voidflow, *rflow =3D &voidflow;
-	int cpu, ret;
+	{
+		struct rps_dev_flow voidflow, *rflow =3D &voidflow;
+		int cpu, ret;
=20
-	rcu_read_lock();
+		rcu_read_lock();
+
+		cpu =3D get_rps_cpu(skb->dev, skb, &rflow);
=20
-	cpu =3D get_rps_cpu(skb->dev, skb, &rflow);
+		if (cpu >=3D 0) {
+			ret =3D enqueue_to_backlog(skb, cpu, &rflow->last_qtail);
+			rcu_read_unlock();
+		} else {
+			rcu_read_unlock();
+			ret =3D __netif_receive_skb(skb);
+		}
=20
-	if (cpu >=3D 0) {
-		ret =3D enqueue_to_backlog(skb, cpu, &rflow->last_qtail);
-		rcu_read_unlock();
-	} else {
-		rcu_read_unlock();
-		ret =3D __netif_receive_skb(skb);
+		return ret;
 	}
-
-	return ret;
 #else
 	return __netif_receive_skb(skb);
 #endif
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index dcc7d25..01eee5d 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -122,6 +122,13 @@ static struct ctl_table net_core_table[] =3D {
 		.proc_handler	=3D proc_dointvec
 	},
 	{
+		.procname	=3D "netdev_tstamp_prequeue",
+		.data		=3D &netdev_tstamp_prequeue,
+		.maxlen		=3D sizeof(int),
+		.mode		=3D 0644,
+		.proc_handler	=3D proc_dointvec
+	},
+	{
 		.procname	=3D "message_cost",
 		.data		=3D &net_ratelimit_state.interval,
 		.maxlen		=3D sizeof(int),


