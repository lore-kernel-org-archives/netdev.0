From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net] net/mlx4_en: Fix endianness bug in IPV6 csum calculation
Date: Wed,  4 May 2016 15:00:33 +0300
Message-ID: <1462363233-8598-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Daniel Jurgens <danielj@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:59477 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750735AbcEDMbd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2016 08:31:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Jurgens <danielj@mellanox.com>

Use htons instead of unconditionally byte swapping nexthdr.  On a little
endian systems shifting the byte is correct behavior, but it results in
incorrect csums on big endian architectures.

Fixes: f8c6455bb04b ('net/mlx4_en: Extend checksum offloading by CHECKSUM COMPLETE')
Signed-off-by: Daniel Jurgens <danielj@mellanox.com>
Reviewed-by: Carol Soto <clsoto@us.ibm.com>
Tested-by: Carol Soto <clsoto@us.ibm.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index b723e3b..ca3a384 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -707,7 +707,7 @@ static int get_fixed_ipv6_csum(__wsum hw_checksum, struct sk_buff *skb,
 
 	if (ipv6h->nexthdr == IPPROTO_FRAGMENT || ipv6h->nexthdr == IPPROTO_HOPOPTS)
 		return -1;
-	hw_checksum = csum_add(hw_checksum, (__force __wsum)(ipv6h->nexthdr << 8));
+	hw_checksum = csum_add(hw_checksum, (__force __wsum)htons(ipv6h->nexthdr));
 
 	csum_pseudo_hdr = csum_partial(&ipv6h->saddr,
 				       sizeof(ipv6h->saddr) + sizeof(ipv6h->daddr), 0);
-- 
1.8.3.1
