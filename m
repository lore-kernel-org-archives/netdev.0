From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 2/4] bonding: do not save non-existent device to
 bond primary in check params
Date: Thu, 9 Jan 2014 19:20:39 +0800
Message-ID: <52CE8607.1050103@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:27323 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752446AbaAILVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 06:21:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When install the bonding, the primay will be use to distinguish
the primary slave for ab, alb and tlb mode, but it is meanless
to save a no existed device, so add check for it.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index de646e2..651c5fd 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4246,13 +4246,19 @@ static int bond_check_params(struct bond_params *params)
 		pr_debug("Warning: either miimon or arp_interval and arp_ip_target module parameters must be specified, otherwise bonding will not detect link failures! see bonding.txt for details.\n");
 	}
 
-	if (primary && !USES_PRIMARY(bond_mode)) {
-		/* currently, using a primary only makes sense
-		 * in active backup, TLB or ALB modes
-		 */
-		pr_warning("Warning: %s primary device specified but has no effect in %s mode\n",
-			   primary, bond_mode_name(bond_mode));
-		primary = NULL;
+	if (primary) {
+		if (!__dev_get_by_name(&init_net, primary)) {
+			pr_warn("Warning: %s primary device is not exist\n",
+				primary);
+			primary = NULL;
+		} else if (!USES_PRIMARY(bond_mode)) {
+			/* currently, using a primary only makes sense
+			 * in active backup, TLB or ALB modes
+			 */
+			pr_warn("Warning: %s primary device specified but has no effect in %s mode\n",
+				primary, bond_mode_name(bond_mode));
+			primary = NULL;
+		}
 	}
 
 	if (primary && primary_reselect) {
-- 
1.8.0
