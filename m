From: Olaf Hering <olh@suse.de>
Subject: Re: limited number if iptable rules on 64bit hosts
Date: Thu, 3 Feb 2005 19:59:28 +0100
Message-ID: <20050203185928.GA22832@suse.de>
References: <20050202133851.GA9680@suse.de> <20050202222516.GA15440@suse.de> <20050202223853.GA29237@ti64.telemetry-investments.com> <20050202225258.GA15563@suse.de> <20050203111939.GI31570@suse.de> <20050203104822.05be3281.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Olaf Kirch <okir@suse.de>, brugolsky@telemetry-investments.com,
        netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050203104822.05be3281.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 On Thu, Feb 03, David S. Miller wrote:

> On Thu, 3 Feb 2005 12:19:39 +0100
> Olaf Kirch <okir@suse.de> wrote:
> 
> > At 3445 rules, tmp.size is 524272 (why does it want that much memory? I
> > would expect the only data that's per-CPU is the packet and byte
> > counters).
> 
> The rule itself is replicated per-cpu as well to keep L2 cache
> accesses local per cpu on SMP systems.

Andy made this change, which helped on a dual box.


diff -u linux-2.6.5/net/ipv4/netfilter/ip_tables.c-o linux-2.6.5/net/ipv4/netfilter/ip_tables.c
--- linux-2.6.5/net/ipv4/netfilter/ip_tables.c-o	2005-02-03 08:06:33.000000000 +0100
+++ linux-2.6.5/net/ipv4/netfilter/ip_tables.c	2005-02-03 13:06:32.163182472 +0100
@@ -29,6 +29,12 @@
 
 #include <linux/netfilter_ipv4/ip_tables.h>
 
+#ifdef CONFIG_HOTPLUG_CPU
+#define NF_NR_CPUS NR_CPUS
+#else
+#define NF_NR_CPUS num_online_cpus() 
+#endif
+
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
 MODULE_DESCRIPTION("IPv4 packet filter");
@@ -860,7 +866,7 @@
 	}
 
 	/* And one copy for every other CPU */
-	for (i = 1; i < NR_CPUS; i++) {
+	for (i = 1; i < NF_NR_CPUS; i++) {
 		memcpy(newinfo->entries + SMP_ALIGN(newinfo->size)*i,
 		       newinfo->entries,
 		       SMP_ALIGN(newinfo->size));
@@ -882,7 +888,7 @@
 		struct ipt_entry *table_base;
 		unsigned int i;
 
-		for (i = 0; i < NR_CPUS; i++) {
+		for (i = 0; i < NF_NR_CPUS; i++) {
 			table_base =
 				(void *)newinfo->entries
 				+ TABLE_OFFSET(newinfo, i);
@@ -929,7 +935,7 @@
 	unsigned int cpu;
 	unsigned int i;
 
-	for (cpu = 0; cpu < NR_CPUS; cpu++) {
+	for (cpu = 0; cpu < NF_NR_CPUS; cpu++) {
 		i = 0;
 		IPT_ENTRY_ITERATE(t->entries + TABLE_OFFSET(t, cpu),
 				  t->size,
@@ -1067,7 +1073,7 @@
 		return -ENOMEM;
 
 	newinfo = vmalloc(sizeof(struct ipt_table_info)
-			  + SMP_ALIGN(tmp.size) * NR_CPUS);
+			  + SMP_ALIGN(tmp.size) * NF_NR_CPUS);
 	if (!newinfo)
 		return -ENOMEM;
 
@@ -1380,7 +1386,7 @@
 		= { 0, 0, 0, { 0 }, { 0 }, { } };
 
 	newinfo = vmalloc(sizeof(struct ipt_table_info)
-			  + SMP_ALIGN(table->table->size) * NR_CPUS);
+			  + SMP_ALIGN(table->table->size) * NF_NR_CPUS);
 	if (!newinfo)
 		return -ENOMEM;
 
diff -u linux-2.6.5/mm/vmalloc.c-o linux-2.6.5/mm/vmalloc.c
--- linux-2.6.5/mm/vmalloc.c-o	2005-02-03 08:06:50.000000000 +0100
+++ linux-2.6.5/mm/vmalloc.c	2005-02-03 13:07:44.162236952 +0100
@@ -310,7 +310,10 @@
 			__free_page(area->pages[i]);
 		}
 
-		kfree(area->pages);
+		if (area->nr_pages * sizeof(struct page *) >= 4*PAGE_SIZE)
+			vfree(area->pages);
+		else
+			kfree(area->pages);
 	}
 
 	kfree(area);
@@ -414,7 +417,11 @@
 	array_size = (nr_pages * sizeof(struct page *));
 
 	area->nr_pages = nr_pages;
-	area->pages = pages = kmalloc(array_size, (gfp_mask & ~__GFP_HIGHMEM));
+
+	if (array_size >= 4*PAGE_SIZE) 
+		area->pages = pages = __vmalloc(array_size, (gfp_mask & ~__GFP_HIGHMEM), PAGE_KERNEL);
+	else
+		area->pages = pages = kmalloc(array_size, (gfp_mask & ~__GFP_HIGHMEM));
 	if (!area->pages) {
 		remove_vm_area(area->addr);
 		kfree(area);
