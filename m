From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] openvswitch: restore OVS_FLOW_CMD_NEW notifications
Date: Wed, 17 Sep 2014 18:13:20 +0200
Message-ID: <1410970400-9797-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, dev@openvswitch.org, netdev@vger.kernel.org,
	Samuel Gauthier <samuel.gauthier@6wind.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:35385 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755940AbaIQQOC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 12:14:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Samuel Gauthier <samuel.gauthier@6wind.com>

Since commit fb5d1e9e127a ("openvswitch: Build flow cmd netlink reply only if needed."),
the new flows are not notified to the listeners of OVS_FLOW_MCGROUP.

This commit fixes the problem by checking that there are listeners in
the actual OVS_FLOW_MCGROUP group, instead of 0.

Signed-off-by: Samuel Gauthier <samuel.gauthier@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/openvswitch/datapath.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 91d66b7e64ac..8396f6063343 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -79,10 +79,10 @@ static const struct genl_multicast_group ovs_dp_vport_multicast_group = {
 /* Check if need to build a reply message.
  * OVS userspace sets the NLM_F_ECHO flag if it needs the reply. */
 static bool ovs_must_notify(struct genl_info *info,
-			    const struct genl_multicast_group *grp)
+			    unsigned int group)
 {
 	return info->nlhdr->nlmsg_flags & NLM_F_ECHO ||
-		netlink_has_listeners(genl_info_net(info)->genl_sock, 0);
+		netlink_has_listeners(genl_info_net(info)->genl_sock, group);
 }
 
 static void ovs_notify(struct genl_family *family,
@@ -763,7 +763,7 @@ static struct sk_buff *ovs_flow_cmd_alloc_info(const struct sw_flow_actions *act
 {
 	struct sk_buff *skb;
 
-	if (!always && !ovs_must_notify(info, &ovs_dp_flow_multicast_group))
+	if (!always && !ovs_must_notify(info, dp_flow_genl_family.mcgrp_offset))
 		return NULL;
 
 	skb = genlmsg_new_unicast(ovs_flow_cmd_msg_size(acts), info, GFP_KERNEL);
-- 
2.1.0
