From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][NETNS] Consolidate hashes creation in netdev_init()
Date: Fri, 14 Sep 2007 12:40:49 +0400
Message-ID: <46EA4911.9070401@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>, devel@openvz.org,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:52979 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751806AbXINIn4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 04:43:56 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The dev_name_hash and the dev_index_hash are now booth kmalloc-ed
(and each element is properly initialized as usually) so I think
it's worth consolidating this code making it look nicer (and 
saving 28 bytes of .text section ;) )

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/core/dev.c b/net/core/dev.c
index a22a95d..1a60ed2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4258,32 +4258,39 @@ int netdev_compute_features(unsigned lon
 }
 EXPORT_SYMBOL(netdev_compute_features);
 
+static struct hlist_head *netdev_create_hash(void)
+{
+	int i;
+	struct hlist_head *hash;
+
+	hash = kmalloc(sizeof(*hash) * NETDEV_HASHENTRIES, GFP_KERNEL);
+	if (hash != NULL)
+		for (i = 0; i < NETDEV_HASHENTRIES; i++)
+			INIT_HLIST_HEAD(&hash[i]);
+
+	return hash;
+}
+
 /* Initialize per network namespace state */
 static int netdev_init(struct net *net)
 {
-	int i;
 	INIT_LIST_HEAD(&net->dev_base_head);
 	rwlock_init(&dev_base_lock);
 
-	net->dev_name_head = kmalloc(
-		sizeof(*net->dev_name_head)*NETDEV_HASHENTRIES, GFP_KERNEL);
-	if (!net->dev_name_head)
-		return -ENOMEM;
-
-	net->dev_index_head = kmalloc(
-		sizeof(*net->dev_index_head)*NETDEV_HASHENTRIES, GFP_KERNEL);
-	if (!net->dev_index_head) {
-		kfree(net->dev_name_head);
-		return -ENOMEM;
-	}
-
-	for (i = 0; i < NETDEV_HASHENTRIES; i++)
-		INIT_HLIST_HEAD(&net->dev_name_head[i]);
-
-	for (i = 0; i < NETDEV_HASHENTRIES; i++)
-		INIT_HLIST_HEAD(&net->dev_index_head[i]);
+	net->dev_name_head = netdev_create_hash();
+	if (net->dev_name_head == NULL)
+		goto err_name;
+
+	net->dev_index_head = netdev_create_hash();
+	if (net->dev_index_head == NULL)
+		goto err_idx;
 
 	return 0;
+
+err_idx:
+	kfree(net->dev_name_head);
+err_name:
+	return -ENOMEM;
 }
 
 static void netdev_exit(struct net *net)
