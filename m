From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH 4/4] e1000: remove e1000_clean_tx_irq call from e1000_netpoll
Date: Thu, 19 Jun 2008 17:19:12 -0400
Message-ID: <20080619211912.GF22981@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36296 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753901AbYFSVTO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jun 2008 17:19:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The call to e1000_clean_tx_irq in e1000_netpoll can race with the call
to e1000_clean_tx_irq in e1000_clean.  With a small bit of tweaking to
to netpoll_send_skb to simulate a system that was under extreme stress,
I was able to reproduce these concurrent calls.  This can result in
multiple frees to the skbs on the tx ring buffer.

Dropping this call from e1000_netpoll should be fine since we can rely
on the calls in e1000_clean to do what is needed since napi will poll
the hardware just after calling poll_controller.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
---
 drivers/net/e1000/e1000_main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 0dc1ef0..047028f 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -5277,7 +5277,6 @@ e1000_netpoll(struct net_device *netdev)
 
 	disable_irq(adapter->pdev->irq);
 	e1000_intr(adapter->pdev->irq, netdev);
-	e1000_clean_tx_irq(adapter, adapter->tx_ring);
 #ifndef CONFIG_E1000_NAPI
 	adapter->clean_rx(adapter, adapter->rx_ring);
 #endif
-- 
1.5.2.1

