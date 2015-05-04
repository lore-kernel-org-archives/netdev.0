From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net] bnx2x: Fix to prevent inner-reload
Date: Mon, 4 May 2015 12:34:12 +0300
Message-ID: <1430732052-17722-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:8407 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752085AbbEDJeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 05:34:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Submit 909d9faae2a44 ("bnx2x: Prevent inner-reload while VFs exist")
contained a bug - MTU change was not prevented by it; Instead, it
`randomally' prevented bnx2x_resume() from running [harmless yet wrong].

This moves the check to its correct spot.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
Hi Dave,

Please consider applying this to 'net'.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 3558a36..4213825 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -4786,6 +4786,11 @@ int bnx2x_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 
+	if (pci_num_vf(bp->pdev)) {
+		DP(BNX2X_MSG_IOV, "VFs are enabled, can not change MTU\n");
+		return -EPERM;
+	}
+
 	if (bp->recovery_state != BNX2X_RECOVERY_DONE) {
 		BNX2X_ERR("Can't perform change MTU during parity recovery\n");
 		return -EAGAIN;
@@ -4953,11 +4958,6 @@ int bnx2x_resume(struct pci_dev *pdev)
 	}
 	bp = netdev_priv(dev);
 
-	if (pci_num_vf(bp->pdev)) {
-		DP(BNX2X_MSG_IOV, "VFs are enabled, can not change MTU\n");
-		return -EPERM;
-	}
-
 	if (bp->recovery_state != BNX2X_RECOVERY_DONE) {
 		BNX2X_ERR("Handling parity error recovery. Try again later\n");
 		return -EAGAIN;
-- 
1.9.3
