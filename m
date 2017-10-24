From: avivh@mellanox.com
Subject: [PATCH net-next 1/3] xfrm: Fix xfrm_input() to verify state is valid when (encap_type < 0)
Date: Tue, 24 Oct 2017 18:10:29 +0300
Message-ID: <1508857831-55824-1-git-send-email-avivh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Boris Pismenny <borisp@mellanox.com>,
        Yossi Kuperman <yossiku@mellanox.com>,
        Yevgeny Kliteynik <kliteyn@mellanox.com>,
        netdev@vger.kernel.org, Aviv Heller <avivh@mellanox.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0069.outbound.protection.outlook.com ([104.47.1.69]:35072
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932397AbdJXPKx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Oct 2017 11:10:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aviv Heller <avivh@mellanox.com>

Code path when (encap_type < 0) does not verify the state is valid
before progressing.

This will result in a crash if, for instance, x->km.state ==
XFRM_STATE_ACQ.

Fixes: 7785bba299a8 ("esp: Add a software GRO codepath")
Signed-off-by: Aviv Heller <avivh@mellanox.com>
Signed-off-by: Yevgeny Kliteynik <kliteyn@mellanox.com>
---
 net/xfrm/xfrm_input.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 2515cd2..ea9407f 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -206,7 +206,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 	xfrm_address_t *daddr;
 	struct xfrm_mode *inner_mode;
 	u32 mark = skb->mark;
-	unsigned int family;
+	unsigned int family = AF_UNSPEC;
 	int decaps = 0;
 	int async = 0;
 	bool xfrm_gro = false;
@@ -215,6 +215,16 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 
 	if (encap_type < 0) {
 		x = xfrm_input_state(skb);
+
+		if (unlikely(x->km.state != XFRM_STATE_VALID)) {
+			if (x->km.state == XFRM_STATE_ACQ)
+				XFRM_INC_STATS(net, LINUX_MIB_XFRMACQUIREERROR);
+			else
+				XFRM_INC_STATS(net,
+					       LINUX_MIB_XFRMINSTATEINVALID);
+			goto drop;
+		}
+
 		family = x->outer_mode->afinfo->family;
 
 		/* An encap_type of -1 indicates async resumption. */
-- 
1.8.3.1
