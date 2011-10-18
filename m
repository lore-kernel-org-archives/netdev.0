From: Serge Hallyn <serge@hallyn.com>
Subject: [PATCH 7/9] user namespace: make each net (net_ns) belong to a user_ns
Date: Tue, 18 Oct 2011 21:54:56 +0000
Message-ID: <1318974898-21431-8-git-send-email-serge@hallyn.com>
References: <1318974898-21431-1-git-send-email-serge@hallyn.com>
Cc: ebiederm@xmission.com, akpm@linux-foundation.org, oleg@redhat.com,
	richard@nod.at, mikevs@xs4all.net, segoon@openwall.com,
	gregkh@suse.de, dhowells@redhat.com, eparis@redhat.com,
	"Serge E. Hallyn" <serge.hallyn@canonical.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1318974898-21431-1-git-send-email-serge@hallyn.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Serge E. Hallyn" <serge.hallyn@canonical.com>

The user namespace which creates a new network namespace owns that
namespace and all resources created in it.  This way we can target
capability checks for privileged operations against network resources to
the user_ns which created the network namespace in which the resource
lives.  Privilege to the user namespace which owns the network
namespace, or any parent user namespace thereof, provides the same
privilege to the network resource.

Changelog:
   jul 8: nsproxy: don't assign netns->userns if not cloning.

Signed-off-by: Serge E. Hallyn <serge.hallyn@canonical.com>
Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: netdev@vger.kernel.org
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
index 9aeab4b..0d5bf8d 100644
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
index 5bbdbf0..791c19c 100644
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
