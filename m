From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/12] igbvf: after mailbox write, wait for reply
Date: Wed,  9 Aug 2017 14:47:44 -0700
Message-ID: <20170809214746.28139-11-jeffrey.t.kirsher@intel.com>
References: <20170809214746.28139-1-jeffrey.t.kirsher@intel.com>
Cc: Greg Edwards <gedwards@ddn.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:32910 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752366AbdHIVr5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Aug 2017 17:47:57 -0400
In-Reply-To: <20170809214746.28139-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Edwards <gedwards@ddn.com>

Two of the VF mailbox commands were not waiting for a reply from the PF,
which can result in a VF mailbox timeout in the VM for the next command.

Signed-off-by: Greg Edwards <gedwards@ddn.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igbvf/vf.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igbvf/vf.c b/drivers/net/ethernet/intel/igbvf/vf.c
index 528be116184e..1d3aa9adcaa8 100644
--- a/drivers/net/ethernet/intel/igbvf/vf.c
+++ b/drivers/net/ethernet/intel/igbvf/vf.c
@@ -230,6 +230,7 @@ static void e1000_update_mc_addr_list_vf(struct e1000_hw *hw,
 	u16 *hash_list = (u16 *)&msgbuf[1];
 	u32 hash_value;
 	u32 cnt, i;
+	s32 ret_val;
 
 	/* Each entry in the list uses 1 16 bit word.  We have 30
 	 * 16 bit words available in our HW msg buffer (minus 1 for the
@@ -250,7 +251,9 @@ static void e1000_update_mc_addr_list_vf(struct e1000_hw *hw,
 		mc_addr_list += ETH_ALEN;
 	}
 
-	mbx->ops.write_posted(hw, msgbuf, E1000_VFMAILBOX_SIZE);
+	ret_val = mbx->ops.write_posted(hw, msgbuf, E1000_VFMAILBOX_SIZE);
+	if (!ret_val)
+		mbx->ops.read_posted(hw, msgbuf, 1);
 }
 
 /**
@@ -293,11 +296,14 @@ void e1000_rlpml_set_vf(struct e1000_hw *hw, u16 max_size)
 {
 	struct e1000_mbx_info *mbx = &hw->mbx;
 	u32 msgbuf[2];
+	s32 ret_val;
 
 	msgbuf[0] = E1000_VF_SET_LPE;
 	msgbuf[1] = max_size;
 
-	mbx->ops.write_posted(hw, msgbuf, 2);
+	ret_val = mbx->ops.write_posted(hw, msgbuf, 2);
+	if (!ret_val)
+		mbx->ops.read_posted(hw, msgbuf, 1);
 }
 
 /**
-- 
2.13.3
