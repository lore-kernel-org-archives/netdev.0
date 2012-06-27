From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: tcp: dont cache unconfirmed intput dst
Date: Wed, 27 Jun 2012 11:14:15 +0200
Message-ID: <1340788455.26242.67.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:46437 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754651Ab2F0JOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 05:14:20 -0400
Received: by eaak11 with SMTP id k11so275974eaa.19
        for <netdev@vger.kernel.org>; Wed, 27 Jun 2012 02:14:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

DDOS synflood attacks hit badly IP route cache.

On typical machines, this cache is allowed to hold up to 8 Millions dst
entries, 256 bytes for each, for a total of 2GB of memory.

rt_garbage_collect() triggers and tries to cleanup things.

Eventually route cache is disabled but machine is under fire and might
OOM and crash.

This patch exploits the new TCP early demux, to set a nocache
boolean in case incoming TCP frame is for a not yet ESTABLISHED or
TIMEWAIT socket.

This 'nocache' boolean is then used in case dst entry is not found in
route cache, to create an unhashed dst entry (DST_NOCACHE)

SYN-cookie-ACK sent use a similar mechanism (ipv4: tcp: dont cache
output dst for syncookies), so after this patch, a machine is able to
absorb a DDOS synflood attack without polluting its IP route cache.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>
---
 include/net/protocol.h |    2 +-
 include/net/route.h    |    8 ++++----
 include/net/tcp.h      |    2 +-
 net/ipv4/arp.c         |    2 +-
 net/ipv4/ip_fragment.c |    2 +-
 net/ipv4/ip_input.c    |    5 +++--
 net/ipv4/route.c       |    8 +++++---
 net/ipv4/tcp_ipv4.c    |    4 +++-
 net/ipv4/xfrm4_input.c |    2 +-
 9 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/include/net/protocol.h b/include/net/protocol.h
