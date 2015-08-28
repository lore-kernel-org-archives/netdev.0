From: clsoto@linux.vnet.ibm.com
Subject: [PATCH net-next] net/mlx4_en: Fix IPv6 csum calculation
Date: Fri, 28 Aug 2015 14:28:27 -0500
Message-ID: <1440790107-24268-1-git-send-email-clsoto@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	brking@linux.vnet.ibm.com, amirv@mellanox.com,
	Carol L Soto <clsoto@linux.vnet.ibm.com>,
	Muhammad Mahajna <muhammadm@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp05.br.ibm.com ([32.104.18.26]:51614 "EHLO
	e24smtp05.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752164AbbH1TdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 15:33:16 -0400
Received: from /spool/local
	by e24smtp05.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <wenxiong@us.ibm.com>;
	Fri, 28 Aug 2015 16:33:12 -0300
Received: from d24relay02.br.ibm.com (d24relay02.br.ibm.com [9.13.184.26])
	by d24dlp02.br.ibm.com (Postfix) with ESMTP id 6EE961DC006D
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 15:32:08 -0400 (EDT)
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay02.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t7SJVPuo30605772
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 16:31:26 -0300
Received: from d24av01.br.ibm.com (localhost [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t7SJX9nv022714
	for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 16:33:09 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carol L Soto <clsoto@linux.vnet.ibm.com>

Seeing this message with mlx4_eni with IPv6: hw csum failure

Changing IPv6 csum calculation to be based on OFED 2.4 code.
When calculate IPv6 csum based also on source and destination
addresses.

Signed-off-by: Muhammad Mahajna <muhammadm@mellanox.com>
Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 46 +++++++++++++++++++++---------
 1 file changed, 33 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 4402a1e..d43c512 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -693,26 +693,46 @@ static void get_fixed_ipv4_csum(__wsum hw_checksum, struct sk_buff *skb,
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
-/* In IPv6 packets, besides subtracting the pseudo header checksum,
- * we also compute/add the IP header checksum which
- * is not added by the HW.
- */
+static __wsum csum_ipv6_magic_nofold(const struct in6_addr *saddr,
+				     const struct in6_addr *daddr,
+				     __u32 len, unsigned short proto)
+{
+	__wsum res = 0;
+
+	res = csum_add(res, saddr->in6_u.u6_addr32[0]);
+	res = csum_add(res, saddr->in6_u.u6_addr32[1]);
+	res = csum_add(res, saddr->in6_u.u6_addr32[2]);
+	res = csum_add(res, saddr->in6_u.u6_addr32[3]);
+	res = csum_add(res, daddr->in6_u.u6_addr32[0]);
+	res = csum_add(res, daddr->in6_u.u6_addr32[1]);
+	res = csum_add(res, daddr->in6_u.u6_addr32[2]);
+	res = csum_add(res, daddr->in6_u.u6_addr32[3]);
+	res = csum_add(res, len);
+	res = csum_add(res, htonl(proto));
+
+	return res;
+}
+
 static int get_fixed_ipv6_csum(__wsum hw_checksum, struct sk_buff *skb,
 			       struct ipv6hdr *ipv6h)
 {
-	__wsum csum_pseudo_hdr = 0;
+	__wsum csum_pseudo_header = 0;
 
-	if (ipv6h->nexthdr == IPPROTO_FRAGMENT || ipv6h->nexthdr == IPPROTO_HOPOPTS)
+	if (ipv6h->nexthdr == IPPROTO_FRAGMENT ||
+	    ipv6h->nexthdr == IPPROTO_HOPOPTS)
 		return -1;
-	hw_checksum = csum_add(hw_checksum, (__force __wsum)(ipv6h->nexthdr << 8));
 
-	csum_pseudo_hdr = csum_partial(&ipv6h->saddr,
-				       sizeof(ipv6h->saddr) + sizeof(ipv6h->daddr), 0);
-	csum_pseudo_hdr = csum_add(csum_pseudo_hdr, (__force __wsum)ipv6h->payload_len);
-	csum_pseudo_hdr = csum_add(csum_pseudo_hdr, (__force __wsum)ntohs(ipv6h->nexthdr));
+	hw_checksum = csum_add(hw_checksum, cpu_to_be16(ipv6h->nexthdr));
+	csum_pseudo_header = csum_ipv6_magic_nofold(&ipv6h->saddr,
+						    &ipv6h->daddr,
+						    ipv6h->payload_len,
+						    ipv6h->nexthdr);
+	hw_checksum = csum_sub(hw_checksum, csum_pseudo_header);
+	hw_checksum = csum_partial(ipv6h, sizeof(struct ipv6hdr), hw_checksum);
+	if (!hw_checksum)
+		return -1;
 
-	skb->csum = csum_sub(hw_checksum, csum_pseudo_hdr);
-	skb->csum = csum_add(skb->csum, csum_partial(ipv6h, sizeof(struct ipv6hdr), 0));
+	skb->csum = hw_checksum;
 	return 0;
 }
 #endif
-- 
1.8.3.1
