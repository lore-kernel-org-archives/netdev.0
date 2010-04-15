From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 3/3] ipv4: ipmr: fix NULL pointer deref during unres queue destruction
Date: Thu, 15 Apr 2010 14:47:58 +0200
Message-ID: <1271335678-20961-4-git-send-email-kaber@trash.net>
References: <1271335678-20961-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63172 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753481Ab0DOMsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 08:48:03 -0400
In-Reply-To: <1271335678-20961-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix an oversight in ipmr_destroy_unres() - the net pointer is
unconditionally initialized to NULL, resulting in a NULL pointer
dereference later on.

Fix by adding a net pointer to struct mr_table and using it in
ipmr_destroy_unres().

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/ipmr.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 0643fb6..7d8a2bc 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -71,6 +71,9 @@
 
 struct mr_table {
 	struct list_head	list;
+#ifdef CONFIG_NET_NS
+	struct net		*net;
+#endif
 	u32			id;
 	struct sock		*mroute_sk;
 	struct timer_list	ipmr_expire_timer;
@@ -308,6 +311,7 @@ static struct mr_table *ipmr_new_table(struct net *net, u32 id)
 	mrt = kzalloc(sizeof(*mrt), GFP_KERNEL);
 	if (mrt == NULL)
 		return NULL;
+	write_pnet(&mrt->net, net);
 	mrt->id = id;
 
 	/* Forwarding cache */
@@ -580,7 +584,7 @@ static inline void ipmr_cache_free(struct mfc_cache *c)
 
 static void ipmr_destroy_unres(struct mr_table *mrt, struct mfc_cache *c)
 {
-	struct net *net = NULL; //mrt->net;
+	struct net *net = read_pnet(&mrt->net);
 	struct sk_buff *skb;
 	struct nlmsgerr *e;
 
-- 
1.7.0.4

