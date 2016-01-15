From: Adam Seering <adam@seering.org>
Subject: [PATCH] appletalk: Pass IP-over-DDP packets through when 'ipddp0'
 interface is not present
Date: Thu, 14 Jan 2016 23:40:47 -0500
Message-ID: <1452832847.1707.42.camel@seering.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from resqmta-ch2-10v.sys.comcast.net ([69.252.207.42]:54926 "EHLO
	resqmta-ch2-10v.sys.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752354AbcAOEtN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 23:49:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Let userspace programs transmit and receive raw IP-over-DDP packets
with a kernel where "ipddp" was compiled as a module but is not loaded
(so no "ipddp0" network interface is exposed).  This makes the "module
is unloaded" behavior match the "module was never compiled" behavior.

Signed-off-by: Adam Seering <adam@seering.org>

---

This is a small proposed change to the ddp code.  It's also my first attempt at a kernel patch; I'd appreciate any feedback or discussion.  I'm working on the Linux "macipgw" port; it duplicates some functionality of the "ipddp" module, but the latter depends on userspace utilities which I can no longer find up-to-date working copies of?


diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index d5871ac..d30e55f 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1284,17 +1284,10 @@ static __inline__ int is_ip_over_ddp(struct sk_buff *skb)
 	return skb->data[12] == 22;
 }
 
-static int handle_ip_over_ddp(struct sk_buff *skb)
+static int handle_ip_over_ddp(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_device *dev = __dev_get_by_name(&init_net, "ipddp0");
 	struct net_device_stats *stats;
 
-	/* This needs to be able to handle ipddp"N" devices */
-	if (!dev) {
-		kfree_skb(skb);
-		return NET_RX_DROP;
-	}
-
 	skb->protocol = htons(ETH_P_IP);
 	skb_pull(skb, 13);
 	skb->dev   = dev;
@@ -1308,7 +1301,7 @@ static int handle_ip_over_ddp(struct sk_buff *skb)
 #else
 /* make it easy for gcc to optimize this test out, i.e. kill the code */
 #define is_ip_over_ddp(skb) 0
-#define handle_ip_over_ddp(skb) 0
+#define handle_ip_over_ddp(skb, dev) 0
 #endif
 
 static int atalk_route_packet(struct sk_buff *skb, struct net_device *dev,
@@ -1418,6 +1411,8 @@ static int atalk_rcv(struct sk_buff *skb, struct net_device *dev,
 	struct sock *sock;
 	struct atalk_iface *atif;
 	struct sockaddr_at tosat;
+	struct net_device *ipddp_dev;
+
 	int origlen;
 	__u16 len_hops;
 
@@ -1473,9 +1468,14 @@ static int atalk_rcv(struct sk_buff *skb, struct net_device *dev,
 		return atalk_route_packet(skb, dev, ddp, len_hops, origlen);
 	}
 
-	/* if IP over DDP is not selected this code will be optimized out */
-	if (is_ip_over_ddp(skb))
-		return handle_ip_over_ddp(skb);
+	/* if IP over DDP is not selected this code should be optimized out */
+	if (is_ip_over_ddp(skb)) {
+		ipddp_dev = __dev_get_by_name(&init_net, "ipddp0");
+
+		/* This needs to be able to handle ipddp"N" devices */
+		if (ipddp_dev)
+			return handle_ip_over_ddp(skb, ipddp_dev);
+	}
 	/*
 	 * Which socket - atalk_search_socket() looks for a *full match*
 	 * of the <net, node, port> tuple.
