From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [net-next PATCH v2 5/9] llc: optimize multicast delivery
Date: Thu, 24 Dec 2009 01:45:30 +0200
Message-ID: <1261611934-24348-6-git-send-email-opurdila@ixiacom.com>
References: <1261611934-24348-1-git-send-email-opurdila@ixiacom.com>
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Octavian Purdila <opurdila@ixiacom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:23684 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757548AbZLWXtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 18:49:12 -0500
In-Reply-To: <1261611934-24348-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Optimize multicast delivery by doing the actual delivery without
holding the lock. Based on the same approach used in UDP code.

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 net/llc/llc_sap.c |   36 ++++++++++++++++++++++++++++--------
 1 files changed, 28 insertions(+), 8 deletions(-)

diff --git a/net/llc/llc_sap.c b/net/llc/llc_sap.c
index f154ab5..6a06b89 100644
--- a/net/llc/llc_sap.c
+++ b/net/llc/llc_sap.c
@@ -355,6 +355,24 @@ static inline bool llc_mcast_match(const struct llc_sap *sap,
 	  llc->dev == skb->dev;
 }
 
+static void llc_do_mcast(struct llc_sap *sap, struct sk_buff *skb,
+			 struct sock **stack, int count)
+{
+	struct sk_buff *skb1;
+	int i;
+
+	for (i = 0; i < count; i++) {
+		skb1 = skb_clone(skb, GFP_ATOMIC);
+		if (!skb1) {
+			sock_put(stack[i]);
+			continue;
+		}
+
+		llc_sap_rcv(sap, skb1, stack[i]);
+		sock_put(stack[i]);
+	}
+}
+
 /**
  * 	llc_sap_mcast - Deliver multicast PDU's to all matching datagram sockets.
  *	@sap: SAP
@@ -367,25 +385,27 @@ static void llc_sap_mcast(struct llc_sap *sap,
 			  const struct llc_addr *laddr,
 			  struct sk_buff *skb)
 {
-	struct sock *sk;
+	int i = 0, count = 256 / sizeof(struct sock *);
+	struct sock *sk, *stack[count];
 	struct hlist_nulls_node *node;
 
 	spin_lock_bh(&sap->sk_lock);
 	sk_nulls_for_each_rcu(sk, node, &sap->sk_list) {
-		struct sk_buff *skb1;
 
 		if (!llc_mcast_match(sap, laddr, skb, sk))
 			continue;
 
-		skb1 = skb_clone(skb, GFP_ATOMIC);
-		if (!skb1)
-			break;
-
 		sock_hold(sk);
-		llc_sap_rcv(sap, skb1, sk);
-		sock_put(sk);
+		if (i < count)
+			stack[i++] = sk;
+		else {
+			llc_do_mcast(sap, skb, stack, i);
+			i = 0;
+		}
 	}
 	spin_unlock_bh(&sap->sk_lock);
+
+	llc_do_mcast(sap, skb, stack, i);
 }
 
 
-- 
1.5.6.5

