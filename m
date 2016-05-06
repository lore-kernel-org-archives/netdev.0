From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] fq_codel: add memory limitation per queue
Date: Fri, 06 May 2016 08:55:12 -0700
Message-ID: <1462550112.13075.47.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAA93jw6QLyx9EaS+ntB0D3duoysu_Z-UYyQfHnRa=pfqPDfWOw@mail.gmail.com>
	 <865DA393-262D-40B6-A9D3-1B978CD5F6C6@gmail.com>
	 <1462128385.5535.200.camel@edumazet-glaptop3.roam.corp.google.com>
	 <C5D365DA-18EE-446E-9D25-41F48B1C583E@gmail.com>
	 <1462136140.5535.219.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CACiydbKUu11=zWitkDha0ddgk1-G_Z4-e1+=9ky776VktF5HHg@mail.gmail.com>
	 <1462201620.5535.250.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CACiydbKeKUENncrc-NmYRcku-DGVeGqqzYMqsCqKdxPsR7yUOQ@mail.gmail.com>
	 <1462205669.5535.254.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CACiydbL26Jj3EcEL4EmqaH=1Dm-Q0dpVwoWxqUSZ7ry10bRgeg@mail.gmail.com>
	 <1462464776.13075.18.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CACiydbJYrFRMJvSHM6tJYWR8vmgV3xxnSUQsb-h5WcnLW=KXoQ@mail.gmail.com>
	 <1462476207.13075.20.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAA93jw4XZ1+LLX1z6wQ6DHsp4vFCS5zmMz-uku_8SBNG_KuUxA@mail.gmail.com>
	 <542135C7-D7CC-4E33-B35B-C2AD259FA5AB@gmx.de>
	 <20160506133323.0b190f47@redhat.com>
	 <D29AB9B2-D514-4D14-9A16-CFB9ECD05B17@gmx.de>
	 <1462541156.13075.34.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Dave =?ISO-8859-1?Q?T=E4ht?= <dave.taht@gmail.com>,
	netdev <netdev@vger.kernel.org>, moeller0 <moeller0@gmx.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35319 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758073AbcEFPzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 11:55:15 -0400
Received: by mail-pa0-f52.google.com with SMTP id iv1so48726518pac.2
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 08:55:14 -0700 (PDT)
In-Reply-To: <1462541156.13075.34.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

On small embedded routers, one wants to control maximal amount of
memory used by fq_codel, instead of controlling number of packets or
bytes, since GRO/TSO make these not practical.

Assuming skb->truesize is accurate, we have to keep track of
skb->truesize sum for skbs in queue.

This patch adds a new TCA_FQ_CODEL_MEMORY_LIMIT attribute.

I chose a default value of 32 MBytes, which looks reasonable even
for heavy duty usages. (Prior fq_codel users should not be hurt
when they upgrade their kernels)

Two fields are added to tc_fq_codel_qd_stats to report :
 - Current memory usage
 - Number of drops caused by memory limits

# tc qd replace dev eth1 root est 1sec 4sec fq_codel memory_limit 4M
=2E.
# tc -s -d qd sh dev eth1
qdisc fq_codel 8008: root refcnt 257 limit 10240p flows 1024
 quantum 1514 target 5.0ms interval 100.0ms memory_limit 4Mb ecn=20
 Sent 2083566791363 bytes 1376214889 pkt (dropped 4994406, overlimits 0
requeues 21705223)=20
 rate 9841Mbit 812549pps backlog 3906120b 376p requeues 21705223=20
  maxpacket 68130 drop_overlimit 4994406 new_flow_count 28855414
  ecn_mark 0 memory_used 4190048 drop_overmemory 4994406
  new_flows_len 1 old_flows_len 177


Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Dave T=C3=A4ht <dave.taht@gmail.com>
Cc: Sebastian M=C3=B6ller <moeller0@gmx.de>
---
 include/uapi/linux/pkt_sched.h |    3 +++
 net/sched/sch_fq_codel.c       |   27 ++++++++++++++++++++++++---
 2 files changed, 27 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sc=
