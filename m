From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net 3/4] qlcnic: Fix tx timeout.
Date: Tue, 28 Jan 2014 11:55:29 -0500
Message-ID: <1390928130-10710-4-git-send-email-rajesh.borundia@qlogic.com>
References: <1390928130-10710-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:61456 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755239AbaA1RaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jan 2014 12:30:05 -0500
In-Reply-To: <1390928130-10710-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o __qlcnic_down call's netif_tx_disable which in turn stops
  all the TX queues, corresponding start queue was missing in
  __qlcnic_up which was leading to tx timeout.
o The commit b84caae486135d588fb200973b0be8cb8a511edf
  (qlcnic: Fix usage of netif_tx_{wake, stop} api during link change.)
  exposed this issue.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 1f79d47..ba78c74 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -1837,6 +1837,7 @@ int __qlcnic_up(struct qlcnic_adapter *adapter, struct net_device *netdev)
 	qlcnic_linkevent_request(adapter, 1);
 
 	adapter->ahw->reset_context = 0;
+	netif_tx_start_all_queues(netdev);
 	return 0;
 }
 
@@ -2704,14 +2705,8 @@ static int qlcnic_open(struct net_device *netdev)
 
 	err = __qlcnic_up(adapter, netdev);
 	if (err)
-		goto err_out;
-
-	netif_tx_start_all_queues(netdev);
-
-	return 0;
+		qlcnic_detach(adapter);
 
-err_out:
-	qlcnic_detach(adapter);
 	return err;
 }
 
-- 
1.5.6
