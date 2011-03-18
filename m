From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 05/36] block,rcu: convert call_rcu(disk_free_ptbl_rcu_cb)
 to kfree_rcu()
Date: Fri, 18 Mar 2011 11:42:58 +0800
Message-ID: <4D82D4C2.8020503__30667.6882355989$1300419700$gmane$org@cn.fujitsu.com>
References: <4D82D071.5020703@cn.fujitsu.com> <4D82D3FF.2080303@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>, Jens Axboe <axboe@kernel.dk>,
	Robert Love <robert.w.love@intel.com>,
	"James E.J. Bottomley" <James.Bottom
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61906 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932090Ab1CRDlP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2011 23:41:15 -0400
In-Reply-To: <4D82D3FF.2080303@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



The rcu callback disk_free_ptbl_rcu_cb() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(disk_free_ptbl_rcu_cb).

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 block/genhd.c |   10 +---------
 1 files changed, 1 insertions(+), 9 deletions(-)

diff --git a/block/genhd.c b/block/genhd.c
index cbf1112..2800cc8 100644
--- a/block/genhd.c
+++ b/block/genhd.c
@@ -1018,14 +1018,6 @@ static const struct attribute_group *disk_attr_groups[] = {
 	NULL
 };
 
-static void disk_free_ptbl_rcu_cb(struct rcu_head *head)
-{
-	struct disk_part_tbl *ptbl =
-		container_of(head, struct disk_part_tbl, rcu_head);
-
-	kfree(ptbl);
-}
-
 /**
  * disk_replace_part_tbl - replace disk->part_tbl in RCU-safe way
  * @disk: disk to replace part_tbl for
@@ -1046,7 +1038,7 @@ static void disk_replace_part_tbl(struct gendisk *disk,
 
 	if (old_ptbl) {
 		rcu_assign_pointer(old_ptbl->last_lookup, NULL);
-		call_rcu(&old_ptbl->rcu_head, disk_free_ptbl_rcu_cb);
+		kfree_rcu(old_ptbl, rcu_head);
 	}
 }
 
-- 
1.7.4
