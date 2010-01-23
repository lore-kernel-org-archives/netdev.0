From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 3/7] ixgbe: Allow the VF driver to be loaded
	before the PF driver
Date: Sat, 23 Jan 2010 00:46:22 -0800
Message-ID: <20100123084620.9865.56449.stgit@localhost.localdomain>
References: <20100123084457.9865.51853.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta15.emeryville.ca.mail.comcast.net ([76.96.27.228]:60469
	"EHLO qmta15.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754319Ab0AWIqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 03:46:39 -0500
In-Reply-To: <20100123084457.9865.51853.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The PF Reset Done bit should not be set in the extended control register
until the PF has actually completed the bring up process.  It is a mis-
interpretation of the purpose of this bit to assume it should be set
when the physical reset of the device is done.  Instead it should be used
to indicate to the VFs when the PF is ready to provide them with required
services.  This is not until after the PF is finished coming up and ready
to process mailbox events.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82599.c |    6 +-----
 drivers/net/ixgbe/ixgbe_main.c  |    7 +++++++
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 9ec296c..591c7b9 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -890,7 +890,7 @@ static s32 ixgbe_setup_copper_link_82599(struct ixgbe_hw *hw,
 static s32 ixgbe_reset_hw_82599(struct ixgbe_hw *hw)
 {
 	s32 status = 0;
-	u32 ctrl, ctrl_ext;
+	u32 ctrl;
 	u32 i;
 	u32 autoc;
 	u32 autoc2;
@@ -945,10 +945,6 @@ static s32 ixgbe_reset_hw_82599(struct ixgbe_hw *hw)
 		status = IXGBE_ERR_RESET_FAILED;
 		hw_dbg(hw, "Reset polling failed to complete.\n");
 	}
-	/* Clear PF Reset Done bit so PF/VF Mail Ops can work */
-	ctrl_ext = IXGBE_READ_REG(hw, IXGBE_CTRL_EXT);
-	ctrl_ext |= IXGBE_CTRL_EXT_PFRSTD;
-	IXGBE_WRITE_REG(hw, IXGBE_CTRL_EXT, ctrl_ext);
 
 	msleep(50);
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 2091658..a986f1d 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2826,6 +2826,7 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 	u32 txdctl, rxdctl, mhadd;
 	u32 dmatxctl;
 	u32 gpie;
+	u32 ctrl_ext;
 
 	ixgbe_get_hw_control(adapter);
 
@@ -3015,6 +3016,12 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 	adapter->flags |= IXGBE_FLAG_NEED_LINK_UPDATE;
 	adapter->link_check_timeout = jiffies;
 	mod_timer(&adapter->watchdog_timer, jiffies);
+
+	/* Set PF Reset Done bit so PF/VF Mail Ops can work */
+	ctrl_ext = IXGBE_READ_REG(hw, IXGBE_CTRL_EXT);
+	ctrl_ext |= IXGBE_CTRL_EXT_PFRSTD;
+	IXGBE_WRITE_REG(hw, IXGBE_CTRL_EXT, ctrl_ext);
+
 	return 0;
 }
 

