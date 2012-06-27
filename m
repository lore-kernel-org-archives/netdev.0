From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/7] sock_diag: Do not use RTA_PUT() macros
Date: Wed, 27 Jun 2012 11:36:11 +0200
Message-ID: <aebb990d61eec6d97f1dfe52a0579981c40cce9e.1340788373.git.tgraf@suug.ch>
References: <cover.1340788373.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42780 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755935Ab2F0JgV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2012 05:36:21 -0400
In-Reply-To: <cover.1340788373.git.tgraf@suug.ch>
In-Reply-To: <cover.1340788373.git.tgraf@suug.ch>
References: <cover.1340788373.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/core/sock_diag.c |   12 +++---------
 1 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index 0d934ce..ff2967a 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -4,7 +4,6 @@
 #include <net/netlink.h>
 #include <net/net_namespace.h>
 #include <linux/module.h>
-#include <linux/rtnetlink.h>
 #include <net/sock.h>
 
 #include <linux/inet_diag.h>
@@ -35,9 +34,7 @@ EXPORT_SYMBOL_GPL(sock_diag_save_cookie);
 
 int sock_diag_put_meminfo(struct sock *sk, struct sk_buff *skb, int attrtype)
 {
-	__u32 *mem;
-
-	mem = RTA_DATA(__RTA_PUT(skb, attrtype, SK_MEMINFO_VARS * sizeof(__u32)));
+	u32 mem[SK_MEMINFO_VARS];
 
 	mem[SK_MEMINFO_RMEM_ALLOC] = sk_rmem_alloc_get(sk);
 	mem[SK_MEMINFO_RCVBUF] = sk->sk_rcvbuf;
@@ -48,10 +45,7 @@ int sock_diag_put_meminfo(struct sock *sk, struct sk_buff *skb, int attrtype)
 	mem[SK_MEMINFO_OPTMEM] = atomic_read(&sk->sk_omem_alloc);
 	mem[SK_MEMINFO_BACKLOG] = sk->sk_backlog.len;
 
-	return 0;
-
-rtattr_failure:
-	return -EMSGSIZE;
+	return nla_put(skb, attrtype, sizeof(mem), &mem);
 }
 EXPORT_SYMBOL_GPL(sock_diag_put_meminfo);
 
@@ -121,7 +115,7 @@ static inline void sock_diag_unlock_handler(const struct sock_diag_handler *h)
 static int __sock_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	int err;
-	struct sock_diag_req *req = NLMSG_DATA(nlh);
+	struct sock_diag_req *req = nlmsg_data(nlh);
 	const struct sock_diag_handler *hndl;
 
 	if (nlmsg_len(nlh) < sizeof(*req))
-- 
1.7.7.6
