From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH] ipv6: do not increment mac header when it's unset
Date: Fri, 21 Oct 2016 17:39:54 +0900
Message-ID: <20161021083954.20941-1-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, pageexec@gmail.com,
        re.emese@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:41301 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752915AbcJUIkL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Oct 2016 04:40:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise we'll overflow the integer. This occurs when layer 3 tunneled
packets are handed off to the IPv6 layer.

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
---
 net/ipv6/reassembly.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index e2ea311..431d69d 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -456,7 +456,8 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 	skb_network_header(head)[nhoff] = skb_transport_header(head)[0];
 	memmove(head->head + sizeof(struct frag_hdr), head->head,
 		(head->data - head->head) - sizeof(struct frag_hdr));
-	head->mac_header += sizeof(struct frag_hdr);
+	if (skb_mac_header_was_set(skb))
+		head->mac_header += sizeof(struct frag_hdr);
 	head->network_header += sizeof(struct frag_hdr);
 
 	skb_reset_transport_header(head);
-- 
2.10.1
