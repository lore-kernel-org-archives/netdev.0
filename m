From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.4] backport neighbour cache redesign
Date: Mon, 4 Oct 2004 12:17:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041004121759.26798f1d.davem@davemloft.net>
References: <20040930154753.GD1860@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20040930154753.GD1860@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Ok I started playing with this, here is what I have currently.
Changes:

1) Merge in missing fixes from 2.6.x port.  In particular:
	- missing "recalculate hash rand on hash grow"
	- missing ARP clip fixes (was initializing neigh
	  table by hand, needed to use net/core/neighbour.c
	  interfaces for that).  This one wasn't Harald's fault
	  as this fix was made after he created this 2.4.x backport
2) Missing symbol exports for the new interfaces modules can use,
   namely:
	neigh_lookup_nodev
	neigh_seq_start
	neigh_seq_next
	neigh_seq_stop
3) Delete instead of "#if 0" out the now totally unused code
   inside of net/atm/clip.c

We need to test and verify this patch a lot before I can toss
such a big thing over to Marcelo, but I definitely intend to
send this to him.

===== drivers/net/bonding/bond_main.c 1.86 vs edited =====
--- 1.86/drivers/net/bonding/bond_main.c	2004-01-21 08:55:17 -08:00
+++ edited/drivers/net/bonding/bond_main.c	2004-10-03 15:12:55 -07:00
@@ -3086,8 +3086,6 @@ out:
 
 #ifdef CONFIG_PROC_FS
 
-#define SEQ_START_TOKEN ((void *)1)
-
 static void *bond_info_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	struct bonding *bond = seq->private;
===== fs/proc/root.c 1.8 vs edited =====
--- 1.8/fs/proc/root.c	2003-11-15 08:23:40 -08:00
+++ edited/fs/proc/root.c	2004-10-03 15:12:55 -07:00
@@ -17,7 +17,7 @@
 #include <linux/module.h>
 #include <asm/bitops.h>
 
-struct proc_dir_entry *proc_net, *proc_bus, *proc_root_fs, *proc_root_driver;
+struct proc_dir_entry *proc_net, *proc_net_stat, *proc_bus, *proc_root_fs, *proc_root_driver;
 
 #ifdef CONFIG_SYSCTL
 struct proc_dir_entry *proc_sys_root;
@@ -38,6 +38,8 @@ void __init proc_root_init(void)
 	}
 	proc_misc_init();
 	proc_net = proc_mkdir("net", 0);
+	proc_net_stat = proc_mkdir("net/stat", NULL);
+
 #ifdef CONFIG_SYSVIPC
 	proc_mkdir("sysvipc", 0);
 #endif
@@ -143,5 +145,6 @@ EXPORT_SYMBOL(remove_proc_entry);
 EXPORT_SYMBOL(proc_root);
 EXPORT_SYMBOL(proc_root_fs);
 EXPORT_SYMBOL(proc_net);
+EXPORT_SYMBOL(proc_net_stat);
 EXPORT_SYMBOL(proc_bus);
 EXPORT_SYMBOL(proc_root_driver);
===== include/linux/proc_fs.h 1.9 vs edited =====
--- 1.9/include/linux/proc_fs.h	2003-09-15 01:39:45 -07:00
+++ edited/include/linux/proc_fs.h	2004-10-03 15:12:55 -07:00
@@ -79,6 +79,7 @@ struct proc_dir_entry {
 extern struct proc_dir_entry proc_root;
 extern struct proc_dir_entry *proc_root_fs;
 extern struct proc_dir_entry *proc_net;
+extern struct proc_dir_entry *proc_net_stat;
 extern struct proc_dir_entry *proc_bus;
 extern struct proc_dir_entry *proc_root_driver;
 extern struct proc_dir_entry *proc_root_kcore;
@@ -168,6 +169,16 @@ static inline struct proc_dir_entry *pro
 	mode_t mode, get_info_t *get_info)
 {
 	return create_proc_info_entry(name,mode,proc_net,get_info);
+}
+
+static inline struct proc_dir_entry *proc_net_fops_create(const char *name,
+	mode_t mode, struct file_operations *fops)
+{
+	struct proc_dir_entry *res = create_proc_entry(name, mode, proc_net);
+
+	if (res)
+		res->proc_fops = fops;
+	return res;
 }
 
 static inline void proc_net_remove(const char *name)
===== include/linux/seq_file.h 1.3 vs edited =====
--- 1.3/include/linux/seq_file.h	2003-08-25 09:34:39 -07:00
+++ edited/include/linux/seq_file.h	2004-10-03 15:12:55 -07:00
@@ -65,5 +65,8 @@ int seq_path(struct seq_file *, struct v
 int single_open(struct file *, int (*)(struct seq_file *, void *), void *);
 int single_release(struct inode *, struct file *);
 int seq_release_private(struct inode *, struct file *);
+
+#define SEQ_START_TOKEN ((void *)1)
+
 #endif
 #endif
===== include/net/dn_neigh.h 1.1 vs edited =====
--- 1.1/include/net/dn_neigh.h	2002-02-05 09:39:49 -08:00
+++ edited/include/net/dn_neigh.h	2004-10-03 15:12:55 -07:00
@@ -18,7 +18,6 @@ struct dn_neigh {
 
 extern void dn_neigh_init(void);
 extern void dn_neigh_cleanup(void);
-extern struct neighbour *dn_neigh_lookup(struct neigh_table *tbl, void *ptr);
 extern int dn_neigh_router_hello(struct sk_buff *skb);
 extern int dn_neigh_endnode_hello(struct sk_buff *skb);
 extern void dn_neigh_pointopoint_hello(struct sk_buff *skb);
===== include/net/neighbour.h 1.3 vs edited =====
--- 1.3/include/net/neighbour.h	2004-07-15 13:33:03 -07:00
+++ edited/include/net/neighbour.h	2004-10-03 15:12:55 -07:00
@@ -7,6 +7,11 @@
  *	Authors:
  *	Pedro Roque		<pedro_m@yahoo.com>
  *	Alexey Kuznetsov	<kuznet@ms2.inr.ac.ru>
+ *
+ * 	Changes:
+ *
+ *	Harald Welte:		<laforge@gnumonks.org>
+ *		- Add neighbour cache statistics like rtstat
  */
 
 /* The following flags & states are exported to user space,
@@ -45,6 +50,7 @@
 
 #include <asm/atomic.h>
 #include <linux/skbuff.h>
+#include <linux/seq_file.h>
 
 #define NUD_IN_TIMER	(NUD_INCOMPLETE|NUD_DELAY|NUD_PROBE)
 #define NUD_VALID	(NUD_PERMANENT|NUD_NOARP|NUD_REACHABLE|NUD_PROBE|NUD_STALE|NUD_DELAY)
@@ -78,12 +84,25 @@ struct neigh_parms
 
 struct neigh_statistics
 {
-	unsigned long allocs;
-	unsigned long res_failed;
-	unsigned long rcv_probes_mcast;
-	unsigned long rcv_probes_ucast;
+	unsigned long allocs;		/* number of allocated neighs */
+	unsigned long destroys;		/* number of destroyed neighs */
+	unsigned long hash_grows;	/* number of hash resizes */
+
+	unsigned long res_failed;	/* nomber of failed resolutions */
+
+	unsigned long lookups;		/* number of lookups */
+	unsigned long hits;		/* number of hits (among lookups) */
+
+	unsigned long rcv_probes_mcast;	/* number of received mcast ipv6 */
+	unsigned long rcv_probes_ucast; /* number of received ucast ipv6 */
+
+	unsigned long periodic_gc_runs;	/* number of periodic GC runs */
+	unsigned long forced_gc_runs;	/* number of forced GC runs */
 };
 
+#define NEIGH_CACHE_STAT_INC(tbl, field)				\
+		((tbl)->stats[smp_processor_id()].field++)
+
 struct neighbour
 {
 	struct neighbour	*next;
@@ -128,9 +147,6 @@ struct pneigh_entry
 	u8			key[0];
 };
 
-#define NEIGH_HASHMASK		0x1F
-#define PNEIGH_HASHMASK		0xF
-
 /*
  *	neighbour table manipulation
  */
@@ -164,9 +180,15 @@ struct neigh_table
 	struct neigh_parms	*parms_list;
 	kmem_cache_t		*kmem_cachep;
 	struct tasklet_struct	gc_task;
-	struct neigh_statistics	stats;
-	struct neighbour	*hash_buckets[NEIGH_HASHMASK+1];
-	struct pneigh_entry	*phash_buckets[PNEIGH_HASHMASK+1];
+	struct neigh_statistics	stats[NR_CPUS];
+	struct neighbour	**hash_buckets;
+	unsigned int		hash_mask;
+	__u32			hash_rnd;
+	unsigned int		hash_chain_gc;
+	struct pneigh_entry	**phash_buckets;
+#ifdef CONFIG_PROC_FS
+	struct proc_dir_entry	*pde;
+#endif
 };
 
 extern void			neigh_table_init(struct neigh_table *tbl);
@@ -174,6 +196,8 @@ extern int			neigh_table_clear(struct ne
 extern struct neighbour *	neigh_lookup(struct neigh_table *tbl,
 					     const void *pkey,
 					     struct net_device *dev);
+extern struct neighbour *	neigh_lookup_nodev(struct neigh_table *tbl,
+						   const void *pkey);
 extern struct neighbour *	neigh_create(struct neigh_table *tbl,
 					     const void *pkey,
 					     struct net_device *dev);
@@ -204,6 +228,24 @@ extern int neigh_dump_info(struct sk_buf
 extern int neigh_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg);
 extern int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg);
 extern void neigh_app_ns(struct neighbour *n);
+
+extern void neigh_for_each(struct neigh_table *tbl, void (*cb)(struct neighbour *, void *), void *cookie);
+extern void __neigh_for_each_release(struct neigh_table *tbl, int (*cb)(struct neighbour *));
+extern void pneigh_for_each(struct neigh_table *tbl, void (*cb)(struct pneigh_entry *));
+
+struct neigh_seq_state {
+	struct neigh_table *tbl;
+	void *(*neigh_sub_iter)(struct neigh_seq_state *state,
+				struct neighbour *n, loff_t *pos);
+	unsigned int bucket;
+	unsigned int flags;
+#define NEIGH_SEQ_NEIGH_ONLY	0x00000001
+#define NEIGH_SEQ_IS_PNEIGH	0x00000002
+#define NEIGH_SEQ_SKIP_NOARP	0x00000004
+};
+extern void *neigh_seq_start(struct seq_file *, loff_t *, struct neigh_table *, unsigned int);
+extern void *neigh_seq_next(struct seq_file *, void *, loff_t *);
+extern void neigh_seq_stop(struct seq_file *, void *);
 
 extern int			neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
 						      int p_id, int pdev_id, char *p_name);
===== net/netsyms.c 1.49 vs edited =====
--- 1.49/net/netsyms.c	2004-08-29 21:11:49 -07:00
+++ edited/net/netsyms.c	2004-10-03 19:14:10 -07:00
@@ -179,9 +179,13 @@ EXPORT_SYMBOL(neigh_connected_output);
 EXPORT_SYMBOL(neigh_update);
 EXPORT_SYMBOL(neigh_create);
 EXPORT_SYMBOL(neigh_lookup);
