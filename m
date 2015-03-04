From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 1/3] net/dcb: Add IEEE QCN attribute
Date: Wed,  4 Mar 2015 14:51:06 +0200
Message-ID: <1425473468-25969-2-git-send-email-ogerlitz@mellanox.com>
References: <1425473468-25969-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:53511 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758974AbbCDMv3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Mar 2015 07:51:29 -0500
In-Reply-To: <1425473468-25969-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shani Michaeli <shanim@mellanox.com>

As specified in 802.1Qau spec. Add this optional attribute to the
DCB netlink layer. To allow for application to use the new attribute,
NIC drivers should implement and register the  callbacks ieee_getqcn,
ieee_setqcn and ieee_getqcnstats.

The QCN attribute holds a set of parameters for management, and
a set of statistics to provide informative data on Congestion-Control
defined by this spec.

Signed-off-by: Shani Michaeli <shanim@mellanox.com>
Signed-off-by: Shachar Raindel <raindel@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 include/net/dcbnl.h        |    3 ++
 include/uapi/linux/dcbnl.h |   66 ++++++++++++++++++++++++++++++++++++++++++++
 net/dcb/dcbnl.c            |   41 +++++++++++++++++++++++++--
 3 files changed, 107 insertions(+), 3 deletions(-)

diff --git a/include/net/dcbnl.h b/include/net/dcbnl.h
index 597b88a..207d9ba 100644
--- a/include/net/dcbnl.h
+++ b/include/net/dcbnl.h
@@ -49,6 +49,9 @@ struct dcbnl_rtnl_ops {
 	int (*ieee_setets) (struct net_device *, struct ieee_ets *);
 	int (*ieee_getmaxrate) (struct net_device *, struct ieee_maxrate *);
 	int (*ieee_setmaxrate) (struct net_device *, struct ieee_maxrate *);
+	int (*ieee_getqcn) (struct net_device *, struct ieee_qcn *);
+	int (*ieee_setqcn) (struct net_device *, struct ieee_qcn *);
+	int (*ieee_getqcnstats) (struct net_device *, struct ieee_qcn_stats *);
 	int (*ieee_getpfc) (struct net_device *, struct ieee_pfc *);
 	int (*ieee_setpfc) (struct net_device *, struct ieee_pfc *);
 	int (*ieee_getapp) (struct net_device *, struct dcb_app *);
diff --git a/include/uapi/linux/dcbnl.h b/include/uapi/linux/dcbnl.h
index e711f20..6497d79 100644
--- a/include/uapi/linux/dcbnl.h
+++ b/include/uapi/linux/dcbnl.h
@@ -78,6 +78,70 @@ struct ieee_maxrate {
 	__u64	tc_maxrate[IEEE_8021QAZ_MAX_TCS];
 };
 
+enum dcbnl_cndd_states {
+	DCB_CNDD_RESET = 0,
+	DCB_CNDD_EDGE,
+	DCB_CNDD_INTERIOR,
+	DCB_CNDD_INTERIOR_READY,
+};
+
+/* This structure contains the IEEE 802.1Qau QCN managed object.
+ *
+ *@rpg_enable: enable QCN RP
+ *@rppp_max_rps: maximum number of RPs allowed for this CNPV on this port
+ *@rpg_time_reset: time between rate increases if no CNMs received.
+ *		   given in u-seconds
+ *@rpg_byte_reset: transmitted data between rate increases if no CNMs received.
+ *		   given in Bytes
+ *@rpg_threshold: The number of times rpByteStage or rpTimeStage can count
+ *		   before RP rate control state machine advances states
+ *@rpg_max_rate: the maxinun rate, in Mbits per second,
+ *		 at which an RP can transmit
+ *@rpg_ai_rate: The rate, in Mbits per second,
+ *		used to increase rpTargetRate in the RPR_ACTIVE_INCREASE
+ *@rpg_hai_rate: The rate, in Mbits per second,
+ *		 used to increase rpTargetRate in the RPR_HYPER_INCREASE state
+ *@rpg_gd: Upon CNM receive, flow rate is limited to (Fb/Gd)*CurrentRate.
+ *	   rpgGd is given as log2(Gd), where Gd may only be powers of 2
+ *@rpg_min_dec_fac: The minimum factor by which the current transmit rate
+ *		    can be changed by reception of a CNM.
+ *		    value is given as percentage (1-100)
+ *@rpg_min_rate: The minimum value, in bits per second, for rate to limit
+ *@cndd_state_machine: The state of the congestion notification domain
+ *		       defense state machine, as defined by IEEE 802.3Qau
+ *		       section 32.1.1. In the interior ready state,
+ *		       the QCN capable hardware may add CN-TAG TLV to the
+ *		       outgoing traffic, to specifically identify outgoing
+ *		       flows.
+ */
+
+struct ieee_qcn {
+	__u8 rpg_enable[IEEE_8021QAZ_MAX_TCS];
+	__u32 rppp_max_rps[IEEE_8021QAZ_MAX_TCS];
+	__u32 rpg_time_reset[IEEE_8021QAZ_MAX_TCS];
+	__u32 rpg_byte_reset[IEEE_8021QAZ_MAX_TCS];
+	__u32 rpg_threshold[IEEE_8021QAZ_MAX_TCS];
+	__u32 rpg_max_rate[IEEE_8021QAZ_MAX_TCS];
+	__u32 rpg_ai_rate[IEEE_8021QAZ_MAX_TCS];
+	__u32 rpg_hai_rate[IEEE_8021QAZ_MAX_TCS];
+	__u32 rpg_gd[IEEE_8021QAZ_MAX_TCS];
+	__u32 rpg_min_dec_fac[IEEE_8021QAZ_MAX_TCS];
+	__u32 rpg_min_rate[IEEE_8021QAZ_MAX_TCS];
+	__u32 cndd_state_machine[IEEE_8021QAZ_MAX_TCS];
+};
+
+/* This structure contains the IEEE 802.1Qau QCN statistics.
+ *
+ *@rppp_rp_centiseconds: the number of RP-centiseconds accumulated
+ *			 by RPs at this priority level on this Port
+ *@rppp_created_rps: number of active RPs(flows) that react to CNMs
+ */
+
+struct ieee_qcn_stats {
+	__u64 rppp_rp_centiseconds[IEEE_8021QAZ_MAX_TCS];
+	__u32 rppp_created_rps[IEEE_8021QAZ_MAX_TCS];
+};
+
 /* This structure contains the IEEE 802.1Qaz PFC managed object
  *
  * @pfc_cap: Indicates the number of traffic classes on the local device
@@ -334,6 +398,8 @@ enum ieee_attrs {
 	DCB_ATTR_IEEE_PEER_PFC,
 	DCB_ATTR_IEEE_PEER_APP,
 	DCB_ATTR_IEEE_MAXRATE,
+	DCB_ATTR_IEEE_QCN,
+	DCB_ATTR_IEEE_QCN_STATS,
 	__DCB_ATTR_IEEE_MAX
 };
 #define DCB_ATTR_IEEE_MAX (__DCB_ATTR_IEEE_MAX - 1)
diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 93ea801..6fce458 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -177,6 +177,8 @@ static const struct nla_policy dcbnl_ieee_policy[DCB_ATTR_IEEE_MAX + 1] = {
 	[DCB_ATTR_IEEE_PFC]	    = {.len = sizeof(struct ieee_pfc)},
 	[DCB_ATTR_IEEE_APP_TABLE]   = {.type = NLA_NESTED},
 	[DCB_ATTR_IEEE_MAXRATE]   = {.len = sizeof(struct ieee_maxrate)},
+	[DCB_ATTR_IEEE_QCN]         = {.len = sizeof(struct ieee_qcn)},
+	[DCB_ATTR_IEEE_QCN_STATS]   = {.len = sizeof(struct ieee_qcn_stats)},
 };
 
 static const struct nla_policy dcbnl_ieee_app[DCB_ATTR_IEEE_APP_MAX + 1] = {
@@ -1030,7 +1032,7 @@ nla_put_failure:
 	return err;
 }
 
-/* Handle IEEE 802.1Qaz GET commands. */
+/* Handle IEEE 802.1Qaz/802.1Qau/802.1Qbb GET commands. */
 static int dcbnl_ieee_fill(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct nlattr *ieee, *app;
@@ -1067,6 +1069,30 @@ static int dcbnl_ieee_fill(struct sk_buff *skb, struct net_device *netdev)
 		}
 	}
 
