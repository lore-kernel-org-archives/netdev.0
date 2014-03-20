From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] ixgbe: clean up ixgbe_atr_compute_perfect_hash_82599
Date: Thu, 20 Mar 2014 01:33:03 -0700
Message-ID: <1395304385-6874-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395304385-6874-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Arun Sharma <asharma@fb.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8075 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755935AbaCTId4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Mar 2014 04:33:56 -0400
In-Reply-To: <1395304385-6874-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Rather than assign several parameters in a row, we should use a for
loop, which reduces code size.

CC: Arun Sharma <asharma@fb.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c | 46 +++++---------------------
 1 file changed, 9 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index bdac7bd..34ab2fc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -1597,35 +1597,20 @@ void ixgbe_atr_compute_perfect_hash_82599(union ixgbe_atr_input *input,
 {
 
 	u32 hi_hash_dword, lo_hash_dword, flow_vm_vlan;
-	u32 bucket_hash = 0;
+	u32 bucket_hash = 0, hi_dword = 0;
+	int i;
 
 	/* Apply masks to input data */
-	input->dword_stream[0]  &= input_mask->dword_stream[0];
-	input->dword_stream[1]  &= input_mask->dword_stream[1];
-	input->dword_stream[2]  &= input_mask->dword_stream[2];
-	input->dword_stream[3]  &= input_mask->dword_stream[3];
-	input->dword_stream[4]  &= input_mask->dword_stream[4];
-	input->dword_stream[5]  &= input_mask->dword_stream[5];
-	input->dword_stream[6]  &= input_mask->dword_stream[6];
-	input->dword_stream[7]  &= input_mask->dword_stream[7];
-	input->dword_stream[8]  &= input_mask->dword_stream[8];
-	input->dword_stream[9]  &= input_mask->dword_stream[9];
-	input->dword_stream[10] &= input_mask->dword_stream[10];
+	for (i = 0; i <= 10; i++)
+		input->dword_stream[i] &= input_mask->dword_stream[i];
 
 	/* record the flow_vm_vlan bits as they are a key part to the hash */
 	flow_vm_vlan = ntohl(input->dword_stream[0]);
 
 	/* generate common hash dword */
-	hi_hash_dword = ntohl(input->dword_stream[1] ^
-				    input->dword_stream[2] ^
-				    input->dword_stream[3] ^
-				    input->dword_stream[4] ^
-				    input->dword_stream[5] ^
-				    input->dword_stream[6] ^
-				    input->dword_stream[7] ^
-				    input->dword_stream[8] ^
-				    input->dword_stream[9] ^
-				    input->dword_stream[10]);
+	for (i = 1; i <= 10; i++)
+		hi_dword ^= input->dword_stream[i];
+	hi_hash_dword = ntohl(hi_dword);
 
 	/* low dword is word swapped version of common */
 	lo_hash_dword = (hi_hash_dword >> 16) | (hi_hash_dword << 16);
@@ -1644,21 +1629,8 @@ void ixgbe_atr_compute_perfect_hash_82599(union ixgbe_atr_input *input,
 	lo_hash_dword ^= flow_vm_vlan ^ (flow_vm_vlan << 16);
 
 	/* Process remaining 30 bit of the key */
-	IXGBE_COMPUTE_BKT_HASH_ITERATION(1);
-	IXGBE_COMPUTE_BKT_HASH_ITERATION(2);
-	IXGBE_COMPUTE_BKT_HASH_ITERATION(3);
-	IXGBE_COMPUTE_BKT_HASH_ITERATION(4);
-	IXGBE_COMPUTE_BKT_HASH_ITERATION(5);
-	IXGBE_COMPUTE_BKT_HASH_ITERATION(6);
-	IXGBE_COMPUTE_BKT_HASH_ITERATION(7);
-	IXGBE_COMPUTE_BKT_HASH_ITERATION(8);
-	IXGBE_COMPUTE_BKT_HASH_ITERATION(9);
-	IXGBE_COMPUTE_BKT_HASH_ITERATION(10);
-	IXGBE_COMPUTE_BKT_HASH_ITERATION(11);
-	IXGBE_COMPUTE_BKT_HASH_ITERATION(12);
-	IXGBE_COMPUTE_BKT_HASH_ITERATION(13);
-	IXGBE_COMPUTE_BKT_HASH_ITERATION(14);
-	IXGBE_COMPUTE_BKT_HASH_ITERATION(15);
+	for (i = 1; i <= 15; i++)
+		IXGBE_COMPUTE_BKT_HASH_ITERATION(i);
 
 	/*
 	 * Limit hash to 13 bits since max bucket count is 8K.
-- 
1.8.3.1