+EXPORT_SYMBOL(neigh_lookup_nodev);
 EXPORT_SYMBOL(__neigh_event_send);
 EXPORT_SYMBOL(neigh_event_ns);
 EXPORT_SYMBOL(neigh_ifdown);
+EXPORT_SYMBOL(neigh_seq_start);
+EXPORT_SYMBOL(neigh_seq_next);
+EXPORT_SYMBOL(neigh_seq_stop);
 #ifdef CONFIG_ARPD
 EXPORT_SYMBOL(neigh_app_ns);
 #endif
===== net/atm/clip.c 1.13 vs edited =====
--- 1.13/net/atm/clip.c	2004-02-04 23:20:52 -08:00
+++ edited/net/atm/clip.c	2004-10-03 15:19:49 -07:00
@@ -1,6 +1,10 @@
 /* net/atm/clip.c - RFC1577 Classical IP over ATM */
 
-/* Written 1995-2000 by Werner Almesberger, EPFL LRC/ICA */
+/* Written 1995-2000 by Werner Almesberger, EPFL LRC/ICA 
+ *
+ * Changes:
+ * 	Harald Welte <laforge@gnumonks.org>:
+ * 	- backport DaveM's generalized neighbour cache from 2.6.9-rcX */
 
 
 #include <linux/config.h>
@@ -24,6 +28,7 @@
 #include <linux/if.h> /* for IFF_UP */
 #include <linux/inetdevice.h>
 #include <linux/bitops.h>
+#include <linux/jhash.h>
 #include <net/route.h> /* for struct rtable and routing */
 #include <net/icmp.h> /* icmp_send */
 #include <asm/param.h> /* for HZ */
@@ -119,64 +124,49 @@ out:
 	spin_unlock_bh(&entry->neigh->dev->xmit_lock);
 }
 
