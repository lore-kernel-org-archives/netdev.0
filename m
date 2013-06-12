From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 2/4] openvswitch: Simplify interface ovs_flow_metadata_from_nlattrs()
Date: Wed, 12 Jun 2013 15:57:04 -0700
Message-ID: <1371077824-19718-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog119.obsmtp.com ([74.125.149.246]:45647 "HELO
	na3sys009aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758166Ab3FLW5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 18:57:09 -0400
Received: by mail-pa0-f53.google.com with SMTP id tj12so5580571pac.12
        for <netdev@vger.kernel.org>; Wed, 12 Jun 2013 15:57:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is not functional change, this is just code cleanup.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/datapath.c |    5 +----
 net/openvswitch/flow.c     |   23 +++++++++++------------
 net/openvswitch/flow.h     |    4 ++--
 3 files changed, 14 insertions(+), 18 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index d12d6b8..39cd821 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -739,10 +739,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	if (err)
 		goto err_flow_free;
 
-	err = ovs_flow_metadata_from_nlattrs(&flow->key.phy.priority,
-					     &flow->key.phy.skb_mark,
-					     &flow->key.phy.in_port,
-					     a[OVS_PACKET_ATTR_KEY]);
+	err = ovs_flow_metadata_from_nlattrs(flow, key_len, a[OVS_PACKET_ATTR_KEY]);
 	if (err)
 		goto err_flow_free;
 
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index b15321a..150f181 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -1122,10 +1122,9 @@ int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
 
 /**
  * ovs_flow_metadata_from_nlattrs - parses Netlink attributes into a flow key.
- * @priority: receives the skb priority
- * @mark: receives the skb mark
- * @in_port: receives the extracted input port.
- * @key: Netlink attribute holding nested %OVS_KEY_ATTR_* Netlink attribute
+ * @flow: Receives extracted in_port, priority, tun_key and skb_mark.
+ * @key_len: Length of key in @flow.  Used for calculating flow hash.
+ * @attr: Netlink attribute holding nested %OVS_KEY_ATTR_* Netlink attribute
  * sequence.
  *
  * This parses a series of Netlink attributes that form a flow key, which must
@@ -1133,15 +1132,15 @@ int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
  * get the metadata, that is, the parts of the flow key that cannot be
  * extracted from the packet itself.
  */
-int ovs_flow_metadata_from_nlattrs(u32 *priority, u32 *mark, u16 *in_port,
-			       const struct nlattr *attr)
+int ovs_flow_metadata_from_nlattrs(struct sw_flow *flow, int key_len,
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
@@ -1152,17 +1151,17 @@ int ovs_flow_metadata_from_nlattrs(u32 *priority, u32 *mark, u16 *in_port,
 
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
index 0875fde..1feff5d 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -141,8 +141,8 @@ u64 ovs_flow_used_time(unsigned long flow_jiffies);
 int ovs_flow_to_nlattrs(const struct sw_flow_key *, struct sk_buff *);
 int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
 		      const struct nlattr *);
-int ovs_flow_metadata_from_nlattrs(u32 *priority, u32 *mark, u16 *in_port,
-			       const struct nlattr *);
+int ovs_flow_metadata_from_nlattrs(struct sw_flow *flow, int key_len,
+				  const struct nlattr *attr);
 
 #define MAX_ACTIONS_BUFSIZE    (16 * 1024)
 #define TBL_MIN_BUCKETS		1024
-- 
1.7.1
