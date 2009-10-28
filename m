From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 15/20] igb: setup vlan tag replication stripping
	in igb_vmm_control
Date: Tue, 27 Oct 2009 18:54:04 -0700
Message-ID: <20091028015403.12470.83156.stgit@localhost.localdomain>
References: <20091028014858.12470.99520.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.westchester.pa.mail.comcast.net ([76.96.59.212]:50215
	"EHLO QMTA14.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756993AbZJ1B5q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 21:57:46 -0400
In-Reply-To: <20091028014858.12470.99520.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This update adds vlan tag stripping for inter-vf communications to the
igb_vmm_control configuration function.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.h |    9 +++++++++
 drivers/net/igb/igb_main.c    |   11 +++++++++++
 2 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.h b/drivers/net/igb/e1000_82575.h
index 7be3a0b..9418683 100644
--- a/drivers/net/igb/e1000_82575.h
+++ b/drivers/net/igb/e1000_82575.h
@@ -203,6 +203,15 @@ struct e1000_adv_tx_context_desc {
 #define E1000_IOVCTL 0x05BBC
 #define E1000_IOVCTL_REUSE_VFQ 0x00000001
 
+#define E1000_RPLOLR_STRVLAN   0x40000000
+#define E1000_RPLOLR_STRCRC    0x80000000
+
+#define E1000_DTXCTL_8023LL     0x0004
+#define E1000_DTXCTL_VLAN_ADDED 0x0008
+#define E1000_DTXCTL_OOS_ENABLE 0x0010
+#define E1000_DTXCTL_MDP_EN     0x0020
+#define E1000_DTXCTL_SPOOF_INT  0x0040
+
 #define ALL_QUEUES   0xFFFF
 
 void igb_vmdq_set_loopback_pf(struct e1000_hw *, bool);
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 24a119e..9dd290c 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -5799,11 +5799,22 @@ static int igb_set_vf_mac(struct igb_adapter *adapter,
 static void igb_vmm_control(struct igb_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
+	u32 reg;
 
 	/* replication is not supported for 82575 */
 	if (hw->mac.type == e1000_82575)
 		return;
 
+	/* enable replication vlan tag stripping */
+	reg = rd32(E1000_RPLOLR);
+	reg |= E1000_RPLOLR_STRVLAN;
+	wr32(E1000_RPLOLR, reg);
+
+	/* notify HW that the MAC is adding vlan tags */
+	reg = rd32(E1000_DTXCTL);
+	reg |= E1000_DTXCTL_VLAN_ADDED;
+	wr32(E1000_DTXCTL, reg);
+
 	if (adapter->vfs_allocated_count) {
 		igb_vmdq_set_loopback_pf(hw, true);
 		igb_vmdq_set_replication_pf(hw, true);

