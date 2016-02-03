From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH] flowi: add concept of "not_oif"
Date: Wed,  3 Feb 2016 18:46:35 +0100
Message-ID: <1454521595-6721-1-git-send-email-Jason@zx2c4.com>
References: <CAHmME9pgwgjKJAFH2=sEEMJauno_rVEzY6JORTQze91Xo5zefw@mail.gmail.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:37552 "EHLO frisell.zx2c4.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964823AbcBCRpv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Feb 2016 12:45:51 -0500
In-Reply-To: <CAHmME9pgwgjKJAFH2=sEEMJauno_rVEzY6JORTQze91Xo5zefw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch simply adds support for specifying a "not_oif" device in
flowi4 and flowi6 lookups, that will find a matching route that _isn't_
via the specified device.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
---
 include/net/flow.h  | 3 +++
 net/ipv4/fib_trie.c | 2 ++
 net/ipv6/route.c    | 6 +++++-
 3 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 83969ee..29967ad 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -26,6 +26,7 @@ struct flowi_tunnel {
 
 struct flowi_common {
 	int	flowic_oif;
+	int	flowic_not_oif;
 	int	flowic_iif;
 	__u32	flowic_mark;
 	__u8	flowic_tos;
@@ -67,6 +68,7 @@ union flowi_uli {
 struct flowi4 {
 	struct flowi_common	__fl_common;
 #define flowi4_oif		__fl_common.flowic_oif
+#define flowi4_not_oif		__fl_common.flowic_not_oif
 #define flowi4_iif		__fl_common.flowic_iif
 #define flowi4_mark		__fl_common.flowic_mark
 #define flowi4_tos		__fl_common.flowic_tos
@@ -125,6 +127,7 @@ static inline void flowi4_update_output(struct flowi4 *fl4, int oif, __u8 tos,
 struct flowi6 {
 	struct flowi_common	__fl_common;
 #define flowi6_oif		__fl_common.flowic_oif
+#define flowi6_not_oif		__fl_common.flowic_not_oif
 #define flowi6_iif		__fl_common.flowic_iif
 #define flowi6_mark		__fl_common.flowic_mark
 #define flowi6_tos		__fl_common.flowic_tos
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 7aea0cc..d03e991 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1429,6 +1429,8 @@ found:
 				    flp->flowi4_oif != nh->nh_oif)
 					continue;
 			}
+			if (flp->flowi4_not_oif && flp->flowi4_not_oif == nh->nh_oif)
+				continue;
 
 			if (!(fib_flags & FIB_LOOKUP_NOREF))
 				atomic_inc(&fi->fib_clntref);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 3c8834b..2a793b5 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -467,6 +467,7 @@ static inline struct rt6_info *rt6_device_match(struct net *net,
 						    struct rt6_info *rt,
 						    const struct in6_addr *saddr,
 						    int oif,
+						    int not_oif,
 						    int flags)
 {
 	struct rt6_info *local = NULL;
@@ -478,6 +479,9 @@ static inline struct rt6_info *rt6_device_match(struct net *net,
 	for (sprt = rt; sprt; sprt = sprt->dst.rt6_next) {
 		struct net_device *dev = sprt->dst.dev;
 
+		if (not_oif && dev->ifindex == not_oif)
+			continue;
+
 		if (oif) {
 			if (dev->ifindex == oif)
 				return sprt;
@@ -856,7 +860,7 @@ static struct rt6_info *ip6_pol_route_lookup(struct net *net,
 	fn = fib6_lookup(&table->tb6_root, &fl6->daddr, &fl6->saddr);
 restart:
 	rt = fn->leaf;
-	rt = rt6_device_match(net, rt, &fl6->saddr, fl6->flowi6_oif, flags);
+	rt = rt6_device_match(net, rt, &fl6->saddr, fl6->flowi6_oif, fl6->flowi6_not_oif, flags);
 	if (rt->rt6i_nsiblings && fl6->flowi6_oif == 0)
 		rt = rt6_multipath_select(rt, fl6, fl6->flowi6_oif, flags);
 	if (rt == net->ipv6.ip6_null_entry) {
-- 
2.7.0
