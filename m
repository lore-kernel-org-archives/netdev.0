From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] openvswitch: Provide OVS_DP_ATTR_UPCALL_PID in datapath messages
Date: Wed,  3 Apr 2013 00:28:29 +0200
Message-ID: <e7d0e105e879fb78ff3e5628147e41d52fb0cddd.1364941614.git.tgraf@suug.ch>
Cc: dev@openvswitch.org, netdev@vger.kernel.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:43592
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933679Ab3DBW2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 18:28:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The upcall port configured when adding a new datapath is currently
only provided to user space as part of the vport message. Therefore
user space has to request two separate messages which is prone to
race conditions.

Provide the upcall port of the local port (0) of a data path in the
datapath message to gain symmetry between the SET and GET command.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/openvswitch/datapath.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index d406503..e9b9469 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1240,6 +1240,7 @@ static size_t ovs_dp_cmd_msg_size(void)
 	size_t msgsize = NLMSG_ALIGN(sizeof(struct ovs_header));
 
 	msgsize += nla_total_size(IFNAMSIZ);
+	msgsize += nla_total_size(4); /* OVS_DP_ATTR_UPCALL_PID */
 	msgsize += nla_total_size(sizeof(struct ovs_dp_stats));
 
 	return msgsize;
@@ -1250,6 +1251,7 @@ static int ovs_dp_cmd_fill_info(struct datapath *dp, struct sk_buff *skb,
 {
 	struct ovs_header *ovs_header;
 	struct ovs_dp_stats dp_stats;
+	struct vport *local;
 	int err;
 
 	ovs_header = genlmsg_put(skb, portid, seq, &dp_datapath_genl_family,
@@ -1261,17 +1263,24 @@ static int ovs_dp_cmd_fill_info(struct datapath *dp, struct sk_buff *skb,
 
 	rcu_read_lock();
 	err = nla_put_string(skb, OVS_DP_ATTR_NAME, ovs_dp_name(dp));
-	rcu_read_unlock();
 	if (err)
 		goto nla_put_failure;
 
+	local = ovs_vport_rcu(dp, OVSP_LOCAL);
+	if (local &&
+	    nla_put_u32(skb, OVS_DP_ATTR_UPCALL_PID, local->upcall_portid))
+		goto nla_put_failure;
+
 	get_dp_stats(dp, &dp_stats);
 	if (nla_put(skb, OVS_DP_ATTR_STATS, sizeof(struct ovs_dp_stats), &dp_stats))
 		goto nla_put_failure;
 
+	rcu_read_unlock();
+
 	return genlmsg_end(skb, ovs_header);
 
 nla_put_failure:
+	rcu_read_unlock();
 	genlmsg_cancel(skb, ovs_header);
 error:
 	return -EMSGSIZE;
-- 
1.7.11.7
