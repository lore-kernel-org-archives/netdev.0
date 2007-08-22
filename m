From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][VIA-RHINE]: Fix CONFIG_VIA_RHINE_NAPI usage
Date: Wed, 22 Aug 2007 14:58:55 -0700 (PDT)
Message-ID: <20070822.145855.32177470.davem@davemloft.net>
References: <20070822214659.GC23220@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36073
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S934417AbXHVV67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 17:58:59 -0400
In-Reply-To: <20070822214659.GC23220@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 22 Aug 2007 18:46:59 -0300

> Hi David,
> 
> 	napi is broken here, with this patch at least I can isolate this
> breakage and boot the machine with a non-napi via-rhine driver.
> 
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Thanks for finding this problem.

The core issue seems to be that via-rhine.c tries to perform
a napi_enable() when there has not been a previous napi_disable().

So lets make sure that all paths that lead to an init_registers()
call makes a preceeding napi_disable().

Please give this patch a try:

diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index 8f4cf82..0e6aefe 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -1167,6 +1167,7 @@ static int rhine_open(struct net_device *dev)
 		free_irq(rp->pdev->irq, dev);
 		return rc;
 	}
+	napi_disable(&rp->napi);
 	alloc_rbufs(dev);
 	alloc_tbufs(dev);
 	rhine_chip_reset(dev);
@@ -1195,6 +1196,8 @@ static void rhine_tx_timeout(struct net_device *dev)
 	/* protect against concurrent rx interrupts */
 	disable_irq(rp->pdev->irq);
 
+	napi_disable(&rp->napi);
+
 	spin_lock(&rp->lock);
 
 	/* clear all descriptors */
@@ -1935,6 +1938,7 @@ static int rhine_suspend(struct pci_dev *pdev, pm_message_t state)
 	if (!netif_running(dev))
 		return 0;
 
+	napi_disable(&rp->napi);
 	netif_device_detach(dev);
 	pci_save_state(pdev);
 
