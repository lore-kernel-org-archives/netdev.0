From: <ilant@mellanox.com>
Subject: [PATCH net-next] net/esp4: Fix invalid esph pointer crash
Date: Sun, 30 Apr 2017 16:34:38 +0300
Message-ID: <20170430133438.31962-1-ilant@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Ilan Tayari <ilant@mellanox.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0061.outbound.protection.outlook.com ([104.47.2.61]:25265
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1035146AbdD3Nes (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Apr 2017 09:34:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilan Tayari <ilant@mellanox.com>

Both esp_output and esp_xmit take a pointer to the ESP header
and place it in esp_info struct prior to calling esp_output_head.

Inside esp_output_head, the call to esp_output_udp_encap
makes sure to update the pointer if it gets invalid.
However, if esp_output_head itself calls skb_cow_data, the
pointer is not updated and stays invalid, causing a crash
after esp_output_head returns.

Update the pointer if it becomes invalid in esp_output_head

Fixes: fca11ebde3f0 ("esp4: Reorganize esp_output")
Signed-off-by: Ilan Tayari <ilant@mellanox.com>
---
 net/ipv4/esp4.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 7f2caf71212b..65cc02bd82bc 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -317,6 +317,7 @@ int esp_output_head(struct xfrm_state *x, struct sk_buff *skb, struct esp_info *
 	if (nfrags < 0)
 		goto out;
 	tail = skb_tail_pointer(trailer);
+	esp->esph = ip_esp_hdr(skb);
 
 skip_cow:
 	esp_output_fill_trailer(tail, esp->tfclen, esp->plen, esp->proto);
-- 
2.11.0
