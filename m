From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Reduce netfilter memory use on MP systems
Date: Fri, 04 Feb 2005 19:13:34 +0100
Message-ID: <4203BB4E.3070908@trash.net>
References: <20050204140900.GD2518@wotan.suse.de>
	<1107538482.1111.6.camel@tux.rsn.bth.se>
	<20050204175134.GD2737@wotan.suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------000409090703040601060603"
Cc: netdev@oss.sgi.com, Netfilter-devel <netfilter-devel@lists.netfilter.org>,
	Martin Josefsson <gandalf@wlug.westbo.se>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20050204175134.GD2737@wotan.suse.de>
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

This is a multi-part message in MIME format.
--------------000409090703040601060603
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Andi Kleen wrote:

>The main motivation is actually not to save the memory (that's just
>a useful side effect), but increase the max limit on 64bit systems.
>Fixing it fully will require fixing vmalloc of course, but it already
>help. Without it you can't get more than ~3800 rules
>on a 64bit system with NR_CPUS==128 and 128 byte cache lines.
>
Thanks Andi, I've added the patch to my 2.6.12 tree. I've also made the
same change in arp_tables, ip6_tables and ebtables for consistency.

Regards
Patrick


--------------000409090703040601060603
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

===== net/bridge/netfilter/ebtables.c 1.17 vs edited =====
--- 1.17/net/bridge/netfilter/ebtables.c	2004-11-24 08:46:46 +01:00
+++ edited/net/bridge/netfilter/ebtables.c	2005-02-04 19:03:01 +01:00
@@ -822,10 +822,10 @@
 		/* this will get free'd in do_replace()/ebt_register_table()
 		   if an error occurs */
 		newinfo->chainstack = (struct ebt_chainstack **)
-		   vmalloc(NR_CPUS * sizeof(struct ebt_chainstack));
+		   vmalloc(num_possible_cpus() * sizeof(struct ebt_chainstack));
 		if (!newinfo->chainstack)
 			return -ENOMEM;
