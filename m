From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: [PATCH 2/2] [e1000 VLAN] Disable vlan hw accel when
	promiscuous mode
Date: Sun, 11 Nov 2007 09:51:20 +0900
Message-ID: <47365200.0f10240a.0686.2173@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net,
	'Dave Johnson' <djohnson+linux-kernel@sw.starentnetworks.com>,
	linux-kernel@vger.kernel.org
To: "'David Miller'" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

IMHO even though netdevice is in the promiscuous mode, we should receive all of ingress packets.
This disable the vlan filtering feature when a vlan hw accel configured e1000 device goes into promiscuous mode.
This make packets visible to sniffers though it's not vlan id of itself.
Any check, comments will be appreciated.
Thanks.

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 drivers/net/e1000/e1000_main.c |   26 ++++++++++++++++++++------
 1 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c index 72deff0..cdd5c84 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2424,7 +2424,7 @@ e1000_set_multi(struct net_device *netdev)
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	struct dev_mc_list *mc_ptr;
-	uint32_t rctl;
+	uint32_t rctl, ctrl;
 	uint32_t hash_value;
 	int i, rar_entries = E1000_RAR_ENTRIES;
 	int mta_reg_count = (hw->mac_type == e1000_ich8lan) ?
@@ -2441,14 +2441,25 @@ e1000_set_multi(struct net_device *netdev)
 	/* Check for Promiscuous and All Multicast modes */
 
 	rctl = E1000_READ_REG(hw, RCTL);
+	ctrl = E1000_READ_REG(&adapter->hw, CTRL);
 
 	if (netdev->flags & IFF_PROMISC) {
 		rctl |= (E1000_RCTL_UPE | E1000_RCTL_MPE);
-	} else if (netdev->flags & IFF_ALLMULTI) {
-		rctl |= E1000_RCTL_MPE;
-		rctl &= ~E1000_RCTL_UPE;
+		if (adapter->hw.mac_type != e1000_ich8lan) {
+			if (ctrl & E1000_CTRL_VME)
+				rctl &= ~E1000_RCTL_VFE;
+		}
 	} else {
-		rctl &= ~(E1000_RCTL_UPE | E1000_RCTL_MPE);
+		if (adapter->hw.mac_type != e1000_ich8lan) {
+			if (ctrl & E1000_CTRL_VME)
+				rctl |= E1000_RCTL_VFE;
+		}
+		if (netdev->flags & IFF_ALLMULTI) {
+			rctl |= E1000_RCTL_MPE;
+			rctl &= ~E1000_RCTL_UPE;
+		} else {
+			rctl &= ~(E1000_RCTL_UPE | E1000_RCTL_MPE);
+		}
 	}
 
 	E1000_WRITE_REG(hw, RCTL, rctl);
@@ -4952,7 +4963,10 @@ e1000_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 		if (adapter->hw.mac_type != e1000_ich8lan) {
 			/* enable VLAN receive filtering */
 			rctl = E1000_READ_REG(&adapter->hw, RCTL);
-			rctl |= E1000_RCTL_VFE;
+			if (netdev->flags & IFF_PROMISC)
+				rctl &= ~E1000_RCTL_VFE;
+			else
+				rctl |= E1000_RCTL_VFE;
 			rctl &= ~E1000_RCTL_CFIEN;
 			E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
 			e1000_update_mng_vlan(adapter);
---


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
