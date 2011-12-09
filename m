From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 8/13] inet_diag: Generalize inet_diag dump and get_exact calls
Date: Fri, 09 Dec 2011 20:23:18 +0400
Message-ID: <4EE235F6.80009@parallels.com>
References: <4EE23561.5020804@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:38339 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750780Ab1LIQXX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Dec 2011 11:23:23 -0500
In-Reply-To: <4EE23561.5020804@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce two callbacks in inet_diag_handler -- one for dumping all
sockets (with filters) and the other one for dumping a single sk.

Replace direct calls to icsk handlers with indirect calls to callbacks
provided by handlers.

Make existing TCP and DCCP handlers use provided helpers for icsk-s.

The UDP diag module will provide its own.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/inet_diag.h |   18 +++++++++++++++++-
 net/dccp/diag.c           |   15 ++++++++++++++-
 net/ipv4/inet_diag.c      |   11 ++++++-----
 net/ipv4/tcp_diag.c       |   15 ++++++++++++++-
 4 files changed, 51 insertions(+), 8 deletions(-)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index eaf5865..78972a1 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -138,9 +138,18 @@ struct inet_hashinfo;
 struct nlattr;
 struct nlmsghdr;
 struct sk_buff;
+struct netlink_callback;
 
 struct inet_diag_handler {
-	struct inet_hashinfo    *idiag_hashinfo;
+	void			(*dump)(struct sk_buff *skb,
+					struct netlink_callback *cb,
+					struct inet_diag_req *r,
+					struct nlattr *bc);
+
+	int			(*dump_one)(struct sk_buff *in_skb,
+					const struct nlmsghdr *nlh,
+					struct inet_diag_req *req);
+
 	void			(*idiag_get_info)(struct sock *sk,
 						  struct inet_diag_msg *r,
 						  void *info);
@@ -152,6 +161,13 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 			      struct sk_buff *skb, struct inet_diag_req *req,
 			      u32 pid, u32 seq, u16 nlmsg_flags,
 			      const struct nlmsghdr *unlh);
+void inet_diag_dump_icsk(struct inet_hashinfo *h, struct sk_buff *skb,
+		struct netlink_callback *cb, struct inet_diag_req *r,
+		struct nlattr *bc);
+int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo,
+		struct sk_buff *in_skb, const struct nlmsghdr *nlh,
+		struct inet_diag_req *req);
+
 int inet_diag_bc_sk(const struct nlattr *_bc, struct sock *sk);
 int inet_diag_check_cookie(struct sock *sk, struct inet_diag_req *req);
 
diff --git a/net/dccp/diag.c b/net/dccp/diag.c
index 9343f52..e29214d 100644
--- a/net/dccp/diag.c
+++ b/net/dccp/diag.c
@@ -48,8 +48,21 @@ static void dccp_diag_get_info(struct sock *sk, struct inet_diag_msg *r,
 		dccp_get_info(sk, _info);
 }
 
+static void dccp_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
+		struct inet_diag_req *r, struct nlattr *bc)
+{
+	inet_diag_dump_icsk(&dccp_hashinfo, skb, cb, r, bc);
+}
+
+static int dccp_diag_dump_one(struct sk_buff *in_skb, const struct nlmsghdr *nlh,
+		struct inet_diag_req *req)
+{
+	return inet_diag_dump_one_icsk(&dccp_hashinfo, in_skb, nlh, req);
+}
+
 static const struct inet_diag_handler dccp_diag_handler = {
-	.idiag_hashinfo	 = &dccp_hashinfo,
+	.dump		 = dccp_diag_dump,
+	.dump_one	 = dccp_diag_dump_one,
 	.idiag_get_info	 = dccp_diag_get_info,
 	.idiag_type	 = IPPROTO_DCCP,
 };
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index dc8611e..9b3e0b1 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -273,7 +273,7 @@ int inet_diag_check_cookie(struct sock *sk, struct inet_diag_req *req)
 }
 EXPORT_SYMBOL_GPL(inet_diag_check_cookie);
 
-static int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *in_skb,
+int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *in_skb,
 		const struct nlmsghdr *nlh, struct inet_diag_req *req)
 {
 	int err;
@@ -339,6 +339,7 @@ out:
 out_nosk:
 	return err;
 }
+EXPORT_SYMBOL_GPL(inet_diag_dump_one_icsk);
 
 static int inet_diag_get_exact(struct sk_buff *in_skb,
 			       const struct nlmsghdr *nlh,
@@ -351,8 +352,7 @@ static int inet_diag_get_exact(struct sk_buff *in_skb,
 	if (IS_ERR(handler))
 		err = PTR_ERR(handler);
 	else
-		err = inet_diag_dump_one_icsk(handler->idiag_hashinfo,
-				in_skb, nlh, req);
+		err = handler->dump_one(in_skb, nlh, req);
 	inet_diag_unlock_handler(handler);
 
 	return err;
@@ -731,7 +731,7 @@ out:
 	return err;
 }
 
-static void inet_diag_dump_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *skb,
+void inet_diag_dump_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *skb,
 		struct netlink_callback *cb, struct inet_diag_req *r, struct nlattr *bc)
 {
 	int i, num;
@@ -880,6 +880,7 @@ done:
 out:
 	;
 }
+EXPORT_SYMBOL_GPL(inet_diag_dump_icsk);
 
 static int __inet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
 		struct inet_diag_req *r, struct nlattr *bc)
@@ -888,7 +889,7 @@ static int __inet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
 
 	handler = inet_diag_lock_handler(r->sdiag_protocol);
 	if (!IS_ERR(handler))
-		inet_diag_dump_icsk(handler->idiag_hashinfo, skb, cb, r, bc);
+		handler->dump(skb, cb, r, bc);
 	inet_diag_unlock_handler(handler);
 
 	return skb->len;
diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
index 42e6bec..6334b1f 100644
--- a/net/ipv4/tcp_diag.c
+++ b/net/ipv4/tcp_diag.c
@@ -34,8 +34,21 @@ static void tcp_diag_get_info(struct sock *sk, struct inet_diag_msg *r,
 		tcp_get_info(sk, info);
 }
 
+static void tcp_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
+		struct inet_diag_req *r, struct nlattr *bc)
+{
+	inet_diag_dump_icsk(&tcp_hashinfo, skb, cb, r, bc);
+}
+
+static int tcp_diag_dump_one(struct sk_buff *in_skb, const struct nlmsghdr *nlh,
+		struct inet_diag_req *req)
+{
+	return inet_diag_dump_one_icsk(&tcp_hashinfo, in_skb, nlh, req);
+}
+
 static const struct inet_diag_handler tcp_diag_handler = {
-	.idiag_hashinfo	 = &tcp_hashinfo,
+	.dump		 = tcp_diag_dump,
+	.dump_one	 = tcp_diag_dump_one,
 	.idiag_get_info	 = tcp_diag_get_info,
 	.idiag_type	 = IPPROTO_TCP,
 };
-- 
1.5.5.6
