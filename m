From: Paolo Abeni <pabeni@redhat.com>
Subject: [RFC PATCH 10/11] IP: early demux can return an error code
Date: Tue, 26 Sep 2017 22:18:52 +0200
Message-ID: <e0d6b84bd95f975183dd96d34909867bf2617d19.1506114055.git.pabeni@redhat.com>
References: <cover.1506114055.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6184 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935846AbdIZUTH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 16:19:07 -0400
In-Reply-To: <cover.1506114055.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

it will used by later patch to cope with unconnected sockets.
Since early demux can do a route lookup and an ipv4 route
lookup can return an error code this is consistent with the
current ipv4 route infrastructure.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
This patch and the next one did not land on the ML previously
due to PEBKAC, appending now to give the complete picture of
this RFC series.
Side note: currently the early demux lookup for mcast sockets
does not perform source address validation and we need (also)
something like this commit to fix the issue without causing
large performance regressions.
---
 include/net/protocol.h |  4 ++--
 include/net/tcp.h      |  2 +-
 include/net/udp.h      |  2 +-
 net/ipv4/ip_input.c    | 25 +++++++++++++++----------
 net/ipv4/tcp_ipv4.c    |  9 +++++----
 net/ipv4/udp.c         | 11 ++++++-----
 6 files changed, 30 insertions(+), 23 deletions(-)

