From: akpm@linux-foundation.org
Subject: [patch 17/21] cxgb3: remove duplicate tests in lro
Date: Mon, 22 Sep 2008 14:52:26 -0700
Message-ID: <200809222152.m8MLqQX5031987@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, divy@chelsio.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34547 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753068AbYIVV5K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 17:57:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

The generic lro code checks TCP flags/options.  Remove duplicate tests
done in the driver.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/cxgb3/sge.c |   35 -----------------------------------
 1 file changed, 35 deletions(-)

diff -puN drivers/net/cxgb3/sge.c~cxgb3-remove-duplicate-tests-in-lro drivers/net/cxgb3/sge.c
--- a/drivers/net/cxgb3/sge.c~cxgb3-remove-duplicate-tests-in-lro
+++ a/drivers/net/cxgb3/sge.c
@@ -1937,38 +1937,6 @@ static inline int lro_frame_ok(const str
 		eh->h_proto == htons(ETH_P_IP) && ih->ihl == (sizeof(*ih) >> 2);
 }
 
-#define TCP_FLAG_MASK (TCP_FLAG_CWR | TCP_FLAG_ECE | TCP_FLAG_URG |\
-                       TCP_FLAG_ACK | TCP_FLAG_PSH | TCP_FLAG_RST |\
-		                       TCP_FLAG_SYN | TCP_FLAG_FIN)
-#define TSTAMP_WORD ((TCPOPT_NOP << 24) | (TCPOPT_NOP << 16) |\
-                     (TCPOPT_TIMESTAMP << 8) | TCPOLEN_TIMESTAMP)
-
-/**
- *	lro_segment_ok - check if a TCP segment is eligible for LRO
- *	@tcph: the TCP header of the packet
- *
- *	Returns true if a TCP packet is eligible for LRO.  This requires that
- *	the packet have only the ACK flag set and no TCP options besides
- *	time stamps.
- */
-static inline int lro_segment_ok(const struct tcphdr *tcph)
-{
-	int optlen;
-
-	if (unlikely((tcp_flag_word(tcph) & TCP_FLAG_MASK) != TCP_FLAG_ACK))
-		return 0;
-
-	optlen = (tcph->doff << 2) - sizeof(*tcph);
-	if (optlen) {
-		const u32 *opt = (const u32 *)(tcph + 1);
-
-		if (optlen != TCPOLEN_TSTAMP_ALIGNED ||
-		    *opt != htonl(TSTAMP_WORD) || !opt[2])
-			return 0;
-	}
-	return 1;
-}
-
 static int t3_get_lro_header(void **eh,  void **iph, void **tcph,
 			     u64 *hdr_flags, void *priv)
 {
@@ -1981,9 +1949,6 @@ static int t3_get_lro_header(void **eh, 
 	*iph = (struct iphdr *)((struct ethhdr *)*eh + 1);
 	*tcph = (struct tcphdr *)((struct iphdr *)*iph + 1);
 
-	 if (!lro_segment_ok(*tcph))
-		return -1;
-
 	*hdr_flags = LRO_IPV4 | LRO_TCP;
 	return 0;
 }
_
