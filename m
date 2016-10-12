From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net v2] netvsc: fix checksum on UDP IPV6
Date: Wed, 12 Oct 2016 09:58:14 -0700
Message-ID: <20161012095814.483fcbaa@xeon-e3>
References: <20161011140307.15fd390b@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
        "K. Y. Srinivasan" <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34759 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752511AbcJLQ6A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 12:58:00 -0400
Received: by mail-pf0-f178.google.com with SMTP id 190so21430629pfv.1
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 09:58:00 -0700 (PDT)
In-Reply-To: <20161011140307.15fd390b@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <sthemmin@microsoft.com>

The software calculation of UDP checksum in Netvsc driver was
only handling IPv4 case. Instead, use common code to recompute
checksum as needed for all protocols.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
v2 remove accidental udp.h inclusion

 drivers/net/hyperv/netvsc_drv.c | 71 ++++++++++++-----------------------------
 1 file changed, 21 insertions(+), 50 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 52eeb2f..f0919bd 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -442,8 +442,6 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 	}
 
 	net_trans_info = get_net_transport_info(skb, &hdr_offset);
-	if (net_trans_info == TRANSPORT_INFO_NOT_IP)
-		goto do_send;
 
 	/*
 	 * Setup the sendside checksum offload only if this is not a
@@ -478,56 +476,29 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 		}
 		lso_info->lso_v2_transmit.tcp_header_offset = hdr_offset;
 		lso_info->lso_v2_transmit.mss = skb_shinfo(skb)->gso_size;
-		goto do_send;
-	}
-
-	if ((skb->ip_summed == CHECKSUM_NONE) ||
-	    (skb->ip_summed == CHECKSUM_UNNECESSARY))
-		goto do_send;
-
-	rndis_msg_size += NDIS_CSUM_PPI_SIZE;
-	ppi = init_ppi_data(rndis_msg, NDIS_CSUM_PPI_SIZE,
-			    TCPIP_CHKSUM_PKTINFO);
-
-	csum_info = (struct ndis_tcp_ip_checksum_info *)((void *)ppi +
-			ppi->ppi_offset);
-
-	if (net_trans_info & (INFO_IPV4 << 16))
-		csum_info->transmit.is_ipv4 = 1;
-	else
-		csum_info->transmit.is_ipv6 = 1;
-
-	if (net_trans_info & INFO_TCP) {
-		csum_info->transmit.tcp_checksum = 1;
-		csum_info->transmit.tcp_header_offset = hdr_offset;
-	} else if (net_trans_info & INFO_UDP) {
-		/* UDP checksum offload is not supported on ws2008r2.
-		 * Furthermore, on ws2012 and ws2012r2, there are some
-		 * issues with udp checksum offload from Linux guests.
-		 * (these are host issues).
-		 * For now compute the checksum here.
-		 */
-		struct udphdr *uh;
-		u16 udp_len;
-
-		ret = skb_cow_head(skb, 0);
-		if (ret)
-			goto no_memory;
-
-		uh = udp_hdr(skb);
-		udp_len = ntohs(uh->len);
-		uh->check = 0;
-		uh->check = csum_tcpudp_magic(ip_hdr(skb)->saddr,
-					      ip_hdr(skb)->daddr,
-					      udp_len, IPPROTO_UDP,
-					      csum_partial(uh, udp_len, 0));
-		if (uh->check == 0)
-			uh->check = CSUM_MANGLED_0;
-
-		csum_info->transmit.udp_checksum = 0;
+	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		if (net_trans_info & INFO_TCP) {
+			rndis_msg_size += NDIS_CSUM_PPI_SIZE;
+			ppi = init_ppi_data(rndis_msg, NDIS_CSUM_PPI_SIZE,
+					    TCPIP_CHKSUM_PKTINFO);
+
+			csum_info = (struct ndis_tcp_ip_checksum_info *)((void *)ppi +
+									 ppi->ppi_offset);
+
+			if (net_trans_info & (INFO_IPV4 << 16))
+				csum_info->transmit.is_ipv4 = 1;
+			else
+				csum_info->transmit.is_ipv6 = 1;
+
+			csum_info->transmit.tcp_checksum = 1;
+			csum_info->transmit.tcp_header_offset = hdr_offset;
+		} else {
+			/* UDP checksum (and other) offload is not supported. */
+			if (skb_checksum_help(skb))
+				goto drop;
+		}
 	}
 
-do_send:
 	/* Start filling in the page buffers with the rndis hdr */
 	rndis_msg->msg_len += rndis_msg_size;
 	packet->total_data_buflen = rndis_msg->msg_len;
-- 
2.9.3
