From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net] macvtap: always pass ethernet header in linear
Date: Tue,  8 Mar 2016 15:18:54 -0500
Message-ID: <1457468334-66777-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f67.google.com ([209.85.192.67]:35227 "EHLO
	mail-qg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751194AbcCHUS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 15:18:59 -0500
Received: by mail-qg0-f67.google.com with SMTP id p68so1714855qge.2
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2016 12:18:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

The stack expects link layer headers in the skb linear section.
Macvtap can create skbs with llheader in frags in edge cases:
when (IFF_VNET_HDR is off or vnet_hdr.hdr_len < ETH_HLEN) and
prepad + len > PAGE_SIZE and vnet_hdr.flags has no or bad csum.

Add checks to ensure linear is always at least ETH_HLEN.
At this point, len is already ensured to be >= ETH_HLEN.

For backwards compatiblity, rounds up short vnet_hdr.hdr_len.
This differs from tap and packet, which return an error.

Fixes b9fb9ee07e67 ("macvtap: add GSO/csum offload support")
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 drivers/net/macvtap.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index d636d05..95394ed 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -760,6 +760,8 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 			macvtap16_to_cpu(q, vnet_hdr.hdr_len) : GOODCOPY_LEN;
 		if (copylen > good_linear)
 			copylen = good_linear;
+		else if (copylen < ETH_HLEN)
+			copylen = ETH_HLEN;
 		linear = copylen;
 		i = *from;
 		iov_iter_advance(&i, copylen);
@@ -769,10 +771,11 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 
 	if (!zerocopy) {
 		copylen = len;
-		if (macvtap16_to_cpu(q, vnet_hdr.hdr_len) > good_linear)
+		linear = macvtap16_to_cpu(q, vnet_hdr.hdr_len);
+		if (linear > good_linear)
 			linear = good_linear;
-		else
-			linear = macvtap16_to_cpu(q, vnet_hdr.hdr_len);
+		else if (linear < ETH_HLEN)
+			linear = ETH_HLEN;
 	}
 
 	skb = macvtap_alloc_skb(&q->sk, MACVTAP_RESERVE, copylen,
-- 
2.7.0.rc3.207.g0ac5344
