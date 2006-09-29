From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 4/8][ATM]: [lec] convert lec_arp_table to hlist
Date: Fri, 29 Sep 2006 12:40:47 -0400
Message-ID: <200609291640.k8TGelQi025553@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:58588 "EHLO
	ginger.cmf.nrl.navy.mil") by vger.kernel.org with ESMTP
	id S1161208AbWI2QlM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 12:41:12 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

please consider for 2.6.19 -- thanks!

[ATM]: [lec] convert lec_arp_table to hlist

Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

---
commit cf14c654bcb812dae6ed85075777a19e1e02bee1
tree d01bc707baf050862e676e5609081ba1cc22aca1
parent ad9e9d30230b99dd41921b61a506c41e168e1a84
author chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Wed, 20 Sep 2006 18:52:59 -0400
committer chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Wed, 20 Sep 2006 18:52:59 -0400

 net/atm/lec.c      |  442 +++++++++++++++++++---------------------------------
 net/atm/lec.h      |    8 -
 net/atm/lec_arpc.h |    2 
 3 files changed, 170 insertions(+), 282 deletions(-)

diff --git a/net/atm/lec.c b/net/atm/lec.c
index 13aeacf..87fb0c2 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -806,7 +806,7 @@ #endif
 			dev_kfree_skb(skb);
 			return;
 		}
