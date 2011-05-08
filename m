From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 031/115] sysctl: remove .child from kernel/sched_domain/cpuX/domainY/
Date: Mon,  9 May 2011 00:38:43 +0200
Message-ID: <1304894407-32201-32-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40833 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932297Ab1EHWlD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:41:03 -0400
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Note: this patch makes sure to add empty kernel/sched_domain/cpuX/
directories when there are no domains in them.

This was the behaviour before this patch, and I thought it may need to
remain so in the new implementation. If they are not necessary this
can be removed to simplify the code.

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 kernel/sched.c |  266 ++++++++++++++++++++++++++++++++++++++------------------
 1 files changed, 180 insertions(+), 86 deletions(-)

diff --git a/kernel/sched.c b/kernel/sched.c
index 23a980c..6e39b7c 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -6181,52 +6181,6 @@ static struct ctl_table sd_table_template[] = {
 	{ }
 };
 
-static struct ctl_table sd_ctl_dir[] = {
-	{
-		.procname	= "sched_domain",
-		.mode		= 0555,
-	},
-	{}
-};
-
-static struct ctl_table sd_ctl_root[] = {
-	{
-		.procname	= "kernel",
-		.mode		= 0555,
-		.child		= sd_ctl_dir,
-	},
-	{}
-};
-
-static struct ctl_table *sd_alloc_ctl_entry(int n)
-{
-	struct ctl_table *entry =
-		kcalloc(n, sizeof(struct ctl_table), GFP_KERNEL);
-
-	return entry;
-}
-
-static void sd_free_ctl_entry(struct ctl_table **tablep)
-{
-	struct ctl_table *entry;
-
-	/*
-	 * In the intermediate directories, both the child directory and
-	 * procname are dynamically allocated and could fail but the mode
-	 * will always be set. In the lowest directory the names are
-	 * static strings and all have proc handlers.
-	 */
-	for (entry = *tablep; entry->mode; entry++) {
-		if (entry->child)
-			sd_free_ctl_entry(&entry->child);
-		if (entry->proc_handler == NULL)
-			kfree(entry->procname);
-	}
-
-	kfree(*tablep);
-	*tablep = NULL;
-}
-
 static struct ctl_table *
 sd_alloc_ctl_domain_table(struct sched_domain *sd)
 {
@@ -6250,64 +6204,204 @@ sd_alloc_ctl_domain_table(struct sched_domain *sd)
 	return table;
 }
 
