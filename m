From: Paul Moore <pmoore@redhat.com>
Subject: [PATCH] netlabel: fix build problems when CONFIG_IPV6=n
Date: Fri, 08 Mar 2013 09:45:39 -0500
Message-ID: <20130308144539.16729.15070.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45437 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932528Ab3CHOpl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Mar 2013 09:45:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My last patch to solve a problem where the static/fallback labels were
not fully displayed resulted in build problems when IPv6 was disabled.
This patch resolves the IPv6 build problems; sorry for the screw-up.

Please queue for -stable or simply merge with the previous patch.

Reported-by: Kbuild Test Robot <fengguang.wu@intel.com>
Signed-off-by: Paul Moore <pmoore@redhat.com>
---
 net/netlabel/netlabel_unlabeled.c |   15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/net/netlabel/netlabel_unlabeled.c b/net/netlabel/netlabel_unlabeled.c
index 85742b7..8a6c6ea 100644
--- a/net/netlabel/netlabel_unlabeled.c
+++ b/net/netlabel/netlabel_unlabeled.c
@@ -1189,8 +1189,6 @@ static int netlbl_unlabel_staticlist(struct sk_buff *skb,
 	struct netlbl_unlhsh_walk_arg cb_arg;
 	u32 skip_bkt = cb->args[0];
 	u32 skip_chain = cb->args[1];
-	u32 skip_addr4 = cb->args[2];
-	u32 skip_addr6 = cb->args[3];
 	u32 iter_bkt;
 	u32 iter_chain = 0, iter_addr4 = 0, iter_addr6 = 0;
 	struct netlbl_unlhsh_iface *iface;
@@ -1215,7 +1213,7 @@ static int netlbl_unlabel_staticlist(struct sk_buff *skb,
 				continue;
 			netlbl_af4list_foreach_rcu(addr4,
 						   &iface->addr4_list) {
-				if (iter_addr4++ < skip_addr4)
+				if (iter_addr4++ < cb->args[2])
 					continue;
 				if (netlbl_unlabel_staticlist_gen(
 					      NLBL_UNLABEL_C_STATICLIST,
@@ -1231,7 +1229,7 @@ static int netlbl_unlabel_staticlist(struct sk_buff *skb,
 #if IS_ENABLED(CONFIG_IPV6)
 			netlbl_af6list_foreach_rcu(addr6,
 						   &iface->addr6_list) {
-				if (iter_addr6++ < skip_addr6)
+				if (iter_addr6++ < cb->args[3])
 					continue;
 				if (netlbl_unlabel_staticlist_gen(
 					      NLBL_UNLABEL_C_STATICLIST,
@@ -1273,12 +1271,9 @@ static int netlbl_unlabel_staticlistdef(struct sk_buff *skb,
 {
 	struct netlbl_unlhsh_walk_arg cb_arg;
 	struct netlbl_unlhsh_iface *iface;
-	u32 skip_addr4 = cb->args[0];
-	u32 skip_addr6 = cb->args[1];
-	u32 iter_addr4 = 0;
+	u32 iter_addr4 = 0, iter_addr6 = 0;
 	struct netlbl_af4list *addr4;
 #if IS_ENABLED(CONFIG_IPV6)
-	u32 iter_addr6 = 0;
 	struct netlbl_af6list *addr6;
 #endif
 
@@ -1292,7 +1287,7 @@ static int netlbl_unlabel_staticlistdef(struct sk_buff *skb,
 		goto unlabel_staticlistdef_return;
 
 	netlbl_af4list_foreach_rcu(addr4, &iface->addr4_list) {
-		if (iter_addr4++ < skip_addr4)
+		if (iter_addr4++ < cb->args[0])
 			continue;
 		if (netlbl_unlabel_staticlist_gen(NLBL_UNLABEL_C_STATICLISTDEF,
 					      iface,
@@ -1305,7 +1300,7 @@ static int netlbl_unlabel_staticlistdef(struct sk_buff *skb,
 	}
 #if IS_ENABLED(CONFIG_IPV6)
 	netlbl_af6list_foreach_rcu(addr6, &iface->addr6_list) {
-		if (iter_addr6++ < skip_addr6)
+		if (iter_addr6++ < cb->args[1])
 			continue;
 		if (netlbl_unlabel_staticlist_gen(NLBL_UNLABEL_C_STATICLISTDEF,
 					      iface,
