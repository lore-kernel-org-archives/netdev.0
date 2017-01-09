From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 2/3] net: reduce cycles spend on ICMP replies that
 gets rate limited
Date: Mon, 09 Jan 2017 16:04:09 +0100
Message-ID: <20170109150409.30215.34612.stgit@firesoul>
References: <20170109150246.30215.63371.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com
To: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50456 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1030202AbdAIPEL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Jan 2017 10:04:11 -0500
In-Reply-To: <20170109150246.30215.63371.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch split the global and per (inet)peer ICMP-reply limiter
code, and moves the global limit check to earlier in the packet
processing path.  Thus, avoid spending cycles on ICMP replies that
gets limited/suppressed anyhow.

The global ICMP rate limiter icmp_global_allow() is a good solution,
it just happens too late in the process.  The kernel goes through the
full route lookup (return path) for the ICMP message, before taking
the rate limit decision of not sending the ICMP reply.

Details: The kernels global rate limiter for ICMP messages got added
in commit 4cdf507d5452 ("icmp: add a global rate limitation").  It is
a token bucket limiter with a global lock.  It brilliantly avoids
locking congestion by only updating when 20ms (HZ/50) were elapsed. It
can then avoids taking lock when credit is exhausted (when under
pressure) and time constraint for refill is not yet meet.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 net/ipv4/icmp.c |   71 +++++++++++++++++++++++++++++++++++++------------------
 net/ipv6/icmp.c |   49 ++++++++++++++++++++++++++------------
 2 files changed, 82 insertions(+), 38 deletions(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index b4b9807329a7..58d75ca58b83 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -282,6 +282,33 @@ bool icmp_global_allow(void)
 }
 EXPORT_SYMBOL(icmp_global_allow);
 
+static bool icmpv4_mask_allow(struct net *net, int type, int code)
+{
+	if (type > NR_ICMP_TYPES)
+		return true;
+
+	/* Don't limit PMTU discovery. */
+	if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED)
+		return true;
+
+	/* Limit if icmp type is enabled in ratemask. */
+	if (!((1 << type) & net->ipv4.sysctl_icmp_ratemask))
+		return true;
+
+	return false;
+}
+
+static bool icmpv4_global_allow(struct net *net, int type, int code)
+{
+	if (icmpv4_mask_allow(net, type, code))
+		return true;
+
+	if (icmp_global_allow())
+		return true;
+
+	return false;
+}
+
 /*
  *	Send an ICMP frame.
  */
@@ -290,34 +317,22 @@ static bool icmpv4_xrlim_allow(struct net *net, struct rtable *rt,
 			       struct flowi4 *fl4, int type, int code)
 {
 	struct dst_entry *dst = &rt->dst;
+	struct inet_peer *peer;
 	bool rc = true;
+	int vif;
 
-	if (type > NR_ICMP_TYPES)
-		goto out;
-
-	/* Don't limit PMTU discovery. */
-	if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED)
+	if (icmpv4_mask_allow(net, type, code))
 		goto out;
 
 	/* No rate limit on loopback */
 	if (dst->dev && (dst->dev->flags&IFF_LOOPBACK))
 		goto out;
 
-	/* Limit if icmp type is enabled in ratemask. */
-	if (!((1 << type) & net->ipv4.sysctl_icmp_ratemask))
-		goto out;
-
-	rc = false;
-	if (icmp_global_allow()) {
-		int vif = l3mdev_master_ifindex(dst->dev);
-		struct inet_peer *peer;
-
-		peer = inet_getpeer_v4(net->ipv4.peers, fl4->daddr, vif, 1);
-		rc = inet_peer_xrlim_allow(peer,
-					   net->ipv4.sysctl_icmp_ratelimit);
-		if (peer)
-			inet_putpeer(peer);
-	}
+	vif = l3mdev_master_ifindex(dst->dev);
+	peer = inet_getpeer_v4(net->ipv4.peers, fl4->daddr, vif, 1);
+	rc = inet_peer_xrlim_allow(peer, net->ipv4.sysctl_icmp_ratelimit);
+	if (peer)
+		inet_putpeer(peer);
 out:
 	return rc;
 }
@@ -396,6 +411,8 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	struct inet_sock *inet;
 	__be32 daddr, saddr;
 	u32 mark = IP4_REPLY_MARK(net, skb->mark);
