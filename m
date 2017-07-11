From: Amritha Nambiar <amritha.nambiar@intel.com>
Subject: [PATCH 1/6] [next-queue]net: mqprio: Introduce new hardware offload
 mode in mqprio for offloading full TC configurations
Date: Tue, 11 Jul 2017 03:18:35 -0700
Message-ID: <149976831535.2896.16233967758531918702.stgit@anamdev.jf.intel.com>
References: <149976762072.2896.5722904915197643856.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, kiran.patil@intel.com,
        amritha.nambiar@intel.com, netdev@vger.kernel.org,
        mitch.a.williams@intel.com, alexander.duyck@gmail.com,
        neerav.parikh@intel.com, sridhar.samudrala@intel.com,
        carolyn.wyborny@intel.com
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:35797 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932322AbdGKKTE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Jul 2017 06:19:04 -0400
In-Reply-To: <149976762072.2896.5722904915197643856.stgit@anamdev.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces a new hardware offload mode in mqprio
which makes full use of the mqprio options, the TCs, the
queue configurations and the bandwidth rates for the TCs.
This is achieved by setting the value 2 for the "hw" option.
This new offload mode supports new attributes for traffic
class such as minimum and maximum values for bandwidth rate limits.

Introduces a new datastructure 'tc_mqprio_qopt_offload' for offloading
mqprio queue options and use this to be shared between the kernel and
device driver. This contains a copy of the exisiting datastructure
for mqprio queue options. This new datastructure can be extended when
adding new attributes for traffic class such as bandwidth rate limits. The
existing datastructure for mqprio queue options will be shared between the
kernel and userspace.

This patch enables configuring additional attributes associated
with a traffic class such as minimum and maximum bandwidth
rates and can be offloaded to the hardware in the new offload mode.
The min and max limits for bandwidth rates are provided
by the user along with the the TCs and the queue configurations
when creating the mqprio qdisc.

Example:
# tc qdisc add dev eth0 root mqprio num_tc 2 map 0 0 0 0 1 1 1 1\
  queues 4@0 4@4 min_rate 0Mbit 0Mbit max_rate 55Mbit 60Mbit hw 2

To dump the bandwidth rates:

# tc qdisc show dev eth0

qdisc mqprio 804a: root  tc 2 map 0 0 0 0 1 1 1 1 0 0 0 0 0 0 0 0
             queues:(0:3) (4:7)
             min rates:0bit 0bit
             max rates:55Mbit 60Mbit

Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
---
 include/linux/netdevice.h      |    2 
 include/net/pkt_cls.h          |    7 ++
 include/uapi/linux/pkt_sched.h |   13 +++
 net/sched/sch_mqprio.c         |  170 +++++++++++++++++++++++++++++++++++++---
 4 files changed, 181 insertions(+), 11 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e48ee2e..12c6c3f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -779,6 +779,7 @@ enum {
 	TC_SETUP_CLSFLOWER,
 	TC_SETUP_MATCHALL,
 	TC_SETUP_CLSBPF,
+	TC_SETUP_MQPRIO_EXT,
 };
 
 struct tc_cls_u32_offload;
@@ -791,6 +792,7 @@ struct tc_to_netdev {
 		struct tc_cls_matchall_offload *cls_mall;
 		struct tc_cls_bpf_offload *cls_bpf;
 		struct tc_mqprio_qopt *mqprio;
+		struct tc_mqprio_qopt_offload *mqprio_qopt;
 	};
 	bool egress_dev;
 };
diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 537d0a0..9facda2 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -569,6 +569,13 @@ struct tc_cls_bpf_offload {
 	u32 gen_flags;
 };
 
