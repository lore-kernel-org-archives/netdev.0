From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 3/3] ixgbevf: Cache PF ack bit in interrupt
Date: Wed, 05 May 2010 22:57:49 -0700
Message-ID: <20100506055748.8482.25239.stgit@localhost.localdomain>
References: <20100506055703.8482.16515.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:60302 "EHLO
	qmta07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752303Ab0EFF6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 01:58:08 -0400
In-Reply-To: <20100506055703.8482.16515.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

When the PF acks a message from the VF the VF gets an interrupt.  It
must cache the ack bit so that polling SW will not miss the ack.  Also
avoid reading the message buffer on acks because that also will clear
the ack bit.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbevf/ixgbevf_main.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index 0870740..460c37f 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -961,12 +961,28 @@ static irqreturn_t ixgbevf_msix_mbx(int irq, void *data)
 	eicr = IXGBE_READ_REG(hw, IXGBE_VTEICS);
 	IXGBE_WRITE_REG(hw, IXGBE_VTEICR, eicr);
 
+	if (!hw->mbx.ops.check_for_ack(hw)) {
+		/*
+		 * checking for the ack clears the PFACK bit.  Place
+		 * it back in the v2p_mailbox cache so that anyone
+		 * polling for an ack will not miss it.  Also
+		 * avoid the read below because the code to read
+		 * the mailbox will also clear the ack bit.  This was
+		 * causing lost acks.  Just cache the bit and exit
+		 * the IRQ handler.
+		 */
+		hw->mbx.v2p_mailbox |= IXGBE_VFMAILBOX_PFACK;
+		goto out;
+	}
+
+	/* Not an ack interrupt, go ahead and read the message */
 	hw->mbx.ops.read(hw, &msg, 1);
 
 	if ((msg & IXGBE_MBVFICR_VFREQ_MASK) == IXGBE_PF_CONTROL_MSG)
 		mod_timer(&adapter->watchdog_timer,
 			  round_jiffies(jiffies + 1));
 
+out:
 	return IRQ_HANDLED;
 }
 

