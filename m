From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net PATCH v3 1/1] drivers: net : cpsw: pass proper device name while requesting irq
Date: Wed, 18 Dec 2013 21:33:50 +0530
Message-ID: <1387382630-3683-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-omap@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:38944 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754517Ab3LRQD4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 11:03:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During checking the interrupts with "cat /proc/interrupts", it is showing
device name as (null), this change was done with commit id aa1a15e2d where
request_irq is changed to devm_request_irq also changing the irq name from
platform device name to net device name, but the net device is not
registered at this point with the network frame work, so devm_request_irq
is called with device name as NULL, by which it is showed as "(null)" in
"cat /proc/interrupts". So this patch changes back irq name to platform
device name itself in devm_request_irq so that the device name shows as
below.

Previous to this patch
root@am335x-evm:~# cat /proc/interrupts
           CPU0
 28:       2265      INTC  12  edma
 30:         80      INTC  14  edma_error
 56:          0      INTC  40  (null)
 57:       1794      INTC  41  (null)
 58:          7      INTC  42  (null)
 59:          0      INTC  43  (null)

With this patch
root@am335x-evm:~# cat /proc/interrupts
           CPU0
 28:        213      INTC  12  edma
 30:          9      INTC  14  edma_error
 56:          0      INTC  40  4a100000.ethernet
 57:      16097      INTC  41  4a100000.ethernet
 58:      11964      INTC  42  4a100000.ethernet
 59:          0      INTC  43  4a100000.ethernet

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
Changes from Initial version
* Changed the commit message to hold more details of the commit changes

Changes from v2
* Instead of moving request irq below net dev register, changing the
  request irq name from net device to platform device as previous to
  convertion to devm* is done.
---
 drivers/net/ethernet/ti/cpsw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 614f284..5330fd2 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2108,7 +2108,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	while ((res = platform_get_resource(priv->pdev, IORESOURCE_IRQ, k))) {
 		for (i = res->start; i <= res->end; i++) {
 			if (devm_request_irq(&pdev->dev, i, cpsw_interrupt, 0,
-					     dev_name(priv->dev), priv)) {
+					     dev_name(&pdev->dev), priv)) {
 				dev_err(priv->dev, "error attaching irq\n");
 				goto clean_ale_ret;
 			}
-- 
1.8.5.2.192.g7794a68
