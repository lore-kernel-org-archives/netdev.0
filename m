From: Tom Herbert <therbert@google.com>
Subject: [PATCH 4/5] net: Allow setting sock flow hash without a sock
Date: Wed, 20 Nov 2013 12:27:49 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1311201219590.17745@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, edumazet@google.com, hkchu@google.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f73.google.com ([209.85.220.73]:60218 "EHLO
	mail-pa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754992Ab3KTU1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 15:27:51 -0500
Received: by mail-pa0-f73.google.com with SMTP id kp14so528287pab.0
        for <netdev@vger.kernel.org>; Wed, 20 Nov 2013 12:27:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds sock_rps_record_flow_hash and sock_rps_reset_flow_hash
which take a hash value as an argument and sets the sock_flow_table
accordingly.  This allows the table to be populated in cases where flow
is being tracked outside of a sock structure.

sock_rps_record_flow and sock_rps_reset_flow call this function
where the hash is taken from sk_rxhash.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/sock.h | 18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index e3a18ff..fe2410b 100644
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
1.8.4.1
