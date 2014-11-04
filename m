From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 05/14] openvswitch: Additional logging for -EINVAL on flow setups.
Date: Mon,  3 Nov 2014 22:01:14 -0800
Message-ID: <1415080874-1779-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>,
	Federico Iezzi <fiezzi@enter.it>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog011.obsmtp.com ([74.125.150.62]:43477 "HELO
	na6sys009bog011.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752001AbaKEUB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 15:01:28 -0500
Received: by mail-pa0-f51.google.com with SMTP id kq14so1455574pab.10
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 12:01:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>

There are many possible ways that a flow can be invalid so we've
added logging for most of them. This adds logs for the remaining
possible cases so there isn't any ambiguity while debugging.

CC: Federico Iezzi <fiezzi@enter.it>
Signed-off-by: Jesse Gross <jesse@nicira.com>
Acked-by: Thomas Graf <tgraf@noironetworks.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/datapath.c     | 12 +++++++++---
 net/openvswitch/flow_netlink.c | 17 +++++++++++++----
 2 files changed, 22 insertions(+), 7 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index a532a9c..04a26ae 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -817,10 +817,14 @@ static int ovs_flow_cmd_new(struct sk_buff *skb, struct genl_info *info)
 
 	/* Must have key and actions. */
 	error = -EINVAL;
-	if (!a[OVS_FLOW_ATTR_KEY])
+	if (!a[OVS_FLOW_ATTR_KEY]) {
+		OVS_NLERR("Flow key attribute not present in new flow.\n");
 		goto error;
-	if (!a[OVS_FLOW_ATTR_ACTIONS])
+	}
+	if (!a[OVS_FLOW_ATTR_ACTIONS]) {
+		OVS_NLERR("Flow actions attribute not present in new flow.\n");
 		goto error;
+	}
 
 	/* Most of the time we need to allocate a new flow, do it before
 	 * locking.
@@ -979,8 +983,10 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
 
 	/* Extract key. */
 	error = -EINVAL;
-	if (!a[OVS_FLOW_ATTR_KEY])
+	if (!a[OVS_FLOW_ATTR_KEY]) {
+		OVS_NLERR("Flow key attribute not present in set flow.\n");
 		goto error;
+	}
 
 	ovs_match_init(&match, &key, &mask);
 	error = ovs_nla_get_match(&match,
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 5a91d79..1b29ea7 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -581,10 +581,13 @@ static int metadata_from_nlattrs(struct sw_flow_match *match,  u64 *attrs,
 	if (*attrs & (1 << OVS_KEY_ATTR_IN_PORT)) {
 		u32 in_port = nla_get_u32(a[OVS_KEY_ATTR_IN_PORT]);
 
-		if (is_mask)
+		if (is_mask) {
 			in_port = 0xffffffff; /* Always exact match in_port. */
-		else if (in_port >= DP_MAX_PORTS)
+		} else if (in_port >= DP_MAX_PORTS) {
+			OVS_NLERR("Port (%d) exceeds maximum allowable (%d).\n",
+				  in_port, DP_MAX_PORTS);
 			return -EINVAL;
+		}
 
 		SW_FLOW_KEY_PUT(match, phy.in_port, in_port, is_mask);
 		*attrs &= ~(1 << OVS_KEY_ATTR_IN_PORT);
@@ -824,8 +827,11 @@ static int ovs_key_from_nlattrs(struct sw_flow_match *match, u64 attrs,
 		attrs &= ~(1 << OVS_KEY_ATTR_ND);
 	}
 
-	if (attrs != 0)
+	if (attrs != 0) {
+		OVS_NLERR("Unknown key attributes (%llx).\n",
+			  (unsigned long long)attrs);
 		return -EINVAL;
+	}
 
 	return 0;
 }
@@ -1250,8 +1256,10 @@ struct sw_flow_actions *ovs_nla_alloc_flow_actions(int size)
 {
 	struct sw_flow_actions *sfa;
 
-	if (size > MAX_ACTIONS_BUFSIZE)
+	if (size > MAX_ACTIONS_BUFSIZE) {
+		OVS_NLERR("Flow action size (%u bytes) exceeds maximum", size);
 		return ERR_PTR(-EINVAL);
+	}
 
 	sfa = kmalloc(sizeof(*sfa) + size, GFP_KERNEL);
 	if (!sfa)
@@ -1786,6 +1794,7 @@ static int ovs_nla_copy_actions__(const struct nlattr *attr,
 			break;
 
 		default:
+			OVS_NLERR("Unknown tunnel attribute (%d).\n", type);
 			return -EINVAL;
 		}
 		if (!skip_copy) {
-- 
1.9.3
