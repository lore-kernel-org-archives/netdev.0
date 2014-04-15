From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 2/3] ipv4,fib: pass LOOPBACK_IFINDEX instead of 0 to flowi4_iif
Date: Mon, 14 Apr 2014 18:33:27 -0700
Message-ID: <1397525608-11592-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1397525608-11592-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Biederman <ebiederm@xmission.com>,
	Julian Anastasov <ja@ssi.bg>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:53469 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750898AbaDOBdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 21:33:39 -0400
Received: by mail-pb0-f47.google.com with SMTP id up15so8877012pbc.34
        for <netdev@vger.kernel.org>; Mon, 14 Apr 2014 18:33:38 -0700 (PDT)
In-Reply-To: <1397525608-11592-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>

As suggested by Julian:

	Simply, flowi4_iif must not contain 0, it does not
	look logical to ignore all ip rules with specified iif.

because in fib_rule_match() we do:

        if (rule->iifindex && (rule->iifindex != fl->flowi_iif))
                goto out;

flowi4_iif should be LOOPBACK_IFINDEX by default.

Cc: Eric Biederman <ebiederm@xmission.com>
Cc: Julian Anastasov <ja@ssi.bg>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Cong Wang <cwang@twopensource.com>
---
 include/net/flow.h                | 2 +-
 net/ipv4/fib_frontend.c           | 2 +-
 net/ipv4/ipmr.c                   | 2 +-
 net/ipv4/netfilter/ipt_rpfilter.c | 5 +----
 net/ipv6/ip6mr.c                  | 2 +-
 5 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 5401998..8109a15 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -88,7 +88,7 @@ static inline void flowi4_init_output(struct flowi4 *fl4, int oif,
 				      __be16 dport, __be16 sport)
 {
 	fl4->flowi4_oif = oif;
-	fl4->flowi4_iif = 0;
+	fl4->flowi4_iif = LOOPBACK_IFINDEX;
 	fl4->flowi4_mark = mark;
 	fl4->flowi4_tos = tos;
 	fl4->flowi4_scope = scope;
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 1a629f8..255aa99 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -250,7 +250,7 @@ static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 	bool dev_match;
 
 	fl4.flowi4_oif = 0;
-	fl4.flowi4_iif = oif;
+	fl4.flowi4_iif = oif ? : LOOPBACK_IFINDEX;
 	fl4.daddr = src;
 	fl4.saddr = dst;
 	fl4.flowi4_tos = tos;
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 2886357..d84dc8d 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -455,7 +455,7 @@ static netdev_tx_t reg_vif_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct mr_table *mrt;
 	struct flowi4 fl4 = {
 		.flowi4_oif	= dev->ifindex,
-		.flowi4_iif	= skb->skb_iif,
+		.flowi4_iif	= skb->skb_iif ? : LOOPBACK_IFINDEX,
 		.flowi4_mark	= skb->mark,
 	};
 	int err;
diff --git a/net/ipv4/netfilter/ipt_rpfilter.c b/net/ipv4/netfilter/ipt_rpfilter.c
index c49dcd0..4bfaedf 100644
--- a/net/ipv4/netfilter/ipt_rpfilter.c
+++ b/net/ipv4/netfilter/ipt_rpfilter.c
@@ -89,11 +89,8 @@ static bool rpfilter_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	if (ipv4_is_multicast(iph->daddr)) {
 		if (ipv4_is_zeronet(iph->saddr))
 			return ipv4_is_local_multicast(iph->daddr) ^ invert;
-		flow.flowi4_iif = 0;
-	} else {
-		flow.flowi4_iif = LOOPBACK_IFINDEX;
 	}
-
+	flow.flowi4_iif = LOOPBACK_IFINDEX;
 	flow.daddr = iph->saddr;
 	flow.saddr = rpfilter_get_saddr(iph->daddr);
 	flow.flowi4_oif = 0;
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 8737400..8659067 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -700,7 +700,7 @@ static netdev_tx_t reg_vif_xmit(struct sk_buff *skb,
 	struct mr6_table *mrt;
 	struct flowi6 fl6 = {
 		.flowi6_oif	= dev->ifindex,
-		.flowi6_iif	= skb->skb_iif,
+		.flowi6_iif	= skb->skb_iif ? : LOOPBACK_IFINDEX,
 		.flowi6_mark	= skb->mark,
 	};
 	int err;
-- 
1.8.3.1
