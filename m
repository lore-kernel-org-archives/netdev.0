From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/5] neigh: wrap proc dointvec functions
Date: Fri,  6 Dec 2013 19:29:01 +0100
Message-ID: <1386354544-19122-3-git-send-email-jiri@resnulli.us>
References: <1386354544-19122-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	hannes@stressinduktion.org, bcrl@kvack.org,
	william.manley@youview.com, gaofeng@cn.fujitsu.com,
	joe@perches.com, herbert@gondor.apana.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:47491 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753718Ab3LFS3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 13:29:14 -0500
Received: by mail-ee0-f43.google.com with SMTP id c13so458915eek.30
        for <netdev@vger.kernel.org>; Fri, 06 Dec 2013 10:29:12 -0800 (PST)
In-Reply-To: <1386354544-19122-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will be needed later on to provide better management of default values.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/net/neighbour.h |  9 ++++++++
 net/core/neighbour.c    | 55 ++++++++++++++++++++++++++++++++++++++++---------
 net/ipv6/ndisc.c        | 10 ++++-----
 3 files changed, 59 insertions(+), 15 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 4cb5478..ed7eba0 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -296,6 +296,15 @@ void *neigh_seq_start(struct seq_file *, loff_t *, struct neigh_table *,
 void *neigh_seq_next(struct seq_file *, void *, loff_t *);
 void neigh_seq_stop(struct seq_file *, void *);
 
+int neigh_proc_dointvec(struct ctl_table *ctl, int write,
+			void __user *buffer, size_t *lenp, loff_t *ppos);
+int neigh_proc_dointvec_jiffies(struct ctl_table *ctl, int write,
+				void __user *buffer,
+				size_t *lenp, loff_t *ppos);
+int neigh_proc_dointvec_ms_jiffies(struct ctl_table *ctl, int write,
+				   void __user *buffer,
+				   size_t *lenp, loff_t *ppos);
+
 int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
 			  char *p_name, proc_handler *proc_handler);
 void neigh_sysctl_unregister(struct neigh_parms *p);
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 742fa10..60edd97 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2825,6 +2825,43 @@ static int neigh_proc_dointvec_zero_intmax(struct ctl_table *ctl, int write,
 	return proc_dointvec_minmax(&tmp, write, buffer, lenp, ppos);
 }
 
+int neigh_proc_dointvec(struct ctl_table *ctl, int write,
+			void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	return proc_dointvec(ctl, write, buffer, lenp, ppos);
+}
+EXPORT_SYMBOL(neigh_proc_dointvec);
+
+int neigh_proc_dointvec_jiffies(struct ctl_table *ctl, int write,
+				void __user *buffer,
+				size_t *lenp, loff_t *ppos)
+{
+	return proc_dointvec_jiffies(ctl, write, buffer, lenp, ppos);
+}
+EXPORT_SYMBOL(neigh_proc_dointvec_jiffies);
+
+static int neigh_proc_dointvec_userhz_jiffies(struct ctl_table *ctl, int write,
+					      void __user *buffer,
+					      size_t *lenp, loff_t *ppos)
+{
+	return proc_dointvec_userhz_jiffies(ctl, write, buffer, lenp, ppos);
+}
+
+int neigh_proc_dointvec_ms_jiffies(struct ctl_table *ctl, int write,
+				   void __user *buffer,
+				   size_t *lenp, loff_t *ppos)
+{
+	return proc_dointvec_ms_jiffies(ctl, write, buffer, lenp, ppos);
+}
+EXPORT_SYMBOL(neigh_proc_dointvec_ms_jiffies);
+
+static int neigh_proc_dointvec_unres_qlen(struct ctl_table *ctl, int write,
+					  void __user *buffer,
+					  size_t *lenp, loff_t *ppos)
+{
+	return proc_unres_qlen(ctl, write, buffer, lenp, ppos);
+}
+
 #define NEIGH_PARMS_DATA_OFFSET(index)	\
 	(&((struct neigh_parms *) 0)->data[index])
 
