From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 6/13] inet_diag: Introduce the byte-code run on an inet socket
Date: Fri, 09 Dec 2011 20:22:44 +0400
Message-ID: <4EE235D4.1000808@parallels.com>
References: <4EE23561.5020804@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:20627 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750831Ab1LIQWt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Dec 2011 11:22:49 -0500
In-Reply-To: <4EE23561.5020804@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The upcoming UDP module will require exactly this ability, so just
move the existing code to provide one.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/inet_diag.h |    2 +
 net/ipv4/inet_diag.c      |   55 +++++++++++++++++++++++++-------------------
 2 files changed, 33 insertions(+), 24 deletions(-)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index 5036747..907c899 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -135,6 +135,7 @@ struct tcpvegas_info {
 #ifdef __KERNEL__
 struct sock;
 struct inet_hashinfo;
+struct nlattr;
 
 struct inet_diag_handler {
 	struct inet_hashinfo    *idiag_hashinfo;
@@ -144,6 +145,7 @@ struct inet_diag_handler {
 	__u16                   idiag_type;
 };
 
+int inet_diag_bc_sk(const struct nlattr *_bc, struct sock *sk);
 int inet_diag_check_cookie(struct sock *sk, struct inet_diag_req *req);
 
 extern int  inet_diag_register(const struct inet_diag_handler *handler);
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index f50df2e..08e5498 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -449,6 +449,35 @@ static int inet_diag_bc_run(const struct nlattr *_bc,
 	return len == 0;
 }
 
+int inet_diag_bc_sk(const struct nlattr *bc, struct sock *sk)
+{
+	struct inet_diag_entry entry;
+	struct inet_sock *inet = inet_sk(sk);
+
+	if (bc == NULL)
+		return 1;
+
+	entry.family = sk->sk_family;
+#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+	if (entry.family == AF_INET6) {
+		struct ipv6_pinfo *np = inet6_sk(sk);
+
+		entry.saddr = np->rcv_saddr.s6_addr32;
+		entry.daddr = np->daddr.s6_addr32;
+	} else
+#endif
+	{
+		entry.saddr = &inet->inet_rcv_saddr;
+		entry.daddr = &inet->inet_daddr;
+	}
+	entry.sport = inet->inet_num;
+	entry.dport = ntohs(inet->inet_dport);
+	entry.userlocks = sk->sk_userlocks;
+
+	return inet_diag_bc_run(bc, &entry);
+}
+EXPORT_SYMBOL_GPL(inet_diag_bc_sk);
+
 static int valid_cc(const void *bc, int len, int cc)
 {
 	while (len >= 0) {
@@ -509,30 +538,8 @@ static int inet_csk_diag_dump(struct sock *sk,
 			      struct inet_diag_req *r,
 			      const struct nlattr *bc)
 {
-	if (bc != NULL) {
-		struct inet_diag_entry entry;
-		struct inet_sock *inet = inet_sk(sk);
-
-		entry.family = sk->sk_family;
-#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
-		if (entry.family == AF_INET6) {
-			struct ipv6_pinfo *np = inet6_sk(sk);
-
-			entry.saddr = np->rcv_saddr.s6_addr32;
-			entry.daddr = np->daddr.s6_addr32;
-		} else
-#endif
-		{
-			entry.saddr = &inet->inet_rcv_saddr;
-			entry.daddr = &inet->inet_daddr;
-		}
-		entry.sport = inet->inet_num;
-		entry.dport = ntohs(inet->inet_dport);
-		entry.userlocks = sk->sk_userlocks;
-
-		if (!inet_diag_bc_run(bc, &entry))
-			return 0;
-	}
+	if (!inet_diag_bc_sk(bc, sk))
+		return 0;
 
 	return inet_csk_diag_fill(sk, skb, r,
 				  NETLINK_CB(cb->skb).pid,
-- 
1.5.5.6