-		if (priv->lec_arp_empty_ones) {
+		if (!hlist_empty(&priv->lec_arp_empty_ones)) {
 			lec_arp_check_empties(priv, vcc, skb);
 		}
 		skb->dev = dev;
@@ -998,29 +998,32 @@ static void lec_info(struct seq_file *se
 struct lec_state {
 	unsigned long flags;
 	struct lec_priv *locked;
-	struct lec_arp_table *entry;
+	struct hlist_node *node;
 	struct net_device *dev;
 	int itf;
 	int arp_table;
 	int misc_table;
 };
 
-static void *lec_tbl_walk(struct lec_state *state, struct lec_arp_table *tbl,
+static void *lec_tbl_walk(struct lec_state *state, struct hlist_head *tbl,
 			  loff_t *l)
 {
-	struct lec_arp_table *e = state->entry;
+	struct hlist_node *e = state->node;
+	struct lec_arp_table *tmp;
 
 	if (!e)
-		e = tbl;
+		e = tbl->first;
 	if (e == (void *)1) {
-		e = tbl;
+		e = tbl->first;
 		--*l;
 	}
-	for (; e; e = e->next) {
+
+	hlist_for_each_entry_from(tmp, e, next) {
 		if (--*l < 0)
 			break;
 	}
-	state->entry = e;
+	state->node = e;
+
 	return (*l < 0) ? state : NULL;
 }
 
@@ -1031,7 +1034,7 @@ static void *lec_arp_walk(struct lec_sta
 	int p;
 
 	for (p = state->arp_table; p < LEC_ARP_TABLE_SIZE; p++) {
-		v = lec_tbl_walk(state, priv->lec_arp_tables[p], l);
+		v = lec_tbl_walk(state, &priv->lec_arp_tables[p], l);
 		if (v)
 			break;
 	}
@@ -1042,10 +1045,10 @@ static void *lec_arp_walk(struct lec_sta
 static void *lec_misc_walk(struct lec_state *state, loff_t *l,
 			   struct lec_priv *priv)
 {
-	struct lec_arp_table *lec_misc_tables[] = {
-		priv->lec_arp_empty_ones,
-		priv->lec_no_forward,
-		priv->mcast_fwds
+	struct hlist_head *lec_misc_tables[] = {
+		&priv->lec_arp_empty_ones,
+		&priv->lec_no_forward,
+		&priv->mcast_fwds
 	};
 	void *v = NULL;
 	int q;
@@ -1112,7 +1115,7 @@ static void *lec_seq_start(struct seq_fi
 	state->locked = NULL;
 	state->arp_table = 0;
 	state->misc_table = 0;
-	state->entry = (void *)1;
+	state->node = (void *)1;
 
 	return *pos ? lec_get_idx(state, *pos) : (void *)1;
 }
@@ -1148,9 +1151,10 @@ static int lec_seq_show(struct seq_file 
 	else {
 		struct lec_state *state = seq->private;
 		struct net_device *dev = state->dev;
+		struct lec_arp_table *entry = hlist_entry(state->node, struct lec_arp_table, next);
 
 		seq_printf(seq, "%s ", dev->name);
-		lec_info(seq, state->entry);
+		lec_info(seq, entry);
 	}
 	return 0;
 }
@@ -1455,8 +1459,11 @@ static void lec_arp_init(struct lec_priv
 	unsigned short i;
 
 	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
-		priv->lec_arp_tables[i] = NULL;
+		INIT_HLIST_HEAD(&priv->lec_arp_tables[i]);
 	}
+        INIT_HLIST_HEAD(&priv->lec_arp_empty_ones);
+        INIT_HLIST_HEAD(&priv->lec_no_forward);
+        INIT_HLIST_HEAD(&priv->mcast_fwds);
 	spin_lock_init(&priv->lec_arp_lock);
 	init_timer(&priv->lec_arp_timer);
 	priv->lec_arp_timer.expires = jiffies + LEC_ARP_REFRESH_INTERVAL;
@@ -1479,7 +1486,7 @@ static void lec_arp_clear_vccs(struct le
 		vcc->user_back = NULL;
 		vcc->push = entry->old_push;
 		vcc_release_async(vcc, -EPIPE);
-		vcc = NULL;
+		entry->vcc = NULL;
 	}
 	if (entry->recv_vcc) {
 		entry->recv_vcc->push = entry->old_recv_push;
@@ -1493,27 +1500,17 @@ static void lec_arp_clear_vccs(struct le
  * LANE2: Add to the end of the list to satisfy 8.1.13
  */
 static inline void
-lec_arp_add(struct lec_priv *priv, struct lec_arp_table *to_add)
+lec_arp_add(struct lec_priv *priv, struct lec_arp_table *entry)
 {
-	unsigned short place;
-	struct lec_arp_table *tmp;
+	struct hlist_head *tmp;
 
-	place = HASH(to_add->mac_addr[ETH_ALEN - 1]);
-	tmp = priv->lec_arp_tables[place];
-	to_add->next = NULL;
-	if (tmp == NULL)
-		priv->lec_arp_tables[place] = to_add;
-
-	else {			/* add to the end */
-		while (tmp->next)
-			tmp = tmp->next;
-		tmp->next = to_add;
-	}
+	tmp = &priv->lec_arp_tables[HASH(entry->mac_addr[ETH_ALEN - 1])];
+	hlist_add_head(&entry->next, tmp);
 
 	DPRINTK("LEC_ARP: Added entry:%2.2x %2.2x %2.2x %2.2x %2.2x %2.2x\n",
-		0xff & to_add->mac_addr[0], 0xff & to_add->mac_addr[1],
-		0xff & to_add->mac_addr[2], 0xff & to_add->mac_addr[3],
-		0xff & to_add->mac_addr[4], 0xff & to_add->mac_addr[5]);
+		0xff & entry->mac_addr[0], 0xff & entry->mac_addr[1],
+		0xff & entry->mac_addr[2], 0xff & entry->mac_addr[3],
+		0xff & entry->mac_addr[4], 0xff & entry->mac_addr[5]);
 }
 
 /*
@@ -1522,40 +1519,26 @@ lec_arp_add(struct lec_priv *priv, struc
 static int
 lec_arp_remove(struct lec_priv *priv, struct lec_arp_table *to_remove)
 {
-	unsigned short place;
-	struct lec_arp_table *tmp;
-	int remove_vcc = 1;
+	struct hlist_node *node;
+	struct lec_arp_table *entry;
+	int i, remove_vcc = 1;
 
 	if (!to_remove) {
 		return -1;
 	}
-	place = HASH(to_remove->mac_addr[ETH_ALEN - 1]);
-	tmp = priv->lec_arp_tables[place];
-	if (tmp == to_remove) {
-		priv->lec_arp_tables[place] = tmp->next;
-	} else {
-		while (tmp && tmp->next != to_remove) {
-			tmp = tmp->next;
-		}
-		if (!tmp) {	/* Entry was not found */
-			return -1;
-		}
-	}
-	tmp->next = to_remove->next;
+
+	hlist_del(&to_remove->next);
 	del_timer(&to_remove->timer);
 
-	/* If this is the only MAC connected to this VCC, also tear down
-	   the VCC */
+	/* If this is the only MAC connected to this VCC, also tear down the VCC */
 	if (to_remove->status >= ESI_FLUSH_PENDING) {
 		/*
 		 * ESI_FLUSH_PENDING, ESI_FORWARD_DIRECT
 		 */
-		for (place = 0; place < LEC_ARP_TABLE_SIZE; place++) {
-			for (tmp = priv->lec_arp_tables[place]; tmp != NULL;
-			     tmp = tmp->next) {
-				if (memcmp
-				    (tmp->atm_addr, to_remove->atm_addr,
-				     ATM_ESA_LEN) == 0) {
+		for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
+			hlist_for_each_entry(entry, node, &priv->lec_arp_tables[i], next) {
+				if (memcmp(to_remove->atm_addr,
+					   entry->atm_addr, ATM_ESA_LEN) == 0) {
 					remove_vcc = 0;
 					break;
 				}
@@ -1591,28 +1574,19 @@ static char *get_status_string(unsigned 
 		return "<UNKNOWN>";
 	}
 }
-#endif
 
 static void dump_arp_table(struct lec_priv *priv)
 {
-#if DEBUG_ARP_TABLE
-	int i, j, offset;
+	struct hlist_node *node;
 	struct lec_arp_table *rulla;
-	char buf[1024];
-	struct lec_arp_table **lec_arp_tables =
-	    (struct lec_arp_table **)priv->lec_arp_tables;
-	struct lec_arp_table *lec_arp_empty_ones =
-	    (struct lec_arp_table *)priv->lec_arp_empty_ones;
-	struct lec_arp_table *lec_no_forward =
-	    (struct lec_arp_table *)priv->lec_no_forward;
-	struct lec_arp_table *mcast_fwds = priv->mcast_fwds;
+	char buf[256];
+	int i, j, offset;
 
 	printk("Dump %p:\n", priv);
 	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
-		rulla = lec_arp_tables[i];
-		offset = 0;
-		offset += sprintf(buf, "%d: %p\n", i, rulla);
-		while (rulla) {
+		hlist_for_each_entry(rulla, node, &priv->lec_arp_tables[i], next) {
+			offset = 0;
+			offset += sprintf(buf, "%d: %p\n", i, rulla);
 			offset += sprintf(buf + offset, "Mac:");
 			for (j = 0; j < ETH_ALEN; j++) {
 				offset += sprintf(buf + offset,
@@ -1639,15 +1613,13 @@ #if DEBUG_ARP_TABLE
 				    "Flags:%x, Packets_flooded:%x, Status: %s ",
 				    rulla->flags, rulla->packets_flooded,
 				    get_status_string(rulla->status));
-			offset += sprintf(buf + offset, "->%p\n", rulla->next);
-			rulla = rulla->next;
+			printk("%s\n", buf);
 		}
-		printk("%s", buf);
 	}
-	rulla = lec_no_forward;
-	if (rulla)
+
+	if (!hlist_empty(&priv->lec_no_forward))
 		printk("No forward\n");
-	while (rulla) {
+	hlist_for_each_entry(rulla, node, &priv->lec_no_forward, next) {
 		offset = 0;
 		offset += sprintf(buf + offset, "Mac:");
 		for (j = 0; j < ETH_ALEN; j++) {
@@ -1671,14 +1643,12 @@ #if DEBUG_ARP_TABLE
 				  "Flags:%x, Packets_flooded:%x, Status: %s ",
 				  rulla->flags, rulla->packets_flooded,
 				  get_status_string(rulla->status));
-		offset += sprintf(buf + offset, "->%lx\n", (long)rulla->next);
-		rulla = rulla->next;
-		printk("%s", buf);
+		printk("%s\n", buf);
 	}
-	rulla = lec_arp_empty_ones;
-	if (rulla)
+
+	if (!hlist_empty(&priv->lec_arp_empty_ones))
 		printk("Empty ones\n");
-	while (rulla) {
+	hlist_for_each_entry(rulla, node, &priv->lec_arp_empty_ones, next) {
 		offset = 0;
 		offset += sprintf(buf + offset, "Mac:");
 		for (j = 0; j < ETH_ALEN; j++) {
@@ -1702,15 +1672,12 @@ #if DEBUG_ARP_TABLE
 				  "Flags:%x, Packets_flooded:%x, Status: %s ",
 				  rulla->flags, rulla->packets_flooded,
 				  get_status_string(rulla->status));
-		offset += sprintf(buf + offset, "->%lx\n", (long)rulla->next);
-		rulla = rulla->next;
 		printk("%s", buf);
 	}
 
-	rulla = mcast_fwds;
-	if (rulla)
+	if (!hlist_empty(&priv->mcast_fwds))
 		printk("Multicast Forward VCCs\n");
-	while (rulla) {
+	hlist_for_each_entry(rulla, node, &priv->mcast_fwds, next) {
 		offset = 0;
 		offset += sprintf(buf + offset, "Mac:");
 		for (j = 0; j < ETH_ALEN; j++) {
@@ -1734,13 +1701,13 @@ #if DEBUG_ARP_TABLE
 				  "Flags:%x, Packets_flooded:%x, Status: %s ",
 				  rulla->flags, rulla->packets_flooded,
 				  get_status_string(rulla->status));
-		offset += sprintf(buf + offset, "->%lx\n", (long)rulla->next);
-		rulla = rulla->next;
-		printk("%s", buf);
+		printk("%s\n", buf);
 	}
 
-#endif
 }
+#else
+#define dump_arp_table(priv) do { } while (0)
+#endif
 
 /*
  * Destruction of arp-cache
@@ -1748,7 +1715,8 @@ #endif
 static void lec_arp_destroy(struct lec_priv *priv)
 {
 	unsigned long flags;
-	struct lec_arp_table *entry, *next;
+	struct hlist_node *node, *next;
+	struct lec_arp_table *entry;
 	int i;
 
 	del_timer_sync(&priv->lec_arp_timer);
@@ -1759,43 +1727,37 @@ static void lec_arp_destroy(struct lec_p
 
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
 	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
-		for (entry = priv->lec_arp_tables[i]; entry != NULL;
-		     entry = next) {
-			next = entry->next;
+		hlist_for_each_entry_safe(entry, node, next, &priv->lec_arp_tables[i], next) {
 			lec_arp_remove(priv, entry);
 			kfree(entry);
 		}
+		INIT_HLIST_HEAD(&priv->lec_arp_tables[i]);
 	}
-	entry = priv->lec_arp_empty_ones;
-	while (entry) {
-		next = entry->next;
+
+	hlist_for_each_entry_safe(entry, node, next, &priv->lec_arp_empty_ones, next) {
 		del_timer_sync(&entry->timer);
 		lec_arp_clear_vccs(entry);
+		hlist_del(&entry->next);
 		kfree(entry);
-		entry = next;
 	}
-	priv->lec_arp_empty_ones = NULL;
-	entry = priv->lec_no_forward;
-	while (entry) {
-		next = entry->next;
+	INIT_HLIST_HEAD(&priv->lec_arp_empty_ones);
+	
+	hlist_for_each_entry_safe(entry, node, next, &priv->lec_no_forward, next) {
 		del_timer_sync(&entry->timer);
 		lec_arp_clear_vccs(entry);
+		hlist_del(&entry->next);
 		kfree(entry);
-		entry = next;
 	}
-	priv->lec_no_forward = NULL;
-	entry = priv->mcast_fwds;
-	while (entry) {
-		next = entry->next;
+	INIT_HLIST_HEAD(&priv->lec_no_forward);
+
+	hlist_for_each_entry_safe(entry, node, next, &priv->mcast_fwds, next) {
 		/* No timer, LANEv2 7.1.20 and 2.3.5.3 */
 		lec_arp_clear_vccs(entry);
+		hlist_del(&entry->next);
 		kfree(entry);
-		entry = next;
 	}
-	priv->mcast_fwds = NULL;
+	INIT_HLIST_HEAD(&priv->mcast_fwds);
 	priv->mcast_vcc = NULL;
-	memset(priv->lec_arp_tables, 0,
-	       sizeof(struct lec_arp_table *) * LEC_ARP_TABLE_SIZE);
 	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
 }
 
@@ -1805,20 +1767,19 @@ static void lec_arp_destroy(struct lec_p
 static struct lec_arp_table *lec_arp_find(struct lec_priv *priv,
 					  unsigned char *mac_addr)
 {
-	unsigned short place;
-	struct lec_arp_table *to_return;
+	struct hlist_node *node;
+	struct hlist_head *head;
+	struct lec_arp_table *entry;
 
 	DPRINTK("LEC_ARP: lec_arp_find :%2.2x %2.2x %2.2x %2.2x %2.2x %2.2x\n",
 		mac_addr[0] & 0xff, mac_addr[1] & 0xff, mac_addr[2] & 0xff,
 		mac_addr[3] & 0xff, mac_addr[4] & 0xff, mac_addr[5] & 0xff);
-	place = HASH(mac_addr[ETH_ALEN - 1]);
 
-	to_return = priv->lec_arp_tables[place];
-	while (to_return) {
-		if (!compare_ether_addr(mac_addr, to_return->mac_addr)) {
-			return to_return;
+	head = &priv->lec_arp_tables[HASH(mac_addr[ETH_ALEN - 1])];
+	hlist_for_each_entry(entry, node, head, next) {
+		if (!compare_ether_addr(mac_addr, entry->mac_addr)) {
+			return entry;
 		}
-		to_return = to_return->next;
 	}
 	return NULL;
 }
@@ -1834,6 +1795,7 @@ static struct lec_arp_table *make_entry(
 		return NULL;
 	}
 	memcpy(to_return->mac_addr, mac_addr, ETH_ALEN);
+	INIT_HLIST_NODE(&to_return->next);
 	init_timer(&to_return->timer);
 	to_return->timer.function = lec_arp_expire_arp;
 	to_return->timer.data = (unsigned long)to_return;
@@ -1871,7 +1833,6 @@ static void lec_arp_expire_vcc(unsigned 
 	unsigned long flags;
 	struct lec_arp_table *to_remove = (struct lec_arp_table *)data;
 	struct lec_priv *priv = (struct lec_priv *)to_remove->priv;
-	struct lec_arp_table *entry = NULL;
 
 	del_timer(&to_remove->timer);
 
@@ -1879,30 +1840,9 @@ static void lec_arp_expire_vcc(unsigned 
 		to_remove, priv,
 		to_remove->vcc ? to_remove->recv_vcc->vpi : 0,
 		to_remove->vcc ? to_remove->recv_vcc->vci : 0);
-	DPRINTK("eo:%p nf:%p\n", priv->lec_arp_empty_ones,
-		priv->lec_no_forward);
 
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
-	if (to_remove == priv->lec_arp_empty_ones)
-		priv->lec_arp_empty_ones = to_remove->next;
-	else {
-		entry = priv->lec_arp_empty_ones;
-		while (entry && entry->next != to_remove)
-			entry = entry->next;
-		if (entry)
-			entry->next = to_remove->next;
-	}
-	if (!entry) {
-		if (to_remove == priv->lec_no_forward) {
-			priv->lec_no_forward = to_remove->next;
-		} else {
-			entry = priv->lec_no_forward;
-			while (entry && entry->next != to_remove)
-				entry = entry->next;
-			if (entry)
-				entry->next = to_remove->next;
-		}
-	}
+	hlist_del(&to_remove->next);
 	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
 
 	lec_arp_clear_vccs(to_remove);
@@ -1929,18 +1869,17 @@ static void lec_arp_check_expire(unsigne
 {
 	unsigned long flags;
 	struct lec_priv *priv = (struct lec_priv *)data;
-	struct lec_arp_table *entry, *next;
+	struct hlist_node *node, *next;
+	struct lec_arp_table *entry;
 	unsigned long now;
 	unsigned long time_to_check;
 	int i;
 
 	DPRINTK("lec_arp_check_expire %p\n", priv);
-	DPRINTK("expire: eo:%p nf:%p\n", priv->lec_arp_empty_ones,
-		priv->lec_no_forward);
 	now = jiffies;
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
 	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
-		for (entry = priv->lec_arp_tables[i]; entry != NULL;) {
+		hlist_for_each_entry_safe(entry, node, next, &priv->lec_arp_tables[i], next) {
 			if ((entry->flags) & LEC_REMOTE_FLAG &&
 			    priv->topology_change)
 				time_to_check = priv->forward_delay_time;
@@ -1954,10 +1893,8 @@ static void lec_arp_check_expire(unsigne
 			    && !(entry->mac_addr[0] & 0x01)) {	/* LANE2: 7.1.20 */
 				/* Remove entry */
 				DPRINTK("LEC:Entry timed out\n");
-				next = entry->next;
 				lec_arp_remove(priv, entry);
 				kfree(entry);
-				entry = next;
 			} else {
 				/* Something else */
 				if ((entry->status == ESI_VC_PENDING ||
@@ -1988,7 +1925,6 @@ static void lec_arp_check_expire(unsigne
 					entry->last_used = jiffies;
 					entry->status = ESI_FORWARD_DIRECT;
 				}
-				entry = entry->next;
 			}
 		}
 	}
@@ -2100,15 +2036,14 @@ lec_addr_delete(struct lec_priv *priv, u
 		unsigned long permanent)
 {
 	unsigned long flags;
-	struct lec_arp_table *entry, *next;
+	struct hlist_node *node, *next;
+	struct lec_arp_table *entry;
 	int i;
 
 	DPRINTK("lec_addr_delete\n");
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
 	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
-		for (entry = priv->lec_arp_tables[i]; entry != NULL;
-		     entry = next) {
-			next = entry->next;
+		hlist_for_each_entry_safe(entry, node, next, &priv->lec_arp_tables[i], next) {
 			if (!memcmp(atm_addr, entry->atm_addr, ATM_ESA_LEN)
 			    && (permanent ||
 				!(entry->flags & LEC_PERMANENT_FLAG))) {
@@ -2132,6 +2067,7 @@ lec_arp_update(struct lec_priv *priv, un
 	       unsigned int targetless_le_arp)
 {
 	unsigned long flags;
+	struct hlist_node *node, *next;
 	struct lec_arp_table *entry, *tmp;
 	int i;
 
@@ -2147,50 +2083,39 @@ lec_arp_update(struct lec_priv *priv, un
 				 * LANE2: ignore targetless LE_ARPs for which
 				 * we have no entry in the cache. 7.1.30
 				 */
-	if (priv->lec_arp_empty_ones) {
-		entry = priv->lec_arp_empty_ones;
-		if (!memcmp(entry->atm_addr, atm_addr, ATM_ESA_LEN)) {
-			priv->lec_arp_empty_ones = entry->next;
-		} else {
-			while (entry->next && memcmp(entry->next->atm_addr,
-						     atm_addr, ATM_ESA_LEN))
-				entry = entry->next;
-			if (entry->next) {
-				tmp = entry;
-				entry = entry->next;
-				tmp->next = entry->next;
-			} else
-				entry = NULL;
-
-		}
-		if (entry) {
-			del_timer(&entry->timer);
-			tmp = lec_arp_find(priv, mac_addr);
-			if (tmp) {
-				del_timer(&tmp->timer);
-				tmp->status = ESI_FORWARD_DIRECT;
-				memcpy(tmp->atm_addr, atm_addr, ATM_ESA_LEN);
-				tmp->vcc = entry->vcc;
-				tmp->old_push = entry->old_push;
-				tmp->last_used = jiffies;
+	if (!hlist_empty(&priv->lec_arp_empty_ones)) {
+		hlist_for_each_entry_safe(entry, node, next, &priv->lec_arp_empty_ones, next) {
+			if (memcmp(entry->atm_addr, atm_addr, ATM_ESA_LEN) == 0) {
+				hlist_del(&entry->next);
 				del_timer(&entry->timer);
-				kfree(entry);
-				entry = tmp;
-			} else {
-				entry->status = ESI_FORWARD_DIRECT;
-				memcpy(entry->mac_addr, mac_addr, ETH_ALEN);
-				entry->last_used = jiffies;
-				lec_arp_add(priv, entry);
+				tmp = lec_arp_find(priv, mac_addr);
+				if (tmp) {
+					del_timer(&tmp->timer);
+					tmp->status = ESI_FORWARD_DIRECT;
+					memcpy(tmp->atm_addr, atm_addr, ATM_ESA_LEN);
+					tmp->vcc = entry->vcc;
+					tmp->old_push = entry->old_push;
+					tmp->last_used = jiffies;
+					del_timer(&entry->timer);
+					kfree(entry);
+					entry = tmp;
+				} else {
+					entry->status = ESI_FORWARD_DIRECT;
+					memcpy(entry->mac_addr, mac_addr, ETH_ALEN);
+					entry->last_used = jiffies;
+					lec_arp_add(priv, entry);
+				}
+				if (remoteflag)
+					entry->flags |= LEC_REMOTE_FLAG;
+				else
+					entry->flags &= ~LEC_REMOTE_FLAG;
+				DPRINTK("After update\n");
+				dump_arp_table(priv);
+				goto out;
 			}
-			if (remoteflag)
-				entry->flags |= LEC_REMOTE_FLAG;
-			else
-				entry->flags &= ~LEC_REMOTE_FLAG;
-			DPRINTK("After update\n");
-			dump_arp_table(priv);
-			goto out;
 		}
 	}
+
 	entry = lec_arp_find(priv, mac_addr);
 	if (!entry) {
 		entry = make_entry(priv, mac_addr);
@@ -2203,7 +2128,7 @@ lec_arp_update(struct lec_priv *priv, un
 	memcpy(entry->atm_addr, atm_addr, ATM_ESA_LEN);
 	del_timer(&entry->timer);
 	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
-		for (tmp = priv->lec_arp_tables[i]; tmp; tmp = tmp->next) {
+		hlist_for_each_entry(tmp, node, &priv->lec_arp_tables[i], next) {
 			if (entry != tmp &&
 			    !memcmp(tmp->atm_addr, atm_addr, ATM_ESA_LEN)) {
 				/* Vcc to this host exists */
@@ -2226,8 +2151,7 @@ lec_arp_update(struct lec_priv *priv, un
 		entry->flags &= ~LEC_REMOTE_FLAG;
 	if (entry->status == ESI_ARP_PENDING || entry->status == ESI_UNKNOWN) {
 		entry->status = ESI_VC_PENDING;
-		send_to_lecd(priv, l_svc_setup, entry->mac_addr, atm_addr,
-			     NULL);
+		send_to_lecd(priv, l_svc_setup, entry->mac_addr, atm_addr, NULL);
 	}
 	DPRINTK("After update2\n");
 	dump_arp_table(priv);
@@ -2244,6 +2168,7 @@ lec_vcc_added(struct lec_priv *priv, str
 	      void (*old_push) (struct atm_vcc *vcc, struct sk_buff *skb))
 {
 	unsigned long flags;
+	struct hlist_node *node;
 	struct lec_arp_table *entry;
 	int i, found_entry = 0;
 
@@ -2269,8 +2194,7 @@ #endif
 		memcpy(entry->atm_addr, ioc_data->atm_addr, ATM_ESA_LEN);
 		entry->recv_vcc = vcc;
 		entry->old_recv_push = old_push;
-		entry->next = priv->mcast_fwds;
-		priv->mcast_fwds = entry;
+		hlist_add_head(&entry->next, &priv->mcast_fwds);
 		goto out;
 	} else if (ioc_data->receive == 1) {
 		/*
@@ -2300,9 +2224,8 @@ #endif
 		entry->status = ESI_UNKNOWN;
 		entry->timer.expires = jiffies + priv->vcc_timeout_period;
 		entry->timer.function = lec_arp_expire_vcc;
+		hlist_add_head(&entry->next, &priv->lec_no_forward);
 		add_timer(&entry->timer);
-		entry->next = priv->lec_no_forward;
-		priv->lec_no_forward = entry;
 		dump_arp_table(priv);
 		goto out;
 	}
@@ -2320,8 +2243,7 @@ #endif
 	     ioc_data->atm_addr[16], ioc_data->atm_addr[17],
 	     ioc_data->atm_addr[18], ioc_data->atm_addr[19]);
 	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
-		for (entry = priv->lec_arp_tables[i]; entry;
-		     entry = entry->next) {
+		hlist_for_each_entry(entry, node, &priv->lec_arp_tables[i], next) {
 			if (memcmp
 			    (ioc_data->atm_addr, entry->atm_addr,
 			     ATM_ESA_LEN) == 0) {
@@ -2384,8 +2306,7 @@ #endif
 	memcpy(entry->atm_addr, ioc_data->atm_addr, ATM_ESA_LEN);
 	memset(entry->mac_addr, 0, ETH_ALEN);
 	entry->status = ESI_UNKNOWN;
-	entry->next = priv->lec_arp_empty_ones;
-	priv->lec_arp_empty_ones = entry;
+	hlist_add_head(&entry->next, &priv->lec_arp_empty_ones);
 	entry->timer.expires = jiffies + priv->vcc_timeout_period;
 	entry->timer.function = lec_arp_expire_vcc;
 	add_timer(&entry->timer);
@@ -2398,14 +2319,14 @@ out:
 static void lec_flush_complete(struct lec_priv *priv, unsigned long tran_id)
 {
 	unsigned long flags;
+	struct hlist_node *node;
 	struct lec_arp_table *entry;
 	int i;
 
 	DPRINTK("LEC:lec_flush_complete %lx\n", tran_id);
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
 	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
-		for (entry = priv->lec_arp_tables[i]; entry;
-		     entry = entry->next) {
+		hlist_for_each_entry(entry, node, &priv->lec_arp_tables[i], next) {
 			if (entry->flush_tran_id == tran_id
 			    && entry->status == ESI_FLUSH_PENDING) {
 				struct sk_buff *skb;
@@ -2427,19 +2348,19 @@ lec_set_flush_tran_id(struct lec_priv *p
 		      unsigned char *atm_addr, unsigned long tran_id)
 {
 	unsigned long flags;
+	struct hlist_node *node;
 	struct lec_arp_table *entry;
 	int i;
 
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
 	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++)
-		for (entry = priv->lec_arp_tables[i]; entry;
-		     entry = entry->next)
+		hlist_for_each_entry(entry, node, &priv->lec_arp_tables[i], next) {
 			if (!memcmp(atm_addr, entry->atm_addr, ATM_ESA_LEN)) {
 				entry->flush_tran_id = tran_id;
-				DPRINTK
-				    ("Set flush transaction id to %lx for %p\n",
-				     tran_id, entry);
+				DPRINTK("Set flush transaction id to %lx for %p\n",
+				        tran_id, entry);
 			}
+		}
 	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
 }
 
@@ -2483,15 +2404,17 @@ out:
 static void lec_vcc_close(struct lec_priv *priv, struct atm_vcc *vcc)
 {
 	unsigned long flags;
-	struct lec_arp_table *entry, *next;
+	struct hlist_node *node, *next;
+	struct lec_arp_table *entry;
 	int i;
 
 	DPRINTK("LEC_ARP: lec_vcc_close vpi:%d vci:%d\n", vcc->vpi, vcc->vci);
 	dump_arp_table(priv);
+
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
+
 	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
-		for (entry = priv->lec_arp_tables[i]; entry; entry = next) {
-			next = entry->next;
+		hlist_for_each_entry_safe(entry, node, next, &priv->lec_arp_tables[i], next) {
 			if (vcc == entry->vcc) {
 				lec_arp_remove(priv, entry);
 				kfree(entry);
@@ -2502,49 +2425,31 @@ static void lec_vcc_close(struct lec_pri
 		}
 	}
 
-	entry = priv->lec_arp_empty_ones;
-	priv->lec_arp_empty_ones = NULL;
-	while (entry != NULL) {
-		next = entry->next;
-		if (entry->vcc == vcc) {	/* leave it out from the list */
+	hlist_for_each_entry_safe(entry, node, next, &priv->lec_arp_empty_ones, next) {
+		if (entry->vcc == vcc) {
 			lec_arp_clear_vccs(entry);
 			del_timer(&entry->timer);
+			hlist_del(&entry->next);
 			kfree(entry);
-		} else {			/* put it back to the list */
-			entry->next = priv->lec_arp_empty_ones;
-			priv->lec_arp_empty_ones = entry;
 		}
-		entry = next;
 	}
 
-	entry = priv->lec_no_forward;
-	priv->lec_no_forward = NULL;
-	while (entry != NULL) {
-		next = entry->next;
+	hlist_for_each_entry_safe(entry, node, next, &priv->lec_no_forward, next) {
 		if (entry->recv_vcc == vcc) {
 			lec_arp_clear_vccs(entry);
 			del_timer(&entry->timer);
+			hlist_del(&entry->next);
 			kfree(entry);
-		} else {
-			entry->next = priv->lec_no_forward;
-			priv->lec_no_forward = entry;
 		}
-		entry = next;
 	}
 
-	entry = priv->mcast_fwds;
-	priv->mcast_fwds = NULL;
-	while (entry != NULL) {
-		next = entry->next;
+	hlist_for_each_entry_safe(entry, node, next, &priv->mcast_fwds, next) {
 		if (entry->recv_vcc == vcc) {
 			lec_arp_clear_vccs(entry);
 			/* No timer, LANEv2 7.1.20 and 2.3.5.3 */
+			hlist_del(&entry->next);
 			kfree(entry);
-		} else {
-			entry->next = priv->mcast_fwds;
-			priv->mcast_fwds = entry;
 		}
-		entry = next;
 	}
 
 	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
@@ -2556,7 +2461,8 @@ lec_arp_check_empties(struct lec_priv *p
 		      struct atm_vcc *vcc, struct sk_buff *skb)
 {
 	unsigned long flags;
-	struct lec_arp_table *entry, *prev;
+	struct hlist_node *node, *next;
+	struct lec_arp_table *entry, *tmp;
 	struct lecdatahdr_8023 *hdr = (struct lecdatahdr_8023 *)skb->data;
 	unsigned char *src;
 #ifdef CONFIG_TR
@@ -2569,41 +2475,23 @@ #endif
 		src = hdr->h_source;
 
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
-	entry = priv->lec_arp_empty_ones;
-	if (vcc == entry->vcc) {
-		del_timer(&entry->timer);
-		memcpy(entry->mac_addr, src, ETH_ALEN);
-		entry->status = ESI_FORWARD_DIRECT;
-		entry->last_used = jiffies;
-		priv->lec_arp_empty_ones = entry->next;
-		/* We might have got an entry */
-		if ((prev = lec_arp_find(priv, src))) {
-			lec_arp_remove(priv, prev);
-			kfree(prev);
+	hlist_for_each_entry_safe(entry, node, next, &priv->lec_arp_empty_ones, next) {
+		if (vcc == entry->vcc) {
+			del_timer(&entry->timer);
+			memcpy(entry->mac_addr, src, ETH_ALEN);
+			entry->status = ESI_FORWARD_DIRECT;
+			entry->last_used = jiffies;
+			/* We might have got an entry */
+			if ((tmp = lec_arp_find(priv, src))) {
+				lec_arp_remove(priv, tmp);
+				kfree(tmp);
+			}
+			hlist_del(&entry->next);
+			lec_arp_add(priv, entry);
+			goto out;
 		}
-		lec_arp_add(priv, entry);
-		goto out;
-	}
-	prev = entry;
-	entry = entry->next;
-	while (entry && entry->vcc != vcc) {
-		prev = entry;
-		entry = entry->next;
 	}
-	if (!entry) {
-		DPRINTK("LEC_ARP: Arp_check_empties: entry not found!\n");
-		goto out;
-	}
-	del_timer(&entry->timer);
-	memcpy(entry->mac_addr, src, ETH_ALEN);
-	entry->status = ESI_FORWARD_DIRECT;
-	entry->last_used = jiffies;
-	prev->next = entry->next;
-	if ((prev = lec_arp_find(priv, src))) {
-		lec_arp_remove(priv, prev);
-		kfree(prev);
-	}
-	lec_arp_add(priv, entry);
+	DPRINTK("LEC_ARP: Arp_check_empties: entry not found!\n");
 out:
 	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
 }
diff --git a/net/atm/lec.h b/net/atm/lec.h
index 7efd586..8a6cb64 100644
--- a/net/atm/lec.h
+++ b/net/atm/lec.h
@@ -72,18 +72,18 @@ #define LEC_ARP_TABLE_SIZE 16
 struct lec_priv {
 	struct net_device_stats stats;
 	unsigned short lecid;			/* Lecid of this client */
-	struct lec_arp_table *lec_arp_empty_ones;
+	struct hlist_head lec_arp_empty_ones;
 						/* Used for storing VCC's that don't have a MAC address attached yet */
-	struct lec_arp_table *lec_arp_tables[LEC_ARP_TABLE_SIZE];
+	struct hlist_head lec_arp_tables[LEC_ARP_TABLE_SIZE];
 						/* Actual LE ARP table */
-	struct lec_arp_table *lec_no_forward;
+	struct hlist_head lec_no_forward;
 						/*
 						 * Used for storing VCC's (and forward packets from) which are to
 						 * age out by not using them to forward packets. 
 						 * This is because to some LE clients there will be 2 VCCs. Only
 						 * one of them gets used.
 						 */
-	struct lec_arp_table *mcast_fwds;
+	struct hlist_head mcast_fwds;
 						/*
 						 * With LANEv2 it is possible that BUS (or a special multicast server)
 						 * establishes multiple Multicast Forward VCCs to us. This list
diff --git a/net/atm/lec_arpc.h b/net/atm/lec_arpc.h
index eb09a35..3cc2eba 100644
--- a/net/atm/lec_arpc.h
+++ b/net/atm/lec_arpc.h
@@ -11,7 +11,7 @@ #include <linux/if_ether.h>
 #include <linux/atmlec.h>
 
 struct lec_arp_table {
-	struct lec_arp_table *next;	/* Linked entry list */
+	struct hlist_node next;		/* Linked entry list */
 	unsigned char atm_addr[ATM_ESA_LEN];	/* Atm address */
 	unsigned char mac_addr[ETH_ALEN];	/* Mac address */
 	int is_rdesc;			/* Mac address is a route descriptor */
