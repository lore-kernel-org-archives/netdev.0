From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: ip_rt_send_redirect() optimization
Date: Mon, 24 Aug 2009 18:47:48 +0200
Message-ID: <4A92C434.1080406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52637 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752676AbZHXQrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2009 12:47:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While doing some forwarding benchmarks, I noticed ip_rt_send_redirect() is rather
expensive, even if send_redirects is false for the device.

Fix is to avoid two atomic ops, we dont really need to take a reference on in_dev

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/route.c |   20 +++++++++++---------
 1 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 278f46f..ffad509 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1514,13 +1514,17 @@ static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst)
 void ip_rt_send_redirect(struct sk_buff *skb)
 {
 	struct rtable *rt = skb_rtable(skb);
-	struct in_device *in_dev = in_dev_get(rt->u.dst.dev);
+	struct in_device *in_dev;
+	int log_martians;
 
-	if (!in_dev)
+	rcu_read_lock();
+	in_dev = __in_dev_get_rcu(rt->u.dst.dev);
+	if (!in_dev || !IN_DEV_TX_REDIRECTS(in_dev)) {
+		rcu_read_unlock();
 		return;
-
-	if (!IN_DEV_TX_REDIRECTS(in_dev))
-		goto out;
+	}
+	log_martians = IN_DEV_LOG_MARTIANS(in_dev);
+	rcu_read_unlock();
 
 	/* No redirected packets during ip_rt_redirect_silence;
 	 * reset the algorithm.
@@ -1533,7 +1537,7 @@ void ip_rt_send_redirect(struct sk_buff *skb)
 	 */
 	if (rt->u.dst.rate_tokens >= ip_rt_redirect_number) {
 		rt->u.dst.rate_last = jiffies;
-		goto out;
+		return;
 	}
 
 	/* Check for load limit; set rate_last to the latest sent
@@ -1547,7 +1551,7 @@ void ip_rt_send_redirect(struct sk_buff *skb)
 		rt->u.dst.rate_last = jiffies;
 		++rt->u.dst.rate_tokens;
 #ifdef CONFIG_IP_ROUTE_VERBOSE
-		if (IN_DEV_LOG_MARTIANS(in_dev) &&
+		if (log_martians &&
 		    rt->u.dst.rate_tokens == ip_rt_redirect_number &&
 		    net_ratelimit())
 			printk(KERN_WARNING "host %pI4/if%d ignores redirects for %pI4 to %pI4.\n",
@@ -1555,8 +1559,6 @@ void ip_rt_send_redirect(struct sk_buff *skb)
 				&rt->rt_dst, &rt->rt_gateway);
 #endif
 	}
-out:
-	in_dev_put(in_dev);
 }
 
 static int ip_error(struct sk_buff *skb)
