From: Amritha Nambiar <amritha.nambiar@intel.com>
Subject: [jkirsher/next-queue PATCH v5 1/6] net: sched: Identify hardware
 traffic classes using classid
Date: Fri, 27 Oct 2017 02:35:34 -0700
Message-ID: <150909693494.48377.7265505471193257120.stgit@anamdev.jf.intel.com>
References: <150909628755.48377.16561267691881106259.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, jiri@resnulli.us,
        amritha.nambiar@intel.com, netdev@vger.kernel.org,
        jhs@mojatatu.com, alexander.duyck@gmail.com,
        shannon.nelson@oracle.com, xiyou.wangcong@gmail.com
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:42338 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752103AbdJ0JhM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 27 Oct 2017 05:37:12 -0400
In-Reply-To: <150909628755.48377.16561267691881106259.stgit@anamdev.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch offloads the classid to hardware and uses the classid
reserved in the range :ffe0 - :ffef to identify hardware traffic
classes reported via dev->num_tc.

tcf_result structure contains the class ID of the class to which
the packet belongs and is offloaded to hardware via flower filter.
A new helper function is introduced to represent HW traffic
classes 0 through 15 using the reserved classid values :ffe0 - :ffef.

v5: Added helper function to get HW TC values from classid.

Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
---
 include/net/pkt_cls.h     |    1 +
 include/net/sch_generic.h |    7 +++++++
 net/sched/cls_flower.c    |    2 ++
 3 files changed, 10 insertions(+)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 04caa24..45c958f 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -664,6 +664,7 @@ struct tc_cls_flower_offload {
 	struct fl_flow_key *mask;
 	struct fl_flow_key *key;
 	struct tcf_exts *exts;
+	u32 classid;
 };
 
 enum tc_matchall_command {
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 031dffd..c79d9aa 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -409,6 +409,13 @@ qdisc_class_find(const struct Qdisc_class_hash *hash, u32 id)
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
index 16f58ab..addbc31 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -227,6 +227,7 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
 	cls_flower.mask = mask;
 	cls_flower.key = &f->mkey;
 	cls_flower.exts = &f->exts;
+	cls_flower.classid = f->res.classid;
 
 	err = tc_setup_cb_call(block, &f->exts, TC_SETUP_CLSFLOWER,
 			       &cls_flower, skip_sw);
@@ -252,6 +253,7 @@ static void fl_hw_update_stats(struct tcf_proto *tp, struct cls_fl_filter *f)
 	cls_flower.command = TC_CLSFLOWER_STATS;
 	cls_flower.cookie = (unsigned long) f;
 	cls_flower.exts = &f->exts;
+	cls_flower.classid = f->res.classid;
 
 	tc_setup_cb_call(block, &f->exts, TC_SETUP_CLSFLOWER,
 			 &cls_flower, false);
