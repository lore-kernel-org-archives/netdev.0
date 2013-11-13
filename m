From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH] 6lowpan: Uncompression of traffic class field was incorrect
Date: Wed, 13 Nov 2013 11:03:39 +0200
Message-ID: <1384333419-4087-1-git-send-email-jukka.rissanen@linux.intel.com>
Cc: alex.aring@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:52515 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933456Ab3KMJDn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Nov 2013 04:03:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If priority/traffic class field in IPv6 header is set (seen when
using ssh), the uncompression sets the TC and Flow fields incorrectly.

Example:

This is IPv6 header of a sent packet. Note the priority/TC (=1) in
the first byte.

00000000: 61 00 00 00 00 2c 06 40 fe 80 00 00 00 00 00 00
00000010: 02 02 72 ff fe c6 42 10 fe 80 00 00 00 00 00 00
00000020: 02 1e ab ff fe 4c 52 57

This gets compressed like this in the sending side

00000000: 72 31 04 06 02 1e ab ff fe 4c 52 57 ec c2 00 16
00000010: aa 2d fe 92 86 4e be c6 ....

In the receiving end, the packet gets uncompressed to this
IPv6 header

00000000: 60 06 06 02 00 2a 1e 40 fe 80 00 00 00 00 00 00
00000010: 02 02 72 ff fe c6 42 10 fe 80 00 00 00 00 00 00
00000020: ab ff fe 4c 52 57 ec c2

First four bytes are set incorrectly and we have also lost
two bytes from destination address.

The fix is to switch the case values in switch statement
when checking the TC field.

Signed-off-by: Jukka Rissanen <jukka.rissanen@linux.intel.com>
---
 net/ieee802154/6lowpan.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 426b5df..459e200 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -956,7 +956,7 @@ lowpan_process_data(struct sk_buff *skb)
 	 * Traffic class carried in-line
 	 * ECN + DSCP (1 byte), Flow Label is elided
 	 */
-	case 1: /* 10b */
+	case 2: /* 10b */
 		if (lowpan_fetch_skb_u8(skb, &tmp))
 			goto drop;
 
@@ -967,7 +967,7 @@ lowpan_process_data(struct sk_buff *skb)
 	 * Flow Label carried in-line
 	 * ECN + 2-bit Pad + Flow Label (3 bytes), DSCP is elided
 	 */
-	case 2: /* 01b */
+	case 1: /* 01b */
 		if (lowpan_fetch_skb_u8(skb, &tmp))
 			goto drop;
 
-- 
1.8.3.1
