From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/3] igb: cleanup usage of virtualization
	registers
Date: Mon, 22 Mar 2010 17:07:46 -0700
Message-ID: <20100323000744.19939.65933.stgit@localhost.localdomain>
References: <20100323000724.19939.17642.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.westchester.pa.mail.comcast.net ([76.96.59.227]:43475
	"EHLO qmta12.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753850Ab0CWAIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 20:08:05 -0400
In-Reply-To: <20100323000724.19939.17642.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The igb driver was incorrectly attempting to write to registers that do not
exist on 82580 hardware.  This wasn't causing any issues that I can tell,
but it is not recommended behavior either so I have changed this so we are
determining which registers to write to based on mac type.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   28 ++++++++++++++++------------
 1 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 83431e9..61029e8 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -6158,19 +6158,23 @@ static void igb_vmm_control(struct igb_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 reg;
 
-	/* replication is not supported for 82575 */
-	if (hw->mac.type == e1000_82575)
+	switch (hw->mac.type) {
+	case e1000_82575:
+	default:
+		/* replication is not supported for 82575 */
 		return;
-
-	/* enable replication vlan tag stripping */
-	reg = rd32(E1000_RPLOLR);
-	reg |= E1000_RPLOLR_STRVLAN;
-	wr32(E1000_RPLOLR, reg);
-
-	/* notify HW that the MAC is adding vlan tags */
-	reg = rd32(E1000_DTXCTL);
-	reg |= E1000_DTXCTL_VLAN_ADDED;
-	wr32(E1000_DTXCTL, reg);
+	case e1000_82576:
+		/* notify HW that the MAC is adding vlan tags */
+		reg = rd32(E1000_DTXCTL);
+		reg |= E1000_DTXCTL_VLAN_ADDED;
+		wr32(E1000_DTXCTL, reg);
+	case e1000_82580:
+		/* enable replication vlan tag stripping */
+		reg = rd32(E1000_RPLOLR);
+		reg |= E1000_RPLOLR_STRVLAN;
+		wr32(E1000_RPLOLR, reg);
+		break;
+	}
 
 	if (adapter->vfs_allocated_count) {
 		igb_vmdq_set_loopback_pf(hw, true);

