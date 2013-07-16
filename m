From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 3/9] sfc: Increase size of RX SKB header area
Date: Tue, 16 Jul 2013 21:57:05 +0100
Message-ID: <1374008225.2120.26.camel@bwh-desktop.uk.level5networks.com>
References: <1372104708.1896.29.camel@bwh-desktop.uk.level5networks.com>
	 <1372104801.1896.32.camel@bwh-desktop.uk.level5networks.com>
	 <1373996035.6097.5.camel@edumazet-glaptop>
	 <1373997228.2120.15.camel@bwh-desktop.uk.level5networks.com>
	 <1374006120.6097.6.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:44399 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933954Ab3GPU5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 16:57:09 -0400
In-Reply-To: <1374006120.6097.6.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-16 at 13:22 -0700, Eric Dumazet wrote:
> On Tue, 2013-07-16 at 18:53 +0100, Ben Hutchings wrote:
> 
> > Perhaps, yes.  I also thought of using some of the other parser status
> > from RX completions to estimate the length of headers.
> 
> That would be ideal indeed, I can provide a patch.

This is what I was intending to do, but it's untested.  It doesn't allow
for a VLAN tag, but that can be done by reading the RX_EV_PKT_TYPE field
in completions.

Ben.

Subject: WIP: sfc: Pull less data into header area in efx_rx_mk_skb()

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/net_driver.h |  2 ++
 drivers/net/ethernet/sfc/nic.c        |  3 +++
 drivers/net/ethernet/sfc/rx.c         | 34 ++++++++++++++++++++++++----------
 3 files changed, 29 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index f4c7e6b..cbcf709 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -243,6 +243,8 @@ struct efx_rx_buffer {
 #define EFX_RX_BUF_LAST_IN_PAGE	0x0001
 #define EFX_RX_PKT_CSUMMED	0x0002
 #define EFX_RX_PKT_DISCARD	0x0004
+#define EFX_RX_PKT_IPV4		0x0010
+#define EFX_RX_PKT_IPV6		0x0020
 #define EFX_RX_PKT_TCP		0x0040
 
 /**
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index 56ed3bc..b6ae31b 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -1093,6 +1093,9 @@ efx_handle_rx_event(struct efx_channel *channel, const efx_qword_t *event)
 			flags |= EFX_RX_PKT_CSUMMED;
 			/* fall through */
 		case FSE_CZ_RX_EV_HDR_TYPE_IPV4V6_OTHER:
+			flags |= EFX_QWORD_FIELD(*event, FSF_CZ_RX_EV_IPV6_PKT)
+				? EFX_RX_PKT_IPV6 : EFX_RX_PKT_IPV4;
+			break;
 		case FSE_AZ_RX_EV_HDR_TYPE_OTHER:
 			break;
 		}
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 65646cd..80bb7a5 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -451,25 +451,27 @@ efx_rx_packet_gro(struct efx_channel *channel, struct efx_rx_buffer *rx_buf,
 static struct sk_buff *efx_rx_mk_skb(struct efx_channel *channel,
 				     struct efx_rx_buffer *rx_buf,
 				     unsigned int n_frags,
-				     u8 *eh, int hdr_len)
+				     u8 *eh, int min_hdr_len,
+				     int max_hdr_len)
 {
 	struct efx_nic *efx = channel->efx;
 	struct sk_buff *skb;
 
 	/* Allocate an SKB to store the headers */
-	skb = netdev_alloc_skb(efx->net_dev, hdr_len + EFX_PAGE_SKB_ALIGN);
+	skb = netdev_alloc_skb(efx->net_dev, max_hdr_len + EFX_PAGE_SKB_ALIGN);
 	if (unlikely(skb == NULL))
 		return NULL;
 
-	EFX_BUG_ON_PARANOID(rx_buf->len < hdr_len);
+	EFX_BUG_ON_PARANOID(rx_buf->len < min_hdr_len);
+	EFX_BUG_ON_PARANOID(max_hdr_len < min_hdr_len);
 
 	skb_reserve(skb, EFX_PAGE_SKB_ALIGN);
-	memcpy(__skb_put(skb, hdr_len), eh, hdr_len);
+	memcpy(__skb_put(skb, min_hdr_len), eh, min_hdr_len);
 
 	/* Append the remaining page(s) onto the frag list */
-	if (rx_buf->len > hdr_len) {
-		rx_buf->page_offset += hdr_len;
-		rx_buf->len -= hdr_len;
+	if (rx_buf->len > min_hdr_len) {
+		rx_buf->page_offset += min_hdr_len;
+		rx_buf->len -= min_hdr_len;
 
 		for (;;) {
 			skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags,
@@ -587,9 +589,21 @@ static void efx_rx_deliver(struct efx_channel *channel, u8 *eh,
 			   unsigned int n_frags)
 {
 	struct sk_buff *skb;
-	u16 hdr_len = min_t(u16, rx_buf->len, EFX_SKB_HEADERS);
-
-	skb = efx_rx_mk_skb(channel, rx_buf, n_frags, eh, hdr_len);
+	int min_hdr_len = ETH_HLEN;
+ 
+	/* If the RX parser found an IPv4 or IPv6 header, assume we'll
+	 * need to pull that and at least another 8 bytes of transport
+	 * header.  TODO: should handle VLAN tag too
+	 */
+	if (rx_buf->flags & EFX_RX_PKT_IPV4)
+		min_hdr_len += sizeof(struct iphdr) + 8;
+	else if (rx_buf->flags & EFX_RX_PKT_IPV6)
+		min_hdr_len += sizeof(struct ipv6hdr) + 8;
+	if (unlikely(min_hdr_len) > rx_buf->len)
+		min_hdr_len = rx_buf->len;
+
+	skb = efx_rx_mk_skb(channel, rx_buf, n_frags, eh,
+			    min_hdr_len, EFX_SKB_HEADERS);
 	if (unlikely(skb == NULL)) {
 		efx_free_rx_buffer(rx_buf);
 		return;

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
