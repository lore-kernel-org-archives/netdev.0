From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH 4/6] 6lowpan: add function to uncompress multicast addr
Date: Tue, 13 Aug 2013 23:53:31 +0200
Message-ID: <1376430813-30982-6-git-send-email-alex.aring@gmail.com>
References: <1376430813-30982-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:63487 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758422Ab3HMVty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 17:49:54 -0400
Received: by mail-ee0-f46.google.com with SMTP id c13so4455351eek.5
        for <netdev@vger.kernel.org>; Tue, 13 Aug 2013 14:49:52 -0700 (PDT)
In-Reply-To: <1376430813-30982-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add function to uncompress multicast address.
This function split the uncompress function for a multicast address
in a seperate function.

To uncompress a multicast address is different than a other
non-multicasts addresses according to rfc6282.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 net/ieee802154/6lowpan.c | 78 ++++++++++++++++++++++++++++++++++++------------
 1 file changed, 59 insertions(+), 19 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 632b3fd..0df8874 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -88,15 +88,6 @@ static const u8 lowpan_unc_llconf[] = {0x0f, 0x28, 0x22, 0x20};
  */
 static const u8 lowpan_unc_ctxconf[] = {0x00, 0x88, 0x82, 0x80};
 
-/*
- * Uncompression of ctx-base
- *   0 -> 0 bits from packet
- *   1 -> 2 bytes from prefix - bunch of zeroes 5 from packet
- *   2 -> 2 bytes from prefix - zeroes + 3 from packet
- *   3 -> 2 bytes from prefix - infer 1 bytes from lladdr
- */
-static const u8 lowpan_unc_mxconf[] = {0x0f, 0x25, 0x23, 0x21};
-
 /* Link local prefix */
 static const u8 lowpan_llprefix[] = {0xfe, 0x80};
 
@@ -240,6 +231,63 @@ lowpan_uncompress_addr(struct sk_buff *skb, struct in6_addr *ipaddr,
 	return 0;
 }
 
+/* Uncompress function for multicast destination address,
+ * when M bit is set.
+ */
+static int
+lowpan_uncompress_multicast_daddr(struct sk_buff *skb,
+		struct in6_addr *ipaddr,
+		const u8 dam)
+{
+	bool fail;
+
+	switch (dam) {
+	case LOWPAN_IPHC_DAM_00:
+		/* 00:  128 bits.  The full address
+		 * is carried in-line.
+		 */
+		fail = lowpan_fetch_skb(skb, ipaddr->s6_addr, 16);
+		break;
+	case LOWPAN_IPHC_DAM_01:
+		/* 01:  48 bits.  The address takes
+		 * the form ffXX::00XX:XXXX:XXXX.
+		 */
+		ipaddr->s6_addr[0] = 0xFF;
+		fail = lowpan_fetch_skb(skb, &ipaddr->s6_addr[1], 1);
+		fail |= lowpan_fetch_skb(skb, &ipaddr->s6_addr[11], 5);
+		break;
+	case LOWPAN_IPHC_DAM_10:
+		/* 10:  32 bits.  The address takes
+		 * the form ffXX::00XX:XXXX.
+		 */
+		ipaddr->s6_addr[0] = 0xFF;
+		fail = lowpan_fetch_skb(skb, &ipaddr->s6_addr[1], 1);
+		fail |= lowpan_fetch_skb(skb, &ipaddr->s6_addr[13], 3);
+		break;
+	case LOWPAN_IPHC_DAM_11:
+		/* 11:  8 bits.  The address takes
+		 * the form ff02::00XX.
+		 */
+		ipaddr->s6_addr[0] = 0xFF;
+		ipaddr->s6_addr[1] = 0x02;
+		fail = lowpan_fetch_skb(skb, &ipaddr->s6_addr[15], 1);
+		break;
+	default:
+		pr_debug("DAM value has a wrong value: 0x%x\n", dam);
+		return -EINVAL;
+	}
+
+	if (fail) {
+		pr_debug("Failed to fetch skb data\n");
+		return -EIO;
+	}
+
+	pr_debug("Reconstructed ipv6 multicast addr is:\n");
+	lowpan_raw_dump_inline(NULL, NULL, ipaddr->s6_addr, 16);
+
+	return 0;
+}
+
 static void
 lowpan_compress_udp_header(u8 **hc06_ptr, struct sk_buff *skb)
 {
@@ -927,16 +975,8 @@ lowpan_process_data(struct sk_buff *skb)
 			pr_debug("dest: context-based mcast compression\n");
 			/* TODO: implement this */
 		} else {
-			u8 prefix[] = {0xff, 0x02};
-
-			pr_debug("dest: non context-based mcast compression\n");
-			if (0 < tmp && tmp < 3) {
-				if (lowpan_fetch_skb_u8(skb, &prefix[1]))
-					goto drop;
-			}
-
-			err = lowpan_uncompress_addr(skb, &hdr.daddr, prefix,
-					lowpan_unc_mxconf[tmp], NULL);
+			err = lowpan_uncompress_multicast_daddr(
+					skb, &hdr.daddr, tmp);
 			if (err)
 				goto drop;
 		}
-- 
1.8.3.3
