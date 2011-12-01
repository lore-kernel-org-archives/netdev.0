From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/7] atm: clip: Convert over to neighbour_priv()
Date: Wed, 30 Nov 2011 22:41:47 -0500 (EST)
Message-ID: <20111130.224147.1630970245809256278.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58067 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753660Ab1LADlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 22:41:49 -0500
Received: from localhost (cpe-66-65-61-233.nyc.res.rr.com [66.65.61.233])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pB13flpA027345
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 19:41:48 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/atmclip.h |    2 --
 net/atm/clip.c        |   28 +++++++++++++++-------------
 2 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/include/net/atmclip.h b/include/net/atmclip.h
index 497ef64..852a3b2 100644
--- a/include/net/atmclip.h
+++ b/include/net/atmclip.h
@@ -15,7 +15,6 @@
 
 
 #define CLIP_VCC(vcc) ((struct clip_vcc *) ((vcc)->user_back))
-#define NEIGH2ENTRY(neigh) ((struct atmarp_entry *) (neigh)->primary_key)
 
 struct sk_buff;
 
@@ -36,7 +35,6 @@ struct clip_vcc {
 
 
 struct atmarp_entry {
-	__be32		ip;		/* IP address */
 	struct clip_vcc	*vccs;		/* active VCCs; NULL if resolution is
 					   pending */
 	unsigned long	expires;	/* entry expiration time */
diff --git a/net/atm/clip.c b/net/atm/clip.c
index b1c7ada..a9d3484 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -119,7 +119,7 @@ out:
 /* The neighbour entry n->lock is held. */
 static int neigh_check_cb(struct neighbour *n)
 {
-	struct atmarp_entry *entry = NEIGH2ENTRY(n);
+	struct atmarp_entry *entry = neighbour_priv(n);
 	struct clip_vcc *cv;
 
 	for (cv = entry->vccs; cv; cv = cv->next) {
@@ -262,8 +262,10 @@ static void clip_pop(struct atm_vcc *vcc, struct sk_buff *skb)
 
 static void clip_neigh_solicit(struct neighbour *neigh, struct sk_buff *skb)
 {
+	__be32 *ip = (__be32 *) neigh->primary_key;
+
 	pr_debug("(neigh %p, skb %p)\n", neigh, skb);
-	to_atmarpd(act_need, PRIV(neigh->dev)->number, NEIGH2ENTRY(neigh)->ip);
+	to_atmarpd(act_need, PRIV(neigh->dev)->number, *ip);
 }
 
 static void clip_neigh_error(struct neighbour *neigh, struct sk_buff *skb)
@@ -284,13 +286,13 @@ static const struct neigh_ops clip_neigh_ops = {
 
 static int clip_constructor(struct neighbour *neigh)
 {
-	struct atmarp_entry *entry = NEIGH2ENTRY(neigh);
+	struct atmarp_entry *entry = neighbour_priv(neigh);
 	struct net_device *dev = neigh->dev;
 	struct in_device *in_dev;
 	struct neigh_parms *parms;
 
 	pr_debug("(neigh %p, entry %p)\n", neigh, entry);
-	neigh->type = inet_addr_type(&init_net, entry->ip);
+	neigh->type = inet_addr_type(&init_net, *((__be32 *) neigh->primary_key));
 	if (neigh->type != RTN_UNICAST)
 		return -EINVAL;
 
@@ -398,12 +400,12 @@ static netdev_tx_t clip_start_xmit(struct sk_buff *skb,
 		dev->stats.tx_dropped++;
 		return NETDEV_TX_OK;
 	}
-	entry = NEIGH2ENTRY(n);
+	entry = neighbour_priv(n);
 	if (!entry->vccs) {
 		if (time_after(jiffies, entry->expires)) {
 			/* should be resolved */
 			entry->expires = jiffies + ATMARP_RETRY_DELAY * HZ;
-			to_atmarpd(act_need, PRIV(dev)->number, entry->ip);
+			to_atmarpd(act_need, PRIV(dev)->number, *((__be32 *)n->primary_key));
 		}
 		if (entry->neigh->arp_queue.qlen < ATMARP_MAX_UNRES_PACKETS)
 			skb_queue_tail(&entry->neigh->arp_queue, skb);
@@ -510,7 +512,7 @@ static int clip_setentry(struct atm_vcc *vcc, __be32 ip)
 	ip_rt_put(rt);
 	if (!neigh)
 		return -ENOMEM;
-	entry = NEIGH2ENTRY(neigh);
+	entry = neighbour_priv(neigh);
 	if (entry != clip_vcc->entry) {
 		if (!clip_vcc->entry)
 			pr_debug("add\n");
@@ -771,9 +773,10 @@ static void svc_addr(struct seq_file *seq, struct sockaddr_atmsvc *addr)
 /* This means the neighbour entry has no attached VCC objects. */
 #define SEQ_NO_VCC_TOKEN	((void *) 2)
 
-static void atmarp_info(struct seq_file *seq, struct net_device *dev,
+static void atmarp_info(struct seq_file *seq, struct neighbour *n,
 			struct atmarp_entry *entry, struct clip_vcc *clip_vcc)
 {
+	struct net_device *dev = n->dev;
 	unsigned long exp;
 	char buf[17];
 	int svc, llc, off;
@@ -793,8 +796,7 @@ static void atmarp_info(struct seq_file *seq, struct net_device *dev,
 	seq_printf(seq, "%-6s%-4s%-4s%5ld ",
 		   dev->name, svc ? "SVC" : "PVC", llc ? "LLC" : "NULL", exp);
 
-	off = scnprintf(buf, sizeof(buf) - 1, "%pI4",
-			&entry->ip);
+	off = scnprintf(buf, sizeof(buf) - 1, "%pI4", n->primary_key);
 	while (off < 16)
 		buf[off++] = ' ';
 	buf[off] = '\0';
@@ -865,7 +867,7 @@ static void *clip_seq_sub_iter(struct neigh_seq_state *_state,
 {
 	struct clip_seq_state *state = (struct clip_seq_state *)_state;
 
-	return clip_seq_vcc_walk(state, NEIGH2ENTRY(n), pos);
+	return clip_seq_vcc_walk(state, neighbour_priv(n), pos);
 }
 
 static void *clip_seq_start(struct seq_file *seq, loff_t * pos)
@@ -884,10 +886,10 @@ static int clip_seq_show(struct seq_file *seq, void *v)
 		seq_puts(seq, atm_arp_banner);
 	} else {
 		struct clip_seq_state *state = seq->private;
-		struct neighbour *n = v;
 		struct clip_vcc *vcc = state->vcc;
+		struct neighbour *n = v;
 
-		atmarp_info(seq, n->dev, NEIGH2ENTRY(n), vcc);
+		atmarp_info(seq, n, neighbour_priv(n), vcc);
 	}
 	return 0;
 }
-- 
1.7.6.4
