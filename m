From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/4] vti: fix NULL dereference in xfrm_input()
Date: Mon, 9 Oct 2017 09:16:38 +0200
Message-ID: <1507533399-29399-4-git-send-email-steffen.klassert@secunet.com>
References: <1507533399-29399-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:49560 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751068AbdJIHQt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 03:16:49 -0400
In-Reply-To: <1507533399-29399-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Kodanev <alexey.kodanev@oracle.com>

Can be reproduced with LTP tests:
  # icmp-uni-vti.sh -p ah -a sha256 -m tunnel -S fffffffe -k 1 -s 10

IPv4:
  RIP: 0010:xfrm_input+0x7f9/0x870
  ...
  Call Trace:
  <IRQ>
  vti_input+0xaa/0x110 [ip_vti]
  ? skb_free_head+0x21/0x40
  vti_rcv+0x33/0x40 [ip_vti]
  xfrm4_ah_rcv+0x33/0x60
  ip_local_deliver_finish+0x94/0x1e0
  ip_local_deliver+0x6f/0xe0
  ? ip_route_input_noref+0x28/0x50
  ...

  # icmp-uni-vti.sh -6 -p ah -a sha256 -m tunnel -S fffffffe -k 1 -s 10
IPv6:
  RIP: 0010:xfrm_input+0x7f9/0x870
  ...
  Call Trace:
  <IRQ>
  xfrm6_rcv_tnl+0x3c/0x40
  vti6_rcv+0xd5/0xe0 [ip6_vti]
  xfrm6_ah_rcv+0x33/0x60
  ip6_input_finish+0xee/0x460
  ip6_input+0x3f/0xb0
  ip6_rcv_finish+0x45/0xa0
  ipv6_rcv+0x34b/0x540

xfrm_input() invokes xfrm_rcv_cb() -> vti_rcv_cb(), the last callback
might call skb_scrub_packet(), which in turn can reset secpath.

Fix it by adding a check that skb->sp is not NULL.

Fixes: 7e9e9202bccc ("xfrm: Clear RX SKB secpath xfrm_offload")
Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_input.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 2515cd2..8ac9d32 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -429,7 +429,8 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 	nf_reset(skb);
 
 	if (decaps) {
-		skb->sp->olen = 0;
+		if (skb->sp)
+			skb->sp->olen = 0;
 		skb_dst_drop(skb);
 		gro_cells_receive(&gro_cells, skb);
 		return 0;
@@ -440,7 +441,8 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 
 		err = x->inner_mode->afinfo->transport_finish(skb, xfrm_gro || async);
 		if (xfrm_gro) {
-			skb->sp->olen = 0;
+			if (skb->sp)
+				skb->sp->olen = 0;
 			skb_dst_drop(skb);
 			gro_cells_receive(&gro_cells, skb);
 			return err;
-- 
2.7.4
