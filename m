From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 2/2] bonding: verify if we still have slaves in bond_3ad_unbind_slave()
Date: Fri, 27 Sep 2013 15:10:58 +0200
Message-ID: <1380287458-3488-3-git-send-email-vfalico@redhat.com>
References: <1380287458-3488-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3579 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751891Ab3I0NKp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Sep 2013 09:10:45 -0400
In-Reply-To: <1380287458-3488-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit 1f718f0f4f97145f4072d2d72dcf85069ca7226d ("bonding: populate
neighbour's private on enslave"), we've moved the unlinking of the slave
to the earliest position possible - so that nobody will see an
half-uninited slave.

However, bond_3ad_unbind_slave() relied that, even while removing the last
slave, it is still accessible - via __get_first_agg() (and, eventually,
bond_first_slave()).

Fix that by verifying if the aggregator return is an actual aggregator, but
not NULL.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_3ad.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 1337eaf..2715ea8 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2056,7 +2056,9 @@ void bond_3ad_unbind_slave(struct slave *slave)
 				pr_info("%s: Removing an active aggregator\n",
 					slave->bond->dev->name);
 				// select new active aggregator
-				ad_agg_selection_logic(__get_first_agg(port));
+				temp_aggregator = __get_first_agg(port);
+				if (temp_aggregator)
+					ad_agg_selection_logic(temp_aggregator);
 			}
 		}
 	}
-- 
1.8.4
