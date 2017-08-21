From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 4/8] esp6: Fix RX checksum after header pull
Date: Mon, 21 Aug 2017 07:49:29 +0200
Message-ID: <1503294573-10206-5-git-send-email-steffen.klassert@secunet.com>
References: <1503294573-10206-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:34914 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751240AbdHUFtm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 01:49:42 -0400
In-Reply-To: <1503294573-10206-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yossi Kuperman <yossiku@mellanox.com>

Both ip6_input_finish (non-GRO) and esp6_gro_receive (GRO) strip
the IPv6 header without adjusting skb->csum accordingly. As a
result CHECKSUM_COMPLETE breaks and "hw csum failure" is written
to the kernel log by netdev_rx_csum_fault (dev.c).

Fix skb->csum by substracting the checksum value of the pulled IPv6
header using a call to skb_postpull_rcsum.

This affects both transport and tunnel modes.

Note that the fix occurs far from the place that the header was
pulled. This is based on existing code, see:
ipv6_srh_rcv() in exthdrs.c and rawv6_rcv() in raw.c

Signed-off-by: Yossi Kuperman <yossiku@mellanox.com>
Signed-off-by: Ilan Tayari <ilant@mellanox.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/esp6.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 0ca1db6..74bde20 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -495,6 +495,8 @@ int esp6_input_done2(struct sk_buff *skb, int err)
 
 	trimlen = alen + padlen + 2;
 	if (skb->ip_summed == CHECKSUM_COMPLETE) {
+		skb_postpull_rcsum(skb, skb_network_header(skb),
+				   skb_network_header_len(skb));
 		csumdiff = skb_checksum(skb, skb->len - trimlen, trimlen, 0);
 		skb->csum = csum_block_sub(skb->csum, csumdiff,
 					   skb->len - trimlen);
-- 
2.7.4
