From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 9/9] ixgbe: Do not parse past IP header on fragments beyond the first
Date: Sat,  1 Dec 2012 03:53:37 -0800
Message-ID: <1354362817-26168-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1354362817-26168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:27557 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752027Ab2LALx6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2012 06:53:58 -0500
In-Reply-To: <1354362817-26168-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that only the first fragment in a series of fragments
will have the L4 header pulled.  Previously we were always pulling the L4
header as well and in the case of UDP this can harm performance since only the
first fragment will have the header, the rest just contain data which should
be left in the paged portion of the packet.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Tested-by: Marcus Dennis <marcusx.e.dennis@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 484bbed..79b8345 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1338,26 +1338,29 @@ static unsigned int ixgbe_get_headlen(unsigned char *data,
 		if (hlen < sizeof(struct iphdr))
 			return hdr.network - data;
 
-		/* record next protocol */
-		nexthdr = hdr.ipv4->protocol;
-		hdr.network += hlen;
+		/* record next protocol if header is present */
+		if (!hdr.ipv4->frag_off)
+			nexthdr = hdr.ipv4->protocol;
 	} else if (protocol == __constant_htons(ETH_P_IPV6)) {
 		if ((hdr.network - data) > (max_len - sizeof(struct ipv6hdr)))
 			return max_len;
 
 		/* record next protocol */
 		nexthdr = hdr.ipv6->nexthdr;
-		hdr.network += sizeof(struct ipv6hdr);
+		hlen = sizeof(struct ipv6hdr);
 #ifdef IXGBE_FCOE
 	} else if (protocol == __constant_htons(ETH_P_FCOE)) {
 		if ((hdr.network - data) > (max_len - FCOE_HEADER_LEN))
 			return max_len;
-		hdr.network += FCOE_HEADER_LEN;
+		hlen = FCOE_HEADER_LEN;
 #endif
 	} else {
 		return hdr.network - data;
 	}
 
+	/* relocate pointer to start of L4 header */
+	hdr.network += hlen;
+
 	/* finally sort out TCP/UDP */
 	if (nexthdr == IPPROTO_TCP) {
 		if ((hdr.network - data) > (max_len - sizeof(struct tcphdr)))
-- 
1.7.11.7
