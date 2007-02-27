From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/4] pktgen: use random32
Date: Tue, 27 Feb 2007 12:06:03 -0800
Message-ID: <20070227120603.5a23f0a7@freekitty>
References: <20070227120447.55a7e39d@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Robert Olsson <Robert.Olsson@data.slu.se>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:52668 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752637AbXB0VTo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Feb 2007 16:19:44 -0500
In-Reply-To: <20070227120447.55a7e39d@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Can use random32() now.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 net/core/pktgen.c |   52 +++++++++++++++++++---------------------------------
 1 file changed, 19 insertions(+), 33 deletions(-)

--- pktgen.orig/net/core/pktgen.c	2007-02-26 14:34:36.000000000 -0800
+++ pktgen/net/core/pktgen.c	2007-02-26 14:39:53.000000000 -0800
@@ -464,17 +464,6 @@
 	return tmp;
 }
 
-static inline u32 pktgen_random(void)
-{
-#if 0
-	__u32 n;
-	get_random_bytes(&n, 4);
-	return n;
-#else
-	return net_random();
-#endif
-}
-
 static inline __u64 getCurMs(void)
 {
 	struct timeval tv;
@@ -2091,7 +2080,7 @@
 	int flow = 0;
 
 	if (pkt_dev->cflows) {
-		flow = pktgen_random() % pkt_dev->cflows;
+		flow = random32() % pkt_dev->cflows;
 
 		if (pkt_dev->flows[flow].count > pkt_dev->lflow)
 			pkt_dev->flows[flow].count = 0;
@@ -2103,7 +2092,7 @@
 		__u32 tmp;
 
 		if (pkt_dev->flags & F_MACSRC_RND)
-			mc = pktgen_random() % (pkt_dev->src_mac_count);
+			mc = random32() % pkt_dev->src_mac_count;
 		else {
 			mc = pkt_dev->cur_src_mac_offset++;
 			if (pkt_dev->cur_src_mac_offset >
@@ -2129,7 +2118,7 @@
 		__u32 tmp;
 
 		if (pkt_dev->flags & F_MACDST_RND)
-			mc = pktgen_random() % (pkt_dev->dst_mac_count);
+			mc = random32() % pkt_dev->dst_mac_count;
 
 		else {
 			mc = pkt_dev->cur_dst_mac_offset++;
@@ -2156,24 +2145,23 @@
 		for(i = 0; i < pkt_dev->nr_labels; i++)
 			if (pkt_dev->labels[i] & MPLS_STACK_BOTTOM)
 				pkt_dev->labels[i] = MPLS_STACK_BOTTOM |
-					     ((__force __be32)pktgen_random() &
+					     ((__force __be32)random32() &
 						      htonl(0x000fffff));
 	}
 
 	if ((pkt_dev->flags & F_VID_RND) && (pkt_dev->vlan_id != 0xffff)) {
-		pkt_dev->vlan_id = pktgen_random() % 4096;
+		pkt_dev->vlan_id = random32() & (4096-1);
 	}
 
 	if ((pkt_dev->flags & F_SVID_RND) && (pkt_dev->svlan_id != 0xffff)) {
-		pkt_dev->svlan_id = pktgen_random() % 4096;
+		pkt_dev->svlan_id = random32() & (4096 - 1);
 	}
 
 	if (pkt_dev->udp_src_min < pkt_dev->udp_src_max) {
 		if (pkt_dev->flags & F_UDPSRC_RND)
-			pkt_dev->cur_udp_src =
-			    ((pktgen_random() %
-			      (pkt_dev->udp_src_max - pkt_dev->udp_src_min)) +
-			     pkt_dev->udp_src_min);
+			pkt_dev->cur_udp_src = random32() %
+				(pkt_dev->udp_src_max - pkt_dev->udp_src_min)
+				+ pkt_dev->udp_src_min;
 
 		else {
 			pkt_dev->cur_udp_src++;
@@ -2184,10 +2172,9 @@
 
 	if (pkt_dev->udp_dst_min < pkt_dev->udp_dst_max) {
 		if (pkt_dev->flags & F_UDPDST_RND) {
-			pkt_dev->cur_udp_dst =
-			    ((pktgen_random() %
-			      (pkt_dev->udp_dst_max - pkt_dev->udp_dst_min)) +
-			     pkt_dev->udp_dst_min);
+			pkt_dev->cur_udp_dst = random32() %
+				(pkt_dev->udp_dst_max - pkt_dev->udp_dst_min)
+				+ pkt_dev->udp_dst_min;
 		} else {
 			pkt_dev->cur_udp_dst++;
 			if (pkt_dev->cur_udp_dst >= pkt_dev->udp_dst_max)
@@ -2202,7 +2189,7 @@
 							       saddr_max))) {
 			__u32 t;
 			if (pkt_dev->flags & F_IPSRC_RND)
-				t = ((pktgen_random() % (imx - imn)) + imn);
+				t = random32() % (imx - imn) + imn;
 			else {
 				t = ntohl(pkt_dev->cur_saddr);
 				t++;
@@ -2223,14 +2210,13 @@
 				__be32 s;
 				if (pkt_dev->flags & F_IPDST_RND) {
 
-					t = pktgen_random() % (imx - imn) + imn;
+					t = random32() % (imx - imn) + imn;
 					s = htonl(t);
 
 					while (LOOPBACK(s) || MULTICAST(s)
 					       || BADCLASS(s) || ZERONET(s)
 					       || LOCAL_MCAST(s)) {
-						t = (pktgen_random() %
-						      (imx - imn)) + imn;
+						t = random32() % (imx - imn) + imn;
 						s = htonl(t);
 					}
 					pkt_dev->cur_daddr = s;
@@ -2262,7 +2248,7 @@
 
 			for (i = 0; i < 4; i++) {
 				pkt_dev->cur_in6_daddr.s6_addr32[i] =
-				    (((__force __be32)pktgen_random() |
+				    (((__force __be32)random32() |
 				      pkt_dev->min_in6_daddr.s6_addr32[i]) &
 				     pkt_dev->max_in6_daddr.s6_addr32[i]);
 			}
@@ -2272,9 +2258,9 @@
 	if (pkt_dev->min_pkt_size < pkt_dev->max_pkt_size) {
 		__u32 t;
 		if (pkt_dev->flags & F_TXSIZE_RND) {
-			t = ((pktgen_random() %
-			      (pkt_dev->max_pkt_size - pkt_dev->min_pkt_size))
-			     + pkt_dev->min_pkt_size);
+			t = random32() %
+				(pkt_dev->max_pkt_size - pkt_dev->min_pkt_size)
+				+ pkt_dev->min_pkt_size;
 		} else {
 			t = pkt_dev->cur_pkt_size + 1;
 			if (t > pkt_dev->max_pkt_size)
