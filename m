From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 1/6] qed: Pass MAC hints to VFs
Date: Sun, 9 Oct 2016 18:25:33 +0300
Message-ID: <1476026738-26069-2-git-send-email-Yuval.Mintz@qlogic.com>
References: <1476026738-26069-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@caviumnetworks.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:49246 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751694AbcJIQSP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2016 12:18:15 -0400
In-Reply-To: <1476026738-26069-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@caviumnetworks.com>

Some hypervisors can support MAC hints to their VFs.
Even though we don't have such a hypervisor API in linux, we add
sufficient logic for the VF to be able to receive such hints and
set the mac accordingly - as long as the VF has not been set with
a MAC already.

Signed-off-by: Yuval Mintz <Yuval.Mintz@caviumnetworks.com>
---
 drivers/net/ethernet/qlogic/qed/qed_vf.c     | 4 ++--
 drivers/net/ethernet/qlogic/qede/qede_main.c | 6 +++++-
 include/linux/qed/qed_eth_if.h               | 2 +-
 3 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.c b/drivers/net/ethernet/qlogic/qed/qed_vf.c
index abf5bf1..f580bf4 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.c
@@ -1230,8 +1230,8 @@ static void qed_handle_bulletin_change(struct qed_hwfn *hwfn)
 
 	is_mac_exist = qed_vf_bulletin_get_forced_mac(hwfn, mac,
 						      &is_mac_forced);
-	if (is_mac_exist && is_mac_forced && cookie)
-		ops->force_mac(cookie, mac);
+	if (is_mac_exist && cookie)
+		ops->force_mac(cookie, mac, !!is_mac_forced);
 
 	/* Always update link configuration according to bulletin */
 	qed_link_update(hwfn);
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 343038c..9866d95 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -171,10 +171,14 @@ static struct pci_driver qede_pci_driver = {
 #endif
 };
 
-static void qede_force_mac(void *dev, u8 *mac)
+static void qede_force_mac(void *dev, u8 *mac, bool forced)
 {
 	struct qede_dev *edev = dev;
 
+	/* MAC hints take effect only if we haven't set one already */
+	if (is_valid_ether_addr(edev->ndev->dev_addr) && !forced)
+		return;
+
 	ether_addr_copy(edev->ndev->dev_addr, mac);
 	ether_addr_copy(edev->primary_mac, mac);
 }
diff --git a/include/linux/qed/qed_eth_if.h b/include/linux/qed/qed_eth_if.h
index 33c24eb..1c77948 100644
--- a/include/linux/qed/qed_eth_if.h
+++ b/include/linux/qed/qed_eth_if.h
@@ -129,7 +129,7 @@ struct qed_tunn_params {
 
 struct qed_eth_cb_ops {
 	struct qed_common_cb_ops common;
-	void (*force_mac) (void *dev, u8 *mac);
+	void (*force_mac) (void *dev, u8 *mac, bool forced);
 };
 
 #ifdef CONFIG_DCB
-- 
1.9.3
