From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 3/3] e1000: fix close race with interrupt
Date: Thu, 26 Mar 2009 00:59:22 -0700
Message-ID: <20090326075922.30121.40411.stgit@lost.foo-projects.org>
References: <20090326075844.30121.48999.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:47501
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755038AbZCZH7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 03:59:44 -0400
In-Reply-To: <20090326075844.30121.48999.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

this is in regards to
http://bugzilla.kernel.org/show_bug.cgi?id=12876

where it appears that e1000 can leave its interrupt enabled after
exiting the driver.  Fix the bug by making the interrupt enable
paths more aware of the driver exiting.

Thanks to Alan Cox for the poke and initial investigation.

CC: Alan Cox <alan@lxorguk.ukuu.org.uk>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_main.c |   28 ++++++++++++++++++++++++----
 1 files changed, 24 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 5c61b92..93b861d 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -577,12 +577,30 @@ out:
 
 void e1000_down(struct e1000_adapter *adapter)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
+	u32 rctl, tctl;
 
 	/* signal that we're down so the interrupt handler does not
 	 * reschedule our watchdog timer */
 	set_bit(__E1000_DOWN, &adapter->flags);
 
+	/* disable receives in the hardware */
+	rctl = er32(RCTL);
+	ew32(RCTL, rctl & ~E1000_RCTL_EN);
+	/* flush and sleep below */
+
+	/* can be netif_tx_disable when NETIF_F_LLTX is removed */
+	netif_stop_queue(netdev);
+
+	/* disable transmits in the hardware */
+	tctl = er32(TCTL);
+	tctl &= ~E1000_TCTL_EN;
+	ew32(TCTL, tctl);
+	/* flush both disables and wait for them to finish */
+	E1000_WRITE_FLUSH();
+	msleep(10);
+
 	napi_disable(&adapter->napi);
 
 	e1000_irq_disable(adapter);
@@ -595,7 +613,6 @@ void e1000_down(struct e1000_adapter *adapter)
 	adapter->link_speed = 0;
 	adapter->link_duplex = 0;
 	netif_carrier_off(netdev);
-	netif_stop_queue(netdev);
 
 	e1000_reset(adapter);
 	e1000_clean_all_tx_rings(adapter);
@@ -3744,10 +3761,12 @@ static irqreturn_t e1000_intr(int irq, void *data)
 		adapter->total_rx_bytes = 0;
 		adapter->total_rx_packets = 0;
 		__napi_schedule(&adapter->napi);
-	} else
+	} else {
 		/* this really should not happen! if it does it is basically a
 		 * bug, but not a hard error, so enable ints and continue */
-		e1000_irq_enable(adapter);
+		if (!test_bit(__E1000_DOWN, &adapter->flags))
+			e1000_irq_enable(adapter);
+	}
 
 	return IRQ_HANDLED;
 }
@@ -3777,7 +3796,8 @@ static int e1000_clean(struct napi_struct *napi, int budget)
 		if (likely(adapter->itr_setting & 3))
 			e1000_set_itr(adapter);
 		napi_complete(napi);
-		e1000_irq_enable(adapter);
+		if (!test_bit(__E1000_DOWN, &adapter->flags))
+			e1000_irq_enable(adapter);
 	}
 
 	return work_done;

