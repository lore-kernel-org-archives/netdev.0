From: pablo@netfilter.org
Subject: [PATCH 3/4] netfilter: ipset: autoload set type modules safely
Date: Tue, 17 Jan 2012 12:04:48 +0100
Message-ID: <1326798289-11592-4-git-send-email-pablo@netfilter.org>
References: <1326798289-11592-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:32808 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753303Ab2AQLFQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jan 2012 06:05:16 -0500
In-Reply-To: <1326798289-11592-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Jan Engelhardt noticed when userspace requests a set type unknown
to the kernel, it can lead to a loop due to the unsafe type module
loading. The issue is fixed in this patch.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_core.c |   36 ++++++++++++++++++++++++++----------
 1 files changed, 26 insertions(+), 10 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 86137b5..0f8e5f2 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -77,35 +77,42 @@ find_set_type(const char *name, u8 family, u8 revision)
 }
 
 /* Unlock, try to load a set type module and lock again */
-static int
-try_to_load_type(const char *name)
+static bool
+load_settype(const char *name)
 {
 	nfnl_unlock();
 	pr_debug("try to load ip_set_%s\n", name);
 	if (request_module("ip_set_%s", name) < 0) {
 		pr_warning("Can't find ip_set type %s\n", name);
 		nfnl_lock();
-		return -IPSET_ERR_FIND_TYPE;
+		return false;
 	}
 	nfnl_lock();
-	return -EAGAIN;
+	return true;
 }
 
 /* Find a set type and reference it */
+#define find_set_type_get(name, family, revision, found)	\
+	__find_set_type_get(name, family, revision, found, false)
+
 static int
-find_set_type_get(const char *name, u8 family, u8 revision,
-		  struct ip_set_type **found)
+__find_set_type_get(const char *name, u8 family, u8 revision,
+		    struct ip_set_type **found, bool retry)
 {
 	struct ip_set_type *type;
 	int err;
 
+	if (retry && !load_settype(name))
+		return -IPSET_ERR_FIND_TYPE;
+
 	rcu_read_lock();
 	*found = find_set_type(name, family, revision);
 	if (*found) {
 		err = !try_module_get((*found)->me) ? -EFAULT : 0;
 		goto unlock;
 	}
-	/* Make sure the type is loaded but we don't support the revision */
+	/* Make sure the type is already loaded
+	 * but we don't support the revision */
 	list_for_each_entry_rcu(type, &ip_set_type_list, list)
 		if (STREQ(type->name, name)) {
 			err = -IPSET_ERR_FIND_TYPE;
@@ -113,7 +120,8 @@ find_set_type_get(const char *name, u8 family, u8 revision,
 		}
 	rcu_read_unlock();
 
-	return try_to_load_type(name);
+	return retry ? -IPSET_ERR_FIND_TYPE :
+		__find_set_type_get(name, family, revision, found, true);
 
 unlock:
 	rcu_read_unlock();
@@ -124,12 +132,19 @@ unlock:
  * If we succeeded, the supported minimal and maximum revisions are
  * filled out.
  */
+#define find_set_type_minmax(name, family, min, max) \
+	__find_set_type_minmax(name, family, min, max, false)
+
 static int
-find_set_type_minmax(const char *name, u8 family, u8 *min, u8 *max)
+__find_set_type_minmax(const char *name, u8 family, u8 *min, u8 *max,
+		       bool retry)
 {
 	struct ip_set_type *type;
 	bool found = false;
 
+	if (retry && !load_settype(name))
+		return -IPSET_ERR_FIND_TYPE;
+
 	*min = 255; *max = 0;
 	rcu_read_lock();
 	list_for_each_entry_rcu(type, &ip_set_type_list, list)
@@ -145,7 +160,8 @@ find_set_type_minmax(const char *name, u8 family, u8 *min, u8 *max)
 	if (found)
 		return 0;
 
-	return try_to_load_type(name);
+	return retry ? -IPSET_ERR_FIND_TYPE :
+		__find_set_type_minmax(name, family, min, max, true);
 }
 
 #define family_name(f)	((f) == AF_INET ? "inet" : \
-- 
1.7.7.3
