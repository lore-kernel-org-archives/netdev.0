From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH] [RFT] ip_tables NUMA optimization
Date: Thu, 17 Nov 2005 15:43:28 +0100
Message-ID: <20051117144328.GG14201@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="K1n7F7fSdjvFAEnM"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Eric dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--K1n7F7fSdjvFAEnM
Content-Type: multipart/mixed; boundary="oXNgvKVxGWJ0RPMJ"
Content-Disposition: inline


--oXNgvKVxGWJ0RPMJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

I've hand-merged Eric Dumazet's original ip_tables numa optimization
patch to current git head.  Also, I've ported it to ip6_tables and
arp_tables.

Since this is 2.6.16 stuff, I don't want to have it applied at this
time, but merely request testers (esp. for the non-ipv4 part).

Thanks,

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--oXNgvKVxGWJ0RPMJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="vmalloc_node.patch"
Content-Transfer-Encoding: quoted-printable

[NETFILTER] ip_tables: NUMA-aware allocation

Part of a performance problem with ip_tables is that memory allocation is n=
ot
NUMA aware, but 'only' SMP aware (ie each CPU normally touch separate cache
lines)                                                                     =
  =20

Even with small iptables rules, the cost of this misplacement can be high on
common workloads.  Instead of using one vmalloc() area (located in the node=
 of
the iptables process), we now allocate an area for each possible CPU, using
vmalloc_node() so that memory should be allocated in the CPU's node if
possible.

Port to arp_tables and ip6_tables by Harald Welte.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_table=
s.c
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -68,19 +68,14 @@ struct arpt_table_info {
 	unsigned int initial_entries;
 	unsigned int hook_entry[NF_ARP_NUMHOOKS];
 	unsigned int underflow[NF_ARP_NUMHOOKS];
-	char entries[0] __attribute__((aligned(SMP_CACHE_BYTES)));
+	void *entries[NR_CPUS];
 };
=20
 static LIST_HEAD(arpt_target);
 static LIST_HEAD(arpt_tables);
+#define SET_COUNTER(c,b,p) do { (c).bcnt =3D (b); (c).pcnt =3D (p); } whil=
e(0)
 #define ADD_COUNTER(c,b,p) do { (c).bcnt +=3D (b); (c).pcnt +=3D (p); } wh=
