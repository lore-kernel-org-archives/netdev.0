From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v4 net-next 3/8] udp: Check static key udp_encap_needed in udp_gro_receive
Date: Thu, 28 Sep 2017 16:52:25 -0700
Message-ID: <20170928235230.22158-4-tom@quantonium.net>
References: <20170928235230.22158-1-tom@quantonium.net>
Cc: netdev@vger.kernel.org, rohit@quantonium.net,
        Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:48337 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751880AbdI1XxA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 19:53:00 -0400
Received: by mail-pf0-f175.google.com with SMTP id n24so1630590pfk.5
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2017 16:52:59 -0700 (PDT)
In-Reply-To: <20170928235230.22158-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the only support for udp gro is provided by UDP encapsulation
protocols. Since they always set udp_encap_needed we can check that in
udp_gro_receive functions before performing a socket lookup.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 include/net/udp.h      | 2 ++
 net/ipv4/udp.c         | 4 +++-
 net/ipv4/udp_offload.c | 7 +++++++
 net/ipv6/udp_offload.c | 7 +++++++
 4 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index 12dfbfe2e2d7..c6b1c5d8d3c9 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -97,6 +97,8 @@ static inline struct udp_hslot *udp_hashslot2(struct udp_table *table,
 
 extern struct proto udp_prot;
 
+extern struct static_key udp_encap_needed;
+
 extern atomic_long_t udp_memory_allocated;
 
 /* sysctl variables for udp */
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 784ced0b9150..2788843e8eb2 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1813,7 +1813,9 @@ static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 	return 0;
 }
 
-static struct static_key udp_encap_needed __read_mostly;
+struct static_key udp_encap_needed __read_mostly;
+EXPORT_SYMBOL(udp_encap_needed);
+
 void udp_encap_enable(void)
 {
 	static_key_enable(&udp_encap_needed);
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 97658bfc1b58..a744bb515455 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -261,6 +261,13 @@ static struct sk_buff **udp4_gro_receive(struct sk_buff **head,
 {
 	struct udphdr *uh = udp_gro_udphdr(skb);
 
+	if (!static_key_false(&udp_encap_needed)) {
+		/* Currently udp_gro_receive only does something if
+		 * a UDP encapsulation has been set.
+		 */
+		goto flush;
+	}
+
 	if (unlikely(!uh))
 		goto flush;
 
diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index 455fd4e39333..111b026e4f03 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -34,6 +34,13 @@ static struct sk_buff **udp6_gro_receive(struct sk_buff **head,
 {
 	struct udphdr *uh = udp_gro_udphdr(skb);
 
+	if (!static_key_false(&udp_encap_needed)) {
+		/* Currently udp_gro_receive only does something if
+		 * a UDP encapsulation has been set.
+		 */
+		goto flush;
+	}
+
 	if (unlikely(!uh))
 		goto flush;
 
-- 
2.11.0
