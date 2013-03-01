From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v2 net-next 4/4] qlcnic: Use generic fdb handler when driver options are not enabled.
Date: Fri,  1 Mar 2013 10:31:46 -0500
Message-ID: <1362151906-20993-5-git-send-email-vyasevic@redhat.com>
References: <1362151906-20993-1-git-send-email-vyasevic@redhat.com>
Cc: john.r.fastabend@intel.com, Vlad Yasevich <vyasevic@redhat.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>, linux-driver@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40266 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751688Ab3CAPcI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Mar 2013 10:32:08 -0500
In-Reply-To: <1362151906-20993-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow qlcnic to use the generic fdb handler when the driver options
are not enabled.   Untill the driver is fully fixed, this allows
the use of the FDB interface with qlogic driver, but simply puts
the driver into promisc mode since the driver currently does not
support IFF_UNICAST_FLT.

CC: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Acked-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
CC: Sony Chacko <sony.chacko@qlogic.com>
CC: linux-driver@qlogic.com
Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   21 ++++++---------------
 1 files changed, 6 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 5d5fd06..d8dbf29 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -253,11 +253,8 @@ static int qlcnic_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	int err = -EOPNOTSUPP;
 
-	if (!adapter->fdb_mac_learn) {
-		pr_info("%s: Driver mac learn is enabled, FDB operation not allowed\n",
-			__func__);
-		return err;
-	}
+	if (!adapter->fdb_mac_learn)
+		return ndo_dflt_fdb_del(ndm, tb, netdev, addr);
 
 	if (adapter->flags & QLCNIC_ESWITCH_ENABLED) {
 		if (is_unicast_ether_addr(addr))
@@ -277,11 +274,8 @@ static int qlcnic_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	int err = 0;
 
-	if (!adapter->fdb_mac_learn) {
-		pr_info("%s: Driver mac learn is enabled, FDB operation not allowed\n",
-			__func__);
-		return -EOPNOTSUPP;
-	}
+	if (!adapter->fdb_mac_learn)
+		return ndo_dflt_fdb_add(ndm, tb, netdev, addr, flags);
 
 	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED)) {
 		pr_info("%s: FDB e-switch is not enabled\n", __func__);
@@ -306,11 +300,8 @@ static int qlcnic_fdb_dump(struct sk_buff *skb, struct netlink_callback *ncb,
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 
-	if (!adapter->fdb_mac_learn) {
-		pr_info("%s: Driver mac learn is enabled, FDB operation not allowed\n",
-			__func__);
-		return -EOPNOTSUPP;
-	}
+	if (!adapter->fdb_mac_learn)
+		return ndo_dflt_fdb_dump(skb, ncb, netdev, idx);
 
 	if (adapter->flags & QLCNIC_ESWITCH_ENABLED)
 		idx = ndo_dflt_fdb_dump(skb, ncb, netdev, idx);
-- 
1.7.7.6