ile(0)
=20
-#ifdef CONFIG_SMP
-#define TABLE_OFFSET(t,p) (SMP_ALIGN((t)->size)*(p))
-#else
-#define TABLE_OFFSET(t,p) 0
-#endif
-
 static inline int arp_devaddr_compare(const struct arpt_devaddr_info *ap,
 				      char *hdr_addr, int len)
 {
@@ -269,9 +264,7 @@ unsigned int arpt_do_table(struct sk_buf
 	outdev =3D out ? out->name : nulldevname;
=20
 	read_lock_bh(&table->lock);
-	table_base =3D (void *)table->private->entries
-		+ TABLE_OFFSET(table->private,
-			       smp_processor_id());
+	table_base =3D (void *)table->private->entries[smp_processor_id()];
 	e =3D get_entry(table_base, table->private->hook_entry[hook]);
 	back =3D get_entry(table_base, table->private->underflow[hook]);
=20
@@ -462,7 +455,8 @@ static inline int unconditional(const st
 /* Figures out from what hook each rule can be called: returns 0 if
  * there are loops.  Puts hook bitmask in comefrom.
  */
-static int mark_source_chains(struct arpt_table_info *newinfo, unsigned in=
t valid_hooks)
+static int mark_source_chains(struct arpt_table_info *newinfo,
+			      unsigned int valid_hooks, void *entry0)
 {
 	unsigned int hook;
=20
@@ -472,7 +466,7 @@ static int mark_source_chains(struct arp
 	for (hook =3D 0; hook < NF_ARP_NUMHOOKS; hook++) {
 		unsigned int pos =3D newinfo->hook_entry[hook];
 		struct arpt_entry *e
-			=3D (struct arpt_entry *)(newinfo->entries + pos);
+			=3D (struct arpt_entry *)(entry0 + pos);
=20
 		if (!(valid_hooks & (1 << hook)))
 			continue;
@@ -514,13 +508,13 @@ static int mark_source_chains(struct arp
 						goto next;
=20
 					e =3D (struct arpt_entry *)
-						(newinfo->entries + pos);
+						(entry0 + pos);
 				} while (oldpos =3D=3D pos + e->next_offset);
=20
 				/* Move along one */
 				size =3D e->next_offset;
 				e =3D (struct arpt_entry *)
-					(newinfo->entries + pos + size);
+					(entry0 + pos + size);
 				e->counters.pcnt =3D pos;
 				pos +=3D size;
 			} else {
@@ -537,7 +531,7 @@ static int mark_source_chains(struct arp
 					newpos =3D pos + e->next_offset;
 				}
 				e =3D (struct arpt_entry *)
-					(newinfo->entries + newpos);
+					(entry0 + newpos);
 				e->counters.pcnt =3D pos;
 				pos =3D newpos;
 			}
@@ -689,6 +683,7 @@ static inline int cleanup_entry(struct a
 static int translate_table(const char *name,
 			   unsigned int valid_hooks,
 			   struct arpt_table_info *newinfo,
+			   void *entry0,
 			   unsigned int size,
 			   unsigned int number,
 			   const unsigned int *hook_entries,
@@ -713,8 +708,8 @@ static int translate_table(const char *n
 	ret =3D ARPT_ENTRY_ITERATE(newinfo->entries, newinfo->size,
 				 check_entry_size_and_hooks,
 				 newinfo,
-				 newinfo->entries,
-				 newinfo->entries + size,
+				 entry0,
+				 entry0 + size,
 				 hook_entries, underflows, &i);
 	duprintf("translate_table: ARPT_ENTRY_ITERATE gives %d\n", ret);
 	if (ret !=3D 0)
@@ -743,29 +738,26 @@ static int translate_table(const char *n
 		}
 	}
=20
-	if (!mark_source_chains(newinfo, valid_hooks)) {
+	if (!mark_source_chains(newinfo, valid_hooks, entry0)) {
 		duprintf("Looping hook\n");
 		return -ELOOP;
 	}
=20
 	/* Finally, each sanity check must pass */
 	i =3D 0;
-	ret =3D ARPT_ENTRY_ITERATE(newinfo->entries, newinfo->size,
+	ret =3D ARPT_ENTRY_ITERATE(entry0, newinfo->size,
 				 check_entry, name, size, &i);
=20
 	if (ret !=3D 0) {
-		ARPT_ENTRY_ITERATE(newinfo->entries, newinfo->size,
+		ARPT_ENTRY_ITERATE(entry0, newinfo->size,
 				   cleanup_entry, &i);
 		return ret;
 	}
=20
 	/* And one copy for every other CPU */
 	for_each_cpu(i) {
-		if (i =3D=3D 0)
-			continue;
-		memcpy(newinfo->entries + SMP_ALIGN(newinfo->size) * i,
-		       newinfo->entries,
-		       SMP_ALIGN(newinfo->size));
+		if (newinfo->entries[i] && newinfo->entries[i] !=3D entry0)
+			memcpy(newinfo->entries[smp_processor_id()], entry0, newinfo->size);
 	}
=20
 	return ret;
@@ -807,20 +799,45 @@ static inline int add_entry_to_counter(c
 	return 0;
 }
=20
+static inline int set_entry_to_counter(const struct arpt_entry *e,
+				       struct arpt_counters total[],
+				       unsigned int *i)
+{
+	SET_COUNTER(total[*i], e->counters.bcnt, e->counters.pcnt);
+
+	(*i)++;
+	return 0;
+}
+
 static void get_counters(const struct arpt_table_info *t,
 			 struct arpt_counters counters[])
 {
 	unsigned int cpu;
 	unsigned int i;
+	unsigned int curcpu =3D get_cpu();
+
+	/* Instead of clearing (by a previous call to memset())
+	 * the counters and using adds, we set the counters
+	 * with data used by current CPU */
+
+	i =3D 0;
+	ARPT_ENTRY_ITERATE(t->entries[curcpu],
+			   t->size,
+			   set_entry_to_counter,
+			   counters,
+			   &i);
=20
 	for_each_cpu(cpu) {
+		if (cpu =3D=3D curcpu)
+			continue;
 		i =3D 0;
-		ARPT_ENTRY_ITERATE(t->entries + TABLE_OFFSET(t, cpu),
+		ARPT_ENTRY_ITERATE(t->entries[cpu],
 				   t->size,
 				   add_entry_to_counter,
 				   counters,
 				   &i);
 	}
+	put_cpu();
 }
=20
 static int copy_entries_to_user(unsigned int total_size,
@@ -831,6 +848,7 @@ static int copy_entries_to_user(unsigned
 	struct arpt_entry *e;
 	struct arpt_counters *counters;
 	int ret =3D 0;
+	void *loc_cpu_entry;
=20
 	/* We need atomic snapshot of counters: rest doesn't change
 	 * (other than comefrom, which userspace doesn't care
@@ -843,13 +861,13 @@ static int copy_entries_to_user(unsigned
 		return -ENOMEM;
=20
 	/* First, sum counters... */
-	memset(counters, 0, countersize);
 	write_lock_bh(&table->lock);
 	get_counters(table->private, counters);
 	write_unlock_bh(&table->lock);
=20
-	/* ... then copy entire thing from CPU 0... */
-	if (copy_to_user(userptr, table->private->entries, total_size) !=3D 0) {
+	loc_cpu_entry =3D table->private->entries[get_cpu()];
+	/* ... then copy entire thing ... */
+	if (copy_to_user(userptr, loc_cpu_entry, total_size) !=3D 0) {
 		ret =3D -EFAULT;
 		goto free_counters;
 	}
@@ -859,7 +877,7 @@ static int copy_entries_to_user(unsigned
 	for (off =3D 0, num =3D 0; off < total_size; off +=3D e->next_offset, num=
++){
 		struct arpt_entry_target *t;
=20
-		e =3D (struct arpt_entry *)(table->private->entries + off);
+		e =3D (struct arpt_entry *)(loc_cpu_entry + off);
 		if (copy_to_user(userptr + off
 				 + offsetof(struct arpt_entry, counters),
 				 &counters[num],
@@ -880,6 +898,7 @@ static int copy_entries_to_user(unsigned
 	}
=20
  free_counters:
+	put_cpu();
 	vfree(counters);
 	return ret;
 }
@@ -911,6 +930,47 @@ static int get_entries(const struct arpt
 	return ret;
 }
=20
+static void free_table_info(struct arpt_table_info *info)
+{
+	int cpu;
+	for_each_cpu(cpu) {
+		if (info->size <=3D PAGE_SIZE)
+			kfree(info->entries[cpu]);
+		else
+			kfree(info->entries[cpu]);
+	}
+	kfree(info);
+}
+
+static struct arpt_table_info *alloc_table_info(unsigned int size)
+{
+	struct arpt_table_info *newinfo;
+	int cpu;
+=09
+	newinfo =3D kzalloc(sizeof(struct arpt_table_info), GFP_KERNEL);
+	if (!newinfo)
+		return NULL;
+
+	newinfo->size =3D size;
+
+	for_each_cpu(cpu) {
+		if (size <=3D PAGE_SIZE)
+			newinfo->entries[cpu] =3D kmalloc_node(size,
+							GFP_KERNEL,
+							cpu_to_node(cpu));
+		else
+			newinfo->entries[cpu] =3D vmalloc_node(size,
+							     cpu_to_node(cpu));
+
+		if (newinfo->entries[cpu] =3D=3D NULL) {
+			free_table_info(newinfo);
+			return NULL;
+		}
+	}
+
+	return newinfo;
+}
+
 static int do_replace(void __user *user, unsigned int len)
 {
 	int ret;
@@ -918,6 +978,7 @@ static int do_replace(void __user *user,
 	struct arpt_table *t;
 	struct arpt_table_info *newinfo, *oldinfo;
 	struct arpt_counters *counters;
+	void *loc_cpu_entry, *loc_cpu_old_entry;
=20
 	if (copy_from_user(&tmp, user, sizeof(tmp)) !=3D 0)
 		return -EFAULT;
@@ -930,13 +991,13 @@ static int do_replace(void __user *user,
 	if ((SMP_ALIGN(tmp.size) >> PAGE_SHIFT) + 2 > num_physpages)
 		return -ENOMEM;
=20
-	newinfo =3D vmalloc(sizeof(struct arpt_table_info)
-			  + SMP_ALIGN(tmp.size) *
-			  		(highest_possible_processor_id()+1));
+	newinfo =3D alloc_table_info(tmp.size);
 	if (!newinfo)
 		return -ENOMEM;
=20
-	if (copy_from_user(newinfo->entries, user + sizeof(tmp),
+	/* choose the copy that is on our node/cpu */
+	loc_cpu_entry =3D newinfo->entries[get_cpu()];
+	if (copy_from_user(loc_cpu_entry, user + sizeof(tmp),
 			   tmp.size) !=3D 0) {
 		ret =3D -EFAULT;
 		goto free_newinfo;
@@ -947,10 +1008,9 @@ static int do_replace(void __user *user,
 		ret =3D -ENOMEM;
 		goto free_newinfo;
 	}
-	memset(counters, 0, tmp.num_counters * sizeof(struct arpt_counters));
=20
 	ret =3D translate_table(tmp.name, tmp.valid_hooks,
-			      newinfo, tmp.size, tmp.num_entries,
+			      newinfo, loc_cpu_entry, tmp.size, tmp.num_entries,
 			      tmp.hook_entry, tmp.underflow);
 	if (ret !=3D 0)
 		goto free_newinfo_counters;
@@ -989,8 +1049,10 @@ static int do_replace(void __user *user,
 	/* Get the old counters. */
 	get_counters(oldinfo, counters);
 	/* Decrease module usage counts and free resource */
-	ARPT_ENTRY_ITERATE(oldinfo->entries, oldinfo->size, cleanup_entry,NULL);
-	vfree(oldinfo);
+	loc_cpu_old_entry =3D oldinfo->entries[smp_processor_id()];
+	ARPT_ENTRY_ITERATE(loc_cpu_old_entry, oldinfo->size, cleanup_entry,NULL);
+	put_cpu();
+	free_table_info(oldinfo);
 	if (copy_to_user(tmp.counters, counters,
 			 sizeof(struct arpt_counters) * tmp.num_counters) !=3D 0)
 		ret =3D -EFAULT;
@@ -1002,11 +1064,12 @@ static int do_replace(void __user *user,
 	module_put(t->me);
 	up(&arpt_mutex);
  free_newinfo_counters_untrans:
-	ARPT_ENTRY_ITERATE(newinfo->entries, newinfo->size, cleanup_entry, NULL);
+	ARPT_ENTRY_ITERATE(loc_cpu_entry, newinfo->size, cleanup_entry, NULL);
  free_newinfo_counters:
 	vfree(counters);
  free_newinfo:
-	vfree(newinfo);
+	put_cpu();
+	free_table_info(newinfo);
 	return ret;
 }
=20
@@ -1030,6 +1093,7 @@ static int do_add_counters(void __user *
 	struct arpt_counters_info tmp, *paddc;
 	struct arpt_table *t;
 	int ret =3D 0;
+	void *loc_cpu_entry;
=20
 	if (copy_from_user(&tmp, user, sizeof(tmp)) !=3D 0)
 		return -EFAULT;
@@ -1059,7 +1123,9 @@ static int do_add_counters(void __user *
 	}
=20
 	i =3D 0;
-	ARPT_ENTRY_ITERATE(t->private->entries,
+	/* Choose the copy that is on our node */
+	loc_cpu_entry =3D t->private->entries[smp_processor_id()];
+	ARPT_ENTRY_ITERATE(loc_cpu_entry,
 			   t->private->size,
 			   add_counter_to_entry,
 			   paddc->counters,
@@ -1220,30 +1286,33 @@ int arpt_register_table(struct arpt_tabl
 	struct arpt_table_info *newinfo;
 	static struct arpt_table_info bootstrap
 		=3D { 0, 0, 0, { 0 }, { 0 }, { } };
+	void *loc_cpu_entry;
=20
-	newinfo =3D vmalloc(sizeof(struct arpt_table_info)
-			  + SMP_ALIGN(repl->size) *
-			  		(highest_possible_processor_id()+1));
+	newinfo =3D alloc_table_info(repl->size);
 	if (!newinfo) {
 		ret =3D -ENOMEM;
 		return ret;
 	}
-	memcpy(newinfo->entries, repl->entries, repl->size);
+
+	/* choose the copy on our node/cpu */
+	loc_cpu_entry =3D newinfo->entries[get_cpu()];
+	memcpy(loc_cpu_entry, repl->entries, repl->size);
=20
 	ret =3D translate_table(table->name, table->valid_hooks,
-			      newinfo, repl->size,
+			      newinfo, loc_cpu_entry, repl->size,
 			      repl->num_entries,
 			      repl->hook_entry,
 			      repl->underflow);
+	put_cpu();
 	duprintf("arpt_register_table: translate table gives %d\n", ret);
 	if (ret !=3D 0) {
-		vfree(newinfo);
+		free_table_info(newinfo);
 		return ret;
 	}
=20
 	ret =3D down_interruptible(&arpt_mutex);
 	if (ret !=3D 0) {
-		vfree(newinfo);
+		free_table_info(newinfo);
 		return ret;
 	}
=20
@@ -1272,20 +1341,24 @@ int arpt_register_table(struct arpt_tabl
 	return ret;
=20
  free_unlock:
-	vfree(newinfo);
+	free_table_info(newinfo);
 	goto unlock;
 }
=20
 void arpt_unregister_table(struct arpt_table *table)
 {
+	void *loc_cpu_entry;
+
 	down(&arpt_mutex);
 	LIST_DELETE(&arpt_tables, table);
 	up(&arpt_mutex);
=20
 	/* Decrease module usage counts and free resources */
-	ARPT_ENTRY_ITERATE(table->private->entries, table->private->size,
+	loc_cpu_entry =3D table->private->entries[get_cpu()];
+	ARPT_ENTRY_ITERATE(loc_cpu_entry, table->private->size,
 			   cleanup_entry, NULL);
-	vfree(table->private);
+	put_cpu();
+	free_table_info(table->private);
 }
=20
 /* The built-in targets: standard (NULL) and error. */
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -83,11 +83,6 @@ static DECLARE_MUTEX(ipt_mutex);
    context stops packets coming through and allows user context to read
    the counters or update the rules.
=20
-   To be cache friendly on SMP, we arrange them like so:
-   [ n-entries ]
-   ... cache-align padding ...
-   [ n-entries ]
-
    Hence the start of any table is given by get_table() below.  */
=20
 /* The table itself */
@@ -105,20 +100,15 @@ struct ipt_table_info
 	unsigned int underflow[NF_IP_NUMHOOKS];
=20
 	/* ipt_entry tables: one per CPU */
-	char entries[0] ____cacheline_aligned;
+	void *entries[NR_CPUS];
 };
=20
 static LIST_HEAD(ipt_target);
 static LIST_HEAD(ipt_match);
 static LIST_HEAD(ipt_tables);
+#define SET_COUNTER(c,b,p) do { (c).bcnt =3D (b); (c).pcnt =3D (p); } whil=
e(0)
 #define ADD_COUNTER(c,b,p) do { (c).bcnt +=3D (b); (c).pcnt +=3D (p); } wh=
ile(0)
=20
-#ifdef CONFIG_SMP
-#define TABLE_OFFSET(t,p) (SMP_ALIGN((t)->size)*(p))
-#else
-#define TABLE_OFFSET(t,p) 0
-#endif
-
 #if 0
 #define down(x) do { printk("DOWN:%u:" #x "\n", __LINE__); down(x); } whil=
e(0)
 #define down_interruptible(x) ({ int __r; printk("DOWNi:%u:" #x "\n", __LI=
NE__); __r =3D down_interruptible(x); if (__r !=3D 0) printk("ABORT-DOWNi:%=
u\n", __LINE__); __r; })
@@ -290,8 +280,7 @@ ipt_do_table(struct sk_buff **pskb,
=20
 	read_lock_bh(&table->lock);
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
-	table_base =3D (void *)table->private->entries
-		+ TABLE_OFFSET(table->private, smp_processor_id());
+	table_base =3D (void *)table->private->entries[smp_processor_id()];
 	e =3D get_entry(table_base, table->private->hook_entry[hook]);
=20
 #ifdef CONFIG_NETFILTER_DEBUG
@@ -563,7 +552,8 @@ unconditional(const struct ipt_ip *ip)
 /* Figures out from what hook each rule can be called: returns 0 if
    there are loops.  Puts hook bitmask in comefrom. */
 static int
-mark_source_chains(struct ipt_table_info *newinfo, unsigned int valid_hook=
s)
+mark_source_chains(struct ipt_table_info *newinfo,
+		   unsigned int valid_hooks, void *entry0)
 {
 	unsigned int hook;
=20
@@ -572,7 +562,7 @@ mark_source_chains(struct ipt_table_info
 	for (hook =3D 0; hook < NF_IP_NUMHOOKS; hook++) {
 		unsigned int pos =3D newinfo->hook_entry[hook];
 		struct ipt_entry *e
-			=3D (struct ipt_entry *)(newinfo->entries + pos);
+			=3D (struct ipt_entry *)(entry0 + pos);
=20
 		if (!(valid_hooks & (1 << hook)))
 			continue;
@@ -622,13 +612,13 @@ mark_source_chains(struct ipt_table_info
 						goto next;
=20
 					e =3D (struct ipt_entry *)
-						(newinfo->entries + pos);
+						(entry0 + pos);
 				} while (oldpos =3D=3D pos + e->next_offset);
=20
 				/* Move along one */
 				size =3D e->next_offset;
 				e =3D (struct ipt_entry *)
-					(newinfo->entries + pos + size);
+					(entry0 + pos + size);
 				e->counters.pcnt =3D pos;
 				pos +=3D size;
 			} else {
@@ -645,7 +635,7 @@ mark_source_chains(struct ipt_table_info
 					newpos =3D pos + e->next_offset;
 				}
 				e =3D (struct ipt_entry *)
-					(newinfo->entries + newpos);
+					(entry0 + newpos);
 				e->counters.pcnt =3D pos;
 				pos =3D newpos;
 			}
@@ -855,6 +845,7 @@ static int
 translate_table(const char *name,
 		unsigned int valid_hooks,
 		struct ipt_table_info *newinfo,
+		void *entry0,
 		unsigned int size,
 		unsigned int number,
 		const unsigned int *hook_entries,
@@ -875,11 +866,11 @@ translate_table(const char *name,
 	duprintf("translate_table: size %u\n", newinfo->size);
 	i =3D 0;
 	/* Walk through entries, checking offsets. */
-	ret =3D IPT_ENTRY_ITERATE(newinfo->entries, newinfo->size,
+	ret =3D IPT_ENTRY_ITERATE(entry0, newinfo->size,
 				check_entry_size_and_hooks,
 				newinfo,
-				newinfo->entries,
-				newinfo->entries + size,
+				entry0,
+				entry0 + size,
 				hook_entries, underflows, &i);
 	if (ret !=3D 0)
 		return ret;
@@ -907,27 +898,24 @@ translate_table(const char *name,
 		}
 	}
=20
-	if (!mark_source_chains(newinfo, valid_hooks))
+	if (!mark_source_chains(newinfo, valid_hooks, entry0))
 		return -ELOOP;
=20
 	/* Finally, each sanity check must pass */
 	i =3D 0;
-	ret =3D IPT_ENTRY_ITERATE(newinfo->entries, newinfo->size,
+	ret =3D IPT_ENTRY_ITERATE(entry0, newinfo->size,
 				check_entry, name, size, &i);
=20
 	if (ret !=3D 0) {
-		IPT_ENTRY_ITERATE(newinfo->entries, newinfo->size,
+		IPT_ENTRY_ITERATE(entry0, newinfo->size,
 				  cleanup_entry, &i);
 		return ret;
 	}
=20
 	/* And one copy for every other CPU */
 	for_each_cpu(i) {
-		if (i =3D=3D 0)
-			continue;
-		memcpy(newinfo->entries + SMP_ALIGN(newinfo->size) * i,
-		       newinfo->entries,
-		       SMP_ALIGN(newinfo->size));
+		if (newinfo->entries[i] && newinfo->entries[i] !=3D entry0)
+			memcpy(newinfo->entries[i], entry0, newinfo->size);
 	}
=20
 	return ret;
@@ -943,15 +931,12 @@ replace_table(struct ipt_table *table,
=20
 #ifdef CONFIG_NETFILTER_DEBUG
 	{
-		struct ipt_entry *table_base;
-		unsigned int i;
+		int cpu;
=20
-		for_each_cpu(i) {
-			table_base =3D
-				(void *)newinfo->entries
-				+ TABLE_OFFSET(newinfo, i);
-
-			table_base->comefrom =3D 0xdead57ac;
+		for_each_cpu(cpu) {
+			struct ipt_entry *table_base =3D newinfo->entries[cpu];
+			if (table_base)
+				table_base->comefrom =3D 0xdead57ac;
 		}
 	}
 #endif
@@ -986,21 +971,47 @@ add_entry_to_counter(const struct ipt_en
 	return 0;
 }
=20
+static inline int
+set_entry_to_counter(const struct ipt_entry *e,
+		     struct ipt_counters total[],
+		     unsigned int *i)
+{
+	SET_COUNTER(total[*i], e->counters.bcnt, e->counters.pcnt);
+
+	(*i)++;
+	return 0;
+}
+
 static void
 get_counters(const struct ipt_table_info *t,
 	     struct ipt_counters counters[])
 {
 	unsigned int cpu;
 	unsigned int i;
+	unsigned int curcpu =3D get_cpu();
+
+	/* Instead of clearing (by a previous call to memset())
+	 * the counters and using adds, we set the counters
+	 * with data used by current CPU */
+
+	i =3D 0;
+	IPT_ENTRY_ITERATE(t->entries[curcpu],
+			  t->size,
+			  set_entry_to_counter,
+			  counters,
+			  &i);
=20
 	for_each_cpu(cpu) {
+		if (cpu =3D=3D curcpu)
+			continue;
 		i =3D 0;
-		IPT_ENTRY_ITERATE(t->entries + TABLE_OFFSET(t, cpu),
+		IPT_ENTRY_ITERATE(t->entries[cpu],
 				  t->size,
 				  add_entry_to_counter,
 				  counters,
 				  &i);
 	}
+	put_cpu();
 }
=20
 static int
@@ -1012,6 +1023,7 @@ copy_entries_to_user(unsigned int total_
 	struct ipt_entry *e;
 	struct ipt_counters *counters;
 	int ret =3D 0;
+	void *loc_cpu_entry;
=20
 	/* We need atomic snapshot of counters: rest doesn't change
 	   (other than comefrom, which userspace doesn't care
@@ -1023,13 +1035,14 @@ copy_entries_to_user(unsigned int total_
 		return -ENOMEM;
=20
 	/* First, sum counters... */
-	memset(counters, 0, countersize);
 	write_lock_bh(&table->lock);
 	get_counters(table->private, counters);
 	write_unlock_bh(&table->lock);
=20
-	/* ... then copy entire thing from CPU 0... */
-	if (copy_to_user(userptr, table->private->entries, total_size) !=3D 0) {
+	/* choose the copy that is on our node/cpu, ... */
+	loc_cpu_entry =3D table->private->entries[get_cpu()];
+	/* ... then copy entire thing ... */
+	if (copy_to_user(userptr, loc_cpu_entry, total_size) !=3D 0) {
 		ret =3D -EFAULT;
 		goto free_counters;
 	}
@@ -1041,7 +1054,7 @@ copy_entries_to_user(unsigned int total_
 		struct ipt_entry_match *m;
 		struct ipt_entry_target *t;
=20
-		e =3D (struct ipt_entry *)(table->private->entries + off);
+		e =3D (struct ipt_entry *)(loc_cpu_entry + off);
 		if (copy_to_user(userptr + off
 				 + offsetof(struct ipt_entry, counters),
 				 &counters[num],
@@ -1078,6 +1091,7 @@ copy_entries_to_user(unsigned int total_
 	}
=20
  free_counters:
+	put_cpu();
 	vfree(counters);
 	return ret;
 }
@@ -1110,6 +1124,45 @@ get_entries(const struct ipt_get_entries
 	return ret;
 }
=20
+static void free_table_info(struct ipt_table_info *info)
+{
+	int cpu;
+	for_each_cpu(cpu) {
+		if (info->size <=3D PAGE_SIZE)
+			kfree(info->entries[cpu]);
+		else
+			vfree(info->entries[cpu]);
+	}
+	kfree(info);
+}
+
+static struct ipt_table_info *alloc_table_info(unsigned int size)
+{
+	struct ipt_table_info *newinfo;
+	int cpu;
+
+	newinfo =3D kzalloc(sizeof(struct ipt_table_info), GFP_KERNEL);
+	if (!newinfo)
+		return NULL;
+
+	newinfo->size =3D size;
+
+	for_each_cpu(cpu) {
+		if (size <=3D PAGE_SIZE)
+			newinfo->entries[cpu] =3D kmalloc_node(size,
+				GFP_KERNEL,
+				cpu_to_node(cpu));
+		else
+			newinfo->entries[cpu] =3D vmalloc_node(size, cpu_to_node(cpu));
+		if (newinfo->entries[cpu] =3D=3D 0) {
+			free_table_info(newinfo);
+			return NULL;
+		}
+	}
+
+	return newinfo;
+}
+
 static int
 do_replace(void __user *user, unsigned int len)
 {
@@ -1118,6 +1171,7 @@ do_replace(void __user *user, unsigned i
 	struct ipt_table *t;
 	struct ipt_table_info *newinfo, *oldinfo;
 	struct ipt_counters *counters;
+	void *loc_cpu_entry, *loc_cpu_old_entry;
=20
 	if (copy_from_user(&tmp, user, sizeof(tmp)) !=3D 0)
 		return -EFAULT;
@@ -1130,13 +1184,13 @@ do_replace(void __user *user, unsigned i
 	if ((SMP_ALIGN(tmp.size) >> PAGE_SHIFT) + 2 > num_physpages)
 		return -ENOMEM;
=20
-	newinfo =3D vmalloc(sizeof(struct ipt_table_info)
-			  + SMP_ALIGN(tmp.size) *=20
-			  	(highest_possible_processor_id()+1));
+	newinfo =3D alloc_table_info(tmp.size);
 	if (!newinfo)
 		return -ENOMEM;
=20
-	if (copy_from_user(newinfo->entries, user + sizeof(tmp),
+	/* choose the copy that is our node/cpu */
+	loc_cpu_entry =3D newinfo->entries[get_cpu()];
+	if (copy_from_user(loc_cpu_entry, user + sizeof(tmp),
 			   tmp.size) !=3D 0) {
 		ret =3D -EFAULT;
 		goto free_newinfo;
@@ -1147,10 +1201,9 @@ do_replace(void __user *user, unsigned i
 		ret =3D -ENOMEM;
 		goto free_newinfo;
 	}
-	memset(counters, 0, tmp.num_counters * sizeof(struct ipt_counters));
=20
 	ret =3D translate_table(tmp.name, tmp.valid_hooks,
-			      newinfo, tmp.size, tmp.num_entries,
+			      newinfo, loc_cpu_entry, tmp.size, tmp.num_entries,
 			      tmp.hook_entry, tmp.underflow);
 	if (ret !=3D 0)
 		goto free_newinfo_counters;
@@ -1189,8 +1242,10 @@ do_replace(void __user *user, unsigned i
 	/* Get the old counters. */
 	get_counters(oldinfo, counters);
 	/* Decrease module usage counts and free resource */
-	IPT_ENTRY_ITERATE(oldinfo->entries, oldinfo->size, cleanup_entry,NULL);
-	vfree(oldinfo);
+	loc_cpu_old_entry =3D oldinfo->entries[smp_processor_id()];
+	IPT_ENTRY_ITERATE(loc_cpu_old_entry, oldinfo->size, cleanup_entry,NULL);
+	put_cpu();
+	free_table_info(oldinfo);
 	if (copy_to_user(tmp.counters, counters,
 			 sizeof(struct ipt_counters) * tmp.num_counters) !=3D 0)
 		ret =3D -EFAULT;
@@ -1202,11 +1257,12 @@ do_replace(void __user *user, unsigned i
 	module_put(t->me);
 	up(&ipt_mutex);
  free_newinfo_counters_untrans:
-	IPT_ENTRY_ITERATE(newinfo->entries, newinfo->size, cleanup_entry,NULL);
+	IPT_ENTRY_ITERATE(loc_cpu_entry, newinfo->size, cleanup_entry,NULL);
  free_newinfo_counters:
 	vfree(counters);
  free_newinfo:
-	vfree(newinfo);
+	put_cpu();
+	free_table_info(newinfo);
 	return ret;
 }
=20
@@ -1239,6 +1295,7 @@ do_add_counters(void __user *user, unsig
 	struct ipt_counters_info tmp, *paddc;
 	struct ipt_table *t;
 	int ret =3D 0;
+	void *loc_cpu_entry;
=20
 	if (copy_from_user(&tmp, user, sizeof(tmp)) !=3D 0)
 		return -EFAULT;
@@ -1268,7 +1325,9 @@ do_add_counters(void __user *user, unsig
 	}
=20
 	i =3D 0;
-	IPT_ENTRY_ITERATE(t->private->entries,
+	/* Choose the copy that is on our node */
+	loc_cpu_entry =3D t->private->entries[smp_processor_id()];
+	IPT_ENTRY_ITERATE(loc_cpu_entry,
 			  t->private->size,
 			  add_counter_to_entry,
 			  paddc->counters,
@@ -1460,28 +1519,30 @@ int ipt_register_table(struct ipt_table=20
 	struct ipt_table_info *newinfo;
 	static struct ipt_table_info bootstrap
 		=3D { 0, 0, 0, { 0 }, { 0 }, { } };
+	void *loc_cpu_entry;
=20
-	newinfo =3D vmalloc(sizeof(struct ipt_table_info)
-			  + SMP_ALIGN(repl->size) *=20
-			  		(highest_possible_processor_id()+1));
+	newinfo =3D alloc_table_info(repl->size);
 	if (!newinfo)
 		return -ENOMEM;
=20
-	memcpy(newinfo->entries, repl->entries, repl->size);
+	/* choose the copy on our node/cpu */
+	loc_cpu_entry =3D newinfo->entries[get_cpu()];
+	memcpy(loc_cpu_entry, repl->entries, repl->size);
=20
 	ret =3D translate_table(table->name, table->valid_hooks,
-			      newinfo, repl->size,
+			      newinfo, loc_cpu_entry, repl->size,
 			      repl->num_entries,
 			      repl->hook_entry,
 			      repl->underflow);
+	put_cpu();
 	if (ret !=3D 0) {
-		vfree(newinfo);
+		free_table_info(newinfo);
 		return ret;
 	}
=20
 	ret =3D down_interruptible(&ipt_mutex);
 	if (ret !=3D 0) {
-		vfree(newinfo);
+		free_table_info(newinfo);
 		return ret;
 	}
=20
@@ -1510,20 +1571,24 @@ int ipt_register_table(struct ipt_table=20
 	return ret;
=20
  free_unlock:
-	vfree(newinfo);
+	free_table_info(newinfo);
 	goto unlock;
 }
=20
 void ipt_unregister_table(struct ipt_table *table)
 {
+	void *loc_cpu_entry;
+
 	down(&ipt_mutex);
 	LIST_DELETE(&ipt_tables, table);
 	up(&ipt_mutex);
=20
 	/* Decrease module usage counts and free resources */
-	IPT_ENTRY_ITERATE(table->private->entries, table->private->size,
+	loc_cpu_entry =3D table->private->entries[get_cpu()];
+	IPT_ENTRY_ITERATE(loc_cpu_entry, table->private->size,
 			  cleanup_entry, NULL);
-	vfree(table->private);
+	put_cpu();
+	free_table_info(table->private);
 }
=20
 /* Returns 1 if the port is matched by the range, 0 otherwise */
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_table=
s.c
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -86,11 +86,6 @@ static DECLARE_MUTEX(ip6t_mutex);
    context stops packets coming through and allows user context to read
    the counters or update the rules.
=20
-   To be cache friendly on SMP, we arrange them like so:
-   [ n-entries ]
-   ... cache-align padding ...
-   [ n-entries ]
-
    Hence the start of any table is given by get_table() below.  */
=20
 /* The table itself */
@@ -108,20 +103,15 @@ struct ip6t_table_info
 	unsigned int underflow[NF_IP6_NUMHOOKS];
=20
 	/* ip6t_entry tables: one per CPU */
-	char entries[0] ____cacheline_aligned;
+	void *entries[NR_CPUS];
 };
=20
 static LIST_HEAD(ip6t_target);
 static LIST_HEAD(ip6t_match);
 static LIST_HEAD(ip6t_tables);
+#define SET_COUNTER(c,b,p) do { (c).bcnt =3D (b); (c).pcnt =3D (p); } whil=
e(0)
 #define ADD_COUNTER(c,b,p) do { (c).bcnt +=3D (b); (c).pcnt +=3D (p); } wh=
ile(0)
=20
-#ifdef CONFIG_SMP
-#define TABLE_OFFSET(t,p) (SMP_ALIGN((t)->size)*(p))
-#else
-#define TABLE_OFFSET(t,p) 0
-#endif
-
 #if 0
 #define down(x) do { printk("DOWN:%u:" #x "\n", __LINE__); down(x); } whil=
e(0)
 #define down_interruptible(x) ({ int __r; printk("DOWNi:%u:" #x "\n", __LI=
NE__); __r =3D down_interruptible(x); if (__r !=3D 0) printk("ABORT-DOWNi:%=
u\n", __LINE__); __r; })
@@ -376,8 +366,7 @@ ip6t_do_table(struct sk_buff **pskb,
=20
 	read_lock_bh(&table->lock);
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
-	table_base =3D (void *)table->private->entries
-		+ TABLE_OFFSET(table->private, smp_processor_id());
+	table_base =3D (void *)table->private->entries[smp_processor_id()];
 	e =3D get_entry(table_base, table->private->hook_entry[hook]);
=20
 #ifdef CONFIG_NETFILTER_DEBUG
@@ -649,7 +638,8 @@ unconditional(const struct ip6t_ip6 *ipv
 /* Figures out from what hook each rule can be called: returns 0 if
    there are loops.  Puts hook bitmask in comefrom. */
 static int
-mark_source_chains(struct ip6t_table_info *newinfo, unsigned int valid_hoo=
ks)
+mark_source_chains(struct ip6t_table_info *newinfo,
+		   unsigned int valid_hooks, void *entry0)
 {
 	unsigned int hook;
=20
@@ -658,7 +648,7 @@ mark_source_chains(struct ip6t_table_inf
 	for (hook =3D 0; hook < NF_IP6_NUMHOOKS; hook++) {
 		unsigned int pos =3D newinfo->hook_entry[hook];
 		struct ip6t_entry *e
-			=3D (struct ip6t_entry *)(newinfo->entries + pos);
+			=3D (struct ip6t_entry *)(entry0 + pos);
=20
 		if (!(valid_hooks & (1 << hook)))
 			continue;
@@ -708,13 +698,13 @@ mark_source_chains(struct ip6t_table_inf
 						goto next;
=20
 					e =3D (struct ip6t_entry *)
-						(newinfo->entries + pos);
+						(entry0 + pos);
 				} while (oldpos =3D=3D pos + e->next_offset);
=20
 				/* Move along one */
 				size =3D e->next_offset;
 				e =3D (struct ip6t_entry *)
-					(newinfo->entries + pos + size);
+					(entry0 + pos + size);
 				e->counters.pcnt =3D pos;
 				pos +=3D size;
 			} else {
@@ -731,7 +721,7 @@ mark_source_chains(struct ip6t_table_inf
 					newpos =3D pos + e->next_offset;
 				}
 				e =3D (struct ip6t_entry *)
-					(newinfo->entries + newpos);
+					(entry0 + newpos);
 				e->counters.pcnt =3D pos;
 				pos =3D newpos;
 			}
@@ -941,6 +931,7 @@ static int
 translate_table(const char *name,
 		unsigned int valid_hooks,
 		struct ip6t_table_info *newinfo,
+		void *entry0,
 		unsigned int size,
 		unsigned int number,
 		const unsigned int *hook_entries,
@@ -964,8 +955,8 @@ translate_table(const char *name,
 	ret =3D IP6T_ENTRY_ITERATE(newinfo->entries, newinfo->size,
 				check_entry_size_and_hooks,
 				newinfo,
-				newinfo->entries,
-				newinfo->entries + size,
+				entry0,
+				entry0 + size,
 				hook_entries, underflows, &i);
 	if (ret !=3D 0)
 		return ret;
@@ -993,27 +984,24 @@ translate_table(const char *name,
 		}
 	}
=20
-	if (!mark_source_chains(newinfo, valid_hooks))
+	if (!mark_source_chains(newinfo, valid_hooks, entry0))
 		return -ELOOP;
=20
 	/* Finally, each sanity check must pass */
 	i =3D 0;
-	ret =3D IP6T_ENTRY_ITERATE(newinfo->entries, newinfo->size,
+	ret =3D IP6T_ENTRY_ITERATE(entry0, newinfo->size,
 				check_entry, name, size, &i);
=20
 	if (ret !=3D 0) {
-		IP6T_ENTRY_ITERATE(newinfo->entries, newinfo->size,
+		IP6T_ENTRY_ITERATE(entry0, newinfo->size,
 				  cleanup_entry, &i);
 		return ret;
 	}
=20
 	/* And one copy for every other CPU */
 	for_each_cpu(i) {
-		if (i =3D=3D 0)
-			continue;
-		memcpy(newinfo->entries + SMP_ALIGN(newinfo->size) * i,
-		       newinfo->entries,
-		       SMP_ALIGN(newinfo->size));
+		if (newinfo->entries[i] && newinfo->entries[i] !=3D entry0)
+			memcpy(newinfo->entries[i], entry0, newinfo->size);
 	}
=20
 	return ret;
@@ -1029,15 +1017,12 @@ replace_table(struct ip6t_table *table,
=20
 #ifdef CONFIG_NETFILTER_DEBUG
 	{
-		struct ip6t_entry *table_base;
-		unsigned int i;
-
-		for_each_cpu(i) {
-			table_base =3D
-				(void *)newinfo->entries
-				+ TABLE_OFFSET(newinfo, i);
+		int cpu;
=20
-			table_base->comefrom =3D 0xdead57ac;
+		for_each_cpu(cpu) {
+			struct ip6t_entry *table_base =3D newinfo->entries[cpu];
+			if (table_base)
+				table_base->comefrom =3D 0xdead57ac;
 		}
 	}
 #endif
@@ -1072,21 +1057,47 @@ add_entry_to_counter(const struct ip6t_e
 	return 0;
 }
=20
+static inline int
+set_entry_to_counter(const struct ip6t_entry *e,
+		     struct ip6t_counters total[],
+		     unsigned int *i)
+{
+	SET_COUNTER(total[*i], e->counters.bcnt, e->counters.pcnt);
+
+	(*i)++;
+	return 0;
+}
+
 static void
 get_counters(const struct ip6t_table_info *t,
 	     struct ip6t_counters counters[])
 {
 	unsigned int cpu;
 	unsigned int i;
+	unsigned int curcpu =3D get_cpu();
+
+	/* Instead of clearing (by a previous call to memset())
+	 * the counters and using adds, we set the counters
+	 * with data used by current CPU */
+
+	i =3D 0;
+	IP6T_ENTRY_ITERATE(t->entries[curcpu],
+			   t->size,
+			   set_entry_to_counter,
+			   counters,
+			   &i);
=20
 	for_each_cpu(cpu) {
+		if (cpu =3D=3D curcpu)
+			continue;
 		i =3D 0;
-		IP6T_ENTRY_ITERATE(t->entries + TABLE_OFFSET(t, cpu),
+		IP6T_ENTRY_ITERATE(t->entries[cpu],
 				  t->size,
 				  add_entry_to_counter,
 				  counters,
 				  &i);
 	}
+	put_cpu();
 }
=20
 static int
@@ -1098,6 +1109,7 @@ copy_entries_to_user(unsigned int total_
 	struct ip6t_entry *e;
 	struct ip6t_counters *counters;
 	int ret =3D 0;
+	void *loc_cpu_entry;
=20
 	/* We need atomic snapshot of counters: rest doesn't change
 	   (other than comefrom, which userspace doesn't care
@@ -1109,13 +1121,13 @@ copy_entries_to_user(unsigned int total_
 		return -ENOMEM;
=20
 	/* First, sum counters... */
-	memset(counters, 0, countersize);
 	write_lock_bh(&table->lock);
 	get_counters(table->private, counters);
 	write_unlock_bh(&table->lock);
=20
-	/* ... then copy entire thing from CPU 0... */
-	if (copy_to_user(userptr, table->private->entries, total_size) !=3D 0) {
+	/* choose the copy that is on ourc node/cpu */
+	loc_cpu_entry =3D table->private->entries[get_cpu()];
+	if (copy_to_user(userptr, loc_cpu_entry, total_size) !=3D 0) {
 		ret =3D -EFAULT;
 		goto free_counters;
 	}
@@ -1127,7 +1139,7 @@ copy_entries_to_user(unsigned int total_
 		struct ip6t_entry_match *m;
 		struct ip6t_entry_target *t;
=20
-		e =3D (struct ip6t_entry *)(table->private->entries + off);
+		e =3D (struct ip6t_entry *)(loc_cpu_entry + off);
 		if (copy_to_user(userptr + off
 				 + offsetof(struct ip6t_entry, counters),
 				 &counters[num],
@@ -1164,6 +1176,7 @@ copy_entries_to_user(unsigned int total_
 	}
=20
  free_counters:
+	put_cpu();
 	vfree(counters);
 	return ret;
 }
@@ -1196,6 +1209,46 @@ get_entries(const struct ip6t_get_entrie
 	return ret;
 }
=20
+static void free_table_info(struct ip6t_table_info *info)
+{
+	int cpu;
+	for_each_cpu(cpu) {
+		if (info->size <=3D PAGE_SIZE)
+			kfree(info->entries[cpu]);
+		else
+			vfree(info->entries[cpu]);
+	}
+	kfree(info);
+}
+
+static struct ip6t_table_info *alloc_table_info(unsigned int size)
+{
+	struct ip6t_table_info *newinfo;
+	int cpu;
+
+	newinfo =3D kzalloc(sizeof(struct ip6t_table_info), GFP_KERNEL);
+	if (!newinfo)
+		return NULL;
+
+	newinfo->size =3D size;
+
+	for_each_cpu(cpu) {
+		if (size <=3D PAGE_SIZE)
+			newinfo->entries[cpu] =3D kmalloc_node(size,
+							GFP_KERNEL,
+							cpu_to_node(cpu));
+		else
+			newinfo->entries[cpu] =3D vmalloc_node(size,
+							     cpu_to_node(cpu));
+		if (newinfo->entries[cpu] =3D=3D NULL) {
+			free_table_info(newinfo);
+			return NULL;
+		}
+	}
+
+	return newinfo;
+}
+
 static int
 do_replace(void __user *user, unsigned int len)
 {
@@ -1204,6 +1257,7 @@ do_replace(void __user *user, unsigned i
 	struct ip6t_table *t;
 	struct ip6t_table_info *newinfo, *oldinfo;
 	struct ip6t_counters *counters;
+	void *loc_cpu_entry, *loc_cpu_old_entry;
=20
 	if (copy_from_user(&tmp, user, sizeof(tmp)) !=3D 0)
 		return -EFAULT;
@@ -1212,13 +1266,13 @@ do_replace(void __user *user, unsigned i
 	if ((SMP_ALIGN(tmp.size) >> PAGE_SHIFT) + 2 > num_physpages)
 		return -ENOMEM;
=20
-	newinfo =3D vmalloc(sizeof(struct ip6t_table_info)
-			  + SMP_ALIGN(tmp.size) *
-			  		(highest_possible_processor_id()+1));
+	newinfo =3D alloc_table_info(tmp.size);
 	if (!newinfo)
 		return -ENOMEM;
=20
-	if (copy_from_user(newinfo->entries, user + sizeof(tmp),
+	/* choose the copy that is on our node/cpu */
+	loc_cpu_entry =3D newinfo->entries[get_cpu()];
+	if (copy_from_user(loc_cpu_entry, user + sizeof(tmp),
 			   tmp.size) !=3D 0) {
 		ret =3D -EFAULT;
 		goto free_newinfo;
@@ -1229,10 +1283,9 @@ do_replace(void __user *user, unsigned i
 		ret =3D -ENOMEM;
 		goto free_newinfo;
 	}
-	memset(counters, 0, tmp.num_counters * sizeof(struct ip6t_counters));
=20
 	ret =3D translate_table(tmp.name, tmp.valid_hooks,
-			      newinfo, tmp.size, tmp.num_entries,
+			      newinfo, loc_cpu_entry, tmp.size, tmp.num_entries,
 			      tmp.hook_entry, tmp.underflow);
 	if (ret !=3D 0)
 		goto free_newinfo_counters;
@@ -1271,8 +1324,10 @@ do_replace(void __user *user, unsigned i
 	/* Get the old counters. */
 	get_counters(oldinfo, counters);
 	/* Decrease module usage counts and free resource */
-	IP6T_ENTRY_ITERATE(oldinfo->entries, oldinfo->size, cleanup_entry,NULL);
-	vfree(oldinfo);
+	loc_cpu_old_entry =3D oldinfo->entries[smp_processor_id()];
+	IP6T_ENTRY_ITERATE(loc_cpu_old_entry, oldinfo->size, cleanup_entry,NULL);
+	put_cpu();
+	free_table_info(oldinfo);
 	if (copy_to_user(tmp.counters, counters,
 			 sizeof(struct ip6t_counters) * tmp.num_counters) !=3D 0)
 		ret =3D -EFAULT;
@@ -1284,11 +1339,12 @@ do_replace(void __user *user, unsigned i
 	module_put(t->me);
 	up(&ip6t_mutex);
  free_newinfo_counters_untrans:
-	IP6T_ENTRY_ITERATE(newinfo->entries, newinfo->size, cleanup_entry,NULL);
+	IP6T_ENTRY_ITERATE(loc_cpu_entry, newinfo->size, cleanup_entry,NULL);
  free_newinfo_counters:
 	vfree(counters);
  free_newinfo:
-	vfree(newinfo);
+	put_cpu();
+	free_table_info(newinfo);
 	return ret;
 }
=20
@@ -1321,6 +1377,7 @@ do_add_counters(void __user *user, unsig
 	struct ip6t_counters_info tmp, *paddc;
 	struct ip6t_table *t;
 	int ret =3D 0;
+	void *loc_cpu_entry;
=20
 	if (copy_from_user(&tmp, user, sizeof(tmp)) !=3D 0)
 		return -EFAULT;
@@ -1350,7 +1407,9 @@ do_add_counters(void __user *user, unsig
 	}
=20
 	i =3D 0;
-	IP6T_ENTRY_ITERATE(t->private->entries,
+	/* Choose the copy that is on our node */
+	loc_cpu_entry =3D t->private->entries[smp_processor_id()];
+	IP6T_ENTRY_ITERATE(loc_cpu_entry,
 			  t->private->size,
 			  add_counter_to_entry,
 			  paddc->counters,
@@ -1543,28 +1602,30 @@ int ip6t_register_table(struct ip6t_tabl
 	struct ip6t_table_info *newinfo;
 	static struct ip6t_table_info bootstrap
 		=3D { 0, 0, 0, { 0 }, { 0 }, { } };
+	void *loc_cpu_entry;
=20
-	newinfo =3D vmalloc(sizeof(struct ip6t_table_info)
-			  + SMP_ALIGN(repl->size) *
-			  		(highest_possible_processor_id()+1));
+	newinfo =3D alloc_table_info(repl->size);
 	if (!newinfo)
 		return -ENOMEM;
=20
-	memcpy(newinfo->entries, repl->entries, repl->size);
+	/* choose the copy on our node/cpu */
+	loc_cpu_entry =3D newinfo->entries[get_cpu()];
+	memcpy(loc_cpu_entry, repl->entries, repl->size);
=20
 	ret =3D translate_table(table->name, table->valid_hooks,
-			      newinfo, repl->size,
+			      newinfo, loc_cpu_entry, repl->size,
 			      repl->num_entries,
 			      repl->hook_entry,
 			      repl->underflow);
+	put_cpu();
 	if (ret !=3D 0) {
-		vfree(newinfo);
+		free_table_info(newinfo);
 		return ret;
 	}
=20
 	ret =3D down_interruptible(&ip6t_mutex);
 	if (ret !=3D 0) {
-		vfree(newinfo);
+		free_table_info(newinfo);
 		return ret;
 	}
=20
@@ -1593,20 +1654,24 @@ int ip6t_register_table(struct ip6t_tabl
 	return ret;
=20
  free_unlock:
-	vfree(newinfo);
+	free_table_info(newinfo);
 	goto unlock;
 }
=20
 void ip6t_unregister_table(struct ip6t_table *table)
 {
+	void *loc_cpu_entry;
+
 	down(&ip6t_mutex);
 	LIST_DELETE(&ip6t_tables, table);
 	up(&ip6t_mutex);
=20
 	/* Decrease module usage counts and free resources */
-	IP6T_ENTRY_ITERATE(table->private->entries, table->private->size,
+	loc_cpu_entry =3D table->private->entries[get_cpu()];
+	IP6T_ENTRY_ITERATE(loc_cpu_entry, table->private->size,
 			  cleanup_entry, NULL);
-	vfree(table->private);
+	put_cpu();
+	free_table_info(table->private);
 }
=20
 /* Returns 1 if the port is matched by the range, 0 otherwise */

--oXNgvKVxGWJ0RPMJ--

--K1n7F7fSdjvFAEnM
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQFDfJcQXaXGVTD0i/8RAtSuAJsGL0k3SG5OZ2bM2GQALiqzPQrtTQCeJtSd
iRlxN6Rf9vPXnO6ab+Mzy0g=
=j5n7
-----END PGP SIGNATURE-----

--K1n7F7fSdjvFAEnM--
