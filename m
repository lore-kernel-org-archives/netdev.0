From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH] cxgb4i: Fix neigh entry leak
Date: Wed, 17 Jun 2015 17:17:16 +0800
Message-ID: <1434532636-32274-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-scsi@vger.kernel.org>, <netdev@vger.kernel.org>
To: <kxie@chelsio.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When csk->atid returned by cxgb4_alloc_atid() is less than zero,
init_act_open() directly returns with -EINVAL. But as init_act_open()
ever invokes dst_neigh_lookup() before it calls cxgb4_alloc_atid(),
this leads to the leak of neigh entry searched by dst_neigh_lookup().

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index dd00e5f..c449d2a 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -1393,7 +1393,7 @@ static int init_act_open(struct cxgbi_sock *csk)
 	csk->atid = cxgb4_alloc_atid(lldi->tids, csk);
 	if (csk->atid < 0) {
 		pr_err("%s, NO atid available.\n", ndev->name);
-		return -EINVAL;
+		goto rel_resource;
 	}
 	cxgbi_sock_set_flag(csk, CTPF_HAS_ATID);
 	cxgbi_sock_get(csk);
-- 
1.7.9.5

