From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH 2/2] RDS: Fix the atomicity for congestion map update
Date: Fri,  8 Apr 2016 15:26:40 -0700
Message-ID: <1460154400-14546-3-git-send-email-santosh.shilimkar@oracle.com>
References: <1460154400-14546-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460154400-14546-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Two different threads with different rds sockets may be in
rds_recv_rcvbuf_delta() via receive path. If their ports
both map to the same word in the congestion map, then
using non-atomic ops to update it could cause the map to
be incorrect. Lets use atomics to avoid such an issue.

Full credit to Wengang <wen.gang.wang@oracle.com> for
finding the issue, analysing it and also pointing out
to offending code with spin lock based fix.

Reviewed-by: Leon Romanovsky <leon@leon.nu>
Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/cong.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/rds/cong.c b/net/rds/cong.c
index e6144b8..6641bcf 100644
--- a/net/rds/cong.c
+++ b/net/rds/cong.c
@@ -299,7 +299,7 @@ void rds_cong_set_bit(struct rds_cong_map *map, __be16 port)
 	i = be16_to_cpu(port) / RDS_CONG_MAP_PAGE_BITS;
 	off = be16_to_cpu(port) % RDS_CONG_MAP_PAGE_BITS;
 
-	__set_bit_le(off, (void *)map->m_page_addrs[i]);
+	set_bit_le(off, (void *)map->m_page_addrs[i]);
 }
 
 void rds_cong_clear_bit(struct rds_cong_map *map, __be16 port)
@@ -313,7 +313,7 @@ void rds_cong_clear_bit(struct rds_cong_map *map, __be16 port)
 	i = be16_to_cpu(port) / RDS_CONG_MAP_PAGE_BITS;
 	off = be16_to_cpu(port) % RDS_CONG_MAP_PAGE_BITS;
 
-	__clear_bit_le(off, (void *)map->m_page_addrs[i]);
+	clear_bit_le(off, (void *)map->m_page_addrs[i]);
 }
 
 static int rds_cong_test_bit(struct rds_cong_map *map, __be16 port)
-- 
1.9.1
