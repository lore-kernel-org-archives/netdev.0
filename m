From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] ipmr: fix sparse warning when testing origin or group
Date: Tue, 22 Jan 2013 11:18:03 +0100
Message-ID: <1358849883-10452-1-git-send-email-nicolas.dichtel@6wind.com>
References: <50fe2be1.tv57lZmJcPMuyVta%fengguang.wu@intel.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:51801 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752981Ab3AVK0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 05:26:17 -0500
In-Reply-To: <50fe2be1.tv57lZmJcPMuyVta%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mfc_mcastgrp and mfc_origin are __be32, thus we need to convert INADDR_ANY.
Because INADDR_ANY is 0, this patch just fix sparse warnings.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv4/ipmr.c | 23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 4b5e226..7085b9b 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -832,12 +832,12 @@ static struct mfc_cache *ipmr_cache_find(struct mr_table *mrt,
 static struct mfc_cache *ipmr_cache_find_any_parent(struct mr_table *mrt,
 						    int vifi)
 {
-	int line = MFC_HASH(INADDR_ANY, INADDR_ANY);
+	int line = MFC_HASH(htonl(INADDR_ANY), htonl(INADDR_ANY));
 	struct mfc_cache *c;
 
 	list_for_each_entry_rcu(c, &mrt->mfc_cache_array[line], list)
-		if (c->mfc_origin == INADDR_ANY &&
-		    c->mfc_mcastgrp == INADDR_ANY &&
+		if (c->mfc_origin == htonl(INADDR_ANY) &&
+		    c->mfc_mcastgrp == htonl(INADDR_ANY) &&
 		    c->mfc_un.res.ttls[vifi] < 255)
 			return c;
 
@@ -848,14 +848,14 @@ static struct mfc_cache *ipmr_cache_find_any_parent(struct mr_table *mrt,
 static struct mfc_cache *ipmr_cache_find_any(struct mr_table *mrt,
 					     __be32 mcastgrp, int vifi)
 {
-	int line = MFC_HASH(mcastgrp, INADDR_ANY);
+	int line = MFC_HASH(mcastgrp, htonl(INADDR_ANY));
 	struct mfc_cache *c, *proxy;
 
-	if (mcastgrp == INADDR_ANY)
+	if (mcastgrp == htonl(INADDR_ANY))
 		goto skip;
 
 	list_for_each_entry_rcu(c, &mrt->mfc_cache_array[line], list)
-		if (c->mfc_origin == INADDR_ANY &&
+		if (c->mfc_origin == htonl(INADDR_ANY) &&
 		    c->mfc_mcastgrp == mcastgrp) {
 			if (c->mfc_un.res.ttls[vifi] < 255)
 				return c;
@@ -1148,7 +1148,7 @@ static int ipmr_mfc_add(struct net *net, struct mr_table *mrt,
 		return 0;
 	}
 
-	if (mfc->mfcc_mcastgrp.s_addr != INADDR_ANY &&
+	if (mfc->mfcc_mcastgrp.s_addr != htonl(INADDR_ANY) &&
 	    !ipv4_is_multicast(mfc->mfcc_mcastgrp.s_addr))
 		return -EINVAL;
 
@@ -1807,7 +1807,7 @@ static int ip_mr_forward(struct net *net, struct mr_table *mrt,
 	cache->mfc_un.res.pkt++;
 	cache->mfc_un.res.bytes += skb->len;
 
-	if (cache->mfc_origin == INADDR_ANY && true_vifi >= 0) {
+	if (cache->mfc_origin == htonl(INADDR_ANY) && true_vifi >= 0) {
 		struct mfc_cache *cache_proxy;
 
 		/* For an (*,G) entry, we only check that the incomming
@@ -1863,8 +1863,8 @@ forward:
 	/*
 	 *	Forward the frame
 	 */
-	if (cache->mfc_origin == INADDR_ANY &&
-	    cache->mfc_mcastgrp == INADDR_ANY) {
+	if (cache->mfc_origin == htonl(INADDR_ANY) &&
+	    cache->mfc_mcastgrp == htonl(INADDR_ANY)) {
 		if (true_vifi >= 0 &&
 		    true_vifi != cache->mfc_parent &&
 		    ip_hdr(skb)->ttl >
@@ -1881,7 +1881,8 @@ forward:
 	for (ct = cache->mfc_un.res.maxvif - 1;
 	     ct >= cache->mfc_un.res.minvif; ct--) {
 		/* For (*,G) entry, don't forward to the incoming interface */
-		if ((cache->mfc_origin != INADDR_ANY || ct != true_vifi) &&
+		if ((cache->mfc_origin != htonl(INADDR_ANY) ||
+		     ct != true_vifi) &&
 		    ip_hdr(skb)->ttl > cache->mfc_un.res.ttls[ct]) {
 			if (psend != -1) {
 				struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
-- 
1.8.0.1
