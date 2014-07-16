From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 1/5] net/mlx4_core: Fix leakage of SW multicast entries
Date: Wed, 16 Jul 2014 11:57:47 +0300
Message-ID: <1405501071-9340-2-git-send-email-amirv@mellanox.com>
References: <1405501071-9340-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:50752 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759786AbaGPI6I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2014 04:58:08 -0400
In-Reply-To: <1405501071-9340-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

When removing multicast address in B0 steering mode there is
a bug in cases where there is a single QP registered for the address,
and this QP is also promiscuous. In such cases the entry wouldn't be
deleted from the SW structure representing all Ethernet MCG entries,
but would be removed in HW. This way when driver goes to remove it
from SW and HW structures the HW deletion fails.
Moreover the same index could later be used for registering
different address, which can be Infiniband.


Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/mcg.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index 4c36def..14a4071 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -363,8 +363,20 @@ static bool can_remove_steering_entry(struct mlx4_dev *dev, u8 port,
 	ret = true;
 	list_for_each_entry_safe(entry, tmp_entry, &s_steer->steer_entries[steer], list) {
 		if (entry->index == index) {
-			if (list_empty(&entry->duplicates)) {
+			if (list_empty(&entry->duplicates) ||
+			    members_count == 1) {
+				struct mlx4_promisc_qp *pqp, *tmp_pqp;
+				/* If there is only 1 entry in duplicates then
+				 * this is the QP we want to delete, going over
+				 * the list and deleting the entry.
+				 */
 				list_del(&entry->list);
+				list_for_each_entry_safe(pqp, tmp_pqp,
+							 &entry->duplicates,
+							 list) {
+					list_del(&pqp->list);
+					kfree(pqp);
+				}
 				kfree(entry);
 			} else {
 				/* This entry contains duplicates so it shouldn't be removed */
-- 
1.8.3.4
