From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 14/20] igb: delay VF reset notification until
	after interrupts are enabed
Date: Tue, 27 Oct 2009 18:53:45 -0700
Message-ID: <20091028015344.12470.76498.stgit@localhost.localdomain>
References: <20091028014858.12470.99520.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.westchester.pa.mail.comcast.net ([76.96.62.16]:44460
	"EHLO QMTA01.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756821AbZJ1B51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 21:57:27 -0400
In-Reply-To: <20091028014858.12470.99520.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This update delays the VF reset notification until after interrupts are
enabled.  Otherwise there is a chance of having the VF try to reset itself too
soon and being ignored by the PF as a result.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   33 +++++++++++++++++++++++----------
 1 files changed, 23 insertions(+), 10 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index ea05604..24a119e 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1165,6 +1165,13 @@ int igb_up(struct igb_adapter *adapter)
 	rd32(E1000_ICR);
 	igb_irq_enable(adapter);
 
+	/* notify VFs that reset has been completed */
+	if (adapter->vfs_allocated_count) {
+		u32 reg_data = rd32(E1000_CTRL_EXT);
+		reg_data |= E1000_CTRL_EXT_PFRSTD;
+		wr32(E1000_CTRL_EXT, reg_data);
+	}
+
 	netif_tx_start_all_queues(adapter->netdev);
 
 	/* Fire a link change interrupt to start the watchdog. */
@@ -1948,6 +1955,13 @@ static int igb_open(struct net_device *netdev)
 
 	igb_irq_enable(adapter);
 
+	/* notify VFs that reset has been completed */
+	if (adapter->vfs_allocated_count) {
+		u32 reg_data = rd32(E1000_CTRL_EXT);
+		reg_data |= E1000_CTRL_EXT_PFRSTD;
+		wr32(E1000_CTRL_EXT, reg_data);
+	}
+
 	netif_tx_start_all_queues(netdev);
 
 	/* Fire a link status change interrupt to start the watchdog. */
@@ -5785,19 +5799,18 @@ static int igb_set_vf_mac(struct igb_adapter *adapter,
 static void igb_vmm_control(struct igb_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
-	u32 reg_data;
 
-	if (!adapter->vfs_allocated_count)
+	/* replication is not supported for 82575 */
+	if (hw->mac.type == e1000_82575)
 		return;
 
-	/* VF's need PF reset indication before they
-	 * can send/receive mail */
-	reg_data = rd32(E1000_CTRL_EXT);
-	reg_data |= E1000_CTRL_EXT_PFRSTD;
-	wr32(E1000_CTRL_EXT, reg_data);
-
-	igb_vmdq_set_loopback_pf(hw, true);
-	igb_vmdq_set_replication_pf(hw, true);
+	if (adapter->vfs_allocated_count) {
+		igb_vmdq_set_loopback_pf(hw, true);
+		igb_vmdq_set_replication_pf(hw, true);
+	} else {
+		igb_vmdq_set_loopback_pf(hw, false);
+		igb_vmdq_set_replication_pf(hw, false);
+	}
 }
 
 /* igb_main.c */

