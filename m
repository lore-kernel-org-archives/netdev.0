From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 3/4] e1000e: fix close interrupt race
Date: Thu, 26 Mar 2009 01:05:41 -0700
Message-ID: <20090326080541.30401.83097.stgit@lost.foo-projects.org>
References: <20090326080503.30401.71355.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:38128 "EHLO
	QMTA07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755710AbZCZIGC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 04:06:02 -0400
In-Reply-To: <20090326080503.30401.71355.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

As noticed by Alan Cox, it is possible for e1000e to exit its interrupt
handler or NAPI with interrupts enabled even when the driver is unloading or
being configured administratively down.

fix related to fix for: http://bugzilla.kernel.org/show_bug.cgi?id=12876

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Alan Cox <alan@lxorguk.ukuu.org.uk>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 1797412..b4ae046 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1261,7 +1261,8 @@ static irqreturn_t e1000_msix_other(int irq, void *data)
 	u32 icr = er32(ICR);
 
 	if (!(icr & E1000_ICR_INT_ASSERTED)) {
-		ew32(IMS, E1000_IMS_OTHER);
+		if (!test_bit(__E1000_DOWN, &adapter->state))
+			ew32(IMS, E1000_IMS_OTHER);
 		return IRQ_NONE;
 	}
 
@@ -1278,7 +1279,8 @@ static irqreturn_t e1000_msix_other(int irq, void *data)
 	}
 
 no_link_interrupt:
-	ew32(IMS, E1000_IMS_LSC | E1000_IMS_OTHER);
+	if (!test_bit(__E1000_DOWN, &adapter->state))
+		ew32(IMS, E1000_IMS_LSC | E1000_IMS_OTHER);
 
 	return IRQ_HANDLED;
 }
@@ -2015,10 +2017,12 @@ clean_rx:
 		if (adapter->itr_setting & 3)
 			e1000_set_itr(adapter);
 		napi_complete(napi);
-		if (adapter->msix_entries)
-			ew32(IMS, adapter->rx_ring->ims_val);
-		else
-			e1000_irq_enable(adapter);
+		if (!test_bit(__E1000_DOWN, &adapter->state)) {
+			if (adapter->msix_entries)
+				ew32(IMS, adapter->rx_ring->ims_val);
+			else
+				e1000_irq_enable(adapter);
+		}
 	}
 
 	return work_done;

