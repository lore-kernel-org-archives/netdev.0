From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] e1000: fix bug with shared interrupt during reset
Date: Tue, 27 Jan 2009 15:27:16 -0800
Message-ID: <20090127232714.24458.66863.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.westchester.pa.mail.comcast.net ([76.96.62.48]:59469
	"EHLO QMTA05.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751020AbZA0X1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 18:27:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

A nasty bug was found where an MTU change (or anything else that caused a
reset) could race with the interrupt code.  The interrupt code was entered
by a shared interrupt during the MTU change.

This change prevents the interrupt code from running while the driver is in
the middle of its reset path.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
---

 drivers/net/e1000/e1000_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 26474c9..c986978 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -31,7 +31,7 @@
 
 char e1000_driver_name[] = "e1000";
 static char e1000_driver_string[] = "Intel(R) PRO/1000 Network Driver";
-#define DRV_VERSION "7.3.20-k3-NAPI"
+#define DRV_VERSION "7.3.21-k3-NAPI"
 const char e1000_driver_version[] = DRV_VERSION;
 static const char e1000_copyright[] = "Copyright (c) 1999-2006 Intel Corporation.";
 
@@ -3712,7 +3712,7 @@ static irqreturn_t e1000_intr(int irq, void *data)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 rctl, icr = er32(ICR);
 
-	if (unlikely(!icr))
+	if (unlikely((!icr) || test_bit(__E1000_RESETTING, &adapter->flags)))
 		return IRQ_NONE;  /* Not our interrupt */
 
 	/* IMS will not auto-mask if INT_ASSERTED is not set, and if it is

