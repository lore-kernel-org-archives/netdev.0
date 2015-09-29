From: Daniel Mack <daniel@zonque.org>
Subject: [PATCH RFC 7/7] net: dccp: hook up LOCAL_SOCKET_IN netfilter chains
Date: Tue, 29 Sep 2015 13:12:20 +0200
Message-ID: <1443525140-13493-8-git-send-email-daniel@zonque.org>
References: <1443525140-13493-1-git-send-email-daniel@zonque.org>
Cc: daniel@iogearbox.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, fw@strlen.de, balazs.scheidler@balabit.com,
	Daniel Mack <daniel@zonque.org>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1443525140-13493-1-git-send-email-daniel@zonque.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Run the NF_INET_LOCAL_SOCKET_IN netfilter chain rules after the
destination socket for DCCP packets have been looked up.

Signed-off-by: Daniel Mack <daniel@zonque.org>
---
 net/dccp/ipv4.c | 14 +++++++++++++-
 net/dccp/ipv6.c | 14 +++++++++++++-
 2 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index ccf4c56..9746138 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -14,6 +14,7 @@
 #include <linux/icmp.h>
 #include <linux/slab.h>
 #include <linux/module.h>
+#include <linux/netfilter.h>
 #include <linux/skbuff.h>
 #include <linux/random.h>
 
@@ -807,7 +808,7 @@ static int dccp_v4_rcv(struct sk_buff *skb)
 	const struct dccp_hdr *dh;
 	const struct iphdr *iph;
 	struct sock *sk;
-	int min_cov;
+	int ret, min_cov;
 
 	/* Step 1: Check header basics */
 
@@ -857,6 +858,17 @@ static int dccp_v4_rcv(struct sk_buff *skb)
 
 	/*
 	 * Step 2:
+	 *	... or any LOCAL_SOCKET_IN rule disagrees ...
+	 */
+	ret = nf_hook(NFPROTO_IPV4, NF_INET_LOCAL_SOCKET_IN, sk,
+		      skb, skb->dev, NULL, NULL);
+	if (ret != 1) {
+		sock_put(sk);
+		return 0;
+	}
+
+	/*
+	 * Step 2:
 	 *	... or S.state == TIMEWAIT,
 	 *		Generate Reset(No Connection) unless P.type == Reset
 	 *		Drop packet and return
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 5165571..63b51e6 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -14,6 +14,7 @@
 
 #include <linux/module.h>
 #include <linux/random.h>
+#include <linux/netfilter.h>
 #include <linux/slab.h>
 #include <linux/xfrm.h>
 
@@ -691,7 +692,7 @@ static int dccp_v6_rcv(struct sk_buff *skb)
 {
 	const struct dccp_hdr *dh;
 	struct sock *sk;
-	int min_cov;
+	int ret, min_cov;
 
 	/* Step 1: Check header basics */
 
@@ -732,6 +733,17 @@ static int dccp_v6_rcv(struct sk_buff *skb)
 
 	/*
 	 * Step 2:
+	 *	... or any LOCAL_SOCKET_IN rule disagrees ...
+	 */
+	ret = nf_hook(NFPROTO_IPV6, NF_INET_LOCAL_SOCKET_IN, sk,
+		      skb, skb->dev, NULL, NULL);
+	if (ret != 1) {
+		sock_put(sk);
+		return 0;
+	}
+
+	/*
+	 * Step 2:
 	 *	... or S.state == TIMEWAIT,
 	 *		Generate Reset(No Connection) unless P.type == Reset
 	 *		Drop packet and return
-- 
2.5.0

