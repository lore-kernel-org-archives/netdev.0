From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 1/7] kobject: add kobject_uevent_net_broadcast()
Date: Tue, 19 Sep 2017 16:27:03 -0700
Message-ID: <20170919232709.14690-2-edumazet@google.com>
References: <20170919232709.14690-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:48569 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751578AbdISX1P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 19:27:15 -0400
Received: by mail-pg0-f43.google.com with SMTP id v23so675261pgc.5
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 16:27:15 -0700 (PDT)
In-Reply-To: <20170919232709.14690-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This removes some #ifdef pollution and will ease follow up patches.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 lib/kobject_uevent.c | 96 +++++++++++++++++++++++++++++-----------------------
 1 file changed, 53 insertions(+), 43 deletions(-)

diff --git a/lib/kobject_uevent.c b/lib/kobject_uevent.c
index e590523ea4761425df5e112a2c2aab873dbaa90d..4f48cc3b11d566e44c4115cc7716bc3b1cdf96df 100644
--- a/lib/kobject_uevent.c
+++ b/lib/kobject_uevent.c
@@ -294,6 +294,57 @@ static void cleanup_uevent_env(struct subprocess_info *info)
 }
 #endif
 
+static int kobject_uevent_net_broadcast(struct kobject *kobj,
+					struct kobj_uevent_env *env,
+					const char *action_string,
+					const char *devpath)
+{
+	int retval = 0;
+#if defined(CONFIG_NET)
+	struct uevent_sock *ue_sk;
+
+	/* send netlink message */
+	list_for_each_entry(ue_sk, &uevent_sock_list, list) {
+		struct sock *uevent_sock = ue_sk->sk;
+		struct sk_buff *skb;
+		size_t len;
+
+		if (!netlink_has_listeners(uevent_sock, 1))
+			continue;
+
+		/* allocate message with the maximum possible size */
+		len = strlen(action_string) + strlen(devpath) + 2;
+		skb = alloc_skb(len + env->buflen, GFP_KERNEL);
+		if (skb) {
+			char *scratch;
+			int i;
+
+			/* add header */
+			scratch = skb_put(skb, len);
+			sprintf(scratch, "%s@%s", action_string, devpath);
+
+			/* copy keys to our continuous event payload buffer */
+			for (i = 0; i < env->envp_idx; i++) {
+				len = strlen(env->envp[i]) + 1;
+				scratch = skb_put(skb, len);
+				strcpy(scratch, env->envp[i]);
+			}
+
+			NETLINK_CB(skb).dst_group = 1;
+			retval = netlink_broadcast_filtered(uevent_sock, skb,
+							    0, 1, GFP_KERNEL,
+							    kobj_bcast_filter,
+							    kobj);
+			/* ENOBUFS should be handled in userspace */
+			if (retval == -ENOBUFS || retval == -ESRCH)
+				retval = 0;
+		} else
+			retval = -ENOMEM;
+	}
+#endif
+	return retval;
+}
+
 /**
  * kobject_uevent_env - send an uevent with environmental data
  *
@@ -316,9 +367,6 @@ int kobject_uevent_env(struct kobject *kobj, enum kobject_action action,
 	const struct kset_uevent_ops *uevent_ops;
 	int i = 0;
 	int retval = 0;
-#ifdef CONFIG_NET
-	struct uevent_sock *ue_sk;
-#endif
 
 	pr_debug("kobject: '%s' (%p): %s\n",
 		 kobject_name(kobj), kobj, __func__);
@@ -427,46 +475,8 @@ int kobject_uevent_env(struct kobject *kobj, enum kobject_action action,
 		mutex_unlock(&uevent_sock_mutex);
 		goto exit;
 	}
-
-#if defined(CONFIG_NET)
-	/* send netlink message */
-	list_for_each_entry(ue_sk, &uevent_sock_list, list) {
-		struct sock *uevent_sock = ue_sk->sk;
-		struct sk_buff *skb;
-		size_t len;
-
-		if (!netlink_has_listeners(uevent_sock, 1))
-			continue;
-
-		/* allocate message with the maximum possible size */
-		len = strlen(action_string) + strlen(devpath) + 2;
-		skb = alloc_skb(len + env->buflen, GFP_KERNEL);
-		if (skb) {
-			char *scratch;
-
-			/* add header */
-			scratch = skb_put(skb, len);
-			sprintf(scratch, "%s@%s", action_string, devpath);
-
-			/* copy keys to our continuous event payload buffer */
-			for (i = 0; i < env->envp_idx; i++) {
-				len = strlen(env->envp[i]) + 1;
-				scratch = skb_put(skb, len);
-				strcpy(scratch, env->envp[i]);
-			}
-
-			NETLINK_CB(skb).dst_group = 1;
-			retval = netlink_broadcast_filtered(uevent_sock, skb,
-							    0, 1, GFP_KERNEL,
-							    kobj_bcast_filter,
-							    kobj);
-			/* ENOBUFS should be handled in userspace */
-			if (retval == -ENOBUFS || retval == -ESRCH)
-				retval = 0;
-		} else
-			retval = -ENOMEM;
-	}
-#endif
+	retval = kobject_uevent_net_broadcast(kobj, env, action_string,
+					      devpath);
 	mutex_unlock(&uevent_sock_mutex);
 
 #ifdef CONFIG_UEVENT_HELPER
-- 
2.14.1.690.gbb1197296e-goog
