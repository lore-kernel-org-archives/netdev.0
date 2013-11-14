From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next 2/6] 6lowpan: fix udp compress ordering
Date: Thu, 14 Nov 2013 16:48:48 +0100
Message-ID: <1384444132-1427-3-git-send-email-alex.aring@gmail.com>
References: <1384444132-1427-1-git-send-email-alex.aring@gmail.com>
Cc: linux-zigbee-devel@lists.sourceforge.net, werner@almesberger.net,
	jukka.rissanen@linux.intel.com, dbaryshkov@gmail.com,
	netdev@vger.kernel.org, Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f48.google.com ([209.85.214.48]:62174 "EHLO
	mail-bk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754049Ab3KNPtF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 10:49:05 -0500
Received: by mail-bk0-f48.google.com with SMTP id v10so613094bkz.35
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 07:49:04 -0800 (PST)
In-Reply-To: <1384444132-1427-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case ((ntohs(uh->source) & LOWPAN_NHC_UDP_8BIT_MASK) the order of
uncompression is wrong. It's always first source port then destination
port as second.

See:
http://tools.ietf.org/html/rfc6282#section-4.3.3

"Fields carried in-line (in part or in whole) appear in the same order
as they do in the UDP header format"

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 net/ieee802154/6lowpan.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 8633379..ad6755a 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -359,8 +359,8 @@ lowpan_compress_udp_header(u8 **hc06_ptr, struct sk_buff *skb)
 			LOWPAN_NHC_UDP_8BIT_PORT) {
 		pr_debug("UDP header: remove 8 bits of source\n");
 		**hc06_ptr = LOWPAN_NHC_UDP_CS_P_10;
-		memcpy(*hc06_ptr + 1, &uh->dest, 2);
-		*(*hc06_ptr + 3) = (u8)(uh->source - LOWPAN_NHC_UDP_8BIT_PORT);
+		*(*hc06_ptr + 1) = (u8)(uh->source - LOWPAN_NHC_UDP_8BIT_PORT);
+		memcpy(*hc06_ptr + 2, &uh->dest, 2);
 		*hc06_ptr += 4;
 	} else {
 		pr_debug("UDP header: can't compress\n");
-- 
1.8.4.2
