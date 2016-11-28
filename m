From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net PATCH 2/2] ixgbe/ixgbevf: Don't use lco_csum to compute IPv4
 checksum
Date: Mon, 28 Nov 2016 10:42:29 -0500
Message-ID: <20161128154228.15466.37196.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161128153927.15466.99193.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, davem@davemloft.net,
        jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:20307 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933486AbcK1VoF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 16:44:05 -0500
In-Reply-To: <20161128153927.15466.99193.stgit@ahduyck-blue-test.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the case of IPIP and SIT tunnel frames the outer transport header
offset is actually set to the same offset as the inner transport header.
This results in the lco_csum call not doing any checksum computation over
the inner IPv4/v6 header data.

In order to account for that I am updating the code so that we determine
the location to start the checksum ourselves based on the location of the
IPv4 header and the length.

Fixes: b83e30104bd9 ("ixgbe/ixgbevf: Add support for GSO partial")
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |    8 ++++++--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    8 ++++++--
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index b4f0374..c72f783 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7284,11 +7284,15 @@ static int ixgbe_tso(struct ixgbe_ring *tx_ring,
 
 	/* initialize outer IP header fields */
 	if (ip.v4->version == 4) {
+		unsigned char *csum_start = skb_checksum_start(skb);
+		unsigned char *trans_start = ip.hdr + (ip.v4->ihl * 4);
+
 		/* IP header will have to cancel out any data that
 		 * is not a part of the outer IP header
 		 */
-		ip.v4->check = csum_fold(csum_add(lco_csum(skb),
-						  csum_unfold(l4.tcp->check)));
+		ip.v4->check = csum_fold(csum_partial(trans_start,
+						      csum_start - trans_start,
+						      0));
 		type_tucmd |= IXGBE_ADVTXD_TUCMD_IPV4;
 
 		ip.v4->tot_len = 0;
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index d9d6616..baa885e 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -3326,11 +3326,15 @@ static int ixgbevf_tso(struct ixgbevf_ring *tx_ring,
 
 	/* initialize outer IP header fields */
 	if (ip.v4->version == 4) {
+		unsigned char *csum_start = skb_checksum_start(skb);
+		unsigned char *trans_start = ip.hdr + (ip.v4->ihl * 4);
+
 		/* IP header will have to cancel out any data that
 		 * is not a part of the outer IP header
 		 */
-		ip.v4->check = csum_fold(csum_add(lco_csum(skb),
-						  csum_unfold(l4.tcp->check)));
+		ip.v4->check = csum_fold(csum_partial(trans_start,
+						      csum_start - trans_start,
+						      0));
 		type_tucmd |= IXGBE_ADVTXD_TUCMD_IPV4;
 
 		ip.v4->tot_len = 0;
