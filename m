From: Samuel Gauthier <samuel.gauthier@6wind.com>
Subject: [PATCH net-next 2/2] ovs: support to refresh a flow via netlink
Date: Wed, 16 Mar 2016 16:07:52 +0100
Message-ID: <1458140872-22438-3-git-send-email-samuel.gauthier@6wind.com>
References: <1458140872-22438-1-git-send-email-samuel.gauthier@6wind.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Samuel Gauthier <samuel.gauthier@6wind.com>
To: Pravin Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:38666 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932331AbcCPPIm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 11:08:42 -0400
In-Reply-To: <1458140872-22438-1-git-send-email-samuel.gauthier@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The used parameter of a flow tells us when it was used for the last
time. It is possible to set this parameter to 0 using the
OVS_FLOW_ATTR_CLEAR attribute, which means 'never used'. But it is not
possible to set this parameter to 'now'.

With this commit, adding OVS_FLOW_ATTR_USED to a 'set flow' netlink
message refreshes the flow used time to the current time. The value in
OVS_FLOW_ATTR_USED attribute is not used in this case.

Signed-off-by: Samuel Gauthier <samuel.gauthier@6wind.com>
---
 net/openvswitch/datapath.c | 2 ++
 net/openvswitch/flow.c     | 6 ++++++
 net/openvswitch/flow.h     | 1 +
 3 files changed, 9 insertions(+)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 8c6dcffe9b62..f2050af3965a 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1183,6 +1183,8 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	/* Clear stats. */
 	if (a[OVS_FLOW_ATTR_CLEAR])
 		ovs_flow_stats_clear(flow);
+	if (a[OVS_FLOW_ATTR_USED])
+		ovs_flow_refresh(flow);
 	ovs_unlock();
 
 	if (reply)
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 831db351fef9..602795dd3656 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -167,6 +167,12 @@ void ovs_flow_stats_get(const struct sw_flow *flow,
 	}
 }
 
+/* Must be called with rcu_read_lock or ovs_mutex. */
+void ovs_flow_refresh(struct sw_flow *flow)
+{
+	ovs_flow_stats_update(flow, 0, 0, 0);
+}
+
 /* Called with ovs_mutex. */
 void ovs_flow_stats_clear(struct sw_flow *flow)
 {
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 51e10c4b1ce6..4b6b64c999ed 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -214,6 +214,7 @@ void ovs_flow_stats_update_skb(struct sw_flow *, __be16 tcp_flags,
 			       const struct sk_buff *);
 void ovs_flow_stats_get(const struct sw_flow *, struct ovs_flow_stats *,
 			unsigned long *used, __be16 *tcp_flags);
+void ovs_flow_refresh(struct sw_flow *);
 void ovs_flow_stats_clear(struct sw_flow *);
 u64 ovs_flow_used_time(unsigned long flow_jiffies);
 
-- 
2.2.1.62.g3f15098
