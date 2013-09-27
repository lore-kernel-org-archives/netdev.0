From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 4/9] bonding: make __get_active_agg() use bond_for_each_slave()
Date: Fri, 27 Sep 2013 16:12:00 +0200
Message-ID: <1380291125-5671-5-git-send-email-vfalico@redhat.com>
References: <1380291125-5671-1-git-send-email-vfalico@redhat.com>
Cc: nikolay@redhat.com, bhutchings@solarflare.com,
	Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31703 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752458Ab3I0OLz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Sep 2013 10:11:55 -0400
In-Reply-To: <1380291125-5671-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we're relying on suboptimal construct

for (; aggregator; aggregator = __get_next_agg(aggregator)) {

where aggregator is an argument of __get_active_agg() which is _always_ the
first slave's aggregator - judging by all the callers, comments in the
ad_agg_selection_logic() and by logic.

Convert it to use the standard bond_for_each_slave().

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_3ad.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 8b64ed4..1109d82 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -720,16 +720,15 @@ static u32 __get_agg_bandwidth(struct aggregator *aggregator)
  */
 static struct aggregator *__get_active_agg(struct aggregator *aggregator)
 {
-	struct aggregator *retval = NULL;
+	struct bonding *bond = aggregator->slave->bond;
+	struct list_head *iter;
+	struct slave *slave;
 
-	for (; aggregator; aggregator = __get_next_agg(aggregator)) {
-		if (aggregator->is_active) {
-			retval = aggregator;
-			break;
-		}
-	}
+	bond_for_each_slave(bond, slave, iter)
+		if (SLAVE_AD_INFO(slave).aggregator.is_active)
+			return &(SLAVE_AD_INFO(slave).aggregator);
 
-	return retval;
+	return NULL;
 }
 
 /**
-- 
1.8.4
