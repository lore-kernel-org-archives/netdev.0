From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: [net-next PATCH 1/2] mqprio: Change handling of hw u8 to allow for
 multiple hardware offload modes
Date: Wed, 15 Mar 2017 10:39:18 -0700
Message-ID: <20170315173918.16349.55189.stgit@localhost.localdomain>
References: <20170315172929.16349.95037.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: thomas.lendacky@amd.com, bkenward@solarflare.com,
        amritha.nambiar@intel.com, madalin.bucur@nxp.com, w-kwok2@ti.com,
        saeedm@mellanox.com, ariel.elior@cavium.com, m-karicheri2@ti.com,
        jeffrey.t.kirsher@intel.com, Yuval.Mintz@cavium.com,
        ecree@solarflare.com, michael.chan@broadcom.com,
        tariqt@mellanox.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34870 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751014AbdCORsV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 13:48:21 -0400
Received: by mail-pg0-f65.google.com with SMTP id g2so3002212pge.2
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 10:47:21 -0700 (PDT)
In-Reply-To: <20170315172929.16349.95037.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch is meant to allow for support of multiple hardware offload type
for a single device. There is currently no bounds checking for the hw
member of the mqprio_qopt structure.  This results in us being able to pass
values from 1 to 255 with all being treated the same.  On retreiving the
value it is returned as 1 for anything 1 or greater being set.

With this change we are currently adding limited bounds checking by
defining an enum and using those values to limit the reported hardware
offloads.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 include/uapi/linux/pkt_sched.h |    8 ++++++++
 net/sched/sch_mqprio.c         |   26 ++++++++++++++++----------
 2 files changed, 24 insertions(+), 10 deletions(-)

diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
index df7451d35131..099bf5528fed 100644
--- a/include/uapi/linux/pkt_sched.h
+++ b/include/uapi/linux/pkt_sched.h
@@ -617,6 +617,14 @@ struct tc_drr_stats {
 #define TC_QOPT_BITMASK 15
 #define TC_QOPT_MAX_QUEUE 16
 
+enum {
+	TC_MQPRIO_HW_OFFLOAD_NONE,	/* no offload requested */
+	TC_MQPRIO_HW_OFFLOAD_TCS,	/* offload TCs, no queue counts */
+	__TC_MQPRIO_HW_OFFLOAD_MAX
+};
+
+#define TC_MQPRIO_HW_OFFLOAD_MAX (__TC_MQPRIO_HW_OFFLOAD_MAX - 1)
+
 struct tc_mqprio_qopt {
 	__u8	num_tc;
 	__u8	prio_tc_map[TC_QOPT_BITMASK + 1];
diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
index b851e209da4d..5f55bf149d9f 100644
--- a/net/sched/sch_mqprio.c
+++ b/net/sched/sch_mqprio.c
@@ -21,7 +21,7 @@
 
 struct mqprio_sched {
 	struct Qdisc		**qdiscs;
-	int hw_owned;
+	int hw_offload;
 };
 
 static void mqprio_destroy(struct Qdisc *sch)
@@ -39,7 +39,7 @@ static void mqprio_destroy(struct Qdisc *sch)
 		kfree(priv->qdiscs);
 	}
 
-	if (priv->hw_owned && dev->netdev_ops->ndo_setup_tc)
+	if (priv->hw_offload && dev->netdev_ops->ndo_setup_tc)
 		dev->netdev_ops->ndo_setup_tc(dev, sch->handle, 0, &tc);
 	else
 		netdev_set_num_tc(dev, 0);
@@ -59,15 +59,20 @@ static int mqprio_parse_opt(struct net_device *dev, struct tc_mqprio_qopt *qopt)
 			return -EINVAL;
 	}
 
-	/* net_device does not support requested operation */
-	if (qopt->hw && !dev->netdev_ops->ndo_setup_tc)
-		return -EINVAL;
+	/* Limit qopt->hw to maximum supported offload value.  Drivers have
+	 * the option of overriding this later if they don't support the a
+	 * given offload type.
+	 */
+	if (qopt->hw > TC_MQPRIO_HW_OFFLOAD_MAX)
+		qopt->hw = TC_MQPRIO_HW_OFFLOAD_MAX;
 
-	/* if hw owned qcount and qoffset are taken from LLD so
-	 * no reason to verify them here
+	/* If hardware offload is requested we will leave it to the device
+	 * to either populate the queue counts itself or to validate the
+	 * provided queue counts.  If ndo_setup_tc is not present then
+	 * hardware doesn't support offload and we should return an error.
 	 */
 	if (qopt->hw)
-		return 0;
+		return dev->netdev_ops->ndo_setup_tc ? 0 : -EINVAL;
 
 	for (i = 0; i < qopt->num_tc; i++) {
 		unsigned int last = qopt->offset[i] + qopt->count[i];
@@ -142,10 +147,11 @@ static int mqprio_init(struct Qdisc *sch, struct nlattr *opt)
 		struct tc_to_netdev tc = {.type = TC_SETUP_MQPRIO,
 					  { .tc = qopt->num_tc }};
 
-		priv->hw_owned = 1;
 		err = dev->netdev_ops->ndo_setup_tc(dev, sch->handle, 0, &tc);
 		if (err)
 			return err;
+
+		priv->hw_offload = qopt->hw;
 	} else {
 		netdev_set_num_tc(dev, qopt->num_tc);
 		for (i = 0; i < qopt->num_tc; i++)
@@ -243,7 +249,7 @@ static int mqprio_dump(struct Qdisc *sch, struct sk_buff *skb)
 
 	opt.num_tc = netdev_get_num_tc(dev);
 	memcpy(opt.prio_tc_map, dev->prio_tc_map, sizeof(opt.prio_tc_map));
-	opt.hw = priv->hw_owned;
+	opt.hw = priv->hw_offload;
 
 	for (i = 0; i < netdev_get_num_tc(dev); i++) {
 		opt.count[i] = dev->tc_to_txq[i].count;
