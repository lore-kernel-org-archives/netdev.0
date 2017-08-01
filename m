From: ilant@mellanox.com
Subject: [PATCH net-next 4/7] esp6: Fix RX checksum after header pull
Date: Tue,  1 Aug 2017 12:49:07 +0300
Message-ID: <20170801094910.14895-5-ilant@mellanox.com>
References: <20170801094910.14895-1-ilant@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yossi Kuperman <yossiku@mellanox.com>,
        Ilan Tayari <ilant@mellanox.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr50051.outbound.protection.outlook.com ([40.107.5.51]:57152
        "EHLO EUR03-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751700AbdHAJt7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Aug 2017 05:49:59 -0400
In-Reply-To: <20170801094910.14895-1-ilant@mellanox.com>
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
---
 net/ipv6/esp6.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 0ca1db62e381..74bde202eb9a 100644
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
2.11.0
