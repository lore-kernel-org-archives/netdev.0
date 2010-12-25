From: jeffrey.t.kirsher@intel.com
Subject: [net-next-2.6 15/15] ixgbevf: Add X540 VF device support to the ixgbevf driver
Date: Fri, 24 Dec 2010 22:06:14 -0800
Message-ID: <1293257174-15498-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:28057 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751125Ab0LYGHS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Dec 2010 01:07:18 -0500
To: davem@davemloft.net
In-Reply-To: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The X540 introduces a new Virtual Function device ID so that the X540
VF device can be distinguished from the 82599 VF device.  The X540 VF
device will have additional capability over the 82599 VF device so it
is necessary to be able to discern the difference.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbevf/defines.h      |    1 +
 drivers/net/ixgbevf/ixgbevf.h      |    4 +++-
 drivers/net/ixgbevf/ixgbevf_main.c |    7 +++++--
 drivers/net/ixgbevf/vf.c           |    6 +++++-
 drivers/net/ixgbevf/vf.h           |    1 +
 5 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgbevf/defines.h b/drivers/net/ixgbevf/defines.h
index f8a807d..de643eb 100644
--- a/drivers/net/ixgbevf/defines.h
+++ b/drivers/net/ixgbevf/defines.h
@@ -30,6 +30,7 @@
 
 /* Device IDs */
 #define IXGBE_DEV_ID_82599_VF           0x10ED
+#define IXGBE_DEV_ID_X540_VF            0x1515
 
 #define IXGBE_VF_IRQ_CLEAR_MASK         7
 #define IXGBE_VF_MAX_TX_QUEUES          1
diff --git a/drivers/net/ixgbevf/ixgbevf.h b/drivers/net/ixgbevf/ixgbevf.h
index 0cd6abc..a63efcb 100644
--- a/drivers/net/ixgbevf/ixgbevf.h
+++ b/drivers/net/ixgbevf/ixgbevf.h
@@ -275,9 +275,11 @@ enum ixbgevf_state_t {
 
 enum ixgbevf_boards {
 	board_82599_vf,
+	board_X540_vf,
 };
 
-extern struct ixgbevf_info ixgbevf_vf_info;
+extern struct ixgbevf_info ixgbevf_82599_vf_info;
+extern struct ixgbevf_info ixgbevf_X540_vf_info;
 extern struct ixgbe_mac_operations ixgbevf_mbx_ops;
 
 /* needed by ethtool.c */
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index 809e38c..464e6c9 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -51,13 +51,14 @@ char ixgbevf_driver_name[] = "ixgbevf";
 static const char ixgbevf_driver_string[] =
 	"Intel(R) 82599 Virtual Function";
 
-#define DRV_VERSION "1.0.12-k0"
+#define DRV_VERSION "1.0.19-k0"
 const char ixgbevf_driver_version[] = DRV_VERSION;
 static char ixgbevf_copyright[] =
 	"Copyright (c) 2009 - 2010 Intel Corporation.";
 
 static const struct ixgbevf_info *ixgbevf_info_tbl[] = {
-	[board_82599_vf] = &ixgbevf_vf_info,
+	[board_82599_vf] = &ixgbevf_82599_vf_info,
+	[board_X540_vf]  = &ixgbevf_X540_vf_info,
 };
 
 /* ixgbevf_pci_tbl - PCI Device ID Table
@@ -71,6 +72,8 @@ static const struct ixgbevf_info *ixgbevf_info_tbl[] = {
 static struct pci_device_id ixgbevf_pci_tbl[] = {
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_VF),
 	board_82599_vf},
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X540_VF),
+	board_X540_vf},
 
 	/* required last entry */
 	{0, }
diff --git a/drivers/net/ixgbevf/vf.c b/drivers/net/ixgbevf/vf.c
index 971019d..eecd3bf 100644
--- a/drivers/net/ixgbevf/vf.c
+++ b/drivers/net/ixgbevf/vf.c
@@ -381,8 +381,12 @@ static struct ixgbe_mac_operations ixgbevf_mac_ops = {
 	.set_vfta            = ixgbevf_set_vfta_vf,
 };
 
-struct ixgbevf_info ixgbevf_vf_info = {
+struct ixgbevf_info ixgbevf_82599_vf_info = {
 	.mac = ixgbe_mac_82599_vf,
 	.mac_ops = &ixgbevf_mac_ops,
 };
 
+struct ixgbevf_info ixgbevf_X540_vf_info = {
+	.mac = ixgbe_mac_X540_vf,
+	.mac_ops = &ixgbevf_mac_ops,
+};
diff --git a/drivers/net/ixgbevf/vf.h b/drivers/net/ixgbevf/vf.h
index 144c99d..23eb114 100644
--- a/drivers/net/ixgbevf/vf.h
+++ b/drivers/net/ixgbevf/vf.h
@@ -73,6 +73,7 @@ struct ixgbe_mac_operations {
 enum ixgbe_mac_type {
 	ixgbe_mac_unknown = 0,
 	ixgbe_mac_82599_vf,
+	ixgbe_mac_X540_vf,
 	ixgbe_num_macs
 };
 
-- 
1.7.3.4

