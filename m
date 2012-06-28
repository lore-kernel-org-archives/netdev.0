From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Kill early demux method return value.
Date: Wed, 27 Jun 2012 22:07:53 -0700 (PDT)
Message-ID: <20120627.220753.1945337609138098230.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49710 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123Ab2F1FHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 01:07:53 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 5236F5846B3
	for <netdev@vger.kernel.org>; Wed, 27 Jun 2012 22:07:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It's completely unnecessary.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/protocol.h |    2 +-
 include/net/tcp.h      |    2 +-
 net/ipv4/ip_input.c    |   42 +++++++++++++++++++-----------------------
 net/ipv4/tcp_ipv4.c    |   19 ++++++-------------
 4 files changed, 27 insertions(+), 38 deletions(-)

diff --git a/include/net/protocol.h b/include/net/protocol.h
index 967b926..057f2d3 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -37,7 +37,7 @@
 
 /* This is used to register protocols. */
 struct net_protocol {
-	int			(*early_demux)(struct sk_buff *skb);
+	void			(*early_demux)(struct sk_buff *skb);
 	int			(*handler)(struct sk_buff *skb);
 	void			(*err_handler)(struct sk_buff *skb, u32 info);
 	int			(*gso_send_check)(struct sk_buff *skb);
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 6660ffc..53fb7d8 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -325,7 +325,7 @@ extern void tcp_v4_err(struct sk_buff *skb, u32);
 
 extern void tcp_shutdown (struct sock *sk, int how);
 
-extern int tcp_v4_early_demux(struct sk_buff *skb);
+extern void tcp_v4_early_demux(struct sk_buff *skb);
 extern int tcp_v4_rcv(struct sk_buff *skb);
 
 extern struct inet_peer *tcp_v4_get_peer(struct sock *sk);
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 2a39204..b27d444 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -320,33 +320,29 @@ static int ip_rcv_finish(struct sk_buff *skb)
 	const struct iphdr *iph = ip_hdr(skb);
 	struct rtable *rt;
 
+	if (sysctl_ip_early_demux && !skb_dst(skb)) {
+		const struct net_protocol *ipprot;
+		int protocol = iph->protocol;
+
+		rcu_read_lock();
+		ipprot = rcu_dereference(inet_protos[protocol]);
+		if (ipprot && ipprot->early_demux)
+			ipprot->early_demux(skb);
+		rcu_read_unlock();
+	}
+
 	/*
 	 *	Initialise the virtual path cache for the packet. It describes
 	 *	how the packet travels inside Linux networking.
 	 */
-	if (skb_dst(skb) == NULL) {
-		int err = -ENOENT;
-
-		if (sysctl_ip_early_demux) {
-			const struct net_protocol *ipprot;
-			int protocol = iph->protocol;
-
-			rcu_read_lock();
-			ipprot = rcu_dereference(inet_protos[protocol]);
-			if (ipprot && ipprot->early_demux)
-				err = ipprot->early_demux(skb);
-			rcu_read_unlock();
-		}
-
-		if (err) {
-			err = ip_route_input_noref(skb, iph->daddr, iph->saddr,
-						   iph->tos, skb->dev);
-			if (unlikely(err)) {
-				if (err == -EXDEV)
-					NET_INC_STATS_BH(dev_net(skb->dev),
-							 LINUX_MIB_IPRPFILTER);
-				goto drop;
-			}
+	if (!skb_dst(skb)) {
+		int err = ip_route_input_noref(skb, iph->daddr, iph->saddr,
+					       iph->tos, skb->dev);
+		if (unlikely(err)) {
+			if (err == -EXDEV)
+				NET_INC_STATS_BH(dev_net(skb->dev),
+						 LINUX_MIB_IPRPFILTER);
+			goto drop;
 		}
 	}
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 1781dc6..b4ae1c1 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1673,30 +1673,28 @@ csum_err:
 }
 EXPORT_SYMBOL(tcp_v4_do_rcv);
 
-int tcp_v4_early_demux(struct sk_buff *skb)
+void tcp_v4_early_demux(struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb->dev);
 	const struct iphdr *iph;
 	const struct tcphdr *th;
 	struct net_device *dev;
 	struct sock *sk;
-	int err;
 
-	err = -ENOENT;
 	if (skb->pkt_type != PACKET_HOST)
-		goto out_err;
+		return;
 
 	if (!pskb_may_pull(skb, ip_hdrlen(skb) + sizeof(struct tcphdr)))
-		goto out_err;
+		return;
 
 	iph = ip_hdr(skb);
 	th = (struct tcphdr *) ((char *)iph + ip_hdrlen(skb));
 
 	if (th->doff < sizeof(struct tcphdr) / 4)
-		goto out_err;
+		return;
 
 	if (!pskb_may_pull(skb, ip_hdrlen(skb) + th->doff * 4))
-		goto out_err;
+		return;
 
 	dev = skb->dev;
 	sk = __inet_lookup_established(net, &tcp_hashinfo,
@@ -1713,16 +1711,11 @@ int tcp_v4_early_demux(struct sk_buff *skb)
 			if (dst) {
 				struct rtable *rt = (struct rtable *) dst;
 
-				if (rt->rt_iif == dev->ifindex) {
+				if (rt->rt_iif == dev->ifindex)
 					skb_dst_set_noref(skb, dst);
-					err = 0;
-				}
 			}
 		}
 	}
-
-out_err:
-	return err;
 }
 
 /*
-- 
1.7.10
