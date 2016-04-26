From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 5/8] ovs: align nlattr properly when needed
Date: Tue, 26 Apr 2016 10:06:15 +0200
Message-ID: <1461657978-13360-6-git-send-email-nicolas.dichtel@6wind.com>
References: <1461657978-13360-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, sd@queasysnail.net, johannes@sipsolutions.net,
	kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
	jack@suse.com, linux-kernel@vger.kernel.org, pshelar@nicira.com,
	dev@openvswitch.org, jhs@mojatatu.com, philipp.reisner@linbit.com,
	lars.ellenberg@linbit.com, drbd-dev@lists.linbit.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:55819 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752226AbcDZIGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 04:06:48 -0400
In-Reply-To: <1461657978-13360-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I also fix commit 8b32ab9e6ef1: use nla_total_size_64bit() for
OVS_FLOW_ATTR_USED in ovs_flow_cmd_msg_size().

Fixes: 8b32ab9e6ef1 ("ovs: use nla_put_u64_64bit()")
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/openvswitch.h |  2 ++
 net/openvswitch/datapath.c       | 27 +++++++++++++++------------
 2 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index d6be1fb778a5..bb0d515b7654 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -84,6 +84,7 @@ enum ovs_datapath_attr {
 	OVS_DP_ATTR_STATS,		/* struct ovs_dp_stats */
 	OVS_DP_ATTR_MEGAFLOW_STATS,	/* struct ovs_dp_megaflow_stats */
 	OVS_DP_ATTR_USER_FEATURES,	/* OVS_DP_F_*  */
+	OVS_DP_ATTR_PAD,
 	__OVS_DP_ATTR_MAX
 };
 
@@ -253,6 +254,7 @@ enum ovs_vport_attr {
 	OVS_VPORT_ATTR_UPCALL_PID, /* array of u32 Netlink socket PIDs for */
 				/* receiving upcalls */
 	OVS_VPORT_ATTR_STATS,	/* struct ovs_vport_stats */
+	OVS_VPORT_ATTR_PAD,
 	__OVS_VPORT_ATTR_MAX
 };
 
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 22d9a5316304..856bd8dba676 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -738,9 +738,9 @@ static size_t ovs_flow_cmd_msg_size(const struct sw_flow_actions *acts,
 		len += nla_total_size(acts->orig_len);
 
 	return len
-		+ nla_total_size(sizeof(struct ovs_flow_stats)) /* OVS_FLOW_ATTR_STATS */
+		+ nla_total_size_64bit(sizeof(struct ovs_flow_stats)) /* OVS_FLOW_ATTR_STATS */
 		+ nla_total_size(1) /* OVS_FLOW_ATTR_TCP_FLAGS */
-		+ nla_total_size(8); /* OVS_FLOW_ATTR_USED */
+		+ nla_total_size_64bit(8); /* OVS_FLOW_ATTR_USED */
 }
 
 /* Called with ovs_mutex or RCU read lock. */
@@ -759,7 +759,9 @@ static int ovs_flow_cmd_fill_stats(const struct sw_flow *flow,
 		return -EMSGSIZE;
 
 	if (stats.n_packets &&
-	    nla_put(skb, OVS_FLOW_ATTR_STATS, sizeof(struct ovs_flow_stats), &stats))
+	    nla_put_64bit(skb, OVS_FLOW_ATTR_STATS,
+			  sizeof(struct ovs_flow_stats), &stats,
+			  OVS_FLOW_ATTR_PAD))
 		return -EMSGSIZE;
 
 	if ((u8)ntohs(tcp_flags) &&
@@ -1435,8 +1437,8 @@ static size_t ovs_dp_cmd_msg_size(void)
 	size_t msgsize = NLMSG_ALIGN(sizeof(struct ovs_header));
 
 	msgsize += nla_total_size(IFNAMSIZ);
-	msgsize += nla_total_size(sizeof(struct ovs_dp_stats));
-	msgsize += nla_total_size(sizeof(struct ovs_dp_megaflow_stats));
+	msgsize += nla_total_size_64bit(sizeof(struct ovs_dp_stats));
+	msgsize += nla_total_size_64bit(sizeof(struct ovs_dp_megaflow_stats));
 	msgsize += nla_total_size(sizeof(u32)); /* OVS_DP_ATTR_USER_FEATURES */
 
 	return msgsize;
@@ -1463,13 +1465,13 @@ static int ovs_dp_cmd_fill_info(struct datapath *dp, struct sk_buff *skb,
 		goto nla_put_failure;
 
 	get_dp_stats(dp, &dp_stats, &dp_megaflow_stats);
-	if (nla_put(skb, OVS_DP_ATTR_STATS, sizeof(struct ovs_dp_stats),
-			&dp_stats))
+	if (nla_put_64bit(skb, OVS_DP_ATTR_STATS, sizeof(struct ovs_dp_stats),
+			  &dp_stats, OVS_DP_ATTR_PAD))
 		goto nla_put_failure;
 
-	if (nla_put(skb, OVS_DP_ATTR_MEGAFLOW_STATS,
-			sizeof(struct ovs_dp_megaflow_stats),
-			&dp_megaflow_stats))
+	if (nla_put_64bit(skb, OVS_DP_ATTR_MEGAFLOW_STATS,
+			  sizeof(struct ovs_dp_megaflow_stats),
+			  &dp_megaflow_stats, OVS_DP_ATTR_PAD))
 		goto nla_put_failure;
 
 	if (nla_put_u32(skb, OVS_DP_ATTR_USER_FEATURES, dp->user_features))
@@ -1838,8 +1840,9 @@ static int ovs_vport_cmd_fill_info(struct vport *vport, struct sk_buff *skb,
 		goto nla_put_failure;
 
 	ovs_vport_get_stats(vport, &vport_stats);
-	if (nla_put(skb, OVS_VPORT_ATTR_STATS, sizeof(struct ovs_vport_stats),
-		    &vport_stats))
+	if (nla_put_64bit(skb, OVS_VPORT_ATTR_STATS,
+			  sizeof(struct ovs_vport_stats), &vport_stats,
+			  OVS_VPORT_ATTR_PAD))
 		goto nla_put_failure;
 
 	if (ovs_vport_get_upcall_portids(vport, skb))
-- 
2.8.1
