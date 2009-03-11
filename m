From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: [RFC v2: Patch 1/3] net: hand off skb list to other cpu to submit
	to upper layer
Date: Wed, 11 Mar 2009 16:53:44 +0800
Message-ID: <1236761624.2567.442.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, jesse.brandeburg@intel.com,
	shemminger@vyatta.com, David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:60823 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752174AbZCKIyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 04:54:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I got some comments. Special thanks to =EF=BB=BFStephen Hemminger for t=
eaching me on
what reorder is and some other comments. Also thank other guys who rais=
ed comments.

v2 has some improvements.
1) Add new sysfs interface /sys/class/net/ethXXX/rx_queueXXX/processing=
_cpu. Admin
could use it to configure the binding between RX and cpu number. So it'=
s convenient
for drivers to use the new capability.
2) Delete function netif_rx_queue;
3) Optimize ipi notification. There is no new notification when destina=
tion's
input_pkt_alien_queue isn't empty.
4) Did lots of testing, mostly focusing on slab allocator (slab/slub/sl=
qb) and use
SLUB with big slub_max_order currently.

---

=EF=BB=BF=EF=BB=BFSubject: net: hand off skb list to other cpu to submi=
t to upper layer
=46rom: =EF=BB=BFZhang Yanmin <yanmin.zhang@linux.intel.com>

=EF=BB=BFRecently, I am investigating an ip_forward performance issue w=
ith 10G IXGBE NIC.
I start the testing on 2 machines. Every machine has 2 10G NICs. The 1s=
t one seconds
packets by pktgen. The 2nd receives the packets from one NIC and forwar=
ds them out
from the 2nd NIC.=20

Initial testing showed cpu cache sharing has impact on speed. As NICs s=
upports
multi-queue, I bind the queues to different logical cpu of different ph=
ysical cpu
while considering cache sharing carefully. I could get about 30~40% imp=
rovement;

Comparing with sending speed on the 1st machine, the forward speed is s=
till not good,
only about 60% of sending speed. As a matter of fact, IXGBE driver star=
ts NAPI when
interrupt arrives. When ip_forward=3D1, receiver collects a packet and =
forwards it out
immediately. So although IXGBE collects packets with NAPI, the forwardi=
ng really has
much impact on collection. As IXGBE runs very fast, it drops packets qu=
ickly. The better
way for receiving cpu is doing nothing than just collecting packets.

Currently kernel has backlog to support a similar capability, but proce=
ss_backlog still
runs on the receiving cpu. I enhance backlog by adding a new input_pkt_=
alien_queue to
softnet_data. Receving cpu collects packets and link them into skb list=
, then delivers
the list to the =EF=BB=BFinput_pkt_alien_queue of other cpu. process_ba=
cklog picks up the skb list
from =EF=BB=BFinput_pkt_alien_queue when =EF=BB=BFinput_pkt_queue is em=
pty.

=EF=BB=BF
I tested my patch on top of 2.6.28.5. The improvement is about 43%.

Some questions:

1) Reorder: My method wouldn't introduce reorder issue, because we use =
N:1 mapping between
RX queue and cpu number.
2) If there is no free cpu to work on packet collection: It depends on =
cpu resource
allocation. We could allocate more RX queue to the same cpu. With my ne=
w testing, the
forwarding speed could be at about 4.8M pps (packets per second and pac=
ket size is 60Byte)
on Nehalem machine, and 8 packet processing cpus almost have no idle ti=
me while receiving cpu
idle is about 50%. I just have 4 old NIC and couldn't test more on this=
 question.
3) packet delaying: I didn't calculate it or measure it and might measu=
re it later. The
forwarding speed is close to 270M bytes/s. At least sar shows mostly re=
ceiving matches
forwarding. But at sending side, the sending speed is bigger than forwa=
rding speed, although
my method decreases the difference largely.
4) 10G NICs other than IXGBE: I have no other 10G NICs now.
5) Other kinds of machines working as forwarder: I test it between 1 2*=
4 stoakley and
2*4*2 Nehalem. I reversed the testing and found the improvement on stoa=
kley is less than 30%,
not so big as on Nehalem.
=EF=BB=BF6) Memory utilization: =EF=BB=BFMy nehalem machine has 12GB me=
mory. To reach the maximum speed,
I tried netdev_max_backlog=3D400000. That consumes 10GB memory sometime=
s.
7) Any impact if driver enables the new capability but admin doesn't co=
nfigure it: I didn't
measure the speed difference now.
8) If receiving cpu collects packets very fast and processing cpu is sl=
ow: We can start many
RX queues on the receiving cpu and bind them to different processing cp=
u.


