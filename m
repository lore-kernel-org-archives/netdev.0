From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] ipv6: protect skb->sk accesses from recursive dereference inside the stack
Date: Wed,  1 Apr 2015 17:07:44 +0200
Message-ID: <1427900864-13891-1-git-send-email-hannes@stressinduktion.org>
Cc: "hannes@stressinduktion.org" <hannes@stressinduktion.org>,
	Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:49998 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750849AbbDAPNH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 11:13:07 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 5533920977
	for <netdev@vger.kernel.org>; Wed,  1 Apr 2015 11:07:47 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "hannes@stressinduktion.org" <hannes@stressinduktion.org>

We should not consult skb->sk for output decisions in xmit recursion
levels > 0 in the stack. Otherwise local socket settings could influence
the result of e.g. tunnel encapsulation process.

ipv6 does not conform with this in three places:

1) ip6_fragment: we do consult ipv6_npinfo for frag_size

2) sk_mc_loop in ipv6 uses skb->sk and checks if we should
   loop the packet back to the local socket

3) ip6_skb_dst_mtu could query the settings from the user socket and
   force a wrong MTU

Furthermore:
In sk_mc_loop we could potentially land in WARN_ON(1) if we use a
PF_PACKET socket ontop of an IPv6-backed vxlan device.

Reuse xmit_recursion as we are currently only interested in protecting
tunnel devices.

Cc: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---

Jiri tried to fix this bug by passing down the tunnel sock pointer.
Currently there should be no difference in behaviour with this patch.

http://patchwork.ozlabs.org/patch/380404/
http://patchwork.ozlabs.org/patch/380406/
http://patchwork.ozlabs.org/patch/380405/

In case we do need more specific fragmentation setup semantics we would
need to go with Jiri's approach. Currently we don't care about sk_mc_loop
for kernel sockets, so it is easy to just shut them up. Other options
are safe as well.

Please review carefully!

 include/linux/netdevice.h |  6 ++++++
 include/net/ip.h          | 16 ----------------
 include/net/ip6_route.h   |  3 ++-
 include/net/sock.h        |  2 ++
 net/core/dev.c            |  4 +++-
 net/core/sock.c           | 19 +++++++++++++++++++
 net/ipv6/ip6_output.c     |  3 ++-
 7 files changed, 34 insertions(+), 19 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 967bb4c..1064075 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2176,6 +2176,12 @@ void netdev_freemem(struct net_device *dev);
 void synchronize_net(void);
 int init_dummy_netdev(struct net_device *dev);
 
+DECLARE_PER_CPU(int, xmit_recursion);
+static inline int dev_recursion_level(void)
+{
+	return this_cpu_read(xmit_recursion);
+}
+
 struct net_device *dev_get_by_index(struct net *net, int ifindex);
 struct net_device *__dev_get_by_index(struct net *net, int ifindex);
 struct net_device *dev_get_by_index_rcu(struct net *net, int ifindex);
diff --git a/include/net/ip.h b/include/net/ip.h
index d0808a3..69cd9cb 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -455,22 +455,6 @@ static __inline__ void inet_reset_saddr(struct sock *sk)
 
 #endif
 
-static inline int sk_mc_loop(struct sock *sk)
-{
-	if (!sk)
-		return 1;
-	switch (sk->sk_family) {
-	case AF_INET:
-		return inet_sk(sk)->mc_loop;
-#if IS_ENABLED(CONFIG_IPV6)
-	case AF_INET6:
-		return inet6_sk(sk)->mc_loop;
-#endif
-	}
-	WARN_ON(1);
-	return 1;
-}
-
 bool ip_call_ra_chain(struct sk_buff *skb);
 
 /*
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 1d09b46..eda131d 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -174,7 +174,8 @@ int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *));
 
 static inline int ip6_skb_dst_mtu(struct sk_buff *skb)
 {
-	struct ipv6_pinfo *np = skb->sk ? inet6_sk(skb->sk) : NULL;
+	struct ipv6_pinfo *np = skb->sk && !dev_recursion_level() ?
+				inet6_sk(skb->sk) : NULL;
 
 	return (np && np->pmtudisc >= IPV6_PMTUDISC_PROBE) ?
 	       skb_dst(skb)->dev->mtu : dst_mtu(skb_dst(skb));
diff --git a/include/net/sock.h b/include/net/sock.h
index 3f9b8ce..bd6f523 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1762,6 +1762,8 @@ struct dst_entry *__sk_dst_check(struct sock *sk, u32 cookie);
 
 struct dst_entry *sk_dst_check(struct sock *sk, u32 cookie);
 
+bool sk_mc_loop(struct sock *sk);
+
 static inline bool sk_can_gso(const struct sock *sk)
 {
 	return net_gso_ok(sk->sk_route_caps, sk->sk_gso_type);
diff --git a/net/core/dev.c b/net/core/dev.c
index 65492b0..08c0df9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2849,7 +2849,9 @@ static void skb_update_prio(struct sk_buff *skb)
 #define skb_update_prio(skb)
 #endif
 
-static DEFINE_PER_CPU(int, xmit_recursion);
+DEFINE_PER_CPU(int, xmit_recursion);
+EXPORT_SYMBOL(xmit_recursion);
+
 #define RECURSION_LIMIT 10
 
 /**
diff --git a/net/core/sock.c b/net/core/sock.c
index 119ae46..654e38a 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -653,6 +653,25 @@ static inline void sock_valbool_flag(struct sock *sk, int bit, int valbool)
 		sock_reset_flag(sk, bit);
 }
 
+bool sk_mc_loop(struct sock *sk)
+{
+	if (dev_recursion_level())
+		return false;
+	if (!sk)
+		return true;
+	switch (sk->sk_family) {
+	case AF_INET:
+		return inet_sk(sk)->mc_loop;
+#if IS_ENABLED(CONFIG_IPV6)
+	case AF_INET6:
+		return inet6_sk(sk)->mc_loop;
+#endif
+	}
+	WARN_ON(1);
+	return true;
+}
+EXPORT_SYMBOL(sk_mc_loop);
+
 /*
  *	This is meant for all protocols to use and covers goings on
  *	at the socket level. Everything here is generic.
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 84c58da..654f245 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -542,7 +542,8 @@ int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 {
 	struct sk_buff *frag;
 	struct rt6_info *rt = (struct rt6_info *)skb_dst(skb);
-	struct ipv6_pinfo *np = skb->sk ? inet6_sk(skb->sk) : NULL;
+	struct ipv6_pinfo *np = skb->sk && !dev_recursion_level() ?
+				inet6_sk(skb->sk) : NULL;
 	struct ipv6hdr *tmp_hdr;
 	struct frag_hdr *fh;
 	unsigned int mtu, hlen, left, len;
-- 
2.1.0
