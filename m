From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next 1/6] 6lowpan: fix udp nullpointer dereferencing
Date: Thu, 14 Nov 2013 16:48:47 +0100
Message-ID: <1384444132-1427-2-git-send-email-alex.aring@gmail.com>
References: <1384444132-1427-1-git-send-email-alex.aring@gmail.com>
Cc: linux-zigbee-devel@lists.sourceforge.net, werner@almesberger.net,
	jukka.rissanen@linux.intel.com, dbaryshkov@gmail.com,
	netdev@vger.kernel.org, Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f45.google.com ([209.85.214.45]:59482 "EHLO
	mail-bk0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753626Ab3KNPtF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 10:49:05 -0500
Received: by mail-bk0-f45.google.com with SMTP id r7so1139689bkg.18
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 07:49:03 -0800 (PST)
In-Reply-To: <1384444132-1427-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sometimes a nullpointer dereferencing occurs because of using a wrong
pointer arithmetic in udp_uncompression.

This patch changes "**(hc06_ptr + 3)" to the right one "*(*hc06_ptr +
3)". Dereferencing like "**(hc06_ptr + 3)" works in a random case only.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 net/ieee802154/6lowpan.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 426b5df..8633379 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -344,7 +344,7 @@ lowpan_compress_udp_header(u8 **hc06_ptr, struct sk_buff *skb)
 				LOWPAN_NHC_UDP_4BIT_PORT)) {
 		pr_debug("UDP header: both ports compression to 4 bits\n");
 		**hc06_ptr = LOWPAN_NHC_UDP_CS_P_11;
-		**(hc06_ptr + 1) = /* subtraction is faster */
+		*(*hc06_ptr + 1) = /* subtraction is faster */
 		   (u8)((uh->dest - LOWPAN_NHC_UDP_4BIT_PORT) +
 		       ((uh->source & LOWPAN_NHC_UDP_4BIT_PORT) << 4));
 		*hc06_ptr += 2;
@@ -353,14 +353,14 @@ lowpan_compress_udp_header(u8 **hc06_ptr, struct sk_buff *skb)
 		pr_debug("UDP header: remove 8 bits of dest\n");
 		**hc06_ptr = LOWPAN_NHC_UDP_CS_P_01;
 		memcpy(*hc06_ptr + 1, &uh->source, 2);
-		**(hc06_ptr + 3) = (u8)(uh->dest - LOWPAN_NHC_UDP_8BIT_PORT);
+		*(*hc06_ptr + 3) = (u8)(uh->dest - LOWPAN_NHC_UDP_8BIT_PORT);
 		*hc06_ptr += 4;
 	} else if ((uh->source & LOWPAN_NHC_UDP_8BIT_MASK) ==
 			LOWPAN_NHC_UDP_8BIT_PORT) {
 		pr_debug("UDP header: remove 8 bits of source\n");
 		**hc06_ptr = LOWPAN_NHC_UDP_CS_P_10;
 		memcpy(*hc06_ptr + 1, &uh->dest, 2);
-		**(hc06_ptr + 3) = (u8)(uh->source - LOWPAN_NHC_UDP_8BIT_PORT);
+		*(*hc06_ptr + 3) = (u8)(uh->source - LOWPAN_NHC_UDP_8BIT_PORT);
 		*hc06_ptr += 4;
 	} else {
 		pr_debug("UDP header: can't compress\n");
-- 
1.8.4.2
