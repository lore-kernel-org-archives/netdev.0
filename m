From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: [PATCH net 17/18] net/ena: fix NULL dereference when removing the driver after device reset faild
Date: Sun, 20 Nov 2016 10:45:46 +0200
Message-ID: <1479631547-29354-18-git-send-email-netanel@annapurnalabs.com>
References: <1479631547-29354-1-git-send-email-netanel@annapurnalabs.com>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479631547-29354-1-git-send-email-netanel@annapurnalabs.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If for some reason the device stop responding and the device reset failed
to recover the device, the mmio register read datastructure will not be
reinitialized.
On driver removal, the driver will also tries to reset the device
but this time the mmio data structure will be NULL.

To solve this issue perform the device reset in the remove function only if
the device is runnig.

Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index ba395aa..12d1dca 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -2591,6 +2591,8 @@ static void ena_fw_reset_device(struct work_struct *work)
 err:
 	rtnl_unlock();
 
+	clear_bit(ENA_FLAG_DEVICE_RUNNING, &adapter->flags);
+
 	dev_err(&pdev->dev,
 		"Reset attempt failed. Can not reset the device\n");
 }
@@ -3251,7 +3253,9 @@ static void ena_remove(struct pci_dev *pdev)
 
 	cancel_work_sync(&adapter->resume_io_task);
 
-	ena_com_dev_reset(ena_dev);
+	/* Reset the device only if the device is running. */
+	if (test_bit(ENA_FLAG_DEVICE_RUNNING, &adapter->flags))
+		ena_com_dev_reset(ena_dev);
 
 	ena_free_mgmnt_irq(adapter);
 
-- 
1.9.1
