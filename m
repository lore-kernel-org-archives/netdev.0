From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 7/8] net: Add calaulation of non folded IPV6 pseudo header checksum
Date: Thu, 30 Oct 2014 18:06:55 +0200
Message-ID: <1414685216-28907-8-git-send-email-ogerlitz@mellanox.com>
References: <1414685216-28907-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:39649 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759393AbaJ3QHG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2014 12:07:06 -0400
In-Reply-To: <1414685216-28907-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shani Michaeli <shanim@mellanox.com>

Compute IPV6 pseudo header checksum without folding it to a 16 bit
return value.

Signed-off-by: Shani Michaeli <shanim@mellanox.com>
Signed-off-by: Matan Barak <matanb@mellanox.com>
---
 include/net/ip6_checksum.h |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/include/net/ip6_checksum.h b/include/net/ip6_checksum.h
index 1a49b73..c45d690 100644
--- a/include/net/ip6_checksum.h
+++ b/include/net/ip6_checksum.h
@@ -41,6 +41,27 @@ __sum16 csum_ipv6_magic(const struct in6_addr *saddr,
 			__wsum csum);
 #endif
 
+static inline __wsum csum_ipv6_magic_nofold(const struct in6_addr *saddr,
+					    const struct in6_addr *daddr,
+					    __u32 len, unsigned short proto,
+					    __wsum sum)
+{
+	__wsum res = sum;
+
+	res = csum_add(res, (__force __wsum)saddr->in6_u.u6_addr32[0]);
+	res = csum_add(res, (__force __wsum)saddr->in6_u.u6_addr32[1]);
+	res = csum_add(res, (__force __wsum)saddr->in6_u.u6_addr32[2]);
+	res = csum_add(res, (__force __wsum)saddr->in6_u.u6_addr32[3]);
+	res = csum_add(res, (__force __wsum)daddr->in6_u.u6_addr32[0]);
+	res = csum_add(res, (__force __wsum)daddr->in6_u.u6_addr32[1]);
+	res = csum_add(res, (__force __wsum)daddr->in6_u.u6_addr32[2]);
+	res = csum_add(res, (__force __wsum)daddr->in6_u.u6_addr32[3]);
+	res = csum_add(res, (__force __wsum)htonl(len));
+	res = csum_add(res, (__force __wsum)htonl(proto));
+
+	return res;
+}
+
 static inline __wsum ip6_compute_pseudo(struct sk_buff *skb, int proto)
 {
 	return ~csum_unfold(csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
-- 
1.7.1