+struct tc_mqprio_qopt_offload {
+	/* struct tc_mqprio_qopt must always be the first element */
+	struct tc_mqprio_qopt qopt;
+	u32 flags;
+	u64 min_rate[TC_QOPT_MAX_QUEUE];
+	u64 max_rate[TC_QOPT_MAX_QUEUE];
+};
 
 /* This structure holds cookie structure that is passed from user
  * to the kernel for actions and classifiers
diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
index 099bf55..cf2a146 100644
--- a/include/uapi/linux/pkt_sched.h
+++ b/include/uapi/linux/pkt_sched.h
@@ -620,6 +620,7 @@ struct tc_drr_stats {
 enum {
 	TC_MQPRIO_HW_OFFLOAD_NONE,	/* no offload requested */
 	TC_MQPRIO_HW_OFFLOAD_TCS,	/* offload TCs, no queue counts */
+	TC_MQPRIO_HW_OFFLOAD,		/* fully supported offload */
 	__TC_MQPRIO_HW_OFFLOAD_MAX
 };
 
@@ -633,6 +634,18 @@ struct tc_mqprio_qopt {
 	__u16	offset[TC_QOPT_MAX_QUEUE];
 };
 
+#define TC_MQPRIO_F_MIN_RATE  0x1
+#define TC_MQPRIO_F_MAX_RATE  0x2
+
+enum {
+	TCA_MQPRIO_UNSPEC,
+	TCA_MQPRIO_MIN_RATE64,
+	TCA_MQPRIO_MAX_RATE64,
+	__TCA_MQPRIO_MAX,
+};
+
+#define TCA_MQPRIO_MAX (__TCA_MQPRIO_MAX - 1)
+
 /* SFB */
 
 enum {
diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index e0c0272..6524d12 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -18,10 +18,13 @@
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
 #include <net/sch_generic.h>
+#include <net/pkt_cls.h>
 
 struct mqprio_sched {
 	struct Qdisc		**qdiscs;
 	int hw_offload;
+	u32 flags;
+	u64 min_rate[TC_QOPT_MAX_QUEUE], max_rate[TC_QOPT_MAX_QUEUE];
 };
 
 static void mqprio_destroy(struct Qdisc *sch)
@@ -39,9 +42,21 @@ static void mqprio_destroy(struct Qdisc *sch)
 	}
 
 	if (priv->hw_offload && dev->netdev_ops->ndo_setup_tc) {
-		struct tc_mqprio_qopt offload = { 0 };
-		struct tc_to_netdev tc = { .type = TC_SETUP_MQPRIO,
-					   { .mqprio = &offload } };
+		struct tc_mqprio_qopt_offload offload = { { 0 } };
+		struct tc_to_netdev tc = { 0 };
+
+		switch (priv->hw_offload) {
+		case TC_MQPRIO_HW_OFFLOAD_TCS:
+			tc.type = TC_SETUP_MQPRIO;
+			tc.mqprio = &offload.qopt;
+			break;
+		case TC_MQPRIO_HW_OFFLOAD:
+			tc.type = TC_SETUP_MQPRIO_EXT;
+			tc.mqprio_qopt = &offload;
+			break;
+		default:
+			return;
+		}
 
 		dev->netdev_ops->ndo_setup_tc(dev, sch->handle, 0, 0, &tc);
 	} else {
@@ -99,6 +114,24 @@ static int mqprio_parse_opt(struct net_device *dev, struct tc_mqprio_qopt *qopt)
 	return 0;
 }
 
+static const struct nla_policy mqprio_policy[TCA_MQPRIO_MAX + 1] = {
+	[TCA_MQPRIO_MIN_RATE64] = { .type = NLA_NESTED },
+	[TCA_MQPRIO_MAX_RATE64] = { .type = NLA_NESTED },
+};
+
+static int parse_attr(struct nlattr *tb[], int maxtype, struct nlattr *nla,
+		      const struct nla_policy *policy, int len)
+{
+	int nested_len = nla_len(nla) - NLA_ALIGN(len);
+
+	if (nested_len >= nla_attr_size(0))
+		return nla_parse(tb, maxtype, nla_data(nla) + NLA_ALIGN(len),
+				 nested_len, policy, NULL);
+
+	memset(tb, 0, sizeof(struct nlattr *) * (maxtype + 1));
+	return 0;
+}
+
 static int mqprio_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct net_device *dev = qdisc_dev(sch);
