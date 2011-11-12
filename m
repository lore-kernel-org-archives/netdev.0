From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: creating netdev queues on the fly?
Date: Sat, 12 Nov 2011 10:45:46 +0100
Message-ID: <1321091146.12394.8.camel@edumazet-laptop>
References: <1320933501.3967.68.camel@jlt3.sipsolutions.net>
	 <CAGXE3d-_RFgW_zwfX2vTBe1psXmgoBFO5pd5cAgtYo=Jwpddhw@mail.gmail.com>
	 <7be02f26a67fac4c7448a74f1f17aa01@visp.net.lb>
	 <CAA93jw7ECQegWj6rpd48sbmDQUjorCYzXANXJSj0baHtxzC7EA@mail.gmail.com>
	 <1321009374.2548.31.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Denys Fedoryshchenko <denys@wbc.net.sa>,
	Helmut Schaa <helmut.schaa@googlemail.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61980 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751262Ab1KLJpx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Nov 2011 04:45:53 -0500
In-Reply-To: <1321009374.2548.31.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 11 novembre 2011 =C3=A0 12:02 +0100, Eric Dumazet a =C3=A9c=
rit :

> I would see a new Qdisc/Class property, like the rate estimator, that=
 we
> can attach to any Qdisc/Class with a new tc option.
>=20
> Even without any limit enforcing (might be Random Early Detection by =
the
> way), it could be used to get a Queue Delay estimation, using EWMA
>=20
> avqdelay =3D avqdelay*(1-W) + qdelay*W;
> W =3D 2^(-ewma_log);
>=20
> tc [ qdisc | class] add [...] [est 1sec 8sec] [delayest ewma_log ] ..
>=20
> tc -s -d qdisc ...
> qdisc htb 1: root refcnt 2 r2q 10 default 1 direct_packets_stat 0 ver=
 3.17
>  Sent 3596219 bytes 2567 pkt (dropped 238, overlimits 3797 requeues 0=
)=20
>  rate 2557Kbit 215pps backlog 0b 0p requeues 0=20
>  delay 91ms
>=20
>=20


I coded the thing (delayest at qdisc level) and got interesting values,
for example with following HTB setup :

DEV=3Deth3
MTU=3D1500
rate=3D10mbit
EST=3D"est 1sec 8sec delayest 6"

tc qdisc del dev $DEV root
tc qdisc add dev $DEV root handle 1: ${EST} \
	htb default 1=20
tc class add dev $DEV parent 1: classid 1:1 htb \
	rate ${rate} mtu 40000 quantum 80000
tc qdisc add dev $DEV parent 1:1 handle 10: ${EST} pfifo limit 3


With light trafic on my x86_64 machine I have :

# tcnew -s -d qdisc show dev eth3
qdisc htb 1: root refcnt 17 r2q 10 default 1 direct_packets_stat 0 ver =
3.17
 Sent 78216 bytes 569 pkt (dropped 0, overlimits 0 requeues 0)=20
 rate 9040bit 13pps backlog 0b 0p requeues 0=20
 delay 1126 ns log 6
qdisc pfifo 10: parent 1:1 limit 3p
 Sent 78216 bytes 569 pkt (dropped 0, overlimits 0 requeues 0)=20
 rate 9040bit 13pps backlog 0b 0p requeues 0=20
 delay 731 ns log 6

Wow, 1126ns of overhead per packet...

This is the prototype kernel patch I used on top of net-next :

diff --git a/include/linux/gen_stats.h b/include/linux/gen_stats.h
index 552c8a0..5ad57a6 100644
--- a/include/linux/gen_stats.h
+++ b/include/linux/gen_stats.h
@@ -63,5 +63,16 @@ struct gnet_estimator {
 	unsigned char	ewma_log;
 };
=20
+/**
+ * struct gnet_qdelay - queue delay configuration / reports
+ * @avdelay: average queue delay in ns
+ * @limit: packets delayed more than this value are dropped
+ * @avdelaylog: the log of measurement window weight
+ */
+struct gnet_qdelay {
+	__u64 avdelay;
+	__u64 limit;
+	__u32 avdelaylog;
+};
=20
 #endif /* __LINUX_GEN_STATS_H */
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 8e872ea..61c66ec 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -484,6 +484,7 @@ enum {
 	TCA_FCNT,
 	TCA_STATS2,
 	TCA_STAB,
+	TCA_QDELAY,
 	__TCA_MAX
 };
=20
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index f6bb08b..e293228 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -42,6 +42,13 @@ struct qdisc_size_table {
 	u16			data[];
 };
