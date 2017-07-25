From: David Ahern <dsahern@gmail.com>
Subject: [RFC PATCH 01/10] net: Add sk_lookup struct and helper
Date: Tue, 25 Jul 2017 08:38:32 -0700
Message-ID: <1500997121-3218-2-git-send-email-dsahern@gmail.com>
References: <1500997121-3218-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33511 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752734AbdGYPiv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 11:38:51 -0400
Received: by mail-pf0-f194.google.com with SMTP id k72so9809044pfj.0
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 08:38:51 -0700 (PDT)
In-Reply-To: <1500997121-3218-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Consolidate the socket lookup args into a struct.

Add helper that compares sk_bound_dev_if for a socket to the lookup
parameters.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/net/sock.h | 38 ++++++++++++++++++++++++++++++++++++++
 1 file changed, 38 insertions(+)

diff --git a/include/net/sock.h b/include/net/sock.h
index 7c0632c7e870..a2db5fd30192 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -491,6 +491,44 @@ enum sk_pacing {
 #define rcu_dereference_sk_user_data(sk)	rcu_dereference(__sk_user_data((sk)))
 #define rcu_assign_sk_user_data(sk, ptr)	rcu_assign_pointer(__sk_user_data((sk)), ptr)
 
+/* used for socket lookups */
+struct sk_lookup {
+	union {
+		const struct in6_addr *ipv6;
+		__be32 ipv4;
+	} saddr;
+	union {
+		const struct in6_addr *ipv6;
+		__be32 ipv4;
+	} daddr;
+
+	__be16 sport;
+	__be16 dport;
+	unsigned short hnum;
+
+	int dif;
+	bool exact_dif;
+};
+
+/* Compare sk_bound_dev_if to socket lookup dif
+ * Returns:
+ *   -1   exact dif required and not met
+ *    0   sk_bound_dev_if is either not set or does not match
+ *    1   sk_bound_dev_if is set and matches dif
+ */
+static inline int sk_lookup_device_cmp(const struct sock *sk,
+				       const struct sk_lookup *params)
+{
+	/* exact_dif true == l3mdev case */
+	if (params->exact_dif && sk->sk_bound_dev_if != params->dif)
+		return -1;
+
+	if (sk->sk_bound_dev_if && sk->sk_bound_dev_if == params->dif)
+		return 1;
+
+	return 0;
+}
+
 /*
  * SK_CAN_REUSE and SK_NO_REUSE on a socket mean that the socket is OK
  * or not whether his port will be reused by someone else. SK_FORCE_REUSE
-- 
2.1.4
