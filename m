From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 5/7] qlcnic: Enhance semaphore lock access failure error message
Date: Fri, 21 Feb 2014 13:20:14 -0500
Message-ID: <1393006816-20294-6-git-send-email-shahed.shaikh@qlogic.com>
References: <1393006816-20294-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Harish Patil <harish.patil@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:35555 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753541AbaBUSzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 13:55:50 -0500
In-Reply-To: <1393006816-20294-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harish Patil <harish.patil@qlogic.com>

Signed-off-by: Harish Patil <harish.patil@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c | 22 +++++++++++++++-------
 1 file changed, 15 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index 03d18a0..9f3adf4 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -317,9 +317,7 @@ static void qlcnic_write_window_reg(u32 addr, void __iomem *bar0, u32 data)
 int
 qlcnic_pcie_sem_lock(struct qlcnic_adapter *adapter, int sem, u32 id_reg)
 {
-	int timeout = 0;
-	int err = 0;
-	u32 done = 0;
+	int timeout = 0, err = 0, done = 0;
 
 	while (!done) {
 		done = QLCRD32(adapter, QLCNIC_PCIE_REG(PCIE_SEM_LOCK(sem)),
@@ -327,10 +325,20 @@ qlcnic_pcie_sem_lock(struct qlcnic_adapter *adapter, int sem, u32 id_reg)
 		if (done == 1)
 			break;
 		if (++timeout >= QLCNIC_PCIE_SEM_TIMEOUT) {
-			dev_err(&adapter->pdev->dev,
-				"Failed to acquire sem=%d lock; holdby=%d\n",
-				sem,
-				id_reg ? QLCRD32(adapter, id_reg, &err) : -1);
+			if (id_reg) {
+				done = QLCRD32(adapter, id_reg, &err);
+				if (done != -1)
+					dev_err(&adapter->pdev->dev,
+						"Failed to acquire sem=%d lock held by=%d\n",
+						sem, done);
+				else
+					dev_err(&adapter->pdev->dev,
+						"Failed to acquire sem=%d lock",
+						sem);
+			} else {
+				dev_err(&adapter->pdev->dev,
+					"Failed to acquire sem=%d lock", sem);
+			}
 			return -EIO;
 		}
 		msleep(1);
-- 
1.8.1.4
