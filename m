From: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 06/15] user namespace: make each net (net_ns) belong to a
	user_ns
Date: Fri,  2 Sep 2011 19:56:31 +0000
Message-ID: <1314993400-6910-9-git-send-email-serge@hallyn.com>
References: <1314993400-6910-1-git-send-email-serge@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm-3NddpPZAyC0@public.gmane.org, segooon-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
        dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1314993400-6910-1-git-send-email-serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

This way we can target capabilites at the user_ns which created the
net ns.

Changelog:
   jul 8: nsproxy: don't assign netns->userns if not cloning.

Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/net/net_namespace.h |    2 ++
 kernel/nsproxy.c            |    2 ++
 net/core/net_namespace.c    |    3 +++
 3 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 3bb6fa0..d91fe5f 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -29,6 +29,7 @@ struct ctl_table_header;
 struct net_generic;
 struct sock;
 struct netns_ipvs;
+struct user_namespace;
 
 
 #define NETDEV_HASHBITS    8
@@ -101,6 +102,7 @@ struct net {
 	struct netns_xfrm	xfrm;
 #endif
 	struct netns_ipvs	*ipvs;
+	struct user_namespace	*user_ns;
 };
 
 
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index e274577..752b477 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -95,6 +95,8 @@ static struct nsproxy *create_new_namespaces(unsigned long flags,
 		err = PTR_ERR(new_nsp->net_ns);
 		goto out_net;
 	}
+	if (flags & CLONE_NEWNET)
+		new_nsp->net_ns->user_ns = get_user_ns(task_cred_xxx(tsk, user_ns));
 
 	return new_nsp;
 
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 6f6698d..5ca95cc 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -10,6 +10,7 @@
 #include <linux/nsproxy.h>
 #include <linux/proc_fs.h>
 #include <linux/file.h>
+#include <linux/user_namespace.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 
@@ -209,6 +210,7 @@ static void net_free(struct net *net)
 	}
 #endif
 	kfree(net->gen);
+	put_user_ns(net->user_ns);
 	kmem_cache_free(net_cachep, net);
 }
 
@@ -389,6 +391,7 @@ static int __init net_ns_init(void)
 	rcu_assign_pointer(init_net.gen, ng);
 
 	mutex_lock(&net_mutex);
+	init_net.user_ns = &init_user_ns;
 	if (setup_net(&init_net))
 		panic("Could not setup the initial network namespace");
 
-- 
1.7.5.4
