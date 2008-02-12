From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH 2.6.25] ixgbe/igb: correctly obtain protocol information on transmit
Date: Mon, 11 Feb 2008 20:35:40 -0500
Message-ID: <20080212013540.GD856@gospo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Auke Kok <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:33310 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755325AbYBLBfo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2008 20:35:44 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I noticed a strange panic on a box with an ixgbe-based interface when
using bridging.  Protocol information ought to come from the frame
itself rather than anywhere else.

The igb driver has a similar coding error that would cause incorrect
flags to be set, so it would not panic.  It should still get fixed
though.

Checking the frame's payload on both drivers seems like a better
option.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
---

 igb/igb_main.c     |    3 ++-
 ixgbe/ixgbe_main.c |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index f3c144d..5572923 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2514,9 +2514,10 @@ static inline bool igb_tx_csum_adv(struct igb_adapter *adapter,
 		tu_cmd |= (E1000_TXD_CMD_DEXT | E1000_ADVTXD_DTYP_CTXT);
 
 		if (skb->ip_summed == CHECKSUM_PARTIAL) {
+			struct iphdr *iph = ip_hdr(skb);
 			if (skb->protocol == htons(ETH_P_IP))
 				tu_cmd |= E1000_ADVTXD_TUCMD_IPV4;
-			if (skb->sk && (skb->sk->sk_protocol == IPPROTO_TCP))
+			if (iph->protocol == IPPROTO_TCP)
 				tu_cmd |= E1000_ADVTXD_TUCMD_L4T_TCP;
 		}
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 3732dd6..4542870 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2202,10 +2202,11 @@ static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
 				    IXGBE_ADVTXD_DTYP_CTXT);
 
 		if (skb->ip_summed == CHECKSUM_PARTIAL) {
+			struct iphdr *iph = ip_hdr(skb);
 			if (skb->protocol == htons(ETH_P_IP))
 				type_tucmd_mlhl |= IXGBE_ADVTXD_TUCMD_IPV4;
 
-			if (skb->sk->sk_protocol == IPPROTO_TCP)
+			if (iph->protocol == IPPROTO_TCP)
 				type_tucmd_mlhl |= IXGBE_ADVTXD_TUCMD_L4T_TCP;
 		}
 
