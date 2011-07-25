From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/7] atm: clip: Convert over to neighbour_priv()
Date: Mon, 25 Jul 2011 03:01:33 -0700 (PDT)
Message-ID: <20110725.030133.676768390222361722.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org
To: roland@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45779 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751953Ab1GYKDg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2011 06:03:36 -0400
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
index e19a0e7..44ee92d 100644
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
@@ -255,8 +255,10 @@ static void clip_pop(struct atm_vcc *vcc, struct sk_buff *skb)
 
 static void clip_neigh_solicit(struct neighbour *neigh, struct sk_buff *skb)
 {
+	__be32 *ip = (__be32 *) neigh->primary_key;
+
 	pr_debug("(neigh %p, skb %p)\n", neigh, skb);
-	to_atmarpd(act_need, PRIV(neigh->dev)->number, NEIGH2ENTRY(neigh)->ip);
+	to_atmarpd(act_need, PRIV(neigh->dev)->number, *ip);
 }
 
 static void clip_neigh_error(struct neighbour *neigh, struct sk_buff *skb)
@@ -277,13 +279,13 @@ static const struct neigh_ops clip_neigh_ops = {
 
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
 
@@ -391,12 +393,12 @@ static netdev_tx_t clip_start_xmit(struct sk_buff *skb,
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
@@ -526,7 +528,7 @@ static int clip_setentry(struct atm_vcc *vcc, __be32 ip)
 	ip_rt_put(rt);
 	if (!neigh)
 		return -ENOMEM;
-	entry = NEIGH2ENTRY(neigh);
+	entry = neighbour_priv(neigh);
 	if (entry != clip_vcc->entry) {
 		if (!clip_vcc->entry)
 			pr_debug("add\n");
@@ -787,9 +789,10 @@ static void svc_addr(struct seq_file *seq, struct sockaddr_atmsvc *addr)
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
@@ -809,8 +812,7 @@ static void atmarp_info(struct seq_file *seq, struct net_device *dev,
 	seq_printf(seq, "%-6s%-4s%-4s%5ld ",
 		   dev->name, svc ? "SVC" : "PVC", llc ? "LLC" : "NULL", exp);
 
-	off = scnprintf(buf, sizeof(buf) - 1, "%pI4",
-			&entry->ip);
+	off = scnprintf(buf, sizeof(buf) - 1, "%pI4", n->primary_key);
 	while (off < 16)
 		buf[off++] = ' ';
 	buf[off] = '\0';
@@ -881,7 +883,7 @@ static void *clip_seq_sub_iter(struct neigh_seq_state *_state,
 {
 	struct clip_seq_state *state = (struct clip_seq_state *)_state;
 
-	return clip_seq_vcc_walk(state, NEIGH2ENTRY(n), pos);
+	return clip_seq_vcc_walk(state, neighbour_priv(n), pos);
 }
 
 static void *clip_seq_start(struct seq_file *seq, loff_t * pos)
@@ -900,10 +902,10 @@ static int clip_seq_show(struct seq_file *seq, void *v)
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
1.7.6

