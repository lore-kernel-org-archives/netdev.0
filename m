From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 3/3] net: for rate-limited ICMP replies save one
 atomic operation
Date: Mon, 09 Jan 2017 16:04:14 +0100
Message-ID: <20170109150414.30215.63724.stgit@firesoul>
References: <20170109150246.30215.63371.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com
To: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50500 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S968799AbdAIPEQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Jan 2017 10:04:16 -0500
In-Reply-To: <20170109150246.30215.63371.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is possible to avoid the atomic operation in icmp{v6,}_xmit_lock,
by checking the sysctl_icmp_msgs_per_sec ratelimit before these calls,
as pointed out by Eric Dumazet, but the BH disabled state must be correct.

The icmp_global_allow() call states it must be called with BH
disabled.  This protection was given by the calls icmp_xmit_lock and
icmpv6_xmit_lock.  Thus, split out local_bh_disable/enable from these
functions and maintain it explicitly at callers.

Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 net/ipv4/icmp.c |   34 +++++++++++++++++++++-------------
 net/ipv6/icmp.c |   25 ++++++++++++++++---------
 2 files changed, 37 insertions(+), 22 deletions(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 58d75ca58b83..fc310db2708b 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -209,19 +209,17 @@ static struct sock *icmp_sk(struct net *net)
 	return *this_cpu_ptr(net->ipv4.icmp_sk);
 }
 
+/* Called with BH disabled */
 static inline struct sock *icmp_xmit_lock(struct net *net)
 {
 	struct sock *sk;
 
-	local_bh_disable();
-
 	sk = icmp_sk(net);
 
 	if (unlikely(!spin_trylock(&sk->sk_lock.slock))) {
 		/* This can happen if the output path signals a
 		 * dst_link_failure() for an outgoing ICMP packet.
 		 */
-		local_bh_enable();
 		return NULL;
 	}
 	return sk;
@@ -229,7 +227,7 @@ static inline struct sock *icmp_xmit_lock(struct net *net)
 
 static inline void icmp_xmit_unlock(struct sock *sk)
 {
-	spin_unlock_bh(&sk->sk_lock.slock);
+	spin_unlock(&sk->sk_lock.slock);
 }
 
 int sysctl_icmp_msgs_per_sec __read_mostly = 1000;
@@ -417,14 +415,17 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	if (ip_options_echo(&icmp_param->replyopts.opt.opt, skb))
 		return;
 
-	sk = icmp_xmit_lock(net);
-	if (!sk)
-		return;
-	inet = inet_sk(sk);
+	/* Needed by both icmp_global_allow and icmp_xmit_lock */
+	local_bh_disable();
 
 	/* global icmp_msgs_per_sec */
 	if (!icmpv4_global_allow(net, type, code))
-		goto out_unlock;
+		goto out_bh_enable;
+
+	sk = icmp_xmit_lock(net);
+	if (!sk)
+		goto out_bh_enable;
+	inet = inet_sk(sk);
 
 	icmp_param->data.icmph.checksum = 0;
 
@@ -459,6 +460,8 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	ip_rt_put(rt);
 out_unlock:
 	icmp_xmit_unlock(sk);
+out_bh_enable:
+	local_bh_enable();
 }
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
@@ -668,13 +671,16 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 		}
 	}
 
-	sk = icmp_xmit_lock(net);
-	if (!sk)
-		goto out;
+	/* Needed by both icmp_global_allow and icmp_xmit_lock */
+	local_bh_disable();
 
 	/* Check global sysctl_icmp_msgs_per_sec ratelimit */
 	if (!icmpv4_global_allow(net, type, code))
-		goto out_unlock;
+		goto out_bh_enable;
+
+	sk = icmp_xmit_lock(net);
+	if (!sk)
+		goto out_bh_enable;
 
 	/*
 	 *	Construct source address and options.
@@ -750,6 +756,8 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	ip_rt_put(rt);
 out_unlock:
 	icmp_xmit_unlock(sk);
+out_bh_enable:
+	local_bh_enable();
 out:;
 }
 EXPORT_SYMBOL(icmp_send);
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index b26ae8b5c1ce..230b5aac9f03 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -110,19 +110,17 @@ static const struct inet6_protocol icmpv6_protocol = {
 	.flags		=	INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
 };
 
+/* Called with BH disabled */
 static __inline__ struct sock *icmpv6_xmit_lock(struct net *net)
 {
 	struct sock *sk;
 
-	local_bh_disable();
-
 	sk = icmpv6_sk(net);
 	if (unlikely(!spin_trylock(&sk->sk_lock.slock))) {
 		/* This can happen if the output path (f.e. SIT or
 		 * ip6ip6 tunnel) signals dst_link_failure() for an
 		 * outgoing ICMP6 packet.
 		 */
-		local_bh_enable();
 		return NULL;
 	}
 	return sk;
@@ -130,7 +128,7 @@ static __inline__ struct sock *icmpv6_xmit_lock(struct net *net)
 
 static __inline__ void icmpv6_xmit_unlock(struct sock *sk)
 {
-	spin_unlock_bh(&sk->sk_lock.slock);
+	spin_unlock(&sk->sk_lock.slock);
 }
 
 /*
@@ -489,6 +487,13 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info,
 		return;
 	}
 
+	/* Needed by both icmp_global_allow and icmpv6_xmit_lock */
+	local_bh_disable();
+
+	/* Check global sysctl_icmp_msgs_per_sec ratelimit */
+	if (!icmpv6_global_allow(type))
+		goto out_bh_enable;
+
 	mip6_addr_swap(skb);
 
 	memset(&fl6, 0, sizeof(fl6));
@@ -507,10 +512,7 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info,
 
 	sk = icmpv6_xmit_lock(net);
 	if (!sk)
-		return;
-
-	if (!icmpv6_global_allow(type))
-		goto out;
+		goto out_bh_enable;
 
 	sk->sk_mark = mark;
 	np = inet6_sk(sk);
@@ -571,6 +573,8 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info,
 	dst_release(dst);
 out:
 	icmpv6_xmit_unlock(sk);
+out_bh_enable:
+	local_bh_enable();
 }
 
 /* Slightly more convenient version of icmp6_send.
@@ -684,9 +688,10 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	fl6.flowi6_uid = sock_net_uid(net, NULL);
 	security_skb_classify_flow(skb, flowi6_to_flowi(&fl6));
 
+	local_bh_disable();
 	sk = icmpv6_xmit_lock(net);
 	if (!sk)
-		return;
+		goto out_bh_enable;
 	sk->sk_mark = mark;
 	np = inet6_sk(sk);
 
@@ -728,6 +733,8 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	dst_release(dst);
 out:
 	icmpv6_xmit_unlock(sk);
+out_bh_enable:
+	local_bh_enable();
 }
 
 void icmpv6_notify(struct sk_buff *skb, u8 type, u8 code, __be32 info)