-
-static void idle_timer_check(unsigned long dummy)
+/* The neighbour entry n->lock is held. */
+static int neigh_check_cb(struct neighbour *n)
 {
-	int i;
+	struct atmarp_entry *entry = NEIGH2ENTRY(n);
+	struct clip_vcc *cv;
 
-	/*DPRINTK("idle_timer_check\n");*/
-	write_lock(&clip_tbl.lock);
-	for (i = 0; i <= NEIGH_HASHMASK; i++) {
-		struct neighbour **np;
+	for (cv = entry->vccs; cv; cv = cv->next) {
+		unsigned long exp = cv->last_use + cv->idle_timeout;
 
-		for (np = &clip_tbl.hash_buckets[i]; *np;) {
-			struct neighbour *n = *np;
-			struct atmarp_entry *entry = NEIGH2ENTRY(n);
-			struct clip_vcc *clip_vcc;
-
-			write_lock(&n->lock);
-
-			for (clip_vcc = entry->vccs; clip_vcc;
-			    clip_vcc = clip_vcc->next)
-				if (clip_vcc->idle_timeout &&
-				    time_after(jiffies, clip_vcc->last_use+
-				    clip_vcc->idle_timeout)) {
-					DPRINTK("releasing vcc %p->%p of "
-					    "entry %p\n",clip_vcc,clip_vcc->vcc,
-					    entry);
-					vcc_release_async(clip_vcc->vcc,
-							  -ETIMEDOUT);
-				}
-			if (entry->vccs ||
-			    time_before(jiffies, entry->expires)) {
-				np = &n->next;
-				write_unlock(&n->lock);
-				continue;
-			}
-			if (atomic_read(&n->refcnt) > 1) {
-				struct sk_buff *skb;
-
-				DPRINTK("destruction postponed with ref %d\n",
-				    atomic_read(&n->refcnt));
-				while ((skb = skb_dequeue(&n->arp_queue)) !=
-				     NULL) 
-					dev_kfree_skb(skb);
-				np = &n->next;
-				write_unlock(&n->lock);
-				continue;
-			}
-			*np = n->next;
-			DPRINTK("expired neigh %p\n",n);
-			n->dead = 1;
-			write_unlock(&n->lock);
-			neigh_release(n);
+		if (cv->idle_timeout && time_after(jiffies, exp)) {
+			DPRINTK("releasing vcc %p->%p of entry %p\n",
+				cv, cv->vcc, entry);
+			vcc_release_async(cv->vcc, -ETIMEDOUT);
 		}
 	}
+
+	if (entry->vccs || time_before(jiffies, entry->expires))
+		return 0;
+
+	if (atomic_read(&n->refcnt) > 1) {
+		struct sk_buff *skb;
+
+		DPRINTK("destruction postponed with ref %d\n",
+			atomic_read(&n->refcnt));
+
+		while ((skb = skb_dequeue(&n->arp_queue)) != NULL) 
+			dev_kfree_skb(skb);
+
+		return 0;
+	}
+
+	DPRINTK("expired neigh %p\n",n);
+	return 1;
+}
+
+static void idle_timer_check(unsigned long dummy)
+{
+	write_lock(&clip_tbl.lock);
+	__neigh_for_each_release(&clip_tbl, neigh_check_cb);
 	mod_timer(&idle_timer, jiffies+CLIP_CHECK_INTERVAL*HZ);
 	write_unlock(&clip_tbl.lock);
 }
 
-
 static int clip_arp_rcv(struct sk_buff *skb)
 {
 	struct atm_vcc *vcc;
@@ -320,15 +310,7 @@ static int clip_constructor(struct neigh
 
 static u32 clip_hash(const void *pkey, const struct net_device *dev)
 {
-	u32 hash_val;
-
-	hash_val = *(u32*)pkey;
-	hash_val ^= (hash_val>>16);
-	hash_val ^= hash_val>>8;
-	hash_val ^= hash_val>>3;
-	hash_val = (hash_val^dev->ifindex)&NEIGH_HASHMASK;
-
-	return hash_val;
+	return jhash_2words(*(u32 *)pkey, dev->ifindex, clip_tbl.hash_rnd);
 }
 
 
@@ -768,19 +750,7 @@ static struct atm_clip_ops __atm_clip_op
 
 static int __init atm_clip_init(void)
 {
-	/* we should use neigh_table_init() */
-	clip_tbl.lock = RW_LOCK_UNLOCKED;
-	clip_tbl.kmem_cachep = kmem_cache_create(clip_tbl.id,
-	    clip_tbl.entry_size, 0, SLAB_HWCACHE_ALIGN, NULL, NULL);
-
-	if (!clip_tbl.kmem_cachep)
-		return -ENOMEM;
-
-	/* so neigh_ifdown() doesn't complain */
-	clip_tbl.proxy_timer.data = 0;
-	clip_tbl.proxy_timer.function = 0;
-	init_timer(&clip_tbl.proxy_timer);
-	skb_queue_head_init(&clip_tbl.proxy_queue);
+	neigh_table_init(&clip_tbl);
 
 	clip_tbl_hook = &clip_tbl;
 	atm_clip_ops_set(&__atm_clip_ops);
@@ -794,7 +764,18 @@ static void __exit atm_clip_exit(void)
 
 	atm_clip_ops_set(NULL);
 
+	/* First, stop the idle timer, so it stops banging
+	 * on the table.
+	 */
+	if (start_timer == 0)
+		del_timer(&idle_timer);
+
+	/* Next, purge the table, so that the device
+	 * unregister loop below does not hang due to
+	 * device references remaining in the table.
+	 */
 	neigh_ifdown(&clip_tbl, NULL);
+
 	dev = clip_devs;
 	while (dev) {
 		next = PRIV(dev)->next;
@@ -802,9 +783,9 @@ static void __exit atm_clip_exit(void)
 		kfree(dev);
 		dev = next;
 	}
-	if (start_timer == 0) del_timer(&idle_timer);
 
-	kmem_cache_destroy(clip_tbl.kmem_cachep);
+	/* Now it is safe to fully shutdown whole table. */
+	neigh_table_clear(&clip_tbl);
 
 	clip_tbl_hook = NULL;
 }
===== net/atm/proc.c 1.11 vs edited =====
--- 1.11/net/atm/proc.c	2003-10-14 14:01:53 -07:00
+++ edited/net/atm/proc.c	2004-10-03 15:30:31 -07:00
@@ -44,11 +44,6 @@
 #include "ipcommon.h"
 #endif
 
-#if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
-#include "lec.h"
-#include "lec_arpc.h"
-#endif
-
 static ssize_t proc_dev_atm_read(struct file *file,char *buf,size_t count,
     loff_t *pos);
 static ssize_t proc_spec_atm_read(struct file *file,char *buf,size_t count,
@@ -90,74 +85,202 @@ static void dev_info(const struct atm_de
 
 #if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
 
+#define SEQ_NO_VCC_TOKEN   ((void *) 2)
 
-static int svc_addr(char *buf,struct sockaddr_atmsvc *addr)
+static void svc_addr(struct seq_file *seq, struct sockaddr_atmsvc *addr)
 {
 	static int code[] = { 1,2,10,6,1,0 };
 	static int e164[] = { 1,8,4,6,1,0 };
-	int *fields;
-	int len,i,j,pos;
 
-	len = 0;
 	if (*addr->sas_addr.pub) {
-		strcpy(buf,addr->sas_addr.pub);
-		len = strlen(addr->sas_addr.pub);
-		buf += len;
-		if (*addr->sas_addr.prv) {
-			*buf++ = '+';
-			len++;
-		}
+		seq_printf(seq, "%s", addr->sas_addr.pub);
+		if (*addr->sas_addr.prv)
+			seq_putc(seq, '+');
+	} else if (!*addr->sas_addr.prv) {
+		seq_printf(seq, "%s", "(none)");
+		return;
 	}
-	else if (!*addr->sas_addr.prv) {
-			strcpy(buf,"(none)");
-			return strlen(buf);
-		}
 	if (*addr->sas_addr.prv) {
-		len += 44;
-		pos = 0;
-		fields = *addr->sas_addr.prv == ATM_AFI_E164 ? e164 : code;
+		unsigned char *prv = addr->sas_addr.prv;
+		int *fields;
+		int i, j;
+
+		fields = *prv == ATM_AFI_E164 ? e164 : code;
 		for (i = 0; fields[i]; i++) {
-			for (j = fields[i]; j; j--) {
-				sprintf(buf,"%02X",addr->sas_addr.prv[pos++]);
-				buf += 2;
-			}
-			if (fields[i+1]) *buf++ = '.';
+			for (j = fields[i]; j; j--)
+				seq_printf(seq, "%02X", *prv++);
+			if (fields[i+1]) 
+				seq_putc(seq, '.');
 		}
 	}
-	return len;
 }
 
 
-static void atmarp_info(struct net_device *dev,struct atmarp_entry *entry,
-    struct clip_vcc *clip_vcc,char *buf)
-{
-	unsigned char *ip;
-	int svc,off,ip_len;
-
-	svc = !clip_vcc || clip_vcc->vcc->sk->family == AF_ATMSVC;
-	off = sprintf(buf,"%-6s%-4s%-4s%5ld ",dev->name,svc ? "SVC" : "PVC",
-	    !clip_vcc || clip_vcc->encap ? "LLC" : "NULL",
-	    (jiffies-(clip_vcc ? clip_vcc->last_use : entry->neigh->used))/
-	    HZ);
-	ip = (unsigned char *) &entry->ip;
-	ip_len = sprintf(buf+off,"%d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
-	off += ip_len;
-	while (ip_len++ < 16) buf[off++] = ' ';
-	if (!clip_vcc)
+static void atmarp_info(struct seq_file *seq, struct net_device *dev,struct
+			atmarp_entry *entry, struct clip_vcc *clip_vcc) {
+	unsigned long exp;
+	char buf[17];
+	int svc, llc, off;
+
+	svc = ((clip_vcc == SEQ_NO_VCC_TOKEN) ||
+	       (clip_vcc->vcc->sk->family == AF_ATMSVC));
+
+	llc = ((clip_vcc == SEQ_NO_VCC_TOKEN) ||
+	       (clip_vcc->encap));
+
+	if (clip_vcc == SEQ_NO_VCC_TOKEN)
+		exp = entry->neigh->used;
+	else
+		exp = clip_vcc->last_use;
+
+	exp = (jiffies - exp) / HZ;
+
+	seq_printf(seq, "%-6s%-4s%-4s%5ld ",
+		   dev->name,
+		   svc ? "SVC" : "PVC",
+		   llc ? "LLC" : "NULL",
+		   exp);
+
+	off = snprintf(buf, sizeof(buf)-1, "%d.%d.%d.%d", NIPQUAD(entry->ip));
+	while (off < 16)
+		buf[off++] = ' ';
+	buf[off] = '\0';
+	seq_printf(seq, "%s", buf);
+
+	if (clip_vcc == SEQ_NO_VCC_TOKEN) {
 		if (time_before(jiffies, entry->expires))
-			strcpy(buf+off,"(resolving)\n");
-		else sprintf(buf+off,"(expired, ref %d)\n",
-			    atomic_read(&entry->neigh->refcnt));
-	else if (!svc)
-			sprintf(buf+off,"%d.%d.%d\n",clip_vcc->vcc->dev->number,
-			    clip_vcc->vcc->vpi,clip_vcc->vcc->vci);
-		else {
-			off += svc_addr(buf+off,&clip_vcc->vcc->remote);
-			strcpy(buf+off,"\n");
+			seq_printf(seq, "(resolving)\n");
+		else
+			seq_printf(seq, "(expired, ref %d)\n",
+				   atomic_read(&entry->neigh->refcnt));
+	} else if (!svc) {
+		seq_printf(seq, "%d.%d.%d\n",
+			   clip_vcc->vcc->dev->number,
+			   clip_vcc->vcc->vpi,
+			   clip_vcc->vcc->vci);
+	} else {
+		svc_addr(seq, &clip_vcc->vcc->remote);
+		seq_putc(seq, '\n');
+	}
+}
+
+struct clip_seq_state {
+	/* This member must be first. */
+	struct neigh_seq_state ns;
+
+	/* Local to clip specific iteration. */
+	struct clip_vcc *vcc;
+};
+
+static struct clip_vcc *clip_seq_next_vcc(struct atmarp_entry *e,
+					  struct clip_vcc *curr)
+{
+	if (!curr) {
+		curr = e->vccs;
+		if (!curr)
+			return SEQ_NO_VCC_TOKEN;
+		return curr;
+	}
+
+	if (curr == SEQ_NO_VCC_TOKEN)
+		return NULL;
+
+	curr = curr->next;
+
+	return curr;
+}
+
+static void *clip_seq_vcc_walk(struct clip_seq_state *state,
+			       struct atmarp_entry *e, loff_t *pos)
+{
+	struct clip_vcc *vcc = state->vcc;
+
+	vcc = clip_seq_next_vcc(e, vcc);
+	if (vcc && pos != NULL) {
+		while (*pos) {
+			vcc = clip_seq_next_vcc(e, vcc);
+			if (!vcc)
+				break;
+			--(*pos);
 		}
+	}
+	state->vcc = vcc;
+
+	return vcc;
+}
+
+static void *clip_seq_sub_iter(struct neigh_seq_state *_state,
+			       struct neighbour *n, loff_t *pos)
+{
+	struct clip_seq_state *state = (struct clip_seq_state *) _state;
+
+	return clip_seq_vcc_walk(state, NEIGH2ENTRY(n), pos);
+}
+
+static void *clip_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	return neigh_seq_start(seq, pos, clip_tbl_hook, NEIGH_SEQ_NEIGH_ONLY);
+}
+
+static int clip_seq_show(struct seq_file *seq, void *v)
+{
+	static char atm_arp_banner[] = 
+		"IPitf TypeEncp Idle IP address      ATM address\n";
+
+	if (v == SEQ_START_TOKEN) {
+		seq_puts(seq, atm_arp_banner);
+	} else {
+		struct clip_seq_state *state = seq->private;
+		struct neighbour *n = v;
+		struct clip_vcc *vcc = state->vcc;
+
+		atmarp_info(seq, n->dev, NEIGH2ENTRY(n), vcc);
+	}
+	return 0;
 }
 
+static struct seq_operations arp_seq_ops = {
+	.start	= clip_seq_start,
+	.next	= neigh_seq_next,
+	.stop	= neigh_seq_stop,
+	.show	= clip_seq_show,
+};
 
+static int arp_seq_open(struct inode *inode, struct file *file)
+{
+	struct clip_seq_state *state;
+	struct seq_file *seq;
+	int rc = -EAGAIN;
+
+	state = kmalloc(sizeof(*state), GFP_KERNEL);
+	if (!state) {
+		rc = -ENOMEM;
+		goto out_kfree;
+	}
+	memset(state, 0, sizeof(*state));
+	state->ns.neigh_sub_iter = clip_seq_sub_iter;
+
+	rc = seq_open(file, &arp_seq_ops);
+	if (rc)
+		goto out_kfree;
+
+	seq = file->private_data;
+	seq->private = state;
+out:
+	return rc;
+
+out_kfree:
+	kfree(state);
+	goto out;
+}
+
+static struct file_operations arp_seq_fops = {
+	.open		= arp_seq_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release_private,
+	.owner		= THIS_MODULE,
+};
 #endif
 
 
@@ -250,57 +373,6 @@ static void svc_info(struct atm_vcc *vcc
 }
 
 
-#if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
-
-static char*
-lec_arp_get_status_string(unsigned char status)
-{
-  switch(status) {
-  case ESI_UNKNOWN:
-    return "ESI_UNKNOWN       ";
-  case ESI_ARP_PENDING:
-    return "ESI_ARP_PENDING   ";
-  case ESI_VC_PENDING:
-    return "ESI_VC_PENDING    ";
-  case ESI_FLUSH_PENDING:
-    return "ESI_FLUSH_PENDING ";
-  case ESI_FORWARD_DIRECT:
-    return "ESI_FORWARD_DIRECT";
-  default:
-    return "<Unknown>         ";
-  }
-}
-
-static void 
-lec_info(struct lec_arp_table *entry, char *buf)
-{
-        int j, offset=0;
-
-        for(j=0;j<ETH_ALEN;j++) {
-                offset+=sprintf(buf+offset,"%2.2x",0xff&entry->mac_addr[j]);
-        }
-        offset+=sprintf(buf+offset, " ");
-        for(j=0;j<ATM_ESA_LEN;j++) {
-                offset+=sprintf(buf+offset,"%2.2x",0xff&entry->atm_addr[j]);
-        }
-        offset+=sprintf(buf+offset, " %s %4.4x",
-                        lec_arp_get_status_string(entry->status),
-                        entry->flags&0xffff);
-        if (entry->vcc) {
-                offset+=sprintf(buf+offset, "%3d %3d ", entry->vcc->vpi, 
-                                entry->vcc->vci);                
-        } else
-                offset+=sprintf(buf+offset, "        ");
-        if (entry->recv_vcc) {
-                offset+=sprintf(buf+offset, "     %3d %3d", 
-                                entry->recv_vcc->vpi, entry->recv_vcc->vci);
-        }
-
-        sprintf(buf+offset,"\n");
-}
-
-#endif
-
 static int atm_devices_info(loff_t pos,char *buf)
 {
 	struct atm_dev *dev;
@@ -416,129 +488,6 @@ static int atm_svc_info(loff_t pos,char 
 	return 0;
 }
 
-#if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
-static int atm_arp_info(loff_t pos,char *buf)
-{
-	struct neighbour *n;
-	int i,count;
-
-	if (!pos) {
-		return sprintf(buf,"IPitf TypeEncp Idle IP address      "
-		    "ATM address\n");
-	}
-	if (!try_atm_clip_ops())
-		return 0;
-	count = pos;
-	read_lock_bh(&clip_tbl_hook->lock);
-	for (i = 0; i <= NEIGH_HASHMASK; i++)
-		for (n = clip_tbl_hook->hash_buckets[i]; n; n = n->next) {
-			struct atmarp_entry *entry = NEIGH2ENTRY(n);
-			struct clip_vcc *vcc;
-
-			if (!entry->vccs) {
-				if (--count) continue;
-				atmarp_info(n->dev,entry,NULL,buf);
-				read_unlock_bh(&clip_tbl_hook->lock);
-				if (atm_clip_ops->owner)
-					__MOD_DEC_USE_COUNT(atm_clip_ops->owner);
-				return strlen(buf);
-			}
-			for (vcc = entry->vccs; vcc;
-			    vcc = vcc->next) {
-				if (--count) continue;
-				atmarp_info(n->dev,entry,vcc,buf);
-				read_unlock_bh(&clip_tbl_hook->lock);
-				if (atm_clip_ops->owner)
-					__MOD_DEC_USE_COUNT(atm_clip_ops->owner);
-				return strlen(buf);
-			}
-		}
-	read_unlock_bh(&clip_tbl_hook->lock);
-	if (atm_clip_ops->owner)
-		__MOD_DEC_USE_COUNT(atm_clip_ops->owner);
-	return 0;
-}
-#endif
-
-#if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
-static int atm_lec_info(loff_t pos,char *buf)
-{
-	unsigned long flags;
-	struct lec_priv *priv;
-	struct lec_arp_table *entry;
-	int i, count, d, e;
-	struct net_device *dev;
-
-	if (!pos) {
-		return sprintf(buf,"Itf  MAC          ATM destination"
-		    "                          Status            Flags "
-		    "VPI/VCI Recv VPI/VCI\n");
-	}
-	if (!try_atm_lane_ops())
-		return 0; /* the lane module is not there yet */
-
-	count = pos;
-	for(d = 0; d < MAX_LEC_ITF; d++) {
-		dev = atm_lane_ops->get_lec(d);
-		if (!dev || !(priv = (struct lec_priv *) dev->priv))
-			continue;
-		spin_lock_irqsave(&priv->lec_arp_lock, flags);
-		for(i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
-			for(entry = priv->lec_arp_tables[i]; entry; entry = entry->next) {
-				if (--count)
-					continue;
-				e = sprintf(buf,"%s ", dev->name);
-				lec_info(entry, buf+e);
-				spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
-				dev_put(dev);
-				if (atm_lane_ops->owner)
-					__MOD_DEC_USE_COUNT(atm_lane_ops->owner);
-				return strlen(buf);
-			}
-		}
-		for(entry = priv->lec_arp_empty_ones; entry; entry = entry->next) {
-			if (--count)
-				continue;
-			e = sprintf(buf,"%s ", dev->name);
-			lec_info(entry, buf+e);
-			spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
-			dev_put(dev);
-			if (atm_lane_ops->owner)
-				__MOD_DEC_USE_COUNT(atm_lane_ops->owner);
-			return strlen(buf);
-		}
-		for(entry = priv->lec_no_forward; entry; entry=entry->next) {
-			if (--count)
-				continue;
-			e = sprintf(buf,"%s ", dev->name);
-			lec_info(entry, buf+e);
-			spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
-			dev_put(dev);
-			if (atm_lane_ops->owner)
-				__MOD_DEC_USE_COUNT(atm_lane_ops->owner);
-			return strlen(buf);
-		}
-		for(entry = priv->mcast_fwds; entry; entry = entry->next) {
-			if (--count)
-				continue;
-			e = sprintf(buf,"%s ", dev->name);
-			lec_info(entry, buf+e);
-			spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
-			dev_put(dev);
-			if (atm_lane_ops->owner)
-				__MOD_DEC_USE_COUNT(atm_lane_ops->owner);
-			return strlen(buf);
-		}
-		spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
-		dev_put(dev);
-	}
-	if (atm_lane_ops->owner)
-		__MOD_DEC_USE_COUNT(atm_lane_ops->owner);
-	return 0;
-}
-#endif
-
-
 static ssize_t proc_dev_atm_read(struct file *file,char *buf,size_t count,
     loff_t *pos)
 {
@@ -666,7 +615,10 @@ int atm_proc_init(void)
 	CREATE_ENTRY(svc);
 	CREATE_ENTRY(vc);
 #if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
-	CREATE_ENTRY(arp);
+	arp  = create_proc_entry("arp", S_IRUGO, atm_proc_root);
+	if (!arp)
+		goto cleanup;
+	arp->proc_fops = &arp_seq_fops;
 #endif
 #if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
 	CREATE_ENTRY(lec);
===== net/core/neighbour.c 1.12 vs edited =====
--- 1.12/net/core/neighbour.c	2004-07-15 13:33:03 -07:00
+++ edited/net/core/neighbour.c	2004-10-03 15:43:21 -07:00
@@ -12,6 +12,8 @@
  *
  *	Fixes:
  *	Vitaly E. Lavrov	releasing NULL neighbor in neigh_add.
+ *	Harald Welte		Add neighbour cache statistics like rtstat
+ *	Harald Welte		port neighbour cache rework from 2.6.9-rcX
  */
 
 #include <linux/config.h>
@@ -20,6 +22,7 @@
 #include <linux/socket.h>
 #include <linux/sched.h>
 #include <linux/netdevice.h>
+#include <linux/proc_fs.h>
 #ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
 #endif
@@ -27,6 +30,7 @@
 #include <net/dst.h>
 #include <net/sock.h>
 #include <linux/rtnetlink.h>
+#include <linux/random.h>
 
 #define NEIGH_DEBUG 1
 
@@ -45,6 +49,8 @@
 #define NEIGH_PRINTK2 NEIGH_PRINTK
 #endif
 
+#define PNEIGH_HASHMASK		0xF
+
 static void neigh_timer_handler(unsigned long arg);
 #ifdef CONFIG_ARPD
 static void neigh_app_notify(struct neighbour *n);
@@ -54,6 +60,7 @@ void neigh_changeaddr(struct neigh_table
 
 static int neigh_glbl_allocs;
 static struct neigh_table *neigh_tables;
+static struct file_operations neigh_stat_seq_fops;
 
 /*
    Neighbour hash table buckets are protected with rwlock tbl->lock.
@@ -111,27 +118,21 @@ static int neigh_forced_gc(struct neigh_
 	int shrunk = 0;
 	int i;
 
-	for (i=0; i<=NEIGH_HASHMASK; i++) {
+	NEIGH_CACHE_STAT_INC(tbl, forced_gc_runs);
+
+	write_lock_bh(&tbl->lock);
+	for (i = 0; i <= tbl->hash_mask; i++) {
 		struct neighbour *n, **np;
 
 		np = &tbl->hash_buckets[i];
-		write_lock_bh(&tbl->lock);
 		while ((n = *np) != NULL) {
 			/* Neighbour record may be discarded if:
-			   - nobody refers to it.
-			   - it is not permanent
-			   - (NEW and probably wrong)
-			     INCOMPLETE entries are kept at least for
-			     n->parms->retrans_time, otherwise we could
-			     flood network with resolution requests.
-			     It is not clear, what is better table overflow
-			     or flooding.
+			 * - nobody refers to it.
+			 * - it is not permanent
 			 */
 			write_lock(&n->lock);
 			if (atomic_read(&n->refcnt) == 1 &&
-			    !(n->nud_state&NUD_PERMANENT) &&
-			    (n->nud_state != NUD_INCOMPLETE ||
-			     jiffies - n->used > n->parms->retrans_time)) {
+			    !(n->nud_state&NUD_PERMANENT)) {
 				*np = n->next;
 				n->dead = 1;
 				shrunk = 1;
@@ -142,10 +143,12 @@ static int neigh_forced_gc(struct neigh_
 			write_unlock(&n->lock);
 			np = &n->next;
 		}
-		write_unlock_bh(&tbl->lock);
 	}
 	
 	tbl->last_flush = jiffies;
+
+	write_unlock_bh(&tbl->lock);
+
 	return shrunk;
 }
 
@@ -176,7 +179,7 @@ void neigh_changeaddr(struct neigh_table
 
 	write_lock_bh(&tbl->lock);
 
-	for (i=0; i <= NEIGH_HASHMASK; i++) {
+	for (i=0; i <= tbl->hash_mask; i++) {
 		struct neighbour *n, **np;
 
 		np = &tbl->hash_buckets[i];
@@ -203,7 +206,7 @@ int neigh_ifdown(struct neigh_table *tbl
 
 	write_lock_bh(&tbl->lock);
 
-	for (i=0; i<=NEIGH_HASHMASK; i++) {
+	for (i = 0; i <= tbl->hash_mask; i++) {
 		struct neighbour *n, **np;
 
 		np = &tbl->hash_buckets[i];
@@ -277,7 +280,7 @@ static struct neighbour *neigh_alloc(str
 	init_timer(&n->timer);
 	n->timer.function = neigh_timer_handler;
 	n->timer.data = (unsigned long)n;
-	tbl->stats.allocs++;
+	NEIGH_CACHE_STAT_INC(tbl, allocs);
 	neigh_glbl_allocs++;
 	tbl->entries++;
 	n->tbl = tbl;
@@ -286,20 +289,104 @@ static struct neighbour *neigh_alloc(str
 	return n;
 }
 
+static struct neighbour **neigh_hash_alloc(unsigned int entries)
+{
+	unsigned long size = entries * sizeof(struct neighbour *);
+	struct neighbour **ret;
+
+	if (size <= PAGE_SIZE) {
+		ret = kmalloc(size, GFP_ATOMIC);
+	} else {
+		ret = (struct neighbour **)
+			__get_free_pages(GFP_ATOMIC, get_order(size));
+	}
+	if (ret)
+		memset(ret, 0, size);
+
+	return ret;
+}
+
+static void neigh_hash_free(struct neighbour **hash, unsigned int entries)
+{
+	unsigned long size = entries * sizeof(struct neighbour *);
+
+	if (size <= PAGE_SIZE)
+		kfree(hash);
+	else
+		free_pages((unsigned long)hash, get_order(size));
+}
+
+static void neigh_hash_grow(struct neigh_table *tbl, unsigned long new_entries)
+{
+	struct neighbour **new_hash, **old_hash;
+	unsigned int i, new_hash_mask, old_entries;
+
+	NEIGH_CACHE_STAT_INC(tbl, hash_grows);
+
+	BUG_ON(new_entries & (new_entries - 1));
+	new_hash = neigh_hash_alloc(new_entries);
+	if (!new_hash)
+		return;
+
+	old_entries = tbl->hash_mask + 1;
+	new_hash_mask = new_entries - 1;
+	old_hash = tbl->hash_buckets;
+
+	get_random_bytes(&tbl->hash_rnd, sizeof(tbl->hash_rnd));
+	for (i = 0; i < old_entries; i++) {
+		struct neighbour *n, *next;
+
+		for (n = old_hash[i]; n; n = next) {
+			unsigned int hash_val = tbl->hash(n->primary_key, n->dev);
+
+			hash_val &= new_hash_mask;
+			next = n->next;
+
+			n->next = new_hash[hash_val];
+			new_hash[hash_val] = n;
+		}
+	}
+	tbl->hash_buckets = new_hash;
+	tbl->hash_mask = new_hash_mask;
+
+	neigh_hash_free(old_hash, old_entries);
+}
+
 struct neighbour *neigh_lookup(struct neigh_table *tbl, const void *pkey,
 			       struct net_device *dev)
 {
 	struct neighbour *n;
-	u32 hash_val;
 	int key_len = tbl->key_len;
+	u32 hash_val = tbl->hash(pkey, dev) & tbl->hash_mask;
 
-	hash_val = tbl->hash(pkey, dev);
+	NEIGH_CACHE_STAT_INC(tbl, lookups);
 
 	read_lock_bh(&tbl->lock);
 	for (n = tbl->hash_buckets[hash_val]; n; n = n->next) {
 		if (dev == n->dev &&
 		    memcmp(n->primary_key, pkey, key_len) == 0) {
 			neigh_hold(n);
+			NEIGH_CACHE_STAT_INC(tbl, hits);
+			break;
+		}
+	}
+	read_unlock_bh(&tbl->lock);
+	return n;
+}
+
+struct neighbour *neigh_lookup_nodev(struct neigh_table *tbl, const void *pkey)
+{
+	struct neighbour *n;
+	int key_len = tbl->key_len;
+	u32 hash_val = tbl->hash(pkey, NULL) & tbl->hash_mask;
+
+	NEIGH_CACHE_STAT_INC(tbl, lookups);
+
+	read_lock_bh(&tbl->lock);
+	for (n = tbl->hash_buckets[hash_val]; n; n = n->next) {
+		if (!memcmp(n->primary_key, pkey, key_len)) {
+			neigh_hold(n);
+			NEIGH_CACHE_STAT_INC(tbl, hits);
 			break;
 		}
 	}
@@ -338,9 +425,11 @@ struct neighbour * neigh_create(struct n
 
 	n->confirmed = jiffies - (n->parms->base_reachable_time<<1);
 
-	hash_val = tbl->hash(pkey, dev);
+	hash_val = tbl->hash(pkey, dev) & tbl->hash_mask;
 
 	write_lock_bh(&tbl->lock);
+	if (tbl->entries > (tbl->hash_mask + 1))
+		neigh_hash_grow(tbl, (tbl->hash_mask + 1) << 1);
 	for (n1 = tbl->hash_buckets[hash_val]; n1; n1 = n1->next) {
 		if (dev == n1->dev &&
 		    memcmp(n1->primary_key, pkey, key_len) == 0) {
@@ -418,9 +507,9 @@ int pneigh_delete(struct neigh_table *tb
 	hash_val ^= hash_val>>4;
 	hash_val &= PNEIGH_HASHMASK;
 
+	write_lock_bh(&tbl->lock);
 	for (np = &tbl->phash_buckets[hash_val]; (n=*np) != NULL; np = &n->next) {
 		if (memcmp(n->key, pkey, key_len) == 0 && n->dev == dev) {
-			write_lock_bh(&tbl->lock);
 			*np = n->next;
 			write_unlock_bh(&tbl->lock);
 			if (tbl->pdestructor)
@@ -429,6 +518,7 @@ int pneigh_delete(struct neigh_table *tb
 			return 0;
 		}
 	}
+	write_unlock_bh(&tbl->lock);
 	return -ENOENT;
 }
 
@@ -462,6 +552,8 @@ void neigh_destroy(struct neighbour *nei
 {	
 	struct hh_cache *hh;
 
+	NEIGH_CACHE_STAT_INC(neigh->tbl, destroys);
+
 	if (!neigh->dead) {
 		printk("Destroying alive neighbour %p\n", neigh);
 		dump_stack();
@@ -566,9 +658,10 @@ static void neigh_sync(struct neighbour 
 static void SMP_TIMER_NAME(neigh_periodic_timer)(unsigned long arg)
 {
 	struct neigh_table *tbl = (struct neigh_table*)arg;
-	unsigned long now = jiffies;
-	int i;
+	struct neighbour *n, **np;
+	unsigned long expire, now = jiffies;
 
+	NEIGH_CACHE_STAT_INC(tbl, periodic_gc_runs);
 
 	write_lock(&tbl->lock);
 
@@ -583,46 +676,49 @@ static void SMP_TIMER_NAME(neigh_periodi
 			p->reachable_time = neigh_rand_reach_time(p->base_reachable_time);
 	}
 
-	for (i=0; i <= NEIGH_HASHMASK; i++) {
-		struct neighbour *n, **np;
-
-		np = &tbl->hash_buckets[i];
-		while ((n = *np) != NULL) {
-			unsigned state;
-
-			write_lock(&n->lock);
+	np = &tbl->hash_buckets[tbl->hash_chain_gc];
+	tbl->hash_chain_gc = ((tbl->hash_chain_gc + 1) & tbl->hash_mask);
 
-			state = n->nud_state;
-			if (state&(NUD_PERMANENT|NUD_IN_TIMER)) {
-				write_unlock(&n->lock);
-				goto next_elt;
-			}
+	while ((n = *np) != NULL) {
+		unsigned int state;
 
-			if ((long)(n->used - n->confirmed) < 0)
-				n->used = n->confirmed;
+		write_lock(&n->lock);
+  
+		state = n->nud_state;
+		if (state & (NUD_PERMANENT | NUD_IN_TIMER)) {
+			write_unlock(&n->lock);
+			goto next_elt;
+		}
 
-			if (atomic_read(&n->refcnt) == 1 &&
-			    (state == NUD_FAILED || now - n->used > n->parms->gc_staletime)) {
-				*np = n->next;
-				n->dead = 1;
-				write_unlock(&n->lock);
-				neigh_release(n);
-				continue;
-			}
+		if (time_before(n->used, n->confirmed))
+			n->used = n->confirmed;
 
-			if (n->nud_state&NUD_REACHABLE &&
-			    now - n->confirmed > n->parms->reachable_time) {
-				n->nud_state = NUD_STALE;
-				neigh_suspect(n);
-			}
+		if (atomic_read(&n->refcnt) == 1 &&
+		    (state == NUD_FAILED ||
+		     time_after(now, n->used + n->parms->gc_staletime))) {
+			*np = n->next;
+			n->dead = 1;
 			write_unlock(&n->lock);
+			neigh_release(n);
+			continue;
+		}
+		write_unlock(&n->lock);
 
 next_elt:
-			np = &n->next;
-		}
+		np = &n->next;
 	}
+  
+ 	/* Cycle through all hash buckets every base_reachable_time/2 ticks.
+ 	 * ARP entry timeouts range from 1/2 base_reachable_time to 3/2
+ 	 * base_reachable_time.
+	 */
+	expire = tbl->parms.base_reachable_time >> 1;
+	expire /= (tbl->hash_mask + 1);
+	if (!expire)
+		expire = 1;
+
+ 	mod_timer(&tbl->gc_timer, now + expire);
 
-	mod_timer(&tbl->gc_timer, now + tbl->gc_interval);
 	write_unlock(&tbl->lock);
 }
 
@@ -680,7 +776,7 @@ static void neigh_timer_handler(unsigned
 
 		neigh->nud_state = NUD_FAILED;
 		notify = 1;
-		neigh->tbl->stats.res_failed++;
+		NEIGH_CACHE_STAT_INC(neigh->tbl, res_failed);
 		NEIGH_PRINTK2("neigh %p is failed.\n", neigh);
 
 		/* It is very thin place. report_unreachable is very complicated
@@ -1132,6 +1228,7 @@ void neigh_parms_release(struct neigh_ta
 void neigh_table_init(struct neigh_table *tbl)
 {
 	unsigned long now = jiffies;
+	unsigned long phsize;
 
 	tbl->parms.reachable_time = neigh_rand_reach_time(tbl->parms.base_reachable_time);
 
@@ -1141,6 +1238,30 @@ void neigh_table_init(struct neigh_table
 						     0, SLAB_HWCACHE_ALIGN,
 						     NULL, NULL);
 
+	if (!tbl->kmem_cachep)
+		panic("cannot create neighbour cache");
+
+#ifdef CONFIG_PROC_FS
+	tbl->pde = create_proc_entry(tbl->id, 0, proc_net_stat);
+	if (!tbl->pde) 
+		panic("cannot create neighbour proc dir entry");
+	tbl->pde->proc_fops = &neigh_stat_seq_fops;
+	tbl->pde->data = tbl;
+#endif
+
+	tbl->hash_mask = 1;
+	tbl->hash_buckets = neigh_hash_alloc(tbl->hash_mask + 1);
+
+	phsize = (PNEIGH_HASHMASK + 1) * sizeof(struct pneigh_entry *);
+	tbl->phash_buckets = kmalloc(phsize, GFP_KERNEL);
+
+	if (!tbl->hash_buckets || !tbl->phash_buckets)
+		panic("cannot allocate neighbour cache hashes");
+
+	memset(tbl->phash_buckets, 0, phsize);
+
+	get_random_bytes(&tbl->hash_rnd, sizeof(tbl->hash_rnd));
+
 #ifdef CONFIG_SMP
 	tasklet_init(&tbl->gc_task, SMP_TIMER_NAME(neigh_periodic_timer), (unsigned long)tbl);
 #endif
@@ -1148,7 +1269,7 @@ void neigh_table_init(struct neigh_table
 	tbl->lock = RW_LOCK_UNLOCKED;
 	tbl->gc_timer.data = (unsigned long)tbl;
 	tbl->gc_timer.function = neigh_periodic_timer;
-	tbl->gc_timer.expires = now + tbl->gc_interval + tbl->parms.reachable_time;
+	tbl->gc_timer.expires = now + 1;
 	add_timer(&tbl->gc_timer);
 
 	init_timer(&tbl->proxy_timer);
@@ -1184,6 +1305,13 @@ int neigh_table_clear(struct neigh_table
 		}
 	}
 	write_unlock(&neigh_tbl_lock);
+
+	neigh_hash_free(tbl->hash_buckets, tbl->hash_mask + 1);
+	tbl->hash_buckets = NULL;
+
+	kfree(tbl->phash_buckets);
+	tbl->phash_buckets = NULL;
+
 #ifdef CONFIG_SYSCTL
 	neigh_sysctl_unregister(&tbl->parms);
 #endif
@@ -1364,7 +1492,7 @@ static int neigh_dump_table(struct neigh
 
 	s_h = cb->args[1];
 	s_idx = idx = cb->args[2];
-	for (h=0; h <= NEIGH_HASHMASK; h++) {
+	for (h=0; h <= tbl->hash_mask; h++) {
 		if (h < s_h) continue;
 		if (h > s_h)
 			s_idx = 0;
@@ -1414,6 +1542,359 @@ int neigh_dump_info(struct sk_buff *skb,
 
 	return skb->len;
 }
+
+void neigh_for_each(struct neigh_table *tbl, void (*cb)(struct neighbour *, void *), void *cookie)
+{
+	int chain;
+
+	read_lock_bh(&tbl->lock);
+	for (chain = 0; chain <= tbl->hash_mask; chain++) {
+		struct neighbour *n;
+
+		for (n = tbl->hash_buckets[chain]; n; n = n->next)
+			cb(n, cookie);
+	}
+	read_unlock_bh(&tbl->lock);
+}
+
+/* The tbl->lock must be held as a writer and BH disabled. */
+void __neigh_for_each_release(struct neigh_table *tbl,
+			      int (*cb)(struct neighbour *))
+{
+	int chain;
+
+	for (chain = 0; chain <= tbl->hash_mask; chain++) {
+		struct neighbour *n, **np;
+
+		np = &tbl->hash_buckets[chain];
+		while ((n = *np) != NULL) {
+			int release;
+
+			write_lock(&n->lock);
+			release = cb(n);
+			if (release) {
+				*np = n->next;
+				n->dead = 1;
+			} else
+				np = &n->next;
+			write_unlock(&n->lock);
+			if (release)
+				neigh_release(n);
+		}
+	}
+}
+
+#ifdef CONFIG_PROC_FS
+
+static struct neighbour *neigh_get_first(struct seq_file *seq)
+{
+	struct neigh_seq_state *state = seq->private;
+	struct neigh_table *tbl = state->tbl;
+	struct neighbour *n = NULL;
+	int bucket = state->bucket;
+
+	state->flags &= ~NEIGH_SEQ_IS_PNEIGH;
+	for (bucket = 0; bucket <= tbl->hash_mask; bucket++) {
+		n = tbl->hash_buckets[bucket];
+
+		while (n) {
+			if (state->neigh_sub_iter) {
+				loff_t fakep = 0;
+				void *v;
+
+				v = state->neigh_sub_iter(state, n, &fakep);
+				if (!v)
+					goto next;
+			}
+			if (!(state->flags & NEIGH_SEQ_SKIP_NOARP))
+				break;
+			if (n->nud_state & ~NUD_NOARP)
+				break;
+		next:
+			n = n->next;
+		}
+
+		if (n)
+			break;
+	}
+	state->bucket = bucket;
+
+	return n;
+}
+
+static struct neighbour *neigh_get_next(struct seq_file *seq,
+					struct neighbour *n,
+					loff_t *pos)
+{
+	struct neigh_seq_state *state = seq->private;
+	struct neigh_table *tbl = state->tbl;
+
+	if (state->neigh_sub_iter) {
+		void *v = state->neigh_sub_iter(state, n, pos);
+		if (v)
+			return n;
+	}
+	n = n->next;
+
+	while (1) {
+		while (n) {
+			if (state->neigh_sub_iter) {
+				void *v = state->neigh_sub_iter(state, n, pos);
+				if (v)
+					return n;
+				goto next;
+			}
+			if (!(state->flags & NEIGH_SEQ_SKIP_NOARP))
+				break;
+
+			if (n->nud_state & ~NUD_NOARP)
+				break;
+		next:
+			n = n->next;
+		}
+
+		if (n)
+			break;
+
+		if (++state->bucket > tbl->hash_mask)
+			break;
+
+		n = tbl->hash_buckets[state->bucket];
+	}
+
+	if (n && pos)
+		--(*pos);
+	return n;
+}
+
+static struct neighbour *neigh_get_idx(struct seq_file *seq, loff_t *pos)
+{
+	struct neighbour *n = neigh_get_first(seq);
+
+	if (n) {
+		while (*pos) {
+			n = neigh_get_next(seq, n, pos);
+			if (!n)
+				break;
+		}
+	}
+	return *pos ? NULL : n;
+}
+
+static struct pneigh_entry *pneigh_get_first(struct seq_file *seq)
+{
+	struct neigh_seq_state *state = seq->private;
+	struct neigh_table *tbl = state->tbl;
+	struct pneigh_entry *pn = NULL;
+	int bucket = state->bucket;
+
+	state->flags |= NEIGH_SEQ_IS_PNEIGH;
+	for (bucket = 0; bucket <= PNEIGH_HASHMASK; bucket++) {
+		pn = tbl->phash_buckets[bucket];
+		if (pn)
+			break;
+	}
+	state->bucket = bucket;
+
+	return pn;
+}
+
+static struct pneigh_entry *pneigh_get_next(struct seq_file *seq,
+					    struct pneigh_entry *pn,
+					    loff_t *pos)
+{
+	struct neigh_seq_state *state = seq->private;
+	struct neigh_table *tbl = state->tbl;
+
+	pn = pn->next;
+	while (!pn) {
+		if (++state->bucket > PNEIGH_HASHMASK)
+			break;
+		pn = tbl->phash_buckets[state->bucket];
+		if (pn)
+			break;
+	}
+
+	if (pn && pos)
+		--(*pos);
+
+	return pn;
+}
+
+static struct pneigh_entry *pneigh_get_idx(struct seq_file *seq, loff_t *pos)
+{
+	struct pneigh_entry *pn = pneigh_get_first(seq);
+
+	if (pn) {
+		while (*pos) {
+			pn = pneigh_get_next(seq, pn, pos);
+			if (!pn)
+				break;
+		}
+	}
+	return *pos ? NULL : pn;
+}
+
+static void *neigh_get_idx_any(struct seq_file *seq, loff_t *pos)
+{
+	struct neigh_seq_state *state = seq->private;
+	void *rc;
+
+	rc = neigh_get_idx(seq, pos);
+	if (!rc && !(state->flags & NEIGH_SEQ_NEIGH_ONLY))
+		rc = pneigh_get_idx(seq, pos);
+
+	return rc;
+}
+
+void *neigh_seq_start(struct seq_file *seq, loff_t *pos, struct neigh_table *tbl, unsigned int neigh_seq_flags)
+{
+	struct neigh_seq_state *state = seq->private;
+	loff_t pos_minus_one;
+
+	state->tbl = tbl;
+	state->bucket = 0;
+	state->flags = (neigh_seq_flags & ~NEIGH_SEQ_IS_PNEIGH);
+
+	read_lock_bh(&tbl->lock);
+
+	pos_minus_one = *pos - 1;
+	return *pos ? neigh_get_idx_any(seq, &pos_minus_one) : SEQ_START_TOKEN;
+}
+
+void *neigh_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct neigh_seq_state *state;
+	void *rc;
+
+	if (v == SEQ_START_TOKEN) {
+		rc = neigh_get_idx(seq, pos);
+		goto out;
+	}
+
+	state = seq->private;
+	if (!(state->flags & NEIGH_SEQ_IS_PNEIGH)) {
+		rc = neigh_get_next(seq, v, NULL);
+		if (rc)
+			goto out;
+		if (!(state->flags & NEIGH_SEQ_NEIGH_ONLY))
+			rc = pneigh_get_first(seq);
+	} else {
+		BUG_ON(state->flags & NEIGH_SEQ_NEIGH_ONLY);
+		rc = pneigh_get_next(seq, v, NULL);
+	}
+out:
+	++(*pos);
+	return rc;
+}
+
+void neigh_seq_stop(struct seq_file *seq, void *v)
+{
+	struct neigh_seq_state *state = seq->private;
+	struct neigh_table *tbl = state->tbl;
+
+	read_unlock_bh(&tbl->lock);
+}
+
+/* statistics via seq_file */
+
+static void *neigh_stat_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	struct proc_dir_entry *pde = seq->private;
+	struct neigh_table *tbl = pde->data;
+	int lcpu;
+
+	if (*pos == 0)
+		return SEQ_START_TOKEN;
+	
+	for (lcpu = *pos-1; lcpu < smp_num_cpus; ++lcpu) {
+		int i = cpu_logical_map(lcpu);
+		*pos = lcpu+1;
+		return &tbl->stats[i];
+	}
+	return NULL;
+}
+
+static void *neigh_stat_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct proc_dir_entry *pde = seq->private;
+	struct neigh_table *tbl = pde->data;
+	int lcpu;
+
+	for (lcpu = *pos; lcpu < smp_num_cpus; ++lcpu) {
+		int i = cpu_logical_map(lcpu);
+		*pos = lcpu+1;
+		return &tbl->stats[i];
+	}
+	return NULL;
+}
+
+static void neigh_stat_seq_stop(struct seq_file *seq, void *v)
+{
+
+}
+
+static int neigh_stat_seq_show(struct seq_file *seq, void *v)
+{
+	struct proc_dir_entry *pde = seq->private;
+	struct neigh_table *tbl = pde->data;
+	struct neigh_statistics *st = v;
+
+	if (v == SEQ_START_TOKEN) {
+		seq_printf(seq, "entries  allocs destroys hash_grows  lookups hits  res_failed  rcv_probes_mcast rcv_probes_ucast  periodic_gc_runs forced_gc_runs forced_gc_goal_miss\n");
+		return 0;
+	}
+
+	seq_printf(seq, "%08x  %08lx %08lx %08lx  %08lx %08lx  %08lx  "
+			"%08lx %08lx  %08lx %08lx\n",
+		   tbl->entries,
+
+		   st->allocs,
+		   st->destroys,
+		   st->hash_grows,
+
+		   st->lookups,
+		   st->hits,
+
+		   st->res_failed,
+
+		   st->rcv_probes_mcast,
+		   st->rcv_probes_ucast,
+
+		   st->periodic_gc_runs,
+		   st->forced_gc_runs
+		   );
+
+	return 0;
+}
+
+static struct seq_operations neigh_stat_seq_ops = {
+	.start	= neigh_stat_seq_start,
+	.next	= neigh_stat_seq_next,
+	.stop	= neigh_stat_seq_stop,
+	.show	= neigh_stat_seq_show,
+};
+
+static int neigh_stat_seq_open(struct inode *inode, struct file *file)
+{
+	int ret = seq_open(file, &neigh_stat_seq_ops);
+
+	if (!ret) {
+		struct seq_file *sf = file->private_data;
+		sf->private = PDE(inode);
+	}
+	return ret;
+};
+
+static struct file_operations neigh_stat_seq_fops = {
+	.owner	 = THIS_MODULE,
+	.open 	 = neigh_stat_seq_open,
+	.read	 = seq_read,
+	.llseek	 = seq_lseek,
+	.release = seq_release,
+};
+
+#endif /* CONFIG_PROC_FS */
 
 #ifdef CONFIG_ARPD
 void neigh_app_ns(struct neighbour *n)
===== net/decnet/dn_neigh.c 1.3 vs edited =====
--- 1.3/net/decnet/dn_neigh.c	2004-01-25 21:21:33 -08:00
+++ edited/net/decnet/dn_neigh.c	2004-10-03 15:12:55 -07:00
@@ -20,6 +20,7 @@
  *     Steve Whitehouse     : Fixed neighbour states (for now anyway).
  *     Steve Whitehouse     : Made error_report functions dummies. This
  *                            is not the right place to return skbs.
+ *     Harald Welte         : Port to DaveM's generalized ncache from 2.6.x
  *
  */
 
@@ -33,6 +34,8 @@
 #include <linux/string.h>
 #include <linux/netfilter_decnet.h>
 #include <linux/spinlock.h>
+#include <linux/seq_file.h>
+#include <linux/jhash.h>
 #include <asm/atomic.h>
 #include <net/neighbour.h>
 #include <net/dst.h>
@@ -118,13 +121,7 @@ struct neigh_table dn_neigh_table = {
 
 static u32 dn_neigh_hash(const void *pkey, const struct net_device *dev)
 {
-	u32 hash_val;
-
-	hash_val = *(dn_address *)pkey;
-	hash_val ^= (hash_val >> 10);
-	hash_val ^= (hash_val >> 3);
-
-	return hash_val & NEIGH_HASHMASK;
+	return jhash_2words(*(dn_address *)pkey, 0, dn_neigh_table.hash_rnd);
 }
 
 static int dn_neigh_construct(struct neighbour *neigh)
@@ -322,33 +319,6 @@ static int dn_phase3_output(struct sk_bu
 }
 
 /*
- * Unfortunately, the neighbour code uses the device in its hash
- * function, so we don't get any advantage from it. This function
- * basically does a neigh_lookup(), but without comparing the device
- * field. This is required for the On-Ethernet cache
- */
-struct neighbour *dn_neigh_lookup(struct neigh_table *tbl, void *ptr)
-{
-	struct neighbour *neigh;
-	u32 hash_val;
-
-	hash_val = tbl->hash(ptr, NULL);
-
-	read_lock_bh(&tbl->lock);
-	for(neigh = tbl->hash_buckets[hash_val]; neigh != NULL; neigh = neigh->next) {
-		if (memcmp(neigh->primary_key, ptr, tbl->key_len) == 0) {
-			atomic_inc(&neigh->refcnt);
-			read_unlock_bh(&tbl->lock);
-			return neigh;
-		}
-	}
-	read_unlock_bh(&tbl->lock);
-
-	return NULL;
-}
-
-
-/*
  * Any traffic on a pointopoint link causes the timer to be reset
  * for the entry in the neighbour table.
  */
@@ -484,113 +454,146 @@ static char *dn_find_slot(char *base, in
 	return (*min < priority) ? (min - 6) : NULL;
 }
 
-int dn_neigh_elist(struct net_device *dev, unsigned char *ptr, int n)
+struct elist_cb_state {
+	struct net_device *dev;
+	unsigned char *ptr;
+	unsigned char *rs;
+	int t, n;
+};
+
+static void neigh_elist_cb(struct neighbour *neigh, void *_info)
 {
-	int t = 0;
-	int i;
-	struct neighbour *neigh;
+	struct elist_cb_state *s = _info;
+	struct dn_dev *dn_db;
 	struct dn_neigh *dn;
-	struct neigh_table *tbl = &dn_neigh_table;
-	unsigned char *rs = ptr;
-	struct dn_dev *dn_db = (struct dn_dev *)dev->dn_ptr;
 
-	read_lock_bh(&tbl->lock);
+	if (neigh->dev != s->dev)
+		return;
 
-	for(i = 0; i < NEIGH_HASHMASK; i++) {
-		for(neigh = tbl->hash_buckets[i]; neigh != NULL; neigh = neigh->next) {
-			if (neigh->dev != dev)
-				continue;
-			dn = (struct dn_neigh *)neigh;
-			if (!(dn->flags & (DN_NDFLAG_R1|DN_NDFLAG_R2)))
-				continue;
-			if (dn_db->parms.forwarding == 1 && (dn->flags & DN_NDFLAG_R2))
-				continue;
-			if (t == n)
-				rs = dn_find_slot(ptr, n, dn->priority);
-			else
-				t++;
-			if (rs == NULL)
-				continue;
-			dn_dn2eth(rs, dn->addr);
-			rs += 6;
-			*rs = neigh->nud_state & NUD_CONNECTED ? 0x80 : 0x0;
-			*rs |= dn->priority;
-			rs++;
-		}
-	}
+	dn = (struct dn_neigh *) neigh;
+	if (!(dn->flags & (DN_NDFLAG_R1|DN_NDFLAG_R2)))
+		return;
+
+	dn_db = (struct dn_dev *) s->dev->dn_ptr;
+	if (dn_db->parms.forwarding == 1 && (dn->flags & DN_NDFLAG_R2))
+		return;
 
-	read_unlock_bh(&tbl->lock);
+	if (s->t == s->n)
+		s->rs = dn_find_slot(s->ptr, s->n, dn->priority);
+	else
+		s->t++;
+	if (s->rs == NULL)
+		return;
+
+	dn_dn2eth(s->rs, dn->addr);
+	s->rs += 6;
+	*(s->rs) = neigh->nud_state & NUD_CONNECTED ? 0x80 : 0x0;
+	*(s->rs) |= dn->priority;
+	s->rs++;
+}
+  
+int dn_neigh_elist(struct net_device *dev, unsigned char *ptr, int n)
+{
+	struct elist_cb_state state;
+
+	state.dev = dev;
+	state.t = 0;
+	state.n = n;
+	state.ptr = ptr;
+	state.rs = ptr;
+
+	neigh_for_each(&dn_neigh_table, neigh_elist_cb, &state);
 
-	return t;
+	return state.t;
 }
+
 #endif /* CONFIG_DECNET_ROUTER */
 
 
 
 #ifdef CONFIG_PROC_FS
-static int dn_neigh_get_info(char *buffer, char **start, off_t offset, int length)
+
+static inline void dn_neigh_format_entry(struct seq_file *seq,
+					 struct neighbour *n)
 {
-        int len     = 0;
-        off_t pos   = 0;
-        off_t begin = 0;
-	struct neighbour *n;
-	int i;
+	struct dn_neigh *dn = (struct dn_neigh *) n;
 	char buf[DN_ASCBUF_LEN];
 
-	len += sprintf(buffer + len, "Addr    Flags State Use Blksize Dev\n");
-
-	for(i=0;i <= NEIGH_HASHMASK; i++) {
-		read_lock_bh(&dn_neigh_table.lock);
-		n = dn_neigh_table.hash_buckets[i];
-		for(; n != NULL; n = n->next) {
-			struct dn_neigh *dn = (struct dn_neigh *)n;
-
-			read_lock(&n->lock);
-			len += sprintf(buffer+len, "%-7s %s%s%s   %02x    %02d  %07ld %-8s\n",
-					dn_addr2asc(dn_ntohs(dn->addr), buf),
-					(dn->flags&DN_NDFLAG_R1) ? "1" : "-",
-					(dn->flags&DN_NDFLAG_R2) ? "2" : "-",
-					(dn->flags&DN_NDFLAG_P3) ? "3" : "-",
-					dn->n.nud_state,
-					atomic_read(&dn->n.refcnt),
-					dn->blksize,
-					(dn->n.dev) ? dn->n.dev->name : "?");
-			read_unlock(&n->lock);
-
-			pos = begin + len;
-
-                	if (pos < offset) {
-                        	len = 0;
-                        	begin = pos;
-                	}
-
-                	if (pos > offset + length) {
-				read_unlock_bh(&dn_neigh_table.lock);
-                       		goto done;
-			}
-		}
-		read_unlock_bh(&dn_neigh_table.lock);
+	read_lock(&n->lock);
+	seq_printf(seq, "%-7s %s%s%s   %02x    %02d  %07ld %-8s\n",
+		   dn_addr2asc(dn_ntohs(dn->addr), buf),
+		   (dn->flags&DN_NDFLAG_R1) ? "1" : "-",
+		   (dn->flags&DN_NDFLAG_R2) ? "2" : "-",
+		   (dn->flags&DN_NDFLAG_P3) ? "3" : "-",
+		   dn->n.nud_state,
+		   atomic_read(&dn->n.refcnt),
+		   dn->blksize,
+		   (dn->n.dev) ? dn->n.dev->name : "?");
+	read_unlock(&n->lock);
+}
+
+static int dn_neigh_seq_show(struct seq_file *seq, void *v)
+{
+	if (v == SEQ_START_TOKEN) {
+		seq_puts(seq, "Addr    Flags State Use Blksize Dev\n");
+	} else {
+		dn_neigh_format_entry(seq, v);
 	}
 
-done:
+	return 0;
+}
 
-        *start = buffer + (offset - begin);
-        len   -= offset - begin;
+static void *dn_neigh_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	return neigh_seq_start(seq, pos, &dn_neigh_table,
+			       NEIGH_SEQ_NEIGH_ONLY);
+}
 
-        if (len > length) len = length;
+static struct seq_operations dn_neigh_seq_ops = {
+	.start = dn_neigh_seq_start,
+	.next = neigh_seq_next,
+	.stop = neigh_seq_stop,
+	.show = dn_neigh_seq_show,
+};
 
-        return len;
-}
+static int dn_neigh_seq_open(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq;
+	int rc = -ENOMEM;
+	struct neigh_seq_state *s = kmalloc(sizeof(*s), GFP_KERNEL);
+
+	if (!s)
+		goto out;
+
+	memset(s, 0, sizeof(*s));
+	rc = seq_open(file, &dn_neigh_seq_ops);
+	if (rc)
+		goto out_kfree;
+
+	seq = file->private_data;
+	seq->private = s;
+	memset(s, 0, sizeof(*s));
+out:
+	return rc;
+out_kfree:
+	kfree(s);
+	goto out;
+}
+
+static struct file_operations dn_neigh_seq_fops = {
+	.owner		= THIS_MODULE,
+	.open		= dn_neigh_seq_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release_private,
+};
 
 #endif
 
 void __init dn_neigh_init(void)
 {
 	neigh_table_init(&dn_neigh_table);
-
-#ifdef CONFIG_PROC_FS
-	proc_net_create("decnet_neigh",0,dn_neigh_get_info);
-#endif /* CONFIG_PROC_FS */
+	proc_net_fops_create("decnet_neigh", S_IRUGO, &dn_neigh_seq_fops);
 }
 
 void __exit dn_neigh_cleanup(void)
===== net/decnet/dn_route.c 1.6 vs edited =====
--- 1.6/net/decnet/dn_route.c	2002-08-12 13:43:21 -07:00
+++ edited/net/decnet/dn_route.c	2004-10-03 15:12:55 -07:00
@@ -761,7 +761,7 @@ static int dn_route_output_slow(struct d
 
 	/* Look in On-Ethernet cache first */
 	if (!(flags & MSG_TRYHARD)) {
-		if ((neigh = dn_neigh_lookup(&dn_neigh_table, &dst)) != NULL)
+		if ((neigh = neigh_lookup_nodev(&dn_neigh_table, &dst)) != NULL)
 			goto got_route;
 	}
 
===== net/ipv4/arp.c 1.16 vs edited =====
--- 1.16/net/ipv4/arp.c	2004-02-19 10:13:39 -08:00
+++ edited/net/ipv4/arp.c	2004-10-03 15:12:55 -07:00
@@ -70,6 +70,7 @@
  *					arp_xmit so intermediate drivers like
  *					bonding can change the skb before
  *					sending (e.g. insert 8021q tag).
+ *		Harald Welte	:	convert to make use of jenkins hash
  */
 
 #include <linux/types.h>
@@ -92,6 +93,7 @@
 #include <linux/proc_fs.h>
 #include <linux/stat.h>
 #include <linux/init.h>
+#include <linux/jhash.h>
 #ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
 #endif
@@ -218,15 +220,7 @@ int arp_mc_map(u32 addr, u8 *haddr, stru
 
 static u32 arp_hash(const void *pkey, const struct net_device *dev)
 {
-	u32 hash_val;
-
-	hash_val = *(u32*)pkey;
-	hash_val ^= (hash_val>>16);
-	hash_val ^= hash_val>>8;
-	hash_val ^= hash_val>>3;
-	hash_val = (hash_val^dev->ifindex)&NEIGH_HASHMASK;
-
-	return hash_val;
+	return jhash_2words(*(u32 *)pkey, dev->ifindex, arp_tbl.hash_rnd);
 }
 
 static int arp_constructor(struct neighbour *neigh)
@@ -1185,129 +1179,155 @@ out:
 	return err;
 }
 
+#ifdef CONFIG_PROC_FS
+#if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
+
+/* ------------------------------------------------------------------------ */
 /*
- *	Write the contents of the ARP cache to a PROCfs file.
+ *	ax25 -> ASCII conversion
  */
-#ifndef CONFIG_PROC_FS
-static int arp_get_info(char *buffer, char **start, off_t offset, int length) { return 0; }
-#else
-#if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
-static char *ax2asc2(ax25_address *a, char *buf);
-#endif
+static char *ax2asc2(ax25_address *a, char *buf)
+{
+	char c, *s;
+	int n;
+
+	for (n = 0, s = buf; n < 6; n++) {
+		c = (a->ax25_call[n] >> 1) & 0x7F;
+
+		if (c != ' ') *s++ = c;
+	}
+	
+	*s++ = '-';
+
+	if ((n = ((a->ax25_call[6] >> 1) & 0x0F)) > 9) {
+		*s++ = '1';
+		n -= 10;
+	}
+	
+	*s++ = n + '0';
+	*s++ = '\0';
+
+	if (*buf == '\0' || *buf == '-')
+	   return "*";
+
+	return buf;
+
+}
+#endif /* CONFIG_AX25 */
+
 #define HBUFFERLEN 30
 
-static int arp_get_info(char *buffer, char **start, off_t offset, int length)
+static void arp_format_neigh_entry(struct seq_file *seq,
+				   struct neighbour *n)
 {
-	int len=0;
-	off_t pos=0;
-	int size;
 	char hbuffer[HBUFFERLEN];
-	int i,j,k;
 	const char hexbuf[] =  "0123456789ABCDEF";
+	int k, j;
+	char tbuf[16];
+	struct net_device *dev = n->dev;
+	int hatype = dev->type;
 
-	size = sprintf(buffer,"IP address       HW type     Flags       HW address            Mask     Device\n");
-
-	pos+=size;
-	len+=size;
+	read_lock(&n->lock);
 
-	for(i=0; i<=NEIGH_HASHMASK; i++) {
-		struct neighbour *n;
-		read_lock_bh(&arp_tbl.lock);
-		for (n=arp_tbl.hash_buckets[i]; n; n=n->next) {
-			struct net_device *dev = n->dev;
-			int hatype = dev->type;
-
-			/* Do not confuse users "arp -a" with magic entries */
-			if (!(n->nud_state&~NUD_NOARP))
-				continue;
-
-			read_lock(&n->lock);
-
-/*
- *	Convert hardware address to XX:XX:XX:XX ... form.
- */
+	/* Convert hardware address to XX:XX:XX:XX ... form. */
 #if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
-			if (hatype == ARPHRD_AX25 || hatype == ARPHRD_NETROM)
-				ax2asc2((ax25_address *)n->ha, hbuffer);
-			else {
-#endif
-			for (k=0,j=0;k<HBUFFERLEN-3 && j<dev->addr_len;j++) {
-				hbuffer[k++]=hexbuf[(n->ha[j]>>4)&15 ];
-				hbuffer[k++]=hexbuf[n->ha[j]&15     ];
-				hbuffer[k++]=':';
-			}
-			hbuffer[--k]=0;
-
+	if (hatype == ARPHRD_AX25 || hatype == ARPHRD_NETROM)
+		ax2asc2((ax25_address *)n->ha, hbuffer);
+	else {
+#endif
+	for (k=0,j=0;k<HBUFFERLEN-3 && j<dev->addr_len;j++) {
+		hbuffer[k++]=hexbuf[(n->ha[j]>>4)&15 ];
+		hbuffer[k++]=hexbuf[n->ha[j]&15     ];
+		hbuffer[k++]=':';
+	}
+	hbuffer[--k]=0;
 #if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
-		}
+	}
 #endif
+	sprintf(tbuf, "%u.%u.%u.%u", NIPQUAD(*(u32*)n->primary_key));
+	seq_printf(seq, "%-16s 0x%-10x0x%-10x%s     *        %s\n",
+		   tbuf, hatype, arp_state_to_flags(n), hbuffer, dev->name);
+	read_unlock(&n->lock);
+}
 
-			{
-				char tbuf[16];
-				sprintf(tbuf, "%u.%u.%u.%u", NIPQUAD(*(u32*)n->primary_key));
-				size = sprintf(buffer+len, "%-16s 0x%-10x0x%-10x%s"
-							"     *        %s\n",
-					tbuf,
-					hatype,
-					arp_state_to_flags(n), 
-					hbuffer,
-					dev->name);
-			}
+static void arp_format_pneigh_entry(struct seq_file *seq,
+				    struct pneigh_entry *n)
+{
+	struct net_device *dev = n->dev;
+	int hatype = dev ? dev->type : 0;
+	char tbuf[16];
 
-			read_unlock(&n->lock);
+	sprintf(tbuf, "%u.%u.%u.%u", NIPQUAD(*(u32*)n->key));
+	seq_printf(seq, "%-16s 0x%-10x0x%-10x%s     *        %s\n",
+		   tbuf, hatype, ATF_PUBL | ATF_PERM, "00:00:00:00:00:00",
+		   dev ? dev->name : "*");
+}
 
-			len += size;
-			pos += size;
-		  
-			if (pos <= offset)
-				len=0;
-			if (pos >= offset+length) {
-				read_unlock_bh(&arp_tbl.lock);
- 				goto done;
-			}
-		}
-		read_unlock_bh(&arp_tbl.lock);
+static int arp_seq_show(struct seq_file *seq, void *v)
+{
+	if (v == SEQ_START_TOKEN) {
+		seq_puts(seq, "IP address       HW type     Flags       "
+			      "HW address            Mask     Device\n");
+	} else {
+		struct neigh_seq_state *state = seq->private;
+
+		if (state->flags & NEIGH_SEQ_IS_PNEIGH)
+			arp_format_pneigh_entry(seq, v);
+		else
+			arp_format_neigh_entry(seq, v);
 	}
 
-	for (i=0; i<=PNEIGH_HASHMASK; i++) {
-		struct pneigh_entry *n;
-		for (n=arp_tbl.phash_buckets[i]; n; n=n->next) {
-			struct net_device *dev = n->dev;
-			int hatype = dev ? dev->type : 0;
-
-			{
-				char tbuf[16];
-				sprintf(tbuf, "%u.%u.%u.%u", NIPQUAD(*(u32*)n->key));
-				size = sprintf(buffer+len, "%-16s 0x%-10x0x%-10x%s"
-							"     *        %s\n",
-					tbuf,
-					hatype,
- 					ATF_PUBL|ATF_PERM,
-					"00:00:00:00:00:00",
-					dev ? dev->name : "*");
-			}
+	return 0;
+}
 
-			len += size;
-			pos += size;
-		  
-			if (pos <= offset)
-				len=0;
-			if (pos >= offset+length)
-				goto done;
-		}
-	}
+static void *arp_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	/* Don't want to confuse "arp -a" w/ magic entries,
+	 * so we tell the generic iterator to skip NUD_NOARP.
+	 */
+	return neigh_seq_start(seq, pos, &arp_tbl, NEIGH_SEQ_SKIP_NOARP);
+}
+
+/* ------------------------------------------------------------------------ */
+
+static struct seq_operations arp_seq_ops = {
+	.start	= arp_seq_start,
+	.next	= neigh_seq_next,
+	.stop	= neigh_seq_stop,
+	.show	= arp_seq_show,
+};
+
+static int arp_seq_open(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq;
+	int rc = -ENOMEM;
+	struct neigh_seq_state *s = kmalloc(sizeof(*s), GFP_KERNEL);
+
+	if (!s)
+		goto out;
+
+	memset(s, 0, sizeof(*s));
+	rc = seq_open(file, &arp_seq_ops);
+	if (rc)
+		goto out_kfree;
 
-done:
-  
-	*start = buffer+len-(pos-offset);	/* Start of wanted data */
-	len = pos-offset;			/* Start slop */
-	if (len>length)
-		len = length;			/* Ending slop */
-	if (len<0)
-		len = 0;
-	return len;
+	seq = file->private_data;
+	seq->private = s;
+out:
+	return rc;
+out_kfree:
+	kfree(s);
+	goto out;
 }
-#endif
+
+static struct file_operations arp_seq_fops = {
+	.owner		= THIS_MODULE,
+	.open		= arp_seq_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release_private,
+};
+#endif /* CONFIG_PROC_FS */
 
 static int arp_netdev_event(struct notifier_block *this, unsigned long event, void *ptr)
 {
@@ -1355,8 +1375,10 @@ void __init arp_init (void)
 
 	dev_add_pack(&arp_packet_type);
 
-	proc_net_create ("arp", 0, arp_get_info);
-
+#ifdef CONFIG_PROC_FS
+	if (!proc_net_fops_create("arp", S_IRUGO, &arp_seq_fops))
+		panic("unable to create arp proc entry");
+#endif
 #ifdef CONFIG_SYSCTL
 	neigh_sysctl_register(NULL, &arp_tbl.parms, NET_IPV4, NET_IPV4_NEIGH, "ipv4");
 #endif
@@ -1364,39 +1386,3 @@ void __init arp_init (void)
 }
 
 
-#ifdef CONFIG_PROC_FS
-#if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
-
-/*
- *	ax25 -> ASCII conversion
- */
-char *ax2asc2(ax25_address *a, char *buf)
-{
-	char c, *s;
-	int n;
-
-	for (n = 0, s = buf; n < 6; n++) {
-		c = (a->ax25_call[n] >> 1) & 0x7F;
-
-		if (c != ' ') *s++ = c;
-	}
-	
-	*s++ = '-';
-
-	if ((n = ((a->ax25_call[6] >> 1) & 0x0F)) > 9) {
-		*s++ = '1';
-		n -= 10;
-	}
-	
-	*s++ = n + '0';
-	*s++ = '\0';
-
-	if (*buf == '\0' || *buf == '-')
-	   return "*";
-
-	return buf;
-
-}
-
-#endif
-#endif
===== net/ipv4/route.c 1.24 vs edited =====
--- 1.24/net/ipv4/route.c	2003-08-16 12:10:15 -07:00
+++ edited/net/ipv4/route.c	2004-10-03 15:12:55 -07:00
@@ -284,6 +284,7 @@ static int rt_cache_stat_get_info(char *
 	int i, lcpu;
 	int len = 0;
 
+ 	len += sprintf(buffer+len, "entries  in_hit in_slow_tot in_slow_mc in_no_route in_brd in_martian_dst in_martian_src  out_hit out_slow_tot out_slow_mc  gc_total gc_ignored gc_goal_miss gc_dst_overflow in_hlist_search out_hlist_search\n");
         for (lcpu = 0; lcpu < smp_num_cpus; lcpu++) {
                 i = cpu_logical_map(lcpu);
 
@@ -2625,7 +2626,8 @@ void __init ip_rt_init(void)
 	add_timer(&rt_secret_timer);
 
 	proc_net_create ("rt_cache", 0, rt_cache_get_info);
-	proc_net_create ("rt_cache_stat", 0, rt_cache_stat_get_info);
+	create_proc_info_entry ("rt_cache", 0, proc_net_stat, 
+				rt_cache_stat_get_info);
 #ifdef CONFIG_NET_CLS_ROUTE
 	create_proc_read_entry("net/rt_acct", 0, 0, ip_rt_acct_read, NULL);
 #endif
===== net/ipv6/ndisc.c 1.26 vs edited =====
--- 1.26/net/ipv6/ndisc.c	2004-07-15 13:33:03 -07:00
+++ edited/net/ipv6/ndisc.c	2004-10-03 15:12:55 -07:00
@@ -60,6 +60,7 @@
 #include <linux/if_arp.h>
 #include <linux/ipv6.h>
 #include <linux/icmpv6.h>
+#include <linux/jhash.h>
 
 #include <net/sock.h>
 #include <net/snmp.h>
@@ -240,15 +241,14 @@ int ndisc_mc_map(struct in6_addr *addr, 
 
 static u32 ndisc_hash(const void *pkey, const struct net_device *dev)
 {
-	u32 hash_val;
+	const u32 *p32 = pkey;
+	u32 addr_hash, i;
 
-	hash_val = *(u32*)(pkey + sizeof(struct in6_addr) - 4);
-	hash_val ^= (hash_val>>16);
-	hash_val ^= hash_val>>8;
-	hash_val ^= hash_val>>3;
-	hash_val = (hash_val^dev->ifindex)&NEIGH_HASHMASK;
+	addr_hash = 0;
+	for (i = 0; i < (sizeof(struct in6_addr) / sizeof(u32)); i++)
+		addr_hash ^= *p32++;
 
-	return hash_val;
+	return jhash_2words(addr_hash, dev->ifindex, nd_tbl.hash_rnd);
 }
 
 static int ndisc_constructor(struct neighbour *neigh)
@@ -696,9 +696,9 @@ void ndisc_recv_ns(struct sk_buff *skb)
 			int inc = ipv6_addr_type(daddr)&IPV6_ADDR_MULTICAST;
 
 			if (inc)
-				nd_tbl.stats.rcv_probes_mcast++;
+				NEIGH_CACHE_STAT_INC(&nd_tbl, rcv_probes_mcast);
 			else
-				nd_tbl.stats.rcv_probes_ucast++;
+				NEIGH_CACHE_STAT_INC(&nd_tbl, rcv_probes_ucast);
 
 			/* 
 			 *	update / create cache entry
@@ -741,9 +741,9 @@ void ndisc_recv_ns(struct sk_buff *skb)
 		if (addr_type & IPV6_ADDR_UNICAST) {
 			int inc = ipv6_addr_type(daddr)&IPV6_ADDR_MULTICAST;
 			if (inc)  
-				nd_tbl.stats.rcv_probes_mcast++;
+				NEIGH_CACHE_STAT_INC(&nd_tbl, rcv_probes_mcast);
  			else
-				nd_tbl.stats.rcv_probes_ucast++;
+				NEIGH_CACHE_STAT_INC(&nd_tbl, rcv_probes_ucast);
 
 			/*
 			 *   update / create cache entry
@@ -775,9 +775,11 @@ void ndisc_recv_ns(struct sk_buff *skb)
 			    inc == 0 ||
 			    in6_dev->nd_parms->proxy_delay == 0) {
 				if (inc)
-					nd_tbl.stats.rcv_probes_mcast++;
+					NEIGH_CACHE_STAT_INC(&nd_tbl, 
+							rcv_probes_mcast);
 				else
-					nd_tbl.stats.rcv_probes_ucast++;
+					NEIGH_CACHE_STAT_INC(&nd_tbl, 
+							rcv_probes_ucast);
 					
 				neigh = neigh_event_ns(&nd_tbl, lladdr, saddr, dev);
 
