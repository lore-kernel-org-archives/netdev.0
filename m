From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net PATCH 1/2] igb/igbvf: Don't use lco_csum to compute IPv4
 checksum
Date: Mon, 28 Nov 2016 10:42:23 -0500
Message-ID: <20161128154223.15466.69052.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161128153927.15466.99193.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, davem@davemloft.net,
        jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:8287 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755587AbcK1Vn7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 16:43:59 -0500
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

Fixes: e10715d3e961 ("igb/igbvf: Add support for GSO partial")
Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |    8 ++++++--
 drivers/net/ethernet/intel/igbvf/netdev.c |    8 ++++++--
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 59125b1..76ce0cc 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -4922,11 +4922,15 @@ static int igb_tso(struct igb_ring *tx_ring,
 
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
 		type_tucmd |= E1000_ADVTXD_TUCMD_IPV4;
 
 		ip.v4->tot_len = 0;
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index b0778ba..e3a80ac 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -1965,11 +1965,15 @@ static int igbvf_tso(struct igbvf_ring *tx_ring,
 
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
 		type_tucmd |= E1000_ADVTXD_TUCMD_IPV4;
 
 		ip.v4->tot_len = 0;