+	int type = icmp_param->data.icmph.type;
+	int code = icmp_param->data.icmph.code;
 
 	if (ip_options_echo(&icmp_param->replyopts.opt.opt, skb))
 		return;
@@ -405,6 +422,10 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 		return;
 	inet = inet_sk(sk);
 
+	/* global icmp_msgs_per_sec */
+	if (!icmpv4_global_allow(net, type, code))
+		goto out_unlock;
+
 	icmp_param->data.icmph.checksum = 0;
 
 	inet->tos = ip_hdr(skb)->tos;
@@ -433,8 +454,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	rt = ip_route_output_key(net, &fl4);
 	if (IS_ERR(rt))
 		goto out_unlock;
-	if (icmpv4_xrlim_allow(net, rt, &fl4, icmp_param->data.icmph.type,
-			       icmp_param->data.icmph.code))
+	if (icmpv4_xrlim_allow(net, rt, &fl4, type, code))
 		icmp_push_reply(icmp_param, &fl4, &ipc, &rt);
 	ip_rt_put(rt);
 out_unlock:
@@ -650,7 +670,11 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 
 	sk = icmp_xmit_lock(net);
 	if (!sk)
-		return;
+		goto out;
+
+	/* Check global sysctl_icmp_msgs_per_sec ratelimit */
+	if (!icmpv4_global_allow(net, type, code))
+		goto out_unlock;
 
 	/*
 	 *	Construct source address and options.
@@ -704,6 +728,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	if (IS_ERR(rt))
 		goto out_unlock;
 
+	/* peer icmp_ratelimit */
 	if (!icmpv4_xrlim_allow(net, rt, &fl4, type, code))
 		goto ende;
 
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 3036f665e6c8..b26ae8b5c1ce 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -168,6 +168,30 @@ static bool is_ineligible(const struct sk_buff *skb)
 	return false;
 }
 
+static bool icmpv6_mask_allow(int type)
+{
+	/* Informational messages are not limited. */
+	if (type & ICMPV6_INFOMSG_MASK)
+		return true;
+
+	/* Do not limit pmtu discovery, it would break it. */
+	if (type == ICMPV6_PKT_TOOBIG)
+		return true;
+
+	return false;
+}
+
+static bool icmpv6_global_allow(int type)
+{
+	if (icmpv6_mask_allow(type))
+		return true;
+
+	if (icmp_global_allow())
+		return true;
+
+	return false;
+}
+
 /*
  * Check the ICMP output rate limit
  */
@@ -178,12 +202,7 @@ static bool icmpv6_xrlim_allow(struct sock *sk, u8 type,
 	struct dst_entry *dst;
 	bool res = false;
 
-	/* Informational messages are not limited. */
-	if (type & ICMPV6_INFOMSG_MASK)
-		return true;
-
-	/* Do not limit pmtu discovery, it would break it. */
-	if (type == ICMPV6_PKT_TOOBIG)
+	if (icmpv6_mask_allow(type))
 		return true;
 
 	/*
@@ -200,20 +219,16 @@ static bool icmpv6_xrlim_allow(struct sock *sk, u8 type,
 	} else {
 		struct rt6_info *rt = (struct rt6_info *)dst;
 		int tmo = net->ipv6.sysctl.icmpv6_time;
+		struct inet_peer *peer;
 
 		/* Give more bandwidth to wider prefixes. */
 		if (rt->rt6i_dst.plen < 128)
 			tmo >>= ((128 - rt->rt6i_dst.plen)>>5);
 
-		if (icmp_global_allow()) {
-			struct inet_peer *peer;
-
-			peer = inet_getpeer_v6(net->ipv6.peers,
-					       &fl6->daddr, 1);
-			res = inet_peer_xrlim_allow(peer, tmo);
-			if (peer)
-				inet_putpeer(peer);
-		}
+		peer = inet_getpeer_v6(net->ipv6.peers, &fl6->daddr, 1);
+		res = inet_peer_xrlim_allow(peer, tmo);
+		if (peer)
+			inet_putpeer(peer);
 	}
 	dst_release(dst);
 	return res;
@@ -493,6 +508,10 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info,
 	sk = icmpv6_xmit_lock(net);
 	if (!sk)
 		return;
+
+	if (!icmpv6_global_allow(type))
+		goto out;
+
 	sk->sk_mark = mark;
 	np = inet6_sk(sk);
 
