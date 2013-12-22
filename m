From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [PATCH 1/2] net: Allow setting sock flow hash without a sock
Date: Sun, 22 Dec 2013 18:54:31 +0800
Message-ID: <1387709672-21917-2-git-send-email-zwu.kernel@gmail.com>
References: <1387709672-21917-1-git-send-email-zwu.kernel@gmail.com>
Cc: netdev@vger.kernel.org, edumazet@google.com,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:36114 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753649Ab3LVKyz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Dec 2013 05:54:55 -0500
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <zwu.kernel@gmail.com>;
	Sun, 22 Dec 2013 05:54:54 -0500
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 50733C90026
	for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 05:54:49 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp22033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBMAspuC2883862
	for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 10:54:51 GMT
Received: from d01av03.pok.ibm.com (localhost [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBMAsoXV009664
	for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 05:54:51 -0500
In-Reply-To: <1387709672-21917-1-git-send-email-zwu.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>

This patch adds sock_rps_record_flow_hash and sock_rps_reset_flow_hash
which take a hash value as an argument and sets the sock_flow_table
accordingly.  This allows the table to be populated in cases where flow
is being tracked outside of a sock structure.

sock_rps_record_flow and sock_rps_reset_flow call this function
where the hash is taken from sk_rxhash.

Signed-off-by: Tom Herbert <therbert@google.com>
Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 include/net/sock.h |   18 ++++++++++++++----
 1 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 2ef3c3e..8ee90ad 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -820,30 +820,40 @@ static inline int sk_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 	return sk->sk_backlog_rcv(sk, skb);
 }
 
-static inline void sock_rps_record_flow(const struct sock *sk)
+static inline void sock_rps_record_flow_hash(__u32 hash)
 {
 #ifdef CONFIG_RPS
 	struct rps_sock_flow_table *sock_flow_table;
 
 	rcu_read_lock();
 	sock_flow_table = rcu_dereference(rps_sock_flow_table);
-	rps_record_sock_flow(sock_flow_table, sk->sk_rxhash);
+	rps_record_sock_flow(sock_flow_table, hash);
 	rcu_read_unlock();
 #endif
 }
 
-static inline void sock_rps_reset_flow(const struct sock *sk)
+static inline void sock_rps_reset_flow_hash(__u32 hash)
 {
 #ifdef CONFIG_RPS
 	struct rps_sock_flow_table *sock_flow_table;
 
 	rcu_read_lock();
 	sock_flow_table = rcu_dereference(rps_sock_flow_table);
-	rps_reset_sock_flow(sock_flow_table, sk->sk_rxhash);
+	rps_reset_sock_flow(sock_flow_table, hash);
 	rcu_read_unlock();
 #endif
 }
 
+static inline void sock_rps_record_flow(const struct sock *sk)
+{
+	sock_rps_record_flow_hash(sk->sk_rxhash);
+}
+
+static inline void sock_rps_reset_flow(const struct sock *sk)
+{
+	sock_rps_reset_flow_hash(sk->sk_rxhash);
+}
+
 static inline void sock_rps_save_rxhash(struct sock *sk,
 					const struct sk_buff *skb)
 {
-- 
1.7.6.5
