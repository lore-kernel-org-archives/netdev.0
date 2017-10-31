From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/9] net: sched: Identify hardware traffic classes using classid
Date: Tue, 31 Oct 2017 11:40:07 -0700
Message-ID: <20171031184012.29690-5-jeffrey.t.kirsher@intel.com>
References: <20171031184012.29690-1-jeffrey.t.kirsher@intel.com>
Cc: Amritha Nambiar <amritha.nambiar@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:21198 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932625AbdJaSkh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 14:40:37 -0400
In-Reply-To: <20171031184012.29690-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amritha Nambiar <amritha.nambiar@intel.com>

This patch offloads the classid to hardware and uses the classid
reserved in the range :ffe0 - :ffef to identify hardware traffic
classes reported via dev->num_tc.

tcf_result structure contains the class ID of the class to which
the packet belongs and is offloaded to hardware via flower filter.
A new helper function is introduced to represent HW traffic
classes 0 through 15 using the reserved classid values :ffe0 - :ffef.

Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
Acked-by: Shannon Nelson <shannon.nelson@oracle.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 include/net/pkt_cls.h     | 1 +
 include/net/sch_generic.h | 7 +++++++
 net/sched/cls_flower.c    | 2 ++
 3 files changed, 10 insertions(+)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index bf73e1675519..37c5ef766655 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -666,6 +666,7 @@ struct tc_cls_flower_offload {
 	struct fl_flow_key *mask;
 	struct fl_flow_key *key;
 	struct tcf_exts *exts;
+	u32 classid;
 };
 
 enum tc_matchall_command {
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 07c179dab478..c23e938f5b19 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -411,6 +411,13 @@ qdisc_class_find(const struct Qdisc_class_hash *hash, u32 id)
 	return NULL;
 }
 
+static inline int tc_classid_to_hwtc(struct net_device *dev, u32 classid)
+{
+	u32 hwtc = TC_H_MIN(classid) - TC_H_MIN_PRIORITY;
+
+	return (hwtc < netdev_get_num_tc(dev)) ? hwtc : -EINVAL;
+}
+
 int qdisc_class_hash_init(struct Qdisc_class_hash *);
 void qdisc_class_hash_insert(struct Qdisc_class_hash *,
 			     struct Qdisc_class_common *);
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 35cb6d684e44..c99fa9e5be46 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -241,6 +241,7 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
 	cls_flower.mask = mask;
 	cls_flower.key = &f->mkey;
 	cls_flower.exts = &f->exts;
+	cls_flower.classid = f->res.classid;
 
 	err = tc_setup_cb_call(block, &f->exts, TC_SETUP_CLSFLOWER,
 			       &cls_flower, skip_sw);
@@ -266,6 +267,7 @@ static void fl_hw_update_stats(struct tcf_proto *tp, struct cls_fl_filter *f)
 	cls_flower.command = TC_CLSFLOWER_STATS;
 	cls_flower.cookie = (unsigned long) f;
 	cls_flower.exts = &f->exts;
+	cls_flower.classid = f->res.classid;
 
 	tc_setup_cb_call(block, &f->exts, TC_SETUP_CLSFLOWER,
 			 &cls_flower, false);
-- 
2.14.2
