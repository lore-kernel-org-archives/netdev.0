From: Wangyufen <wangyufen@huawei.com>
Subject: [PATCH v2 6/8] net: Add variants of capable for use on netlink messages
Date: Fri, 25 Jul 2014 16:22:27 +0800
Message-ID: <1406276549-6616-7-git-send-email-wangyufen@huawei.com>
References: <1406276549-6616-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Wang Yufen <wangyufen@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:30961 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759272AbaGYI0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 04:26:34 -0400
In-Reply-To: <1406276549-6616-1-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

netlink_net_capable - The common case use, for operations that are safe on a network namespace
netlink_capable - For operations that are only known to be safe for the global root
netlink_ns_capable - The general case of capable used to handle special cases

__netlink_ns_capable - Same as netlink_ns_capable except taking a netlink_skb_parms instead of
                       the skbuff of a netlink message.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Wang Yufen <wangyufen@huawei.com>
---
 include/linux/netlink.h  |  7 ++++++
 net/netlink/af_netlink.c | 65 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 72 insertions(+)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index af6c763..f4b56b7 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -279,6 +279,13 @@ static inline int netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 #define NL_NONROOT_SEND 0x2
 extern void netlink_set_nonroot(int protocol, unsigned flag);
 
+bool __netlink_ns_capable(const struct netlink_skb_parms *nsp,
+			  struct user_namespace *ns, int cap);
+bool netlink_ns_capable(const struct sk_buff *skb,
+			struct user_namespace *ns, int cap);
+bool netlink_capable(const struct sk_buff *skb, int cap);
+bool netlink_net_capable(const struct sk_buff *skb, int cap);
+
 #endif /* __KERNEL__ */
 
 #endif	/* __LINUX_NETLINK_H */
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 18b4cc6..7d3cfc9 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -590,6 +590,71 @@ retry:
 	return err;
 }
 
+/**
+ * __netlink_ns_capable - General netlink message capability test
+ * @nsp: NETLINK_CB of the socket buffer holding a netlink command from userspace.
+ * @user_ns: The user namespace of the capability to use
+ * @cap: The capability to use
+ *
+ * Test to see if the opener of the socket we received the message
+ * from had when the netlink socket was created and the sender of the
+ * message has has the capability @cap in the user namespace @user_ns.
+ */
+bool __netlink_ns_capable(const struct netlink_skb_parms *nsp,
+			struct user_namespace *user_ns, int cap)
+{
+	return sk_ns_capable(nsp->ssk, user_ns, cap);
+}
+EXPORT_SYMBOL(__netlink_ns_capable);
+
+/**
+ * netlink_ns_capable - General netlink message capability test
+ * @skb: socket buffer holding a netlink command from userspace
+ * @user_ns: The user namespace of the capability to use
+ * @cap: The capability to use
+ *
+ * Test to see if the opener of the socket we received the message
+ * from had when the netlink socket was created and the sender of the
+ * message has has the capability @cap in the user namespace @user_ns.
+ */
+bool netlink_ns_capable(const struct sk_buff *skb,
+			struct user_namespace *user_ns, int cap)
+{
+	return __netlink_ns_capable(&NETLINK_CB(skb), user_ns, cap);
+}
+EXPORT_SYMBOL(netlink_ns_capable);
+
+/**
+ * netlink_capable - Netlink global message capability test
+ * @skb: socket buffer holding a netlink command from userspace
+ * @cap: The capability to use
+ *
+ * Test to see if the opener of the socket we received the message
+ * from had when the netlink socket was created and the sender of the
+ * message has has the capability @cap in all user namespaces.
+ */
+bool netlink_capable(const struct sk_buff *skb, int cap)
+{
+	return netlink_ns_capable(skb, &init_user_ns, cap);
+}
+EXPORT_SYMBOL(netlink_capable);
+
+/**
+ * netlink_net_capable - Netlink network namespace message capability test
+ * @skb: socket buffer holding a netlink command from userspace
+ * @cap: The capability to use
+ *
+ * Test to see if the opener of the socket we received the message
+ * from had when the netlink socket was created and the sender of the
+ * message has has the capability @cap over the network namespace of
+ * the socket we received the message from.
+ */
+bool netlink_net_capable(const struct sk_buff *skb, int cap)
+{
+	return netlink_ns_capable(skb, sock_net(skb->sk)->user_ns, cap);
+}
+EXPORT_SYMBOL(netlink_net_capable);
+
 static inline int netlink_allowed(const struct socket *sock, unsigned int flag)
 {
 	return (nl_table[sock->sk->sk_protocol].nl_nonroot & flag) ||
-- 
1.8.0
