From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/5] ipv6: icmp: add a force_saddr param to icmp6_send()
Date: Sat, 18 Jun 2016 16:26:36 -0700
Message-ID: <1466292400-3638-2-git-send-email-edumazet@google.com>
References: <1466292400-3638-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Oussama Ghorbel <ghorbel@pivasoftware.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34108 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751090AbcFRX1A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2016 19:27:00 -0400
Received: by mail-pf0-f178.google.com with SMTP id h14so26628808pfe.1
        for <netdev@vger.kernel.org>; Sat, 18 Jun 2016 16:27:00 -0700 (PDT)
In-Reply-To: <1466292400-3638-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SIT or GRE tunnels might want to translate an IPV4 address
into a v4mapped one when translating ICMP to ICMPv6.

This patch adds the parameter to icmp6_send() but
does not change icmpv6_send() signature.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/icmpv6.h | 3 ++-
 net/ipv6/icmp.c        | 7 +++++--
 net/ipv6/ip6_icmp.c    | 2 +-
 3 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/include/linux/icmpv6.h b/include/linux/icmpv6.h
index 630f45335c73..432611a297fb 100644
--- a/include/linux/icmpv6.h
+++ b/include/linux/icmpv6.h
@@ -14,7 +14,8 @@ static inline struct icmp6hdr *icmp6_hdr(const struct sk_buff *skb)
 #if IS_ENABLED(CONFIG_IPV6)
 extern void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info);
 
-typedef void ip6_icmp_send_t(struct sk_buff *skb, u8 type, u8 code, __u32 info);
+typedef void ip6_icmp_send_t(struct sk_buff *skb, u8 type, u8 code, __u32 info,
+			     const struct in6_addr *force_saddr);
 extern int inet6_register_icmp_sender(ip6_icmp_send_t *fn);
 extern int inet6_unregister_icmp_sender(ip6_icmp_send_t *fn);
 
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index e32a72fb9982..6c57e6e90301 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -388,7 +388,8 @@ relookup_failed:
 /*
  *	Send an ICMP message in response to a packet in error
  */
-static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
+static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info,
+		       const struct in6_addr *force_saddr)
 {
 	struct net *net = dev_net(skb->dev);
 	struct inet6_dev *idev = NULL;
@@ -475,6 +476,8 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	memset(&fl6, 0, sizeof(fl6));
 	fl6.flowi6_proto = IPPROTO_ICMPV6;
 	fl6.daddr = hdr->saddr;
+	if (force_saddr)
+		saddr = force_saddr;
 	if (saddr)
 		fl6.saddr = *saddr;
 	fl6.flowi6_mark = mark;
@@ -551,7 +554,7 @@ out:
  */
 void icmpv6_param_prob(struct sk_buff *skb, u8 code, int pos)
 {
-	icmp6_send(skb, ICMPV6_PARAMPROB, code, pos);
+	icmp6_send(skb, ICMPV6_PARAMPROB, code, pos, NULL);
 	kfree_skb(skb);
 }
 
diff --git a/net/ipv6/ip6_icmp.c b/net/ipv6/ip6_icmp.c
index 14dacc544c3e..713676f14a0e 100644
--- a/net/ipv6/ip6_icmp.c
+++ b/net/ipv6/ip6_icmp.c
@@ -39,7 +39,7 @@ void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 
 	if (!send)
 		goto out;
-	send(skb, type, code, info);
+	send(skb, type, code, info, NULL);
 out:
 	rcu_read_unlock();
 }
-- 
2.8.0.rc3.226.g39d4020
