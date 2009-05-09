From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] dropmon: add ability to detect when hardware drops rx
 packets
Date: Sat, 09 May 2009 08:30:35 +0200
Message-ID: <4A05230B.6070806@cosmosbay.com>
References: <20090508195026.GB13017@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47757 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931AbZEIGau convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2009 02:30:50 -0400
In-Reply-To: <20090508195026.GB13017@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman a =E9crit :
> Hey all-
> 	A few weeks back I sent out an RFC in which I proposed that I could
> extend dropwatch to detect drops in hardware by adding a napi poll tr=
acepoint,
> using that as an indicator that I should periodically check the stats=
 to see if
> the rx drop counter had changed.  Having not had any negative feedbac=
k to that
> proposal, heres the patch.  I've tested it and it seems to work fairl=
y well.
> Neil
>=20
>=20
> Patch to add the ability to detect drops in hardware interfaces via d=
ropwatch.
> Adds a tracepoint to net_rx_action to signal everytime a napi instanc=
e is
> polled.  The dropmon code then periodically checks to see if the rx_f=
rames
> counter has changed, and if so, adds a drop notification to the netli=
nk
> protocol, using the reserved all-0's vector to indicate the drop loca=
tion was in
> hardware, rather than somewhere in the code.
>=20
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>=20

Hi Neil

I dont fully understand your patch, but at least have some questions
about rcu stuff.

