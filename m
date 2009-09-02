From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] tc: report informations for multiqueue devices
Date: Wed, 02 Sep 2009 14:30:09 +0200
Message-ID: <4A9E6551.4030209@gmail.com>
References: <20090902081429.GB4878@ff.dom.local>	<4A9E2CC7.1010103@gmail.com> <20090902.013002.181288977.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jarkao2@gmail.com, cl@linux-foundation.org, kaber@trash.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:32787 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751050AbZIBMaP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 08:30:15 -0400
In-Reply-To: <20090902.013002.181288977.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 02 Sep 2009 10:28:55 +0200
>=20
>> What naming convention should we choose for multiqueue devices ?
>=20
> We could give an index field to multiple root qdiscs assigned
> to a device.

Here is a patch then :)

Only point is that I am iterating from 0 to dev->real_num_tx_queues
instead of dev->num_tx_queues. I hope it's fine, because there are
allocated qdisc, but not really used.

Next patches to allow selective qdisc change/fetch (providing a TCA_QIN=
DEX
selector value to kernel)

Thanks


[PATCH net-next-2.6] tc: report informations for multiqueue devices

qdisc and classes are not yet displayed by "tc -s -d {qdisc|class} show=
"
for multiqueue devices.

We use a new TCA_QINDEX attribute, to report queue index to user space.
iproute2 tc should be changed to eventually display this queue index as=
 in :

$ tc -s -d qdisc
qdisc pfifo_fast 0: dev eth0 root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 =
1 1 1 1 1 1
 Sent 52498 bytes 465 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
qdisc pfifo_fast 0: dev eth0 qindex 1 root bands 3 priomap  1 2 2 2 1 2=
 0 0 1 1 1 1 1 1 1 1
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0



Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/rtnetlink.h |    1
 net/sched/sch_api.c       |  118 ++++++++++++++++++++----------------
 2 files changed, 67 insertions(+), 52 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index ba3254e..b80e0f6 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -490,6 +490,7 @@ enum
 	TCA_FCNT,
 	TCA_STATS2,
 	TCA_STAB,
+	TCA_QINDEX,
 	__TCA_MAX
 };
=20
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 24d17ce..74cde83 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -35,9 +35,9 @@
 #include <net/pkt_sched.h>
