From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 02/14] tg3: Drop non-VLAN rx pkts larger than the MTU
Date: Wed, 25 Feb 2009 16:21:52 -0800
Message-ID: <1235616368.15998@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3710 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753716AbZBZCqZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 21:46:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The hardware's MTU is configured so that it will accept packets whose
VLAN tag is left inline.  This means that the hardware will also accept
other packets larger than the desired MTU size.  This patch checks for
and discards packets that are larger than the requested MTU but are not
VLAN tagged frames.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index c7bbbb1..774a01a 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4339,6 +4339,13 @@ static int tg3_rx(struct tg3 *tp, int budget)
 			skb->ip_summed = CHECKSUM_NONE;
 
 		skb->protocol = eth_type_trans(skb, tp->dev);
+
+		if (len > (tp->dev->mtu + ETH_HLEN) &&
+		    skb->protocol != htons(ETH_P_8021Q)) {
+			dev_kfree_skb(skb);
+			goto next_pkt;
+		}
+
 #if TG3_VLAN_TAG_USED
 		if (tp->vlgrp != NULL &&
 		    desc->type_flags & RXD_FLAG_VLAN) {
@@ -6824,7 +6831,8 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	__tg3_set_mac_addr(tp, 0);
 
 	/* MTU + ethernet header + FCS + optional VLAN tag */
-	tw32(MAC_RX_MTU_SIZE, tp->dev->mtu + ETH_HLEN + 8);
+	tw32(MAC_RX_MTU_SIZE,
+	     tp->dev->mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN);
 
 	/* The slot time is changed by tg3_setup_phy if we
 	 * run at gigabit with half duplex.
-- 
1.6.0.6