>=20
>  include/linux/net_dropmon.h |    7 ++
>  include/trace/napi.h        |   11 ++++
>  net/core/dev.c              |    5 +-
>  net/core/drop_monitor.c     |  107 +++++++++++++++++++++++++++++++++=
+++++++++--
>  net/core/net-traces.c       |    4 +
>  net/core/netpoll.c          |    2=20
>  6 files changed, 131 insertions(+), 5 deletions(-)
>=20
> diff --git a/include/linux/net_dropmon.h b/include/linux/net_dropmon.=
h
> index 0217fb8..9addc62 100644
> --- a/include/linux/net_dropmon.h
> +++ b/include/linux/net_dropmon.h
> @@ -8,6 +8,13 @@ struct net_dm_drop_point {
>  	__u32 count;
>  };
> =20
> +#define is_drop_point_hw(x) do {\
> +	int ____i, ____j;\
> +	for (____i =3D 0; ____i < 8; i ____i++)\
> +		____j |=3D x[____i];\
> +	____j;\
> +} while (0)
> +
>  #define NET_DM_CFG_VERSION  0
>  #define NET_DM_CFG_ALERT_COUNT  1
>  #define NET_DM_CFG_ALERT_DELAY 2
> diff --git a/include/trace/napi.h b/include/trace/napi.h
> new file mode 100644
> index 0000000..7c39eb7
> --- /dev/null
> +++ b/include/trace/napi.h
> @@ -0,0 +1,11 @@
> +#ifndef _TRACE_NAPI_H_
> +#define _TRACE_NAPI_H_
> +
> +#include <linux/skbuff.h>
> +#include <linux/tracepoint.h>
> +
> +DECLARE_TRACE(napi_poll,
> +	TP_PROTO(struct napi_struct *napi),
> +	TP_ARGS(napi));
> +
> +#endif
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 637ea71..165979c 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -126,6 +126,7 @@
>  #include <linux/in.h>
>  #include <linux/jhash.h>
>  #include <linux/random.h>
> +#include <trace/napi.h>
> =20
>  #include "net-sysfs.h"
> =20
> @@ -2763,8 +2764,10 @@ static void net_rx_action(struct softirq_actio=
n *h)
>  		 * accidently calling ->poll() when NAPI is not scheduled.
>  		 */
>  		work =3D 0;
> -		if (test_bit(NAPI_STATE_SCHED, &n->state))
> +		if (test_bit(NAPI_STATE_SCHED, &n->state)) {
>  			work =3D n->poll(n, weight);
> +			trace_napi_poll(n);
> +		}
> =20
>  		WARN_ON_ONCE(work > weight);
> =20
> diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
> index 2797b71..538c1d4 100644
> --- a/net/core/drop_monitor.c
> +++ b/net/core/drop_monitor.c
> @@ -22,8 +22,10 @@
>  #include <linux/timer.h>
>  #include <linux/bitops.h>
>  #include <net/genetlink.h>
> +#include <net/netevent.h>
> =20
>  #include <trace/skb.h>
> +#include <trace/napi.h>
> =20
>  #include <asm/unaligned.h>
> =20
> @@ -38,7 +40,7 @@ static void send_dm_alert(struct work_struct *unuse=
d);
>   * and the work handle that will send up
>   * netlink alerts
>   */
> -struct sock *dm_sock;
> +static int trace_state =3D TRACE_OFF;
> =20
>  struct per_cpu_dm_data {
>  	struct work_struct dm_alert_work;
> @@ -47,6 +49,12 @@ struct per_cpu_dm_data {
>  	struct timer_list send_timer;
>  };
> =20
> +struct dm_hw_stat_delta {
> +	struct net_device *dev;
> +	struct list_head list;
> +	unsigned long last_drop_val;
> +};
> +
>  static struct genl_family net_drop_monitor_family =3D {
>  	.id             =3D GENL_ID_GENERATE,
>  	.hdrsize        =3D 0,
> @@ -59,7 +67,8 @@ static DEFINE_PER_CPU(struct per_cpu_dm_data, dm_cp=
u_data);
> =20
>  static int dm_hit_limit =3D 64;
>  static int dm_delay =3D 1;
> -
> +static unsigned long dm_hw_check_delta =3D 2*HZ;
> +static LIST_HEAD(hw_stats_list);
> =20
>  static void reset_per_cpu_data(struct per_cpu_dm_data *data)
>  {
> @@ -115,7 +124,7 @@ static void sched_send_work(unsigned long unused)
>  	schedule_work(&data->dm_alert_work);
>  }
> =20
> -static void trace_kfree_skb_hit(struct sk_buff *skb, void *location)
> +static void trace_drop_common(struct sk_buff *skb, void *location)
>  {
>  	struct net_dm_alert_msg *msg;
>  	struct nlmsghdr *nlh;
> @@ -159,18 +168,59 @@ out:
>  	return;
>  }
> =20
> +static void trace_kfree_skb_hit(struct sk_buff *skb, void *location)
> +{
> +	trace_drop_common(skb, location);
> +}
> +
> +static void trace_napi_poll_hit(struct napi_struct *napi)
> +{
> +	struct dm_hw_stat_delta *new_stat;
> +
> +	/*
> +	 * Ratelimit our check time to dm_hw_check_delta jiffies
> +	 */
> +	if (!time_after(jiffies, napi->dev->last_rx + dm_hw_check_delta))
> +		return;
> +
> +	list_for_each_entry_rcu(new_stat, &hw_stats_list, list) {
> +		if ((new_stat->dev =3D=3D napi->dev)  &&
> +		    (napi->dev->stats.rx_dropped !=3D new_stat->last_drop_val)) {
> +			trace_drop_common(NULL, NULL);
> +			new_stat->last_drop_val =3D napi->dev->stats.rx_dropped;
> +			break;
> +		}
> +	}
> +}
> +
> +
>  static int set_all_monitor_traces(int state)
>  {
>  	int rc =3D 0;
> +	struct dm_hw_stat_delta *new_stat =3D NULL;
> =20
>  	switch (state) {
>  	case TRACE_ON:
>  		rc |=3D register_trace_kfree_skb(trace_kfree_skb_hit);
> +		rc |=3D register_trace_napi_poll(trace_napi_poll_hit);
>  		break;
>  	case TRACE_OFF:
>  		rc |=3D unregister_trace_kfree_skb(trace_kfree_skb_hit);
> +		rc |=3D unregister_trace_napi_poll(trace_napi_poll_hit);
> =20
>  		tracepoint_synchronize_unregister();
> +
> +		/*
> +		 * Clean the device list
> +		 */
> +		rcu_read_lock();
> +		list_for_each_entry_rcu(new_stat, &hw_stats_list, list) {
> +			if (new_stat->dev =3D=3D NULL) {
> +				list_del_rcu(&new_stat->list);
> +				kfree(new_stat);

I can't see  how list_del_rcu(&new_stat->list) can be followed by kfree=
(new_stat)
safely. You need a grace period between two operations. That can be don=
e
with call_rcu() helper.

Also, rcu_read_lock()/rcu_read_unlock() is not the proper locking pragm=
as
needed here. multiple writers are/should be forbidden here. If caller a=
lready
does a locking, then no additional locking is needed here.


> +			}
> +		}
> +		rcu_read_unlock();
>  		break;
>  	default:
>  		rc =3D 1;
> @@ -179,6 +229,7 @@ static int set_all_monitor_traces(int state)
> =20
>  	if (rc)
>  		return -EINPROGRESS;
> +	trace_state =3D state;
>  	return rc;
>  }
> =20
> @@ -204,6 +255,43 @@ static int net_dm_cmd_trace(struct sk_buff *skb,
>  	return -ENOTSUPP;
>  }
> =20
> +int dropmon_net_event(struct notifier_block *ev_block,
> +			unsigned long event, void *ptr)
> +{
> +	struct net_device *dev =3D ptr;
> +	struct dm_hw_stat_delta *new_stat =3D NULL;
> +
> +
> +	switch (event) {
> +	case NETDEV_REGISTER:
> +		new_stat =3D kzalloc(sizeof(struct dm_hw_stat_delta), GFP_KERNEL);
> +
> +		if (!new_stat)
> +			goto out;
> +
> +		new_stat->dev =3D dev;
> +		rcu_read_lock();

same point here, rcu_read_lock is not the proper way to protect the lis=
t.

> +		list_add_rcu(&new_stat->list, &hw_stats_list);
> +		rcu_read_unlock();
> +		break;
> +	case NETDEV_UNREGISTER:
> +		list_for_each_entry_rcu(new_stat, &hw_stats_list, list) {
> +			if (new_stat->dev =3D=3D dev)
> +				new_stat->dev =3D NULL;
> +				break;
> +		}
> +
> +		if (trace_state =3D=3D TRACE_OFF) {
> +			rcu_read_lock();
> +			list_del_rcu(&new_stat->list);
> +			rcu_read_unlock();
> +			kfree(new_stat);

same probleme here. If rcu is used, then you need a grace period.

> +		}
> +		break;
> +	}
> +out:
> +	return NOTIFY_DONE;
> +}
> =20
>  static struct genl_ops dropmon_ops[] =3D {
>  	{
> @@ -220,6 +308,10 @@ static struct genl_ops dropmon_ops[] =3D {
>  	},
>  };
> =20
> +static struct notifier_block dropmon_net_notifier =3D {
> +	.notifier_call =3D dropmon_net_event
> +};
> +
>  static int __init init_net_drop_monitor(void)
>  {
>  	int cpu;
> @@ -243,12 +335,18 @@ static int __init init_net_drop_monitor(void)
>  		ret =3D genl_register_ops(&net_drop_monitor_family,
>  					&dropmon_ops[i]);
>  		if (ret) {
> -			printk(KERN_CRIT "failed to register operation %d\n",
> +			printk(KERN_CRIT "Failed to register operation %d\n",
>  				dropmon_ops[i].cmd);
>  			goto out_unreg;
>  		}
>  	}
> =20
> +	rc =3D register_netdevice_notifier(&dropmon_net_notifier);
> +	if (rc < 0) {
> +		printk(KERN_CRIT "Failed to register netdevice notifier\n");
> +		goto out_unreg;
> +	}
> +
>  	rc =3D 0;
> =20
>  	for_each_present_cpu(cpu) {
> @@ -259,6 +357,7 @@ static int __init init_net_drop_monitor(void)
>  		data->send_timer.data =3D cpu;
>  		data->send_timer.function =3D sched_send_work;
>  	}
> +
>  	goto out;
> =20
>  out_unreg:
> diff --git a/net/core/net-traces.c b/net/core/net-traces.c
> index c8fb456..b07b25b 100644
> --- a/net/core/net-traces.c
> +++ b/net/core/net-traces.c
> @@ -20,6 +20,7 @@
>  #include <linux/netlink.h>
>  #include <linux/net_dropmon.h>
>  #include <trace/skb.h>
> +#include <trace/napi.h>
> =20
>  #include <asm/unaligned.h>
>  #include <asm/bitops.h>
> @@ -27,3 +28,6 @@
> =20
>  DEFINE_TRACE(kfree_skb);
>  EXPORT_TRACEPOINT_SYMBOL_GPL(kfree_skb);
> +
> +DEFINE_TRACE(napi_poll);
> +EXPORT_TRACEPOINT_SYMBOL_GPL(napi_poll);
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index b5873bd..446d3ba 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -24,6 +24,7 @@
>  #include <net/tcp.h>
>  #include <net/udp.h>
>  #include <asm/unaligned.h>
> +#include <trace/napi.h>
> =20
>  /*
>   * We maintain a small pool of fully-sized skbs, to make sure the
> @@ -137,6 +138,7 @@ static int poll_one_napi(struct netpoll_info *npi=
nfo,
>  	set_bit(NAPI_STATE_NPSVC, &napi->state);
> =20
>  	work =3D napi->poll(napi, budget);
> +	trace_napi_poll(napi->dev);
> =20
>  	clear_bit(NAPI_STATE_NPSVC, &napi->state);
>  	atomic_dec(&trapped);
>=20


