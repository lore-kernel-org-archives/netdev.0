From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25 1/3][IPV4] Cleanup the devinet_sysctl_register
Date: Fri, 30 Nov 2007 21:21:00 +0300
Message-ID: <4750548C.1040005@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:40719 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756265AbXK3SVL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2007 13:21:11 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I moved the call to kmalloc() from the *t declaration into 
the code (this is confusing when a variable is initialized
with the result of some call) and removed unneeded comment 
near the error path. Just like I did with the neigh ctl-s.

Besides, I fixed the goto's and the labels - they were indented
with spaces :(

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 1ae7dcf..34c34c6 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1507,12 +1507,13 @@ static void devinet_sysctl_register(struct in_device *in_dev,
 {
 	int i;
 	struct net_device *dev = in_dev ? in_dev->dev : NULL;
-	struct devinet_sysctl_table *t = kmemdup(&devinet_sysctl, sizeof(*t),
-						 GFP_KERNEL);
+	struct devinet_sysctl_table *t;
 	char *dev_name = NULL;
 
+	t = kmemdup(&devinet_sysctl, sizeof(*t), GFP_KERNEL);
 	if (!t)
-		return;
+		goto out;
+
 	for (i = 0; i < ARRAY_SIZE(t->devinet_vars) - 1; i++) {
 		t->devinet_vars[i].data += (char *)p - (char *)&ipv4_devconf;
 		t->devinet_vars[i].extra1 = p;
@@ -1533,7 +1534,7 @@ static void devinet_sysctl_register(struct in_device *in_dev,
 	 */
 	dev_name = kstrdup(dev_name, GFP_KERNEL);
 	if (!dev_name)
-	    goto free;
+		goto free;
 
 	t->devinet_dev[0].procname    = dev_name;
 	t->devinet_dev[0].child	      = t->devinet_vars;
@@ -1543,16 +1544,16 @@ static void devinet_sysctl_register(struct in_device *in_dev,
 
 	t->sysctl_header = register_sysctl_table(t->devinet_root_dir);
 	if (!t->sysctl_header)
-	    goto free_procname;
+		goto free_procname;
 
 	p->sysctl = t;
 	return;
 
-	/* error path */
- free_procname:
+free_procname:
 	kfree(dev_name);
- free:
+free:
 	kfree(t);
+out:
 	return;
 }
 
-- 
1.5.3.4

