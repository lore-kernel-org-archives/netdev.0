From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 04/17] sfc: Move assertions and buffer cleanup earlier in
	efx_rx_packet_lro()
Date: Tue, 24 Nov 2009 02:02:25 +0000
Message-ID: <1259028145.14645.11.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:34593 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757753AbZKXCCV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 21:02:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This removes the need to use a label and goto, and makes the two
branches mirror each other more closely.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/rx.c |   26 ++++++++++++++------------
 1 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index c407352..9e33391 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -449,15 +449,19 @@ static void efx_rx_packet_lro(struct efx_channel *channel,
 
 	/* Pass the skb/page into the LRO engine */
 	if (rx_buf->page) {
-		struct sk_buff *skb = napi_get_frags(napi);
+		struct page *page = rx_buf->page;
+		struct sk_buff *skb;
 
+		EFX_BUG_ON_PARANOID(rx_buf->skb);
+		rx_buf->page = NULL;
+
+		skb = napi_get_frags(napi);
 		if (!skb) {
-			put_page(rx_buf->page);
-			gro_result = GRO_DROP;
-			goto out;
+			put_page(page);
+			return;
 		}
 
-		skb_shinfo(skb)->frags[0].page = rx_buf->page;
+		skb_shinfo(skb)->frags[0].page = page;
 		skb_shinfo(skb)->frags[0].page_offset =
 			efx_rx_buf_offset(rx_buf);
 		skb_shinfo(skb)->frags[0].size = rx_buf->len;
@@ -470,16 +474,14 @@ static void efx_rx_packet_lro(struct efx_channel *channel,
 			checksummed ? CHECKSUM_UNNECESSARY : CHECKSUM_NONE;
 
 		gro_result = napi_gro_frags(napi);
-
-out:
-		EFX_BUG_ON_PARANOID(rx_buf->skb);
-		rx_buf->page = NULL;
 	} else {
-		EFX_BUG_ON_PARANOID(!rx_buf->skb);
-		EFX_BUG_ON_PARANOID(!checksummed);
+		struct sk_buff *skb = rx_buf->skb;
 
-		gro_result = napi_gro_receive(napi, rx_buf->skb);
+		EFX_BUG_ON_PARANOID(!skb);
+		EFX_BUG_ON_PARANOID(!checksummed);
 		rx_buf->skb = NULL;
+
+		gro_result = napi_gro_receive(napi, skb);
 	}
 
 	if (gro_result == GRO_NORMAL) {

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

