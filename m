From: Timo Teras <timo.teras@iki.fi>
Subject: [PATCH net-next] gre: optimize hash lookup
Date: Fri, 23 Jan 2009 08:02:33 +0200
Message-ID: <1232690553-31865-1-git-send-email-timo.teras@iki.fi>
Cc: Timo Teras <timo.teras@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:10199 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751026AbZAWGCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 01:02:39 -0500
Received: by fg-out-1718.google.com with SMTP id 19so2418788fgg.17
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2009 22:02:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of keeping candidate tunnel device from all categories,
keep only one candidate with best score. This optimizes stack
usage and speeds up exit code.

Signed-off-by: Timo Teras <timo.teras@iki.fi>
---
 net/ipv4/ip_gre.c |   69 ++++++++++++++++++++++++++++++----------------------
 1 files changed, 40 insertions(+), 29 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 4a43739..07a188a 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -172,11 +172,11 @@ static struct ip_tunnel * ipgre_tunnel_lookup(struct net_device *dev,
 	int link = dev->ifindex;
 	unsigned h0 = HASH(remote);
 	unsigned h1 = HASH(key);
-	struct ip_tunnel *t, *sel[4] = { NULL, NULL, NULL, NULL };
+	struct ip_tunnel *t, *cand = NULL;
 	struct ipgre_net *ign = net_generic(net, ipgre_net_id);
 	int dev_type = (gre_proto == htons(ETH_P_TEB)) ?
 		       ARPHRD_ETHER : ARPHRD_IPGRE;
-	int idx;
+	int score, cand_score = 4;
 
 	for (t = ign->tunnels_r_l[h0^h1]; t; t = t->next) {
 		if (local != t->parms.iph.saddr ||
@@ -189,15 +189,18 @@ static struct ip_tunnel * ipgre_tunnel_lookup(struct net_device *dev,
 		    t->dev->type != dev_type)
 			continue;
 
-		idx = 0;
+		score = 0;
 		if (t->parms.link != link)
-			idx |= 1;
+			score |= 1;
 		if (t->dev->type != dev_type)
-			idx |= 2;
-		if (idx == 0)
+			score |= 2;
+		if (score == 0)
 			return t;
-		if (sel[idx] == NULL)
-			sel[idx] = t;
+
+		if (score < cand_score) {
+			cand = t;
+			cand_score = score;
+		}
 	}
 
 	for (t = ign->tunnels_r[h0^h1]; t; t = t->next) {
@@ -210,15 +213,18 @@ static struct ip_tunnel * ipgre_tunnel_lookup(struct net_device *dev,
 		    t->dev->type != dev_type)
 			continue;
 
-		idx = 0;
+		score = 0;
 		if (t->parms.link != link)
-			idx |= 1;
+			score |= 1;
 		if (t->dev->type != dev_type)
-			idx |= 2;
-		if (idx == 0)
+			score |= 2;
+		if (score == 0)
 			return t;
-		if (sel[idx] == NULL)
-			sel[idx] = t;
+
+		if (score < cand_score) {
+			cand = t;
+			cand_score = score;
+		}
 	}
 
 	for (t = ign->tunnels_l[h1]; t; t = t->next) {
@@ -233,15 +239,18 @@ static struct ip_tunnel * ipgre_tunnel_lookup(struct net_device *dev,
 		    t->dev->type != dev_type)
 			continue;
 
-		idx = 0;
+		score = 0;
 		if (t->parms.link != link)
-			idx |= 1;
+			score |= 1;
 		if (t->dev->type != dev_type)
-			idx |= 2;
-		if (idx == 0)
+			score |= 2;
+		if (score == 0)
 			return t;
-		if (sel[idx] == NULL)
-			sel[idx] = t;
+
+		if (score < cand_score) {
+			cand = t;
+			cand_score = score;
+		}
 	}
 
 	for (t = ign->tunnels_wc[h1]; t; t = t->next) {
@@ -253,20 +262,22 @@ static struct ip_tunnel * ipgre_tunnel_lookup(struct net_device *dev,
 		    t->dev->type != dev_type)
 			continue;
 
-		idx = 0;
+		score = 0;
 		if (t->parms.link != link)
-			idx |= 1;
+			score |= 1;
 		if (t->dev->type != dev_type)
-			idx |= 2;
-		if (idx == 0)
+			score |= 2;
+		if (score == 0)
 			return t;
-		if (sel[idx] == NULL)
-			sel[idx] = t;
+
+		if (score < cand_score) {
+			cand = t;
+			cand_score = score;
+		}
 	}
 
-	for (idx = 1; idx < ARRAY_SIZE(sel); idx++)
-		if (sel[idx] != NULL)
-			return sel[idx];
+	if (cand != NULL)
+		return cand;
 
 	if (ign->fb_tunnel_dev->flags & IFF_UP)
 		return netdev_priv(ign->fb_tunnel_dev);
-- 
1.5.6.3

