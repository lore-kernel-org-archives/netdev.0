From: David Ahern <dsahern@gmail.com>
Subject: [PATCH v2 net-next 4/7] net: ipv4: add second dif to multicast source filter
Date: Fri,  4 Aug 2017 13:17:00 -0700
Message-ID: <1501877823-31365-5-git-send-email-dsahern@gmail.com>
References: <1501877823-31365-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:37936 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751970AbdHDURN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 16:17:13 -0400
Received: by mail-pf0-f196.google.com with SMTP id h75so2758487pfh.5
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 13:17:13 -0700 (PDT)
In-Reply-To: <1501877823-31365-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/linux/igmp.h | 3 ++-
 net/ipv4/igmp.c      | 6 ++++--
 net/ipv4/raw.c       | 2 +-
 net/ipv4/udp.c       | 2 +-
 4 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index 97caf1821de8..f8231854b5d6 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -118,7 +118,8 @@ extern int ip_mc_msfget(struct sock *sk, struct ip_msfilter *msf,
 		struct ip_msfilter __user *optval, int __user *optlen);
 extern int ip_mc_gsfget(struct sock *sk, struct group_filter *gsf,
 		struct group_filter __user *optval, int __user *optlen);
-extern int ip_mc_sf_allow(struct sock *sk, __be32 local, __be32 rmt, int dif);
+extern int ip_mc_sf_allow(struct sock *sk, __be32 local, __be32 rmt,
+			  int dif, int sdif);
 extern void ip_mc_init_dev(struct in_device *);
 extern void ip_mc_destroy_dev(struct in_device *);
 extern void ip_mc_up(struct in_device *);
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 28f14afd0dd3..5bc8570c2ec3 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -2549,7 +2549,8 @@ int ip_mc_gsfget(struct sock *sk, struct group_filter *gsf,
 /*
  * check if a multicast source filter allows delivery for a given <src,dst,intf>
  */
-int ip_mc_sf_allow(struct sock *sk, __be32 loc_addr, __be32 rmt_addr, int dif)
+int ip_mc_sf_allow(struct sock *sk, __be32 loc_addr, __be32 rmt_addr,
+		   int dif, int sdif)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct ip_mc_socklist *pmc;
@@ -2564,7 +2565,8 @@ int ip_mc_sf_allow(struct sock *sk, __be32 loc_addr, __be32 rmt_addr, int dif)
 	rcu_read_lock();
 	for_each_pmc_rcu(inet, pmc) {
 		if (pmc->multi.imr_multiaddr.s_addr == loc_addr &&
-		    pmc->multi.imr_ifindex == dif)
+		    (pmc->multi.imr_ifindex == dif ||
+		     (sdif && pmc->multi.imr_ifindex == sdif)))
 			break;
 	}
 	ret = inet->mc_all;
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 2726aecf224b..33b70bfd1122 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -193,7 +193,7 @@ static int raw_v4_input(struct sk_buff *skb, const struct iphdr *iph, int hash)
 		delivered = 1;
 		if ((iph->protocol != IPPROTO_ICMP || !icmp_filter(sk, skb)) &&
 		    ip_mc_sf_allow(sk, iph->daddr, iph->saddr,
-				   skb->dev->ifindex)) {
+				   skb->dev->ifindex, sdif)) {
 			struct sk_buff *clone = skb_clone(skb, GFP_ATOMIC);
 
 			/* Not releasing hash table! */
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 608b91b912c9..9a77b29f4ebd 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -606,7 +606,7 @@ static inline bool __udp_is_mcast_sock(struct net *net, struct sock *sk,
 	    (sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif &&
 	     sk->sk_bound_dev_if != sdif))
 		return false;
-	if (!ip_mc_sf_allow(sk, loc_addr, rmt_addr, dif))
+	if (!ip_mc_sf_allow(sk, loc_addr, rmt_addr, dif, sdif))
 		return false;
 	return true;
 }
-- 
2.1.4