+	if (ops->ieee_getqcn) {
+		struct ieee_qcn qcn;
+		memset(&qcn, 0, sizeof(qcn));
+		err = ops->ieee_getqcn(netdev, &qcn);
+		if (!err) {
+			err = nla_put(skb, DCB_ATTR_IEEE_QCN,
+				      sizeof(qcn), &qcn);
+			if (err)
+				return -EMSGSIZE;
+		}
+	}
+
+	if (ops->ieee_getqcnstats) {
+		struct ieee_qcn_stats qcn_stats;
+		memset(&qcn_stats, 0, sizeof(qcn_stats));
+		err = ops->ieee_getqcnstats(netdev, &qcn_stats);
+		if (!err) {
+			err = nla_put(skb, DCB_ATTR_IEEE_QCN_STATS,
+				      sizeof(qcn_stats), &qcn_stats);
+			if (err)
+				return -EMSGSIZE;
+		}
+	}
+
 	if (ops->ieee_getpfc) {
 		struct ieee_pfc pfc;
 		memset(&pfc, 0, sizeof(pfc));
@@ -1379,8 +1405,9 @@ int dcbnl_cee_notify(struct net_device *dev, int event, int cmd,
 }
 EXPORT_SYMBOL(dcbnl_cee_notify);
 
-/* Handle IEEE 802.1Qaz SET commands. If any requested operation can not
- * be completed the entire msg is aborted and error value is returned.
+/* Handle IEEE 802.1Qaz/802.1Qau/802.1Qbb SET commands.
+ * If any requested operation can not be completed
+ * the entire msg is aborted and error value is returned.
  * No attempt is made to reconcile the case where only part of the
  * cmd can be completed.
  */
@@ -1417,6 +1444,14 @@ static int dcbnl_ieee_set(struct net_device *netdev, struct nlmsghdr *nlh,
 			goto err;
 	}
 
+	if (ieee[DCB_ATTR_IEEE_QCN] && ops->ieee_setqcn) {
+		struct ieee_qcn *qcn =
+			nla_data(ieee[DCB_ATTR_IEEE_QCN]);
+		err = ops->ieee_setqcn(netdev, qcn);
+		if (err)
+			goto err;
+	}
+
 	if (ieee[DCB_ATTR_IEEE_PFC] && ops->ieee_setpfc) {
 		struct ieee_pfc *pfc = nla_data(ieee[DCB_ATTR_IEEE_PFC]);
 		err = ops->ieee_setpfc(netdev, pfc);
-- 
1.7.1
