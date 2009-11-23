From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 3/3] ixgbe: Only set/clear VFE in
	ixgbe_set_rx_mode
Date: Mon, 23 Nov 2009 08:32:57 -0800
Message-ID: <20091123163256.19706.37773.stgit@localhost.localdomain>
References: <20091123163145.19706.37720.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.emeryville.ca.mail.comcast.net ([76.96.27.211]:59615
	"EHLO QMTA11.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756028AbZKWQdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 11:33:10 -0500
In-Reply-To: <20091123163145.19706.37720.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

There appears to be a stray setting of the VFE bit when registering vlans.
This should not be done as vlan filtering should be enabled any time the
interface is not in promiscous mode

Signed-off-by:  Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index a3a2a9a..5182b28 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2336,23 +2336,25 @@ static void ixgbe_vlan_rx_register(struct net_device *netdev,
 	 * not in DCB mode.
 	 */
 	ctrl = IXGBE_READ_REG(&adapter->hw, IXGBE_VLNCTRL);
+
+	/* Disable CFI check */
+	ctrl &= ~IXGBE_VLNCTRL_CFIEN;
+
+	/* enable VLAN tag stripping */
 	if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
-		ctrl |= IXGBE_VLNCTRL_VME | IXGBE_VLNCTRL_VFE;
-		ctrl &= ~IXGBE_VLNCTRL_CFIEN;
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_VLNCTRL, ctrl);
+		ctrl |= IXGBE_VLNCTRL_VME;
 	} else if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
-		ctrl |= IXGBE_VLNCTRL_VFE;
-		/* enable VLAN tag insert/strip */
-		ctrl = IXGBE_READ_REG(&adapter->hw, IXGBE_VLNCTRL);
-		ctrl &= ~IXGBE_VLNCTRL_CFIEN;
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_VLNCTRL, ctrl);
 		for (i = 0; i < adapter->num_rx_queues; i++) {
+			u32 ctrl;
 			j = adapter->rx_ring[i].reg_idx;
 			ctrl = IXGBE_READ_REG(&adapter->hw, IXGBE_RXDCTL(j));
 			ctrl |= IXGBE_RXDCTL_VME;
 			IXGBE_WRITE_REG(&adapter->hw, IXGBE_RXDCTL(j), ctrl);
 		}
 	}
+
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_VLNCTRL, ctrl);
+
 	ixgbe_vlan_rx_add_vid(netdev, 0);
 
 	if (!test_bit(__IXGBE_DOWN, &adapter->state))

