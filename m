From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 3/5] e1000e: perform 10/100 adaptive IFS only on parts
	that support it
Date: Thu, 07 Jan 2010 18:31:35 -0800
Message-ID: <20100108023134.31476.40191.stgit@localhost.localdomain>
References: <20100108023033.31476.4034.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:35366
	"EHLO QMTA08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752933Ab0AHCbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 21:31:53 -0500
In-Reply-To: <20100108023033.31476.4034.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Adaptive IFS which involves writing to the Adaptive IFS Throttle register
was being done for all devices supported by the driver even though it is
not supported (i.e. the register doesn't even exist) on some devices.  The
feature is supported on 8257x/82583 and ICH/PCH based devices, but not
on ESB2.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/82571.c   |    2 ++
 drivers/net/e1000e/es2lan.c  |    2 ++
 drivers/net/e1000e/hw.h      |    1 +
 drivers/net/e1000e/ich8lan.c |    2 ++
 drivers/net/e1000e/lib.c     |   14 ++++++++++++++
 5 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index b979464..02d67d0 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -237,6 +237,8 @@ static s32 e1000_init_mac_params_82571(struct e1000_adapter *adapter)
 	/* Set if manageability features are enabled. */
 	mac->arc_subsystem_valid = (er32(FWSM) & E1000_FWSM_MODE_MASK)
 	                ? true : false;
+	/* Adaptive IFS supported */
+	mac->adaptive_ifs = true;
 
 	/* check for link */
 	switch (hw->phy.media_type) {
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index 3028f23..e2aa3b7 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -224,6 +224,8 @@ static s32 e1000_init_mac_params_80003es2lan(struct e1000_adapter *adapter)
 	/* Set if manageability features are enabled. */
 	mac->arc_subsystem_valid = (er32(FWSM) & E1000_FWSM_MODE_MASK)
                         ? true : false;
+	/* Adaptive IFS not supported */
+	mac->adaptive_ifs = false;
 
 	/* check for link */
 	switch (hw->phy.media_type) {
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index 2784cf4..eccf29b 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -818,6 +818,7 @@ struct e1000_mac_info {
 
 	u8  forced_speed_duplex;
 
+	bool adaptive_ifs;
 	bool arc_subsystem_valid;
 	bool autoneg;
 	bool autoneg_failed;
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 9b09246..ad08cf3 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -454,6 +454,8 @@ static s32 e1000_init_mac_params_ich8lan(struct e1000_adapter *adapter)
 		mac->rar_entry_count--;
 	/* Set if manageability features are enabled. */
 	mac->arc_subsystem_valid = true;
+	/* Adaptive IFS supported */
+	mac->adaptive_ifs = true;
 
 	/* LED operations */
 	switch (mac->type) {
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index a86c175..56b59e4 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -1609,6 +1609,11 @@ void e1000e_reset_adaptive(struct e1000_hw *hw)
 {
 	struct e1000_mac_info *mac = &hw->mac;
 
+	if (!mac->adaptive_ifs) {
+		e_dbg("Not in Adaptive IFS mode!\n");
+		goto out;
+	}
+
 	mac->current_ifs_val = 0;
 	mac->ifs_min_val = IFS_MIN;
 	mac->ifs_max_val = IFS_MAX;
@@ -1617,6 +1622,8 @@ void e1000e_reset_adaptive(struct e1000_hw *hw)
 
 	mac->in_ifs_mode = false;
 	ew32(AIT, 0);
+out:
+	return;
 }
 
 /**
@@ -1630,6 +1637,11 @@ void e1000e_update_adaptive(struct e1000_hw *hw)
 {
 	struct e1000_mac_info *mac = &hw->mac;
 
+	if (!mac->adaptive_ifs) {
+		e_dbg("Not in Adaptive IFS mode!\n");
+		goto out;
+	}
+
 	if ((mac->collision_delta * mac->ifs_ratio) > mac->tx_packet_delta) {
 		if (mac->tx_packet_delta > MIN_NUM_XMITS) {
 			mac->in_ifs_mode = true;
@@ -1650,6 +1662,8 @@ void e1000e_update_adaptive(struct e1000_hw *hw)
 			ew32(AIT, 0);
 		}
 	}
+out:
+	return;
 }
 
 /**

