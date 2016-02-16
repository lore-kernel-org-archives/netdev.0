From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/14] igb/igbvf: don't give up
Date: Mon, 15 Feb 2016 19:21:44 -0800
Message-ID: <1455592915-82261-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455592915-82261-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:57142 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753317AbcBPDWC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Feb 2016 22:22:02 -0500
In-Reply-To: <1455592915-82261-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

The driver shouldn't just give up if it fails to get the hardware
mailbox lock. This can happen in a situation where the PF-VF
communication channel is heavily loaded and causes complete
communications failure between the PF and VF drivers.

Add a counter and a delay. The driver will now retry ten times, waiting
one millisecond between retries.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_mbx.c | 18 ++++++++++++------
 drivers/net/ethernet/intel/igbvf/mbx.c     | 20 +++++++++++++-------
 2 files changed, 25 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_mbx.c b/drivers/net/ethernet/intel/igb/e1000_mbx.c
index 162cc49..10f5c9e 100644
--- a/drivers/net/ethernet/intel/igb/e1000_mbx.c
+++ b/drivers/net/ethernet/intel/igb/e1000_mbx.c
@@ -322,14 +322,20 @@ static s32 igb_obtain_mbx_lock_pf(struct e1000_hw *hw, u16 vf_number)
 {
 	s32 ret_val = -E1000_ERR_MBX;
 	u32 p2v_mailbox;
+	int count = 10;
 
-	/* Take ownership of the buffer */
-	wr32(E1000_P2VMAILBOX(vf_number), E1000_P2VMAILBOX_PFU);
+	do {
+		/* Take ownership of the buffer */
+		wr32(E1000_P2VMAILBOX(vf_number), E1000_P2VMAILBOX_PFU);
 
-	/* reserve mailbox for vf use */
-	p2v_mailbox = rd32(E1000_P2VMAILBOX(vf_number));
-	if (p2v_mailbox & E1000_P2VMAILBOX_PFU)
-		ret_val = 0;
+		/* reserve mailbox for vf use */
+		p2v_mailbox = rd32(E1000_P2VMAILBOX(vf_number));
+		if (p2v_mailbox & E1000_P2VMAILBOX_PFU) {
+			ret_val = 0;
+			break;
+		}
+		udelay(1000);
+	} while (count-- > 0);
 
 	return ret_val;
 }
diff --git a/drivers/net/ethernet/intel/igbvf/mbx.c b/drivers/net/ethernet/intel/igbvf/mbx.c
index 7b6cb4c..01752f4 100644
--- a/drivers/net/ethernet/intel/igbvf/mbx.c
+++ b/drivers/net/ethernet/intel/igbvf/mbx.c
@@ -234,13 +234,19 @@ static s32 e1000_check_for_rst_vf(struct e1000_hw *hw)
 static s32 e1000_obtain_mbx_lock_vf(struct e1000_hw *hw)
 {
 	s32 ret_val = -E1000_ERR_MBX;
-
-	/* Take ownership of the buffer */
-	ew32(V2PMAILBOX(0), E1000_V2PMAILBOX_VFU);
-
-	/* reserve mailbox for VF use */
-	if (e1000_read_v2p_mailbox(hw) & E1000_V2PMAILBOX_VFU)
-		ret_val = E1000_SUCCESS;
+	int count = 10;
+
+	do {
+		/* Take ownership of the buffer */
+		ew32(V2PMAILBOX(0), E1000_V2PMAILBOX_VFU);
+
+		/* reserve mailbox for VF use */
+		if (e1000_read_v2p_mailbox(hw) & E1000_V2PMAILBOX_VFU) {
+			ret_val = 0;
+			break;
+		}
+		udelay(1000);
+	} while (count-- > 0);
 
 	return ret_val;
 }
-- 
2.5.0
