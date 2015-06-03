From: Neil McKee <neil.mckee@inmon.com>
Subject: [PATCH net-next] openvswitch: include actions with upcall if allocation allows
Date: Wed,  3 Jun 2015 15:31:07 -0700
Message-ID: <1433370667-30625-1-git-send-email-neil.mckee@inmon.com>
Cc: Neil McKee <neil.mckee@inmon.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f172.google.com ([209.85.216.172]:34139 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752773AbbFCWbR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 18:31:17 -0400
Received: by qcej9 with SMTP id j9so10856438qce.1
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 15:31:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Back out the OVS_USERSPACE_ATTR_ACTIONS attribute that was
gating the inclusion of datapath actions in the upcall.
Instead include the actions every time, provided there is no
problem with the atomic allocation.  If the atomic allocation
fails then try it again with the actions omitted.

Signed-off-by: Neil McKee <neil.mckee@inmon.com>
---
 include/uapi/linux/openvswitch.h |  4 ----
 net/openvswitch/actions.c        |  9 ++-------
 net/openvswitch/datapath.c       | 17 +++++++++++++----
 3 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 1dab776..bbd49a0 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -153,8 +153,6 @@ enum ovs_packet_cmd {
  * flow key against the kernel's.
  * @OVS_PACKET_ATTR_ACTIONS: Contains actions for the packet.  Used
  * for %OVS_PACKET_CMD_EXECUTE.  It has nested %OVS_ACTION_ATTR_* attributes.
- * Also used in upcall when %OVS_ACTION_ATTR_USERSPACE has optional
- * %OVS_USERSPACE_ATTR_ACTIONS attribute.
  * @OVS_PACKET_ATTR_USERDATA: Present for an %OVS_PACKET_CMD_ACTION
  * notification if the %OVS_ACTION_ATTR_USERSPACE action specified an
  * %OVS_USERSPACE_ATTR_USERDATA attribute, with the same length and content
@@ -530,7 +528,6 @@ enum ovs_sample_attr {
  * copied to the %OVS_PACKET_CMD_ACTION message as %OVS_PACKET_ATTR_USERDATA.
  * @OVS_USERSPACE_ATTR_EGRESS_TUN_PORT: If present, u32 output port to get
  * tunnel info.
- * @OVS_USERSPACE_ATTR_ACTIONS: If present, send actions with upcall.
  */
 enum ovs_userspace_attr {
 	OVS_USERSPACE_ATTR_UNSPEC,
@@ -538,7 +535,6 @@ enum ovs_userspace_attr {
 	OVS_USERSPACE_ATTR_USERDATA,  /* Optional user-specified cookie. */
 	OVS_USERSPACE_ATTR_EGRESS_TUN_PORT,  /* Optional, u32 output port
 					      * to get tunnel info. */
-	OVS_USERSPACE_ATTR_ACTIONS,   /* Optional flag to get actions. */
 	__OVS_USERSPACE_ATTR_MAX
 };
 
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 8a8c0b8..337730a 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -618,6 +618,8 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
 
 	memset(&upcall, 0, sizeof(upcall));
 	upcall.cmd = OVS_PACKET_CMD_ACTION;
+	upcall.actions = actions;
+	upcall.actions_len = actions_len;
 
 	for (a = nla_data(attr), rem = nla_len(attr); rem > 0;
 		 a = nla_next(a, &rem)) {
@@ -646,13 +648,6 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
 			break;
 		}
 
-		case OVS_USERSPACE_ATTR_ACTIONS: {
-			/* Include actions. */
-			upcall.actions = actions;
-			upcall.actions_len = actions_len;
-			break;
-		}
-
 		} /* End of switch. */
 	}
 
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index ff8c4a4..02b33a8 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -382,7 +382,7 @@ static int queue_gso_packets(struct datapath *dp, struct sk_buff *skb,
 }
 
 static size_t upcall_msg_size(const struct dp_upcall_info *upcall_info,
-			      unsigned int hdrlen)
+			      unsigned int hdrlen, bool allow_actions)
 {
 	size_t size = NLMSG_ALIGN(sizeof(struct ovs_header))
 		+ nla_total_size(hdrlen) /* OVS_PACKET_ATTR_PACKET */
@@ -397,7 +397,8 @@ static size_t upcall_msg_size(const struct dp_upcall_info *upcall_info,
 		size += nla_total_size(ovs_tun_key_attr_size());
 
 	/* OVS_PACKET_ATTR_ACTIONS */
-	if (upcall_info->actions_len)
+	if (allow_actions &&
+	    upcall_info->actions_len)
 		size += nla_total_size(upcall_info->actions_len);
 
 	return size;
@@ -418,6 +419,7 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 	size_t len;
 	unsigned int hlen;
 	int err, dp_ifindex;
+	bool allow_actions = true;
 
 	dp_ifindex = get_dpifindex(dp);
 	if (!dp_ifindex)
@@ -454,9 +456,15 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 	else
 		hlen = skb->len;
 
-	len = upcall_msg_size(upcall_info, hlen);
+retry_alloc:
+	len = upcall_msg_size(upcall_info, hlen, allow_actions);
 	user_skb = genlmsg_new_unicast(len, &info, GFP_ATOMIC);
 	if (!user_skb) {
+		if (allow_actions &&
+		    upcall_info->actions_len) {
+			allow_actions = false;
+			goto retry_alloc;
+		}
 		err = -ENOMEM;
 		goto out;
 	}
@@ -481,7 +489,8 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 		nla_nest_end(user_skb, nla);
 	}
 
-	if (upcall_info->actions_len) {
+	if (allow_actions &&
+	    upcall_info->actions_len) {
 		nla = nla_nest_start(user_skb, OVS_PACKET_ATTR_ACTIONS);
 		err = ovs_nla_put_actions(upcall_info->actions,
 					  upcall_info->actions_len,
-- 
1.9.3
