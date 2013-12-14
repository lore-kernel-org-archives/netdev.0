From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 09/15] sfc: Copy RX prefix into skb head area in
 efx_rx_mk_skb()
Date: Sat, 14 Dec 2013 23:04:40 +0000
Message-ID: <1387062280.12172.67.camel@deadeye.wl.decadent.org.uk>
References: <1387061852.12172.58.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	"Richard Cochran" <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17371 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753941Ab3LNXEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 18:04:44 -0500
In-Reply-To: <1387061852.12172.58.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can potentially pull the entire packet contents into the head area
and then free the page it was in.  In order to read an inline
timestamp safely, we need to copy the prefix into the head area as
well.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/net_driver.h |    9 ---------
 drivers/net/ethernet/sfc/rx.c         |   10 +++++++---
 2 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 01ffbe849683..1a3e4972c68f 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -521,15 +521,6 @@ enum nic_state {
 	STATE_RECOVERY = 3,	/* device recovering from PCI error */
 };
 
-/*
- * Alignment of the skb->head which wraps a page-allocated RX buffer
- *
- * The skb allocated to wrap an rx_buffer can have this alignment. Since
- * the data is memcpy'd from the rx_buf, it does not need to be equal to
- * NET_IP_ALIGN.
- */
-#define EFX_PAGE_SKB_ALIGN 2
-
 /* Forward declaration */
 struct efx_nic;
 
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 8671bc199a9d..d12abc543975 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -476,14 +476,18 @@ static struct sk_buff *efx_rx_mk_skb(struct efx_channel *channel,
 	struct sk_buff *skb;
 
 	/* Allocate an SKB to store the headers */
-	skb = netdev_alloc_skb(efx->net_dev, hdr_len + EFX_PAGE_SKB_ALIGN);
+	skb = netdev_alloc_skb(efx->net_dev,
+			       efx->rx_ip_align + efx->rx_prefix_size +
+			       hdr_len);
 	if (unlikely(skb == NULL))
 		return NULL;
 
 	EFX_BUG_ON_PARANOID(rx_buf->len < hdr_len);
 
-	skb_reserve(skb, EFX_PAGE_SKB_ALIGN);
-	memcpy(__skb_put(skb, hdr_len), eh, hdr_len);
+	memcpy(skb->data + efx->rx_ip_align, eh - efx->rx_prefix_size,
+	       efx->rx_prefix_size + hdr_len);
+	skb_reserve(skb, efx->rx_ip_align + efx->rx_prefix_size);
+	__skb_put(skb, hdr_len);
 
 	/* Append the remaining page(s) onto the frag list */
 	if (rx_buf->len > hdr_len) {


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
