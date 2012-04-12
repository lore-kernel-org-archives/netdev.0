From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next PATCH v3 7/8] ixgbe: UTA table incorrectly programmed
Date: Thu, 12 Apr 2012 10:07:26 -0700
Message-ID: <20120412170726.2717.84465.stgit@jf-dev1-dcblab>
References: <20120412170258.2717.34628.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gregory.v.rose@intel.com,
	krkumar2@in.ibm.com
To: shemminger@vyatta.com, mst@redhat.com, davem@davemloft.net,
	bhutchings@solarflare.com, sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:1899 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760924Ab2DLRUb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2012 13:20:31 -0400
In-Reply-To: <20120412170258.2717.34628.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The UTA table was being set to the functional equivalent of promiscuous
mode.  This was resulting in traffic from the virtual function being
flooded onto the wire and the PF device. This resulted in additional
overhead for VF traffic sent to the network and in the case of traffic
sent to the PF or another VF resulted in unwanted packets on the wire.

This was actually not the intended behavior. Now that we can program
the embedded switch correctly we can remove this snippit of code. Users
who want to support this should configure the FDB correctly using the
FDB ops.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   29 -------------------------
 1 files changed, 0 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 25a7ed9..10606bd 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2904,33 +2904,6 @@ static void ixgbe_configure_rscctl(struct ixgbe_adapter *adapter,
 	IXGBE_WRITE_REG(hw, IXGBE_RSCCTL(reg_idx), rscctrl);
 }
 
-/**
- *  ixgbe_set_uta - Set unicast filter table address
- *  @adapter: board private structure
- *
- *  The unicast table address is a register array of 32-bit registers.
- *  The table is meant to be used in a way similar to how the MTA is used
- *  however due to certain limitations in the hardware it is necessary to
- *  set all the hash bits to 1 and use the VMOLR ROPE bit as a promiscuous
- *  enable bit to allow vlan tag stripping when promiscuous mode is enabled
- **/
-static void ixgbe_set_uta(struct ixgbe_adapter *adapter)
-{
-	struct ixgbe_hw *hw = &adapter->hw;
-	int i;
-
-	/* The UTA table only exists on 82599 hardware and newer */
-	if (hw->mac.type < ixgbe_mac_82599EB)
-		return;
-
-	/* we only need to do this if VMDq is enabled */
-	if (!(adapter->flags & IXGBE_FLAG_SRIOV_ENABLED))
-		return;
-
-	for (i = 0; i < 128; i++)
-		IXGBE_WRITE_REG(hw, IXGBE_UTA(i), ~0);
-}
-
 #define IXGBE_MAX_RX_DESC_POLL 10
 static void ixgbe_rx_desc_queue_enable(struct ixgbe_adapter *adapter,
 				       struct ixgbe_ring *ring)
@@ -3224,8 +3197,6 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	/* Program registers for the distribution of queues */
 	ixgbe_setup_mrqc(adapter);
 
-	ixgbe_set_uta(adapter);
-
 	/* set_rx_buffer_len must be called before ring initialization */
 	ixgbe_set_rx_buffer_len(adapter);
 
