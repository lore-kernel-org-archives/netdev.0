From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 4/11] inet_diag: Switch from _GETSOCK to IPPROTO_ numbers
Date: Tue, 06 Dec 2011 22:05:24 +0400
Message-ID: <4EDE5964.3060109@parallels.com>
References: <4EDE573A.6040607@parallels.com> <4EDE5797.6010603@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:17707 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751776Ab1LFSFa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 13:05:30 -0500
In-Reply-To: <4EDE5797.6010603@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, but the vger didn't let this message go to the list. Re-sending it with
less spam-filter-prone subject.



When dumping the AF_INET/AF_INET6 sockets user will also specify the protocol,
so prepare the protocol diag handlers to work with IPPROTO_ constants.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 net/dccp/diag.c      |    4 ++--
 net/ipv4/inet_diag.c |   34 +++++++++++++++++++++++-----------
 net/ipv4/tcp_diag.c  |    4 ++--
 3 files changed, 27 insertions(+), 15 deletions(-)

diff --git a/net/dccp/diag.c b/net/dccp/diag.c
index d92ba7d..424dcd8 100644
--- a/net/dccp/diag.c
+++ b/net/dccp/diag.c
@@ -51,7 +51,7 @@ static void dccp_diag_get_info(struct sock *sk, struct inet_diag_msg *r,
 static const struct inet_diag_handler dccp_diag_handler = {
 	.idiag_hashinfo	 = &dccp_hashinfo,
 	.idiag_get_info	 = dccp_diag_get_info,
-	.idiag_type	 = DCCPDIAG_GETSOCK,
+	.idiag_type	 = IPPROTO_DCCP,
 	.idiag_info_size = sizeof(struct tcp_info),
 };
 
@@ -71,4 +71,4 @@ module_exit(dccp_diag_fini);
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Arnaldo Carvalho de Melo <acme@mandriva.com>");
 MODULE_DESCRIPTION("DCCP inet_diag handler");
-MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_NETLINK, NETLINK_SOCK_DIAG, DCCPDIAG_GETSOCK);
+MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_NETLINK, NETLINK_SOCK_DIAG, 33);
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index a406caf..cf8be3e 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -50,19 +50,31 @@ static struct sock *sdiagnl;
 #define INET_DIAG_PUT(skb, attrtype, attrlen) \
 	RTA_DATA(__RTA_PUT(skb, attrtype, attrlen))
 
+static inline int inet_diag_type2proto(int type)
+{
+	switch (type) {
+	case TCPDIAG_GETSOCK:
+		return IPPROTO_TCP;
+	case DCCPDIAG_GETSOCK:
+		return IPPROTO_DCCP;
+	default:
+		return 0;
+	}
+}
+
 static DEFINE_MUTEX(inet_diag_table_mutex);
 
-static const struct inet_diag_handler *inet_diag_lock_handler(int type)
+static const struct inet_diag_handler *inet_diag_lock_handler(int proto)
 {
-	if (!inet_diag_table[type])
+	if (!inet_diag_table[proto])
 		request_module("net-pf-%d-proto-%d-type-%d", PF_NETLINK,
-			       NETLINK_SOCK_DIAG, type);
+			       NETLINK_SOCK_DIAG, proto);
 
 	mutex_lock(&inet_diag_table_mutex);
-	if (!inet_diag_table[type])
+	if (!inet_diag_table[proto])
 		return ERR_PTR(-ENOENT);
 
-	return inet_diag_table[type];
+	return inet_diag_table[proto];
 }
 
 static inline void inet_diag_unlock_handler(
@@ -85,7 +97,7 @@ static int inet_csk_diag_fill(struct sock *sk,
 	unsigned char	 *b = skb_tail_pointer(skb);
 	const struct inet_diag_handler *handler;
 
-	handler = inet_diag_table[unlh->nlmsg_type];
+	handler = inet_diag_table[inet_diag_type2proto(unlh->nlmsg_type)];
 	BUG_ON(handler == NULL);
 
 	nlh = NLMSG_PUT(skb, pid, seq, unlh->nlmsg_type, sizeof(*r));
@@ -257,7 +269,7 @@ static int inet_diag_get_exact(struct sk_buff *in_skb,
 	struct inet_hashinfo *hashinfo;
 	const struct inet_diag_handler *handler;
 
-	handler = inet_diag_lock_handler(nlh->nlmsg_type);
+	handler = inet_diag_lock_handler(inet_diag_type2proto(nlh->nlmsg_type));
 	if (IS_ERR(handler)) {
 		err = PTR_ERR(handler);
 		goto unlock;
@@ -707,7 +719,7 @@ static int inet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	if (nlmsg_attrlen(cb->nlh, sizeof(struct inet_diag_req)))
 		bc = nlmsg_find_attr(cb->nlh, sizeof(*r), INET_DIAG_REQ_BYTECODE);
 
-	handler = inet_diag_lock_handler(cb->nlh->nlmsg_type);
+	handler = inet_diag_lock_handler(inet_diag_type2proto(cb->nlh->nlmsg_type));
 	if (IS_ERR(handler))
 		goto unlock;
 
@@ -907,7 +919,7 @@ int inet_diag_register(const struct inet_diag_handler *h)
 	const __u16 type = h->idiag_type;
 	int err = -EINVAL;
 
-	if (type >= INET_DIAG_GETSOCK_MAX)
+	if (type >= IPPROTO_MAX)
 		goto out;
 
 	mutex_lock(&inet_diag_table_mutex);
@@ -926,7 +938,7 @@ void inet_diag_unregister(const struct inet_diag_handler *h)
 {
 	const __u16 type = h->idiag_type;
 
-	if (type >= INET_DIAG_GETSOCK_MAX)
+	if (type >= IPPROTO_MAX)
 		return;
 
 	mutex_lock(&inet_diag_table_mutex);
@@ -937,7 +949,7 @@ EXPORT_SYMBOL_GPL(inet_diag_unregister);
 
 static int __init inet_diag_init(void)
 {
-	const int inet_diag_table_size = (INET_DIAG_GETSOCK_MAX *
+	const int inet_diag_table_size = (IPPROTO_MAX *
 					  sizeof(struct inet_diag_handler *));
 	int err = -ENOMEM;
 
diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
index 9e276b8..9814977 100644
--- a/net/ipv4/tcp_diag.c
+++ b/net/ipv4/tcp_diag.c
@@ -37,7 +37,7 @@ static void tcp_diag_get_info(struct sock *sk, struct inet_diag_msg *r,
 static const struct inet_diag_handler tcp_diag_handler = {
 	.idiag_hashinfo	 = &tcp_hashinfo,
 	.idiag_get_info	 = tcp_diag_get_info,
-	.idiag_type	 = TCPDIAG_GETSOCK,
+	.idiag_type	 = IPPROTO_TCP,
 	.idiag_info_size = sizeof(struct tcp_info),
 };
 
@@ -54,4 +54,4 @@ static void __exit tcp_diag_exit(void)
 module_init(tcp_diag_init);
 module_exit(tcp_diag_exit);
 MODULE_LICENSE("GPL");
-MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_NETLINK, NETLINK_SOCK_DIAG, TCPDIAG_GETSOCK);
+MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_NETLINK, NETLINK_SOCK_DIAG, 6);
-- 
1.5.5.6
