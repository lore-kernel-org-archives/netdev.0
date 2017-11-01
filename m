From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net] xfrm: defer daddr pointer assignment after spi parsing
Date: Wed,  1 Nov 2017 20:30:49 +0100
Message-ID: <20171101193049.12336-1-fw@strlen.de>
References: <94eb2c05815016ca9c055cef9236@google.com>
Cc: syzkaller-bugs@googlegroups.com, steffen.klassert@secunet.com,
        herbert@gondor.apana.org.au, Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:54442 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754443AbdKATaf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 15:30:35 -0400
In-Reply-To: <94eb2c05815016ca9c055cef9236@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

syzbot reports:
BUG: KASAN: use-after-free in __xfrm_state_lookup+0x695/0x6b0
Read of size 4 at addr ffff8801d434e538 by task syzkaller647520/2991
[..]
__xfrm_state_lookup+0x695/0x6b0 net/xfrm/xfrm_state.c:833
xfrm_state_lookup+0x8a/0x160 net/xfrm/xfrm_state.c:1592
xfrm_input+0x8e5/0x22f0 net/xfrm/xfrm_input.c:302

The use-after-free is the ipv4 destination address, which points
to an skb head area that has been reallocated:
  pskb_expand_head+0x36b/0x1210 net/core/skbuff.c:1494
  __pskb_pull_tail+0x14a/0x17c0 net/core/skbuff.c:1877
  pskb_may_pull include/linux/skbuff.h:2102 [inline]
  xfrm_parse_spi+0x3d3/0x4d0 net/xfrm/xfrm_input.c:170
  xfrm_input+0xce2/0x22f0 net/xfrm/xfrm_input.c:291

so the real bug is that xfrm_parse_spi() uses pskb_may_pull, but
for now do smaller workaround that makes xfrm_input fetch daddr
after spi parsing.

Reported-by: syzbot <syzkaller@googlegroups.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/xfrm/xfrm_input.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 8ac9d32fb79d..1c6051cb7733 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -265,8 +265,6 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 		goto lock;
 	}
 
-	daddr = (xfrm_address_t *)(skb_network_header(skb) +
-				   XFRM_SPI_SKB_CB(skb)->daddroff);
 	family = XFRM_SPI_SKB_CB(skb)->family;
 
 	/* if tunnel is present override skb->mark value with tunnel i_key */
@@ -293,6 +291,8 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 		goto drop;
 	}
 
+	daddr = (xfrm_address_t *)(skb_network_header(skb) +
+				   XFRM_SPI_SKB_CB(skb)->daddroff);
 	do {
 		if (skb->sp->len == XFRM_MAX_DEPTH) {
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMINBUFFERERROR);
-- 
2.13.6
