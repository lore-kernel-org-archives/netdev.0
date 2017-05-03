From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 11/15] netvsc: reduce unnecessary memset
Date: Wed,  3 May 2017 16:01:13 -0700
Message-ID: <20170503230117.20070-12-sthemmin@microsoft.com>
References: <20170503230117.20070-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:35978 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752514AbdECXBc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 19:01:32 -0400
Received: by mail-pg0-f43.google.com with SMTP id t7so1951337pgt.3
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 16:01:32 -0700 (PDT)
In-Reply-To: <20170503230117.20070-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only part of the headroom maybe used on typical packet. Avoid doing memset
of whole area.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index ef3a3a46790f..d9a690ad7cd5 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -195,6 +195,7 @@ static void *init_ppi_data(struct rndis_message *msg, u32 ppi_size,
 	ppi->size = ppi_size;
 	ppi->type = pkt_type;
 	ppi->ppi_offset = sizeof(struct rndis_per_packet_info);
+	memset(ppi + 1, 0, ppi_size - sizeof(struct rndis_per_packet_info));
 
 	rndis_pkt->per_pkt_info_len += ppi_size;
 
@@ -461,12 +462,12 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 
 	rndis_msg = (struct rndis_message *)skb->head;
 
-	memset(rndis_msg, 0, RNDIS_AND_PPI_SIZE);
-
 	/* Add the rndis header */
 	rndis_msg->ndis_msg_type = RNDIS_MSG_PACKET;
 	rndis_msg->msg_len = packet->total_data_buflen;
+
 	rndis_pkt = &rndis_msg->msg.pkt;
+	memset(rndis_pkt, 0, sizeof(*rndis_pkt));
 	rndis_pkt->data_offset = sizeof(struct rndis_packet);
 	rndis_pkt->data_len = packet->total_data_buflen;
 	rndis_pkt->per_pkt_info_offset = sizeof(struct rndis_packet);
-- 
2.11.0
