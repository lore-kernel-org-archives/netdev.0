From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net 1/8] sfc: Add length checks to efx_xmit_with_hwtstamp()
 and efx_ptp_is_ptp_tx()
Date: Wed, 11 Dec 2013 01:53:26 +0000
Message-ID: <1386726806.1516.237.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:40922 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750921Ab3LKBx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 20:53:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

efx_ptp_is_ptp_tx() must be robust against skbs from raw sockets that
have invalid IPv4 and UDP headers.

Add checks that:
- the transport header has been found
- there is enough space between network and transport header offset
  for an IPv4 header
- there is enough space after the transport header offset for a
  UDP header

Fixes: 7c236c43b838 ('sfc: Add support for IEEE-1588 PTP')
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ptp.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index 03acf57df045..93a61a157d10 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -989,7 +989,11 @@ bool efx_ptp_is_ptp_tx(struct efx_nic *efx, struct sk_buff *skb)
 		skb->len >= PTP_MIN_LENGTH &&
 		skb->len <= MC_CMD_PTP_IN_TRANSMIT_PACKET_MAXNUM &&
 		likely(skb->protocol == htons(ETH_P_IP)) &&
+		skb_transport_header_was_set(skb) &&
+		skb_network_header_len(skb) >= sizeof(struct iphdr) &&
 		ip_hdr(skb)->protocol == IPPROTO_UDP &&
+		skb_headlen(skb) >=
+		skb_transport_offset(skb) + sizeof(struct udphdr) &&
 		udp_hdr(skb)->dest == htons(PTP_EVENT_PORT);
 }
 


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
