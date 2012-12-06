From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net] inet_diag: fix oops for IPv4 AF_INET6 TCP SYN-RECV state
Date: Thu,  6 Dec 2012 10:42:26 -0500
Message-ID: <1354808546-644-1-git-send-email-ncardwell@google.com>
Cc: edumazet@google.com, netdev@vger.kernel.org,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f202.google.com ([209.85.220.202]:55520 "EHLO
	mail-vc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423892Ab2LFPma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 10:42:30 -0500
Received: by mail-vc0-f202.google.com with SMTP id m8so673526vcd.1
        for <netdev@vger.kernel.org>; Thu, 06 Dec 2012 07:42:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix inet_diag to be aware of the fact that AF_INET6 TCP connections
instantiated for IPv4 traffic and in the SYN-RECV state were actually
created with inet_reqsk_alloc(), instead of inet6_reqsk_alloc(). This
means that for such connections inet6_rsk(req) returns a pointer to a
random spot in memory up to roughly 64KB beyond the end of the
request_sock.

With this bug, for a server using AF_INET6 TCP sockets and serving
IPv4 traffic, an inet_diag user like `ss state SYN-RECV` would lead to
inet_diag_fill_req() causing an oops or the export to user space of 16
bytes of kernel memory as a garbage IPv6 address, depending on where
the garbage inet6_rsk(req) pointed.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/inet_diag.c |   53 ++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 39 insertions(+), 14 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 0c34bfa..35c3de4 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -44,6 +44,10 @@ struct inet_diag_entry {
 	u16 dport;
 	u16 family;
 	u16 userlocks;
+#if IS_ENABLED(CONFIG_IPV6)
+	struct in6_addr saddr_storage;	/* for IPv4-mapped-IPv6 addresses */
+	struct in6_addr daddr_storage;	/* for IPv4-mapped-IPv6 addresses */
+#endif
 };
 
 static DEFINE_MUTEX(inet_diag_table_mutex);
@@ -67,6 +71,36 @@ static inline void inet_diag_unlock_handler(
 	mutex_unlock(&inet_diag_table_mutex);
 }
 
+
+/* Get the IPv4, IPv6, or IPv4-mapped-IPv6 local and remote addresses
+ * from a request_sock. For IPv4-mapped-IPv6 we must map IPv4 to IPv6.
+ */
+static inline void inet_diag_req_addrs(const struct sock *sk,
+				       const struct request_sock *req,
+				       struct inet_diag_entry *entry)
+{
+	struct inet_request_sock *ireq = inet_rsk(req);
+
+#if IS_ENABLED(CONFIG_IPV6)
+	if (sk->sk_family == AF_INET6) {
+		if (req->rsk_ops->family == AF_INET6) {
+			entry->saddr = inet6_rsk(req)->loc_addr.s6_addr32;
+			entry->daddr = inet6_rsk(req)->rmt_addr.s6_addr32;
+		} else if (req->rsk_ops->family == AF_INET) {
+			ipv6_addr_set_v4mapped(ireq->loc_addr,
+					       &entry->saddr_storage);
+			ipv6_addr_set_v4mapped(ireq->rmt_addr,
+					       &entry->daddr_storage);
+			entry->saddr = entry->saddr_storage.s6_addr32;
+			entry->daddr = entry->daddr_storage.s6_addr32;
+		}
+		return;
+	}
+#endif
+	entry->saddr = &ireq->loc_addr;
+	entry->daddr = &ireq->rmt_addr;
+}
+
 int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 			      struct sk_buff *skb, struct inet_diag_req_v2 *req,
 			      struct user_namespace *user_ns,		      	
@@ -637,8 +671,10 @@ static int inet_diag_fill_req(struct sk_buff *skb, struct sock *sk,
 	r->idiag_inode = 0;
 #if IS_ENABLED(CONFIG_IPV6)
 	if (r->idiag_family == AF_INET6) {
-		*(struct in6_addr *)r->id.idiag_src = inet6_rsk(req)->loc_addr;
-		*(struct in6_addr *)r->id.idiag_dst = inet6_rsk(req)->rmt_addr;
+		struct inet_diag_entry entry;
+		inet_diag_req_addrs(sk, req, &entry);
+		memcpy(r->id.idiag_src, entry.saddr, sizeof(struct in6_addr));
+		memcpy(r->id.idiag_dst, entry.daddr, sizeof(struct in6_addr));
 	}
 #endif
 
@@ -691,18 +727,7 @@ static int inet_diag_dump_reqs(struct sk_buff *skb, struct sock *sk,
 				continue;
 
 			if (bc) {
-				entry.saddr =
-#if IS_ENABLED(CONFIG_IPV6)
-					(entry.family == AF_INET6) ?
-					inet6_rsk(req)->loc_addr.s6_addr32 :
-#endif
-					&ireq->loc_addr;
-				entry.daddr =
-#if IS_ENABLED(CONFIG_IPV6)
-					(entry.family == AF_INET6) ?
-					inet6_rsk(req)->rmt_addr.s6_addr32 :
-#endif
-					&ireq->rmt_addr;
+				inet_diag_req_addrs(sk, req, &entry);
 				entry.dport = ntohs(ireq->rmt_port);
 
 				if (!inet_diag_bc_run(bc, &entry))
-- 
1.7.7.3
