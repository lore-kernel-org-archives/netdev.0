From: Tim Gardner <timg@tpi.com>
Subject: [PATCH} ARP auto-sizing for 2.4.24 - 2.4.26-pre3
Date: Sun, 14 Mar 2004 12:10:57 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <200403141210.57266.timg@tpi.com>
Reply-To: timg@tpi.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Anton Blanchard <anton@samba.org>
List-Id: netdev.vger.kernel.org

Anton,

Included is a patch that auto-sizes ARP caches ala tcp_ehash_size. There is 
also a config option (CONFIG_NEIGH_NUM_HASHBITS) in the Network Options menu 
that allows an override, but the default is auto-size. This patch also 
includes smoothing of the ARP garbage collector, removes gc_interval, and 
removes NEIGH_HASHMASK. I have run this on small configurations. Later 
tonight I'll be trying it on one of my thousand node routers.

I've compiled the other affected protocols (IPv6, ATM, and DecNET), but have 
not run them.

rtg

<--snip-->

diff -r -u --new-file linux-2.4.bk.original/Documentation/Configure.help 
linux-2.4.bk-auto-size/Documentation/Configure.help
--- linux-2.4.bk.original/Documentation/Configure.help	2004-03-14 
08:54:48.000000000 -0700
+++ linux-2.4.bk-auto-size/Documentation/Configure.help	2004-03-13 
21:37:10.000000000 -0700
@@ -7139,6 +7139,19 @@
 
   If unsure, say N.
 
+ARP hash table size power of 2
+CONFIG_NEIGH_NUM_HASHBITS
+  This option defines the size of the ARP hash table for each protocol. The 
default size of 0
+  initiates a boot time auto-sizing algorithm. This algorithm allocates a 
power of 2 hash
+  buckets according to the number of physical pages of RAM. One power of 2 
buckets for each
+  power of 2 MB of RAM, e.g., 8 buckets for 8MB, 16 buckets for 16MB, etc. 
One hash bucket
+  consumes 4 bytes on a 32 bit CPU.
+
+  A non-zero value for CONFIG_NEIGH_NUM_HASHBITS disables the auto-size 
algorithm. You might
+  specifiy a fixed size for environments where the auto-size algorithm is
+  inappropriate. Sometimes small RAM embedded devices handle routing for a 
thousand or more
+  devices.
+
 Packet socket
 CONFIG_PACKET
   The Packet protocol is used by applications which communicate
diff -r -u --new-file linux-2.4.bk.original/include/net/neighbour.h 
linux-2.4.bk-auto-size/include/net/neighbour.h
--- linux-2.4.bk.original/include/net/neighbour.h	2004-03-14 
08:54:27.000000000 -0700
+++ linux-2.4.bk-auto-size/include/net/neighbour.h	2004-03-14 
11:00:45.000000000 -0700
@@ -128,7 +128,6 @@
 	u8			key[0];
 };
 
-#define NEIGH_HASHMASK		0x1F
 #define PNEIGH_HASHMASK		0xF
 
 /*
@@ -149,8 +148,7 @@
 	void			(*proxy_redo)(struct sk_buff *skb);
 	char			*id;
 	struct neigh_parms	parms;
-	/* HACK. gc_* shoul follow parms without a gap! */
-	int			gc_interval;
+	/* HACK. gc_* should follow parms without a gap! */
 	int			gc_thresh1;
 	int			gc_thresh2;
 	int			gc_thresh3;
@@ -165,7 +163,9 @@
 	kmem_cache_t		*kmem_cachep;
 	struct tasklet_struct	gc_task;
 	struct neigh_statistics	stats;
-	struct neighbour	*hash_buckets[NEIGH_HASHMASK+1];
+	struct neighbour	**hash_buckets;
+	int					num_hash_buckets;
+	int					curr_hash_bucket; /* for the garbage collector */
 	struct pneigh_entry	*phash_buckets[PNEIGH_HASHMASK+1];
 };
 