hed.h
index a11afecd4482..2382eed50278 100644
--- a/include/uapi/linux/pkt_sched.h
+++ b/include/uapi/linux/pkt_sched.h
@@ -719,6 +719,7 @@ enum {
 	TCA_FQ_CODEL_QUANTUM,
 	TCA_FQ_CODEL_CE_THRESHOLD,
 	TCA_FQ_CODEL_DROP_BATCH_SIZE,
+	TCA_FQ_CODEL_MEMORY_LIMIT,
 	__TCA_FQ_CODEL_MAX
 };
=20
@@ -743,6 +744,8 @@ struct tc_fq_codel_qd_stats {
 	__u32	new_flows_len;	/* count of flows in new list */
 	__u32	old_flows_len;	/* count of flows in old list */
 	__u32	ce_mark;	/* packets above ce_threshold */
+	__u32	memory_usage;	/* in bytes */
+	__u32	drop_overmemory;
 };
=20
 struct tc_fq_codel_cl_stats {
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index e7b42b0d5145..bb8bd9314629 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -60,8 +60,11 @@ struct fq_codel_sched_data {
 	u32		perturbation;	/* hash perturbation */
 	u32		quantum;	/* psched_mtu(qdisc_dev(sch)); */
 	u32		drop_batch_size;
+	u32		memory_limit;
 	struct codel_params cparams;
 	struct codel_stats cstats;
+	u32		memory_usage;
+	u32		drop_overmemory;
 	u32		drop_overlimit;
 	u32		new_flow_count;
=20
@@ -143,6 +146,7 @@ static unsigned int fq_codel_drop(struct Qdisc *sch=
, unsigned int max_packets)
 	unsigned int maxbacklog =3D 0, idx =3D 0, i, len;
 	struct fq_codel_flow *flow;
 	unsigned int threshold;
+	unsigned int mem =3D 0;
=20
 	/* Queue is full! Find the fat flow and drop packet(s) from it.
 	 * This might sound expensive, but with 1024 flows, we scan
@@ -167,11 +171,13 @@ static unsigned int fq_codel_drop(struct Qdisc *s=
ch, unsigned int max_packets)
 	do {
 		skb =3D dequeue_head(flow);
 		len +=3D qdisc_pkt_len(skb);
+		mem +=3D skb->truesize;
 		kfree_skb(skb);
 	} while (++i < max_packets && len < threshold);
=20
 	flow->dropped +=3D i;
 	q->backlogs[idx] -=3D len;
+	q->memory_usage -=3D mem;
 	sch->qstats.drops +=3D i;
 	sch->qstats.backlog -=3D len;
 	sch->q.qlen -=3D i;
@@ -193,6 +199,7 @@ static int fq_codel_enqueue(struct sk_buff *skb, st=
ruct Qdisc *sch)
 	unsigned int idx, prev_backlog, prev_qlen;
 	struct fq_codel_flow *flow;
 	int uninitialized_var(ret);
+	bool memory_limited;
=20
 	idx =3D fq_codel_classify(skb, sch, &ret);
 	if (idx =3D=3D 0) {
@@ -215,7 +222,9 @@ static int fq_codel_enqueue(struct sk_buff *skb, st=
ruct Qdisc *sch)
 		flow->deficit =3D q->quantum;
 		flow->dropped =3D 0;
 	}
-	if (++sch->q.qlen <=3D sch->limit)
+	q->memory_usage +=3D skb->truesize;
+	memory_limited =3D q->memory_usage > q->memory_limit;
+	if (++sch->q.qlen <=3D sch->limit && !memory_limited)
 		return NET_XMIT_SUCCESS;
=20
 	prev_backlog =3D sch->qstats.backlog;
@@ -229,7 +238,8 @@ static int fq_codel_enqueue(struct sk_buff *skb, st=
ruct Qdisc *sch)
 	ret =3D fq_codel_drop(sch, q->drop_batch_size);
=20
 	q->drop_overlimit +=3D prev_qlen - sch->q.qlen;
-
+	if (memory_limited)
+		q->drop_overmemory +=3D prev_qlen - sch->q.qlen;
 	/* As we dropped packet(s), better let upper stack know this */
 	qdisc_tree_reduce_backlog(sch, prev_qlen - sch->q.qlen,
 				  prev_backlog - sch->qstats.backlog);
@@ -308,6 +318,7 @@ begin:
 			list_del_init(&flow->flowchain);
 		goto begin;
 	}
+	q->memory_usage -=3D skb->truesize;
 	qdisc_bstats_update(sch, skb);
 	flow->deficit -=3D qdisc_pkt_len(skb);
 	/* We cant call qdisc_tree_reduce_backlog() if our qlen is 0,
@@ -355,6 +366,7 @@ static const struct nla_policy fq_codel_policy[TCA_=
=46Q_CODEL_MAX + 1] =3D {
 	[TCA_FQ_CODEL_QUANTUM]	=3D { .type =3D NLA_U32 },
 	[TCA_FQ_CODEL_CE_THRESHOLD] =3D { .type =3D NLA_U32 },
 	[TCA_FQ_CODEL_DROP_BATCH_SIZE] =3D { .type =3D NLA_U32 },
+	[TCA_FQ_CODEL_MEMORY_LIMIT] =3D { .type =3D NLA_U32 },
 };
=20
 static int fq_codel_change(struct Qdisc *sch, struct nlattr *opt)
@@ -409,7 +421,11 @@ static int fq_codel_change(struct Qdisc *sch, stru=
ct nlattr *opt)
 	if (tb[TCA_FQ_CODEL_DROP_BATCH_SIZE])
 		q->drop_batch_size =3D min(1U, nla_get_u32(tb[TCA_FQ_CODEL_DROP_BATC=
H_SIZE]));
=20
-	while (sch->q.qlen > sch->limit) {
+	if (tb[TCA_FQ_CODEL_MEMORY_LIMIT])
+		q->memory_limit =3D min(1U << 31, nla_get_u32(tb[TCA_FQ_CODEL_MEMORY=
_LIMIT]));
+
+	while (sch->q.qlen > sch->limit ||
+	       q->memory_usage > q->memory_limit) {
 		struct sk_buff *skb =3D fq_codel_dequeue(sch);
=20
 		q->cstats.drop_len +=3D qdisc_pkt_len(skb);
@@ -454,6 +470,7 @@ static int fq_codel_init(struct Qdisc *sch, struct =
nlattr *opt)
=20
 	sch->limit =3D 10*1024;
 	q->flows_cnt =3D 1024;
+	q->memory_limit =3D 32 << 20; /* 32 MBytes */
 	q->drop_batch_size =3D 64;
 	q->quantum =3D psched_mtu(qdisc_dev(sch));
 	q->perturbation =3D prandom_u32();
@@ -515,6 +532,8 @@ static int fq_codel_dump(struct Qdisc *sch, struct =
sk_buff *skb)
 			q->quantum) ||
 	    nla_put_u32(skb, TCA_FQ_CODEL_DROP_BATCH_SIZE,
 			q->drop_batch_size) ||
+	    nla_put_u32(skb, TCA_FQ_CODEL_MEMORY_LIMIT,
+			q->memory_limit) ||
 	    nla_put_u32(skb, TCA_FQ_CODEL_FLOWS,
 			q->flows_cnt))
 		goto nla_put_failure;
@@ -543,6 +562,8 @@ static int fq_codel_dump_stats(struct Qdisc *sch, s=
truct gnet_dump *d)
 	st.qdisc_stats.ecn_mark =3D q->cstats.ecn_mark;
 	st.qdisc_stats.new_flow_count =3D q->new_flow_count;
 	st.qdisc_stats.ce_mark =3D q->cstats.ce_mark;
+	st.qdisc_stats.memory_usage  =3D q->memory_usage;
+	st.qdisc_stats.drop_overmemory =3D q->drop_overmemory;
=20
 	list_for_each(pos, &q->new_flows)
 		st.qdisc_stats.new_flows_len++;
