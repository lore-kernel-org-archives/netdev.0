From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 3/8] e1000: prevent oops when adapter is being closed and reset simultaneously
Date: Wed, 27 Nov 2013 23:35:57 -0800
Message-ID: <1385624162-10116-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1385624162-10116-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: yzhu1 <yanjun.zhu@windriver.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:62417 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752275Ab3K1Hgd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Nov 2013 02:36:33 -0500
In-Reply-To: <1385624162-10116-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yzhu1 <yanjun.zhu@windriver.com>

This change is based on a similar change made to e1000e support in
commit bb9e44d0d0f4 ("e1000e: prevent oops when adapter is being closed
and reset simultaneously").  The same issue has also been observed
on the older e1000 cards.

Here, we have increased the RESET_COUNT value to 50 because there are too
many accesses to e1000 nic on stress tests to e1000 nic, it is not enough
to set RESET_COUT 25. Experimentation has shown that it is enough to set
RESET_COUNT 50.

Signed-off-by: yzhu1 <yanjun.zhu@windriver.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000.h      | 5 +++++
 drivers/net/ethernet/intel/e1000/e1000_main.c | 9 +++++++++
 2 files changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000/e1000.h b/drivers/net/ethernet/intel/e1000/e1000.h
index 58c1472..e4093d1 100644
--- a/drivers/net/ethernet/intel/e1000/e1000.h
+++ b/drivers/net/ethernet/intel/e1000/e1000.h
@@ -83,6 +83,11 @@ struct e1000_adapter;
 
 #define E1000_MAX_INTR			10
 
+/*
+ * Count for polling __E1000_RESET condition every 10-20msec.
+ */
+#define E1000_CHECK_RESET_COUNT	50
+
 /* TX/RX descriptor defines */
 #define E1000_DEFAULT_TXD		256
 #define E1000_MAX_TXD			256
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index e386228..c0f5217 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -1440,6 +1440,10 @@ static int e1000_close(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
+	int count = E1000_CHECK_RESET_COUNT;
+
+	while (test_bit(__E1000_RESETTING, &adapter->flags) && count--)
+		usleep_range(10000, 20000);
 
 	WARN_ON(test_bit(__E1000_RESETTING, &adapter->flags));
 	e1000_down(adapter);
@@ -4963,6 +4967,11 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool *enable_wake)
 	netif_device_detach(netdev);
 
 	if (netif_running(netdev)) {
+		int count = E1000_CHECK_RESET_COUNT;
+
+		while (test_bit(__E1000_RESETTING, &adapter->flags) && count--)
+			usleep_range(10000, 20000);
+
 		WARN_ON(test_bit(__E1000_RESETTING, &adapter->flags));
 		e1000_down(adapter);
 	}
-- 
1.8.3.1
