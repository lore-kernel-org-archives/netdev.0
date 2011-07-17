From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/5] neigh: Kill neigh_ops->hh_output
Date: Sun, 17 Jul 2011 12:30:18 -0700 (PDT)
Message-ID: <20110717.123018.638193926865468101.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38800 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756172Ab1GQTaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2011 15:30:20 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p6HJUIq4028637
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sun, 17 Jul 2011 12:30:19 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It's always dev_queue_xmit().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/neighbour.h |    1 -
 net/atm/clip.c          |    1 -
 net/core/neighbour.c    |    4 ++--
 net/decnet/dn_neigh.c   |    3 ---
 net/ipv4/arp.c          |    4 ----
 net/ipv6/ndisc.c        |    3 ---
 6 files changed, 2 insertions(+), 14 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 337da24..97990dd 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -122,7 +122,6 @@ struct neigh_ops {
 	void			(*error_report)(struct neighbour *, struct sk_buff*);
 	int			(*output)(struct sk_buff*);
 	int			(*connected_output)(struct sk_buff*);
-	int			(*hh_output)(struct sk_buff*);
 	int			(*queue_xmit)(struct sk_buff*);
 };
 
diff --git a/net/atm/clip.c b/net/atm/clip.c
index 1d4be60..036cd43 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -273,7 +273,6 @@ static const struct neigh_ops clip_neigh_ops = {
 	.error_report =		clip_neigh_error,
 	.output =		dev_queue_xmit,
 	.connected_output =	dev_queue_xmit,
-	.hh_output =		dev_queue_xmit,
 	.queue_xmit =		dev_queue_xmit,
 };
 
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 83f9998..c22def5 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -746,7 +746,7 @@ static void neigh_connect(struct neighbour *neigh)
 
 	hh = &neigh->hh;
 	if (hh->hh_len)
-		hh->hh_output = neigh->ops->hh_output;
+		hh->hh_output = dev_queue_xmit;
 }
 
 static void neigh_periodic_work(struct work_struct *work)
@@ -1222,7 +1222,7 @@ static void neigh_hh_init(struct neighbour *n, struct dst_entry *dst)
 		goto end;
 
 	if (n->nud_state & NUD_CONNECTED)
-		hh->hh_output = n->ops->hh_output;
+		hh->hh_output = dev_queue_xmit;
 	else
 		hh->hh_output = n->ops->output;
 
diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index 03eb226..abf4de8 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -64,7 +64,6 @@ static const struct neigh_ops dn_long_ops = {
 	.error_report =		dn_long_error_report,
 	.output =		dn_long_output,
 	.connected_output =	dn_long_output,
-	.hh_output =		dev_queue_xmit,
 	.queue_xmit =		dev_queue_xmit,
 };
 
@@ -76,7 +75,6 @@ static const struct neigh_ops dn_short_ops = {
 	.error_report =		dn_short_error_report,
 	.output =		dn_short_output,
 	.connected_output =	dn_short_output,
-	.hh_output =		dev_queue_xmit,
 	.queue_xmit =		dev_queue_xmit,
 };
 
@@ -88,7 +86,6 @@ static const struct neigh_ops dn_phase3_ops = {
 	.error_report =		dn_short_error_report, /* Can use short version here */
 	.output =		dn_phase3_output,
 	.connected_output =	dn_phase3_output,
-	.hh_output =		dev_queue_xmit,
 	.queue_xmit =		dev_queue_xmit
 };
 
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 3e55456..f5f0aa1 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -138,7 +138,6 @@ static const struct neigh_ops arp_generic_ops = {
 	.error_report =		arp_error_report,
 	.output =		neigh_resolve_output,
 	.connected_output =	neigh_connected_output,
-	.hh_output =		dev_queue_xmit,
 	.queue_xmit =		dev_queue_xmit,
 };
 
@@ -148,7 +147,6 @@ static const struct neigh_ops arp_hh_ops = {
 	.error_report =		arp_error_report,
 	.output =		neigh_resolve_output,
 	.connected_output =	neigh_resolve_output,
-	.hh_output =		dev_queue_xmit,
 	.queue_xmit =		dev_queue_xmit,
 };
 
@@ -156,7 +154,6 @@ static const struct neigh_ops arp_direct_ops = {
 	.family =		AF_INET,
 	.output =		dev_queue_xmit,
 	.connected_output =	dev_queue_xmit,
-	.hh_output =		dev_queue_xmit,
 	.queue_xmit =		dev_queue_xmit,
 };
 
@@ -166,7 +163,6 @@ static const struct neigh_ops arp_broken_ops = {
 	.error_report =		arp_error_report,
 	.output =		neigh_compat_output,
 	.connected_output =	neigh_compat_output,
-	.hh_output =		dev_queue_xmit,
 	.queue_xmit =		dev_queue_xmit,
 };
 
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 7596f07..db782d2 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -107,7 +107,6 @@ static const struct neigh_ops ndisc_generic_ops = {
 	.error_report =		ndisc_error_report,
 	.output =		neigh_resolve_output,
 	.connected_output =	neigh_connected_output,
-	.hh_output =		dev_queue_xmit,
 	.queue_xmit =		dev_queue_xmit,
 };
 
@@ -117,7 +116,6 @@ static const struct neigh_ops ndisc_hh_ops = {
 	.error_report =		ndisc_error_report,
 	.output =		neigh_resolve_output,
 	.connected_output =	neigh_resolve_output,
-	.hh_output =		dev_queue_xmit,
 	.queue_xmit =		dev_queue_xmit,
 };
 
@@ -126,7 +124,6 @@ static const struct neigh_ops ndisc_direct_ops = {
 	.family =		AF_INET6,
 	.output =		dev_queue_xmit,
 	.connected_output =	dev_queue_xmit,
-	.hh_output =		dev_queue_xmit,
 	.queue_xmit =		dev_queue_xmit,
 };
 
-- 
1.7.6

