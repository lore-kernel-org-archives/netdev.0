From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/5] neigh: Kill hh_cache->hh_output
Date: Sun, 17 Jul 2011 12:30:24 -0700 (PDT)
Message-ID: <20110717.123024.463888631372775748.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38804 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756172Ab1GQTaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2011 15:30:25 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p6HJUOgt028649
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sun, 17 Jul 2011 12:30:24 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It's just taking on one of two possible values, either
neigh_ops->output or dev_queue_xmit().  And this is purely depending
upon whether nud_state has NUD_CONNECTED set or not.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |    1 -
 include/net/neighbour.h   |    4 ++--
 net/core/neighbour.c      |   25 ++-----------------------
 net/ipv4/route.c          |    6 +++---
 4 files changed, 7 insertions(+), 29 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f84dfd2..52c4e38 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -254,7 +254,6 @@ struct netdev_hw_addr_list {
 struct hh_cache {
 	u16		hh_len;
 	u16		__pad;
-	int		(*hh_output)(struct sk_buff *skb);
 	seqlock_t	hh_lock;
 
 	/* cached hardware header; allow for machine alignment needs.        */
diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 97990dd..60bac81 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -340,13 +340,13 @@ static inline int neigh_hh_output(struct hh_cache *hh, struct sk_buff *skb)
 	} while (read_seqretry(&hh->hh_lock, seq));
 
 	skb_push(skb, hh_len);
-	return hh->hh_output(skb);
+	return dev_queue_xmit(skb);
 }
 
 static inline int neigh_output(struct neighbour *n, struct sk_buff *skb)
 {
 	struct hh_cache *hh = &n->hh;
-	if (hh->hh_len)
+	if ((n->nud_state & NUD_CONNECTED) && hh->hh_len)
 		return neigh_hh_output(hh, skb);
 	else
 		return n->output(skb);
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index c22def5..2feda6e7 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -720,15 +720,9 @@ EXPORT_SYMBOL(neigh_destroy);
  */
 static void neigh_suspect(struct neighbour *neigh)
 {
-	struct hh_cache *hh;
-
 	NEIGH_PRINTK2("neigh %p is suspected.\n", neigh);
 
 	neigh->output = neigh->ops->output;
-
-	hh = &neigh->hh;
-	if (hh->hh_len)
-		hh->hh_output = neigh->ops->output;
 }
 
 /* Neighbour state is OK;
@@ -738,15 +732,9 @@ static void neigh_suspect(struct neighbour *neigh)
  */
 static void neigh_connect(struct neighbour *neigh)
 {
-	struct hh_cache *hh;
-
 	NEIGH_PRINTK2("neigh %p is connected.\n", neigh);
 
 	neigh->output = neigh->ops->connected_output;
-
-	hh = &neigh->hh;
-	if (hh->hh_len)
-		hh->hh_output = dev_queue_xmit;
 }
 
 static void neigh_periodic_work(struct work_struct *work)
@@ -1215,18 +1203,9 @@ static void neigh_hh_init(struct neighbour *n, struct dst_entry *dst)
 	/* Only one thread can come in here and initialize the
 	 * hh_cache entry.
 	 */
-	if (hh->hh_len)
-		goto end;
-
-	if (dev->header_ops->cache(n, hh, prot))
-		goto end;
-
-	if (n->nud_state & NUD_CONNECTED)
-		hh->hh_output = dev_queue_xmit;
-	else
-		hh->hh_output = n->ops->output;
+	if (!hh->hh_len)
+		dev->header_ops->cache(n, hh, prot);
 
-end:
 	write_unlock_bh(&n->lock);
 }
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a52bb74..bcf9bb5 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -427,9 +427,9 @@ static int rt_cache_seq_show(struct seq_file *seq, void *v)
 			      dst_metric(&r->dst, RTAX_RTTVAR)),
 			r->rt_key_tos,
 			-1,
-			(r->dst.neighbour ?
-			 (r->dst.neighbour->hh.hh_output ==
-			  dev_queue_xmit) : 0),
+			(r->dst.neighbour &&
+			 (r->dst.neighbour->nud_state & NUD_CONNECTED)) ?
+			   1 : 0,
 			r->rt_spec_dst, &len);
 
 		seq_printf(seq, "%*s\n", 127 - len, "");
-- 
1.7.6

