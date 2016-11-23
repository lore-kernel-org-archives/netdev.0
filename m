From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V3 for-next 03/11] IB/hns: Optimize the logic of allocating memory using APIs
Date: Wed, 23 Nov 2016 19:41:01 +0000
Message-ID: <20161123194109.420760-4-salil.mehta@huawei.com>
References: <20161123194109.420760-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <xavier.huwei@huawei.com>,
        <oulijun@huawei.com>, <xushaobo2@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <lijun_nudt@163.com>,
        <linux-rdma@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <linuxarm@huawei.com>,
        Ping Zhang <zhangping5@huawei.com>
To: <dledford@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161123194109.420760-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Wei Hu (Xavier)" <xavier.huwei@huawei.com>

This patch modified the logic of allocating memory using APIs in
hns RoCE driver. We used kcalloc instead of kmalloc_array and
bitmap_zero. And When kcalloc failed, call vzalloc to alloc
memory.

Signed-off-by: Wei Hu (Xavier) <xavier.huwei@huawei.com>
Signed-off-by: Ping Zhang <zhangping5@huawei.com>
Signed-off-by: Salil Mehta  <salil.mehta@huawei.com>
---
Change log:

PATCH V2: Addressed comment given by Leon
         Link: https://patchwork.kernel.org/patch/9412859/
PATCH V1: Initial Submit
---
 drivers/infiniband/hw/hns/hns_roce_mr.c |   16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/infiniband/hw/hns/hns_roce_mr.c b/drivers/infiniband/hw/hns/hns_roce_mr.c
index fb87883..d87d189 100644
--- a/drivers/infiniband/hw/hns/hns_roce_mr.c
+++ b/drivers/infiniband/hw/hns/hns_roce_mr.c
@@ -137,11 +137,13 @@ static int hns_roce_buddy_init(struct hns_roce_buddy *buddy, int max_order)
 
 	for (i = 0; i <= buddy->max_order; ++i) {
 		s = BITS_TO_LONGS(1 << (buddy->max_order - i));
-		buddy->bits[i] = kmalloc_array(s, sizeof(long), GFP_KERNEL);
-		if (!buddy->bits[i])
-			goto err_out_free;
-
-		bitmap_zero(buddy->bits[i], 1 << (buddy->max_order - i));
+		buddy->bits[i] = kcalloc(s, sizeof(long), GFP_KERNEL |
+					 __GFP_NOWARN);
+		if (!buddy->bits[i]) {
+			buddy->bits[i] = vzalloc(s * sizeof(long));
+			if (!buddy->bits[i])
+				goto err_out_free;
+		}
 	}
 
 	set_bit(0, buddy->bits[buddy->max_order]);
@@ -151,7 +153,7 @@ static int hns_roce_buddy_init(struct hns_roce_buddy *buddy, int max_order)
 
 err_out_free:
 	for (i = 0; i <= buddy->max_order; ++i)
-		kfree(buddy->bits[i]);
+		kvfree(buddy->bits[i]);
 
 err_out:
 	kfree(buddy->bits);
@@ -164,7 +166,7 @@ static void hns_roce_buddy_cleanup(struct hns_roce_buddy *buddy)
 	int i;
 
 	for (i = 0; i <= buddy->max_order; ++i)
-		kfree(buddy->bits[i]);
+		kvfree(buddy->bits[i]);
 
 	kfree(buddy->bits);
 	kfree(buddy->num_free);
-- 
1.7.9.5
