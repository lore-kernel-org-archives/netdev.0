From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 3/5] Revert "genl: Add genlmsg_new_unicast() for unicast message allocation"
Date: Thu, 18 Feb 2016 15:03:26 +0100
Message-ID: <1455804208-30512-4-git-send-email-fw@strlen.de>
References: <1455804208-30512-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:50168 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1426029AbcBRODx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 09:03:53 -0500
In-Reply-To: <1455804208-30512-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit bb9b18fb55b0 ("genl: Add genlmsg_new_unicast() for
unicast message allocation")'.

Nothing wrong with it; its no longer needed since this was only for
mmapped netlink support.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/genetlink.h    |  4 ----
 net/netlink/genetlink.c    | 21 ---------------------
 net/openvswitch/datapath.c | 10 +++++-----
 net/tipc/netlink_compat.c  |  1 -
 4 files changed, 5 insertions(+), 31 deletions(-)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index 43c0e77..8d4608c 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -83,7 +83,6 @@ struct genl_family {
  * @attrs: netlink attributes
  * @_net: network namespace
  * @user_ptr: user pointers
- * @dst_sk: destination socket
  */
 struct genl_info {
 	u32			snd_seq;
@@ -94,7 +93,6 @@ struct genl_info {
 	struct nlattr **	attrs;
 	possible_net_t		_net;
 	void *			user_ptr[2];
-	struct sock *		dst_sk;
 };
 
 static inline struct net *genl_info_net(struct genl_info *info)
@@ -188,8 +186,6 @@ int genl_unregister_family(struct genl_family *family);
 void genl_notify(struct genl_family *family, struct sk_buff *skb,
 		 struct genl_info *info, u32 group, gfp_t flags);
 
-struct sk_buff *genlmsg_new_unicast(size_t payload, struct genl_info *info,
-				    gfp_t flags);
 void *genlmsg_put(struct sk_buff *skb, u32 portid, u32 seq,
 		  struct genl_family *family, int flags, u8 cmd);
 
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 0ffd721..a09132a 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -463,26 +463,6 @@ int genl_unregister_family(struct genl_family *family)
 EXPORT_SYMBOL(genl_unregister_family);
 
 /**
- * genlmsg_new_unicast - Allocate generic netlink message for unicast
- * @payload: size of the message payload
- * @info: information on destination
- * @flags: the type of memory to allocate
- *
- * Allocates a new sk_buff large enough to cover the specified payload
- * plus required Netlink headers. Will check receiving socket for
- * memory mapped i/o capability and use it if enabled. Will fall back
- * to non-mapped skb if message size exceeds the frame size of the ring.
- */
-struct sk_buff *genlmsg_new_unicast(size_t payload, struct genl_info *info,
-				    gfp_t flags)
-{
-	size_t len = nlmsg_total_size(genlmsg_total_size(payload));
-
-	return netlink_alloc_skb(info->dst_sk, len, info->snd_portid, flags);
-}
-EXPORT_SYMBOL_GPL(genlmsg_new_unicast);
-
-/**
  * genlmsg_put - Add generic netlink header to netlink message
  * @skb: socket buffer holding the message
  * @portid: netlink portid the message is addressed to
@@ -642,7 +622,6 @@ static int genl_family_rcv_msg(struct genl_family *family,
 	info.genlhdr = nlmsg_data(nlh);
 	info.userhdr = nlmsg_data(nlh) + GENL_HDRLEN;
 	info.attrs = attrbuf;
-	info.dst_sk = skb->sk;
 	genl_info_net_set(&info, net);
 	memset(&info.user_ptr, 0, sizeof(info.user_ptr));
 
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 35a2659..c4e8455 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -1477,7 +1477,7 @@ error:
 	return -EMSGSIZE;
 }
 
-static struct sk_buff *ovs_dp_cmd_alloc_info(struct genl_info *info)
+static struct sk_buff *ovs_dp_cmd_alloc_info(void)
 {
 	return genlmsg_new(ovs_dp_cmd_msg_size(), GFP_KERNEL);
 }
@@ -1532,7 +1532,7 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	if (!a[OVS_DP_ATTR_NAME] || !a[OVS_DP_ATTR_UPCALL_PID])
 		goto err;
 
-	reply = ovs_dp_cmd_alloc_info(info);
+	reply = ovs_dp_cmd_alloc_info();
 	if (!reply)
 		return -ENOMEM;
 
@@ -1653,7 +1653,7 @@ static int ovs_dp_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	struct datapath *dp;
 	int err;
 
-	reply = ovs_dp_cmd_alloc_info(info);
+	reply = ovs_dp_cmd_alloc_info();
 	if (!reply)
 		return -ENOMEM;
 
@@ -1686,7 +1686,7 @@ static int ovs_dp_cmd_set(struct sk_buff *skb, struct genl_info *info)
 	struct datapath *dp;
 	int err;
 
-	reply = ovs_dp_cmd_alloc_info(info);
+	reply = ovs_dp_cmd_alloc_info();
 	if (!reply)
 		return -ENOMEM;
 
@@ -1719,7 +1719,7 @@ static int ovs_dp_cmd_get(struct sk_buff *skb, struct genl_info *info)
 	struct datapath *dp;
 	int err;
 
-	reply = ovs_dp_cmd_alloc_info(info);
+	reply = ovs_dp_cmd_alloc_info();
 	if (!reply)
 		return -ENOMEM;
 
diff --git a/net/tipc/netlink_compat.c b/net/tipc/netlink_compat.c
index 2c016fd..de66d8f 100644
--- a/net/tipc/netlink_compat.c
+++ b/net/tipc/netlink_compat.c
@@ -1104,7 +1104,6 @@ static int tipc_nl_compat_recv(struct sk_buff *skb, struct genl_info *info)
 	req_nlh = (struct nlmsghdr *)skb->data;
 	msg.req = nlmsg_data(req_nlh) + GENL_HDRLEN + TIPC_GENL_HDRLEN;
 	msg.cmd = req_userhdr->cmd;
-	msg.dst_sk = info->dst_sk;
 	msg.net = genl_info_net(info);
 
 	if ((msg.cmd & 0xC000) && (!netlink_net_capable(skb, CAP_NET_ADMIN))) {
-- 
2.4.10
