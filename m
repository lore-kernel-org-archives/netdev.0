From: Harald Welte <laforge@gnumonks.org>
Subject: [PATCH 2.4] backport neighbour cache redesign
Date: Thu, 30 Sep 2004 17:47:53 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040930154753.GD1860@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="+vcRm3WFmV0Q/ShD"
Cc: Linux Netdev List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--+vcRm3WFmV0Q/ShD
Content-Type: multipart/mixed; boundary="7tPHY7RFL01rOa8z"
Content-Disposition: inline


--7tPHY7RFL01rOa8z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave!

I've now finished the 2.4.x backport of the neighbour cache redesign.
The patch applies to 2.4.28-pre3-bk5.

It compiles cleanly, and ipv4/ipv6 are working as expected.  I don't
have a decnet or atm test setup, so I leave testing to somebody else ;)

Let's hope I didn't introduce new bugs, the merging got a bit ugly since
percpu is missing and (more important) 2.4.x networking didn't yet use
seq_file.  So in some cases like ATM, clip is now using seq_file, while
everything else uses the old get_info() proc methods.

Cheers,
	Harald

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--7tPHY7RFL01rOa8z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="2.4.28-pre3-bk5-neigh26.patch"
Content-Transfer-Encoding: quoted-printable

diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.4=
=2E28-pre3-bk5-plain/drivers/net/bonding/bond_main.c linux-2.4.28-pre3-bk5-=
neigh/drivers/net/bonding/bond_main.c
--- linux-2.4.28-pre3-bk5-plain/drivers/net/bonding/bond_main.c	2004-04-14 =
15:05:30.000000000 +0200
+++ linux-2.4.28-pre3-bk5-neigh/drivers/net/bonding/bond_main.c	2004-09-30 =
14:16:12.000000000 +0200
@@ -3086,8 +3086,6 @@
=20
 #ifdef CONFIG_PROC_FS
=20
-#define SEQ_START_TOKEN ((void *)1)
-
 static void *bond_info_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	struct bonding *bond =3D seq->private;
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.4=
=2E28-pre3-bk5-plain/fs/proc/root.c linux-2.4.28-pre3-bk5-neigh/fs/proc/roo=
t.c
--- linux-2.4.28-pre3-bk5-plain/fs/proc/root.c	2002-08-03 02:39:45.00000000=
0 +0200
+++ linux-2.4.28-pre3-bk5-neigh/fs/proc/root.c	2004-09-30 11:35:52.00000000=
0 +0200
@@ -17,7 +17,7 @@
 #include <linux/module.h>
 #include <asm/bitops.h>
=20
-struct proc_dir_entry *proc_net, *proc_bus, *proc_root_fs, *proc_root_driv=
er;
+struct proc_dir_entry *proc_net, *proc_net_stat, *proc_bus, *proc_root_fs,=
 *proc_root_driver;
=20
 #ifdef CONFIG_SYSCTL
 struct proc_dir_entry *proc_sys_root;
@@ -38,6 +38,8 @@
 	}
 	proc_misc_init();
 	proc_net =3D proc_mkdir("net", 0);
+	proc_net_stat =3D proc_mkdir("net/stat", NULL);
+
 #ifdef CONFIG_SYSVIPC
 	proc_mkdir("sysvipc", 0);
 #endif
@@ -143,5 +145,6 @@
 EXPORT_SYMBOL(proc_root);
 EXPORT_SYMBOL(proc_root_fs);
 EXPORT_SYMBOL(proc_net);
+EXPORT_SYMBOL(proc_net_stat);
 EXPORT_SYMBOL(proc_bus);
 EXPORT_SYMBOL(proc_root_driver);
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.4=
=2E28-pre3-bk5-plain/include/linux/proc_fs.h linux-2.4.28-pre3-bk5-neigh/in=
clude/linux/proc_fs.h
--- linux-2.4.28-pre3-bk5-plain/include/linux/proc_fs.h	2003-11-28 19:26:21=
=2E000000000 +0100
+++ linux-2.4.28-pre3-bk5-neigh/include/linux/proc_fs.h	2004-09-30 16:34:36=
=2E000000000 +0200
@@ -79,6 +79,7 @@
 extern struct proc_dir_entry proc_root;
 extern struct proc_dir_entry *proc_root_fs;
 extern struct proc_dir_entry *proc_net;
+extern struct proc_dir_entry *proc_net_stat;
 extern struct proc_dir_entry *proc_bus;
 extern struct proc_dir_entry *proc_root_driver;
 extern struct proc_dir_entry *proc_root_kcore;
@@ -170,6 +171,16 @@
 	return create_proc_info_entry(name,mode,proc_net,get_info);
 }
=20
+static inline struct proc_dir_entry *proc_net_fops_create(const char *name,
+	mode_t mode, struct file_operations *fops)
+{
+	struct proc_dir_entry *res =3D create_proc_entry(name, mode, proc_net);
+
+	if (res)
+		res->proc_fops =3D fops;
+	return res;
+}
+
 static inline void proc_net_remove(const char *name)
 {
 	remove_proc_entry(name,proc_net);
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.4=
=2E28-pre3-bk5-plain/include/linux/seq_file.h linux-2.4.28-pre3-bk5-neigh/i=
nclude/linux/seq_file.h
--- linux-2.4.28-pre3-bk5-plain/include/linux/seq_file.h	2004-09-30 14:08:5=
3.000000000 +0200
+++ linux-2.4.28-pre3-bk5-neigh/include/linux/seq_file.h	2004-09-30 14:15:3=
5.000000000 +0200
@@ -65,5 +65,8 @@
 int single_open(struct file *, int (*)(struct seq_file *, void *), void *);
 int single_release(struct inode *, struct file *);
 int seq_release_private(struct inode *, struct file *);
+
+#define SEQ_START_TOKEN ((void *)1)
+
 #endif
 #endif
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.4=
=2E28-pre3-bk5-plain/include/net/dn_neigh.h linux-2.4.28-pre3-bk5-neigh/inc=
lude/net/dn_neigh.h
--- linux-2.4.28-pre3-bk5-plain/include/net/dn_neigh.h	2000-03-02 19:13:16.=
000000000 +0100
+++ linux-2.4.28-pre3-bk5-neigh/include/net/dn_neigh.h	2004-09-30 11:36:35.=
000000000 +0200
@@ -18,7 +18,6 @@
=20
 extern void dn_neigh_init(void);
 extern void dn_neigh_cleanup(void);
-extern struct neighbour *dn_neigh_lookup(struct neigh_table *tbl, void *pt=
r);
 extern int dn_neigh_router_hello(struct sk_buff *skb);
 extern int dn_neigh_endnode_hello(struct sk_buff *skb);
 extern void dn_neigh_pointopoint_hello(struct sk_buff *skb);
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.4=
=2E28-pre3-bk5-plain/include/net/neighbour.h linux-2.4.28-pre3-bk5-neigh/in=
clude/net/neighbour.h
--- linux-2.4.28-pre3-bk5-plain/include/net/neighbour.h	2004-09-30 11:31:17=
=2E000000000 +0200
+++ linux-2.4.28-pre3-bk5-neigh/include/net/neighbour.h	2004-09-30 14:16:33=
=2E000000000 +0200
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
=20
 /* The following flags & states are exported to user space,
@@ -45,6 +50,7 @@
=20
 #include <asm/atomic.h>
 #include <linux/skbuff.h>
+#include <linux/seq_file.h>
=20
 #define NUD_IN_TIMER	(NUD_INCOMPLETE|NUD_DELAY|NUD_PROBE)
 #define NUD_VALID	(NUD_PERMANENT|NUD_NOARP|NUD_REACHABLE|NUD_PROBE|NUD_STA=
LE|NUD_DELAY)
@@ -78,12 +84,25 @@
=20
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
=20
+#define NEIGH_CACHE_STAT_INC(tbl, field)				\
+		((tbl)->stats[smp_processor_id()].field++)
+
 struct neighbour
 {
 	struct neighbour	*next;
@@ -128,9 +147,6 @@
 	u8			key[0];
 };
=20
-#define NEIGH_HASHMASK		0x1F
-#define PNEIGH_HASHMASK		0xF
-
 /*
  *	neighbour table manipulation
  */
@@ -164,9 +180,15 @@
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
=20
 extern void			neigh_table_init(struct neigh_table *tbl);
@@ -174,6 +196,8 @@
 extern struct neighbour *	neigh_lookup(struct neigh_table *tbl,
 					     const void *pkey,
 					     struct net_device *dev);
+extern struct neighbour *	neigh_lookup_nodev(struct neigh_table *tbl,
+						   const void *pkey);
 extern struct neighbour *	neigh_create(struct neigh_table *tbl,
 					     const void *pkey,
 					     struct net_device *dev);
@@ -205,6 +229,24 @@
 extern int neigh_delete(struct sk_buff *skb, struct nlmsghdr *nlh, void *a=
rg);
 extern void neigh_app_ns(struct neighbour *n);
=20
+extern void neigh_for_each(struct neigh_table *tbl, void (*cb)(struct neig=
hbour *, void *), void *cookie);
+extern void __neigh_for_each_release(struct neigh_table *tbl, int (*cb)(st=
ruct neighbour *));
+extern void pneigh_for_each(struct neigh_table *tbl, void (*cb)(struct pne=
igh_entry *));
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
+extern void *neigh_seq_start(struct seq_file *, loff_t *, struct neigh_tab=
le *, unsigned int);
+extern void *neigh_seq_next(struct seq_file *, void *, loff_t *);
+extern void neigh_seq_stop(struct seq_file *, void *);
+
 extern int			neigh_sysctl_register(struct net_device *dev, struct neigh_pa=
rms *p,
 						      int p_id, int pdev_id, char *p_name);
 extern void			neigh_sysctl_unregister(struct neigh_parms *p);
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.4=
=2E28-pre3-bk5-plain/net/atm/clip.c linux-2.4.28-pre3-bk5-neigh/net/atm/cli=
p.c
--- linux-2.4.28-pre3-bk5-plain/net/atm/clip.c	2004-02-18 14:36:32.00000000=
0 +0100
+++ linux-2.4.28-pre3-bk5-neigh/net/atm/clip.c	2004-09-30 12:50:09.00000000=
0 +0200
@@ -1,6 +1,10 @@
 /* net/atm/clip.c - RFC1577 Classical IP over ATM */
=20
-/* Written 1995-2000 by Werner Almesberger, EPFL LRC/ICA */
+/* Written 1995-2000 by Werner Almesberger, EPFL LRC/ICA=20
+ *
+ * Changes:
+ * 	Harald Welte <laforge@gnumonks.org>:
+ * 	- backport DaveM's generalized neighbour cache from 2.6.9-rcX */
=20
=20
 #include <linux/config.h>
@@ -24,6 +28,7 @@
 #include <linux/if.h> /* for IFF_UP */
 #include <linux/inetdevice.h>
 #include <linux/bitops.h>
+#include <linux/jhash.h>
 #include <net/route.h> /* for struct rtable and routing */
 #include <net/icmp.h> /* icmp_send */
 #include <asm/param.h> /* for HZ */
@@ -119,64 +124,49 @@
 	spin_unlock_bh(&entry->neigh->dev->xmit_lock);
 }
