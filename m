From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] net: 6lowpan: fix lowpan_header_create non-compression memcpy call
Date: Mon,  6 Jan 2014 01:45:50 +0100
Message-ID: <1388969150-16041-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Werner Almesberger <werner@almesberger.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64698 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752018AbaAFAp7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jan 2014 19:45:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In function lowpan_header_create(), we invoke the following code
construct:

  struct ipv6hdr *hdr;
  ...
  hdr = ipv6_hdr(skb);
  ...
  if (...)
    memcpy(hc06_ptr + 1, &hdr->flow_lbl[1], 2);
  else
    memcpy(hc06_ptr, &hdr, 4);

Where the else path of the condition, that is, non-compression
path, calls memcpy() with a pointer to struct ipv6hdr *hdr as
source, thus two levels of indirection. This cannot be correct,
and likely only one level of pointer was intended as source
buffer for memcpy() here.

Fixes: 44331fe2aa0d ("IEEE802.15.4: 6LoWPAN basic support")
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Cc: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Cc: Werner Almesberger <werner@almesberger.net>
---
 net/ieee802154/6lowpan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 459e200..a2d2456 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -547,7 +547,7 @@ static int lowpan_header_create(struct sk_buff *skb,
 			hc06_ptr += 3;
 		} else {
 			/* compress nothing */
-			memcpy(hc06_ptr, &hdr, 4);
+			memcpy(hc06_ptr, hdr, 4);
 			/* replace the top byte with new ECN | DSCP format */
 			*hc06_ptr = tmp;
 			hc06_ptr += 4;
-- 
1.7.11.7
