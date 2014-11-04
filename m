From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 07/14] openvswitch: Refactor ovs_flow_cmd_fill_info().
Date: Mon,  3 Nov 2014 22:01:31 -0800
Message-ID: <1415080891-1837-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Joe Stringer <joestringer@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog018.obsmtp.com ([74.125.150.76]:38140 "HELO
	na6sys009bog018.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752112AbaKEUBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 15:01:50 -0500
Received: by mail-pa0-f51.google.com with SMTP id kq14so1430427pab.38
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 12:01:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joestringer@nicira.com>

Split up ovs_flow_cmd_fill_info() to make it easier to cache parts of a
dump reply. This will be used to streamline flow_dump in a future patch.

Signed-off-by: Joe Stringer <joestringer@nicira.com>
Acked-by: Thomas Graf <tgraf@noironetworks.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/datapath.c | 93 ++++++++++++++++++++++++++++++++--------------
 1 file changed, 66 insertions(+), 27 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 04a26ae..bbb920b 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -674,58 +674,67 @@ static size_t ovs_flow_cmd_msg_size(const struct sw_flow_actions *acts)
 }
 
 /* Called with ovs_mutex or RCU read lock. */
-static int ovs_flow_cmd_fill_info(const struct sw_flow *flow, int dp_ifindex,
-				  struct sk_buff *skb, u32 portid,
-				  u32 seq, u32 flags, u8 cmd)
+static int ovs_flow_cmd_fill_match(const struct sw_flow *flow,
+				   struct sk_buff *skb)
 {
-	const int skb_orig_len = skb->len;
-	struct nlattr *start;
-	struct ovs_flow_stats stats;
-	__be16 tcp_flags;
-	unsigned long used;
-	struct ovs_header *ovs_header;
 	struct nlattr *nla;
 	int err;
 
-	ovs_header = genlmsg_put(skb, portid, seq, &dp_flow_genl_family, flags, cmd);
-	if (!ovs_header)
-		return -EMSGSIZE;
-
-	ovs_header->dp_ifindex = dp_ifindex;
-
 	/* Fill flow key. */
 	nla = nla_nest_start(skb, OVS_FLOW_ATTR_KEY);
 	if (!nla)
-		goto nla_put_failure;
+		return -EMSGSIZE;
 
 	err = ovs_nla_put_flow(&flow->unmasked_key, &flow->unmasked_key, skb);
 	if (err)
-		goto error;
+		return err;
+
 	nla_nest_end(skb, nla);
 
+	/* Fill flow mask. */
 	nla = nla_nest_start(skb, OVS_FLOW_ATTR_MASK);
 	if (!nla)
-		goto nla_put_failure;
+		return -EMSGSIZE;
 
 	err = ovs_nla_put_flow(&flow->key, &flow->mask->key, skb);
 	if (err)
-		goto error;
+		return err;
 
 	nla_nest_end(skb, nla);
+	return 0;
+}
+
+/* Called with ovs_mutex or RCU read lock. */
+static int ovs_flow_cmd_fill_stats(const struct sw_flow *flow,
+				   struct sk_buff *skb)
+{
+	struct ovs_flow_stats stats;
+	__be16 tcp_flags;
+	unsigned long used;
 
 	ovs_flow_stats_get(flow, &stats, &used, &tcp_flags);
 
 	if (used &&
 	    nla_put_u64(skb, OVS_FLOW_ATTR_USED, ovs_flow_used_time(used)))
-		goto nla_put_failure;
+		return -EMSGSIZE;
 
 	if (stats.n_packets &&
 	    nla_put(skb, OVS_FLOW_ATTR_STATS, sizeof(struct ovs_flow_stats), &stats))
-		goto nla_put_failure;
+		return -EMSGSIZE;
 
 	if ((u8)ntohs(tcp_flags) &&
 	     nla_put_u8(skb, OVS_FLOW_ATTR_TCP_FLAGS, (u8)ntohs(tcp_flags)))
-		goto nla_put_failure;
+		return -EMSGSIZE;
+
+	return 0;
+}
+
+/* Called with ovs_mutex or RCU read lock. */
+static int ovs_flow_cmd_fill_actions(const struct sw_flow *flow,
+				     struct sk_buff *skb, int skb_orig_len)
+{
+	struct nlattr *start;
+	int err;
 
 	/* If OVS_FLOW_ATTR_ACTIONS doesn't fit, skip dumping the actions if
 	 * this is the first flow to be dumped into 'skb'.  This is unusual for
@@ -749,17 +758,47 @@ static int ovs_flow_cmd_fill_info(const struct sw_flow *flow, int dp_ifindex,
 			nla_nest_end(skb, start);
 		else {
 			if (skb_orig_len)
-				goto error;
+				return err;
 
 			nla_nest_cancel(skb, start);
 		}
-	} else if (skb_orig_len)
-		goto nla_put_failure;
+	} else if (skb_orig_len) {
+		return -EMSGSIZE;
+	}
+
+	return 0;
+}
+
+/* Called with ovs_mutex or RCU read lock. */
+static int ovs_flow_cmd_fill_info(const struct sw_flow *flow, int dp_ifindex,
+				  struct sk_buff *skb, u32 portid,
+				  u32 seq, u32 flags, u8 cmd)
+{
+	const int skb_orig_len = skb->len;
+	struct ovs_header *ovs_header;
+	int err;
+
+	ovs_header = genlmsg_put(skb, portid, seq, &dp_flow_genl_family,
+				 flags, cmd);
+	if (!ovs_header)
+		return -EMSGSIZE;
+
+	ovs_header->dp_ifindex = dp_ifindex;
+
+	err = ovs_flow_cmd_fill_match(flow, skb);
+	if (err)
+		goto error;
+
+	err = ovs_flow_cmd_fill_stats(flow, skb);
+	if (err)
+		goto error;
+
+	err = ovs_flow_cmd_fill_actions(flow, skb, skb_orig_len);
+	if (err)
+		goto error;
 
 	return genlmsg_end(skb, ovs_header);
 
-nla_put_failure:
-	err = -EMSGSIZE;
 error:
 	genlmsg_cancel(skb, ovs_header);
 	return err;
-- 
1.9.3
