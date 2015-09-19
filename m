From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH 01/15] RDS: use kfree_rcu in rds_ib_remove_ipaddr
Date: Sat, 19 Sep 2015 19:04:38 -0400
Message-ID: <1442703892-26692-2-git-send-email-santosh.shilimkar@oracle.com>
References: <1442703892-26692-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442703892-26692-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

synchronize_rcu() slowing down un-necessarily the socket shutdown
path. It is used just kfree() the ip addresses in rds_ib_remove_ipaddr()
which is perfect usecase for kfree_rcu();

So lets use that to gain some speedup.

Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/ib.h      | 1 +
 net/rds/ib_rdma.c | 6 ++----
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/rds/ib.h b/net/rds/ib.h
index aae60fd..f1fd5ff 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -164,6 +164,7 @@ struct rds_ib_connection {
 struct rds_ib_ipaddr {
 	struct list_head	list;
 	__be32			ipaddr;
+	struct rcu_head		rcu;
 };
 
 struct rds_ib_device {
diff --git a/net/rds/ib_rdma.c b/net/rds/ib_rdma.c
index 251d1ce..872f523 100644
--- a/net/rds/ib_rdma.c
+++ b/net/rds/ib_rdma.c
@@ -159,10 +159,8 @@ static void rds_ib_remove_ipaddr(struct rds_ib_device *rds_ibdev, __be32 ipaddr)
 	}
 	spin_unlock_irq(&rds_ibdev->spinlock);
 
-	if (to_free) {
-		synchronize_rcu();
-		kfree(to_free);
-	}
+	if (to_free)
+		kfree_rcu(to_free, rcu);
 }
 
 int rds_ib_update_ipaddr(struct rds_ib_device *rds_ibdev, __be32 ipaddr)
-- 
1.9.1
