From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 2/4] openvswitch: Simplify interface ovs_flow_metadata_from_nlattrs()
Date: Thu, 13 Jun 2013 11:11:32 -0700
Message-ID: <1371147092-29217-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog133.obsmtp.com ([74.125.149.82]:37612 "HELO
	na3sys009aog133.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756839Ab3FMSLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 14:11:36 -0400
Received: by mail-pd0-f177.google.com with SMTP id p10so6034306pdj.22
        for <netdev@vger.kernel.org>; Thu, 13 Jun 2013 11:11:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is not functional change, this is just code cleanup.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
v2:
remove key_len.
---
 net/openvswitch/datapath.c |    5 +----
 net/openvswitch/flow.c     |   22 ++++++++++------------
 net/openvswitch/flow.h     |    4 ++--
 3 files changed, 13 insertions(+), 18 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index d12d6b8..38d221d 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -739,10 +739,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	if (err)
 		goto err_flow_free;
 
-	err = ovs_flow_metadata_from_nlattrs(&flow->key.phy.priority,
-					     &flow->key.phy.skb_mark,
-					     &flow->key.phy.in_port,
-					     a[OVS_PACKET_ATTR_KEY]);
+	err = ovs_flow_metadata_from_nlattrs(flow, a[OVS_PACKET_ATTR_KEY]);
 	if (err)
 		goto err_flow_free;
 
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index b15321a..efa53e3 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -1122,10 +1122,8 @@ int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
 
 /**
  * ovs_flow_metadata_from_nlattrs - parses Netlink attributes into a flow key.
- * @priority: receives the skb priority
- * @mark: receives the skb mark
- * @in_port: receives the extracted input port.
- * @key: Netlink attribute holding nested %OVS_KEY_ATTR_* Netlink attribute
+ * @flow: Receives extracted in_port, priority, tun_key and skb_mark.
+ * @attr: Netlink attribute holding nested %OVS_KEY_ATTR_* Netlink attribute
  * sequence.
  *
  * This parses a series of Netlink attributes that form a flow key, which must
@@ -1133,15 +1131,15 @@ int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
  * get the metadata, that is, the parts of the flow key that cannot be
  * extracted from the packet itself.
  */
-int ovs_flow_metadata_from_nlattrs(u32 *priority, u32 *mark, u16 *in_port,
-			       const struct nlattr *attr)
+int ovs_flow_metadata_from_nlattrs(struct sw_flow *flow,
+				   const struct nlattr *attr)
 {
 	const struct nlattr *nla;
 	int rem;
 
-	*in_port = DP_MAX_PORTS;
-	*priority = 0;
-	*mark = 0;
+	flow->key.phy.in_port = DP_MAX_PORTS;
+	flow->key.phy.priority = 0;
+	flow->key.phy.skb_mark = 0;
 
 	nla_for_each_nested(nla, attr, rem) {
 		int type = nla_type(nla);
@@ -1152,17 +1150,17 @@ int ovs_flow_metadata_from_nlattrs(u32 *priority, u32 *mark, u16 *in_port,
 
 			switch (type) {
 			case OVS_KEY_ATTR_PRIORITY:
-				*priority = nla_get_u32(nla);
+				flow->key.phy.priority = nla_get_u32(nla);
 				break;
 
 			case OVS_KEY_ATTR_IN_PORT:
 				if (nla_get_u32(nla) >= DP_MAX_PORTS)
 					return -EINVAL;
-				*in_port = nla_get_u32(nla);
+				flow->key.phy.in_port = nla_get_u32(nla);
 				break;
 
 			case OVS_KEY_ATTR_SKB_MARK:
-				*mark = nla_get_u32(nla);
+				flow->key.phy.skb_mark = nla_get_u32(nla);
 				break;
 			}
 		}
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 0875fde..2a83e21 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -141,8 +141,8 @@ u64 ovs_flow_used_time(unsigned long flow_jiffies);
 int ovs_flow_to_nlattrs(const struct sw_flow_key *, struct sk_buff *);
 int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
 		      const struct nlattr *);
-int ovs_flow_metadata_from_nlattrs(u32 *priority, u32 *mark, u16 *in_port,
-			       const struct nlattr *);
+int ovs_flow_metadata_from_nlattrs(struct sw_flow *flow,
+				  const struct nlattr *attr);
 
 #define MAX_ACTIONS_BUFSIZE    (16 * 1024)
 #define TBL_MIN_BUCKETS		1024
-- 
1.7.1
