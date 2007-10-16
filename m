From: Karsten Wiese <fzu@wemgehoertderstaat.de>
Subject: [PATCH] Disable polling in rtl8169_suspend() to prevent race with rtl8169_interrupt()
Date: Tue, 16 Oct 2007 18:46:52 +0200
Message-ID: <200710161846.52509.fzu@wemgehoertderstaat.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: romieu@fr.zoreil.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout1.freenet.de ([195.4.92.91]:57333 "EHLO mout1.freenet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752872AbXJPQq4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 12:46:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Sometimes (~ 1 in 10) after suspend to disk my r8169 nic doesn't work and a
"r8169: eth0: link down" gets mingled up with those suspend messages.
First tests show nothing bad, so maybe this patch really helps.
Will post again, if it doesn't.

      Karsten
------------------>

Disable polling in rtl8169_suspend() to prevent race with rtl8169_interrupt()

rtl8169_interrupt() is called during polling.
Without patch, rtl8169_interrupt() could run after rtl8169_asic_down(),
causing a disabled link state being saved later in rtl8169_suspend() by
pci_save_state().
netif_stop_queue() can go as it is called by netif_device_detach().

Signed-off-by: Karsten Wiese <fzu@wemgehoertderstaat.de>
---
 drivers/net/r8169.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index c76dd29..fee6c8e 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3024,7 +3024,7 @@ static int rtl8169_suspend(struct pci_dev *pdev, pm_message_t state)
 		goto out_pci_suspend;
 
 	netif_device_detach(dev);
-	netif_stop_queue(dev);
+	netif_poll_disable(dev);
 
 	spin_lock_irq(&tp->lock);
 
@@ -3054,6 +3054,7 @@ static int rtl8169_resume(struct pci_dev *pdev)
 	if (!netif_running(dev))
 		goto out;
 
+	netif_poll_enable(dev);
 	netif_device_attach(dev);
 
 	rtl8169_schedule_work(dev, rtl8169_reset_task);
-- 
1.5.2.4

