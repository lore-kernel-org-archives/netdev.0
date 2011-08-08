From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net] vmxnet3: Don't enable vlan filters in promiscuous mode.
Date: Mon,  8 Aug 2011 02:15:47 -0700
Message-ID: <1312794947-3163-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, "Scott J. Goldman" <scottjg@vmware.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	VMware PV-Drivers <pv-drivers@vmware.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:56095 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751490Ab1HHJP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 05:15:59 -0400
Received: by pzk37 with SMTP id 37so7995891pzk.1
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2011 02:15:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The vmxnet3 driver enables vlan filters if filtering is enabled for
any vlan.  In promiscuous mode the filter table is cleared to in
order to disable filtering.  However, if a vlan device is subsequently
created that vlan will be added to the filter, re-engaging it.  As a
result, not only do we not see all the vlans in promiscuous mode, we
don't even see vlans for which a filter was previously created.

CC: Scott J. Goldman <scottjg@vmware.com>
CC: Shreyas Bhatewara <sbhatewara@vmware.com>
CC: VMware PV-Drivers <pv-drivers@vmware.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c |   34 ++++++++++++++++++++--------------
 1 files changed, 20 insertions(+), 14 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 1cbacb3..0959583 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1929,14 +1929,17 @@ static void
 vmxnet3_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 {
 	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
-	u32 *vfTable = adapter->shared->devRead.rxFilterConf.vfTable;
-	unsigned long flags;
 
-	VMXNET3_SET_VFTABLE_ENTRY(vfTable, vid);
-	spin_lock_irqsave(&adapter->cmd_lock, flags);
-	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
-			       VMXNET3_CMD_UPDATE_VLAN_FILTERS);
-	spin_unlock_irqrestore(&adapter->cmd_lock, flags);
+	if (!(netdev->flags & IFF_PROMISC)) {
+		u32 *vfTable = adapter->shared->devRead.rxFilterConf.vfTable;
+		unsigned long flags;
+
+		VMXNET3_SET_VFTABLE_ENTRY(vfTable, vid);
+		spin_lock_irqsave(&adapter->cmd_lock, flags);
+		VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
+				       VMXNET3_CMD_UPDATE_VLAN_FILTERS);
+		spin_unlock_irqrestore(&adapter->cmd_lock, flags);
+	}
 
 	set_bit(vid, adapter->active_vlans);
 }
@@ -1946,14 +1949,17 @@ static void
 vmxnet3_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 {
 	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
-	u32 *vfTable = adapter->shared->devRead.rxFilterConf.vfTable;
-	unsigned long flags;
 
-	VMXNET3_CLEAR_VFTABLE_ENTRY(vfTable, vid);
-	spin_lock_irqsave(&adapter->cmd_lock, flags);
-	VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
-			       VMXNET3_CMD_UPDATE_VLAN_FILTERS);
-	spin_unlock_irqrestore(&adapter->cmd_lock, flags);
+	if (!(netdev->flags & IFF_PROMISC)) {
+		u32 *vfTable = adapter->shared->devRead.rxFilterConf.vfTable;
+		unsigned long flags;
+
+		VMXNET3_CLEAR_VFTABLE_ENTRY(vfTable, vid);
+		spin_lock_irqsave(&adapter->cmd_lock, flags);
+		VMXNET3_WRITE_BAR1_REG(adapter, VMXNET3_REG_CMD,
+				       VMXNET3_CMD_UPDATE_VLAN_FILTERS);
+		spin_unlock_irqrestore(&adapter->cmd_lock, flags);
+	}
 
 	clear_bit(vid, adapter->active_vlans);
 }
-- 
1.7.4.1

