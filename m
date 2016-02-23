From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net] net: vrf: Remove direct access to skb->data
Date: Tue, 23 Feb 2016 10:10:26 -0800
Message-ID: <1456251026-21898-1-git-send-email-dsa@cumulusnetworks.com>
Cc: nikolay@cumulusnetworks.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:34037 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754679AbcBWSLe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 13:11:34 -0500
Received: by mail-pf0-f175.google.com with SMTP id x65so116163327pfb.1
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 10:11:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nik pointed that the VRF driver should be using skb_header_pointer
instead of accessing skb->data and bits beyond directly which can
be garbage.

Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
Dave: This should go into v4.4 stable as well.

 drivers/net/vrf.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 9ce088bb28ab..9a9fabb900c1 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -103,20 +103,23 @@ static struct dst_ops vrf_dst_ops = {
 #if IS_ENABLED(CONFIG_IPV6)
 static bool check_ipv6_frame(const struct sk_buff *skb)
 {
-	const struct ipv6hdr *ipv6h = (struct ipv6hdr *)skb->data;
-	size_t hlen = sizeof(*ipv6h);
+	const struct ipv6hdr *ipv6h;
+	struct ipv6hdr _ipv6h;
 	bool rc = true;
 
-	if (skb->len < hlen)
+	ipv6h = skb_header_pointer(skb, 0, sizeof(_ipv6h), &_ipv6h);
+	if (!ipv6h)
 		goto out;
 
 	if (ipv6h->nexthdr == NEXTHDR_ICMP) {
 		const struct icmp6hdr *icmph;
+		struct icmp6hdr _icmph;
 
-		if (skb->len < hlen + sizeof(*icmph))
+		icmph = skb_header_pointer(skb, sizeof(_ipv6h),
+					   sizeof(_icmph), &_icmph);
+		if (!icmph)
 			goto out;
 
-		icmph = (struct icmp6hdr *)(skb->data + sizeof(*ipv6h));
 		switch (icmph->icmp6_type) {
 		case NDISC_ROUTER_SOLICITATION:
 		case NDISC_ROUTER_ADVERTISEMENT:
-- 
2.1.4