-		for (i = 0; i < NR_CPUS; i++) {
+		for (i = 0; i < num_possible_cpus(); i++) {
 			newinfo->chainstack[i] =
 			   vmalloc(udc_cnt * sizeof(struct ebt_chainstack));
 			if (!newinfo->chainstack[i]) {
@@ -898,7 +898,7 @@
 	memcpy(counters, oldcounters,
 	   sizeof(struct ebt_counter) * nentries);
 	/* add other counters to those of cpu 0 */
-	for (cpu = 1; cpu < NR_CPUS; cpu++) {
+	for (cpu = 1; cpu < num_possible_cpus(); cpu++) {
 		counter_base = COUNTER_BASE(oldcounters, nentries, cpu);
 		for (i = 0; i < nentries; i++) {
 			counters[i].pcnt += counter_base[i].pcnt;
@@ -930,7 +930,7 @@
 		BUGPRINT("Entries_size never zero\n");
 		return -EINVAL;
 	}
-	countersize = COUNTER_OFFSET(tmp.nentries) * NR_CPUS;
+	countersize = COUNTER_OFFSET(tmp.nentries) * num_possible_cpus();
 	newinfo = (struct ebt_table_info *)
 	   vmalloc(sizeof(struct ebt_table_info) + countersize);
 	if (!newinfo)
@@ -1023,7 +1023,7 @@
 
 	vfree(table->entries);
 	if (table->chainstack) {
-		for (i = 0; i < NR_CPUS; i++)
+		for (i = 0; i < num_possible_cpus(); i++)
 			vfree(table->chainstack[i]);
 		vfree(table->chainstack);
 	}
@@ -1043,7 +1043,7 @@
 		vfree(counterstmp);
 	/* can be initialized in translate_table() */
 	if (newinfo->chainstack) {
-		for (i = 0; i < NR_CPUS; i++)
+		for (i = 0; i < num_possible_cpus(); i++)
 			vfree(newinfo->chainstack[i]);
 		vfree(newinfo->chainstack);
 	}
@@ -1137,7 +1137,7 @@
 		return -EINVAL;
 	}
 
-	countersize = COUNTER_OFFSET(table->table->nentries) * NR_CPUS;
+	countersize = COUNTER_OFFSET(table->table->nentries) * num_possible_cpus();
 	newinfo = (struct ebt_table_info *)
 	   vmalloc(sizeof(struct ebt_table_info) + countersize);
 	ret = -ENOMEM;
@@ -1191,7 +1191,7 @@
 	up(&ebt_mutex);
 free_chainstack:
 	if (newinfo->chainstack) {
-		for (i = 0; i < NR_CPUS; i++)
+		for (i = 0; i < num_possible_cpus(); i++)
 			vfree(newinfo->chainstack[i]);
 		vfree(newinfo->chainstack);
 	}
@@ -1215,7 +1215,7 @@
 	if (table->private->entries)
 		vfree(table->private->entries);
 	if (table->private->chainstack) {
-		for (i = 0; i < NR_CPUS; i++)
+		for (i = 0; i < num_possible_cpus(); i++)
 			vfree(table->private->chainstack[i]);
 		vfree(table->private->chainstack);
 	}
===== net/ipv4/netfilter/arp_tables.c 1.23 vs edited =====
--- 1.23/net/ipv4/netfilter/arp_tables.c	2005-01-11 03:45:54 +01:00
+++ edited/net/ipv4/netfilter/arp_tables.c	2005-02-04 19:01:20 +01:00
@@ -717,7 +717,7 @@
 	}
 
 	/* And one copy for every other CPU */
-	for (i = 1; i < NR_CPUS; i++) {
+	for (i = 1; i < num_possible_cpus(); i++) {
 		memcpy(newinfo->entries + SMP_ALIGN(newinfo->size)*i,
 		       newinfo->entries,
 		       SMP_ALIGN(newinfo->size));
@@ -768,7 +768,7 @@
 	unsigned int cpu;
 	unsigned int i;
 
-	for (cpu = 0; cpu < NR_CPUS; cpu++) {
+	for (cpu = 0; cpu < num_possible_cpus(); cpu++) {
 		i = 0;
 		ARPT_ENTRY_ITERATE(t->entries + TABLE_OFFSET(t, cpu),
 				   t->size,
@@ -886,7 +886,7 @@
 		return -ENOMEM;
 
 	newinfo = vmalloc(sizeof(struct arpt_table_info)
-			  + SMP_ALIGN(tmp.size) * NR_CPUS);
+			  + SMP_ALIGN(tmp.size) * num_possible_cpus());
 	if (!newinfo)
 		return -ENOMEM;
 
@@ -1159,7 +1159,7 @@
 		= { 0, 0, 0, { 0 }, { 0 }, { } };
 
 	newinfo = vmalloc(sizeof(struct arpt_table_info)
-			  + SMP_ALIGN(repl->size) * NR_CPUS);
+			  + SMP_ALIGN(repl->size) * num_possible_cpus());
 	if (!newinfo) {
 		ret = -ENOMEM;
 		return ret;
===== net/ipv6/netfilter/ip6_tables.c 1.39 vs edited =====
--- 1.39/net/ipv6/netfilter/ip6_tables.c	2005-01-11 03:45:54 +01:00
+++ edited/net/ipv6/netfilter/ip6_tables.c	2005-02-04 19:01:55 +01:00
@@ -952,7 +952,7 @@
 	}
 
 	/* And one copy for every other CPU */
-	for (i = 1; i < NR_CPUS; i++) {
+	for (i = 1; i < num_possible_cpus(); i++) {
 		memcpy(newinfo->entries + SMP_ALIGN(newinfo->size)*i,
 		       newinfo->entries,
 		       SMP_ALIGN(newinfo->size));
@@ -974,7 +974,7 @@
 		struct ip6t_entry *table_base;
 		unsigned int i;
 
-		for (i = 0; i < NR_CPUS; i++) {
+		for (i = 0; i < num_possible_cpus(); i++) {
 			table_base =
 				(void *)newinfo->entries
 				+ TABLE_OFFSET(newinfo, i);
@@ -1021,7 +1021,7 @@
 	unsigned int cpu;
 	unsigned int i;
 
-	for (cpu = 0; cpu < NR_CPUS; cpu++) {
+	for (cpu = 0; cpu < num_possible_cpus(); cpu++) {
 		i = 0;
 		IP6T_ENTRY_ITERATE(t->entries + TABLE_OFFSET(t, cpu),
 				  t->size,
@@ -1155,7 +1155,7 @@
 		return -ENOMEM;
 
 	newinfo = vmalloc(sizeof(struct ip6t_table_info)
-			  + SMP_ALIGN(tmp.size) * NR_CPUS);
+			  + SMP_ALIGN(tmp.size) * num_possible_cpus());
 	if (!newinfo)
 		return -ENOMEM;
 
@@ -1469,7 +1469,7 @@
 		= { 0, 0, 0, { 0 }, { 0 }, { } };
 
 	newinfo = vmalloc(sizeof(struct ip6t_table_info)
-			  + SMP_ALIGN(repl->size) * NR_CPUS);
+			  + SMP_ALIGN(repl->size) * num_possible_cpus());
 	if (!newinfo)
 		return -ENOMEM;
 

--------------000409090703040601060603--