@@ -107,6 +140,10 @@ static int mqprio_init(struct Qdisc *sch, struct nlattr *opt)
 	struct Qdisc *qdisc;
 	int i, err = -EOPNOTSUPP;
 	struct tc_mqprio_qopt *qopt = NULL;
+	struct nlattr *tb[TCA_MQPRIO_MAX + 1];
+	struct nlattr *attr;
+	int rem;
+	int len = nla_len(opt) - NLA_ALIGN(sizeof(*qopt));
 
 	BUILD_BUG_ON(TC_MAX_QUEUE != TC_QOPT_MAX_QUEUE);
 	BUILD_BUG_ON(TC_BITMASK != TC_QOPT_BITMASK);
@@ -124,6 +161,51 @@ static int mqprio_init(struct Qdisc *sch, struct nlattr *opt)
 	if (mqprio_parse_opt(dev, qopt))
 		return -EINVAL;
 
+	if (len > 0) {
+		err = parse_attr(tb, TCA_MQPRIO_MAX, opt, mqprio_policy,
+				 sizeof(*qopt));
+		if (err < 0)
+			return err;
+
+		if (tb[TCA_MQPRIO_MIN_RATE64]) {
+			if (qopt->hw != TC_MQPRIO_HW_OFFLOAD)
+				return -EINVAL;
+
+			i = 0;
+			nla_for_each_nested(attr, tb[TCA_MQPRIO_MIN_RATE64],
+					    rem) {
+				if (nla_type(attr) != TCA_MQPRIO_MIN_RATE64)
+					return -EINVAL;
+
+				if (i >= qopt->num_tc)
+					return -EINVAL;
+
+				priv->min_rate[i] = *(u64 *)nla_data(attr);
+				i++;
+			}
+			priv->flags |= TC_MQPRIO_F_MIN_RATE;
+		}
+
+		if (tb[TCA_MQPRIO_MAX_RATE64]) {
+			if (qopt->hw != TC_MQPRIO_HW_OFFLOAD)
+				return -EINVAL;
+
+			i = 0;
+			nla_for_each_nested(attr, tb[TCA_MQPRIO_MAX_RATE64],
+					    rem) {
+				if (nla_type(attr) != TCA_MQPRIO_MAX_RATE64)
+					return -EINVAL;
+
+				if (i >= qopt->num_tc)
+					return -EINVAL;
+
+				priv->max_rate[i] = *(u64 *)nla_data(attr);
+				i++;
+			}
+			priv->flags |= TC_MQPRIO_F_MAX_RATE;
+		}
+	}
+
 	/* pre-allocate qdisc, attachment can't fail */
 	priv->qdiscs = kcalloc(dev->num_tx_queues, sizeof(priv->qdiscs[0]),
 			       GFP_KERNEL);
