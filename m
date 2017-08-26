From: Ivan Delalande <colona@arista.com>
Subject: [PATCH net-next v2 1/2] inet_diag: allow protocols to provide additional data
Date: Fri, 25 Aug 2017 18:53:45 -0700
Message-ID: <20170826015346.24247-1-colona@arista.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
        Ivan Delalande <colona@arista.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mx.aristanetworks.com ([162.210.130.12]:22013 "EHLO
        prod-mx.aristanetworks.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751541AbdHZCBn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 22:01:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend inet_diag_handler to allow individual protocols to report
additional data on INET_DIAG_INFO through idiag_get_aux. The size
can be dynamic and is computed by idiag_get_aux_size.

Signed-off-by: Ivan Delalande <colona@arista.com>
---
 include/linux/inet_diag.h |  7 +++++++
 net/ipv4/inet_diag.c      | 22 ++++++++++++++++++----
 2 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index 65da430e260f..ee251c585854 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -25,6 +25,13 @@ struct inet_diag_handler {
 					  struct inet_diag_msg *r,
 					  void *info);
 
+	int		(*idiag_get_aux)(struct sock *sk,
+					 bool net_admin,
+					 struct sk_buff *skb);
+
+	size_t		(*idiag_get_aux_size)(struct sock *sk,
+					      bool net_admin);
+
 	int		(*destroy)(struct sk_buff *in_skb,
 				   const struct inet_diag_req_v2 *req);
 
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 67325d5832d7..8a88ef373395 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -93,8 +93,17 @@ void inet_diag_msg_common_fill(struct inet_diag_msg *r, struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(inet_diag_msg_common_fill);
 
-static size_t inet_sk_attr_size(void)
+static size_t inet_sk_attr_size(struct sock *sk,
+				const struct inet_diag_req_v2 *req,
+				bool net_admin)
 {
+	const struct inet_diag_handler *handler;
+	size_t aux = 0;
+
+	handler = inet_diag_table[req->sdiag_protocol];
+	if (handler && handler->idiag_get_aux_size)
+		aux = handler->idiag_get_aux_size(sk, net_admin);
+
 	return	  nla_total_size(sizeof(struct tcp_info))
 		+ nla_total_size(1) /* INET_DIAG_SHUTDOWN */
 		+ nla_total_size(1) /* INET_DIAG_TOS */
@@ -105,6 +114,7 @@ static size_t inet_sk_attr_size(void)
 		+ nla_total_size(SK_MEMINFO_VARS * sizeof(u32))
 		+ nla_total_size(TCP_CA_NAME_MAX)
 		+ nla_total_size(sizeof(struct tcpvegas_info))
+		+ nla_total_size(aux)
 		+ 64;
 }
 
@@ -260,6 +270,10 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 
 	handler->idiag_get_info(sk, r, info);
 
+	if (ext & (1 << (INET_DIAG_INFO - 1)) && handler->idiag_get_aux)
+		if (handler->idiag_get_aux(sk, net_admin, skb) < 0)
+			goto errout;
+
 	if (sk->sk_state < TCP_TIME_WAIT) {
 		union tcp_cc_info info;
 		size_t sz = 0;
@@ -452,13 +466,14 @@ int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo,
 	struct net *net = sock_net(in_skb->sk);
 	struct sk_buff *rep;
 	struct sock *sk;
+	bool net_admin = netlink_net_capable(in_skb, CAP_NET_ADMIN);
 	int err;
 
 	sk = inet_diag_find_one_icsk(net, hashinfo, req);
 	if (IS_ERR(sk))
 		return PTR_ERR(sk);
 
-	rep = nlmsg_new(inet_sk_attr_size(), GFP_KERNEL);
+	rep = nlmsg_new(inet_sk_attr_size(sk, req, net_admin), GFP_KERNEL);
 	if (!rep) {
 		err = -ENOMEM;
 		goto out;
@@ -467,8 +482,7 @@ int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo,
 	err = sk_diag_fill(sk, rep, req,
 			   sk_user_ns(NETLINK_CB(in_skb).sk),
 			   NETLINK_CB(in_skb).portid,
-			   nlh->nlmsg_seq, 0, nlh,
-			   netlink_net_capable(in_skb, CAP_NET_ADMIN));
+			   nlh->nlmsg_seq, 0, nlh, net_admin);
 	if (err < 0) {
 		WARN_ON(err == -EMSGSIZE);
 		nlmsg_free(rep);
-- 
2.14.1
