From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 9/9] ixgbe: Fix bugs in ixgbe_clear_vf_vlans()
Date: Thu, 24 Dec 2015 21:29:56 -0800
Message-ID: <1451021396-68858-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1451021396-68858-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:40717 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753758AbbLYFaA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Dec 2015 00:30:00 -0500
In-Reply-To: <1451021396-68858-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

When I had rewritten the code for ixgbe_clear_vf_vlans() it looks like I
had transitioned back and forth between using word as an offset and using
word as a register offset.  As a result I honestly don't see how the code
was working before other than the fact that resetting the VLANs on the VF
like didn't do much to clear them.

Another issue found is that the mask was using a divide instead of a
modulus.  As a result the mask bit was incorrectly being set to either bit
0 or 1 based on the value of the VF being tested.  As a result the wrong
VFs were having their VLANs cleared if they were enabled.

I have updated the code so that word represents the offset in the array.
This way we can use the modulus and xor operations and they will make sense
instead of being performed on a 4 byte aligned value.

I replaced the statement "(word % 2) ^ 1" with "~word % 2" in order to
reduce the line length as the line exceeded 80 characters with the register
name inserted.  The two should be equivalent so the change should be safe.

Reported-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index fd918da..c817103 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -593,11 +593,11 @@ static void ixgbe_clear_vf_vlans(struct ixgbe_adapter *adapter, u32 vf)
 
 	/* post increment loop, covers VLVF_ENTRIES - 1 to 0 */
 	for (i = IXGBE_VLVF_ENTRIES; i--;) {
-		u32 word = IXGBE_VLVFB(i * 2 + vf / 32);
 		u32 bits[2], vlvfb, vid, vfta, vlvf;
-		u32 mask = 1 << (vf / 32);
+		u32 word = i * 2 + vf / 32;
+		u32 mask = 1 << (vf % 32);
 
-		vlvfb = IXGBE_READ_REG(hw, word);
+		vlvfb = IXGBE_READ_REG(hw, IXGBE_VLVFB(word));
 
 		/* if our bit isn't set we can skip it */
 		if (!(vlvfb & mask))
@@ -608,7 +608,7 @@ static void ixgbe_clear_vf_vlans(struct ixgbe_adapter *adapter, u32 vf)
 
 		/* create 64b mask to chedk to see if we should clear VLVF */
 		bits[word % 2] = vlvfb;
-		bits[(word % 2) ^ 1] = IXGBE_READ_REG(hw, word ^ 1);
+		bits[~word % 2] = IXGBE_READ_REG(hw, IXGBE_VLVFB(word ^ 1));
 
 		/* if promisc is enabled, PF will be present, leave VFTA */
 		if (adapter->flags2 & IXGBE_FLAG2_VLAN_PROMISC) {
-- 
2.5.0
