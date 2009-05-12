From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [STABLE 2.6.28.y PATCH] e1000: fix virtualization bug
Date: Tue, 12 May 2009 10:47:29 -0700
Message-ID: <20090512174728.20525.60800.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: stable@kernel.org, netdev@vger.kernel.org
To: chrisw@sous-sol.org, greg@kroah.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:39208
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751710AbZELRrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 13:47:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

[STABLE] backport upstream commit e151a60ad1faffb6241cf7eb6846353df1f33a32

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
Signed-off-by: "David S. Miller" <davem@davemloft.net>
---

 drivers/net/e1000/e1000_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index b727fef..44f0843 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3732,7 +3732,7 @@ static irqreturn_t e1000_intr(int irq, void *data)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 rctl, icr = er32(ICR);
 
-	if (unlikely((!icr) || test_bit(__E1000_RESETTING, &adapter->flags)))
+	if (unlikely((!icr) || test_bit(__E1000_DOWN, &adapter->flags)))
 		return IRQ_NONE;  /* Not our interrupt */
 
 	/* IMS will not auto-mask if INT_ASSERTED is not set, and if it is

