From: kaber@trash.net
Subject: [PATCH 05/72] netfilter: nf_conntrack: fix the hash random initializing race
Date: Thu, 21 Oct 2010 17:18:52 +0200
Message-ID: <1287674399-31455-6-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59988 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752136Ab0JUPUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:20:03 -0400
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>

nf_conntrack_alloc() isn't called with nf_conntrack_lock locked, so hash
random initializing code maybe executed more than once on different
CPUs.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_conntrack_core.c |   19 +++++++++++++------
 1 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index df3eedb..4c0ad9b 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -65,8 +65,7 @@ EXPORT_SYMBOL_GPL(nf_conntrack_max);
 DEFINE_PER_CPU(struct nf_conn, nf_conntrack_untracked);
 EXPORT_PER_CPU_SYMBOL(nf_conntrack_untracked);
 
-static int nf_conntrack_hash_rnd_initted;
-static unsigned int nf_conntrack_hash_rnd;
+static unsigned int nf_conntrack_hash_rnd __read_mostly;
 
 static u_int32_t __hash_conntrack(const struct nf_conntrack_tuple *tuple,
 				  u16 zone, unsigned int size, unsigned int rnd)
@@ -574,10 +573,18 @@ struct nf_conn *nf_conntrack_alloc(struct net *net, u16 zone,
 {
 	struct nf_conn *ct;
 
-	if (unlikely(!nf_conntrack_hash_rnd_initted)) {
-		get_random_bytes(&nf_conntrack_hash_rnd,
-				sizeof(nf_conntrack_hash_rnd));
-		nf_conntrack_hash_rnd_initted = 1;
+	if (unlikely(!nf_conntrack_hash_rnd)) {
+		unsigned int rand;
+
+		/*
+		 * Why not initialize nf_conntrack_rnd in a "init()" function ?
+		 * Because there isn't enough entropy when system initializing,
+		 * and we initialize it as late as possible.
+		 */
+		do {
+			get_random_bytes(&rand, sizeof(rand));
+		} while (!rand);
+		cmpxchg(&nf_conntrack_hash_rnd, 0, rand);
 	}
 
 	/* We don't want any race condition at early drop stage */
-- 
1.7.1

