From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] Convert ipvs to use seq_file.
Date: Mon, 15 Sep 2003 14:39:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030915143957.041689d8.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lvs-users@LinuxVirtualServer.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert IPVS (for 2.6.0-test5) to use seq_file for the /proc interface.
Got rid of gratuitous 64 column trailing blank padding.

P.s: how come there is no MAINTAINER listed for IPVS?

diff -urNp -X dontdiff linux-2.5/net/ipv4/ipvs/ip_vs_app.c linux-2.5-net/net/ipv4/ipvs/ip_vs_app.c
--- linux-2.5/net/ipv4/ipvs/ip_vs_app.c	2003-09-15 09:57:15.000000000 -0700
+++ linux-2.5-net/net/ipv4/ipvs/ip_vs_app.c	2003-09-15 10:30:18.000000000 -0700
@@ -35,6 +35,7 @@
 #include <asm/system.h>
 #include <linux/stat.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 
 #include <net/ip_vs.h>
 
@@ -480,55 +481,104 @@ int ip_vs_app_pkt_in(struct ip_vs_conn *
 }
 
 
+#ifdef CONFIG_PROC_FS
 /*
  *	/proc/net/ip_vs_app entry function
  */
-static int
-ip_vs_app_getinfo(char *buffer, char **start, off_t offset, int length)
+#define SEQ_START_TOKEN	((void *)1)
+
+static struct ip_vs_app *ip_vs_app_idx(loff_t pos)
 {
-	off_t pos=0;
-	int len=0;
-	char temp[64];
-	struct ip_vs_app *app, *inc;
+	loff_t off = 0;
 	struct list_head *e, *i;
 
-	pos = 64;
-	if (pos > offset) {
-		len += sprintf(buffer+len, "%-63s\n",
-			       "prot port    usecnt name");
+	list_for_each(e, &ip_vs_app_list) {
+		struct ip_vs_app *app
+			= list_entry(e, struct ip_vs_app, a_list);
+		list_for_each (i, &app->incs_list) {
+			if (off == pos)
+				return list_entry(i, struct ip_vs_app, a_list);
+			++off;
+		}	
 	}
+	return NULL;
+
+}
 
+static void *ip_vs_app_seq_start(struct seq_file *seq, loff_t *pos)
+{
 	down(&__ip_vs_app_mutex);
-	list_for_each (e, &ip_vs_app_list) {
+	
+	return *pos ? ip_vs_app_idx(*pos - 1) : SEQ_START_TOKEN;
+}
+
+static void *ip_vs_app_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct ip_vs_app *inc, *app;
+	struct list_head *i, *e;
+
+	++*pos;
+	if (v == SEQ_START_TOKEN)
+		return ip_vs_app_idx(0);
+	
+	inc = v;
+	app = inc->app;
+
+	if ((i = inc->a_list.next) != &app->incs_list)
+		return list_entry(i, struct ip_vs_app, a_list);
+
+	/* go on to next application */
+	for (e = app->a_list.next; e != &ip_vs_app_list; e = e->next) {
 		app = list_entry(e, struct ip_vs_app, a_list);
 		list_for_each (i, &app->incs_list) {
-			inc = list_entry(i, struct ip_vs_app, a_list);
-
-			pos += 64;
-			if (pos <= offset)
-				continue;
-			sprintf(temp, "%-3s  %-7u %-6d %-17s",
-				ip_vs_proto_name(inc->protocol),
-				ntohs(inc->port),
-				atomic_read(&inc->usecnt),
-				inc->name);
-			len += sprintf(buffer+len, "%-63s\n", temp);
-			if (pos >= offset+length)
-				goto done;
+			return list_entry(i, struct ip_vs_app, a_list);
 		}
 	}
-  done:
+	return NULL;
+}
+
+static void ip_vs_app_seq_stop(struct seq_file *seq, void *v)
+{
 	up(&__ip_vs_app_mutex);
+}
 
-	*start = buffer+len-(pos-offset);       /* Start of wanted data */
-	len = pos-offset;
-	if (len > length)
-		len = length;
-	if (len < 0)
-		len = 0;
-	return len;
+static int ip_vs_app_seq_show(struct seq_file *seq, void *v)
+{
+	if (v == SEQ_START_TOKEN)
+		seq_puts(seq, "prot port    usecnt name\n");
+	else {
+		const struct ip_vs_app *inc = v;
+
+		seq_printf(seq, "%-3s  %-7u %-6d %-17s\n",
+			   ip_vs_proto_name(inc->protocol),
+			   ntohs(inc->port),
+			   atomic_read(&inc->usecnt),
+			   inc->name);
+	}
+	return 0;
 }
 
+static struct seq_operations ip_vs_app_seq_ops = {
+	.start = ip_vs_app_seq_start,
+	.next  = ip_vs_app_seq_next,
+	.stop  = ip_vs_app_seq_stop,
+	.show  = ip_vs_app_seq_show,
+};
+
+static int ip_vs_app_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &ip_vs_app_seq_ops);
+}
+
+static struct file_operations ip_vs_app_fops = {
+	.owner	 = THIS_MODULE,
+	.open    = ip_vs_app_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release,
+};
+#endif
+
 
 /*
  *	Replace a segment of data with a new segment
@@ -577,7 +627,7 @@ int ip_vs_skb_replace(struct sk_buff *sk
 int ip_vs_app_init(void)
 {
 	/* we will replace it with proc_net_ipvs_create() soon */