-static ctl_table *sd_alloc_ctl_cpu_table(int cpu)
+/*
+ * Find out what is the maximum number of domains in a cpu, and the
+ * total number of domains across all cpus.
+ */
+static void count_sd_domains(int *p_max, int *p_total)
 {
-	struct ctl_table *entry, *table;
-	struct sched_domain *sd;
-	int domain_num = 0, i;
-	char buf[32];
+	int cpu;
+	int max = 0;
+	int total = 0;
 
-	for_each_domain(cpu, sd)
-		domain_num++;
-	entry = table = sd_alloc_ctl_entry(domain_num + 1);
-	if (table == NULL)
-		return NULL;
+	for_each_possible_cpu(cpu) {
+		struct sched_domain *sd;
+		int domain_num = 0;
 
-	i = 0;
-	for_each_domain(cpu, sd) {
-		snprintf(buf, 32, "domain%d", i);
-		entry->procname = kstrdup(buf, GFP_KERNEL);
-		entry->mode = 0555;
-		entry->child = sd_alloc_ctl_domain_table(sd);
-		entry++;
-		i++;
+		for_each_domain(cpu, sd)
+			domain_num++;
+
+		if (domain_num > max)
+			max = domain_num;
+		total += domain_num;
 	}
-	return table;
+	*p_max = max;
+	*p_total = total;
 }
 
-static struct ctl_table_header *sd_sysctl_header;
+
+/* enough space to hold a string "cpu%d" or "domain%d" */
+#define SD_NAME_LEN 32
+typedef char sd_name_buf[SD_NAME_LEN];
+
+static sd_name_buf *sd_cpu_names, *sd_domain_names;
+static int sd_domain_headers_num, sd_cpudir_headers_num;
+static struct ctl_table_header **sd_domain_headers, **sd_cpudir_headers;
+
 static void register_sched_domain_sysctl(void)
 {
-	int i, cpu_num = num_possible_cpus();
-	struct ctl_table *entry = sd_alloc_ctl_entry(cpu_num + 1);
-	char buf[32];
+	int cpu, i;
+	int cpu_num, max_domain_num;
+
+	/* possitions 2 and 3 in the array bellow */
+#define SD_PATH_CPU 2
+#define SD_PATH_DOM 3
+	struct ctl_path sd_path[] = {
+		{ .procname = "kernel" },
+		{ .procname = "sched_domain" },
+		{ /* 'cpu0' */ },
+		{ /* 'domain0' */ },
+		{  },
+	};
 
-	WARN_ON(sd_ctl_dir[0].child);
-	sd_ctl_dir[0].child = entry;
+	sd_cpudir_headers_num = cpu_num = num_possible_cpus();
+	count_sd_domains(&max_domain_num, &sd_domain_headers_num);
 
-	if (entry == NULL)
-		return;
+	/*
+	 * Allocate space for:
+	 * - all cpu names (cpu0, cpu1,...) and all domain names (domain0,...)
+	 * - the array of headers for cpu dirs    kernel/sched_domain/cpuX/
+	 * - the array of headers for domain dirs kernel/sched_domain/cpuX/domainY
+	 *
+	 * We only register the empty kernel/sched_domain/cpuX/ dirs
+	 * to not break the ABI: if there were no domains defined, we
+	 * would still have empty cpuX dir entries in
+	 * kernel/sched_domain/.
+	 *
+	 * If this is not considered useful or part of the ABI, then
+	 * we can drop the empty cpu dir entries.
+	 */
+	sd_cpu_names = kmalloc(sizeof(sd_name_buf) * cpu_num, GFP_KERNEL);
+	if (sd_cpu_names == NULL)
+		goto fail_alloc_sd_cpu_names;
 
-	for_each_possible_cpu(i) {
-		snprintf(buf, 32, "cpu%d", i);
-		entry->procname = kstrdup(buf, GFP_KERNEL);
-		entry->mode = 0555;
-		entry->child = sd_alloc_ctl_cpu_table(i);
-		entry++;
+	sd_domain_names = kmalloc(sizeof(sd_name_buf) * max_domain_num, GFP_KERNEL);
+	if (sd_domain_names == NULL)
+		goto fail_alloc_sd_domain_names;
+
+	sd_cpudir_headers = kmalloc(sizeof(*sd_cpudir_headers) *
+				    sd_cpudir_headers_num, GFP_KERNEL);
+	if (sd_cpudir_headers == NULL)
+		goto fail_alloc_sd_cpudir_headers;
+
+	sd_domain_headers = kmalloc(sizeof(*sd_domain_headers) *
+				    sd_domain_headers_num, GFP_KERNEL);
+	if (sd_domain_headers == NULL)
+		goto fail_alloc_sd_domain_headers;
+
+	for_each_possible_cpu(cpu)
+		snprintf((char*)&sd_cpu_names[cpu], SD_NAME_LEN, "cpu%d", cpu);
+	for (i = 0; i < max_domain_num; i++)
+		snprintf((char*)&sd_domain_names[i], SD_NAME_LEN, "domain%d", i);
+
+	i = 0;
+	for_each_possible_cpu(cpu) {
+		struct ctl_table *empty = kzalloc(sizeof(*empty), GFP_KERNEL);
+		if (empty == NULL)
+			goto unregister_sd_cpudir_headers;
+		sd_path[SD_PATH_CPU].procname = sd_cpu_names[cpu];
+		sd_path[SD_PATH_DOM].procname = NULL; /* end of array sentinel */
+		sd_cpudir_headers[i] = register_sysctl_paths(sd_path, empty);
+		if (sd_cpudir_headers[i] == NULL) {
+			kfree(empty);
+			goto unregister_sd_cpudir_headers;
+		}
+		i++;
+	}
+
+	i = 0;
+	for_each_possible_cpu(cpu) {
+		struct sched_domain *sd;
+		int domain = 0;
+		for_each_domain(cpu, sd) {
+			struct ctl_table *table = sd_alloc_ctl_domain_table(sd);
+			if (table == NULL)
+				goto unregister_sd_domain_headers;
+			sd_path[SD_PATH_CPU].procname = sd_cpu_names[cpu];
+			sd_path[SD_PATH_DOM].procname = sd_domain_names[domain];
+			sd_domain_headers[i] = register_sysctl_paths(sd_path, table);
+			if (sd_domain_headers[i] == NULL) {
+				kfree(table);
+				goto unregister_sd_domain_headers;
+			}
+			i++;
+			domain++;
+		}
 	}
 
-	WARN_ON(sd_sysctl_header);
-	sd_sysctl_header = register_sysctl_table(sd_ctl_root);
+	return;
+
+unregister_sd_domain_headers:
+	i--; /* the current 'i' was being filled in, but fail_alloced */
+	for(; i >= 0; i--) {
+		struct ctl_table *table = sd_domain_headers[i]->ctl_table_arg;
+		unregister_sysctl_table(sd_domain_headers[i]);
+		kfree(table);
+	}
+	i = sd_cpudir_headers_num;
+unregister_sd_cpudir_headers:
+	i--;
+	for(; i >= 0; i--) {
+		struct ctl_table *table = sd_cpudir_headers[i]->ctl_table_arg;
+		unregister_sysctl_table(sd_cpudir_headers[i]);
+		kfree(table);
+	}
+
+	kfree(sd_domain_headers);
+fail_alloc_sd_domain_headers:
+	kfree(sd_cpudir_headers);
+fail_alloc_sd_cpudir_headers:
+	kfree(sd_domain_names);
+fail_alloc_sd_domain_names:
+	kfree(sd_cpu_names);
+fail_alloc_sd_cpu_names:
+	sd_domain_headers = NULL;
+	sd_cpudir_headers = NULL;
+	sd_domain_names = NULL;
+	sd_cpu_names = NULL;
+	sd_domain_headers_num = 0;
+	sd_cpudir_headers_num = 0;
 }
 
 /* may be called multiple times per register */
 static void unregister_sched_domain_sysctl(void)
 {
-	if (sd_sysctl_header)
-		unregister_sysctl_table(sd_sysctl_header);
-	sd_sysctl_header = NULL;
-	if (sd_ctl_dir[0].child)
-		sd_free_ctl_entry(&sd_ctl_dir[0].child);
+	int i;
+
+	/* because this function may be called multiple times (not
+	 * concurrently) for a single register_sched_domain_sysctl call,
+	 * we skip unregistering if it was already done by a previous
+	 * call. This is also why we make sure to NULLify all
+	 * pointers: make sure nothing is double-freed. */
+	if (sd_domain_headers == NULL)
+		return;
+
+	/* unregister in the reverse order of registering, or we'll
+	 * get a harmless warning saying that the parent of a header
+	 * was registered before all it's children. */
+	for(i = sd_domain_headers_num - 1; i >= 0; i--) {
+		struct ctl_table *table = sd_domain_headers[i]->ctl_table_arg;
+		unregister_sysctl_table(sd_domain_headers[i]);
+		kfree(table);
+	}
+
+	for(i = sd_cpudir_headers_num - 1; i >= 0; i--) {
+		struct ctl_table *table = sd_cpudir_headers[i]->ctl_table_arg;
+		unregister_sysctl_table(sd_cpudir_headers[i]);
+		kfree(table);
+	}
+
+	kfree(sd_domain_headers);
+	kfree(sd_cpudir_headers);
+	kfree(sd_domain_names);
+	kfree(sd_cpu_names);
+
+	sd_domain_headers = NULL;
+	sd_cpudir_headers = NULL;
+	sd_domain_names = NULL;
+	sd_cpu_names = NULL;
+	sd_cpudir_headers_num = 0;
+	sd_domain_headers_num = 0;
 }
 #else
 static void register_sched_domain_sysctl(void)
-- 
1.7.5.134.g1c08b

