From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] e1000: fix virtualization bug
Date: Mon, 04 May 2009 14:19:42 -0700
Message-ID: <20090504211941.10922.95964.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.westchester.pa.mail.comcast.net ([76.96.62.16]:44737
	"EHLO QMTA01.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756661AbZEDVUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 17:20:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

a recent fix to e1000 (commit 15b2bee2) caused KVM/QEMU/VMware based
virtualized e1000 interfaces to begin failing when resetting.

This is because the driver in a virtual environment doesn't
get to run instructions *AT ALL* when an interrupt is asserted.
The interrupt code runs immediately and this recent bug fix
allows an interrupt to be possible when the interrupt handler
will reject it (due to the new code), when being called from
any path in the driver that holds the E1000_RESETTING flag.

the driver should use the __E1000_DOWN flag instead of the
__E1000_RESETTING flag to prevent interrupt execution
while reconfiguring the hardware.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 6a46cee..b1419e2 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3738,7 +3738,7 @@ static irqreturn_t e1000_intr(int irq, void *data)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 rctl, icr = er32(ICR);
 
-	if (unlikely((!icr) || test_bit(__E1000_RESETTING, &adapter->flags)))
+	if (unlikely((!icr) || test_bit(__E1000_DOWN, &adapter->flags)))
 		return IRQ_NONE;  /* Not our interrupt */
 
 	/* IMS will not auto-mask if INT_ASSERTED is not set, and if it is