index 967b926..7cfc8f7 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -37,7 +37,7 @@
 
 /* This is used to register protocols. */
 struct net_protocol {
-	int			(*early_demux)(struct sk_buff *skb);
+	int			(*early_demux)(struct sk_buff *skb, bool *nocache);
 	int			(*handler)(struct sk_buff *skb);
 	void			(*err_handler)(struct sk_buff *skb, u32 info);
 	int			(*gso_send_check)(struct sk_buff *skb);
diff --git a/include/net/route.h b/include/net/route.h
index 47eb25a..6361f93 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -201,18 +201,18 @@ static inline struct rtable *ip_route_output_gre(struct net *net, struct flowi4
 }
 
 extern int ip_route_input_common(struct sk_buff *skb, __be32 dst, __be32 src,
-				 u8 tos, struct net_device *devin, bool noref);
+				 u8 tos, struct net_device *devin, bool noref, bool nocache);
 
 static inline int ip_route_input(struct sk_buff *skb, __be32 dst, __be32 src,
 				 u8 tos, struct net_device *devin)
 {
-	return ip_route_input_common(skb, dst, src, tos, devin, false);
+	return ip_route_input_common(skb, dst, src, tos, devin, false, false);
 }
 
 static inline int ip_route_input_noref(struct sk_buff *skb, __be32 dst, __be32 src,
-				       u8 tos, struct net_device *devin)
+				       u8 tos, struct net_device *devin, bool nocache)
 {
-	return ip_route_input_common(skb, dst, src, tos, devin, true);
+	return ip_route_input_common(skb, dst, src, tos, devin, true, nocache);
 }
 
 extern void ipv4_update_pmtu(struct sk_buff *skb, struct net *net, u32 mtu,
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 6660ffc..917ed2e 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -325,7 +325,7 @@ extern void tcp_v4_err(struct sk_buff *skb, u32);
 
 extern void tcp_shutdown (struct sock *sk, int how);
 
-extern int tcp_v4_early_demux(struct sk_buff *skb);
+extern int tcp_v4_early_demux(struct sk_buff *skb, bool *nocache);
 extern int tcp_v4_rcv(struct sk_buff *skb);
 
 extern struct inet_peer *tcp_v4_get_peer(struct sock *sk);
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 2e560f0..6a97959 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -828,7 +828,7 @@ static int arp_process(struct sk_buff *skb)
 	}
 
 	if (arp->ar_op == htons(ARPOP_REQUEST) &&
-	    ip_route_input_noref(skb, tip, sip, 0, dev) == 0) {
+	    ip_route_input_noref(skb, tip, sip, 0, dev, false) == 0) {
 
 		rt = skb_rtable(skb);
 		addr_type = rt->rt_type;
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 8d07c97..978d55f 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -259,7 +259,7 @@ static void ip_expire(unsigned long arg)
 		skb_dst_drop(head);
 		iph = ip_hdr(head);
 		err = ip_route_input_noref(head, iph->daddr, iph->saddr,
-					   iph->tos, head->dev);
+					   iph->tos, head->dev, false);
 		if (err)
 			goto out_rcu_unlock;
 
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 2a39204..7be54c8 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -326,6 +326,7 @@ static int ip_rcv_finish(struct sk_buff *skb)
 	 */
 	if (skb_dst(skb) == NULL) {
 		int err = -ENOENT;
+		bool nocache = false;
 
 		if (sysctl_ip_early_demux) {
 			const struct net_protocol *ipprot;
@@ -334,13 +335,13 @@ static int ip_rcv_finish(struct sk_buff *skb)
 			rcu_read_lock();
 			ipprot = rcu_dereference(inet_protos[protocol]);
 			if (ipprot && ipprot->early_demux)
-				err = ipprot->early_demux(skb);
+				err = ipprot->early_demux(skb, &nocache);
 			rcu_read_unlock();
 		}
 
 		if (err) {
 			err = ip_route_input_noref(skb, iph->daddr, iph->saddr,
-						   iph->tos, skb->dev);
+						   iph->tos, skb->dev, nocache);
 			if (unlikely(err)) {
 				if (err == -EXDEV)
 					NET_INC_STATS_BH(dev_net(skb->dev),
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 81533e3..fdc7900 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2214,7 +2214,7 @@ static int ip_mkroute_input(struct sk_buff *skb,
  */
 
 static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
-			       u8 tos, struct net_device *dev)
+			       u8 tos, struct net_device *dev, bool nocache)
 {
 	struct fib_result res;
 	struct in_device *in_dev = __in_dev_get_rcu(dev);
@@ -2353,6 +2353,8 @@ local_input:
 		rth->dst.error= -err;
 		rth->rt_flags 	&= ~RTCF_LOCAL;
 	}
+	if (nocache)
+		rth->dst.flags |= DST_NOCACHE;
 	hash = rt_hash(daddr, saddr, fl4.flowi4_iif, rt_genid(net));
 	rth = rt_intern_hash(hash, rth, skb, fl4.flowi4_iif);
 	err = 0;
@@ -2395,7 +2397,7 @@ martian_source_keep_err:
 }
 
 int ip_route_input_common(struct sk_buff *skb, __be32 daddr, __be32 saddr,
-			   u8 tos, struct net_device *dev, bool noref)
+			   u8 tos, struct net_device *dev, bool noref, bool nocache)
 {
 	struct rtable	*rth;
 	unsigned int	hash;
@@ -2471,7 +2473,7 @@ skip_cache:
 		rcu_read_unlock();
 		return -EINVAL;
 	}
-	res = ip_route_input_slow(skb, daddr, saddr, tos, dev);
+	res = ip_route_input_slow(skb, daddr, saddr, tos, dev, nocache);
 	rcu_read_unlock();
 	return res;
 }
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 1781dc6..33aabd4 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1673,7 +1673,7 @@ csum_err:
 }
 EXPORT_SYMBOL(tcp_v4_do_rcv);
 
-int tcp_v4_early_demux(struct sk_buff *skb)
+int tcp_v4_early_demux(struct sk_buff *skb, bool *no_dst_cache)
 {
 	struct net *net = dev_net(skb->dev);
 	const struct iphdr *iph;
@@ -1719,6 +1719,8 @@ int tcp_v4_early_demux(struct sk_buff *skb)
 				}
 			}
 		}
+	} else {
+		*no_dst_cache = true;
 	}
 
 out_err:
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index 06814b6..eee636b 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -28,7 +28,7 @@ static inline int xfrm4_rcv_encap_finish(struct sk_buff *skb)
 		const struct iphdr *iph = ip_hdr(skb);
 
 		if (ip_route_input_noref(skb, iph->daddr, iph->saddr,
-					 iph->tos, skb->dev))
+					 iph->tos, skb->dev, false))
 			goto drop;
 	}
 	return dst_input(skb);
