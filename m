From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 2/3][ROUTE] Clean up proc files creation
Date: Wed, 05 Dec 2007 20:06:39 +0300
Message-ID: <4756DA9F.4000200@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:33718 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751737AbXLERGs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 12:06:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The rt_cache, stats/rt_cache and rt_acct(optional) files
creation looks a bit messy. Clean this out and join them
to other proc-related functions under the proper ifdef.

The struct net * argument in a new function will help net 
namespaces patches look nicer.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index cc5b730..3b9c430 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -520,6 +520,44 @@ static int ip_rt_acct_read(char *buffer, char **start, off_t offset,
 	return length;
 }
 #endif
+
+static __init int ip_rt_proc_init(struct net *net)
+{
+	struct proc_dir_entry *pde;
+
+	pde = proc_net_fops_create(net, "rt_cache", S_IRUGO,
+			&rt_cache_seq_fops);
+	if (!pde)
+		goto err1;
+
+	pde = create_proc_entry("rt_cache", S_IRUGO, net->proc_net_stat);
+	if (!pde)
+		goto err2;
+
+	pde->proc_fops = &rt_cpu_seq_fops;
+
+#ifdef CONFIG_NET_CLS_ROUTE
+	pde = create_proc_read_entry("rt_acct", 0, net->proc_net,
+			ip_rt_acct_read, NULL);
+	if (!pde)
+		goto err3;
+#endif
+	return 0;
+
+#ifdef CONFIG_NET_CLS_ROUTE
+err3:
+	remove_proc_entry("rt_cache", net->proc_net_stat);
+#endif
+err2:
+	remove_proc_entry("rt_cache", net->proc_net);
+err1:
+	return -ENOMEM;
+}
+#else
+static inline int ip_rt_proc_init(struct net *net)
+{
+	return 0;
+}
 #endif /* CONFIG_PROC_FS */
 
 static __inline__ void rt_free(struct rtable *rt)
@@ -2997,20 +3035,8 @@ int __init ip_rt_init(void)
 		ip_rt_secret_interval;
 	add_timer(&rt_secret_timer);
 
-#ifdef CONFIG_PROC_FS
-	{
-	struct proc_dir_entry *rtstat_pde = NULL; /* keep gcc happy */
-	if (!proc_net_fops_create(&init_net, "rt_cache", S_IRUGO, &rt_cache_seq_fops) ||
-	    !(rtstat_pde = create_proc_entry("rt_cache", S_IRUGO,
-					     init_net.proc_net_stat))) {
-		return -ENOMEM;
-	}
-	rtstat_pde->proc_fops = &rt_cpu_seq_fops;
-	}
-#ifdef CONFIG_NET_CLS_ROUTE
-	create_proc_read_entry("rt_acct", 0, init_net.proc_net, ip_rt_acct_read, NULL);
-#endif
-#endif
+	if (ip_rt_proc_init(&init_net))
+		printk(KERN_ERR "Unable to create route proc files\n");
 #ifdef CONFIG_XFRM
 	xfrm_init();
 	xfrm4_init();
-- 
1.5.3.4

