From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH] netlink: make compare exist all the time
Date: Thu, 13 Jun 2013 10:05:38 +0800
Message-ID: <1371089138-4990-1-git-send-email-gaofeng@cn.fujitsu.com>
References: <20130613012216.GA6788@localhost>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Gao feng <gaofeng@cn.fujitsu.com>
To: fengguang.wu@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130613012216.GA6788@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit da12c90e099789a63073fc82a19542ce54d4efb9
"netlink: Add compare function for netlink_table"
only set compare at the time we create kernel netlink,
and reset compare to NULL at the time we finially
release netlink socket, but netlink_lookup wants
the compare exist always.

So we should set compare after we allocate nl_table,
and never reset it. make comapre exist all the time.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/netlink/af_netlink.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 9b6b115..8978755 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1174,7 +1174,6 @@ static int netlink_release(struct socket *sock)
 			kfree_rcu(old, rcu);
 			nl_table[sk->sk_protocol].module = NULL;
 			nl_table[sk->sk_protocol].bind = NULL;
-			nl_table[sk->sk_protocol].compare = NULL;
 			nl_table[sk->sk_protocol].flags = 0;
 			nl_table[sk->sk_protocol].registered = 0;
 		}
@@ -2326,7 +2325,6 @@ __netlink_kernel_create(struct net *net, int unit, struct module *module,
 		rcu_assign_pointer(nl_table[unit].listeners, listeners);
 		nl_table[unit].cb_mutex = cb_mutex;
 		nl_table[unit].module = module;
-		nl_table[unit].compare = netlink_compare;
 		if (cfg) {
 			nl_table[unit].bind = cfg->bind;
 			nl_table[unit].flags = cfg->flags;
@@ -2973,6 +2971,8 @@ static int __init netlink_proto_init(void)
 		hash->shift = 0;
 		hash->mask = 0;
 		hash->rehash_time = jiffies;
+
+		nl_table[i].compare = netlink_compare;
 	}
 
 	netlink_add_usersock_entry();
-- 
1.8.1.4
