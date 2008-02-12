From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] ixgbe: Correctly obtain protocol information on transmit
Date: Tue, 12 Feb 2008 15:20:33 -0800
Message-ID: <20080212232033.13861.17859.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	e1000-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:12754 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752124AbYBLXWd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Feb 2008 18:22:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In reply to "RE: [Fwd: [PATCH 2.6.25] ixgbe/igb: correctly obtain protocol
information on transmit]" from Andy Gospodarek:

The driver was incorrectly looking at socket headers for
protocol information, needed for checksumming offload. Fix
this by not looking at the socket but frame headers instead.

This disregards extension headers but it's unclear that linux
generates those anyway.

Tested by Andy Gospodarek.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   24 +++++++++++++++++++++---
 1 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 540b647..23d0a4a 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2277,11 +2277,29 @@ static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
 				    IXGBE_ADVTXD_DTYP_CTXT);
 
 		if (skb->ip_summed == CHECKSUM_PARTIAL) {
-			if (skb->protocol == htons(ETH_P_IP))
+			switch (skb->protocol) {
+			case __constant_htons(ETH_P_IP):
 				type_tucmd_mlhl |= IXGBE_ADVTXD_TUCMD_IPV4;
+				if (ip_hdr(skb)->protocol == IPPROTO_TCP)
+					type_tucmd_mlhl |=
+						IXGBE_ADVTXD_TUCMD_L4T_TCP;
+				break;
+
+			case __constant_htons(ETH_P_IPV6):
+				/* XXX what about other V6 headers?? */
+				if (ipv6_hdr(skb)->nexthdr == IPPROTO_TCP)
+					type_tucmd_mlhl |=
+						IXGBE_ADVTXD_TUCMD_L4T_TCP;
+				break;
 
-			if (skb->sk->sk_protocol == IPPROTO_TCP)
-				type_tucmd_mlhl |= IXGBE_ADVTXD_TUCMD_L4T_TCP;
+			default:
+				if (unlikely(net_ratelimit())) {
+					DPRINTK(PROBE, WARNING,
+					 "partial checksum but proto=%x!\n",
+					 skb->protocol);
+				}
+				break;
+			}
 		}
 
 		context_desc->type_tucmd_mlhl = cpu_to_le32(type_tucmd_mlhl);

