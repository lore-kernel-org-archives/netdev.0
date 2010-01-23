From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 4/7] ixgbe: Improve reset coordination between
	the PF and the VF
Date: Sat, 23 Jan 2010 00:46:40 -0800
Message-ID: <20100123084639.9865.47156.stgit@localhost.localdomain>
References: <20100123084457.9865.51853.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.emeryville.ca.mail.comcast.net ([76.96.30.96]:49322 "EHLO
	qmta09.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752011Ab0AWIq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 03:46:58 -0500
In-Reply-To: <20100123084457.9865.51853.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Inadequate coordination between the PF driver and the VF driver results
in tx hangs in the VF driver when you perform certain actions that will
lead to a re-init of the PF.  Add feature to notify active VFs when the PF
is about to re-initialize so that the VFs can take appropriate action.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c  |   11 +++++++++++
 drivers/net/ixgbe/ixgbe_sriov.c |   26 ++++++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_sriov.h |    2 ++
 3 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index a986f1d..3d9c075 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3203,6 +3203,17 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	/* signal that we are down to the interrupt handler */
 	set_bit(__IXGBE_DOWN, &adapter->state);
 
+	/* disable receive for all VFs and wait one second */
+	if (adapter->num_vfs) {
+		for (i = 0 ; i < adapter->num_vfs; i++)
+			adapter->vfinfo[i].clear_to_send = 0;
+
+		/* ping all the active vfs to let them know we are going down */
+		ixgbe_ping_all_vfs(adapter);
+		/* Disable all VFTE/VFRE TX/RX */
+		ixgbe_disable_tx_rx(adapter);
+	}
+
 	/* disable receives */
 	rxctrl = IXGBE_READ_REG(hw, IXGBE_RXCTRL);
 	IXGBE_WRITE_REG(hw, IXGBE_RXCTRL, rxctrl & ~IXGBE_RXCTRL_RXEN);
diff --git a/drivers/net/ixgbe/ixgbe_sriov.c b/drivers/net/ixgbe/ixgbe_sriov.c
index 74bca74..d4cd20f 100644
--- a/drivers/net/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ixgbe/ixgbe_sriov.c
@@ -334,3 +334,29 @@ void ixgbe_msg_task(struct ixgbe_adapter *adapter)
 	}
 }
 
+void ixgbe_disable_tx_rx(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+
+	/* disable transmit and receive for all vfs */
+	IXGBE_WRITE_REG(hw, IXGBE_VFTE(0), 0);
+	IXGBE_WRITE_REG(hw, IXGBE_VFTE(1), 0);
+
+	IXGBE_WRITE_REG(hw, IXGBE_VFRE(0), 0);
+	IXGBE_WRITE_REG(hw, IXGBE_VFRE(1), 0);
+}
+
+void ixgbe_ping_all_vfs(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 ping;
+	int i;
+
+	for (i = 0 ; i < adapter->num_vfs; i++) {
+		ping = IXGBE_PF_CONTROL_MSG;
+		if (adapter->vfinfo[i].clear_to_send)
+			ping |= IXGBE_VT_MSGTYPE_CTS;
+		ixgbe_write_mbx(hw, &ping, 1, i);
+	}
+}
+
diff --git a/drivers/net/ixgbe/ixgbe_sriov.h b/drivers/net/ixgbe/ixgbe_sriov.h
index 664b237..51d1106 100644
--- a/drivers/net/ixgbe/ixgbe_sriov.h
+++ b/drivers/net/ixgbe/ixgbe_sriov.h
@@ -39,6 +39,8 @@ void ixgbe_msg_task(struct ixgbe_adapter *adapter);
 int ixgbe_set_vf_mac(struct ixgbe_adapter *adapter,
                      int vf, unsigned char *mac_addr);
 int ixgbe_vf_configuration(struct pci_dev *pdev, unsigned int event_mask);
+void ixgbe_disable_tx_rx(struct ixgbe_adapter *adapter);
+void ixgbe_ping_all_vfs(struct ixgbe_adapter *adapter);
 void ixgbe_dump_registers(struct ixgbe_adapter *adapter);
 
 #endif /* _IXGBE_SRIOV_H_ */

