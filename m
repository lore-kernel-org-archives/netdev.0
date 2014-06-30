From: David Decotigny <decot@googlers.com>
Subject: [PATCH net-next v1 2/2] netpoll: avoid reference leaks
Date: Mon, 30 Jun 2014 16:50:10 -0700
Message-ID: <f98ccbfee35a7ab7f9499ede9b34e6b1120d88f1.1404172155.git.decot@googlers.com>
References: <0f692012238337f2c40893319830ae042523ce18.1404172155.git.decot@googlers.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <edumazet@google.com>,
	Cong Wang <amwang@redhat.com>,
	David Decotigny <decot@googlers.com>,
	Antonio Quartulli <antonio@meshcoding.com>,
	Jiri Pirko <jpirko@redhat.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0f692012238337f2c40893319830ae042523ce18.1404172155.git.decot@googlers.com>
In-Reply-To: <cover.1404172155.git.decot@googlers.com>
References: <cover.1404172155.git.decot@googlers.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This ensures that the ndo_netpoll_cleanup callback is called for every
device that provides one. Otherwise there is a risk of reference leak
with bonding for example, which depends on this callback to cleanup
the slaves' references to netpoll info.

Tested:
  see patch "netpoll: fix use after free"

Signed-off-by: David Decotigny <decot@googlers.com>
---
 net/core/netpoll.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 907fb5e..1e10d5d 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -802,6 +802,7 @@ static void rcu_cleanup_netpoll_info(struct rcu_head *rcu_head)
 void __netpoll_cleanup(struct netpoll *np)
 {
 	struct netpoll_info *npinfo;
+	const struct net_device_ops *ops;
 
 	/* rtnl_dereference would be preferable here but
 	 * rcu_cleanup_netpoll path can put us in here safely without
@@ -813,17 +814,17 @@ void __netpoll_cleanup(struct netpoll *np)
 
 	synchronize_srcu(&netpoll_srcu);
 
-	if (atomic_dec_and_test(&npinfo->refcnt)) {
-		const struct net_device_ops *ops;
+	ops = np->dev->netdev_ops;
+	if (ops->ndo_netpoll_cleanup)
+		ops->ndo_netpoll_cleanup(np->dev);
 
-		ops = np->dev->netdev_ops;
-		if (ops->ndo_netpoll_cleanup)
-			ops->ndo_netpoll_cleanup(np->dev);
+	/* before dropping ref count, make sure this device does not
+	 * reference npinfo anymore
+	 */
+	RCU_INIT_POINTER(np->dev->npinfo, NULL);
 
-		RCU_INIT_POINTER(np->dev->npinfo, NULL);
+	if (atomic_dec_and_test(&npinfo->refcnt))
 		call_rcu_bh(&npinfo->rcu, rcu_cleanup_netpoll_info);
-	} else
-		RCU_INIT_POINTER(np->dev->npinfo, NULL);
 }
 EXPORT_SYMBOL_GPL(__netpoll_cleanup);
 
-- 
2.0.0.526.g5318336
