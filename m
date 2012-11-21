From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/10] igb: Do not parse past IP header on fragments beyond the first
Date: Wed, 21 Nov 2012 02:47:36 -0800
Message-ID: <1353494856-12344-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1353494856-12344-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:43225 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754518Ab2KUKrr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2012 05:47:47 -0500
In-Reply-To: <1353494856-12344-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that only the first fragment in a series of fragments
will have the L4 header pulled.  Previously we were always pulling the L4
header as well and in the case of UDP this can harm performance since only the
first fragment will have the header, the rest just contain data which should
be left in the paged portion of the packet.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 0fe2521..0ce145e 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6145,20 +6145,23 @@ static unsigned int igb_get_headlen(unsigned char *data,
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
 	} else {
 		return hdr.network - data;
 	}
 
+	/* relocate pointer to start of L4 header */
+	hdr.network += hlen;
+
 	/* finally sort out TCP */
 	if (nexthdr == IPPROTO_TCP) {
 		if ((hdr.network - data) > (max_len - sizeof(struct tcphdr)))
-- 
1.7.11.7
