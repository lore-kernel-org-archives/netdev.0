From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net] net: change skb->mac_header when Generic XDP calls
 adjust_head
Date: Tue, 19 Sep 2017 18:45:56 +0100
Message-ID: <394385d4-796a-9ada-8f01-53a52d73a418@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:38706 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751378AbdISRqD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 13:46:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since XDP's view of the packet includes the MAC header, moving the start-
 of-packet with bpf_xdp_adjust_head needs to also update the offset of the
 MAC header (which is relative to skb->head, not to the skb->data that was
 changed).
Without this, tcpdump sees packets starting from the old MAC header rather
 than the new one, at least in my tests on the loopback device.

Fixes: b5cdae3291f7 ("net: Generic XDP")
Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 net/core/dev.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index fb766d9..9a2254f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3892,6 +3892,7 @@ static u32 netif_receive_generic_xdp(struct sk_buff *skb,
 		__skb_pull(skb, off);
 	else if (off < 0)
 		__skb_push(skb, -off);
+	skb->mac_header += off;
 
 	switch (act) {
 	case XDP_REDIRECT:
