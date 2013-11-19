From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 7/9] genetlink: add and use genl_set_err()
Date: Tue, 19 Nov 2013 15:19:37 +0100
Message-ID: <1384870779-17571-8-git-send-email-johannes@sipsolutions.net>
References: <1384870779-17571-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:41401 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752977Ab3KSOTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 09:19:48 -0500
In-Reply-To: <1384870779-17571-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Add a static inline to generic netlink to wrap netlink_set_err()
to make it easier to use here - use it in openvswitch (the only
generic netlink user of netlink_set_err()).

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/net/genetlink.h     | 14 ++++++++++++++
 net/openvswitch/datapath.c  |  8 ++++----
 net/openvswitch/dp_notify.c |  6 +++---
 3 files changed, 21 insertions(+), 7 deletions(-)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index d8a8b1f..11ac77f 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -351,5 +351,19 @@ static inline struct sk_buff *genlmsg_new(size_t payload, gfp_t flags)
 	return nlmsg_new(genlmsg_total_size(payload), flags);
 }
 
+/**
+ * genl_set_err - report error to genetlink broadcast listeners
+ * @net: the network namespace to report the error to
+ * @portid: the PORTID of a process that we want to skip (if any)
+ * @group: the broadcast group that will notice the error
+ * @code: error code, must be negative (as usual in kernelspace)
+ *
+ * This function returns the number of broadcast listeners that have set the
+ * NETLINK_RECV_NO_ENOBUFS socket option.
+ */
+static inline int genl_set_err(struct net *net, u32 portid, u32 group, int code)
+{
+	return netlink_set_err(net->genl_sock, portid, group, code);
+}
 
 #endif	/* __NET_GENERIC_NETLINK_H */
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 8ec8b73..3e2bb15 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -879,8 +879,8 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 	if (!IS_ERR(reply))
 		ovs_notify(reply, info, &ovs_dp_flow_multicast_group);
 	else
-		netlink_set_err(sock_net(skb->sk)->genl_sock, 0,
-				ovs_dp_flow_multicast_group.id, PTR_ERR(reply));
+		genl_set_err(sock_net(skb->sk), 0,
+			     ovs_dp_flow_multicast_group.id, PTR_ERR(reply));
 	return 0;
 
 err_flow_free:
@@ -1326,8 +1326,8 @@ static int ovs_dp_cmd_set(struct sk_buff *skb, struct genl_info *info)
 				      info->snd_seq, OVS_DP_CMD_NEW);
 	if (IS_ERR(reply)) {
 		err = PTR_ERR(reply);
-		netlink_set_err(sock_net(skb->sk)->genl_sock, 0,
-				ovs_dp_datapath_multicast_group.id, err);
+		genl_set_err(sock_net(skb->sk), 0,
+			     ovs_dp_datapath_multicast_group.id, err);
 		err = 0;
 		goto unlock;
 	}
diff --git a/net/openvswitch/dp_notify.c b/net/openvswitch/dp_notify.c
index 5c2dab2..3d55ead 100644
--- a/net/openvswitch/dp_notify.c
+++ b/net/openvswitch/dp_notify.c
@@ -34,9 +34,9 @@ static void dp_detach_port_notify(struct vport *vport)
 					  OVS_VPORT_CMD_DEL);
 	ovs_dp_detach_port(vport);
 	if (IS_ERR(notify)) {
-		netlink_set_err(ovs_dp_get_net(dp)->genl_sock, 0,
-				ovs_dp_vport_multicast_group.id,
-				PTR_ERR(notify));
+		genl_set_err(ovs_dp_get_net(dp), 0,
+			     ovs_dp_vport_multicast_group.id,
+			     PTR_ERR(notify));
 		return;
 	}
 
-- 
1.8.4.rc3
