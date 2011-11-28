From: Ulrich Weber <ulrich.weber@sophos.com>
Subject: [PATCH 1/3] xfrm: add incoming interface to selector
Date: Mon, 28 Nov 2011 21:14:50 +0100
Message-ID: <1322511292-1413-2-git-send-email-ulrich.weber@sophos.com>
References: <1322511292-1413-1-git-send-email-ulrich.weber@sophos.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.sophos.com ([216.47.234.212]:45783 "EHLO mx3.sophos.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753677Ab1K1UZ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Nov 2011 15:25:57 -0500
In-Reply-To: <1322511292-1413-1-git-send-email-ulrich.weber@sophos.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current implementation only allows to match for outgoing
interface in xfrm policy database.

This replaces the user ID (which was never used) with the
incoming interface, so both interfaces can be matched against.

Signed-off-by: Ulrich Weber <ulrich.weber@sophos.com>
---
 include/linux/xfrm.h   |    4 ++--
 net/ipv4/xfrm4_state.c |    3 ++-
 net/ipv6/mip6.c        |    3 ++-
 net/ipv6/xfrm6_state.c |    3 ++-
 net/xfrm/xfrm_policy.c |    6 ++++--
 5 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 22e61fd..bb1bb49 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -54,8 +54,8 @@ struct xfrm_selector {
 	__u8	prefixlen_d;
 	__u8	prefixlen_s;
 	__u8	proto;
-	int	ifindex;
-	__kernel_uid32_t	user;
+	int	oif;
+	int 	iif;
 };
 
 #define XFRM_INF (~(__u64)0)
diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index 9258e75..96d9b55 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -36,7 +36,8 @@ __xfrm4_init_tempsel(struct xfrm_selector *sel, const struct flowi *fl)
 	sel->prefixlen_d = 32;
 	sel->prefixlen_s = 32;
 	sel->proto = fl4->flowi4_proto;
-	sel->ifindex = fl4->flowi4_oif;
+	sel->oif = fl4->flowi4_oif;
+	sel->iif = fl4->flowi4_iif;
 }
 
 static void
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index 7e1e0fb..c0ebe40 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -248,7 +248,8 @@ static int mip6_destopt_reject(struct xfrm_state *x, struct sk_buff *skb,
 	sel.sport = xfrm_flowi_sport(fl, &fl6->uli);
 	if (sel.sport)
 		sel.sport_mask = htons(~0);
-	sel.ifindex = fl6->flowi6_oif;
+	sel.oif = fl6->flowi6_oif;
+	sel.iif = fl6->flowi6_iif;
 
 	err = km_report(net, IPPROTO_DSTOPTS, &sel,
 			(hao ? (xfrm_address_t *)&hao->addr : NULL));
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index 3f2f7c4..bdb13df 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -37,7 +37,8 @@ __xfrm6_init_tempsel(struct xfrm_selector *sel, const struct flowi *fl)
 	sel->prefixlen_d = 128;
 	sel->prefixlen_s = 128;
 	sel->proto = fl6->flowi6_proto;
-	sel->ifindex = fl6->flowi6_oif;
+	sel->oif = fl6->flowi6_oif;
+	sel->iif = fl6->flowi6_iif;
 }
 
 static void
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 4fce1ce..648c9e7 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -66,7 +66,8 @@ __xfrm4_selector_match(const struct xfrm_selector *sel, const struct flowi *fl)
 		!((xfrm_flowi_dport(fl, &fl4->uli) ^ sel->dport) & sel->dport_mask) &&
 		!((xfrm_flowi_sport(fl, &fl4->uli) ^ sel->sport) & sel->sport_mask) &&
 		(fl4->flowi4_proto == sel->proto || !sel->proto) &&
-		(fl4->flowi4_oif == sel->ifindex || !sel->ifindex);
+		(fl4->flowi4_oif == sel->oif || !sel->oif) &&
+		(fl4->flowi4_iif == sel->iif || !sel->iif);
 }
 
 static inline int
@@ -79,7 +80,8 @@ __xfrm6_selector_match(const struct xfrm_selector *sel, const struct flowi *fl)
 		!((xfrm_flowi_dport(fl, &fl6->uli) ^ sel->dport) & sel->dport_mask) &&
 		!((xfrm_flowi_sport(fl, &fl6->uli) ^ sel->sport) & sel->sport_mask) &&
 		(fl6->flowi6_proto == sel->proto || !sel->proto) &&
-		(fl6->flowi6_oif == sel->ifindex || !sel->ifindex);
+		(fl6->flowi6_oif == sel->oif || !sel->oif) &&
+		(fl6->flowi6_iif == sel->iif || !sel->iif);
 }
 
 int xfrm_selector_match(const struct xfrm_selector *sel, const struct flowi *fl,
-- 
1.7.4.1