Current patch is against 2.6.29-rc7.

Signed-off-by: =EF=BB=BFZhang Yanmin <yanmin.zhang@linux.intel.com>

---

--- linux-2.6.29-rc7/include/linux/netdevice.h	2009-03-09 15:20:49.0000=
00000 +0800
+++ linux-2.6.29-rc7_backlog/include/linux/netdevice.h	2009-03-11 10:17=
:08.000000000 +0800
@@ -1119,6 +1119,9 @@ static inline int unregister_gifconf(uns
 /*
  * Incoming packets are placed on per-cpu queues so that
  * no locking is needed.
+ * To speed up fast network, sometimes place incoming packets
+ * to other cpu queues. Use input_pkt_alien_queue.lock to
+ * protect input_pkt_alien_queue.
  */
 struct softnet_data
 {
@@ -1127,6 +1130,7 @@ struct softnet_data
 	struct list_head	poll_list;
 	struct sk_buff		*completion_queue;
=20
+	struct sk_buff_head	input_pkt_alien_queue;
 	struct napi_struct	backlog;
 };
=20
@@ -1368,6 +1372,8 @@ extern void dev_kfree_skb_irq(struct sk_
 extern void dev_kfree_skb_any(struct sk_buff *skb);
=20
 #define HAVE_NETIF_RX 1
+extern int		raise_netif_irq(int cpu,
+					struct sk_buff_head *skb_queue);
 extern int		netif_rx(struct sk_buff *skb);
 extern int		netif_rx_ni(struct sk_buff *skb);
 #define HAVE_NETIF_RECEIVE_SKB 1
--- linux-2.6.29-rc7/net/core/dev.c	2009-03-09 15:20:50.000000000 +0800
+++ linux-2.6.29-rc7_backlog/net/core/dev.c	2009-03-11 10:27:57.0000000=
00 +0800
@@ -1997,6 +1997,114 @@ int netif_rx_ni(struct sk_buff *skb)
=20
 EXPORT_SYMBOL(netif_rx_ni);
=20
+static void net_drop_skb(struct sk_buff_head *skb_queue)
+{
+	struct sk_buff *skb =3D __skb_dequeue(skb_queue);
+
+	while (skb) {
+		__get_cpu_var(netdev_rx_stat).dropped++;
+		kfree_skb(skb);
+		skb =3D __skb_dequeue(skb_queue);
+	}
+}
+
+static int net_backlog_local_merge(struct sk_buff_head *skb_queue)
+{
+	struct softnet_data *queue;
+	unsigned long flags;
+
+	queue =3D &__get_cpu_var(softnet_data);
+	if (queue->input_pkt_queue.qlen + skb_queue->qlen <=3D
+		netdev_max_backlog) {
+
+		local_irq_save(flags);
+		if (!queue->input_pkt_queue.qlen)
+			napi_schedule(&queue->backlog);
+		skb_queue_splice_tail_init(skb_queue, &queue->input_pkt_queue);
+		local_irq_restore(flags);
+
+		return  0;
+	} else {
+		net_drop_skb(skb_queue);
+		return 1;
+	}
+}
+
+static void net_napi_backlog(void *data)
+{
+	struct softnet_data *queue =3D &__get_cpu_var(softnet_data);
+
+	napi_schedule(&queue->backlog);
+	kfree(data);
+}
+
+static int net_backlog_notify_cpu(int cpu)
+{
+	struct call_single_data *data;
+
+	data =3D kmalloc(sizeof(struct call_single_data), GFP_ATOMIC);
+	if (!data)
+		return -1;
+
+	data->func =3D net_napi_backlog;
+	data->info =3D data;
+	data->flags =3D 0;
+	__smp_call_function_single(cpu, data);
+
+	return 0;
+}
+
+int raise_netif_irq(int cpu, struct sk_buff_head *skb_queue)
+{
+	unsigned long flags;
+	struct softnet_data *queue;
+	int retval, need_notify=3D0;
+
+	if (!skb_queue || skb_queue_empty(skb_queue))
+		return 0;
+
+	/*
+	 * If cpu is offline, we queue skb back to
+	 * the queue on current cpu.
+	 */
+	if ((unsigned)cpu >=3D nr_cpu_ids ||
+		!cpu_online(cpu) ||
+		cpu =3D=3D smp_processor_id()) {
+		net_backlog_local_merge(skb_queue);
+		return 0;
+	}
+
+	queue =3D &per_cpu(softnet_data, cpu);
+	if (queue->input_pkt_alien_queue.qlen > netdev_max_backlog)
+		goto failed1;
+
+	spin_lock_irqsave(&queue->input_pkt_alien_queue.lock, flags);
+	if (skb_queue_empty(&queue->input_pkt_alien_queue))
+		need_notify =3D 1;
+	skb_queue_splice_tail_init(skb_queue,
+			&queue->input_pkt_alien_queue);
+	spin_unlock_irqrestore(&queue->input_pkt_alien_queue.lock,
+			flags);
+
+	if (need_notify) {
+		retval =3D net_backlog_notify_cpu(cpu);
+		if (unlikely(retval))
+			goto failed2;
+	}
+
+	return 0;
+
+failed2:
+	spin_lock_irqsave(&queue->input_pkt_alien_queue.lock, flags);
+	skb_queue_splice_tail_init(&queue->input_pkt_alien_queue, skb_queue);
+	spin_unlock_irqrestore(&queue->input_pkt_alien_queue.lock,
+			flags);
+failed1:
+	net_drop_skb(skb_queue);
+
+	return 1;
+}
+
 static void net_tx_action(struct softirq_action *h)
 {
 	struct softnet_data *sd =3D &__get_cpu_var(softnet_data);
@@ -2336,6 +2444,13 @@ static void flush_backlog(void *arg)
 	struct net_device *dev =3D arg;
 	struct softnet_data *queue =3D &__get_cpu_var(softnet_data);
 	struct sk_buff *skb, *tmp;
+	unsigned long flags;
+
+	spin_lock_irqsave(&queue->input_pkt_alien_queue.lock, flags);
+	skb_queue_splice_tail_init(
+			&queue->input_pkt_alien_queue,
+			&queue->input_pkt_queue );
+	spin_unlock_irqrestore(&queue->input_pkt_alien_queue.lock, flags);
=20
 	skb_queue_walk_safe(&queue->input_pkt_queue, skb, tmp)
 		if (skb->dev =3D=3D dev) {
@@ -2594,9 +2709,19 @@ static int process_backlog(struct napi_s
 		local_irq_disable();
 		skb =3D __skb_dequeue(&queue->input_pkt_queue);
 		if (!skb) {
-			__napi_complete(napi);
-			local_irq_enable();
-			break;
+			if (!skb_queue_empty(&queue->input_pkt_alien_queue)) {
+				spin_lock(&queue->input_pkt_alien_queue.lock);
+				skb_queue_splice_tail_init(
+						&queue->input_pkt_alien_queue,
+						&queue->input_pkt_queue );
+				spin_unlock(&queue->input_pkt_alien_queue.lock);
+
+				skb =3D __skb_dequeue(&queue->input_pkt_queue);
+			} else {
+				__napi_complete(napi);
+				local_irq_enable();
+				break;
+			}
 		}
 		local_irq_enable();
=20
@@ -4985,6 +5110,11 @@ static int dev_cpu_callback(struct notif
 	local_irq_enable();
=20
 	/* Process offline CPU's input_pkt_queue */
+	spin_lock(&oldsd->input_pkt_alien_queue.lock);
+	skb_queue_splice_tail_init(&oldsd->input_pkt_alien_queue,
+			&oldsd->input_pkt_queue);
+	spin_unlock(&oldsd->input_pkt_alien_queue.lock);
+
 	while ((skb =3D __skb_dequeue(&oldsd->input_pkt_queue)))
 		netif_rx(skb);
=20
@@ -5184,10 +5314,13 @@ static int __init net_dev_init(void)
 		struct softnet_data *queue;
=20
 		queue =3D &per_cpu(softnet_data, i);
+
 		skb_queue_head_init(&queue->input_pkt_queue);
 		queue->completion_queue =3D NULL;
 		INIT_LIST_HEAD(&queue->poll_list);
=20
+		skb_queue_head_init(&queue->input_pkt_alien_queue);
+
 		queue->backlog.poll =3D process_backlog;
 		queue->backlog.weight =3D weight_p;
 		queue->backlog.gro_list =3D NULL;
@@ -5247,6 +5380,7 @@ EXPORT_SYMBOL(netdev_set_master);
 EXPORT_SYMBOL(netdev_state_change);
 EXPORT_SYMBOL(netif_receive_skb);
 EXPORT_SYMBOL(netif_rx);
+EXPORT_SYMBOL(raise_netif_irq);
 EXPORT_SYMBOL(register_gifconf);
 EXPORT_SYMBOL(register_netdevice);
 EXPORT_SYMBOL(register_netdevice_notifier);


