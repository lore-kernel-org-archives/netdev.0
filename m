From: Fan Du <fan.du@windriver.com>
Subject: [PATCH net-next 2/3] xfrm: clamp down spi range for IPComp when allocating spi
Date: Thu, 28 Nov 2013 10:52:40 +0800
Message-ID: <1385607161-27597-3-git-send-email-fan.du@windriver.com>
References: <1385607161-27597-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:46960 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758650Ab3K1Cwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Nov 2013 21:52:50 -0500
In-Reply-To: <1385607161-27597-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

otherwise xfrm state can not be found properly by peers.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/xfrm/xfrm_state.c |   13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 68c2f35..a6716d7 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1506,6 +1506,19 @@ int xfrm_alloc_spi(struct xfrm_state *x, u32 low, u32 high)
 	__be32 maxspi = htonl(high);
 	u32 mark = x->mark.v & x->mark.m;
 
+	/* Compression Parameter Index(CPI) is 16bits wide
+	 * An 32 bits spi value will hash xfrm_state into wrong hash slot.
+	 * When the upper 16bits of spi values is used as CPI for the peer
+	 * to look up xfrm state, it would generate XfrmOutNoStates error,
+	 * as apparently we are looking for the wrong hash slot.
+	 *
+	 * So clamp down the spi range into only 16bits valid wide.
+	 */
+	if (x->id.proto == IPPROTO_COMP) {
+		minspi = htonl(0xc00);
+		maxspi = htonl(0xff00);
+	}
+
 	spin_lock_bh(&x->lock);
 	if (x->km.state == XFRM_STATE_DEAD)
 		goto unlock;
-- 
1.7.9.5
