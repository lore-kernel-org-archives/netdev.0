From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH v2 1/2] ipv4: Fix packet size calculation in
 __ip_append_data
Date: Wed, 22 Jun 2011 13:04:37 +0200
Message-ID: <20110622110437.GG6489@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51880 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753330Ab1FVLEc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2011 07:04:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Git commit 59104f06 (ip: take care of last fragment in ip_append_data)
added a check to see if we exceed the mtu when we add trailer_len.
However, the mtu is already subtracted by the trailer length when the
xfrm transfomation bundles are set up. So IPsec packets with mtu
size get fragmented, or if the DF bit is set the packets will not
be send even though they match the mtu perfectly fine. This patch
actually reverts commit 59104f06.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/ip_output.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index a8024ea..6b894d4 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -888,12 +888,9 @@ alloc_new_skb:
 			 * because we have no idea what fragment will be
 			 * the last.
 			 */
-			if (datalen == length + fraggap) {
+			if (datalen == length + fraggap)
 				alloclen += rt->dst.trailer_len;
-				/* make sure mtu is not reached */
-				if (datalen > mtu - fragheaderlen - rt->dst.trailer_len)
-					datalen -= ALIGN(rt->dst.trailer_len, 8);
-			}
+
 			if (transhdrlen) {
 				skb = sock_alloc_send_skb(sk,
 						alloclen + hh_len + 15,
-- 
1.7.0.4

