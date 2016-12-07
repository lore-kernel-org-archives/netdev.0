From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: rfs: add a jump label
Date: Wed, 07 Dec 2016 08:29:10 -0800
Message-ID: <1481128150.4930.25.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Paolo Abeni <pabeni@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34174 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932309AbcLGQaN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 11:30:13 -0500
Received: by mail-pg0-f65.google.com with SMTP id e9so23900665pgc.1
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 08:30:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

RFS is not commonly used, so add a jump label to avoid some conditionals
in fast path.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Paolo Abeni <pabeni@redhat.com>
---
 include/linux/netdevice.h  |    1 +
 include/net/sock.h         |   25 ++++++++++++++-----------
 net/core/dev.c             |    2 ++
 net/core/sysctl_net_core.c |    5 ++++-
 4 files changed, 21 insertions(+), 12 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1ff5ea6e12214db818c2cfa8a9b8ed5cbddc307c..994f7423a74bd622884c3b646f4123d28697b8ad 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -192,6 +192,7 @@ struct net_device_stats {
 #ifdef CONFIG_RPS
 #include <linux/static_key.h>
 extern struct static_key rps_needed;
+extern struct static_key rfs_needed;
 #endif
 
 struct neighbour;
diff --git a/include/net/sock.h b/include/net/sock.h
index 1749e38d03014558ac882b5d1fb37b11ac5e6705..2729e77950b762e2f246646ef80f6cc6c75d7a5d 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -913,17 +913,20 @@ static inline void sock_rps_record_flow_hash(__u32 hash)
 static inline void sock_rps_record_flow(const struct sock *sk)
 {
 #ifdef CONFIG_RPS
-	/* Reading sk->sk_rxhash might incur an expensive cache line miss.
-	 *
-	 * TCP_ESTABLISHED does cover almost all states where RFS
-	 * might be useful, and is cheaper [1] than testing :
-	 *	IPv4: inet_sk(sk)->inet_daddr
-	 * 	IPv6: ipv6_addr_any(&sk->sk_v6_daddr)
-	 * OR	an additional socket flag
-	 * [1] : sk_state and sk_prot are in the same cache line.
-	 */
-	if (sk->sk_state == TCP_ESTABLISHED)
-		sock_rps_record_flow_hash(sk->sk_rxhash);
+	if (static_key_false(&rfs_needed)) {
+		/* Reading sk->sk_rxhash might incur an expensive cache line
+		 * miss.
+		 *
+		 * TCP_ESTABLISHED does cover almost all states where RFS
+		 * might be useful, and is cheaper [1] than testing :
+		 *	IPv4: inet_sk(sk)->inet_daddr
+		 * 	IPv6: ipv6_addr_any(&sk->sk_v6_daddr)
+		 * OR	an additional socket flag
+		 * [1] : sk_state and sk_prot are in the same cache line.
+		 */
+		if (sk->sk_state == TCP_ESTABLISHED)
+			sock_rps_record_flow_hash(sk->sk_rxhash);
+	}
 #endif
 }
 
diff --git a/net/core/dev.c b/net/core/dev.c
index bffb5253e77867b1d6a0ada7cc99f4605e03ad28..1d33ce03365f1e10996ad5274e86bf351a526284 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3447,6 +3447,8 @@ EXPORT_SYMBOL(rps_cpu_mask);
 
 struct static_key rps_needed __read_mostly;
 EXPORT_SYMBOL(rps_needed);
+struct static_key rfs_needed __read_mostly;
+EXPORT_SYMBOL(rfs_needed);
 
 static struct rps_dev_flow *
 set_rps_cpu(struct net_device *dev, struct sk_buff *skb,
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 0df2aa6525308a365d89f57f6da76d57a24238f0..2a46e4009f62d8c2ac8949789ae9626b0c016a11 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -79,10 +79,13 @@ static int rps_sock_flow_sysctl(struct ctl_table *table, int write,
 
 		if (sock_table != orig_sock_table) {
 			rcu_assign_pointer(rps_sock_flow_table, sock_table);
-			if (sock_table)
+			if (sock_table) {
 				static_key_slow_inc(&rps_needed);
+				static_key_slow_inc(&rfs_needed);
+			}
 			if (orig_sock_table) {
 				static_key_slow_dec(&rps_needed);
+				static_key_slow_dec(&rfs_needed);
 				synchronize_rcu();
 				vfree(orig_sock_table);
 			}
