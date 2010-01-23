From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 5/7] ixgbevf: Take action when the PF notifies
	the VF it is resetting.
Date: Sat, 23 Jan 2010 00:47:00 -0800
Message-ID: <20100123084658.9865.8972.stgit@localhost.localdomain>
References: <20100123084457.9865.51853.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:41152 "EHLO
	qmta10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752011Ab0AWIrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 03:47:17 -0500
In-Reply-To: <20100123084457.9865.51853.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

When the VF driver gets a control message from the PF that indicates the
PF is about to reset or go down we schedule the watchdog timer so that
it will detect the PF has gone offline and take appropriate action.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbevf/ixgbevf_main.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index 39544af..bd2fd46 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -956,10 +956,17 @@ static irqreturn_t ixgbevf_msix_mbx(int irq, void *data)
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 eicr;
+	u32 msg;
 
 	eicr = IXGBE_READ_REG(hw, IXGBE_VTEICS);
 	IXGBE_WRITE_REG(hw, IXGBE_VTEICR, eicr);
 
+	hw->mbx.ops.read(hw, &msg, 1);
+
+	if ((msg & IXGBE_MBVFICR_VFREQ_MASK) == IXGBE_PF_CONTROL_MSG)
+		mod_timer(&adapter->watchdog_timer,
+			  round_jiffies(jiffies + 10));
+
 	return IRQ_HANDLED;
 }
 

