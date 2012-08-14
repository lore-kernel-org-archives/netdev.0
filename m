From: Steve Hodgson <steve@purestorage.com>
Subject: [PATCH] vmxnet3: Fix race between dev_open() and register_netdev()
Date: Tue, 14 Aug 2012 17:13:36 +0100
Message-ID: <1344960816-12022-1-git-send-email-steve@purestorage.com>
Cc: Steve Hodgson <steve@purestorage.com>
To: "Shreyas Bhatewara" <sbhatewara@vmware.com>, pv-drivers@vmware.com,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog111.obsmtp.com ([74.125.245.90]:43977 "HELO
	na3sys010aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751976Ab2HNQV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 12:21:57 -0400
Received: by wibhm2 with SMTP id hm2so452353wib.10
        for <netdev@vger.kernel.org>; Tue, 14 Aug 2012 09:21:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_open() can complete before register_netdev() returns.
Fix vmxnet3_probe_device() to support this.

Signed-off-by: Steve Hodgson <steve@purestorage.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 93e0cfb..ce9d4f2 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -3019,6 +3019,7 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 	netdev->watchdog_timeo = 5 * HZ;
 
 	INIT_WORK(&adapter->work, vmxnet3_reset_work);
+	set_bit(VMXNET3_STATE_BIT_QUIESCED, &adapter->state);
 
 	if (adapter->intr.type == VMXNET3_IT_MSIX) {
 		int i;
@@ -3043,7 +3044,6 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 		goto err_register;
 	}
 
-	set_bit(VMXNET3_STATE_BIT_QUIESCED, &adapter->state);
 	vmxnet3_check_link(adapter, false);
 	atomic_inc(&devices_found);
 	return 0;
-- 
1.7.9.5
