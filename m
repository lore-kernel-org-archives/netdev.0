From: Blaschka <frank.blaschka@de.ibm.com>
Subject: [RFC] qeth: exploit gro for layer 3 driver
Date: Thu, 21 Jan 2010 13:37:22 +0100
Message-ID: <20100121123722.GA13815@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.17.166]:43993 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752241Ab0AUMhY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 07:37:24 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the qeth driver can not use NAPI I would like to hear
your opinion about following approach to exploit GRO.

The patch apply to net-next. To make it compile/work Dave's
commit 11380a4b2d86fae9a6bce75c9373668cc323fe57 has to be reverted.

There is following idea:

The inbound processing of the qeth driver is already in bottomhalf
(qdio input tasklet) so we can switch from netif_rx to
netif_receive_skb. This allows us to exploit gro code for the
layer 3 driver. I would introduce a dummy napi_struct and call
napi_gro_flush when the inbound tasklet ends.

We have to do some final performance measurements but a first try
looks promising.

Thanks,
  Frank

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core.h    |    1 +
 drivers/s390/net/qeth_l2_main.c |    2 +-
 drivers/s390/net/qeth_l3_main.c |    9 ++++++---
 3 files changed, 8 insertions(+), 4 deletions(-)

--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -739,6 +739,7 @@ struct qeth_card {
 	atomic_t force_alloc_skb;
 	struct service_level qeth_service_level;
 	struct qdio_ssqd_desc ssqd;
+	struct napi_struct napi;
 };
 
 struct qeth_card_list_struct {
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -431,7 +431,7 @@ static void qeth_l2_process_inbound_buff
 			if (skb->protocol == htons(ETH_P_802_2))
 				*((__u32 *)skb->cb) = ++card->seqno.pkt_seqno;
 			len = skb->len;
-			netif_rx(skb);
+			netif_receive_skb(skb);
 			break;
 		case QETH_HEADER_TYPE_OSN:
 			if (card->info.type == QETH_CARD_TYPE_OSN) {
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2106,14 +2106,14 @@ static void qeth_l3_process_inbound_buff
 			len = skb->len;
 			if (vlan_tag && !card->options.sniffer)
 				if (card->vlangrp)
-					vlan_hwaccel_rx(skb, card->vlangrp,
-						vlan_tag);
+					vlan_gro_receive(&card->napi,
+						card->vlangrp, vlan_tag, skb);
 				else {
 					dev_kfree_skb_any(skb);
 					continue;
 				}
 			else
-				netif_rx(skb);
+				napi_gro_receive(&card->napi, skb);
 			break;
 		case QETH_HEADER_TYPE_LAYER2: /* for HiperSockets sniffer */
 			skb->pkt_type = PACKET_HOST;
@@ -3245,6 +3245,8 @@ static int qeth_l3_setup_netdev(struct q
 				NETIF_F_HW_VLAN_FILTER;
 	card->dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
 	card->dev->gso_max_size = 15 * PAGE_SIZE;
+	/* dummy napi struct to use napi gro code */
+	netif_napi_add(card->dev, &card->napi, NULL, 64);
 
 	SET_NETDEV_DEV(card->dev, &card->gdev->dev);
 	return register_netdev(card->dev);
@@ -3286,6 +3288,7 @@ static void qeth_l3_qdio_input_handler(s
 		qeth_put_buffer_pool_entry(card, buffer->pool_entry);
 		qeth_queue_input_buffer(card, index);
 	}
+	napi_gro_flush(&card->napi);
 	if (card->options.performance_stats)
 		card->perf_stats.inbound_time += qeth_get_micros() -
 			card->perf_stats.inbound_start_time;


