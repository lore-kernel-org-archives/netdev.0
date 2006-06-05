From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 1/2] e1000: fix netpoll with NAPI
Date: Mon, 05 Jun 2006 16:11:25 -0700
Message-ID: <20060605231125.12584.17039.stgit@gitlost.site>
References: <20060605230917.12584.55755.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:47878 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1750756AbWFEXGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2006 19:06:00 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060605230917.12584.55755.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Netpoll was broken due to the earlier addition of multiqueue.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index ed15fca..7103a0e 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -4629,10 +4629,17 @@ static void
 e1000_netpoll(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
+#ifdef CONFIG_E1000_NAPI
+	int budget = 0;
+
+	disable_irq(adapter->pdev->irq);
+	e1000_clean_tx_irq(adapter, adapter->tx_ring);
+	adapter->clean_rx(adapter, adapter->rx_ring, &budget, netdev->weight);
+#else
+
 	disable_irq(adapter->pdev->irq);
 	e1000_intr(adapter->pdev->irq, netdev, NULL);
 	e1000_clean_tx_irq(adapter, adapter->tx_ring);
-#ifndef CONFIG_E1000_NAPI
 	adapter->clean_rx(adapter, adapter->rx_ring);
 #endif
 	enable_irq(adapter->pdev->irq);



--
Auke Kok <auke-jan.h.kok@intel.com>
