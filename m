From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/13] ixgbe: Add support for IPv6 and UDP to ixgbe_get_headlen
Date: Fri, 19 Oct 2012 23:25:55 -0700
Message-ID: <1350714367-24208-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1350714367-24208-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:18923 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752909Ab2JTG0h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Oct 2012 02:26:37 -0400
In-Reply-To: <1350714367-24208-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change adds support for IPv6 and UDP to ixgbe_get_headlen. The
advantage to this is that we can now handle ipv4/UDP, ipv6/TCP, and
ipv6/UDP with a single memcpy instead of having to do them in multiple
pskb_may_pull calls.

A quick bit of testing shows that we increase throughput for a single
session of netperf from 8800Mpbs to about 9300Mpbs in the case of ipv6/TCP.
As such overall ipv6 performance should improve with this change.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko  <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index e2a6691..3ef74f8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1244,6 +1244,7 @@ static unsigned int ixgbe_get_headlen(unsigned char *data,
 		struct vlan_hdr *vlan;
 		/* l3 headers */
 		struct iphdr *ipv4;
+		struct ipv6hdr *ipv6;
 	} hdr;
 	__be16 protocol;
 	u8 nexthdr = 0;	/* default to not TCP */
@@ -1284,6 +1285,13 @@ static unsigned int ixgbe_get_headlen(unsigned char *data,
 		/* record next protocol */
 		nexthdr = hdr.ipv4->protocol;
 		hdr.network += hlen;
+	} else if (protocol == __constant_htons(ETH_P_IPV6)) {
+		if ((hdr.network - data) > (max_len - sizeof(struct ipv6hdr)))
+			return max_len;
+
+		/* record next protocol */
+		nexthdr = hdr.ipv6->nexthdr;
+		hdr.network += sizeof(struct ipv6hdr);
 #ifdef IXGBE_FCOE
 	} else if (protocol == __constant_htons(ETH_P_FCOE)) {
 		if ((hdr.network - data) > (max_len - FCOE_HEADER_LEN))
@@ -1294,7 +1302,7 @@ static unsigned int ixgbe_get_headlen(unsigned char *data,
 		return hdr.network - data;
 	}
 
-	/* finally sort out TCP */
+	/* finally sort out TCP/UDP */
 	if (nexthdr == IPPROTO_TCP) {
 		if ((hdr.network - data) > (max_len - sizeof(struct tcphdr)))
 			return max_len;
@@ -1307,6 +1315,11 @@ static unsigned int ixgbe_get_headlen(unsigned char *data,
 			return hdr.network - data;
 
 		hdr.network += hlen;
+	} else if (nexthdr == IPPROTO_UDP) {
+		if ((hdr.network - data) > (max_len - sizeof(struct udphdr)))
+			return max_len;
+
+		hdr.network += sizeof(struct udphdr);
 	}
 
 	/*
-- 
1.7.11.7
