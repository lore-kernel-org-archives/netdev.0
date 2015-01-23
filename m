From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] igb: Indicate failure on vf reset for empty mac address
Date: Thu, 22 Jan 2015 18:37:09 -0800
Message-ID: <1421980631-1955-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421980631-1955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Graf <agraf@suse.de>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:16347 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754188AbbAWChX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 21:37:23 -0500
In-Reply-To: <1421980631-1955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Graf <agraf@suse.de>

Commit 5ac6f91d changed the igb driver to expose a zero (empty) mac
address to the VF on reset rather than a random one.

However, that behavioral change also requires igbvf driver changes
which can be hard especially when we want to talk to proprietary
guest OSs.

Looking at the code previous to the commit in Linux that made igbvf
work with empty mac addresses (8d56b6d), we can see that on reset
failure the driver will try to generate a new mac address with both
the old and the new code.

Furthermore, ixgbe does send reset failure when it detects an empty
mac address (35055928c).

So I think it's safe to make igb behave the same. With this patch I
can successfully run a Windows 8.1 guest with an empty mac address
and an assigned igbvf device that has no mac address set by the host.

If anyone is aware of a guest driver that chokes on NACK returns of
VF RESET commands, please speak up.

Signed-off-by: Alexander Graf <agraf@suse.de>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 6e65449..f366b3b 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6077,8 +6077,12 @@ static void igb_vf_reset_msg(struct igb_adapter *adapter, u32 vf)
 	adapter->vf_data[vf].flags |= IGB_VF_FLAG_CTS;
 
 	/* reply to reset with ack and vf mac address */
-	msgbuf[0] = E1000_VF_RESET | E1000_VT_MSGTYPE_ACK;
-	memcpy(addr, vf_mac, ETH_ALEN);
+	if (!is_zero_ether_addr(vf_mac)) {
+		msgbuf[0] = E1000_VF_RESET | E1000_VT_MSGTYPE_ACK;
+		memcpy(addr, vf_mac, ETH_ALEN);
+	} else {
+		msgbuf[0] = E1000_VF_RESET | E1000_VT_MSGTYPE_NACK;
+	}
 	igb_write_mbx(hw, msgbuf, 3, vf);
 }
 
-- 
1.9.3