diff -r -u --new-file linux-2.4.bk.original/net/atm/clip.c 
linux-2.4.bk-auto-size/net/atm/clip.c
--- linux-2.4.bk.original/net/atm/clip.c	2004-03-14 08:54:29.000000000 -0700
+++ linux-2.4.bk-auto-size/net/atm/clip.c	2004-03-13 22:12:11.000000000 -0700
@@ -126,7 +126,7 @@
 
 	/*DPRINTK("idle_timer_check\n");*/
 	write_lock(&clip_tbl.lock);
-	for (i = 0; i <= NEIGH_HASHMASK; i++) {
+	for (i = 0; i < clip_tbl.num_hash_buckets; i++) {
 		struct neighbour **np;
 
 		for (np = &clip_tbl.hash_buckets[i]; *np;) {
@@ -318,6 +318,7 @@
 	return 0;
 }
 
+static struct neigh_table clip_tbl;
 static u32 clip_hash(const void *pkey, const struct net_device *dev)
 {
 	u32 hash_val;
@@ -326,7 +327,7 @@
 	hash_val ^= (hash_val>>16);
 	hash_val ^= hash_val>>8;
 	hash_val ^= hash_val>>3;
-	hash_val = (hash_val^dev->ifindex)&NEIGH_HASHMASK;
+	hash_val = (hash_val^dev->ifindex)&(clip_tbl.num_hash_buckets-1);
 
 	return hash_val;
 }
diff -r -u --new-file linux-2.4.bk.original/net/atm/proc.c 
linux-2.4.bk-auto-size/net/atm/proc.c
--- linux-2.4.bk.original/net/atm/proc.c	2004-03-14 08:54:29.000000000 -0700
+++ linux-2.4.bk-auto-size/net/atm/proc.c	2004-03-13 22:00:28.000000000 -0700
@@ -430,7 +430,7 @@
 		return 0;
 	count = pos;
 	read_lock_bh(&clip_tbl_hook->lock);
-	for (i = 0; i <= NEIGH_HASHMASK; i++)
+	for (i = 0; i < clip_tbl_hook->num_hash_buckets; i++)
 		for (n = clip_tbl_hook->hash_buckets[i]; n; n = n->next) {
 			struct atmarp_entry *entry = NEIGH2ENTRY(n);
 			struct clip_vcc *vcc;
diff -r -u --new-file linux-2.4.bk.original/net/Config.in 
linux-2.4.bk-auto-size/net/Config.in
--- linux-2.4.bk.original/net/Config.in	2004-03-14 08:54:37.000000000 -0700
+++ linux-2.4.bk-auto-size/net/Config.in	2004-03-14 10:49:33.000000000 -0700
@@ -8,6 +8,8 @@
    bool '  Packet socket: mmapped IO' CONFIG_PACKET_MMAP
 fi
 
+int 'ARP hash table size power of 2' CONFIG_NEIGH_NUM_HASHBITS 0
+
 tristate 'Netlink device emulation' CONFIG_NETLINK_DEV
 
 bool 'Network packet filtering (replaces ipchains)' CONFIG_NETFILTER
diff -r -u --new-file linux-2.4.bk.original/net/core/neighbour.c 
linux-2.4.bk-auto-size/net/core/neighbour.c
--- linux-2.4.bk.original/net/core/neighbour.c	2004-03-14 08:54:29.000000000 
-0700
+++ linux-2.4.bk-auto-size/net/core/neighbour.c	2004-03-14 11:45:53.000000000 
-0700
@@ -111,7 +111,7 @@
 	int shrunk = 0;
 	int i;
 
-	for (i=0; i<=NEIGH_HASHMASK; i++) {
+	for (i=0; i<tbl->num_hash_buckets; i++) {
 		struct neighbour *n, **np;
 
 		np = &tbl->hash_buckets[i];
@@ -176,7 +176,7 @@
 
 	write_lock_bh(&tbl->lock);
 
-	for (i=0; i <= NEIGH_HASHMASK; i++) {
+	for (i=0; i < tbl->num_hash_buckets; i++) {
 		struct neighbour *n, **np;
 
 		np = &tbl->hash_buckets[i];
@@ -203,7 +203,7 @@
 
 	write_lock_bh(&tbl->lock);
 
-	for (i=0; i<=NEIGH_HASHMASK; i++) {
+	for (i=0; i<tbl->num_hash_buckets; i++) {
 		struct neighbour *n, **np;
 
 		np = &tbl->hash_buckets[i];
@@ -566,9 +566,8 @@
 static void SMP_TIMER_NAME(neigh_periodic_timer)(unsigned long arg)
 {
 	struct neigh_table *tbl = (struct neigh_table*)arg;
+	struct neighbour *n, **np;
 	unsigned long now = jiffies;
-	int i;
-
 
 	write_lock(&tbl->lock);
 
@@ -583,46 +582,49 @@
 			p->reachable_time = neigh_rand_reach_time(p->base_reachable_time);
 	}
 
-	for (i=0; i <= NEIGH_HASHMASK; i++) {
-		struct neighbour *n, **np;
+	tbl->curr_hash_bucket &= (tbl->num_hash_buckets-1);
+	np = &tbl->hash_buckets[tbl->curr_hash_bucket++];
 
-		np = &tbl->hash_buckets[i];
-		while ((n = *np) != NULL) {
-			unsigned state;
+	while ((n = *np) != NULL) {
+		unsigned state;
 
-			write_lock(&n->lock);
+		write_lock(&n->lock);
 
-			state = n->nud_state;
-			if (state&(NUD_PERMANENT|NUD_IN_TIMER)) {
-				write_unlock(&n->lock);
-				goto next_elt;
-			}
+		state = n->nud_state;
+		if (state&(NUD_PERMANENT|NUD_IN_TIMER)) {
+			write_unlock(&n->lock);
+			goto next_elt;
+		}
 
-			if ((long)(n->used - n->confirmed) < 0)
-				n->used = n->confirmed;
+		if ((long)(n->used - n->confirmed) < 0)
+			n->used = n->confirmed;
 
-			if (atomic_read(&n->refcnt) == 1 &&
-			    (state == NUD_FAILED || now - n->used > n->parms->gc_staletime)) {
-				*np = n->next;
-				n->dead = 1;
-				write_unlock(&n->lock);
-				neigh_release(n);
-				continue;
-			}
-
-			if (n->nud_state&NUD_REACHABLE &&
-			    now - n->confirmed > n->parms->reachable_time) {
-				n->nud_state = NUD_STALE;
-				neigh_suspect(n);
-			}
+		if (atomic_read(&n->refcnt) == 1 &&
+		    (state == NUD_FAILED || now - n->used > n->parms->gc_staletime)) {
+			*np = n->next;
+			n->dead = 1;
 			write_unlock(&n->lock);
+			neigh_release(n);
+			continue;
+		}
 
-next_elt:
-			np = &n->next;
+		if (n->nud_state&NUD_REACHABLE &&
+		    now - n->confirmed > n->parms->reachable_time) {
+			n->nud_state = NUD_STALE;
+			neigh_suspect(n);
 		}
+		write_unlock(&n->lock);
+
+next_elt:
+		np = &n->next;
 	}
 
-	mod_timer(&tbl->gc_timer, now + tbl->gc_interval);
+	/*
+	 * Cycle through all hash buckets every base_reachable_time/2 ticks. ARP 
entry
+	 * timeouts range from 1/2 base_reachable_time to 3/2 base_reachable_time.
+	 */
+	mod_timer(&tbl->gc_timer, now + 
((tbl->parms.base_reachable_time>>1)/(tbl->num_hash_buckets)));
+
 	write_unlock(&tbl->lock);
 }
 
@@ -905,7 +907,7 @@
 
 	neigh = __neigh_lookup(tbl, saddr, dev, lladdr || !dev->addr_len);
 	if (neigh)
-		neigh_update(neigh, lladdr, NUD_STALE, 1, 1);
+		neigh_update(neigh, lladdr, (lladdr && dev->addr_len) ? NUD_REACHABLE : 
NUD_STALE, 1, 1);
 	return neigh;
 }
 
@@ -1132,6 +1134,39 @@
 void neigh_table_init(struct neigh_table *tbl)
 {
 	unsigned long now = jiffies;
+	unsigned int goal=CONFIG_NEIGH_NUM_HASHBITS;
+
+	/*
+	 * Allocate a power of 2 hash buckets for each power of 2 MB of RAM.
+	 */
+	if (!goal)
+	{
+		unsigned int ram_mb = (num_physpages * PAGE_SIZE) / (1024 * 1024);
+		goal = 31;
+		while ((1<<goal) > ram_mb)
+		{
+			goal--;
+		}
+	}
+
+	tbl->hash_buckets = NULL;
+	while (goal && (!tbl->hash_buckets))
+	{
+		tbl->num_hash_buckets = (1<<goal);
+		tbl->hash_buckets = kmalloc(sizeof(struct neighbour 
*)*tbl->num_hash_buckets,GFP_ATOMIC);
+		goal--;
+	}
+
+	if (tbl->hash_buckets == NULL)
+		panic("%s: Could not allocate memory for hash buckets.\n",__FUNCTION__);
+	memset(tbl->hash_buckets,0,sizeof(struct neighbour 
*)*tbl->num_hash_buckets);
+
+	if (CONFIG_NEIGH_NUM_HASHBITS && (tbl->num_hash_buckets != 
((1<<CONFIG_NEIGH_NUM_HASHBITS)+1)))
+		printk(KERN_WARNING "%s: Could not allocate %u hash buckets, did %u 
instead.\n",
+			__FUNCTION__,
+			(1<<CONFIG_NEIGH_NUM_HASHBITS)+1,
+			tbl->num_hash_buckets
+		);
 
 	tbl->parms.reachable_time = 
neigh_rand_reach_time(tbl->parms.base_reachable_time);
 
@@ -1148,7 +1183,7 @@
 	tbl->lock = RW_LOCK_UNLOCKED;
 	tbl->gc_timer.data = (unsigned long)tbl;
 	tbl->gc_timer.function = neigh_periodic_timer;
-	tbl->gc_timer.expires = now + tbl->gc_interval + tbl->parms.reachable_time;
+	tbl->gc_timer.expires = now + 1;
 	add_timer(&tbl->gc_timer);
 
 	init_timer(&tbl->proxy_timer);
@@ -1364,7 +1399,7 @@
 
 	s_h = cb->args[1];
 	s_idx = idx = cb->args[2];
-	for (h=0; h <= NEIGH_HASHMASK; h++) {
+	for (h=0; h < tbl->num_hash_buckets; h++) {
 		if (h < s_h) continue;
 		if (h > s_h)
 			s_idx = 0;
@@ -1505,9 +1540,6 @@
 	{NET_NEIGH_LOCKTIME, "locktime",
          NULL, sizeof(int), 0644, NULL,
          &proc_dointvec},
-	{NET_NEIGH_GC_INTERVAL, "gc_interval",
-         NULL, sizeof(int), 0644, NULL,
-         &proc_dointvec_jiffies},
 	{NET_NEIGH_GC_THRESH1, "gc_thresh1",
          NULL, sizeof(int), 0644, NULL,
          &proc_dointvec},
diff -r -u --new-file linux-2.4.bk.original/net/decnet/dn_neigh.c 
linux-2.4.bk-auto-size/net/decnet/dn_neigh.c
--- linux-2.4.bk.original/net/decnet/dn_neigh.c	2004-03-14 08:54:29.000000000 
-0700
+++ linux-2.4.bk-auto-size/net/decnet/dn_neigh.c	2004-03-14 11:11:02.000000000 
-0700
@@ -110,7 +110,6 @@
 		proxy_qlen:		0,
 		locktime:		1 * HZ,
 	},
-	gc_interval:			30 * HZ,
 	gc_thresh1:			128,
 	gc_thresh2:			512,
 	gc_thresh3:			1024,
@@ -124,7 +123,7 @@
 	hash_val ^= (hash_val >> 10);
 	hash_val ^= (hash_val >> 3);
 
-	return hash_val & NEIGH_HASHMASK;
+	return hash_val & (dn_neigh_table.num_hash_buckets-1);
 }
 
 static int dn_neigh_construct(struct neighbour *neigh)
@@ -496,7 +495,7 @@
 
 	read_lock_bh(&tbl->lock);
 
-	for(i = 0; i < NEIGH_HASHMASK; i++) {
+	for(i = 0; i < tbl->num_hash_buckets; i++) {
 		for(neigh = tbl->hash_buckets[i]; neigh != NULL; neigh = neigh->next) {
 			if (neigh->dev != dev)
 				continue;
@@ -539,7 +538,7 @@
 
 	len += sprintf(buffer + len, "Addr    Flags State Use Blksize Dev\n");
 
-	for(i=0;i <= NEIGH_HASHMASK; i++) {
+	for(i=0;i < dn_neigh_table.num_hash_buckets; i++) {
 		read_lock_bh(&dn_neigh_table.lock);
 		n = dn_neigh_table.hash_buckets[i];
 		for(; n != NULL; n = n->next) {
diff -r -u --new-file linux-2.4.bk.original/net/ipv4/arp.c 
linux-2.4.bk-auto-size/net/ipv4/arp.c
--- linux-2.4.bk.original/net/ipv4/arp.c	2004-03-14 08:54:29.000000000 -0700
+++ linux-2.4.bk-auto-size/net/ipv4/arp.c	2004-03-14 11:03:09.000000000 -0700
@@ -185,7 +185,6 @@
 		proxy_qlen:		64,
 		locktime:		1 * HZ,
 	},
-	gc_interval:	30 * HZ,
 	gc_thresh1:	128,
 	gc_thresh2:	512,
 	gc_thresh3:	1024,
@@ -220,7 +219,7 @@
 	hash_val ^= (hash_val>>16);
 	hash_val ^= hash_val>>8;
 	hash_val ^= hash_val>>3;
-	hash_val = (hash_val^dev->ifindex)&NEIGH_HASHMASK;
+	hash_val = (hash_val^dev->ifindex)&(arp_tbl.num_hash_buckets-1);
 
 	return hash_val;
 }
@@ -1115,7 +1114,7 @@
 	pos+=size;
 	len+=size;
 
-	for(i=0; i<=NEIGH_HASHMASK; i++) {
+	for(i=0; i<arp_tbl.num_hash_buckets; i++) {
 		struct neighbour *n;
 		read_lock_bh(&arp_tbl.lock);
 		for (n=arp_tbl.hash_buckets[i]; n; n=n->next) {
diff -r -u --new-file linux-2.4.bk.original/net/ipv6/ndisc.c 
linux-2.4.bk-auto-size/net/ipv6/ndisc.c
--- linux-2.4.bk.original/net/ipv6/ndisc.c	2004-03-14 08:54:30.000000000 -0700
+++ linux-2.4.bk-auto-size/net/ipv6/ndisc.c	2004-03-13 22:13:59.000000000 
-0700
@@ -246,7 +246,7 @@
 	hash_val ^= (hash_val>>16);
 	hash_val ^= hash_val>>8;
 	hash_val ^= hash_val>>3;
-	hash_val = (hash_val^dev->ifindex)&NEIGH_HASHMASK;
+	hash_val = (hash_val^dev->ifindex)&(nd_tbl.num_hash_buckets-1);
 
 	return hash_val;
 }

-- 
Tim Gardner - timg@tpi.com
www.tpi.com 406-443-5357
