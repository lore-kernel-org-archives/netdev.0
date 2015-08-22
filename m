From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH 04/14] RDS: don't update ip address tables if the address hasn't changed
Date: Sat, 22 Aug 2015 15:45:25 -0700
Message-ID: <1440283535-4800-5-git-send-email-santosh.shilimkar@oracle.com>
References: <1440283535-4800-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440283535-4800-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If the ip address tables hasn't changed, there is no need to remove
them only to be added back again.

Lets fix it.
Reviewed-by: Ajaykumar Hotchandani <ajaykumar.hotchandani@oracle.com>
Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/ib_rdma.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/rds/ib_rdma.c b/net/rds/ib_rdma.c
index 657ba9f..e49c956 100644
--- a/net/rds/ib_rdma.c
+++ b/net/rds/ib_rdma.c
@@ -151,12 +151,17 @@ int rds_ib_update_ipaddr(struct rds_ib_device *rds_ibdev, __be32 ipaddr)
 	struct rds_ib_device *rds_ibdev_old;
 
 	rds_ibdev_old = rds_ib_get_device(ipaddr);
-	if (rds_ibdev_old) {
+	if (!rds_ibdev_old)
+		return rds_ib_add_ipaddr(rds_ibdev, ipaddr);
+
+	if (rds_ibdev_old != rds_ibdev) {
 		rds_ib_remove_ipaddr(rds_ibdev_old, ipaddr);
 		rds_ib_dev_put(rds_ibdev_old);
+		return rds_ib_add_ipaddr(rds_ibdev, ipaddr);
 	}
+	rds_ib_dev_put(rds_ibdev_old);
 
-	return rds_ib_add_ipaddr(rds_ibdev, ipaddr);
+	return 0;
 }
 
 void rds_ib_add_conn(struct rds_ib_device *rds_ibdev, struct rds_connection *conn)
-- 
1.9.1