@@ -2841,19 +2878,19 @@ static int neigh_proc_dointvec_zero_intmax(struct ctl_table *ctl, int write,
 	NEIGH_SYSCTL_ENTRY(attr, attr, name, 0644, neigh_proc_dointvec_zero_intmax)
 
 #define NEIGH_SYSCTL_JIFFIES_ENTRY(attr, name) \
-	NEIGH_SYSCTL_ENTRY(attr, attr, name, 0644, proc_dointvec_jiffies)
+	NEIGH_SYSCTL_ENTRY(attr, attr, name, 0644, neigh_proc_dointvec_jiffies)
 
 #define NEIGH_SYSCTL_USERHZ_JIFFIES_ENTRY(attr, name) \
-	NEIGH_SYSCTL_ENTRY(attr, attr, name, 0644, proc_dointvec_userhz_jiffies)
+	NEIGH_SYSCTL_ENTRY(attr, attr, name, 0644, neigh_proc_dointvec_userhz_jiffies)
 
 #define NEIGH_SYSCTL_MS_JIFFIES_ENTRY(attr, name) \
-	NEIGH_SYSCTL_ENTRY(attr, attr, name, 0644, proc_dointvec_ms_jiffies)
+	NEIGH_SYSCTL_ENTRY(attr, attr, name, 0644, neigh_proc_dointvec_ms_jiffies)
 
 #define NEIGH_SYSCTL_MS_JIFFIES_REUSED_ENTRY(attr, data_attr, name) \
-	NEIGH_SYSCTL_ENTRY(attr, data_attr, name, 0644, proc_dointvec_ms_jiffies)
+	NEIGH_SYSCTL_ENTRY(attr, data_attr, name, 0644, neigh_proc_dointvec_ms_jiffies)
 
 #define NEIGH_SYSCTL_UNRES_QLEN_REUSED_ENTRY(attr, data_attr, name) \
-	NEIGH_SYSCTL_ENTRY(attr, data_attr, name, 0644, proc_unres_qlen)
+	NEIGH_SYSCTL_ENTRY(attr, data_attr, name, 0644, neigh_proc_dointvec_unres_qlen)
 
 static struct neigh_sysctl_table {
 	struct ctl_table_header *sysctl_header;
@@ -2921,8 +2958,10 @@ int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
 	if (!t)
 		goto err;
 
-	for (i = 0; i < ARRAY_SIZE(t->neigh_vars); i++)
+	for (i = 0; i < ARRAY_SIZE(t->neigh_vars); i++) {
 		t->neigh_vars[i].data += (long) p;
+		t->neigh_vars[i].extra1 = dev;
+	}
 
 	if (dev) {
 		dev_name_source = dev->name;
@@ -2940,16 +2979,12 @@ int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
 	if (handler) {
 		/* RetransTime */
 		t->neigh_vars[NEIGH_VAR_RETRANS_TIME].proc_handler = handler;
-		t->neigh_vars[NEIGH_VAR_RETRANS_TIME].extra1 = dev;
 		/* ReachableTime */
 		t->neigh_vars[NEIGH_VAR_BASE_REACHABLE_TIME].proc_handler = handler;
-		t->neigh_vars[NEIGH_VAR_BASE_REACHABLE_TIME].extra1 = dev;
 		/* RetransTime (in milliseconds)*/
 		t->neigh_vars[NEIGH_VAR_RETRANS_TIME_MS].proc_handler = handler;
-		t->neigh_vars[NEIGH_VAR_RETRANS_TIME_MS].extra1 = dev;
 		/* ReachableTime (in milliseconds) */
 		t->neigh_vars[NEIGH_VAR_BASE_REACHABLE_TIME_MS].proc_handler = handler;
-		t->neigh_vars[NEIGH_VAR_BASE_REACHABLE_TIME_MS].extra1 = dev;
 	}
 
 	/* Don't export sysctls to unprivileged users */
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 0da0986..5fc6f69 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1655,16 +1655,16 @@ int ndisc_ifinfo_sysctl_change(struct ctl_table *ctl, int write, void __user *bu
 		ndisc_warn_deprecated_sysctl(ctl, "syscall", dev ? dev->name : "default");
 
 	if (strcmp(ctl->procname, "retrans_time") == 0)
-		ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
+		ret = neigh_proc_dointvec(ctl, write, buffer, lenp, ppos);
 
 	else if (strcmp(ctl->procname, "base_reachable_time") == 0)
-		ret = proc_dointvec_jiffies(ctl, write,
-					    buffer, lenp, ppos);
+		ret = neigh_proc_dointvec_jiffies(ctl, write,
+						  buffer, lenp, ppos);
 
 	else if ((strcmp(ctl->procname, "retrans_time_ms") == 0) ||
 		 (strcmp(ctl->procname, "base_reachable_time_ms") == 0))
-		ret = proc_dointvec_ms_jiffies(ctl, write,
-					       buffer, lenp, ppos);
+		ret = neigh_proc_dointvec_ms_jiffies(ctl, write,
+						     buffer, lenp, ppos);
 	else
 		ret = -1;
 
-- 
1.8.3.1
