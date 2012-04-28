From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 07/10] atl1c: cancel task when interface closed
Date: Sat, 28 Apr 2012 09:58:42 +0800
Message-ID: <1335578325-21326-8-git-send-email-xiong@qca.qualcomm.com>
References: <1335578325-21326-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:48308 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759045Ab2D1CAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2012 22:00:20 -0400
In-Reply-To: <1335578325-21326-1-git-send-email-xiong@qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

common_task might be running while close routine is called,
wait/cancel it.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 8fee1fc..e082901 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -330,6 +330,9 @@ static void atl1c_common_task(struct work_struct *work)
 	adapter = container_of(work, struct atl1c_adapter, common_task);
 	netdev = adapter->netdev;
 
+	if (test_bit(__AT_DOWN, &adapter->flags))
+		return;
+
 	if (test_and_clear_bit(ATL1C_WORK_EVENT_RESET, &adapter->work_event)) {
 		netif_device_detach(netdev);
 		atl1c_down(adapter);
@@ -2313,6 +2316,8 @@ static int atl1c_close(struct net_device *netdev)
 	struct atl1c_adapter *adapter = netdev_priv(netdev);
 
 	WARN_ON(test_bit(__AT_RESETTING, &adapter->flags));
+	set_bit(__AT_DOWN, &adapter->flags);
+	cancel_work_sync(&adapter->common_task);
 	atl1c_down(adapter);
 	atl1c_free_ring_resources(adapter);
 	return 0;
-- 
1.7.7