@@ -148,16 +230,37 @@ static int mqprio_init(struct Qdisc *sch, struct nlattr *opt)
 	 * supplied and verified mapping
 	 */
 	if (qopt->hw) {
-		struct tc_mqprio_qopt offload = *qopt;
-		struct tc_to_netdev tc = { .type = TC_SETUP_MQPRIO,
-					   { .mqprio = &offload } };
+		struct tc_mqprio_qopt_offload offload = {.qopt = *qopt};
+		struct tc_to_netdev tc = { 0 };
+
+		switch (qopt->hw) {
+		case TC_MQPRIO_HW_OFFLOAD_TCS:
+			tc.type = TC_SETUP_MQPRIO;
+			tc.mqprio = &offload.qopt;
+			break;
+		case TC_MQPRIO_HW_OFFLOAD:
+			tc.type = TC_SETUP_MQPRIO_EXT;
+			tc.mqprio_qopt = &offload;
+
+			offload.flags = priv->flags;
+			if (priv->flags & TC_MQPRIO_F_MIN_RATE)
+				for (i = 0; i < offload.qopt.num_tc; i++)
+					offload.min_rate[i] = priv->min_rate[i];
+
+			if (priv->flags & TC_MQPRIO_F_MAX_RATE)
+				for (i = 0; i < offload.qopt.num_tc; i++)
+					offload.max_rate[i] = priv->max_rate[i];
+			break;
+		default:
+			return -EINVAL;
+		}
 
 		err = dev->netdev_ops->ndo_setup_tc(dev, sch->handle,
 						    0, 0, &tc);
 		if (err)
 			return err;
 
-		priv->hw_offload = offload.hw;
+		priv->hw_offload = offload.qopt.hw;
 	} else {
 		netdev_set_num_tc(dev, qopt->num_tc);
 		for (i = 0; i < qopt->num_tc; i++)
@@ -227,11 +330,51 @@ static int mqprio_graft(struct Qdisc *sch, unsigned long cl, struct Qdisc *new,
 	return 0;
 }
 
+static int dump_rates(struct mqprio_sched *priv,
+		      struct tc_mqprio_qopt *opt, struct sk_buff *skb)
+{
+	struct nlattr *nest;
+	int i;
+
+	if (priv->flags & TC_MQPRIO_F_MIN_RATE) {
+		nest = nla_nest_start(skb, TCA_MQPRIO_MIN_RATE64);
+		if (!nest)
+			goto nla_put_failure;
+
+		for (i = 0; i < opt->num_tc; i++) {
+			if (nla_put(skb, TCA_MQPRIO_MIN_RATE64,
+				    sizeof(priv->min_rate[i]),
+				    &priv->min_rate[i]))
+				goto nla_put_failure;
+		}
+		nla_nest_end(skb, nest);
+	}
+
+	if (priv->flags & TC_MQPRIO_F_MAX_RATE) {
+		nest = nla_nest_start(skb, TCA_MQPRIO_MAX_RATE64);
+		if (!nest)
+			goto nla_put_failure;
+
+		for (i = 0; i < opt->num_tc; i++) {
+			if (nla_put(skb, TCA_MQPRIO_MAX_RATE64,
+				    sizeof(priv->max_rate[i]),
+				    &priv->max_rate[i]))
+				goto nla_put_failure;
+		}
+		nla_nest_end(skb, nest);
+	}
+	return 0;
+
+nla_put_failure:
+	nla_nest_cancel(skb, nest);
+	return -1;
+}
+
 static int mqprio_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
 	struct net_device *dev = qdisc_dev(sch);
 	struct mqprio_sched *priv = qdisc_priv(sch);
-	unsigned char *b = skb_tail_pointer(skb);
+	struct nlattr *nla = (struct nlattr *)skb_tail_pointer(skb);
 	struct tc_mqprio_qopt opt = { 0 };
 	struct Qdisc *qdisc;
 	unsigned int i;
@@ -262,12 +405,17 @@ static int mqprio_dump(struct Qdisc *sch, struct sk_buff *skb)
 		opt.offset[i] = dev->tc_to_txq[i].offset;
 	}
 
-	if (nla_put(skb, TCA_OPTIONS, sizeof(opt), &opt))
+	if (nla_put(skb, TCA_OPTIONS, NLA_ALIGN(sizeof(opt)), &opt))
 		goto nla_put_failure;
 
-	return skb->len;
+	if (priv->flags & TC_MQPRIO_F_MIN_RATE ||
+	    priv->flags & TC_MQPRIO_F_MAX_RATE)
+		if (dump_rates(priv, &opt, skb) != 0)
+			goto nla_put_failure;
+
+	return nla_nest_end(skb, nla);
 nla_put_failure:
-	nlmsg_trim(skb, b);
+	nlmsg_trim(skb, nla);
 	return -1;
 }
 
