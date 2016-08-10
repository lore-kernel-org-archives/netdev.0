From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: [PATCH v2 1/3] netns: do not call pernet ops for not yet set up init_net namespace
Date: Wed, 10 Aug 2016 14:36:00 -0700
Message-ID: <1470864962-25056-2-git-send-email-dmitry.torokhov@gmail.com>
References: <1470864962-25056-1-git-send-email-dmitry.torokhov@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1470864962-25056-1-git-send-email-dmitry.torokhov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When CONFIG_NET_NS is disabled, registering pernet operations causes
init() to be called immediately with init_net as an argument. Unfortunately
this leads to some pernet ops, such as proc_net_ns_init() to be called too
early, when init_net namespace has not been fully initialized. This causes
issues when we want to change pernet ops to use more data from the net
namespace in question, for example reference user namespace that owns our
network namespace.

To fix this we could either play game of musical chairs and rearrange init
order, or we could do the same as when CONFIG_NET_NS is enabled, and
postpone calling pernet ops->init() until namespace is set up properly.

Note that we can not simply undo commit ed160e839d2e ("[NET]: Cleanup
pernet operation without CONFIG_NET_NS") and use the same implementations
for __register_pernet_operations() and __unregister_pernet_operations(),
because many pernet ops are marked as __net_initdata and will be discarded,
which wreaks havoc on our ops lists. Here we rely on the fact that we only
use lists until init_net is fully initialized, which happens much earlier
than discarding __net_initdata sections.

Signed-off-by: Dmitry Torokhov <dmitry.torokhov@gmail.com>
---
 net/core/net_namespace.c | 21 +++++++++++++++++----
 1 file changed, 17 insertions(+), 4 deletions(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 2c2eb1b..1fe5816 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -37,6 +37,8 @@ struct net init_net = {
 };
 EXPORT_SYMBOL(init_net);
 
+static bool init_net_initialized;
+
 #define INITIAL_NET_GEN_PTRS	13 /* +1 for len +2 for rcu_head */
 
 static unsigned int max_gen_ptrs = INITIAL_NET_GEN_PTRS;
@@ -750,6 +752,8 @@ static int __init net_ns_init(void)
 	if (setup_net(&init_net, &init_user_ns))
 		panic("Could not setup the initial network namespace");
 
+	init_net_initialized = true;
+
 	rtnl_lock();
 	list_add_tail_rcu(&init_net.list, &net_namespace_list);
 	rtnl_unlock();
@@ -811,15 +815,24 @@ static void __unregister_pernet_operations(struct pernet_operations *ops)
 static int __register_pernet_operations(struct list_head *list,
 					struct pernet_operations *ops)
 {
+	if (!init_net_initialized) {
+		list_add_tail(&ops->list, list);
+		return 0;
+	}
+
 	return ops_init(ops, &init_net);
 }
 
 static void __unregister_pernet_operations(struct pernet_operations *ops)
 {
-	LIST_HEAD(net_exit_list);
-	list_add(&init_net.exit_list, &net_exit_list);
-	ops_exit_list(ops, &net_exit_list);
-	ops_free_list(ops, &net_exit_list);
+	if (!init_net_initialized) {
+		list_del(&ops->list);
+	} else {
+		LIST_HEAD(net_exit_list);
+		list_add(&init_net.exit_list, &net_exit_list);
+		ops_exit_list(ops, &net_exit_list);
+		ops_free_list(ops, &net_exit_list);
+	}
 }
 
 #endif /* CONFIG_NET_NS */
-- 
2.8.0.rc3.226.g39d4020
