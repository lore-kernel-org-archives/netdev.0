From: ilant@mellanox.com
Subject: [PATCH net-next 4/4] esp6: Fix RX checksum after header pull
Date: Thu, 22 Jun 2017 15:31:59 +0300
Message-ID: <20170622123159.8348-5-ilant@mellanox.com>
References: <20170622123159.8348-1-ilant@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Yossi Kuperman <yossiku@mellanox.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr10041.outbound.protection.outlook.com ([40.107.1.41]:36016
        "EHLO EUR02-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751118AbdFVMc2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Jun 2017 08:32:28 -0400
In-Reply-To: <20170622123159.8348-1-ilant@mellanox.com>
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
---
 net/ipv6/esp6.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index f872bb16cc9d..3fed3947acf9 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -500,6 +500,8 @@ int esp6_input_done2(struct sk_buff *skb, int err)
 
 	trimlen = alen + padlen + 2;
 	if (skb->ip_summed == CHECKSUM_COMPLETE) {
+		skb_postpull_rcsum(skb, skb_network_header(skb),
+				   skb_network_header_len(skb));
 		csumdiff = skb_checksum(skb, skb->len - trimlen, trimlen, 0);
 		skb->csum = csum_block_sub(skb->csum, csumdiff,
 					   skb->len - trimlen);
-- 
2.11.0
