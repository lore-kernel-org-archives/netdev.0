From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 1/8] genl: Add genlmsg_new_unicast() for unicast message allocation
Date: Fri, 22 Nov 2013 17:56:04 +0100
Message-ID: <9f6d021f5f2ea10693580c49a7559d3c0541fef7.1385137618.git.tgraf@suug.ch>
References: <cover.1385137618.git.tgraf@suug.ch>
Cc: dev@openvswitch.org, netdev@vger.kernel.org, dborkman@redhat.com,
	ffusco@redhat.com, fleitner@redhat.com, eric.dumazet@gmail.com,
	bhutchings@solarflare.com
To: jesse@nicira.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:51458 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755521Ab3KVQ4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Nov 2013 11:56:23 -0500
In-Reply-To: <cover.1385137618.git.tgraf@suug.ch>
In-Reply-To: <cover.1385137618.git.tgraf@suug.ch>
References: <cover.1385137618.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allocates a new sk_buff large enough to cover the specified payload
plus required Netlink headers. Will check receiving socket for
memory mapped i/o capability and use it if enabled. Will fall back
to non-mapped skb if message size exceeds the frame size of the ring.

Signed-of-by: Thomas Graf <tgraf@suug.ch>
Reviewed-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/net/genetlink.h |  4 ++++
 net/netlink/genetlink.c | 21 +++++++++++++++++++++
 2 files changed, 25 insertions(+)

diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index 1b177ed..93695f0 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -73,6 +73,7 @@ struct genl_family {
  * @attrs: netlink attributes
  * @_net: network namespace
  * @user_ptr: user pointers
+ * @dst_sk: destination socket
  */
 struct genl_info {
 	u32			snd_seq;
@@ -85,6 +86,7 @@ struct genl_info {
 	struct net *		_net;
 #endif
 	void *			user_ptr[2];
+	struct sock *		dst_sk;
 };
 
 static inline struct net *genl_info_net(struct genl_info *info)
@@ -177,6 +179,8 @@ void genl_notify(struct genl_family *family,
 		 struct sk_buff *skb, struct net *net, u32 portid,
 		 u32 group, struct nlmsghdr *nlh, gfp_t flags);
 
+struct sk_buff *genlmsg_new_unicast(size_t payload, struct genl_info *info,
+				    gfp_t flags);
 void *genlmsg_put(struct sk_buff *skb, u32 portid, u32 seq,
 		  struct genl_family *family, int flags, u8 cmd);
 
diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index 4518a57..85bf42e 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -454,6 +454,26 @@ int genl_unregister_family(struct genl_family *family)
 EXPORT_SYMBOL(genl_unregister_family);
 
 /**
+ * genlmsg_new_unicast - Allocate generic netlink message for unicast
+ * @payload: size of the message payload
+ * @info: information on destination
+ * @flags: the type of memory to allocate
+ *
+ * Allocates a new sk_buff large enough to cover the specified payload
+ * plus required Netlink headers. Will check receiving socket for
+ * memory mapped i/o capability and use it if enabled. Will fall back
+ * to non-mapped skb if message size exceeds the frame size of the ring.
+ */
+struct sk_buff *genlmsg_new_unicast(size_t payload, struct genl_info *info,
+				    gfp_t flags)
+{
+	size_t len = nlmsg_total_size(genlmsg_total_size(payload));
+
+	return netlink_alloc_skb(info->dst_sk, len, info->snd_portid, flags);
+}
+EXPORT_SYMBOL_GPL(genlmsg_new_unicast);
+
+/**
  * genlmsg_put - Add generic netlink header to netlink message
  * @skb: socket buffer holding the message
  * @portid: netlink portid the message is addressed to
@@ -593,6 +613,7 @@ static int genl_family_rcv_msg(struct genl_family *family,
 	info.genlhdr = nlmsg_data(nlh);
 	info.userhdr = nlmsg_data(nlh) + GENL_HDRLEN;
 	info.attrs = attrbuf;
+	info.dst_sk = skb->sk;
 	genl_info_net_set(&info, net);
 	memset(&info.user_ptr, 0, sizeof(info.user_ptr));
 
-- 
1.8.3.1
