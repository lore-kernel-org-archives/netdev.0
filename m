From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 1/2][NEIGH] Cleanup the neigh_sysctl_register
Date: Fri, 30 Nov 2007 20:23:20 +0300
Message-ID: <47504708.9040405@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:42660 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762436AbXK3RXd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2007 12:23:33 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This mainly removes the err variable, as this call always
return the same error code (-ENOBUFS).

Besides, I moved the call to kmalloc() from the *t declaration
into the code (this is confusing when a variable is initialized
with the result of some call) and removed unneeded comment near
the error path.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index a8b72c1..5dbe26f 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2652,14 +2652,14 @@ int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
 			  int p_id, int pdev_id, char *p_name,
 			  proc_handler *handler, ctl_handler *strategy)
 {
-	struct neigh_sysctl_table *t = kmemdup(&neigh_sysctl_template,
-					       sizeof(*t), GFP_KERNEL);
+	struct neigh_sysctl_table *t;
 	const char *dev_name_source = NULL;
 	char *dev_name = NULL;
-	int err = 0;
 
+	t = kmemdup(&neigh_sysctl_template, sizeof(*t), GFP_KERNEL);
 	if (!t)
-		return -ENOBUFS;
+		goto err;
+
 	t->neigh_vars[0].data  = &p->mcast_probes;
 	t->neigh_vars[1].data  = &p->ucast_probes;
 	t->neigh_vars[2].data  = &p->app_probes;
@@ -2717,10 +2717,8 @@ int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
 	}
 
 	dev_name = kstrdup(dev_name_source, GFP_KERNEL);
-	if (!dev_name) {
-		err = -ENOBUFS;
+	if (!dev_name)
 		goto free;
-	}
 
 	t->neigh_dev[0].procname = dev_name;
 
@@ -2735,20 +2733,18 @@ int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
 	t->neigh_root_dir[0].child     = t->neigh_proto_dir;
 
 	t->sysctl_header = register_sysctl_table(t->neigh_root_dir);
-	if (!t->sysctl_header) {
-		err = -ENOBUFS;
+	if (!t->sysctl_header)
 		goto free_procname;
-	}
+
 	p->sysctl_table = t;
 	return 0;
 
-	/* error path */
- free_procname:
+free_procname:
 	kfree(dev_name);
- free:
+free:
 	kfree(t);
-
-	return err;
+err:
+	return -ENOBUFS;
 }
 
 void neigh_sysctl_unregister(struct neigh_parms *p)
-- 
1.5.3.4


