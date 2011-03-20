From: kaber@trash.net
Subject: [PATCH 2/4] netfilter: ipset: fix checking the type revision at create command
Date: Sun, 20 Mar 2011 16:32:26 +0100
Message-ID: <1300635148-22648-3-git-send-email-kaber@trash.net>
References: <1300635148-22648-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1300635148-22648-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

The revision of the set type was not checked at the create command: if the
userspace sent a valid set type but with not supported revision number,
it'd create a loop.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/ipset/ip_set_core.c |   22 +++++++++++++++++-----
 1 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 618a615..d6b4823 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -94,16 +94,28 @@ static int
 find_set_type_get(const char *name, u8 family, u8 revision,
 		  struct ip_set_type **found)
 {
+	struct ip_set_type *type;
+	int err;
+
 	rcu_read_lock();
 	*found = find_set_type(name, family, revision);
 	if (*found) {
-		int err = !try_module_get((*found)->me);
-		rcu_read_unlock();
-		return err ? -EFAULT : 0;
+		err = !try_module_get((*found)->me) ? -EFAULT : 0;
+		goto unlock;
 	}
+	/* Make sure the type is loaded but we don't support the revision */
+	list_for_each_entry_rcu(type, &ip_set_type_list, list)
+		if (STREQ(type->name, name)) {
+			err = -IPSET_ERR_FIND_TYPE;
+			goto unlock;
+		}
 	rcu_read_unlock();
 
 	return try_to_load_type(name);
+
+unlock:
+	rcu_read_unlock();
+	return err;
 }
 
 /* Find a given set type by name and family.
@@ -116,7 +128,7 @@ find_set_type_minmax(const char *name, u8 family, u8 *min, u8 *max)
 	struct ip_set_type *type;
 	bool found = false;
 
-	*min = *max = 0;
+	*min = 255; *max = 0;
 	rcu_read_lock();
 	list_for_each_entry_rcu(type, &ip_set_type_list, list)
 		if (STREQ(type->name, name) &&
@@ -124,7 +136,7 @@ find_set_type_minmax(const char *name, u8 family, u8 *min, u8 *max)
 			found = true;
 			if (type->revision < *min)
 				*min = type->revision;
-			else if (type->revision > *max)
+			if (type->revision > *max)
 				*max = type->revision;
 		}
 	rcu_read_unlock();
-- 
1.7.4

