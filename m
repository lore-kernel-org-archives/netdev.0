From: frank.blaschka@de.ibm.com
Subject: [patch 2/5] [PATCH] qeth: l3 send dhcp in non pass thru mode
Date: Tue, 09 Mar 2010 07:36:54 +0100
Message-ID: <20100309063936.560827000@de.ibm.com>
References: <20100309063652.706791000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.17.162]:35966 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751791Ab0CIGji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Mar 2010 01:39:38 -0500
Content-Disposition: inline; filename=602-qeth-dhcp.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

dhcp frames are valid IPv4 packets so there is no need to send them
in pass thru mode. This allows dhcp packets to pass HiperSockets.
Also the dhcp release frame is send out correctly with this patch.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---

 drivers/s390/net/qeth_core.h    |    3 ++-
 drivers/s390/net/qeth_l3_main.c |   10 ++++------
 2 files changed, 6 insertions(+), 7 deletions(-)

--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -763,7 +763,8 @@ static inline int qeth_get_micros(void)
 
 static inline int qeth_get_ip_version(struct sk_buff *skb)
 {
-	switch (skb->protocol) {
+	struct ethhdr *ehdr = (struct ethhdr *)skb->data;
+	switch (ehdr->h_proto) {
 	case ETH_P_IPV6:
 		return 6;
 	case ETH_P_IP:
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2900,10 +2900,8 @@ static int qeth_l3_hard_start_xmit(struc
 	int data_offset = -1;
 	int nr_frags;
 
-	if ((card->info.type == QETH_CARD_TYPE_IQD) &&
-	    (((skb->protocol != htons(ETH_P_IPV6)) &&
-	      (skb->protocol != htons(ETH_P_IP))) ||
-	     card->options.sniffer))
+	if (((card->info.type == QETH_CARD_TYPE_IQD) && (!ipv)) ||
+	     card->options.sniffer)
 			goto tx_drop;
 
 	if ((card->state != CARD_STATE_UP) || !card->lan_online) {
@@ -2949,14 +2947,14 @@ static int qeth_l3_hard_start_xmit(struc
 		if (data_offset < 0)
 			skb_pull(new_skb, ETH_HLEN);
 	} else {
-		if (new_skb->protocol == htons(ETH_P_IP)) {
+		if (ipv == 4) {
 			if (card->dev->type == ARPHRD_IEEE802_TR)
 				skb_pull(new_skb, TR_HLEN);
 			else
 				skb_pull(new_skb, ETH_HLEN);
 		}
 
-		if (new_skb->protocol == ETH_P_IPV6 && card->vlangrp &&
+		if (ipv == 6 && card->vlangrp &&
 				vlan_tx_tag_present(new_skb)) {
 			skb_push(new_skb, VLAN_HLEN);
 			skb_copy_to_linear_data(new_skb, new_skb->data + 4, 4);

