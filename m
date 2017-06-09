From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH v4.11 -stable] esp4: Fix udpencap for local TCP packets.
Date: Fri, 9 Jun 2017 11:35:46 +0200
Message-ID: <20170609093545.GS22049@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:47522 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751530AbdFIJfx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Jun 2017 05:35:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Locally generated TCP packets are usually cloned, so we
do skb_cow_data() on this packets. After that we need to
reload the pointer to the esp header. On udpencap this
header has an offset to skb_transport_header, so take this
offset into account.

This is a backport of:
commit 0e78a87306a ("esp4: Fix udpencap for local TCP packets.")

Fixes: 67d349ed603 ("net/esp4: Fix invalid esph pointer crash")
Fixes: fca11ebde3f0 ("esp4: Reorganize esp_output")
Reported-by: Don Bowman <db@donbowman.ca>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/esp4.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index b1e2444..9708a32 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -212,6 +212,7 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	u8 *iv;
 	u8 *tail;
 	u8 *vaddr;
+	int esph_offset;
 	int blksize;
 	int clen;
 	int alen;
@@ -392,12 +393,14 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	}
 
 cow:
+	esph_offset = (unsigned char *)esph - skb_transport_header(skb);
+
 	err = skb_cow_data(skb, tailen, &trailer);
 	if (err < 0)
 		goto error;
 	nfrags = err;
 	tail = skb_tail_pointer(trailer);
-	esph = ip_esp_hdr(skb);
+	esph = (struct ip_esp_hdr *)(skb_transport_header(skb) + esph_offset);
 
 skip_cow:
 	esp_output_fill_trailer(tail, tfclen, plen, proto);
-- 
2.7.4
