From: David Miller <davem@davemloft.net>
Subject: [PATCH 01/16] ipv4: Pull icmp socket delivery out into a helper
 function.
Date: Thu, 12 Jul 2012 01:10:41 -0700 (PDT)
Message-ID: <20120712.011041.1613421959819826944.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54725 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758778Ab2GLIKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 04:10:42 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 363645824C0
	for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 01:10:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/icmp.c |   31 ++++++++++++++++---------------
 1 file changed, 16 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 4a04944..18e39d1 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -634,18 +634,31 @@ out:;
 EXPORT_SYMBOL(icmp_send);
 
 
+static void icmp_socket_deliver(struct sk_buff *skb, u32 info)
+{
+	const struct iphdr *iph = (const struct iphdr *) skb->data;
+	const struct net_protocol *ipprot;
+	int protocol = iph->protocol;
+
+	raw_icmp_error(skb, protocol, info);
+
+	rcu_read_lock();
+	ipprot = rcu_dereference(inet_protos[protocol]);
+	if (ipprot && ipprot->err_handler)
+		ipprot->err_handler(skb, info);
+	rcu_read_unlock();
+}
+
 /*
  *	Handle ICMP_DEST_UNREACH, ICMP_TIME_EXCEED, and ICMP_QUENCH.
  */
 
 static void icmp_unreach(struct sk_buff *skb)
 {
-	const struct net_protocol *ipprot;
 	const struct iphdr *iph;
 	struct icmphdr *icmph;
 	struct net *net;
 	u32 info = 0;
-	int protocol;
 
 	net = dev_net(skb_dst(skb)->dev);
 
@@ -726,19 +739,7 @@ static void icmp_unreach(struct sk_buff *skb)
 	if (!pskb_may_pull(skb, iph->ihl * 4 + 8))
 		goto out;
 
-	iph = (const struct iphdr *)skb->data;
-	protocol = iph->protocol;
-
-	/*
-	 *	Deliver ICMP message to raw sockets. Pretty useless feature?
-	 */
-	raw_icmp_error(skb, protocol, info);
-
-	rcu_read_lock();
-	ipprot = rcu_dereference(inet_protos[protocol]);
-	if (ipprot && ipprot->err_handler)
-		ipprot->err_handler(skb, info);
-	rcu_read_unlock();
+	icmp_socket_deliver(skb, info);
 
 out:
 	return;
-- 
1.7.10.4