=20
-
-static void idle_timer_check(unsigned long dummy)
+/* The neighbour entry n->lock is held. */
+static int neigh_check_cb(struct neighbour *n)
 {
-	int i;
+	struct atmarp_entry *entry =3D NEIGH2ENTRY(n);
+	struct clip_vcc *cv;
=20
-	/*DPRINTK("idle_timer_check\n");*/
-	write_lock(&clip_tbl.lock);
-	for (i =3D 0; i <=3D NEIGH_HASHMASK; i++) {
-		struct neighbour **np;
+	for (cv =3D entry->vccs; cv; cv =3D cv->next) {
+		unsigned long exp =3D cv->last_use + cv->idle_timeout;
=20
-		for (np =3D &clip_tbl.hash_buckets[i]; *np;) {
-			struct neighbour *n =3D *np;
-			struct atmarp_entry *entry =3D NEIGH2ENTRY(n);
-			struct clip_vcc *clip_vcc;
-
-			write_lock(&n->lock);
-
-			for (clip_vcc =3D entry->vccs; clip_vcc;
-			    clip_vcc =3D clip_vcc->next)
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
-				np =3D &n->next;
-				write_unlock(&n->lock);
-				continue;
-			}
-			if (atomic_read(&n->refcnt) > 1) {
-				struct sk_buff *skb;
-
-				DPRINTK("destruction postponed with ref %d\n",
-				    atomic_read(&n->refcnt));
-				while ((skb =3D skb_dequeue(&n->arp_queue)) !=3D
-				     NULL)=20
-					dev_kfree_skb(skb);
-				np =3D &n->next;
-				write_unlock(&n->lock);
-				continue;
-			}
-			*np =3D n->next;
-			DPRINTK("expired neigh %p\n",n);
-			n->dead =3D 1;
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
+		while ((skb =3D skb_dequeue(&n->arp_queue)) !=3D NULL)=20
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
=20
-
 static int clip_arp_rcv(struct sk_buff *skb)
 {
 	struct atm_vcc *vcc;
@@ -320,15 +310,7 @@
=20
 static u32 clip_hash(const void *pkey, const struct net_device *dev)
 {
-	u32 hash_val;
-
-	hash_val =3D *(u32*)pkey;
-	hash_val ^=3D (hash_val>>16);
-	hash_val ^=3D hash_val>>8;
-	hash_val ^=3D hash_val>>3;
-	hash_val =3D (hash_val^dev->ifindex)&NEIGH_HASHMASK;
-
-	return hash_val;
+	return jhash_2words(*(u32 *)pkey, dev->ifindex, clip_tbl.hash_rnd);
 }
=20
=20
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.4=
=2E28-pre3-bk5-plain/net/atm/proc.c linux-2.4.28-pre3-bk5-neigh/net/atm/pro=
c.c
--- linux-2.4.28-pre3-bk5-plain/net/atm/proc.c	2003-11-28 19:26:21.00000000=
0 +0100
+++ linux-2.4.28-pre3-bk5-neigh/net/atm/proc.c	2004-09-30 15:01:36.00000000=
0 +0200
@@ -90,74 +90,202 @@
=20
 #if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
=20
+#define SEQ_NO_VCC_TOKEN   ((void *) 2)
=20
-static int svc_addr(char *buf,struct sockaddr_atmsvc *addr)
+static void svc_addr(struct seq_file *seq, struct sockaddr_atmsvc *addr)
 {
 	static int code[] =3D { 1,2,10,6,1,0 };
 	static int e164[] =3D { 1,8,4,6,1,0 };
-	int *fields;
-	int len,i,j,pos;
=20
-	len =3D 0;
 	if (*addr->sas_addr.pub) {
-		strcpy(buf,addr->sas_addr.pub);
-		len =3D strlen(addr->sas_addr.pub);
-		buf +=3D len;
-		if (*addr->sas_addr.prv) {
-			*buf++ =3D '+';
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
-		len +=3D 44;
-		pos =3D 0;
-		fields =3D *addr->sas_addr.prv =3D=3D ATM_AFI_E164 ? e164 : code;
+		unsigned char *prv =3D addr->sas_addr.prv;
+		int *fields;
+		int i, j;
+
+		fields =3D *prv =3D=3D ATM_AFI_E164 ? e164 : code;
 		for (i =3D 0; fields[i]; i++) {
-			for (j =3D fields[i]; j; j--) {
-				sprintf(buf,"%02X",addr->sas_addr.prv[pos++]);
-				buf +=3D 2;
-			}
-			if (fields[i+1]) *buf++ =3D '.';
+			for (j =3D fields[i]; j; j--)
+				seq_printf(seq, "%02X", *prv++);
+			if (fields[i+1])=20
+				seq_putc(seq, '.');
 		}
 	}
-	return len;
 }
=20
=20
-static void atmarp_info(struct net_device *dev,struct atmarp_entry *entry,
-    struct clip_vcc *clip_vcc,char *buf)
-{
-	unsigned char *ip;
-	int svc,off,ip_len;
+static void atmarp_info(struct seq_file *seq, struct net_device *dev,struct
+			atmarp_entry *entry, struct clip_vcc *clip_vcc) {
+	unsigned long exp;
+	char buf[17];
+	int svc, llc, off;
+
+	svc =3D ((clip_vcc =3D=3D SEQ_NO_VCC_TOKEN) ||
+	       (clip_vcc->vcc->sk->family =3D=3D AF_ATMSVC));
+
+	llc =3D ((clip_vcc =3D=3D SEQ_NO_VCC_TOKEN) ||
+	       (clip_vcc->encap));
+
+	if (clip_vcc =3D=3D SEQ_NO_VCC_TOKEN)
+		exp =3D entry->neigh->used;
+	else
+		exp =3D clip_vcc->last_use;
+
+	exp =3D (jiffies - exp) / HZ;
+
+	seq_printf(seq, "%-6s%-4s%-4s%5ld ",
+		   dev->name,
+		   svc ? "SVC" : "PVC",
+		   llc ? "LLC" : "NULL",
+		   exp);
=20
-	svc =3D !clip_vcc || clip_vcc->vcc->sk->family =3D=3D AF_ATMSVC;
-	off =3D sprintf(buf,"%-6s%-4s%-4s%5ld ",dev->name,svc ? "SVC" : "PVC",
-	    !clip_vcc || clip_vcc->encap ? "LLC" : "NULL",
-	    (jiffies-(clip_vcc ? clip_vcc->last_use : entry->neigh->used))/
-	    HZ);
-	ip =3D (unsigned char *) &entry->ip;
-	ip_len =3D sprintf(buf+off,"%d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
-	off +=3D ip_len;
-	while (ip_len++ < 16) buf[off++] =3D ' ';
-	if (!clip_vcc)
+	off =3D snprintf(buf, sizeof(buf)-1, "%d.%d.%d.%d", NIPQUAD(entry->ip));
+	while (off < 16)
+		buf[off++] =3D ' ';
+	buf[off] =3D '\0';
+	seq_printf(seq, "%s", buf);
+
+	if (clip_vcc =3D=3D SEQ_NO_VCC_TOKEN) {
 		if (time_before(jiffies, entry->expires))
-			strcpy(buf+off,"(resolving)\n");
-		else sprintf(buf+off,"(expired, ref %d)\n",
-			    atomic_read(&entry->neigh->refcnt));
-	else if (!svc)
-			sprintf(buf+off,"%d.%d.%d\n",clip_vcc->vcc->dev->number,
-			    clip_vcc->vcc->vpi,clip_vcc->vcc->vci);
-		else {
-			off +=3D svc_addr(buf+off,&clip_vcc->vcc->remote);
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
+		curr =3D e->vccs;
+		if (!curr)
+			return SEQ_NO_VCC_TOKEN;
+		return curr;
+	}
+
+	if (curr =3D=3D SEQ_NO_VCC_TOKEN)
+		return NULL;
+
+	curr =3D curr->next;
+
+	return curr;
+}
+
+static void *clip_seq_vcc_walk(struct clip_seq_state *state,
+			       struct atmarp_entry *e, loff_t *pos)
+{
+	struct clip_vcc *vcc =3D state->vcc;
+
+	vcc =3D clip_seq_next_vcc(e, vcc);
+	if (vcc && pos !=3D NULL) {
+		while (*pos) {
+			vcc =3D clip_seq_next_vcc(e, vcc);
+			if (!vcc)
+				break;
+			--(*pos);
 		}
+	}
+	state->vcc =3D vcc;
+
+	return vcc;
 }
=20
+static void *clip_seq_sub_iter(struct neigh_seq_state *_state,
+			       struct neighbour *n, loff_t *pos)
+{
+	struct clip_seq_state *state =3D (struct clip_seq_state *) _state;
=20
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
+	static char atm_arp_banner[] =3D=20
+		"IPitf TypeEncp Idle IP address      ATM address\n";
+
+	if (v =3D=3D SEQ_START_TOKEN) {
+		seq_puts(seq, atm_arp_banner);
+	} else {
+		struct clip_seq_state *state =3D seq->private;
+		struct neighbour *n =3D v;
+		struct clip_vcc *vcc =3D state->vcc;
+
+		atmarp_info(seq, n->dev, NEIGH2ENTRY(n), vcc);
+	}
+	return 0;
+}
+
+static struct seq_operations arp_seq_ops =3D {
+	.start	=3D clip_seq_start,
+	.next	=3D neigh_seq_next,
+	.stop	=3D neigh_seq_stop,
+	.show	=3D clip_seq_show,
+};
+
+static int arp_seq_open(struct inode *inode, struct file *file)
+{
+	struct clip_seq_state *state;
+	struct seq_file *seq;
+	int rc =3D -EAGAIN;
+
+	state =3D kmalloc(sizeof(*state), GFP_KERNEL);
+	if (!state) {
+		rc =3D -ENOMEM;
+		goto out_kfree;
+	}
+	memset(state, 0, sizeof(*state));
+	state->ns.neigh_sub_iter =3D clip_seq_sub_iter;
+
+	rc =3D seq_open(file, &arp_seq_ops);
+	if (rc)
+		goto out_kfree;
+
+	seq =3D file->private_data;
+	seq->private =3D state;
+out:
+	return rc;
+
+out_kfree:
+	kfree(state);
+	goto out;
+}
+
+static struct file_operations arp_seq_fops =3D {
+	.open		=3D arp_seq_open,
+	.read		=3D seq_read,
+	.llseek		=3D seq_lseek,
+	.release	=3D seq_release_private,
+	.owner		=3D THIS_MODULE,
+};
 #endif
=20
=20
@@ -416,6 +544,7 @@
 	return 0;
 }
=20
+#if 0
 #if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
 static int atm_arp_info(loff_t pos,char *buf)
 {
@@ -459,6 +588,7 @@
 	return 0;
 }
 #endif
+#endif
=20
 #if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
 static int atm_lec_info(loff_t pos,char *buf)
@@ -666,7 +796,10 @@
 	CREATE_ENTRY(svc);
 	CREATE_ENTRY(vc);
 #if defined(CONFIG_ATM_CLIP) || defined(CONFIG_ATM_CLIP_MODULE)
-	CREATE_ENTRY(arp);
+	arp  =3D create_proc_entry("arp", S_IRUGO, atm_proc_root);
+	if (!arp)
+		goto cleanup;
+	arp->proc_fops =3D &arp_seq_fops;
 #endif
 #if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
 	CREATE_ENTRY(lec);
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.4=
=2E28-pre3-bk5-plain/net/core/neighbour.c linux-2.4.28-pre3-bk5-neigh/net/c=
ore/neighbour.c
--- linux-2.4.28-pre3-bk5-plain/net/core/neighbour.c	2004-09-30 11:31:17.00=
0000000 +0200
+++ linux-2.4.28-pre3-bk5-neigh/net/core/neighbour.c	2004-09-30 14:21:06.00=
0000000 +0200
@@ -12,6 +12,8 @@
  *
  *	Fixes:
  *	Vitaly E. Lavrov	releasing NULL neighbor in neigh_add.
+ *	Harald Welte		Add neighbour cache statistics like rtstat
+ *	Harald Welte		port neighbour cache rework from 2.6.9-rcX
  */
=20
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
=20
 #define NEIGH_DEBUG 1
=20
@@ -45,6 +49,8 @@
 #define NEIGH_PRINTK2 NEIGH_PRINTK
 #endif
=20
+#define PNEIGH_HASHMASK		0xF
+
 static void neigh_timer_handler(unsigned long arg);
 #ifdef CONFIG_ARPD
 static void neigh_app_notify(struct neighbour *n);
@@ -54,6 +60,7 @@
=20
 static int neigh_glbl_allocs;
 static struct neigh_table *neigh_tables;
+static struct file_operations neigh_stat_seq_fops;
=20
 /*
    Neighbour hash table buckets are protected with rwlock tbl->lock.
@@ -111,27 +118,21 @@
 	int shrunk =3D 0;
 	int i;
=20
-	for (i=3D0; i<=3DNEIGH_HASHMASK; i++) {
+	NEIGH_CACHE_STAT_INC(tbl, forced_gc_runs);
+
+	write_lock_bh(&tbl->lock);
+	for (i =3D 0; i <=3D tbl->hash_mask; i++) {
 		struct neighbour *n, **np;
=20
 		np =3D &tbl->hash_buckets[i];
-		write_lock_bh(&tbl->lock);
 		while ((n =3D *np) !=3D NULL) {
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
 			if (atomic_read(&n->refcnt) =3D=3D 1 &&
-			    !(n->nud_state&NUD_PERMANENT) &&
-			    (n->nud_state !=3D NUD_INCOMPLETE ||
-			     jiffies - n->used > n->parms->retrans_time)) {
+			    !(n->nud_state&NUD_PERMANENT)) {
 				*np =3D n->next;
 				n->dead =3D 1;
 				shrunk =3D 1;
@@ -142,10 +143,12 @@
 			write_unlock(&n->lock);
 			np =3D &n->next;
 		}
-		write_unlock_bh(&tbl->lock);
 	}
 =09
 	tbl->last_flush =3D jiffies;
+
+	write_unlock_bh(&tbl->lock);
+
 	return shrunk;
 }
=20
@@ -176,7 +179,7 @@
=20
 	write_lock_bh(&tbl->lock);
=20
-	for (i=3D0; i <=3D NEIGH_HASHMASK; i++) {
+	for (i=3D0; i <=3D tbl->hash_mask; i++) {
 		struct neighbour *n, **np;
=20
 		np =3D &tbl->hash_buckets[i];
@@ -203,7 +206,7 @@
=20
 	write_lock_bh(&tbl->lock);
=20
-	for (i=3D0; i<=3DNEIGH_HASHMASK; i++) {
+	for (i =3D 0; i <=3D tbl->hash_mask; i++) {
 		struct neighbour *n, **np;
=20
 		np =3D &tbl->hash_buckets[i];
@@ -277,7 +280,7 @@
 	init_timer(&n->timer);
 	n->timer.function =3D neigh_timer_handler;
 	n->timer.data =3D (unsigned long)n;
-	tbl->stats.allocs++;
+	NEIGH_CACHE_STAT_INC(tbl, allocs);
 	neigh_glbl_allocs++;
 	tbl->entries++;
 	n->tbl =3D tbl;
@@ -286,20 +289,103 @@
 	return n;
 }
=20
+static struct neighbour **neigh_hash_alloc(unsigned int entries)
+{
+	unsigned long size =3D entries * sizeof(struct neighbour *);
+	struct neighbour **ret;
+
+	if (size <=3D PAGE_SIZE) {
+		ret =3D kmalloc(size, GFP_ATOMIC);
+	} else {
+		ret =3D (struct neighbour **)
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
+	unsigned long size =3D entries * sizeof(struct neighbour *);
+
+	if (size <=3D PAGE_SIZE)
+		kfree(hash);
+	else
+		free_pages((unsigned long)hash, get_order(size));
+}
+
+static void neigh_hash_grow(struct neigh_table *tbl, unsigned long new_ent=
ries)
+{
+	struct neighbour **new_hash, **old_hash;
+	unsigned int i, new_hash_mask, old_entries;
+
+	NEIGH_CACHE_STAT_INC(tbl, hash_grows);
+
+	BUG_ON(new_entries & (new_entries - 1));
+	new_hash =3D neigh_hash_alloc(new_entries);
+	if (!new_hash)
+		return;
+
+	old_entries =3D tbl->hash_mask + 1;
+	new_hash_mask =3D new_entries - 1;
+	old_hash =3D tbl->hash_buckets;
+
+	for (i =3D 0; i < old_entries; i++) {
+		struct neighbour *n, *next;
+
+		for (n =3D old_hash[i]; n; n =3D next) {
+			unsigned int hash_val =3D tbl->hash(n->primary_key, n->dev);
+
+			hash_val &=3D new_hash_mask;
+			next =3D n->next;
+
+			n->next =3D new_hash[hash_val];
+			new_hash[hash_val] =3D n;
+		}
+	}
+	tbl->hash_buckets =3D new_hash;
+	tbl->hash_mask =3D new_hash_mask;
+
+	neigh_hash_free(old_hash, old_entries);
+}
+
 struct neighbour *neigh_lookup(struct neigh_table *tbl, const void *pkey,
 			       struct net_device *dev)
 {
 	struct neighbour *n;
-	u32 hash_val;
 	int key_len =3D tbl->key_len;
+	u32 hash_val =3D tbl->hash(pkey, dev) & tbl->hash_mask;
=20
-	hash_val =3D tbl->hash(pkey, dev);
+	NEIGH_CACHE_STAT_INC(tbl, lookups);
=20
 	read_lock_bh(&tbl->lock);
 	for (n =3D tbl->hash_buckets[hash_val]; n; n =3D n->next) {
 		if (dev =3D=3D n->dev &&
 		    memcmp(n->primary_key, pkey, key_len) =3D=3D 0) {
 			neigh_hold(n);
+			NEIGH_CACHE_STAT_INC(tbl, hits);
+			break;
+		}
+	}
+	read_unlock_bh(&tbl->lock);
+	return n;
+}
+
+struct neighbour *neigh_lookup_nodev(struct neigh_table *tbl, const void *=
pkey)
+{
+	struct neighbour *n;
+	int key_len =3D tbl->key_len;
+	u32 hash_val =3D tbl->hash(pkey, NULL) & tbl->hash_mask;
+
+	NEIGH_CACHE_STAT_INC(tbl, lookups);
+
+	read_lock_bh(&tbl->lock);
+	for (n =3D tbl->hash_buckets[hash_val]; n; n =3D n->next) {
+		if (!memcmp(n->primary_key, pkey, key_len)) {
+			neigh_hold(n);
+			NEIGH_CACHE_STAT_INC(tbl, hits);
 			break;
 		}
 	}
@@ -319,6 +405,12 @@
 	if (n =3D=3D NULL)
 		return ERR_PTR(-ENOBUFS);
=20
+	if (tbl->entries > (tbl->hash_mask + 1)) {
+		write_lock_bh(&tbl->lock);
+		neigh_hash_grow(tbl, (tbl->hash_mask + 1) << 1);
+		write_unlock_bh(&tbl->lock);
+	}
+
 	memcpy(n->primary_key, pkey, key_len);
 	n->dev =3D dev;
 	dev_hold(dev);
@@ -338,7 +430,7 @@
=20
 	n->confirmed =3D jiffies - (n->parms->base_reachable_time<<1);
=20
-	hash_val =3D tbl->hash(pkey, dev);
+	hash_val =3D tbl->hash(pkey, dev) & tbl->hash_mask;
=20
 	write_lock_bh(&tbl->lock);
 	for (n1 =3D tbl->hash_buckets[hash_val]; n1; n1 =3D n1->next) {
@@ -418,9 +510,9 @@
 	hash_val ^=3D hash_val>>4;
 	hash_val &=3D PNEIGH_HASHMASK;
=20
+	write_lock_bh(&tbl->lock);
 	for (np =3D &tbl->phash_buckets[hash_val]; (n=3D*np) !=3D NULL; np =3D &n=
->next) {
 		if (memcmp(n->key, pkey, key_len) =3D=3D 0 && n->dev =3D=3D dev) {
-			write_lock_bh(&tbl->lock);
 			*np =3D n->next;
 			write_unlock_bh(&tbl->lock);
 			if (tbl->pdestructor)
@@ -429,6 +521,7 @@
 			return 0;
 		}
 	}
+	write_unlock_bh(&tbl->lock);
 	return -ENOENT;
 }
=20
@@ -462,6 +555,8 @@
 {=09
 	struct hh_cache *hh;
=20
+	NEIGH_CACHE_STAT_INC(neigh->tbl, destroys);
+
 	if (!neigh->dead) {
 		printk("Destroying alive neighbour %p\n", neigh);
 		dump_stack();
@@ -566,9 +661,10 @@
 static void SMP_TIMER_NAME(neigh_periodic_timer)(unsigned long arg)
 {
 	struct neigh_table *tbl =3D (struct neigh_table*)arg;
-	unsigned long now =3D jiffies;
-	int i;
+	struct neighbour *n, **np;
+	unsigned long expire, now =3D jiffies;
=20
+	NEIGH_CACHE_STAT_INC(tbl, periodic_gc_runs);
=20
 	write_lock(&tbl->lock);
=20
@@ -583,46 +679,49 @@
 			p->reachable_time =3D neigh_rand_reach_time(p->base_reachable_time);
 	}
=20
-	for (i=3D0; i <=3D NEIGH_HASHMASK; i++) {
-		struct neighbour *n, **np;
-
-		np =3D &tbl->hash_buckets[i];
-		while ((n =3D *np) !=3D NULL) {
-			unsigned state;
-
-			write_lock(&n->lock);
+	np =3D &tbl->hash_buckets[tbl->hash_chain_gc];
+	tbl->hash_chain_gc =3D ((tbl->hash_chain_gc + 1) & tbl->hash_mask);
=20
-			state =3D n->nud_state;
-			if (state&(NUD_PERMANENT|NUD_IN_TIMER)) {
-				write_unlock(&n->lock);
-				goto next_elt;
-			}
+	while ((n =3D *np) !=3D NULL) {
+		unsigned int state;
=20
-			if ((long)(n->used - n->confirmed) < 0)
-				n->used =3D n->confirmed;
+		write_lock(&n->lock);
+ =20
+		state =3D n->nud_state;
+		if (state & (NUD_PERMANENT | NUD_IN_TIMER)) {
+			write_unlock(&n->lock);
+			goto next_elt;
+		}
=20
-			if (atomic_read(&n->refcnt) =3D=3D 1 &&
-			    (state =3D=3D NUD_FAILED || now - n->used > n->parms->gc_staletime)=
) {
-				*np =3D n->next;
-				n->dead =3D 1;
-				write_unlock(&n->lock);
-				neigh_release(n);
-				continue;
-			}
+		if (time_before(n->used, n->confirmed))
+			n->used =3D n->confirmed;
=20
-			if (n->nud_state&NUD_REACHABLE &&
-			    now - n->confirmed > n->parms->reachable_time) {
-				n->nud_state =3D NUD_STALE;
-				neigh_suspect(n);
-			}
+		if (atomic_read(&n->refcnt) =3D=3D 1 &&
+		    (state =3D=3D NUD_FAILED ||
+		     time_after(now, n->used + n->parms->gc_staletime))) {
+			*np =3D n->next;
+			n->dead =3D 1;
 			write_unlock(&n->lock);
+			neigh_release(n);
+			continue;
+		}
+		write_unlock(&n->lock);
=20
 next_elt:
-			np =3D &n->next;
-		}
+		np =3D &n->next;
 	}
+ =20
+ 	/* Cycle through all hash buckets every base_reachable_time/2 ticks.
+ 	 * ARP entry timeouts range from 1/2 base_reachable_time to 3/2
+ 	 * base_reachable_time.
+	 */
+	expire =3D tbl->parms.base_reachable_time >> 1;
+	expire /=3D (tbl->hash_mask + 1);
+	if (!expire)
+		expire =3D 1;
+
+ 	mod_timer(&tbl->gc_timer, now + expire);
=20
-	mod_timer(&tbl->gc_timer, now + tbl->gc_interval);
 	write_unlock(&tbl->lock);
 }
=20
@@ -680,7 +779,7 @@
=20
 		neigh->nud_state =3D NUD_FAILED;
 		notify =3D 1;
-		neigh->tbl->stats.res_failed++;
+		NEIGH_CACHE_STAT_INC(neigh->tbl, res_failed);
 		NEIGH_PRINTK2("neigh %p is failed.\n", neigh);
=20
 		/* It is very thin place. report_unreachable is very complicated
@@ -1132,6 +1231,7 @@
 void neigh_table_init(struct neigh_table *tbl)
 {
 	unsigned long now =3D jiffies;
+	unsigned long phsize;
=20
 	tbl->parms.reachable_time =3D neigh_rand_reach_time(tbl->parms.base_reach=
able_time);
=20
@@ -1141,6 +1241,30 @@
 						     0, SLAB_HWCACHE_ALIGN,
 						     NULL, NULL);
=20
+	if (!tbl->kmem_cachep)
+		panic("cannot create neighbour cache");
+
+#ifdef CONFIG_PROC_FS
+	tbl->pde =3D create_proc_entry(tbl->id, 0, proc_net_stat);
+	if (!tbl->pde)=20
+		panic("cannot create neighbour proc dir entry");
+	tbl->pde->proc_fops =3D &neigh_stat_seq_fops;
+	tbl->pde->data =3D tbl;
+#endif
+
+	tbl->hash_mask =3D 0x1f;
+	tbl->hash_buckets =3D neigh_hash_alloc(tbl->hash_mask + 1);
+
+	phsize =3D (PNEIGH_HASHMASK + 1) * sizeof(struct pneigh_entry *);
+	tbl->phash_buckets =3D kmalloc(phsize, GFP_KERNEL);
+
+	if (!tbl->hash_buckets || !tbl->phash_buckets)
+		panic("cannot allocate neighbour cache hashes");
+
+	memset(tbl->phash_buckets, 0, phsize);
+
+	get_random_bytes(&tbl->hash_rnd, sizeof(tbl->hash_rnd));
+
 #ifdef CONFIG_SMP
 	tasklet_init(&tbl->gc_task, SMP_TIMER_NAME(neigh_periodic_timer), (unsign=
ed long)tbl);
 #endif
@@ -1148,7 +1272,7 @@
 	tbl->lock =3D RW_LOCK_UNLOCKED;
 	tbl->gc_timer.data =3D (unsigned long)tbl;
 	tbl->gc_timer.function =3D neigh_periodic_timer;
-	tbl->gc_timer.expires =3D now + tbl->gc_interval + tbl->parms.reachable_t=
ime;
+	tbl->gc_timer.expires =3D now + 1;
 	add_timer(&tbl->gc_timer);
=20
 	init_timer(&tbl->proxy_timer);
@@ -1184,6 +1308,13 @@
 		}
 	}
 	write_unlock(&neigh_tbl_lock);
+
+	neigh_hash_free(tbl->hash_buckets, tbl->hash_mask + 1);
+	tbl->hash_buckets =3D NULL;
+
+	kfree(tbl->phash_buckets);
+	tbl->phash_buckets =3D NULL;
+
 #ifdef CONFIG_SYSCTL
 	neigh_sysctl_unregister(&tbl->parms);
 #endif
@@ -1364,7 +1495,7 @@
=20
 	s_h =3D cb->args[1];
 	s_idx =3D idx =3D cb->args[2];
-	for (h=3D0; h <=3D NEIGH_HASHMASK; h++) {
+	for (h=3D0; h <=3D tbl->hash_mask; h++) {
 		if (h < s_h) continue;
 		if (h > s_h)
 			s_idx =3D 0;
@@ -1415,6 +1546,359 @@
 	return skb->len;
 }
=20
+void neigh_for_each(struct neigh_table *tbl, void (*cb)(struct neighbour *=
, void *), void *cookie)
+{
+	int chain;
+
+	read_lock_bh(&tbl->lock);
+	for (chain =3D 0; chain <=3D tbl->hash_mask; chain++) {
+		struct neighbour *n;
+
+		for (n =3D tbl->hash_buckets[chain]; n; n =3D n->next)
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
+	for (chain =3D 0; chain <=3D tbl->hash_mask; chain++) {
+		struct neighbour *n, **np;
+
+		np =3D &tbl->hash_buckets[chain];
+		while ((n =3D *np) !=3D NULL) {
+			int release;
+
+			write_lock(&n->lock);
+			release =3D cb(n);
+			if (release) {
+				*np =3D n->next;
+				n->dead =3D 1;
+			} else
+				np =3D &n->next;
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
+	struct neigh_seq_state *state =3D seq->private;
+	struct neigh_table *tbl =3D state->tbl;
+	struct neighbour *n =3D NULL;
+	int bucket =3D state->bucket;
+
+	state->flags &=3D ~NEIGH_SEQ_IS_PNEIGH;
+	for (bucket =3D 0; bucket <=3D tbl->hash_mask; bucket++) {
+		n =3D tbl->hash_buckets[bucket];
+
+		while (n) {
+			if (state->neigh_sub_iter) {
+				loff_t fakep =3D 0;
+				void *v;
+
+				v =3D state->neigh_sub_iter(state, n, &fakep);
+				if (!v)
+					goto next;
+			}
+			if (!(state->flags & NEIGH_SEQ_SKIP_NOARP))
+				break;
+			if (n->nud_state & ~NUD_NOARP)
+				break;
+		next:
+			n =3D n->next;
+		}
+
+		if (n)
+			break;
+	}
+	state->bucket =3D bucket;
+
+	return n;
+}
+
+static struct neighbour *neigh_get_next(struct seq_file *seq,
+					struct neighbour *n,
+					loff_t *pos)
+{
+	struct neigh_seq_state *state =3D seq->private;
+	struct neigh_table *tbl =3D state->tbl;
+
+	if (state->neigh_sub_iter) {
+		void *v =3D state->neigh_sub_iter(state, n, pos);
+		if (v)
+			return n;
+	}
+	n =3D n->next;
+
+	while (1) {
+		while (n) {
+			if (state->neigh_sub_iter) {
+				void *v =3D state->neigh_sub_iter(state, n, pos);
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
+			n =3D n->next;
+		}
+
+		if (n)
+			break;
+
+		if (++state->bucket > tbl->hash_mask)
+			break;
+
+		n =3D tbl->hash_buckets[state->bucket];
+	}
+
+	if (n && pos)
+		--(*pos);
+	return n;
+}
+
+static struct neighbour *neigh_get_idx(struct seq_file *seq, loff_t *pos)
+{
+	struct neighbour *n =3D neigh_get_first(seq);
+
+	if (n) {
+		while (*pos) {
+			n =3D neigh_get_next(seq, n, pos);
+			if (!n)
+				break;
+		}
+	}
+	return *pos ? NULL : n;
+}
+
+static struct pneigh_entry *pneigh_get_first(struct seq_file *seq)
+{
+	struct neigh_seq_state *state =3D seq->private;
+	struct neigh_table *tbl =3D state->tbl;
+	struct pneigh_entry *pn =3D NULL;
+	int bucket =3D state->bucket;
+
+	state->flags |=3D NEIGH_SEQ_IS_PNEIGH;
+	for (bucket =3D 0; bucket <=3D PNEIGH_HASHMASK; bucket++) {
+		pn =3D tbl->phash_buckets[bucket];
+		if (pn)
+			break;
+	}
+	state->bucket =3D bucket;
+
+	return pn;
+}
+
+static struct pneigh_entry *pneigh_get_next(struct seq_file *seq,
+					    struct pneigh_entry *pn,
+					    loff_t *pos)
+{
+	struct neigh_seq_state *state =3D seq->private;
+	struct neigh_table *tbl =3D state->tbl;
+
+	pn =3D pn->next;
+	while (!pn) {
+		if (++state->bucket > PNEIGH_HASHMASK)
+			break;
+		pn =3D tbl->phash_buckets[state->bucket];
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
+static struct pneigh_entry *pneigh_get_idx(struct seq_file *seq, loff_t *p=
os)
+{
+	struct pneigh_entry *pn =3D pneigh_get_first(seq);
+
+	if (pn) {
+		while (*pos) {
+			pn =3D pneigh_get_next(seq, pn, pos);
+			if (!pn)
+				break;
+		}
+	}
+	return *pos ? NULL : pn;
+}
+
+static void *neigh_get_idx_any(struct seq_file *seq, loff_t *pos)
+{
+	struct neigh_seq_state *state =3D seq->private;
+	void *rc;
+
+	rc =3D neigh_get_idx(seq, pos);
+	if (!rc && !(state->flags & NEIGH_SEQ_NEIGH_ONLY))
+		rc =3D pneigh_get_idx(seq, pos);
+
+	return rc;
+}
+
+void *neigh_seq_start(struct seq_file *seq, loff_t *pos, struct neigh_tabl=
e *tbl, unsigned int neigh_seq_flags)
+{
+	struct neigh_seq_state *state =3D seq->private;
+	loff_t pos_minus_one;
+
+	state->tbl =3D tbl;
+	state->bucket =3D 0;
+	state->flags =3D (neigh_seq_flags & ~NEIGH_SEQ_IS_PNEIGH);
+
+	read_lock_bh(&tbl->lock);
+
+	pos_minus_one =3D *pos - 1;
+	return *pos ? neigh_get_idx_any(seq, &pos_minus_one) : SEQ_START_TOKEN;
+}
+
+void *neigh_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct neigh_seq_state *state;
+	void *rc;
+
+	if (v =3D=3D SEQ_START_TOKEN) {
+		rc =3D neigh_get_idx(seq, pos);
+		goto out;
+	}
+
+	state =3D seq->private;
+	if (!(state->flags & NEIGH_SEQ_IS_PNEIGH)) {
+		rc =3D neigh_get_next(seq, v, NULL);
+		if (rc)
+			goto out;
+		if (!(state->flags & NEIGH_SEQ_NEIGH_ONLY))
+			rc =3D pneigh_get_first(seq);
+	} else {
+		BUG_ON(state->flags & NEIGH_SEQ_NEIGH_ONLY);
+		rc =3D pneigh_get_next(seq, v, NULL);
+	}
+out:
+	++(*pos);
+	return rc;
+}
+
+void neigh_seq_stop(struct seq_file *seq, void *v)
+{
+	struct neigh_seq_state *state =3D seq->private;
+	struct neigh_table *tbl =3D state->tbl;
+
+	read_unlock_bh(&tbl->lock);
+}
+
+/* statistics via seq_file */
+
+static void *neigh_stat_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	struct proc_dir_entry *pde =3D seq->private;
+	struct neigh_table *tbl =3D pde->data;
+	int lcpu;
+
+	if (*pos =3D=3D 0)
+		return SEQ_START_TOKEN;
+=09
+	for (lcpu =3D *pos-1; lcpu < smp_num_cpus; ++lcpu) {
+		int i =3D cpu_logical_map(lcpu);
+		*pos =3D lcpu+1;
+		return &tbl->stats[i];
+	}
+	return NULL;
+}
+
+static void *neigh_stat_seq_next(struct seq_file *seq, void *v, loff_t *po=
s)
+{
+	struct proc_dir_entry *pde =3D seq->private;
+	struct neigh_table *tbl =3D pde->data;
+	int lcpu;
+
+	for (lcpu =3D *pos; lcpu < smp_num_cpus; ++lcpu) {
+		int i =3D cpu_logical_map(lcpu);
+		*pos =3D lcpu+1;
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
+	struct proc_dir_entry *pde =3D seq->private;
+	struct neigh_table *tbl =3D pde->data;
+	struct neigh_statistics *st =3D v;
+
+	if (v =3D=3D SEQ_START_TOKEN) {
+		seq_printf(seq, "entries  allocs destroys hash_grows  lookups hits  res_=
failed  rcv_probes_mcast rcv_probes_ucast  periodic_gc_runs forced_gc_runs =
forced_gc_goal_miss\n");
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
+static struct seq_operations neigh_stat_seq_ops =3D {
+	.start	=3D neigh_stat_seq_start,
+	.next	=3D neigh_stat_seq_next,
+	.stop	=3D neigh_stat_seq_stop,
+	.show	=3D neigh_stat_seq_show,
+};
+
+static int neigh_stat_seq_open(struct inode *inode, struct file *file)
+{
+	int ret =3D seq_open(file, &neigh_stat_seq_ops);
+
+	if (!ret) {
+		struct seq_file *sf =3D file->private_data;
+		sf->private =3D PDE(inode);
+	}
+	return ret;
+};
+
+static struct file_operations neigh_stat_seq_fops =3D {
+	.owner	 =3D THIS_MODULE,
+	.open 	 =3D neigh_stat_seq_open,
+	.read	 =3D seq_read,
+	.llseek	 =3D seq_lseek,
+	.release =3D seq_release,
+};
+
+#endif /* CONFIG_PROC_FS */
+
 #ifdef CONFIG_ARPD
 void neigh_app_ns(struct neighbour *n)
 {
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.4=
=2E28-pre3-bk5-plain/net/decnet/dn_neigh.c linux-2.4.28-pre3-bk5-neigh/net/=
decnet/dn_neigh.c
--- linux-2.4.28-pre3-bk5-plain/net/decnet/dn_neigh.c	2004-02-18 14:36:32.0=
00000000 +0100
+++ linux-2.4.28-pre3-bk5-neigh/net/decnet/dn_neigh.c	2004-09-30 15:29:46.0=
00000000 +0200
@@ -20,6 +20,7 @@
  *     Steve Whitehouse     : Fixed neighbour states (for now anyway).
  *     Steve Whitehouse     : Made error_report functions dummies. This
  *                            is not the right place to return skbs.
+ *     Harald Welte         : Port to DaveM's generalized ncache from 2.6.x
  *
  */
=20
@@ -33,6 +34,8 @@
 #include <linux/string.h>
 #include <linux/netfilter_decnet.h>
 #include <linux/spinlock.h>
+#include <linux/seq_file.h>
+#include <linux/jhash.h>
 #include <asm/atomic.h>
 #include <net/neighbour.h>
 #include <net/dst.h>
@@ -118,13 +121,7 @@
=20
 static u32 dn_neigh_hash(const void *pkey, const struct net_device *dev)
 {
-	u32 hash_val;
-
-	hash_val =3D *(dn_address *)pkey;
-	hash_val ^=3D (hash_val >> 10);
-	hash_val ^=3D (hash_val >> 3);
-
-	return hash_val & NEIGH_HASHMASK;
+	return jhash_2words(*(dn_address *)pkey, 0, dn_neigh_table.hash_rnd);
 }
=20
 static int dn_neigh_construct(struct neighbour *neigh)
@@ -322,33 +319,6 @@
 }
=20
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
-	hash_val =3D tbl->hash(ptr, NULL);
-
-	read_lock_bh(&tbl->lock);
-	for(neigh =3D tbl->hash_buckets[hash_val]; neigh !=3D NULL; neigh =3D nei=
gh->next) {
-		if (memcmp(neigh->primary_key, ptr, tbl->key_len) =3D=3D 0) {
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
@@ -484,113 +454,146 @@
 	return (*min < priority) ? (min - 6) : NULL;
 }
=20
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
-	int t =3D 0;
-	int i;
-	struct neighbour *neigh;
+	struct elist_cb_state *s =3D _info;
+	struct dn_dev *dn_db;
 	struct dn_neigh *dn;
-	struct neigh_table *tbl =3D &dn_neigh_table;
-	unsigned char *rs =3D ptr;
-	struct dn_dev *dn_db =3D (struct dn_dev *)dev->dn_ptr;
=20
-	read_lock_bh(&tbl->lock);
+	if (neigh->dev !=3D s->dev)
+		return;
=20
-	for(i =3D 0; i < NEIGH_HASHMASK; i++) {
-		for(neigh =3D tbl->hash_buckets[i]; neigh !=3D NULL; neigh =3D neigh->ne=
xt) {
-			if (neigh->dev !=3D dev)
-				continue;
-			dn =3D (struct dn_neigh *)neigh;
-			if (!(dn->flags & (DN_NDFLAG_R1|DN_NDFLAG_R2)))
-				continue;
-			if (dn_db->parms.forwarding =3D=3D 1 && (dn->flags & DN_NDFLAG_R2))
-				continue;
-			if (t =3D=3D n)
-				rs =3D dn_find_slot(ptr, n, dn->priority);
-			else
-				t++;
-			if (rs =3D=3D NULL)
-				continue;
-			dn_dn2eth(rs, dn->addr);
-			rs +=3D 6;
-			*rs =3D neigh->nud_state & NUD_CONNECTED ? 0x80 : 0x0;
-			*rs |=3D dn->priority;
-			rs++;
-		}
-	}
+	dn =3D (struct dn_neigh *) neigh;
+	if (!(dn->flags & (DN_NDFLAG_R1|DN_NDFLAG_R2)))
+		return;
+
+	dn_db =3D (struct dn_dev *) s->dev->dn_ptr;
+	if (dn_db->parms.forwarding =3D=3D 1 && (dn->flags & DN_NDFLAG_R2))
+		return;
=20
-	read_unlock_bh(&tbl->lock);
+	if (s->t =3D=3D s->n)
+		s->rs =3D dn_find_slot(s->ptr, s->n, dn->priority);
+	else
+		s->t++;
+	if (s->rs =3D=3D NULL)
+		return;
+
+	dn_dn2eth(s->rs, dn->addr);
+	s->rs +=3D 6;
+	*(s->rs) =3D neigh->nud_state & NUD_CONNECTED ? 0x80 : 0x0;
+	*(s->rs) |=3D dn->priority;
+	s->rs++;
+}
+ =20
+int dn_neigh_elist(struct net_device *dev, unsigned char *ptr, int n)
+{
+	struct elist_cb_state state;
+
+	state.dev =3D dev;
+	state.t =3D 0;
+	state.n =3D n;
+	state.ptr =3D ptr;
+	state.rs =3D ptr;
+
+	neigh_for_each(&dn_neigh_table, neigh_elist_cb, &state);
=20
-	return t;
+	return state.t;
 }
+
 #endif /* CONFIG_DECNET_ROUTER */
=20
=20
=20
 #ifdef CONFIG_PROC_FS
-static int dn_neigh_get_info(char *buffer, char **start, off_t offset, int=
 length)
+
+static inline void dn_neigh_format_entry(struct seq_file *seq,
+					 struct neighbour *n)
 {
-        int len     =3D 0;
-        off_t pos   =3D 0;
-        off_t begin =3D 0;
-	struct neighbour *n;
-	int i;
+	struct dn_neigh *dn =3D (struct dn_neigh *) n;
 	char buf[DN_ASCBUF_LEN];
=20
-	len +=3D sprintf(buffer + len, "Addr    Flags State Use Blksize Dev\n");
-
-	for(i=3D0;i <=3D NEIGH_HASHMASK; i++) {
-		read_lock_bh(&dn_neigh_table.lock);
-		n =3D dn_neigh_table.hash_buckets[i];
-		for(; n !=3D NULL; n =3D n->next) {
-			struct dn_neigh *dn =3D (struct dn_neigh *)n;
-
-			read_lock(&n->lock);
-			len +=3D sprintf(buffer+len, "%-7s %s%s%s   %02x    %02d  %07ld %-8s\n",
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
-			pos =3D begin + len;
-
-                	if (pos < offset) {
-                        	len =3D 0;
-                        	begin =3D pos;
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
+	if (v =3D=3D SEQ_START_TOKEN) {
+		seq_puts(seq, "Addr    Flags State Use Blksize Dev\n");
+	} else {
+		dn_neigh_format_entry(seq, v);
 	}
=20
-done:
+	return 0;
+}
=20
-        *start =3D buffer + (offset - begin);
-        len   -=3D offset - begin;
+static void *dn_neigh_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	return neigh_seq_start(seq, pos, &dn_neigh_table,
+			       NEIGH_SEQ_NEIGH_ONLY);
+}
=20
-        if (len > length) len =3D length;
+static struct seq_operations dn_neigh_seq_ops =3D {
+	.start =3D dn_neigh_seq_start,
+	.next =3D neigh_seq_next,
+	.stop =3D neigh_seq_stop,
+	.show =3D dn_neigh_seq_show,
+};
=20
-        return len;
-}
+static int dn_neigh_seq_open(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq;
+	int rc =3D -ENOMEM;
+	struct neigh_seq_state *s =3D kmalloc(sizeof(*s), GFP_KERNEL);
+
+	if (!s)
+		goto out;
+
+	memset(s, 0, sizeof(*s));
+	rc =3D seq_open(file, &dn_neigh_seq_ops);
+	if (rc)
+		goto out_kfree;
+
+	seq =3D file->private_data;
+	seq->private =3D s;
+	memset(s, 0, sizeof(*s));
+out:
+	return rc;
+out_kfree:
+	kfree(s);
+	goto out;
+}
+
+static struct file_operations dn_neigh_seq_fops =3D {
+	.owner		=3D THIS_MODULE,
+	.open		=3D dn_neigh_seq_open,
+	.read		=3D seq_read,
+	.llseek		=3D seq_lseek,
+	.release	=3D seq_release_private,
+};
=20
 #endif
=20
 void __init dn_neigh_init(void)
 {
 	neigh_table_init(&dn_neigh_table);
-
-#ifdef CONFIG_PROC_FS
-	proc_net_create("decnet_neigh",0,dn_neigh_get_info);
-#endif /* CONFIG_PROC_FS */
+	proc_net_fops_create("decnet_neigh", S_IRUGO, &dn_neigh_seq_fops);
 }
=20
 void __exit dn_neigh_cleanup(void)
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.4=
=2E28-pre3-bk5-plain/net/decnet/dn_route.c linux-2.4.28-pre3-bk5-neigh/net/=
decnet/dn_route.c
--- linux-2.4.28-pre3-bk5-plain/net/decnet/dn_route.c	2002-11-29 00:53:15.0=
00000000 +0100
+++ linux-2.4.28-pre3-bk5-neigh/net/decnet/dn_route.c	2004-09-30 12:13:03.0=
00000000 +0200
@@ -761,7 +761,7 @@
=20
 	/* Look in On-Ethernet cache first */
 	if (!(flags & MSG_TRYHARD)) {
-		if ((neigh =3D dn_neigh_lookup(&dn_neigh_table, &dst)) !=3D NULL)
+		if ((neigh =3D neigh_lookup_nodev(&dn_neigh_table, &dst)) !=3D NULL)
 			goto got_route;
 	}
=20
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.4=
=2E28-pre3-bk5-plain/net/ipv4/arp.c linux-2.4.28-pre3-bk5-neigh/net/ipv4/ar=
p.c
--- linux-2.4.28-pre3-bk5-plain/net/ipv4/arp.c	2004-04-14 15:05:41.00000000=
0 +0200
+++ linux-2.4.28-pre3-bk5-neigh/net/ipv4/arp.c	2004-09-30 17:07:25.00000000=
0 +0200
@@ -70,6 +70,7 @@
  *					arp_xmit so intermediate drivers like
  *					bonding can change the skb before
  *					sending (e.g. insert 8021q tag).
+ *		Harald Welte	:	convert to make use of jenkins hash
  */
=20
 #include <linux/types.h>
@@ -92,6 +93,7 @@
 #include <linux/proc_fs.h>
 #include <linux/stat.h>
 #include <linux/init.h>
+#include <linux/jhash.h>
 #ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
 #endif
@@ -218,15 +220,7 @@
=20
 static u32 arp_hash(const void *pkey, const struct net_device *dev)
 {
-	u32 hash_val;
-
-	hash_val =3D *(u32*)pkey;
-	hash_val ^=3D (hash_val>>16);
-	hash_val ^=3D hash_val>>8;
-	hash_val ^=3D hash_val>>3;
-	hash_val =3D (hash_val^dev->ifindex)&NEIGH_HASHMASK;
-
-	return hash_val;
+	return jhash_2words(*(u32 *)pkey, dev->ifindex, arp_tbl.hash_rnd);
 }
=20
 static int arp_constructor(struct neighbour *neigh)
@@ -1185,129 +1179,155 @@
 	return err;
 }
=20
+#ifdef CONFIG_PROC_FS
+#if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
+
+/* -----------------------------------------------------------------------=
- */
 /*
- *	Write the contents of the ARP cache to a PROCfs file.
+ *	ax25 -> ASCII conversion
  */
-#ifndef CONFIG_PROC_FS
-static int arp_get_info(char *buffer, char **start, off_t offset, int leng=
th) { return 0; }
-#else
-#if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
-static char *ax2asc2(ax25_address *a, char *buf);
-#endif
+static char *ax2asc2(ax25_address *a, char *buf)
+{
+	char c, *s;
+	int n;
+
+	for (n =3D 0, s =3D buf; n < 6; n++) {
+		c =3D (a->ax25_call[n] >> 1) & 0x7F;
+
+		if (c !=3D ' ') *s++ =3D c;
+	}
+=09
+	*s++ =3D '-';
+
+	if ((n =3D ((a->ax25_call[6] >> 1) & 0x0F)) > 9) {
+		*s++ =3D '1';
+		n -=3D 10;
+	}
+=09
+	*s++ =3D n + '0';
+	*s++ =3D '\0';
+
+	if (*buf =3D=3D '\0' || *buf =3D=3D '-')
+	   return "*";
+
+	return buf;
+
+}
+#endif /* CONFIG_AX25 */
+
 #define HBUFFERLEN 30
=20
-static int arp_get_info(char *buffer, char **start, off_t offset, int leng=
th)
+static void arp_format_neigh_entry(struct seq_file *seq,
+				   struct neighbour *n)
 {
-	int len=3D0;
-	off_t pos=3D0;
-	int size;
 	char hbuffer[HBUFFERLEN];
-	int i,j,k;
 	const char hexbuf[] =3D  "0123456789ABCDEF";
+	int k, j;
+	char tbuf[16];
+	struct net_device *dev =3D n->dev;
+	int hatype =3D dev->type;
=20
-	size =3D sprintf(buffer,"IP address       HW type     Flags       HW addr=
ess            Mask     Device\n");
-
-	pos+=3Dsize;
-	len+=3Dsize;
+	read_lock(&n->lock);
=20
-	for(i=3D0; i<=3DNEIGH_HASHMASK; i++) {
-		struct neighbour *n;
-		read_lock_bh(&arp_tbl.lock);
-		for (n=3Darp_tbl.hash_buckets[i]; n; n=3Dn->next) {
-			struct net_device *dev =3D n->dev;
-			int hatype =3D dev->type;
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
-			if (hatype =3D=3D ARPHRD_AX25 || hatype =3D=3D ARPHRD_NETROM)
-				ax2asc2((ax25_address *)n->ha, hbuffer);
-			else {
-#endif
-			for (k=3D0,j=3D0;k<HBUFFERLEN-3 && j<dev->addr_len;j++) {
-				hbuffer[k++]=3Dhexbuf[(n->ha[j]>>4)&15 ];
-				hbuffer[k++]=3Dhexbuf[n->ha[j]&15     ];
-				hbuffer[k++]=3D':';
-			}
-			hbuffer[--k]=3D0;
-
+	if (hatype =3D=3D ARPHRD_AX25 || hatype =3D=3D ARPHRD_NETROM)
+		ax2asc2((ax25_address *)n->ha, hbuffer);
+	else {
+#endif
+	for (k=3D0,j=3D0;k<HBUFFERLEN-3 && j<dev->addr_len;j++) {
+		hbuffer[k++]=3Dhexbuf[(n->ha[j]>>4)&15 ];
+		hbuffer[k++]=3Dhexbuf[n->ha[j]&15     ];
+		hbuffer[k++]=3D':';
+	}
+	hbuffer[--k]=3D0;
 #if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
-		}
+	}
 #endif
+	sprintf(tbuf, "%u.%u.%u.%u", NIPQUAD(*(u32*)n->primary_key));
+	seq_printf(seq, "%-16s 0x%-10x0x%-10x%s     *        %s\n",
+		   tbuf, hatype, arp_state_to_flags(n), hbuffer, dev->name);
+	read_unlock(&n->lock);
+}
=20
-			{
-				char tbuf[16];
-				sprintf(tbuf, "%u.%u.%u.%u", NIPQUAD(*(u32*)n->primary_key));
-				size =3D sprintf(buffer+len, "%-16s 0x%-10x0x%-10x%s"
-							"     *        %s\n",
-					tbuf,
-					hatype,
-					arp_state_to_flags(n),=20
-					hbuffer,
-					dev->name);
-			}
+static void arp_format_pneigh_entry(struct seq_file *seq,
+				    struct pneigh_entry *n)
+{
+	struct net_device *dev =3D n->dev;
+	int hatype =3D dev ? dev->type : 0;
+	char tbuf[16];
=20
-			read_unlock(&n->lock);
+	sprintf(tbuf, "%u.%u.%u.%u", NIPQUAD(*(u32*)n->key));
+	seq_printf(seq, "%-16s 0x%-10x0x%-10x%s     *        %s\n",
+		   tbuf, hatype, ATF_PUBL | ATF_PERM, "00:00:00:00:00:00",
+		   dev ? dev->name : "*");
+}
=20
-			len +=3D size;
-			pos +=3D size;
-		 =20
-			if (pos <=3D offset)
-				len=3D0;
-			if (pos >=3D offset+length) {
-				read_unlock_bh(&arp_tbl.lock);
- 				goto done;
-			}
-		}
-		read_unlock_bh(&arp_tbl.lock);
+static int arp_seq_show(struct seq_file *seq, void *v)
+{
+	if (v =3D=3D SEQ_START_TOKEN) {
+		seq_puts(seq, "IP address       HW type     Flags       "
+			      "HW address            Mask     Device\n");
+	} else {
+		struct neigh_seq_state *state =3D seq->private;
+
+		if (state->flags & NEIGH_SEQ_IS_PNEIGH)
+			arp_format_pneigh_entry(seq, v);
+		else
+			arp_format_neigh_entry(seq, v);
 	}
=20
-	for (i=3D0; i<=3DPNEIGH_HASHMASK; i++) {
-		struct pneigh_entry *n;
-		for (n=3Darp_tbl.phash_buckets[i]; n; n=3Dn->next) {
-			struct net_device *dev =3D n->dev;
-			int hatype =3D dev ? dev->type : 0;
-
-			{
-				char tbuf[16];
-				sprintf(tbuf, "%u.%u.%u.%u", NIPQUAD(*(u32*)n->key));
-				size =3D sprintf(buffer+len, "%-16s 0x%-10x0x%-10x%s"
-							"     *        %s\n",
-					tbuf,
-					hatype,
- 					ATF_PUBL|ATF_PERM,
-					"00:00:00:00:00:00",
-					dev ? dev->name : "*");
-			}
+	return 0;
+}
=20
-			len +=3D size;
-			pos +=3D size;
-		 =20
-			if (pos <=3D offset)
-				len=3D0;
-			if (pos >=3D offset+length)
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
+/* -----------------------------------------------------------------------=
- */
+
+static struct seq_operations arp_seq_ops =3D {
+	.start	=3D arp_seq_start,
+	.next	=3D neigh_seq_next,
+	.stop	=3D neigh_seq_stop,
+	.show	=3D arp_seq_show,
+};
+
+static int arp_seq_open(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq;
+	int rc =3D -ENOMEM;
+	struct neigh_seq_state *s =3D kmalloc(sizeof(*s), GFP_KERNEL);
+
+	if (!s)
+		goto out;
+
+	memset(s, 0, sizeof(*s));
+	rc =3D seq_open(file, &arp_seq_ops);
+	if (rc)
+		goto out_kfree;
=20
-done:
- =20
-	*start =3D buffer+len-(pos-offset);	/* Start of wanted data */
-	len =3D pos-offset;			/* Start slop */
-	if (len>length)
-		len =3D length;			/* Ending slop */
-	if (len<0)
-		len =3D 0;
-	return len;
+	seq =3D file->private_data;
+	seq->private =3D s;
+out:
+	return rc;
+out_kfree:
+	kfree(s);
+	goto out;
 }
-#endif
+
+static struct file_operations arp_seq_fops =3D {
+	.owner		=3D THIS_MODULE,
+	.open		=3D arp_seq_open,
+	.read		=3D seq_read,
+	.llseek		=3D seq_lseek,
+	.release	=3D seq_release_private,
+};
+#endif /* CONFIG_PROC_FS */
=20
 static int arp_netdev_event(struct notifier_block *this, unsigned long eve=
nt, void *ptr)
 {
@@ -1355,8 +1375,10 @@
=20
 	dev_add_pack(&arp_packet_type);
=20
-	proc_net_create ("arp", 0, arp_get_info);
-
+#ifdef CONFIG_PROC_FS
+	if (!proc_net_fops_create("arp", S_IRUGO, &arp_seq_fops))
+		panic("unable to create arp proc entry");
+#endif
 #ifdef CONFIG_SYSCTL
 	neigh_sysctl_register(NULL, &arp_tbl.parms, NET_IPV4, NET_IPV4_NEIGH, "ip=
v4");
 #endif
@@ -1364,39 +1386,3 @@
 }
=20
=20
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
-	for (n =3D 0, s =3D buf; n < 6; n++) {
-		c =3D (a->ax25_call[n] >> 1) & 0x7F;
-
-		if (c !=3D ' ') *s++ =3D c;
-	}
-=09
-	*s++ =3D '-';
-
-	if ((n =3D ((a->ax25_call[6] >> 1) & 0x0F)) > 9) {
-		*s++ =3D '1';
-		n -=3D 10;
-	}
-=09
-	*s++ =3D n + '0';
-	*s++ =3D '\0';
-
-	if (*buf =3D=3D '\0' || *buf =3D=3D '-')
-	   return "*";
-
-	return buf;
-
-}
-
-#endif
-#endif
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.4=
=2E28-pre3-bk5-plain/net/ipv4/route.c linux-2.4.28-pre3-bk5-neigh/net/ipv4/=
route.c
--- linux-2.4.28-pre3-bk5-plain/net/ipv4/route.c	2003-11-28 19:26:21.000000=
000 +0100
+++ linux-2.4.28-pre3-bk5-neigh/net/ipv4/route.c	2004-09-30 16:33:07.000000=
000 +0200
@@ -284,6 +284,7 @@
 	int i, lcpu;
 	int len =3D 0;
=20
+ 	len +=3D sprintf(buffer+len, "entries  in_hit in_slow_tot in_slow_mc in_=
no_route in_brd in_martian_dst in_martian_src  out_hit out_slow_tot out_slo=
w_mc  gc_total gc_ignored gc_goal_miss gc_dst_overflow in_hlist_search out_=
hlist_search\n");
         for (lcpu =3D 0; lcpu < smp_num_cpus; lcpu++) {
                 i =3D cpu_logical_map(lcpu);
=20
@@ -2625,7 +2626,8 @@
 	add_timer(&rt_secret_timer);
=20
 	proc_net_create ("rt_cache", 0, rt_cache_get_info);
-	proc_net_create ("rt_cache_stat", 0, rt_cache_stat_get_info);
+	create_proc_info_entry ("rt_cache", 0, proc_net_stat,=20
+				rt_cache_stat_get_info);
 #ifdef CONFIG_NET_CLS_ROUTE
 	create_proc_read_entry("net/rt_acct", 0, 0, ip_rt_acct_read, NULL);
 #endif
diff -Nru --exclude-from=3D/sunbeam/home/laforge/scripts/dontdiff linux-2.4=
=2E28-pre3-bk5-plain/net/ipv6/ndisc.c linux-2.4.28-pre3-bk5-neigh/net/ipv6/=
ndisc.c
--- linux-2.4.28-pre3-bk5-plain/net/ipv6/ndisc.c	2004-09-30 11:31:18.000000=
000 +0200
+++ linux-2.4.28-pre3-bk5-neigh/net/ipv6/ndisc.c	2004-09-30 16:12:47.000000=
000 +0200
@@ -60,6 +60,7 @@
 #include <linux/if_arp.h>
 #include <linux/ipv6.h>
 #include <linux/icmpv6.h>
+#include <linux/jhash.h>
=20
 #include <net/sock.h>
 #include <net/snmp.h>
@@ -240,15 +241,14 @@
=20
 static u32 ndisc_hash(const void *pkey, const struct net_device *dev)
 {
-	u32 hash_val;
+	const u32 *p32 =3D pkey;
+	u32 addr_hash, i;
=20
-	hash_val =3D *(u32*)(pkey + sizeof(struct in6_addr) - 4);
-	hash_val ^=3D (hash_val>>16);
-	hash_val ^=3D hash_val>>8;
-	hash_val ^=3D hash_val>>3;
-	hash_val =3D (hash_val^dev->ifindex)&NEIGH_HASHMASK;
+	addr_hash =3D 0;
+	for (i =3D 0; i < (sizeof(struct in6_addr) / sizeof(u32)); i++)
+		addr_hash ^=3D *p32++;
=20
-	return hash_val;
+	return jhash_2words(addr_hash, dev->ifindex, nd_tbl.hash_rnd);
 }
=20
 static int ndisc_constructor(struct neighbour *neigh)
@@ -696,9 +696,9 @@
 			int inc =3D ipv6_addr_type(daddr)&IPV6_ADDR_MULTICAST;
=20
 			if (inc)
-				nd_tbl.stats.rcv_probes_mcast++;
+				NEIGH_CACHE_STAT_INC(&nd_tbl, rcv_probes_mcast);
 			else
-				nd_tbl.stats.rcv_probes_ucast++;
+				NEIGH_CACHE_STAT_INC(&nd_tbl, rcv_probes_ucast);
=20
 			/*=20
 			 *	update / create cache entry
@@ -741,9 +741,9 @@
 		if (addr_type & IPV6_ADDR_UNICAST) {
 			int inc =3D ipv6_addr_type(daddr)&IPV6_ADDR_MULTICAST;
 			if (inc) =20
-				nd_tbl.stats.rcv_probes_mcast++;
+				NEIGH_CACHE_STAT_INC(&nd_tbl, rcv_probes_mcast);
  			else
-				nd_tbl.stats.rcv_probes_ucast++;
+				NEIGH_CACHE_STAT_INC(&nd_tbl, rcv_probes_ucast);
=20
 			/*
 			 *   update / create cache entry
@@ -775,9 +775,11 @@
 			    inc =3D=3D 0 ||
 			    in6_dev->nd_parms->proxy_delay =3D=3D 0) {
 				if (inc)
-					nd_tbl.stats.rcv_probes_mcast++;
+					NEIGH_CACHE_STAT_INC(&nd_tbl,=20
+							rcv_probes_mcast);
 				else
-					nd_tbl.stats.rcv_probes_ucast++;
+					NEIGH_CACHE_STAT_INC(&nd_tbl,=20
+							rcv_probes_ucast);
 				=09
 				neigh =3D neigh_event_ns(&nd_tbl, lladdr, saddr, dev);
=20

--7tPHY7RFL01rOa8z--

--+vcRm3WFmV0Q/ShD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBXCqpXaXGVTD0i/8RAqaQAJ9+HDM8zxG/9joEvip49uYGS3gybQCcCAFS
kPB1qiIT2RwLlSAgll2KfKI=
=E2L8
-----END PGP SIGNATURE-----

--+vcRm3WFmV0Q/ShD--