diff --git a/include/net/protocol.h b/include/net/protocol.h
index 65ba335b0e7e..4fc75f7ae23b 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -39,8 +39,8 @@
 
 /* This is used to register protocols. */
 struct net_protocol {
-	void			(*early_demux)(struct sk_buff *skb);
-	void                    (*early_demux_handler)(struct sk_buff *skb);
+	int			(*early_demux)(struct sk_buff *skb);
+	int			(*early_demux_handler)(struct sk_buff *skb);
 	int			(*handler)(struct sk_buff *skb);
 	void			(*err_handler)(struct sk_buff *skb, u32 info);
 	unsigned int		no_policy:1,
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 49a8a46466f3..cf0bb918c52d 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -345,7 +345,7 @@ void tcp_v4_err(struct sk_buff *skb, u32);
 
 void tcp_shutdown(struct sock *sk, int how);
 
-void tcp_v4_early_demux(struct sk_buff *skb);
+int tcp_v4_early_demux(struct sk_buff *skb);
 int tcp_v4_rcv(struct sk_buff *skb);
 
 int tcp_v4_tw_remember_stamp(struct inet_timewait_sock *tw);
diff --git a/include/net/udp.h b/include/net/udp.h
index 12dfbfe2e2d7..6c759c8594e2 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -259,7 +259,7 @@ static inline struct sk_buff *skb_recv_udp(struct sock *sk, unsigned int flags,
 	return __skb_recv_udp(sk, flags, noblock, &peeked, &off, err);
 }
 
-void udp_v4_early_demux(struct sk_buff *skb);
+int udp_v4_early_demux(struct sk_buff *skb);
 bool udp_sk_rx_dst_set(struct sock *sk, struct dst_entry *dst);
 int udp_get_port(struct sock *sk, unsigned short snum,
 		 int (*saddr_cmp)(const struct sock *,
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 5690ef09da28..f172be87674f 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -311,9 +311,10 @@ static inline bool ip_rcv_options(struct sk_buff *skb)
 static int ip_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	const struct iphdr *iph = ip_hdr(skb);
-	struct rtable *rt;
+	int (*edemux)(struct sk_buff *skb);
 	struct net_device *dev = skb->dev;
-	void (*edemux)(struct sk_buff *skb);
+	struct rtable *rt;
+	int err;
 
 	/* if ingress device is enslaved to an L3 master device pass the
 	 * skb to its handler for processing
@@ -331,7 +332,9 @@ static int ip_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 
 		ipprot = rcu_dereference(inet_protos[protocol]);
 		if (ipprot && (edemux = READ_ONCE(ipprot->early_demux))) {
-			edemux(skb);
+			err = edemux(skb);
+			if (unlikely(err))
+				goto drop_error;
 			/* must reload iph, skb->head might have changed */
 			iph = ip_hdr(skb);
 		}
@@ -342,13 +345,10 @@ static int ip_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 	 *	how the packet travels inside Linux networking.
 	 */
 	if (!skb_valid_dst(skb)) {
-		int err = ip_route_input_noref(skb, iph->daddr, iph->saddr,
-					       iph->tos, dev);
-		if (unlikely(err)) {
-			if (err == -EXDEV)
-				__NET_INC_STATS(net, LINUX_MIB_IPRPFILTER);
-			goto drop;
-		}
+		err = ip_route_input_noref(skb, iph->daddr, iph->saddr,
+					   iph->tos, dev);
+		if (unlikely(err))
+			goto drop_error;
 	}
 
 	/* Since the sk has no reference to the socket, we must
@@ -407,6 +407,11 @@ static int ip_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 drop:
 	kfree_skb(skb);
 	return NET_RX_DROP;
+
+drop_error:
+	if (err == -EXDEV)
+		__NET_INC_STATS(net, LINUX_MIB_IPRPFILTER);
+	goto drop;
 }
 
 /*
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index d9416b5162bc..85164d4d3e53 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1503,23 +1503,23 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(tcp_v4_do_rcv);
 
-void tcp_v4_early_demux(struct sk_buff *skb)
+int tcp_v4_early_demux(struct sk_buff *skb)
 {
 	const struct iphdr *iph;
 	const struct tcphdr *th;
 	struct sock *sk;
 
 	if (skb->pkt_type != PACKET_HOST)
-		return;
+		return 0;
 
 	if (!pskb_may_pull(skb, skb_transport_offset(skb) + sizeof(struct tcphdr)))
-		return;
+		return 0;
 
 	iph = ip_hdr(skb);
 	th = tcp_hdr(skb);
 
 	if (th->doff < sizeof(struct tcphdr) / 4)
-		return;
+		return 0;
 
 	sk = __inet_lookup_established(dev_net(skb->dev), &tcp_hashinfo,
 				       iph->saddr, th->source,
@@ -1538,6 +1538,7 @@ void tcp_v4_early_demux(struct sk_buff *skb)
 				skb_dst_set_noref(skb, dst);
 		}
 	}
+	return 0;
 }
 
 bool tcp_add_backlog(struct sock *sk, struct sk_buff *skb)
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 5cbbd78024dc..b7202a15f360 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2215,7 +2215,7 @@ void udp_set_skb_rx_dst(struct sock *sk, struct sk_buff *skb, u32 cookie)
 }
 EXPORT_SYMBOL_GPL(udp_set_skb_rx_dst);
 
-void udp_v4_early_demux(struct sk_buff *skb)
+int udp_v4_early_demux(struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb->dev);
 	int dif = skb->dev->ifindex;
@@ -2227,7 +2227,7 @@ void udp_v4_early_demux(struct sk_buff *skb)
 
 	/* validate the packet */
 	if (!pskb_may_pull(skb, skb_transport_offset(skb) + sizeof(struct udphdr)))
-		return;
+		return 0;
 
 	iph = ip_hdr(skb);
 	uh = udp_hdr(skb);
@@ -2237,14 +2237,14 @@ void udp_v4_early_demux(struct sk_buff *skb)
 		struct in_device *in_dev = __in_dev_get_rcu(skb->dev);
 
 		if (!in_dev)
-			return;
+			return 0;
 
 		/* we are supposed to accept bcast packets */
 		if (skb->pkt_type == PACKET_MULTICAST) {
 			ours = ip_check_mc_rcu(in_dev, iph->daddr, iph->saddr,
 					       iph->protocol);
 			if (!ours)
-				return;
+				return 0;
 		}
 
 		sk = __udp4_lib_mcast_demux_lookup(net, uh->dest, iph->daddr,
@@ -2256,11 +2256,12 @@ void udp_v4_early_demux(struct sk_buff *skb)
 	}
 
 	if (!sk)
-		return;
+		return 0;
 
 	skb_set_noref_sk(skb, sk);
 	if (udp_use_rx_dst_cache(sk, skb))
 		udp_set_skb_rx_dst(sk, skb, 0);
+	return 0;
 }
 
 int udp_rcv(struct sk_buff *skb)
-- 
2.13.5