-	proc_net_create("ip_vs_app", 0, ip_vs_app_getinfo);
+	proc_net_fops_create("ip_vs_app", 0, &ip_vs_app_fops);
 	return 0;
 }
 
diff -urNp -X dontdiff linux-2.5/net/ipv4/ipvs/ip_vs_conn.c linux-2.5-net/net/ipv4/ipvs/ip_vs_conn.c
--- linux-2.5/net/ipv4/ipvs/ip_vs_conn.c	2003-09-15 09:57:15.000000000 -0700
+++ linux-2.5-net/net/ipv4/ipvs/ip_vs_conn.c	2003-09-15 10:27:45.000000000 -0700
@@ -30,6 +30,7 @@
 #include <linux/compiler.h>
 #include <linux/vmalloc.h>
 #include <linux/proc_fs.h>		/* for proc_net_* */
+#include <linux/seq_file.h>
 #include <linux/jhash.h>
 #include <linux/random.h>
 
@@ -188,14 +189,13 @@ static inline struct ip_vs_conn *__ip_vs
 {
 	unsigned hash;
 	struct ip_vs_conn *cp;
-	struct list_head *l,*e;
+	struct list_head *e;
 
 	hash = ip_vs_conn_hashkey(protocol, s_addr, s_port);
-	l = &ip_vs_conn_tab[hash];
 
 	ct_read_lock(hash);
 
-	for (e=l->next; e!=l; e=e->next) {
+	list_for_each(e, &ip_vs_conn_tab[hash]) {
 		cp = list_entry(e, struct ip_vs_conn, c_list);
 		if (s_addr==cp->caddr && s_port==cp->cport &&
 		    d_port==cp->vport && d_addr==cp->vaddr &&
@@ -242,17 +242,16 @@ struct ip_vs_conn *ip_vs_conn_out_get
 {
 	unsigned hash;
 	struct ip_vs_conn *cp, *ret=NULL;
-	struct list_head *l,*e;
+	struct list_head *e;
 
 	/*
 	 *	Check for "full" addressed entries
 	 */
 	hash = ip_vs_conn_hashkey(protocol, d_addr, d_port);
-	l = &ip_vs_conn_tab[hash];
 
 	ct_read_lock(hash);
 
-	for (e=l->next; e!=l; e=e->next) {
+	list_for_each(e, &ip_vs_conn_tab[hash]) {
 		cp = list_entry(e, struct ip_vs_conn, c_list);
 		if (d_addr == cp->caddr && d_port == cp->cport &&
 		    s_port == cp->dport && s_addr == cp->daddr &&
@@ -615,61 +614,116 @@ ip_vs_conn_new(int proto, __u32 caddr, _
 /*
  *	/proc/net/ip_vs_conn entries
  */
-static int
-ip_vs_conn_getinfo(char *buffer, char **start, off_t offset, int length)
-{
-	off_t pos=0;
-	int idx, len=0;
-	char temp[70];
-	struct ip_vs_conn *cp;
-	struct list_head *l, *e;
+#ifdef CONFIG_PROC_FS
 
-	pos = 128;
-	if (pos > offset) {
-		len += sprintf(buffer+len, "%-127s\n",
-			       "Pro FromIP   FPrt ToIP     TPrt DestIP   DPrt State       Expires");
-	}
+#define SEQ_START_TOKEN	((void *)1)
 
+static void *ip_vs_conn_array(struct seq_file *seq, loff_t pos)
+{
+	struct list_head *e;
+	int idx;
+	loff_t off = 0;
+	
 	for(idx = 0; idx < IP_VS_CONN_TAB_SIZE; idx++) {
-		/*
-		 *	Lock is actually only need in next loop
-		 *	we are called from uspace: must stop bh.
-		 */
 		ct_read_lock_bh(idx);
+		list_for_each(e, &ip_vs_conn_tab[idx]) {
+			if (off == pos) {
+				seq->private = &ip_vs_conn_tab[idx];
+				return list_entry(e, struct ip_vs_conn, c_list);
+			}
+			++off;
+		}	
+		ct_read_unlock_bh(idx);
+	}
 
-		l = &ip_vs_conn_tab[idx];
-		for (e=l->next; e!=l; e=e->next) {
-			cp = list_entry(e, struct ip_vs_conn, c_list);
-			pos += 128;
-			if (pos <= offset)
-				continue;
-			sprintf(temp,
-				"%-3s %08X %04X %08X %04X %08X %04X %-11s %7lu",
+	return NULL;
+}
+
+static void *ip_vs_conn_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	seq->private = NULL;
+	return *pos ? ip_vs_conn_array(seq, *pos - 1) :SEQ_START_TOKEN;
+}
+
+static void *ip_vs_conn_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct ip_vs_conn *cp = v;
+	struct list_head *e, *l = seq->private;
+	int idx;
+
+	++*pos;
+	if (v == SEQ_START_TOKEN) 
+		return ip_vs_conn_array(seq, 0);
+
+	/* more on same hash chain? */
+	if ((e = cp->c_list.next) != l)
+		return list_entry(e, struct ip_vs_conn, c_list);
+
+	idx = l - ip_vs_conn_tab;
+	ct_read_unlock_bh(idx);
+
+	while (++idx < IP_VS_CONN_TAB_SIZE) {
+		ct_read_lock_bh(idx);
+		list_for_each(e, &ip_vs_conn_tab[idx]) {
+			seq->private = &ip_vs_conn_tab[idx];
+			return list_entry(e, struct ip_vs_conn, c_list);
+		}	
+		ct_read_unlock_bh(idx);
+	}
+	seq->private = NULL;
+	return NULL;
+}
+
+static void ip_vs_conn_seq_stop(struct seq_file *seq, void *v)
+{
+	struct list_head *l = seq->private;
+
+	if (l) 
+		ct_read_unlock(l - ip_vs_conn_tab);
+}
+
+static int ip_vs_conn_seq_show(struct seq_file *seq, void *v)
+{
+
+	if (v == SEQ_START_TOKEN)
+		seq_puts(seq,
+   "Pro FromIP   FPrt ToIP     TPrt DestIP   DPrt State       Expires\n");
+	else {
+		const struct ip_vs_conn *cp = v;
+
+		seq_printf(seq,
+			"%-3s %08X %04X %08X %04X %08X %04X %-11s %7lu\n",
 				ip_vs_proto_name(cp->protocol),
 				ntohl(cp->caddr), ntohs(cp->cport),
 				ntohl(cp->vaddr), ntohs(cp->vport),
 				ntohl(cp->daddr), ntohs(cp->dport),
 				ip_vs_state_name(cp->protocol, cp->state),
 				(cp->timer.expires-jiffies)/HZ);
-			len += sprintf(buffer+len, "%-127s\n", temp);
-			if (pos >= offset+length) {
-				ct_read_unlock_bh(idx);
-				goto done;
-			}
-		}
-		ct_read_unlock_bh(idx);
 	}
-
-  done:
-	*start = buffer+len-(pos-offset);       /* Start of wanted data */
-	len = pos-offset;
-	if (len > length)
-		len = length;
-	if (len < 0)
-		len = 0;
-	return len;
+	return 0;
 }
 
+static struct seq_operations ip_vs_conn_seq_ops = {
+	.start = ip_vs_conn_seq_start,
+	.next  = ip_vs_conn_seq_next,
+	.stop  = ip_vs_conn_seq_stop,
+	.show  = ip_vs_conn_seq_show,
+};
+
+static int ip_vs_conn_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &ip_vs_conn_seq_ops);
+}
+
+static struct file_operations ip_vs_conn_fops = {
+	.owner	 = THIS_MODULE,
+	.open    = ip_vs_conn_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release,
+};
+#endif
+
 
 /*
  *      Randomly drop connection entries before running out of memory
@@ -707,7 +761,7 @@ void ip_vs_random_dropentry(void)
 {
 	int idx;
 	struct ip_vs_conn *cp;
-	struct list_head *l,*e;
+	struct list_head *e;
 	struct ip_vs_conn *ct;
 
 	/*
@@ -721,8 +775,7 @@ void ip_vs_random_dropentry(void)
 		 */
 		ct_write_lock(hash);
 
-		l = &ip_vs_conn_tab[hash];
-		for (e=l->next; e!=l; e=e->next) {
+		list_for_each(e, &ip_vs_conn_tab[hash]) {
 			cp = list_entry(e, struct ip_vs_conn, c_list);
 			if (!cp->cport && !(cp->flags & IP_VS_CONN_F_NO_CPORT))
 				/* connection template */
@@ -775,7 +828,7 @@ static void ip_vs_conn_flush(void)
 {
 	int idx;
 	struct ip_vs_conn *cp;
-	struct list_head *l,*e;
+	struct list_head *e;
 	struct ip_vs_conn *ct;
 
   flush_again:
@@ -785,8 +838,7 @@ static void ip_vs_conn_flush(void)
 		 */
 		ct_write_lock_bh(idx);
 
-		l = &ip_vs_conn_tab[idx];
-		for (e=l->next; e!=l; e=e->next) {
+		list_for_each(e, &ip_vs_conn_tab[idx]) {
 			cp = list_entry(e, struct ip_vs_conn, c_list);
 			atomic_inc(&cp->refcnt);
 			ct_write_unlock(idx);
@@ -848,7 +900,7 @@ int ip_vs_conn_init(void)
 		__ip_vs_conntbl_lock_array[idx].l = RW_LOCK_UNLOCKED;
 	}
 
-	proc_net_create("ip_vs_conn", 0, ip_vs_conn_getinfo);
+	proc_net_fops_create("ip_vs_conn", 0, &ip_vs_conn_fops);
 
 	/* calculate the random value for connection hash */
 	get_random_bytes(&ip_vs_conn_rnd, sizeof(ip_vs_conn_rnd));
diff -urNp -X dontdiff linux-2.5/net/ipv4/ipvs/ip_vs_ctl.c linux-2.5-net/net/ipv4/ipvs/ip_vs_ctl.c
--- linux-2.5/net/ipv4/ipvs/ip_vs_ctl.c	2003-09-15 09:57:15.000000000 -0700
+++ linux-2.5-net/net/ipv4/ipvs/ip_vs_ctl.c	2003-09-15 12:52:15.000000000 -0700
@@ -31,6 +31,8 @@
 #include <linux/proc_fs.h>
 #include <linux/timer.h>
 #include <linux/swap.h>
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
@@ -1507,207 +1509,253 @@ static struct ip_vs_sysctl_table ipv4_vs
 	 {0}}
 };
 
+#ifdef CONFIG_PROC_FS
+
+struct ip_vs_iter {
+	struct list_head *table;
+	int bucket;
+};
 
+
+#define SEQ_START_TOKEN	((void *)1)
 /*
  *	Write the contents of the VS rule table to a PROCfs file.
  *	(It is kept just for backward compatibility)
  */
-static inline char *ip_vs_fwd_name(unsigned flags)
+static inline const char *ip_vs_fwd_name(unsigned flags)
 {
-	char *fwd;
-
 	switch (flags & IP_VS_CONN_F_FWD_MASK) {
 	case IP_VS_CONN_F_LOCALNODE:
-		fwd = "Local";
-		break;
+		return "Local";
 	case IP_VS_CONN_F_TUNNEL:
-		fwd = "Tunnel";
-		break;
+		return "Tunnel";
 	case IP_VS_CONN_F_DROUTE:
-		fwd = "Route";
-		break;
+		return "Route";
 	default:
-		fwd = "Masq";
+		return "Masq";
 	}
-	return fwd;
 }
 
-static inline int sprintf_dest(char *str, struct ip_vs_dest *dest)
-{
-	return sprintf(str, "  -> %08X:%04X      %-7s %-6d %-10d %-10d",
-		       ntohl(dest->addr), ntohs(dest->port),
-		       ip_vs_fwd_name(atomic_read(&dest->conn_flags)),
-		       atomic_read(&dest->weight),
-		       atomic_read(&dest->activeconns),
-		       atomic_read(&dest->inactconns));
-}
 
-static int ip_vs_get_info(char *buf, char **start, off_t offset, int length)
+/* Get the Nth entry in the two lists */
+static struct ip_vs_service *ip_vs_info_array(struct seq_file *seq, loff_t pos)
 {
-	int len=0;
-	off_t pos=0;
-	char temp[64], temp2[32];
+	struct ip_vs_iter *iter = seq->private;
 	int idx;
-	struct ip_vs_service *svc;
-	struct ip_vs_dest *dest;
-	struct list_head *l, *e, *p, *q;
-
-	/*
-	 * Note: since the length of the buffer is usually the multiple
-	 * of 512, it is good to use fixed record of the divisor of 512,
-	 * so that records won't be truncated at buffer boundary.
-	 */
-	pos = 192;
-	if (pos > offset) {
-		sprintf(temp,
-			"IP Virtual Server version %d.%d.%d (size=%d)",
-			NVERSION(IP_VS_VERSION_CODE), IP_VS_CONN_TAB_SIZE);
-		len += sprintf(buf+len, "%-63s\n", temp);
-		len += sprintf(buf+len, "%-63s\n",
-			       "Prot LocalAddress:Port Scheduler Flags");
-		len += sprintf(buf+len, "%-63s\n",
-			       "  -> RemoteAddress:Port Forward Weight ActiveConn InActConn");
-	}
+	struct list_head *e;
 
-	read_lock_bh(&__ip_vs_svc_lock);
-
-	/* print the service table hashed by <protocol,addr,port> */
+	/* look in hash by protocol */
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		l = &ip_vs_svc_table[idx];
-		for (e=l->next; e!=l; e=e->next) {
-			svc = list_entry(e, struct ip_vs_service, s_list);
-			pos += 64;
-			if (pos > offset) {
-				if (svc->flags & IP_VS_SVC_F_PERSISTENT)
-					sprintf(temp2, "persistent %d %08X",
-						svc->timeout,
-						ntohl(svc->netmask));
-				else
-					temp2[0] = '\0';
-
-				sprintf(temp, "%s  %08X:%04X %s %s",
-					ip_vs_proto_name(svc->protocol),
-					ntohl(svc->addr),
-					ntohs(svc->port),
-					svc->scheduler->name, temp2);
-				len += sprintf(buf+len, "%-63s\n", temp);
-				if (len >= length)
-					goto done;
-			}
-
-			p = &svc->destinations;
-			for (q=p->next; q!=p; q=q->next) {
-				dest = list_entry(q, struct ip_vs_dest, n_list);
-				pos += 64;
-				if (pos <= offset)
-					continue;
-				sprintf_dest(temp, dest);
-				len += sprintf(buf+len, "%-63s\n", temp);
-				if (len >= length)
-					goto done;
+		list_for_each(e, &ip_vs_svc_table[idx]) {
+			if (pos-- == 0){
+				iter->table = ip_vs_svc_table;
+				iter->bucket = idx;
+				return list_entry(e, struct ip_vs_service, s_list);
 			}
 		}
 	}
 
-	/* print the service table hashed by fwmark */
+	/* keep looking in fwmark */
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		l = &ip_vs_svc_fwm_table[idx];
-		for (e=l->next; e!=l; e=e->next) {
-			svc = list_entry(e, struct ip_vs_service, f_list);
-			pos += 64;
-			if (pos > offset) {
-				if (svc->flags & IP_VS_SVC_F_PERSISTENT)
-					sprintf(temp2, "persistent %d %08X",
-						svc->timeout,
-						ntohl(svc->netmask));
-				else
-					temp2[0] = '\0';
-
-				sprintf(temp, "FWM  %08X %s %s",
-					svc->fwmark,
-					svc->scheduler->name, temp2);
-				len += sprintf(buf+len, "%-63s\n", temp);
-				if (len >= length)
-					goto done;
+		list_for_each(e, &ip_vs_svc_fwm_table[idx]) {
+			if (pos-- == 0) {
+				iter->table = ip_vs_svc_fwm_table;
+				iter->bucket = idx;
+				return list_entry(e, struct ip_vs_service, f_list);
 			}
+		}
+	}
+
+	return NULL;
+}
 
-			p = &svc->destinations;
-			for (q=p->next; q!=p; q=q->next) {
-				dest = list_entry(q, struct ip_vs_dest, n_list);
-				pos += 64;
-				if (pos <= offset)
-					continue;
-				sprintf_dest(temp, dest);
-				len += sprintf(buf+len, "%-63s\n", temp);
-				if (len >= length)
-					goto done;
+static void *ip_vs_info_seq_start(struct seq_file *seq, loff_t *pos)
+{
+
+	read_lock_bh(&__ip_vs_svc_lock);
+	return *pos ? ip_vs_info_array(seq, *pos - 1) : SEQ_START_TOKEN;
+}
+
+
+static void *ip_vs_info_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct list_head *e;
+	struct ip_vs_iter *iter;
+	struct ip_vs_service *svc;
+
+	++*pos;
+	if (v == SEQ_START_TOKEN)
+		return ip_vs_info_array(seq,0);
+	
+	svc = v;
+	iter = seq->private;
+	
+	if (iter->table == ip_vs_svc_table) {
+		/* next service in table hashed by protocol */
+		if ((e = svc->s_list.next) != &ip_vs_svc_table[iter->bucket])
+			return list_entry(e, struct ip_vs_service, s_list);
+
+
+		while (++iter->bucket < IP_VS_SVC_TAB_SIZE) {
+			list_for_each(e, &ip_vs_svc_table[iter->bucket]) {
+				return list_entry(e, struct ip_vs_service, s_list);
 			}
 		}
+
+		iter->table = ip_vs_svc_fwm_table;
+		iter->bucket = -1;
+		goto scan_fwmark;
 	}
 
-  done:
+	/* next service in hashed by fwmark */
+	if ((e = svc->f_list.next) != &ip_vs_svc_fwm_table[iter->bucket])
+		return list_entry(e, struct ip_vs_service, f_list);
+
+ scan_fwmark:
+	while (++iter->bucket < IP_VS_SVC_TAB_SIZE) {
+		list_for_each(e, &ip_vs_svc_fwm_table[iter->bucket]) 
+			return list_entry(e, struct ip_vs_service, f_list);
+	}
+
+	return NULL;
+}
+
+static void ip_vs_info_seq_stop(struct seq_file *seq, void *v)
+{
 	read_unlock_bh(&__ip_vs_svc_lock);
+}
+
+
+static int ip_vs_info_seq_show(struct seq_file *seq, void *v)
+{
+	if (v == SEQ_START_TOKEN) {
+		seq_printf(seq,
+			"IP Virtual Server version %d.%d.%d (size=%d)\n",
+			NVERSION(IP_VS_VERSION_CODE), IP_VS_CONN_TAB_SIZE);
+		seq_puts(seq,
+			 "Prot LocalAddress:Port Scheduler Flags\n");
+		seq_puts(seq,
+			 "  -> RemoteAddress:Port Forward Weight ActiveConn InActConn\n");
+	} else {
+		const struct ip_vs_service *svc = v;
+		const struct ip_vs_iter *iter = seq->private;
+		const struct ip_vs_dest *dest;
+
+		if (iter->table == ip_vs_svc_table) 
+			seq_printf(seq, "%s  %08X:%04X %s ",
+				   ip_vs_proto_name(svc->protocol),
+				   ntohl(svc->addr),
+				   ntohs(svc->port),
+				   svc->scheduler->name);
+		else
+			seq_printf(seq, "FWM  %08X %s ",
+				   svc->fwmark, svc->scheduler->name);
+
+		if (svc->flags & IP_VS_SVC_F_PERSISTENT)
+			seq_printf(seq, "persistent %d %08X\n",
+				svc->timeout,
+				ntohl(svc->netmask));
+		else
+			seq_putc(seq, '\n');
 
-	*start = buf+len-(pos-offset);          /* Start of wanted data */
-	len = pos-offset;
-	if (len > length)
-		len = length;
-	if (len < 0)
-		len = 0;
-	return len;
+		list_for_each_entry(dest, &svc->destinations, n_list) {
+			seq_printf(seq, 
+				   "  -> %08X:%04X      %-7s %-6d %-10d %-10d\n",
+				   ntohl(dest->addr), ntohs(dest->port),
+				   ip_vs_fwd_name(atomic_read(&dest->conn_flags)),
+				   atomic_read(&dest->weight),
+				   atomic_read(&dest->activeconns),
+				   atomic_read(&dest->inactconns));
+		}
+	}
+	return 0;
 }
 
+static struct seq_operations ip_vs_info_seq_ops = {
+	.start = ip_vs_info_seq_start,
+	.next  = ip_vs_info_seq_next,
+	.stop  = ip_vs_info_seq_stop,
+	.show  = ip_vs_info_seq_show,
+};
+
+static int ip_vs_info_open(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq;
+	int rc = -ENOMEM;
+	struct ip_vs_iter *s = kmalloc(sizeof(*s), GFP_KERNEL);
+
+	if (!s)
+		goto out;
+
+	rc = seq_open(file, &ip_vs_info_seq_ops);
+	if (rc)
+		goto out_kfree;
+
+	seq	     = file->private_data;
+	seq->private = s;
+	memset(s, 0, sizeof(*s));
+out:
+	return rc;
+out_kfree:
+	kfree(s);
+	goto out;
+}
+
+static struct file_operations ip_vs_info_fops = {
+	.owner	 = THIS_MODULE,
+	.open    = ip_vs_info_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release_private,
+};
+
+#endif
 
 struct ip_vs_stats ip_vs_stats;
 
-static int
-ip_vs_stats_get_info(char *buf, char **start, off_t offset, int length)
+#ifdef CONFIG_PROC_FS
+static int ip_vs_stats_show(struct seq_file *seq, void *v)
 {
-	int len=0;
-	off_t pos=0;
-	char temp[64];
-
-	pos += 320;
-	if (pos > offset) {
-		len += sprintf(buf+len, "%-63s\n%-63s\n",
-/*                              01234567 01234567 01234567 0123456701234567 0123456701234567 */
-			       "   Total Incoming Outgoing         Incoming         Outgoing",
-			       "   Conns  Packets  Packets            Bytes            Bytes");
-
-		spin_lock_bh(&ip_vs_stats.lock);
-		sprintf(temp, "%8X %8X %8X %8X%08X %8X%08X",
-			ip_vs_stats.conns,
-			ip_vs_stats.inpkts,
-			ip_vs_stats.outpkts,
-			(__u32)(ip_vs_stats.inbytes>>32),
-			(__u32)ip_vs_stats.inbytes,
-			(__u32)(ip_vs_stats.outbytes>>32),
-			(__u32)ip_vs_stats.outbytes);
-		len += sprintf(buf+len, "%-62s\n\n", temp);
-
-		len += sprintf(buf+len, "%-63s\n",
-/*                              01234567 01234567 01234567 0123456701234567 0123456701234567 */
-			       " Conns/s   Pkts/s   Pkts/s          Bytes/s          Bytes/s");
-		sprintf(temp, "%8X %8X %8X %16X %16X",
+
+/*               01234567 01234567 01234567 0123456701234567 0123456701234567 */
+	seq_puts(seq,
+		 "   Total Incoming Outgoing         Incoming         Outgoing\n");
+	seq_printf(seq, 	   
+		   "   Conns  Packets  Packets            Bytes            Bytes\n");
+
+	spin_lock_bh(&ip_vs_stats.lock);
+	seq_printf(seq, "%8X %8X %8X %16LX %16LX\n\n", ip_vs_stats.conns,
+		   ip_vs_stats.inpkts, ip_vs_stats.outpkts,
+		   ip_vs_stats.inbytes, ip_vs_stats.outbytes);
+
+/*                 01234567 01234567 01234567 0123456701234567 0123456701234567 */
+	seq_puts(seq,
+		   " Conns/s   Pkts/s   Pkts/s          Bytes/s          Bytes/s\n");
+	seq_printf(seq,"%8X %8X %8X %16X %16X\n",
 			ip_vs_stats.cps,
 			ip_vs_stats.inpps,
 			ip_vs_stats.outpps,
 			ip_vs_stats.inbps,
 			ip_vs_stats.outbps);
-		len += sprintf(buf+len, "%-63s\n", temp);
+	spin_unlock_bh(&ip_vs_stats.lock);
 
-		spin_unlock_bh(&ip_vs_stats.lock);
-	}
+	return 0;
+}
 
-	*start = buf+len-(pos-offset);          /* Start of wanted data */
-	len = pos-offset;
-	if (len > length)
-		len = length;
-	if (len < 0)
-		len = 0;
-	return len;
+static int ip_vs_stats_seq_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, ip_vs_stats_show, NULL);
 }
 
+static struct file_operations ip_vs_stats_fops = {
+	.owner = THIS_MODULE,
+	.open = ip_vs_stats_seq_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+#endif
 
 /*
  *	Set timeout values for tcp tcpfin udp in the timeout_table.
@@ -2195,8 +2243,8 @@ int ip_vs_control_init(void)
 		return ret;
 	}
 
-	proc_net_create("ip_vs", 0, ip_vs_get_info);
-	proc_net_create("ip_vs_stats", 0, ip_vs_stats_get_info);
+	proc_net_fops_create("ip_vs", 0, &ip_vs_info_fops);
+	proc_net_fops_create("ip_vs_stats",0, &ip_vs_stats_fops);
 
 	ipv4_vs_table.sysctl_header =
 		register_sysctl_table(ipv4_vs_table.root_dir, 0);