=20
 static int qdisc_notify(struct sk_buff *oskb, struct nlmsghdr *n, u32 =
clid,
-			struct Qdisc *old, struct Qdisc *new);
+			struct Qdisc *old, struct Qdisc *new, int qnum);
 static int tclass_notify(struct sk_buff *oskb, struct nlmsghdr *n,
-			 struct Qdisc *q, unsigned long cl, int event);
+			 struct Qdisc *q, unsigned long cl, int event, int qnum);
=20
 /*
=20
@@ -671,10 +671,10 @@ void qdisc_tree_decrease_qlen(struct Qdisc *sch, =
unsigned int n)
 EXPORT_SYMBOL(qdisc_tree_decrease_qlen);
=20
 static void notify_and_destroy(struct sk_buff *skb, struct nlmsghdr *n=
, u32 clid,
-			       struct Qdisc *old, struct Qdisc *new)
+			       struct Qdisc *old, struct Qdisc *new, int qnum)
 {
 	if (new || old)
-		qdisc_notify(skb, n, clid, old, new);
+		qdisc_notify(skb, n, clid, old, new, qnum);
=20
 	if (old)
 		qdisc_destroy(old);
@@ -720,7 +720,7 @@ static int qdisc_graft(struct net_device *dev, stru=
ct Qdisc *parent,
 			if (new && i > 0)
 				atomic_inc(&new->refcnt);
=20
-			notify_and_destroy(skb, n, classid, old, new);
+			notify_and_destroy(skb, n, classid, old, new, i);
 		}
=20
 		if (dev->flags & IFF_UP)
@@ -738,7 +738,7 @@ static int qdisc_graft(struct net_device *dev, stru=
ct Qdisc *parent,
 			}
 		}
 		if (!err)
-			notify_and_destroy(skb, n, classid, old, new);
+			notify_and_destroy(skb, n, classid, old, new, 0);
 	}
 	return err;
 }
@@ -999,7 +999,7 @@ static int tc_get_qdisc(struct sk_buff *skb, struct=
 nlmsghdr *n, void *arg)
 		if ((err =3D qdisc_graft(dev, p, skb, n, clid, NULL, q)) !=3D 0)
 			return err;
 	} else {
-		qdisc_notify(skb, n, clid, NULL, q);
+		qdisc_notify(skb, n, clid, NULL, q, 0);
 	}
 	return 0;
 }
@@ -1116,7 +1116,7 @@ replay:
 		return -EINVAL;
 	err =3D qdisc_change(q, tca);
 	if (err =3D=3D 0)
-		qdisc_notify(skb, n, clid, NULL, q);
+		qdisc_notify(skb, n, clid, NULL, q, 0);
 	return err;
=20
 create_n_graft:
@@ -1148,7 +1148,7 @@ graft:
 }
=20
 static int tc_fill_qdisc(struct sk_buff *skb, struct Qdisc *q, u32 cli=
d,
-			 u32 pid, u32 seq, u16 flags, int event)
+			 u32 pid, u32 seq, u16 flags, int event, int qnum)
 {
 	struct tcmsg *tcm;
 	struct nlmsghdr  *nlh;
@@ -1187,6 +1187,9 @@ static int tc_fill_qdisc(struct sk_buff *skb, str=
uct Qdisc *q, u32 clid,
 	if (gnet_stats_finish_copy(&d) < 0)
 		goto nla_put_failure;
=20
+	if (qnum)
+		NLA_PUT_U32(skb, TCA_QINDEX, qnum);
+
 	nlh->nlmsg_len =3D skb_tail_pointer(skb) - b;
 	return skb->len;
=20
@@ -1197,7 +1200,8 @@ nla_put_failure:
 }
=20
 static int qdisc_notify(struct sk_buff *oskb, struct nlmsghdr *n,
-			u32 clid, struct Qdisc *old, struct Qdisc *new)
+			u32 clid, struct Qdisc *old, struct Qdisc *new,
+			int qnum)
 {
 	struct sk_buff *skb;
 	u32 pid =3D oskb ? NETLINK_CB(oskb).pid : 0;
@@ -1207,11 +1211,13 @@ static int qdisc_notify(struct sk_buff *oskb, s=
truct nlmsghdr *n,
 		return -ENOBUFS;
=20
 	if (old && old->handle) {
-		if (tc_fill_qdisc(skb, old, clid, pid, n->nlmsg_seq, 0, RTM_DELQDISC=
) < 0)
+		if (tc_fill_qdisc(skb, old, clid, pid, n->nlmsg_seq, 0,
+				  RTM_DELQDISC, qnum) < 0)
 			goto err_out;
 	}
 	if (new) {
-		if (tc_fill_qdisc(skb, new, clid, pid, n->nlmsg_seq, old ? NLM_F_REP=
LACE : 0, RTM_NEWQDISC) < 0)
+		if (tc_fill_qdisc(skb, new, clid, pid, n->nlmsg_seq,
+				  old ? NLM_F_REPLACE : 0, RTM_NEWQDISC, qnum) < 0)
 			goto err_out;
 	}
=20
@@ -1230,7 +1236,7 @@ static bool tc_qdisc_dump_ignore(struct Qdisc *q)
=20
 static int tc_dump_qdisc_root(struct Qdisc *root, struct sk_buff *skb,
 			      struct netlink_callback *cb,
-			      int *q_idx_p, int s_q_idx)
+			      int *q_idx_p, int s_q_idx, int qnum)
 {
 	int ret =3D 0, q_idx =3D *q_idx_p;
 	struct Qdisc *q;
@@ -1239,23 +1245,18 @@ static int tc_dump_qdisc_root(struct Qdisc *roo=
t, struct sk_buff *skb,
 		return 0;
=20
 	q =3D root;
-	if (q_idx < s_q_idx) {
-		q_idx++;
-	} else {
-		if (!tc_qdisc_dump_ignore(q) &&
-		    tc_fill_qdisc(skb, q, q->parent, NETLINK_CB(cb->skb).pid,
-				  cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWQDISC) <=3D 0)
-			goto done;
-		q_idx++;
-	}
+	if (q_idx >=3D s_q_idx &&
+	    !tc_qdisc_dump_ignore(q) &&
+	    tc_fill_qdisc(skb, q, q->parent, NETLINK_CB(cb->skb).pid,
+			  cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWQDISC, qnum) <=3D 0)
+		goto done;
+	q_idx++;
+
 	list_for_each_entry(q, &root->list, list) {
-		if (q_idx < s_q_idx) {
-			q_idx++;
-			continue;
-		}
-		if (!tc_qdisc_dump_ignore(q) &&=20
+		if (q_idx >=3D s_q_idx &&
+		    !tc_qdisc_dump_ignore(q) &&=20
 		    tc_fill_qdisc(skb, q, q->parent, NETLINK_CB(cb->skb).pid,
-				  cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWQDISC) <=3D 0)
+				  cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWQDISC, qnum) <=3D 0)
 			goto done;
 		q_idx++;
 	}
@@ -1284,6 +1285,7 @@ static int tc_dump_qdisc(struct sk_buff *skb, str=
uct netlink_callback *cb)
 	idx =3D 0;
 	for_each_netdev(&init_net, dev) {
 		struct netdev_queue *dev_queue;
+		int ntx;
=20
 		if (idx < s_idx)
 			goto cont;
@@ -1291,12 +1293,15 @@ static int tc_dump_qdisc(struct sk_buff *skb, s=
truct netlink_callback *cb)
 			s_q_idx =3D 0;
 		q_idx =3D 0;
=20
-		dev_queue =3D netdev_get_tx_queue(dev, 0);
-		if (tc_dump_qdisc_root(dev_queue->qdisc_sleeping, skb, cb, &q_idx, s=
_q_idx) < 0)
-			goto done;
-
+		for (ntx =3D 0 ; ntx < dev->real_num_tx_queues; ntx++) {
+			dev_queue =3D netdev_get_tx_queue(dev, ntx);
+			if (tc_dump_qdisc_root(dev_queue->qdisc_sleeping, skb,
+					       cb, &q_idx, s_q_idx, ntx) < 0)
+				goto done;
+		}
 		dev_queue =3D &dev->rx_queue;
-		if (tc_dump_qdisc_root(dev_queue->qdisc_sleeping, skb, cb, &q_idx, s=
_q_idx) < 0)
+		if (tc_dump_qdisc_root(dev_queue->qdisc_sleeping, skb, cb,
+				       &q_idx, s_q_idx, 0) < 0)
 			goto done;
=20
 cont:
@@ -1419,10 +1424,10 @@ static int tc_ctl_tclass(struct sk_buff *skb, s=
truct nlmsghdr *n, void *arg)
 		case RTM_DELTCLASS:
 			err =3D cops->delete(q, cl);
 			if (err =3D=3D 0)
-				tclass_notify(skb, n, q, cl, RTM_DELTCLASS);
+				tclass_notify(skb, n, q, cl, RTM_DELTCLASS, 0);
 			goto out;
 		case RTM_GETTCLASS:
-			err =3D tclass_notify(skb, n, q, cl, RTM_NEWTCLASS);
+			err =3D tclass_notify(skb, n, q, cl, RTM_NEWTCLASS, 0);
 			goto out;
 		default:
 			err =3D -EINVAL;
@@ -1433,7 +1438,7 @@ static int tc_ctl_tclass(struct sk_buff *skb, str=
uct nlmsghdr *n, void *arg)
 	new_cl =3D cl;
 	err =3D cops->change(q, clid, pid, tca, &new_cl);
 	if (err =3D=3D 0)
-		tclass_notify(skb, n, q, new_cl, RTM_NEWTCLASS);
+		tclass_notify(skb, n, q, new_cl, RTM_NEWTCLASS, 0);
=20
 out:
 	if (cl)
@@ -1445,7 +1450,7 @@ out:
=20
 static int tc_fill_tclass(struct sk_buff *skb, struct Qdisc *q,
 			  unsigned long cl,
-			  u32 pid, u32 seq, u16 flags, int event)
+			  u32 pid, u32 seq, u16 flags, int event, int qnum)
 {
 	struct tcmsg *tcm;
 	struct nlmsghdr  *nlh;
@@ -1474,6 +1479,9 @@ static int tc_fill_tclass(struct sk_buff *skb, st=
ruct Qdisc *q,
 	if (gnet_stats_finish_copy(&d) < 0)
 		goto nla_put_failure;
=20
+	if (qnum)
+		NLA_PUT_U32(skb, TCA_QINDEX, qnum);
+
 	nlh->nlmsg_len =3D skb_tail_pointer(skb) - b;
 	return skb->len;
=20
@@ -1484,7 +1492,8 @@ nla_put_failure:
 }
=20
 static int tclass_notify(struct sk_buff *oskb, struct nlmsghdr *n,
-			  struct Qdisc *q, unsigned long cl, int event)
+			 struct Qdisc *q, unsigned long cl, int event,
+			 int qnum)
 {
 	struct sk_buff *skb;
 	u32 pid =3D oskb ? NETLINK_CB(oskb).pid : 0;
@@ -1493,7 +1502,7 @@ static int tclass_notify(struct sk_buff *oskb, st=
ruct nlmsghdr *n,
 	if (!skb)
 		return -ENOBUFS;
=20
-	if (tc_fill_tclass(skb, q, cl, pid, n->nlmsg_seq, 0, event) < 0) {
+	if (tc_fill_tclass(skb, q, cl, pid, n->nlmsg_seq, 0, event, qnum) < 0=
) {
 		kfree_skb(skb);
 		return -EINVAL;
 	}
@@ -1503,9 +1512,10 @@ static int tclass_notify(struct sk_buff *oskb, s=
truct nlmsghdr *n,
=20
 struct qdisc_dump_args
 {
-	struct qdisc_walker w;
-	struct sk_buff *skb;
+	struct qdisc_walker	w;
+	struct sk_buff		*skb;
 	struct netlink_callback *cb;
+	int			qnum;
 };
=20
 static int qdisc_class_dump(struct Qdisc *q, unsigned long cl, struct =
qdisc_walker *arg)
@@ -1513,12 +1523,13 @@ static int qdisc_class_dump(struct Qdisc *q, un=
signed long cl, struct qdisc_walk
 	struct qdisc_dump_args *a =3D (struct qdisc_dump_args *)arg;
=20
 	return tc_fill_tclass(a->skb, q, cl, NETLINK_CB(a->cb->skb).pid,
-			      a->cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWTCLASS);
+			      a->cb->nlh->nlmsg_seq, NLM_F_MULTI, RTM_NEWTCLASS,
+			      a->qnum);
 }
=20
 static int tc_dump_tclass_qdisc(struct Qdisc *q, struct sk_buff *skb,
 				struct tcmsg *tcm, struct netlink_callback *cb,
-				int *t_p, int s_t)
+				int *t_p, int s_t, int qnum)
 {
 	struct qdisc_dump_args arg;
=20
@@ -1537,6 +1548,7 @@ static int tc_dump_tclass_qdisc(struct Qdisc *q, =
struct sk_buff *skb,
 	arg.w.stop  =3D 0;
 	arg.w.skip =3D cb->args[1];
 	arg.w.count =3D 0;
+	arg.qnum =3D qnum;
 	q->ops->cl_ops->walk(q, &arg.w);
 	cb->args[1] =3D arg.w.count;
 	if (arg.w.stop)
@@ -1547,18 +1559,18 @@ static int tc_dump_tclass_qdisc(struct Qdisc *q=
, struct sk_buff *skb,
=20
 static int tc_dump_tclass_root(struct Qdisc *root, struct sk_buff *skb=
,
 			       struct tcmsg *tcm, struct netlink_callback *cb,
-			       int *t_p, int s_t)
+			       int *t_p, int s_t, int qnum)
 {
 	struct Qdisc *q;
=20
 	if (!root)
 		return 0;
=20
-	if (tc_dump_tclass_qdisc(root, skb, tcm, cb, t_p, s_t) < 0)
+	if (tc_dump_tclass_qdisc(root, skb, tcm, cb, t_p, s_t, qnum) < 0)
 		return -1;
=20
 	list_for_each_entry(q, &root->list, list) {
-		if (tc_dump_tclass_qdisc(q, skb, tcm, cb, t_p, s_t) < 0)
+		if (tc_dump_tclass_qdisc(q, skb, tcm, cb, t_p, s_t, qnum) < 0)
 			return -1;
 	}
=20
@@ -1571,7 +1583,7 @@ static int tc_dump_tclass(struct sk_buff *skb, st=
ruct netlink_callback *cb)
 	struct net *net =3D sock_net(skb->sk);
 	struct netdev_queue *dev_queue;
 	struct net_device *dev;
-	int t, s_t;
+	int t, s_t, ntx;
=20
 	if (net !=3D &init_net)
 		return 0;
@@ -1584,12 +1596,14 @@ static int tc_dump_tclass(struct sk_buff *skb, =
struct netlink_callback *cb)
 	s_t =3D cb->args[0];
 	t =3D 0;
=20
-	dev_queue =3D netdev_get_tx_queue(dev, 0);
-	if (tc_dump_tclass_root(dev_queue->qdisc_sleeping, skb, tcm, cb, &t, =
s_t) < 0)
-		goto done;
-
+	for (ntx =3D 0 ; ntx < dev->real_num_tx_queues; ntx++) {
+		dev_queue =3D netdev_get_tx_queue(dev, ntx);
+		if (tc_dump_tclass_root(dev_queue->qdisc_sleeping, skb, tcm,
+					cb, &t, s_t, ntx) < 0)
+			goto done;
+	}
 	dev_queue =3D &dev->rx_queue;
-	if (tc_dump_tclass_root(dev_queue->qdisc_sleeping, skb, tcm, cb, &t, =
s_t) < 0)
+	if (tc_dump_tclass_root(dev_queue->qdisc_sleeping, skb, tcm, cb, &t, =
s_t, 0) < 0)
 		goto done;
=20
 done:
