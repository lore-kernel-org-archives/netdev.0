From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/6) ipvs -- use list_for_each_entry macro's
Date: Tue, 16 Sep 2003 14:17:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030916141750.53bbb04e.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Wensong Zhang
 <wensong@linux-vs.org>, lvs-users@LinuxVirtualServer.org,
   netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

There are many places where list_for_each_entry macro can be used in IPVS
code.

diff -Nru a/net/ipv4/ipvs/ip_vs_app.c b/net/ipv4/ipvs/ip_vs_app.c
--- a/net/ipv4/ipvs/ip_vs_app.c	Tue Sep 16 14:08:39 2003
+++ b/net/ipv4/ipvs/ip_vs_app.c	Tue Sep 16 14:08:39 2003
@@ -214,18 +214,14 @@
  */
 void unregister_ip_vs_app(struct ip_vs_app *app)
 {
-	struct ip_vs_app *inc;
-	struct list_head *l = &app->incs_list;
+	struct ip_vs_app *inc, *nxt;
 
 	down(&__ip_vs_app_mutex);
 
-	while (l->next != l) {
-		inc = list_entry(l->next, struct ip_vs_app, a_list);
+	list_for_each_entry_safe(inc, nxt, &app->incs_list, a_list) {
 		ip_vs_app_inc_release(inc);
 	}
 
-	list_del(&app->a_list);
-
 	up(&__ip_vs_app_mutex);
 
 	/* decrease the module use count */
@@ -239,13 +235,11 @@
  */
 struct ip_vs_app *ip_vs_app_get_by_name(char *appname)
 {
-	struct list_head *p;
 	struct ip_vs_app *app, *a = NULL;
 
 	down(&__ip_vs_app_mutex);
 
-	list_for_each (p, &ip_vs_app_list) {
-		app = list_entry(p, struct ip_vs_app, a_list);
+	list_for_each_entry(ent, &ip_vs_app_list, a_list) {
 		if (strcmp(app->name, appname))
 			continue;
 
@@ -485,18 +479,15 @@
 /*
  *	/proc/net/ip_vs_app entry function
  */
+
 static struct ip_vs_app *ip_vs_app_idx(loff_t pos)
 {
-	loff_t off = 0;
-	struct list_head *e, *i;
+	struct ip_vs_app *app, *inc;
 
-	list_for_each(e, &ip_vs_app_list) {
-		struct ip_vs_app *app
-			= list_entry(e, struct ip_vs_app, a_list);
-		list_for_each (i, &app->incs_list) {
-			if (off == pos)
-				return list_entry(i, struct ip_vs_app, a_list);
-			++off;
+	list_for_each_entry(app, &ip_vs_app_list, a_list) {
+		list_for_each_entry(inc, &app->incs_list, a_list) {
+			if (pos-- == 0)
+				return inc;
 		}	
 	}
 	return NULL;
@@ -513,7 +504,7 @@
 static void *ip_vs_app_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct ip_vs_app *inc, *app;
-	struct list_head *i, *e;
+	struct list_head *e;
 
 	++*pos;
 	if (v == SEQ_START_TOKEN)
@@ -522,14 +513,14 @@
 	inc = v;
 	app = inc->app;
 
-	if ((i = inc->a_list.next) != &app->incs_list)
-		return list_entry(i, struct ip_vs_app, a_list);
+	if ((e = inc->a_list.next) != &app->incs_list)
+		return list_entry(e, struct ip_vs_app, a_list);
 
 	/* go on to next application */
 	for (e = app->a_list.next; e != &ip_vs_app_list; e = e->next) {
 		app = list_entry(e, struct ip_vs_app, a_list);
-		list_for_each (i, &app->incs_list) {
-			return list_entry(i, struct ip_vs_app, a_list);
+		list_for_each_entry(inc, &app->incs_list, a_list) {
+			return inc;
 		}
 	}
 	return NULL;
diff -Nru a/net/ipv4/ipvs/ip_vs_conn.c b/net/ipv4/ipvs/ip_vs_conn.c
--- a/net/ipv4/ipvs/ip_vs_conn.c	Tue Sep 16 14:08:39 2003
+++ b/net/ipv4/ipvs/ip_vs_conn.c	Tue Sep 16 14:08:39 2003
@@ -189,14 +189,12 @@
 {
 	unsigned hash;
 	struct ip_vs_conn *cp;
-	struct list_head *e;
 
 	hash = ip_vs_conn_hashkey(protocol, s_addr, s_port);
 
 	ct_read_lock(hash);
 
-	list_for_each(e, &ip_vs_conn_tab[hash]) {
-		cp = list_entry(e, struct ip_vs_conn, c_list);
+	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
 		if (s_addr==cp->caddr && s_port==cp->cport &&
 		    d_port==cp->vport && d_addr==cp->vaddr &&
 		    protocol==cp->protocol) {
@@ -242,7 +240,6 @@
 {
 	unsigned hash;
 	struct ip_vs_conn *cp, *ret=NULL;
-	struct list_head *e;
 
 	/*
 	 *	Check for "full" addressed entries
@@ -251,8 +248,7 @@
 
 	ct_read_lock(hash);
 
-	list_for_each(e, &ip_vs_conn_tab[hash]) {
-		cp = list_entry(e, struct ip_vs_conn, c_list);
+	list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
 		if (d_addr == cp->caddr && d_port == cp->cport &&
 		    s_port == cp->dport && s_addr == cp->daddr &&
 		    protocol == cp->protocol) {
@@ -618,19 +614,17 @@
 
 static void *ip_vs_conn_array(struct seq_file *seq, loff_t pos)
 {
-	struct list_head *e;
 	int idx;
-	loff_t off = 0;
+	struct ip_vs_conn *cp;
 	
 	for(idx = 0; idx < IP_VS_CONN_TAB_SIZE; idx++) {
 		ct_read_lock_bh(idx);
-		list_for_each(e, &ip_vs_conn_tab[idx]) {
-			if (off == pos) {
+		list_for_each_entry(cp, &ip_vs_conn_tab[idx], c_list) {
+			if (pos-- == 0) {
 				seq->private = &ip_vs_conn_tab[idx];
-				return list_entry(e, struct ip_vs_conn, c_list);
+				return cp;
 			}
-			++off;
-		}	
+		}
 		ct_read_unlock_bh(idx);
 	}
 
@@ -662,9 +656,9 @@
 
 	while (++idx < IP_VS_CONN_TAB_SIZE) {
 		ct_read_lock_bh(idx);
-		list_for_each(e, &ip_vs_conn_tab[idx]) {
+		list_for_each_entry(cp, &ip_vs_conn_tab[idx], c_list) {
 			seq->private = &ip_vs_conn_tab[idx];
-			return list_entry(e, struct ip_vs_conn, c_list);
+			return cp;
 		}	
 		ct_read_unlock_bh(idx);
 	}
@@ -769,7 +763,6 @@
 {
 	int idx;
 	struct ip_vs_conn *cp;
-	struct list_head *e;
 	struct ip_vs_conn *ct;
 
 	/*
@@ -783,8 +776,7 @@
 		 */
 		ct_write_lock(hash);
 
-		list_for_each(e, &ip_vs_conn_tab[hash]) {
-			cp = list_entry(e, struct ip_vs_conn, c_list);
+		list_for_each_entry(cp, &ip_vs_conn_tab[hash], c_list) {
 			if (!cp->cport && !(cp->flags & IP_VS_CONN_F_NO_CPORT))
 				/* connection template */
 				continue;
@@ -836,7 +828,6 @@
 {
 	int idx;
 	struct ip_vs_conn *cp;
-	struct list_head *e;
 	struct ip_vs_conn *ct;
 
   flush_again:
@@ -846,8 +837,7 @@
 		 */
 		ct_write_lock_bh(idx);
 
-		list_for_each(e, &ip_vs_conn_tab[idx]) {
-			cp = list_entry(e, struct ip_vs_conn, c_list);
+		list_for_each_entry(cp, &ip_vs_conn_tab[idx], c_list) {
 			atomic_inc(&cp->refcnt);
 			ct_write_unlock(idx);
 
diff -Nru a/net/ipv4/ipvs/ip_vs_ctl.c b/net/ipv4/ipvs/ip_vs_ctl.c
--- a/net/ipv4/ipvs/ip_vs_ctl.c	Tue Sep 16 14:08:39 2003
+++ b/net/ipv4/ipvs/ip_vs_ctl.c	Tue Sep 16 14:08:39 2003
@@ -279,7 +279,7 @@
 static __inline__ unsigned
 ip_vs_svc_hashkey(unsigned proto, __u32 addr, __u16 port)
 {
-	unsigned porth = ntohs(port);
+	register unsigned porth = ntohs(port);
 
 	return (proto^ntohl(addr)^(porth>>IP_VS_SVC_TAB_BITS)^porth)
 		& IP_VS_SVC_TAB_MASK;
@@ -363,14 +363,11 @@
 {
 	unsigned hash;
 	struct ip_vs_service *svc;
-	struct list_head *l,*e;
 
 	/* Check for "full" addressed entries */
 	hash = ip_vs_svc_hashkey(protocol, vaddr, vport);
 
-	l = &ip_vs_svc_table[hash];
-	for (e=l->next; e!=l; e=e->next) {
-		svc = list_entry(e, struct ip_vs_service, s_list);
+	list_for_each_entry(svc, &ip_vs_svc_table[hash], s_list){
 		if ((svc->addr == vaddr)
 		    && (svc->port == vport)
 		    && (svc->protocol == protocol)) {
@@ -391,14 +388,11 @@
 {
 	unsigned hash;
 	struct ip_vs_service *svc;
-	struct list_head *l,*e;
 
 	/* Check for fwmark addressed entries */
 	hash = ip_vs_svc_fwm_hashkey(fwmark);
 
-	l = &ip_vs_svc_fwm_table[hash];
-	for (e=l->next; e!=l; e=e->next) {
-		svc = list_entry(e, struct ip_vs_service, f_list);
+	list_for_each_entry(svc, &ip_vs_svc_fwm_table[hash], f_list) {
 		if (svc->fwmark == fwmark) {
 			/* HIT */
 			atomic_inc(&svc->usecnt);
@@ -482,7 +476,7 @@
  */
 static __inline__ unsigned ip_vs_rs_hashkey(__u32 addr, __u16 port)
 {
-	unsigned porth = ntohs(port);
+	register unsigned porth = ntohs(port);
 
 	return (ntohl(addr)^(porth>>IP_VS_RTAB_BITS)^porth)
 		& IP_VS_RTAB_MASK;
@@ -535,7 +529,6 @@
 {
 	unsigned hash;
 	struct ip_vs_dest *dest;
-	struct list_head *l,*e;
 
 	/*
 	 *	Check for "full" addressed entries
@@ -543,11 +536,8 @@
 	 */
 	hash = ip_vs_rs_hashkey(daddr, dport);
 
-	l = &ip_vs_rtable[hash];
-
 	read_lock(&__ip_vs_rs_lock);
-	for (e=l->next; e!=l; e=e->next) {
-		dest = list_entry(e, struct ip_vs_dest, d_list);
+	list_for_each_entry(dest, &ip_vs_rtable[hash], d_list) {
 		if ((dest->addr == daddr)
 		    && (dest->port == dport)
 		    && ((dest->protocol == protocol) ||
@@ -569,14 +559,11 @@
 ip_vs_lookup_dest(struct ip_vs_service *svc, __u32 daddr, __u16 dport)
 {
 	struct ip_vs_dest *dest;
-	struct list_head *l, *e;
 
 	/*
 	 * Find the destination for the given service
 	 */
-	l = &svc->destinations;
-	for (e=l->next; e!=l; e=e->next) {
-		dest = list_entry(e, struct ip_vs_dest, n_list);
+	list_for_each_entry(dest, &svc->destinations, n_list) {
 		if ((dest->addr == daddr) && (dest->port == dport)) {
 			/* HIT */
 			return dest;
@@ -600,16 +587,12 @@
 static struct ip_vs_dest *
 ip_vs_trash_get_dest(struct ip_vs_service *svc, __u32 daddr, __u16 dport)
 {
-	struct ip_vs_dest *dest;
-	struct list_head *l, *e;
+	struct ip_vs_dest *dest, *nxt;
 
 	/*
 	 * Find the destination in trash
 	 */
-	l = &ip_vs_dest_trash;
-
-	for (e=l->next; e!=l; e=e->next) {
-		dest = list_entry(e, struct ip_vs_dest, n_list);
+	list_for_each_entry_safe(dest, nxt, &ip_vs_dest_trash, n_list) {
 		IP_VS_DBG(3, "Destination %u/%u.%u.%u.%u:%u still in trash, "
 			  "refcnt=%d\n",
 			  dest->vfwmark,
@@ -634,7 +617,6 @@
 				  "from trash\n",
 				  dest->vfwmark,
 				  NIPQUAD(dest->addr), ntohs(dest->port));
-			e = e->prev;
 			list_del(&dest->n_list);
 			ip_vs_dst_reset(dest);
 			__ip_vs_unbind_svc(dest);
@@ -657,13 +639,9 @@
  */
 static void ip_vs_trash_cleanup(void)
 {
-	struct ip_vs_dest *dest;
-	struct list_head *l;
-
-	l = &ip_vs_dest_trash;
+	struct ip_vs_dest *dest, *nxt;
 
-	while (l->next != l) {
-		dest = list_entry(l->next, struct ip_vs_dest, n_list);
+	list_for_each_entry_safe(dest, nxt, &ip_vs_dest_trash, n_list) {
 		list_del(&dest->n_list);
 		ip_vs_dst_reset(dest);
 		__ip_vs_unbind_svc(dest);
@@ -1198,8 +1176,7 @@
  */
 static void __ip_vs_del_service(struct ip_vs_service *svc)
 {
-	struct list_head *l;
-	struct ip_vs_dest *dest;
+	struct ip_vs_dest *dest, *nxt;
 	struct ip_vs_scheduler *old_sched;
 
 	ip_vs_num_services--;
@@ -1220,9 +1197,7 @@
 	/*
 	 *    Unlink the whole destination list
 	 */
-	l = &svc->destinations;
-	while (l->next != l) {
-		dest = list_entry(l->next, struct ip_vs_dest, n_list);
+	list_for_each_entry_safe(dest, nxt, &svc->destinations, n_list) {
 		__ip_vs_unlink_dest(svc, dest, 0);
 		__ip_vs_del_dest(dest);
 	}
@@ -1279,16 +1254,13 @@
 static int ip_vs_flush(void)
 {
 	int idx;
-	struct ip_vs_service *svc;
-	struct list_head *l;
+	struct ip_vs_service *svc, *nxt;
 
 	/*
 	 * Flush the service table hashed by <protocol,addr,port>
 	 */
 	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		l = &ip_vs_svc_table[idx];
-		while (l->next != l) {
-			svc = list_entry(l->next,struct ip_vs_service,s_list);
+		list_for_each_entry_safe(svc, nxt, &ip_vs_svc_table[idx], s_list) {
 			write_lock_bh(&__ip_vs_svc_lock);
 			ip_vs_svc_unhash(svc);
 			/*
@@ -1304,9 +1276,8 @@
 	 * Flush the service table hashed by fwmark
 	 */
 	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		l = &ip_vs_svc_fwm_table[idx];
-		while (l->next != l) {
-			svc = list_entry(l->next,struct ip_vs_service,f_list);
+		list_for_each_entry_safe(svc, nxt, 
+					 &ip_vs_svc_fwm_table[idx], f_list) {
 			write_lock_bh(&__ip_vs_svc_lock);
 			ip_vs_svc_unhash(svc);
 			/*
@@ -1336,12 +1307,10 @@
 
 static int ip_vs_zero_service(struct ip_vs_service *svc)
 {
-	struct list_head *l;
 	struct ip_vs_dest *dest;
 
 	write_lock_bh(&__ip_vs_svc_lock);
-	list_for_each (l, &svc->destinations) {
-		dest = list_entry(l, struct ip_vs_dest, n_list);
+	list_for_each_entry(dest, &svc->destinations, n_list) {
 		ip_vs_zero_stats(&dest->stats);
 	}
 	ip_vs_zero_stats(&svc->stats);
@@ -1352,19 +1321,16 @@
 static int ip_vs_zero_all(void)
 {
 	int idx;
-	struct list_head *l;
 	struct ip_vs_service *svc;
 
 	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		list_for_each (l, &ip_vs_svc_table[idx]) {
-			svc = list_entry(l, struct ip_vs_service, s_list);
+		list_for_each_entry(svc, &ip_vs_svc_table[idx], s_list) {
 			ip_vs_zero_service(svc);
 		}
 	}
 
 	for(idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		list_for_each (l, &ip_vs_svc_fwm_table[idx]) {
-			svc = list_entry(l, struct ip_vs_service, f_list);
+		list_for_each_entry(svc, &ip_vs_svc_fwm_table[idx], f_list) {
 			ip_vs_zero_service(svc);
 		}
 	}
@@ -1540,26 +1506,26 @@
 {
 	struct ip_vs_iter *iter = seq->private;
 	int idx;
-	struct list_head *e;
+	struct ip_vs_service *svc;
 
 	/* look in hash by protocol */
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		list_for_each(e, &ip_vs_svc_table[idx]) {
+		list_for_each_entry(svc, &ip_vs_svc_table[idx], s_list) {
 			if (pos-- == 0){
 				iter->table = ip_vs_svc_table;
 				iter->bucket = idx;
-				return list_entry(e, struct ip_vs_service, s_list);
+				return svc;
 			}
 		}
 	}
 
 	/* keep looking in fwmark */
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		list_for_each(e, &ip_vs_svc_fwm_table[idx]) {
+		list_for_each_entry(svc, &ip_vs_svc_fwm_table[idx], f_list) {
 			if (pos-- == 0) {
 				iter->table = ip_vs_svc_fwm_table;
 				iter->bucket = idx;
-				return list_entry(e, struct ip_vs_service, f_list);
+				return svc;
 			}
 		}
 	}
@@ -1595,8 +1561,9 @@
 
 
 		while (++iter->bucket < IP_VS_SVC_TAB_SIZE) {
-			list_for_each(e, &ip_vs_svc_table[iter->bucket]) {
-				return list_entry(e, struct ip_vs_service, s_list);
+			list_for_each_entry(svc,&ip_vs_svc_table[iter->bucket],
+					    s_list) {
+				return svc;
 			}
 		}
 
@@ -1611,8 +1578,9 @@
 
  scan_fwmark:
 	while (++iter->bucket < IP_VS_SVC_TAB_SIZE) {
-		list_for_each(e, &ip_vs_svc_fwm_table[iter->bucket]) 
-			return list_entry(e, struct ip_vs_service, f_list);
+		list_for_each_entry(svc, &ip_vs_svc_fwm_table[iter->bucket],
+				    f_list) 
+			return svc;
 	}
 
 	return NULL;
@@ -1962,15 +1930,13 @@
 {
 	int idx, count=0;
 	struct ip_vs_service *svc;
-	struct list_head *l;
 	struct ip_vs_service_entry entry;
 	int ret = 0;
 
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		list_for_each (l, &ip_vs_svc_table[idx]) {
+		list_for_each_entry(svc, &ip_vs_svc_table[idx], s_list) {
 			if (count >= get->num_services)
 				goto out;
-			svc = list_entry(l, struct ip_vs_service, s_list);
 			ip_vs_copy_service(&entry, svc);
 			if (copy_to_user(&uptr->entrytable[count],
 					 &entry, sizeof(entry))) {
@@ -1982,10 +1948,9 @@
 	}
 
 	for (idx = 0; idx < IP_VS_SVC_TAB_SIZE; idx++) {
-		list_for_each (l, &ip_vs_svc_fwm_table[idx]) {
+		list_for_each_entry(svc, &ip_vs_svc_fwm_table[idx], f_list) {
 			if (count >= get->num_services)
 				goto out;
-			svc = list_entry(l, struct ip_vs_service, f_list);
 			ip_vs_copy_service(&entry, svc);
 			if (copy_to_user(&uptr->entrytable[count],
 					 &entry, sizeof(entry))) {
@@ -2014,14 +1979,12 @@
 	if (svc) {
 		int count = 0;
 		struct ip_vs_dest *dest;
-		struct list_head *l, *e;
 		struct ip_vs_dest_entry entry;
 
-		l = &svc->destinations;
-		for (e=l->next; e!=l; e=e->next) {
+		list_for_each_entry(dest, &svc->destinations, n_list) {
 			if (count >= get->num_dests)
 				break;
-			dest = list_entry(e, struct ip_vs_dest, n_list);
+
 			entry.addr = dest->addr;
 			entry.port = dest->port;
 			entry.conn_flags = atomic_read(&dest->conn_flags);
diff -Nru a/net/ipv4/ipvs/ip_vs_lblc.c b/net/ipv4/ipvs/ip_vs_lblc.c
--- a/net/ipv4/ipvs/ip_vs_lblc.c	Tue Sep 16 14:08:39 2003
+++ b/net/ipv4/ipvs/ip_vs_lblc.c	Tue Sep 16 14:08:39 2003
@@ -246,15 +246,12 @@
 {
 	unsigned hash;
 	struct ip_vs_lblc_entry *en;
-	struct list_head *l,*e;
 
 	hash = ip_vs_lblc_hashkey(addr);
-	l = &tbl->bucket[hash];
 
 	read_lock(&tbl->lock);
 
-	for (e=l->next; e!=l; e=e->next) {
-		en = list_entry(e, struct ip_vs_lblc_entry, list);
+	list_for_each_entry(en, &tbl->bucket[hash], list) {
 		if (en->addr == addr) {
 			/* HIT */
 			read_unlock(&tbl->lock);
@@ -274,14 +271,11 @@
 static void ip_vs_lblc_flush(struct ip_vs_lblc_table *tbl)
 {
 	int i;
-	struct list_head *l;
-	struct ip_vs_lblc_entry *en;
+	struct ip_vs_lblc_entry *en, *nxt;
 
 	for (i=0; i<IP_VS_LBLC_TAB_SIZE; i++) {
 		write_lock(&tbl->lock);
-		for (l=&tbl->bucket[i]; l->next!=l; ) {
-			en = list_entry(l->next,
-					struct ip_vs_lblc_entry, list);
+		list_for_each_entry_safe(en, nxt, &tbl->bucket[i], list) {
 			ip_vs_lblc_free(en);
 			atomic_dec(&tbl->entries);
 		}
@@ -294,21 +288,17 @@
 {
 	unsigned long now = jiffies;
 	int i, j;
-	struct list_head *l, *e;
-	struct ip_vs_lblc_entry *en;
+	struct ip_vs_lblc_entry *en, *nxt;
 
 	for (i=0, j=tbl->rover; i<IP_VS_LBLC_TAB_SIZE; i++) {
 		j = (j + 1) & IP_VS_LBLC_TAB_MASK;
-		e = l = &tbl->bucket[j];
+
 		write_lock(&tbl->lock);
-		while (e->next != l) {
-			en = list_entry(e->next,
-					struct ip_vs_lblc_entry, list);
+		list_for_each_entry_safe(en, nxt, &tbl->bucket[j], list) {
 			if ((now - en->lastuse) <
-			    sysctl_ip_vs_lblc_expiration) {
-				e = e->next;
+			    sysctl_ip_vs_lblc_expiration) 
 				continue;
-			}
+
 			ip_vs_lblc_free(en);
 			atomic_dec(&tbl->entries);
 		}
@@ -335,8 +325,7 @@
 	unsigned long now = jiffies;
 	int goal;
 	int i, j;
-	struct list_head *l, *e;
-	struct ip_vs_lblc_entry *en;
+	struct ip_vs_lblc_entry *en, *nxt;
 
 	tbl = (struct ip_vs_lblc_table *)data;
 
@@ -358,15 +347,12 @@
 
 	for (i=0, j=tbl->rover; i<IP_VS_LBLC_TAB_SIZE; i++) {
 		j = (j + 1) & IP_VS_LBLC_TAB_MASK;
-		e = l = &tbl->bucket[j];
+
 		write_lock(&tbl->lock);
-		while (e->next != l) {
-			en = list_entry(e->next,
-					struct ip_vs_lblc_entry, list);
-			if ((now - en->lastuse) < ENTRY_TIMEOUT) {
-				e = e->next;
+		list_for_each_entry_safe(en, nxt, &tbl->bucket[j], list) {
+			if ((now - en->lastuse) < ENTRY_TIMEOUT) 
 				continue;
-			}
+
 			ip_vs_lblc_free(en);
 			atomic_dec(&tbl->entries);
 			goal--;
@@ -452,7 +438,6 @@
 static inline struct ip_vs_dest *
 __ip_vs_wlc_schedule(struct ip_vs_service *svc, struct iphdr *iph)
 {
-	register struct list_head *l, *e;
 	struct ip_vs_dest *dest, *least;
 	int loh, doh;
 
@@ -473,10 +458,7 @@
 	 * The server with weight=0 is quiesced and will not receive any
 	 * new connection.
 	 */
-
-	l = &svc->destinations;
-	for (e=l->next; e!=l; e=e->next) {
-		least = list_entry(e, struct ip_vs_dest, n_list);
+	list_for_each_entry(least, &svc->destinations, n_list) {
 		if (least->flags & IP_VS_DEST_F_OVERLOAD)
 			continue;
 		if (atomic_read(&least->weight) > 0) {
@@ -491,9 +473,7 @@
 	 *    Find the destination with the least load.
 	 */
   nextstage:
-	for (e=e->next; e!=l; e=e->next) {
-		dest = list_entry(e, struct ip_vs_dest, n_list);
-
+	list_for_each_entry(dest, &svc->destinations, n_list) {
 		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
 			continue;
 
@@ -525,12 +505,9 @@
 is_overloaded(struct ip_vs_dest *dest, struct ip_vs_service *svc)
 {
 	if (atomic_read(&dest->activeconns) > atomic_read(&dest->weight)) {
-		register struct list_head *l, *e;
 		struct ip_vs_dest *d;
 
-		l = &svc->destinations;
-		for (e=l->next; e!=l; e=e->next) {
-			d = list_entry(e, struct ip_vs_dest, n_list);
+		list_for_each_entry(d, &svc->destinations, n_list) {
 			if (atomic_read(&d->activeconns)*2
 			    < atomic_read(&d->weight)) {
 				return 1;
diff -Nru a/net/ipv4/ipvs/ip_vs_lblcr.c b/net/ipv4/ipvs/ip_vs_lblcr.c
--- a/net/ipv4/ipvs/ip_vs_lblcr.c	Tue Sep 16 14:08:39 2003
+++ b/net/ipv4/ipvs/ip_vs_lblcr.c	Tue Sep 16 14:08:39 2003
@@ -171,7 +171,7 @@
 /* get weighted least-connection node in the destination set */
 static inline struct ip_vs_dest *ip_vs_dest_set_min(struct ip_vs_dest_set *set)
 {
-	struct ip_vs_dest_list *e;
+	register struct ip_vs_dest_list *e;
 	struct ip_vs_dest *dest, *least;
 	int loh, doh;
 
@@ -226,7 +226,7 @@
 /* get weighted most-connection node in the destination set */
 static inline struct ip_vs_dest *ip_vs_dest_set_max(struct ip_vs_dest_set *set)
 {
-	struct ip_vs_dest_list *e;
+	register struct ip_vs_dest_list *e;
 	struct ip_vs_dest *dest, *most;
 	int moh, doh;
 
@@ -432,15 +432,12 @@
 {
 	unsigned hash;
 	struct ip_vs_lblcr_entry *en;
-	struct list_head *l,*e;
 
 	hash = ip_vs_lblcr_hashkey(addr);
-	l = &tbl->bucket[hash];
 
 	read_lock(&tbl->lock);
 
-	for (e=l->next; e!=l; e=e->next) {
-		en = list_entry(e, struct ip_vs_lblcr_entry, list);
+	list_for_each_entry(en, &tbl->bucket[hash], list) {
 		if (en->addr == addr) {
 			/* HIT */
 			read_unlock(&tbl->lock);
@@ -460,14 +457,11 @@
 static void ip_vs_lblcr_flush(struct ip_vs_lblcr_table *tbl)
 {
 	int i;
-	struct list_head *l;
-	struct ip_vs_lblcr_entry *en;
+	struct ip_vs_lblcr_entry *en, *nxt;
 
 	for (i=0; i<IP_VS_LBLCR_TAB_SIZE; i++) {
 		write_lock(&tbl->lock);
-		for (l=&tbl->bucket[i]; l->next!=l; ) {
-			en = list_entry(l->next,
-					struct ip_vs_lblcr_entry, list);
+		list_for_each_entry_safe(en, nxt, &tbl->bucket[i], list) {
 			ip_vs_lblcr_free(en);
 			atomic_dec(&tbl->entries);
 		}
@@ -480,19 +474,15 @@
 {
 	unsigned long now = jiffies;
 	int i, j;
-	struct list_head *l, *e;
-	struct ip_vs_lblcr_entry *en;
+	struct ip_vs_lblcr_entry *en, *nxt;
 
 	for (i=0, j=tbl->rover; i<IP_VS_LBLCR_TAB_SIZE; i++) {
 		j = (j + 1) & IP_VS_LBLCR_TAB_MASK;
-		e = l = &tbl->bucket[j];
+
 		write_lock(&tbl->lock);
-		while (e->next != l) {
-			en = list_entry(e->next,
-					struct ip_vs_lblcr_entry, list);
+		list_for_each_entry_safe(en, nxt, &tbl->bucket[j], list) {
 			if ((now - en->lastuse) <
 			    sysctl_ip_vs_lblcr_expiration) {
-				e = e->next;
 				continue;
 			}
 			ip_vs_lblcr_free(en);
@@ -521,8 +511,7 @@
 	unsigned long now = jiffies;
 	int goal;
 	int i, j;
-	struct list_head *l, *e;
-	struct ip_vs_lblcr_entry *en;
+	struct ip_vs_lblcr_entry *en, *nxt;
 
 	tbl = (struct ip_vs_lblcr_table *)data;
 
@@ -544,15 +533,12 @@
 
 	for (i=0, j=tbl->rover; i<IP_VS_LBLCR_TAB_SIZE; i++) {
 		j = (j + 1) & IP_VS_LBLCR_TAB_MASK;
-		e = l = &tbl->bucket[j];
+
 		write_lock(&tbl->lock);
-		while (e->next != l) {
-			en = list_entry(e->next,
-					struct ip_vs_lblcr_entry, list);
-			if ((now - en->lastuse) < ENTRY_TIMEOUT) {
-				e = e->next;
+		list_for_each_entry_safe(en, nxt, &tbl->bucket[j], list) {
+			if ((now - en->lastuse) < ENTRY_TIMEOUT) 
 				continue;
-			}
+
 			ip_vs_lblcr_free(en);
 			atomic_dec(&tbl->entries);
 			goal--;
@@ -583,7 +569,6 @@
 	struct ip_vs_lblcr_table *tbl;
 	unsigned long now = jiffies;
 	int i;
-	struct list_head *l, *e;
 	struct ip_vs_lblcr_entry *en;
 
 	tbl = lblcr_table_list;
@@ -593,13 +578,11 @@
 	len += size;
 
 	for (i=0; i<IP_VS_LBLCR_TAB_SIZE; i++) {
-		l = &tbl->bucket[i];
 		read_lock_bh(&tbl->lock);
-		for (e=l->next; e!=l; e=e->next) {
+		list_for_each_entry(en, &tbl->bucket[i], list) {
 			char tbuf[16];
 			struct ip_vs_dest_list *d;
 
-			en = list_entry(e, struct ip_vs_lblcr_entry, list);
 			sprintf(tbuf, "%u.%u.%u.%u", NIPQUAD(en->addr));
 			size = sprintf(buffer+len, "%8lu %-16s ",
 				       now-en->lastuse, tbuf);
@@ -708,7 +691,6 @@
 static inline struct ip_vs_dest *
 __ip_vs_wlc_schedule(struct ip_vs_service *svc, struct iphdr *iph)
 {
-	register struct list_head *l, *e;
 	struct ip_vs_dest *dest, *least;
 	int loh, doh;
 
@@ -729,10 +711,7 @@
 	 * The server with weight=0 is quiesced and will not receive any
 	 * new connection.
 	 */
-
-	l = &svc->destinations;
-	for (e=l->next; e!=l; e=e->next) {
-		least = list_entry(e, struct ip_vs_dest, n_list);
+	list_for_each_entry(least, &svc->destinations, n_list) {
 		if (least->flags & IP_VS_DEST_F_OVERLOAD)
 			continue;
 
@@ -748,8 +727,7 @@
 	 *    Find the destination with the least load.
 	 */
   nextstage:
-	for (e=e->next; e!=l; e=e->next) {
-		dest = list_entry(e, struct ip_vs_dest, n_list);
+	list_for_each_entry(dest, &svc->destinations, n_list) {
 		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
 			continue;
 
@@ -781,12 +759,9 @@
 is_overloaded(struct ip_vs_dest *dest, struct ip_vs_service *svc)
 {
 	if (atomic_read(&dest->activeconns) > atomic_read(&dest->weight)) {
-		register struct list_head *l, *e;
 		struct ip_vs_dest *d;
 
-		l = &svc->destinations;
-		for (e=l->next; e!=l; e=e->next) {
-			d = list_entry(e, struct ip_vs_dest, n_list);
+		list_for_each_entry(d, &svc->destinations, n_list) {
 			if (atomic_read(&d->activeconns)*2
 			    < atomic_read(&d->weight)) {
 				return 1;
diff -Nru a/net/ipv4/ipvs/ip_vs_lc.c b/net/ipv4/ipvs/ip_vs_lc.c
--- a/net/ipv4/ipvs/ip_vs_lc.c	Tue Sep 16 14:08:39 2003
+++ b/net/ipv4/ipvs/ip_vs_lc.c	Tue Sep 16 14:08:39 2003
@@ -65,7 +65,6 @@
 static struct ip_vs_dest *
 ip_vs_lc_schedule(struct ip_vs_service *svc, struct iphdr *iph)
 {
-	struct list_head *l, *e;
 	struct ip_vs_dest *dest, *least;
 	unsigned int loh, doh;
 
@@ -80,9 +79,7 @@
 	 * served, but no new connection is assigned to the server.
 	 */
 
-	l = &svc->destinations;
-	for (e=l->next; e!=l; e=e->next) {
-		least = list_entry (e, struct ip_vs_dest, n_list);
+	list_for_each_entry(least, &svc->destinations, n_list) {
 		if (least->flags & IP_VS_DEST_F_OVERLOAD)
 			continue;
 		if (atomic_read(&least->weight) > 0) {
@@ -96,8 +93,7 @@
 	 *    Find the destination with the least load.
 	 */
   nextstage:
-	for (e=e->next; e!=l; e=e->next) {
-		dest = list_entry(e, struct ip_vs_dest, n_list);
+	list_for_each_entry(dest, &svc->destinations, n_list) {
 		if ((dest->flags & IP_VS_DEST_F_OVERLOAD) ||
 		    atomic_read(&dest->weight) == 0)
 			continue;
diff -Nru a/net/ipv4/ipvs/ip_vs_nq.c b/net/ipv4/ipvs/ip_vs_nq.c
--- a/net/ipv4/ipvs/ip_vs_nq.c	Tue Sep 16 14:08:39 2003
+++ b/net/ipv4/ipvs/ip_vs_nq.c	Tue Sep 16 14:08:39 2003
@@ -81,7 +81,6 @@
 static struct ip_vs_dest *
 ip_vs_nq_schedule(struct ip_vs_service *svc, struct iphdr *iph)
 {
-	register struct list_head *l, *e;
 	struct ip_vs_dest *dest, *least;
 	unsigned int loh, doh;
 
@@ -100,9 +99,7 @@
 	 * new connections.
 	 */
 
-	l = &svc->destinations;
-	for (e=l->next; e!=l; e=e->next) {
-		least = list_entry(e, struct ip_vs_dest, n_list);
+	list_for_each_entry(least, &svc->destinations, n_list) {
 		if (!(least->flags & IP_VS_DEST_F_OVERLOAD) &&
 		    atomic_read(&least->weight) > 0) {
 			loh = ip_vs_nq_dest_overhead(least);
@@ -120,8 +117,7 @@
 	 *    Find the destination with the least load.
 	 */
   nextstage:
-	for (e=e->next; e!=l; e=e->next) {
-		dest = list_entry(e, struct ip_vs_dest, n_list);
+	list_for_each_entry(dest, &svc->destinations, n_list) {
 
 		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
 			continue;
diff -Nru a/net/ipv4/ipvs/ip_vs_proto_tcp.c b/net/ipv4/ipvs/ip_vs_proto_tcp.c
--- a/net/ipv4/ipvs/ip_vs_proto_tcp.c	Tue Sep 16 14:08:39 2003
+++ b/net/ipv4/ipvs/ip_vs_proto_tcp.c	Tue Sep 16 14:08:39 2003
@@ -479,22 +479,19 @@
 static int tcp_register_app(struct ip_vs_app *inc)
 {
 	struct ip_vs_app *i;
-	struct list_head *t, *p;
 	__u16 hash, port = inc->port;
 	int ret = 0;
 
 	hash = tcp_app_hashkey(port);
-	t = &tcp_apps[hash];
 
 	spin_lock_bh(&tcp_app_lock);
-	for (p = t->next; p != t; p = p->next) {
-		i = list_entry(p, struct ip_vs_app, p_list);
+	list_for_each_entry(i, &tcp_apps[hash], p_list) {
 		if (i->port == port) {
 			ret = -EEXIST;
 			goto out;
 		}
 	}
-	list_add(&inc->p_list, t);
+	list_add(&inc->p_list, &tcp_apps[hash]);
 	atomic_inc(&ip_vs_protocol_tcp.appcnt);
 
   out:
@@ -516,7 +513,6 @@
 static int
 tcp_app_conn_bind(struct ip_vs_conn *cp)
 {
-	struct list_head *t, *p;
 	int hash;
 	struct ip_vs_app *inc;
 	int result = 0;
@@ -527,11 +523,9 @@
 
 	/* Lookup application incarnations and bind the right one */
 	hash = tcp_app_hashkey(cp->vport);
-	t = &tcp_apps[hash];
 
 	spin_lock(&tcp_app_lock);
-	for (p = t->next; p != t; p = p->next) {
-		inc = list_entry(p, struct ip_vs_app, p_list);
+	list_for_each_entry(inc, &tcp_apps[hash], p_list) {
 		if (inc->port == cp->vport) {
 			if (unlikely(!ip_vs_app_inc_get(inc)))
 				break;
diff -Nru a/net/ipv4/ipvs/ip_vs_proto_udp.c b/net/ipv4/ipvs/ip_vs_proto_udp.c
--- a/net/ipv4/ipvs/ip_vs_proto_udp.c	Tue Sep 16 14:08:39 2003
+++ b/net/ipv4/ipvs/ip_vs_proto_udp.c	Tue Sep 16 14:08:39 2003
@@ -245,22 +245,20 @@
 static int udp_register_app(struct ip_vs_app *inc)
 {
 	struct ip_vs_app *i;
-	struct list_head *t, *p;
 	__u16 hash, port = inc->port;
 	int ret = 0;
 
 	hash = udp_app_hashkey(port);
-	t = &udp_apps[hash];
+
 
 	spin_lock_bh(&udp_app_lock);
-	for (p = t->next; p != t; p = p->next) {
-		i = list_entry(p, struct ip_vs_app, p_list);
+	list_for_each_entry(i, &udp_apps[hash], p_list) {
 		if (i->port == port) {
 			ret = -EEXIST;
 			goto out;
 		}
 	}
-	list_add(&inc->p_list, t);
+	list_add(&inc->p_list, &udp_apps[hash]);
 	atomic_inc(&ip_vs_protocol_udp.appcnt);
 
   out:
@@ -281,7 +279,6 @@
 
 static int udp_app_conn_bind(struct ip_vs_conn *cp)
 {
-	struct list_head *t, *p;
 	int hash;
 	struct ip_vs_app *inc;
 	int result = 0;
@@ -292,11 +289,9 @@
 
 	/* Lookup application incarnations and bind the right one */
 	hash = udp_app_hashkey(cp->vport);
-	t = &udp_apps[hash];
 
 	spin_lock(&udp_app_lock);
-	for (p = t->next; p != t; p = p->next) {
-		inc = list_entry(p, struct ip_vs_app, p_list);
+	list_for_each_entry(inc, &udp_apps[hash], p_list) {
 		if (inc->port == cp->vport) {
 			if (unlikely(!ip_vs_app_inc_get(inc)))
 				break;
diff -Nru a/net/ipv4/ipvs/ip_vs_rr.c b/net/ipv4/ipvs/ip_vs_rr.c
--- a/net/ipv4/ipvs/ip_vs_rr.c	Tue Sep 16 14:08:39 2003
+++ b/net/ipv4/ipvs/ip_vs_rr.c	Tue Sep 16 14:08:39 2003
@@ -57,7 +57,7 @@
 static struct ip_vs_dest *
 ip_vs_rr_schedule(struct ip_vs_service *svc, struct iphdr *iph)
 {
-	register struct list_head *p, *q;
+	struct list_head *p, *q;
 	struct ip_vs_dest *dest;
 
 	IP_VS_DBG(6, "ip_vs_rr_schedule(): Scheduling...\n");
@@ -73,12 +73,12 @@
 			continue;
 		}
 		
+	
 		dest = list_entry(q, struct ip_vs_dest, n_list);
 		if (!(dest->flags & IP_VS_DEST_F_OVERLOAD) &&
 		    atomic_read(&dest->weight) > 0)
 			/* HIT */
 			goto out;
-		q = q->next;
 	} while (q != p);
 	write_unlock(&svc->sched_lock);
 	return NULL;
diff -Nru a/net/ipv4/ipvs/ip_vs_sched.c b/net/ipv4/ipvs/ip_vs_sched.c
--- a/net/ipv4/ipvs/ip_vs_sched.c	Tue Sep 16 14:08:39 2003
+++ b/net/ipv4/ipvs/ip_vs_sched.c	Tue Sep 16 14:08:39 2003
@@ -106,18 +106,13 @@
 static struct ip_vs_scheduler *ip_vs_sched_getbyname(const char *sched_name)
 {
 	struct ip_vs_scheduler *sched;
-	struct list_head *l, *e;
 
 	IP_VS_DBG(2, "ip_vs_sched_getbyname(): sched_name \"%s\"\n",
 		  sched_name);
 
-	l = &ip_vs_schedulers;
-
 	read_lock_bh(&__ip_vs_sched_lock);
 
-	for (e=l->next; e!=l; e=e->next) {
-		sched = list_entry(e, struct ip_vs_scheduler, n_list);
-
+	list_for_each_entry(sched, &ip_vs_schedulers, n_list) {
 		/*
 		 * Test and get the modules atomically
 		 */
diff -Nru a/net/ipv4/ipvs/ip_vs_sed.c b/net/ipv4/ipvs/ip_vs_sed.c
--- a/net/ipv4/ipvs/ip_vs_sed.c	Tue Sep 16 14:08:39 2003
+++ b/net/ipv4/ipvs/ip_vs_sed.c	Tue Sep 16 14:08:39 2003
@@ -85,7 +85,6 @@
 static struct ip_vs_dest *
 ip_vs_sed_schedule(struct ip_vs_service *svc, struct iphdr *iph)
 {
-	register struct list_head *l, *e;
 	struct ip_vs_dest *dest, *least;
 	unsigned int loh, doh;
 
@@ -104,9 +103,7 @@
 	 * new connections.
 	 */
 
-	l = &svc->destinations;
-	for (e=l->next; e!=l; e=e->next) {
-		least = list_entry(e, struct ip_vs_dest, n_list);
+	list_for_each_entry(least, &svc->destinations, n_list) {
 		if (!(least->flags & IP_VS_DEST_F_OVERLOAD) &&
 		    atomic_read(&least->weight) > 0) {
 			loh = ip_vs_sed_dest_overhead(least);
@@ -119,9 +116,7 @@
 	 *    Find the destination with the least load.
 	 */
   nextstage:
-	for (e=e->next; e!=l; e=e->next) {
-		dest = list_entry(e, struct ip_vs_dest, n_list);
-
+	list_for_each_entry(dest, &svc->destinations, n_list) {
 		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
 			continue;
 		doh = ip_vs_sed_dest_overhead(dest);
diff -Nru a/net/ipv4/ipvs/ip_vs_wlc.c b/net/ipv4/ipvs/ip_vs_wlc.c
--- a/net/ipv4/ipvs/ip_vs_wlc.c	Tue Sep 16 14:08:39 2003
+++ b/net/ipv4/ipvs/ip_vs_wlc.c	Tue Sep 16 14:08:39 2003
@@ -73,7 +73,6 @@
 static struct ip_vs_dest *
 ip_vs_wlc_schedule(struct ip_vs_service *svc, struct iphdr *iph)
 {
-	register struct list_head *l, *e;
 	struct ip_vs_dest *dest, *least;
 	unsigned int loh, doh;
 
@@ -92,9 +91,7 @@
 	 * new connections.
 	 */
 
-	l = &svc->destinations;
-	for (e=l->next; e!=l; e=e->next) {
-		least = list_entry(e, struct ip_vs_dest, n_list);
+	list_for_each_entry(least, &svc->destinations, n_list) {
 		if (!(least->flags & IP_VS_DEST_F_OVERLOAD) &&
 		    atomic_read(&least->weight) > 0) {
 			loh = ip_vs_wlc_dest_overhead(least);
@@ -107,9 +104,7 @@
 	 *    Find the destination with the least load.
 	 */
   nextstage:
-	for (e=e->next; e!=l; e=e->next) {
-		dest = list_entry(e, struct ip_vs_dest, n_list);
-
+	list_for_each_entry(dest, &svc->destinations, n_list) {
 		if (dest->flags & IP_VS_DEST_F_OVERLOAD)
 			continue;
 		doh = ip_vs_wlc_dest_overhead(dest);
diff -Nru a/net/ipv4/ipvs/ip_vs_wrr.c b/net/ipv4/ipvs/ip_vs_wrr.c
--- a/net/ipv4/ipvs/ip_vs_wrr.c	Tue Sep 16 14:08:39 2003
+++ b/net/ipv4/ipvs/ip_vs_wrr.c	Tue Sep 16 14:08:39 2003
@@ -56,25 +56,22 @@
 
 static int ip_vs_wrr_gcd_weight(struct ip_vs_service *svc)
 {
-	register struct list_head *l, *e;
 	struct ip_vs_dest *dest;
 	int weight;
 	int g = 1;
 
-	l = &svc->destinations;
-	for (e=l->next; e!=l; e=e->next) {
-		dest = list_entry(e, struct ip_vs_dest, n_list);
+	list_for_each_entry(dest, &svc->destinations, n_list) {
 		weight = atomic_read(&dest->weight);
 		if (weight > 0) {
 			g = weight;
-			break;
+			goto search_gcd;
 		}
 	}
-	if (e == l)
-		return g;
 
-	for (e=e->next; e!=l; e=e->next) {
-		dest = list_entry(e, struct ip_vs_dest, n_list);
+	return g;
+
+ search_gcd:
+	list_for_each_entry(dest, &svc->destinations, n_list) {
 		weight = atomic_read(&dest->weight);
 		if (weight > 0)
 			g = gcd(weight, g);
@@ -89,13 +86,10 @@
  */
 static int ip_vs_wrr_max_weight(struct ip_vs_service *svc)
 {
-	register struct list_head *l, *e;
 	struct ip_vs_dest *dest;
 	int weight = 0;
 
-	l = &svc->destinations;
-	for (e=l->next; e!=l; e=e->next) {
-		dest = list_entry(e, struct ip_vs_dest, n_list);
+	list_for_each_entry(dest, &svc->destinations, n_list) {
 		if (atomic_read(&dest->weight) > weight)
 			weight = atomic_read(&dest->weight);
 	}
