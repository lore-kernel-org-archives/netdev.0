From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next] bonding: fix u64 division
Date: Thu, 23 Jan 2014 23:43:43 +0100
Message-ID: <1390517023-31950-1-git-send-email-nikolay@redhat.com>
References: <52E18720.4060008@redhat.com>
Cc: davem@davemloft.net, zoltan.kiss@citrix.com, andy@greyhouse.net,
	vfalico@redhat.com, fubar@us.ibm.com, nikolay@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30299 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751979AbaAWWo1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jan 2014 17:44:27 -0500
In-Reply-To: <52E18720.4060008@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the option conversion downdelay and updelay divide a u64
and on a 32 bit this causes the following errors:
ERROR: "__udivdi3" [drivers/net/bonding/bonding.ko] undefined!
ERROR: "__umoddi3" [drivers/net/bonding/bonding.ko] undefined!

Fix it by using a normal int instead because newval->value is capped
at INT_MAX by the way the option is defined.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
This is what I meant, but it's only compile-tested, I can't
test it until tomorrow.

 drivers/net/bonding/bond_options.c | 24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 4cee04a..11cb943 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -727,19 +727,21 @@ int bond_option_miimon_set(struct bonding *bond, struct bond_opt_value *newval)
 
 int bond_option_updelay_set(struct bonding *bond, struct bond_opt_value *newval)
 {
+	int value = newval->value;
+
 	if (!bond->params.miimon) {
 		pr_err("%s: Unable to set up delay as MII monitoring is disabled\n",
 		       bond->dev->name);
 		return -EPERM;
 	}
-	if ((newval->value % bond->params.miimon) != 0) {
-		pr_warn("%s: Warning: up delay (%llu) is not a multiple of miimon (%d), updelay rounded to %llu ms\n",
-			bond->dev->name, newval->value,
+	if ((value % bond->params.miimon) != 0) {
+		pr_warn("%s: Warning: up delay (%d) is not a multiple of miimon (%d), updelay rounded to %d ms\n",
+			bond->dev->name, value,
 			bond->params.miimon,
-			(newval->value / bond->params.miimon) *
+			(value / bond->params.miimon) *
 			bond->params.miimon);
 	}
-	bond->params.updelay = newval->value / bond->params.miimon;
+	bond->params.updelay = value / bond->params.miimon;
 	pr_info("%s: Setting up delay to %d.\n",
 		bond->dev->name,
 		bond->params.updelay * bond->params.miimon);
@@ -750,19 +752,21 @@ int bond_option_updelay_set(struct bonding *bond, struct bond_opt_value *newval)
 int bond_option_downdelay_set(struct bonding *bond,
 			      struct bond_opt_value *newval)
 {
+	int value = newval->value;
+
 	if (!bond->params.miimon) {
 		pr_err("%s: Unable to set down delay as MII monitoring is disabled\n",
 		       bond->dev->name);
 		return -EPERM;
 	}
-	if ((newval->value % bond->params.miimon) != 0) {
-		pr_warn("%s: Warning: down delay (%llu) is not a multiple of miimon (%d), delay rounded to %llu ms\n",
-			bond->dev->name, newval->value,
+	if ((value % bond->params.miimon) != 0) {
+		pr_warn("%s: Warning: down delay (%d) is not a multiple of miimon (%d), delay rounded to %d ms\n",
+			bond->dev->name, value,
 			bond->params.miimon,
-			(newval->value / bond->params.miimon) *
+			(value / bond->params.miimon) *
 			bond->params.miimon);
 	}
-	bond->params.downdelay = newval->value / bond->params.miimon;
+	bond->params.downdelay = value / bond->params.miimon;
 	pr_info("%s: Setting down delay to %d.\n",
 		bond->dev->name,
 		bond->params.downdelay * bond->params.miimon);
-- 
1.8.4.2