=20
+/*
+ * qdisc/class avdelay is computed using EWMA, with a fixed factor of =
16
+ * Only the weight is a parameter (avdelaylog)
+ * With u64 values, this leaves 48 bits, a max of 281474 seconds.
+ */
+#define TCQ_AVDELAY_FACTOR 16
+
 struct Qdisc {
 	int 			(*enqueue)(struct sk_buff *skb, struct Qdisc *dev);
 	struct sk_buff *	(*dequeue)(struct Qdisc *dev);
@@ -50,8 +57,11 @@ struct Qdisc {
 #define TCQ_F_INGRESS		2
 #define TCQ_F_CAN_BYPASS	4
 #define TCQ_F_MQROOT		8
+#define TCQ_F_QDELAY		0x10
 #define TCQ_F_WARN_NONWC	(1 << 16)
-	int			padded;
+	u8			padded;
+	u8			avdelaylog; /* avdelay EWMA weight */
+	u8			_pad[2];
 	const struct Qdisc_ops	*ops;
 	struct qdisc_size_table	__rcu *stab;
 	struct list_head	list;
@@ -80,6 +90,10 @@ struct Qdisc {
 	struct gnet_stats_basic_packed bstats;
 	unsigned int		__state;
 	struct gnet_stats_queue	qstats;
+
+	/* average queue delay in ns << TCQ_AVDELAY_FACTOR */
+	u64			avdelay;
+
 	struct rcu_head		rcu_head;
 	spinlock_t		busylock;
 	u32			limit;
@@ -219,6 +233,9 @@ struct tcf_proto {
 };
=20
 struct qdisc_skb_cb {
+#ifdef CONFIG_NET_SCHED_QDELAY
+	ktime_t			enqueue_time;
+#endif
 	unsigned int		pkt_len;
 	long			data[];
 };
@@ -467,6 +484,14 @@ static inline void qdisc_bstats_update(struct Qdis=
c *sch,
 				       const struct sk_buff *skb)
 {
 	bstats_update(&sch->bstats, skb);
+#ifdef CONFIG_NET_SCHED_QDELAY
+	if (sch->flags & TCQ_F_QDELAY) {
+		u64 delay =3D ktime_to_ns(ktime_sub(ktime_get(),
+					qdisc_skb_cb(skb)->enqueue_time));
+		delay <<=3D TCQ_AVDELAY_FACTOR;
+		sch->avdelay +=3D (delay >> sch->avdelaylog) - (sch->avdelay >> sch-=
>avdelaylog);
+	}
+#endif
 }
=20
 static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct Qdi=
sc *sch,
diff --git a/net/core/dev.c b/net/core/dev.c
index 6ba50a1..587534d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2402,6 +2402,13 @@ static inline int __dev_xmit_skb(struct sk_buff =
*skb, struct Qdisc *q,
 	int rc;
=20
 	qdisc_skb_cb(skb)->pkt_len =3D skb->len;
+
+#ifdef CONFIG_NET_SCHED_QDELAY
+	qdisc_skb_cb(skb)->enqueue_time.tv64 =3D 0;
+	if (q->flags & TCQ_F_QDELAY)
+		qdisc_skb_cb(skb)->enqueue_time =3D ktime_get();
+#endif
+
 	qdisc_calculate_pkt_len(skb, q);
 	/*
 	 * Heuristic to force contended enqueues to serialize on a
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 2590e91..028f882 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -470,6 +470,17 @@ config NET_CLS_ACT
 	  A recent version of the iproute2 package is required to use
 	  extended matches.
=20
+config NET_SCHED_QDELAY
+	bool "QDISC/CLASS queue delay Estimators and Limits"
+	---help---
+	  Say Y here if you want to be able to track queue delays, and
+	  be able to drop packets if they stay in a queue a too long time.
+	  It adds some overhead per packet, since it needs to get precise
+	  time at enqueue and dequeue time.
+
+	  A recent version of the iproute2 package is required to use
+	  extended matches.
+
 config NET_ACT_POLICE
 	tristate "Traffic Policing"
         depends on NET_CLS_ACT=20
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index dca6c1a..212fba9 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -842,6 +842,17 @@ qdisc_create(struct net_device *dev, struct netdev=
_queue *dev_queue,
 			}
 			rcu_assign_pointer(sch->stab, stab);
 		}
+		if (tca[TCA_QDELAY]) {
+			struct gnet_qdelay *parm =3D nla_data(tca[TCA_QDELAY]);
+			err =3D -EINVAL;
+			if (nla_len(tca[TCA_QDELAY]) < sizeof(*parm))
+				goto err_out4;
+			sch->avdelaylog =3D parm->avdelaylog;
+			sch->flags |=3D TCQ_F_QDELAY;
+		} else { /* temporary testing */
+			sch->avdelaylog =3D 6;
+			sch->flags |=3D TCQ_F_QDELAY;
+		}
 		if (tca[TCA_RATE]) {
 			spinlock_t *root_lock;
=20
@@ -1206,6 +1217,16 @@ static int tc_fill_qdisc(struct sk_buff *skb, st=
ruct Qdisc *q, u32 clid,
 	if (stab && qdisc_dump_stab(skb, stab) < 0)
 		goto nla_put_failure;
=20
+#ifdef CONFIG_NET_SCHED_QDELAY
+	if (q->flags & TCQ_F_QDELAY) {
+		struct gnet_qdelay qdelay;
+
+		memset(&qdelay, 0, sizeof(qdelay));=09
+		qdelay.avdelay =3D q->avdelay >> TCQ_AVDELAY_FACTOR;
+		qdelay.avdelaylog =3D q->avdelaylog;
+		NLA_PUT(skb, TCA_QDELAY, sizeof(qdelay), &qdelay);
+	}
+#endif
 	if (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS, TCA_XSTA=
TS,
 					 qdisc_root_sleeping_lock(q), &d) < 0)
 		goto nla_put_failure;
