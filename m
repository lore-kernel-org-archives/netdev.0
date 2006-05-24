From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 3/5] s390: qeth driver fixes
Date: Wed, 24 May 2006 09:51:13 +0200
Message-ID: <20060524095113.5f4dfd9f@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:40946 "EHLO
	mtagate1.de.ibm.com") by vger.kernel.org with ESMTP id S932649AbWEXHuu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 May 2006 03:50:50 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.6/8.13.6) with ESMTP id k4O7omN3081082
	for <netdev@vger.kernel.org>; Wed, 24 May 2006 07:50:48 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k4O7qRkc153070
	for <netdev@vger.kernel.org>; Wed, 24 May 2006 09:52:27 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k4O7om9O029118
	for <netdev@vger.kernel.org>; Wed, 24 May 2006 09:50:48 +0200
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Ursula Braun <braunu@de.ibm.com>
From: Frank Blaschka <Frank.Blaschka@de.ibm.com>
From: Frank Pavlic <fpavlic@de.ibm.com>

        - fix fake_ll during initial device bringup. fake_ll was 
	  not active after first start of the device. 
	  Problem only occured when qeth was built without IPV6 support.
        - avoid skb usage after invocation of qeth_flush_buffers, 
	  because skb might already be freed. 
        - remove yet another useless netif_wake_queue in
	  qeth_softsetup_ipv6 since this function is only called
	  when device is going online. In this case card->state will
	  never be in state UP. So let the net_device queue down .

Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>

---

 drivers/s390/net/qeth_main.c |   23 +++++++++++++----------
 1 files changed, 13 insertions(+), 10 deletions(-)

e32bb8db95c84a0af8c5688b92ed6691982e4f9c
diff --git a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
index 0f6648f..9dbb5be 100644
--- a/drivers/s390/net/qeth_main.c
+++ b/drivers/s390/net/qeth_main.c
@@ -3798,11 +3798,11 @@ qeth_open(struct net_device *dev)
 		QETH_DBF_TEXT(trace,4,"nomacadr");
 		return -EPERM;
 	}
-	card->dev->flags |= IFF_UP;
-	netif_start_queue(dev);
 	card->data.state = CH_STATE_UP;
 	card->state = CARD_STATE_UP;
-
+	card->dev->flags |= IFF_UP;
+	netif_start_queue(dev);
+	
 	if (!card->lan_online && netif_carrier_ok(dev))
 		netif_carrier_off(dev);
 	return 0;
@@ -3958,7 +3958,7 @@ qeth_prepare_skb(struct qeth_card *card,
 #endif
 	*hdr = (struct qeth_hdr *)
 		qeth_push_skb(card, skb, sizeof(struct qeth_hdr));
-	if (hdr == NULL)
+	if (*hdr == NULL)
 		return -EINVAL;
 	return 0;
 }
@@ -4416,6 +4416,8 @@ qeth_send_packet(struct qeth_card *card,
 	enum qeth_large_send_types large_send = QETH_LARGE_SEND_NO;
 	struct qeth_eddp_context *ctx = NULL;
 	int tx_bytes = skb->len;
+	unsigned short nr_frags = skb_shinfo(skb)->nr_frags;
+	unsigned short tso_size = skb_shinfo(skb)->tso_size;
 	int rc;
 
 	QETH_DBF_TEXT(trace, 6, "sendpkt");
@@ -4498,16 +4500,16 @@ qeth_send_packet(struct qeth_card *card,
 		card->stats.tx_packets++;
 		card->stats.tx_bytes += tx_bytes;
 #ifdef CONFIG_QETH_PERF_STATS
-		if (skb_shinfo(skb)->tso_size &&
+		if (tso_size &&
 		   !(large_send == QETH_LARGE_SEND_NO)) {
-			card->perf_stats.large_send_bytes += skb->len;
+			card->perf_stats.large_send_bytes += tx_bytes;
 			card->perf_stats.large_send_cnt++;
 		}
- 		if (skb_shinfo(skb)->nr_frags > 0){
+ 		if (nr_frags > 0){
 			card->perf_stats.sg_skbs_sent++;
 			/* nr_frags + skb->data */
 			card->perf_stats.sg_frags_sent +=
-				skb_shinfo(skb)->nr_frags + 1;
+				nr_frags + 1;
 		}
 #endif /* CONFIG_QETH_PERF_STATS */
 	}
@@ -6370,6 +6372,9 @@ qeth_netdev_init(struct net_device *dev)
 	if (!(card->info.unique_id & UNIQUE_ID_NOT_BY_CARD))
 		card->dev->dev_id = card->info.unique_id & 0xffff;
 #endif
+	if (card->options.fake_ll && 
+		(qeth_get_netdev_flags(card) & IFF_NOARP))
+			dev->hard_header = qeth_fake_header;
 	dev->hard_header_parse = NULL;
 	dev->set_mac_address = qeth_layer2_set_mac_address;
 	dev->flags |= qeth_get_netdev_flags(card);
@@ -7031,14 +7036,12 @@ qeth_softsetup_ipv6(struct qeth_card *ca
 
 	QETH_DBF_TEXT(trace,3,"softipv6");
 
-	netif_tx_disable(card->dev);
 	rc = qeth_send_startlan(card, QETH_PROT_IPV6);
 	if (rc) {
 		PRINT_ERR("IPv6 startlan failed on %s\n",
 			  QETH_CARD_IFNAME(card));
 		return rc;
 	}
-	netif_wake_queue(card->dev);
 	rc = qeth_query_ipassists(card,QETH_PROT_IPV6);
 	if (rc) {
 		PRINT_ERR("IPv6 query ipassist failed on %s\n",
-- 
1.2.4

