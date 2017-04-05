From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 5/7] s390/qeth: improve endianness handling
Date: Wed,  5 Apr 2017 10:40:13 +0200
Message-ID: <20170405084015.35772-6-ubraun@linux.vnet.ibm.com>
References: <20170405084015.35772-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        jwi@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, raspl@linux.vnet.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:34326 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754299AbdDEIkf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 04:40:35 -0400
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v358d8wA135508
        for <netdev@vger.kernel.org>; Wed, 5 Apr 2017 04:40:35 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
        by mx0b-001b2d01.pphosted.com with ESMTP id 29mtpqpce3-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 05 Apr 2017 04:40:34 -0400
Received: from localhost
        by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Wed, 5 Apr 2017 09:40:30 +0100
In-Reply-To: <20170405084015.35772-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hans Wippel <hwippel@linux.vnet.ibm.com>

Avoid endianness warnings reported by sparse by (1) using endianness
conversions for assigning and using network packet fields, and (2)
removing unnecessary endianness conversions from qeth_l3_rebuild_skb. No
functional changes.

Signed-off-by: Hans Wippel <hwippel@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h      |  4 ++--
 drivers/s390/net/qeth_core_main.c | 11 +++++-----
 drivers/s390/net/qeth_l3_main.c   | 46 +++++++++++++++++++--------------------
 drivers/s390/net/qeth_l3_sys.c    |  4 ++--
 4 files changed, 33 insertions(+), 32 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index 22aa2cd..6764ab9 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -844,9 +844,9 @@ static inline int qeth_get_ip_version(struct sk_buff *skb)
 {
 	__be16 *p = &((struct ethhdr *)skb->data)->h_proto;
 
-	if (*p == ETH_P_8021Q)
+	if (be16_to_cpu(*p) == ETH_P_8021Q)
 		p += 2;
-	switch (*p) {
+	switch (be16_to_cpu(*p)) {
 	case ETH_P_IPV6:
 		return 6;
 	case ETH_P_IP:
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 194f9d8..e76b764 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -1201,7 +1201,7 @@ static void qeth_notify_skbs(struct qeth_qdio_out_q *q,
 	while (skb) {
 		QETH_CARD_TEXT_(q->card, 5, "skbn%d", notification);
 		QETH_CARD_TEXT_(q->card, 5, "%lx", (long) skb);
-		if (skb->protocol == ETH_P_AF_IUCV) {
+		if (be16_to_cpu(skb->protocol) == ETH_P_AF_IUCV) {
 			if (skb->sk) {
 				struct iucv_sock *iucv = iucv_sk(skb->sk);
 				iucv->sk_txnotify(skb, notification);
@@ -1232,7 +1232,8 @@ static void qeth_release_skbs(struct qeth_qdio_out_buffer *buf)
 	while (skb) {
 		QETH_CARD_TEXT(buf->q->card, 5, "skbr");
 		QETH_CARD_TEXT_(buf->q->card, 5, "%lx", (long) skb);
-		if (notify_general_error && skb->protocol == ETH_P_AF_IUCV) {
+		if (notify_general_error &&
+		    be16_to_cpu(skb->protocol) == ETH_P_AF_IUCV) {
 			if (skb->sk) {
 				iucv = iucv_sk(skb->sk);
 				iucv->sk_txnotify(skb, TX_NOTIFY_GENERALERROR);
@@ -3796,9 +3797,9 @@ int qeth_get_priority_queue(struct qeth_card *card, struct sk_buff *skb,
 		return qeth_cut_iqd_prio(card, ~skb->priority >> 1 & 3);
 	case QETH_PRIO_Q_ING_VLAN:
 		tci = &((struct ethhdr *)skb->data)->h_proto;
-		if (*tci == ETH_P_8021Q)
-			return qeth_cut_iqd_prio(card, ~*(tci + 1) >>
-			(VLAN_PRIO_SHIFT + 1) & 3);
+		if (be16_to_cpu(*tci) == ETH_P_8021Q)
+			return qeth_cut_iqd_prio(card,
+			~be16_to_cpu(*(tci + 1)) >> (VLAN_PRIO_SHIFT + 1) & 3);
 		break;
 	default:
 		break;
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 8de5f74..91060fb 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -1337,7 +1337,7 @@ qeth_diags_trace(struct qeth_card *card, enum qeth_diags_trace_cmds diags_cmd)
 	return qeth_send_ipa_cmd(card, iob, qeth_diags_trace_cb, NULL);
 }
 
-static void qeth_l3_get_mac_for_ipm(__u32 ipm, char *mac)
+static void qeth_l3_get_mac_for_ipm(__be32 ipm, char *mac)
 {
 	ip_eth_mc_map(ipm, mac);
 }
@@ -1410,7 +1410,7 @@ qeth_l3_add_mc_to_hash(struct qeth_card *card, struct in_device *in4_dev)
 	     im4 = rcu_dereference(im4->next_rcu)) {
 		qeth_l3_get_mac_for_ipm(im4->multiaddr, buf);
 
-		tmp->u.a4.addr = im4->multiaddr;
+		tmp->u.a4.addr = be32_to_cpu(im4->multiaddr);
 		memcpy(tmp->mac, buf, sizeof(tmp->mac));
 
 		ipm = qeth_l3_ip_from_hash(card, tmp);
@@ -1421,7 +1421,7 @@ qeth_l3_add_mc_to_hash(struct qeth_card *card, struct in_device *in4_dev)
 			if (!ipm)
 				continue;
 			memcpy(ipm->mac, buf, sizeof(tmp->mac));
-			ipm->u.a4.addr = im4->multiaddr;
+			ipm->u.a4.addr = be32_to_cpu(im4->multiaddr);
 			ipm->is_multicast = 1;
 			ipm->disp_flag = QETH_DISP_ADDR_ADD;
 			hash_add(card->ip_mc_htable,
@@ -1594,8 +1594,8 @@ static void qeth_l3_free_vlan_addresses4(struct qeth_card *card,
 	spin_lock_bh(&card->ip_lock);
 
 	for (ifa = in_dev->ifa_list; ifa; ifa = ifa->ifa_next) {
-		addr->u.a4.addr = ifa->ifa_address;
-		addr->u.a4.mask = ifa->ifa_mask;
+		addr->u.a4.addr = be32_to_cpu(ifa->ifa_address);
+		addr->u.a4.mask = be32_to_cpu(ifa->ifa_mask);
 		addr->type = QETH_IP_TYPE_NORMAL;
 		qeth_l3_delete_ip(card, addr);
 	}
@@ -1686,25 +1686,25 @@ static inline int qeth_l3_rebuild_skb(struct qeth_card *card,
 			struct sk_buff *skb, struct qeth_hdr *hdr,
 			unsigned short *vlan_id)
 {
-	__be16 prot;
+	__u16 prot;
 	struct iphdr *ip_hdr;
 	unsigned char tg_addr[MAX_ADDR_LEN];
 	int is_vlan = 0;
 
 	if (!(hdr->hdr.l3.flags & QETH_HDR_PASSTHRU)) {
-		prot = htons((hdr->hdr.l3.flags & QETH_HDR_IPV6)? ETH_P_IPV6 :
-			      ETH_P_IP);
+		prot = (hdr->hdr.l3.flags & QETH_HDR_IPV6) ? ETH_P_IPV6 :
+			      ETH_P_IP;
 		switch (hdr->hdr.l3.flags & QETH_HDR_CAST_MASK) {
 		case QETH_CAST_MULTICAST:
 			switch (prot) {
 #ifdef CONFIG_QETH_IPV6
-			case __constant_htons(ETH_P_IPV6):
+			case ETH_P_IPV6:
 				ndisc_mc_map((struct in6_addr *)
 				     skb->data + 24,
 				     tg_addr, card->dev, 0);
 				break;
 #endif
-			case __constant_htons(ETH_P_IP):
+			case ETH_P_IP:
 				ip_hdr = (struct iphdr *)skb->data;
 				ip_eth_mc_map(ip_hdr->daddr, tg_addr);
 				break;
@@ -1791,7 +1791,7 @@ static int qeth_l3_process_inbound_buffer(struct qeth_card *card,
 			magic = *(__u16 *)skb->data;
 			if ((card->info.type == QETH_CARD_TYPE_IQD) &&
 			    (magic == ETH_P_AF_IUCV)) {
-				skb->protocol = ETH_P_AF_IUCV;
+				skb->protocol = cpu_to_be16(ETH_P_AF_IUCV);
 				skb->pkt_type = PACKET_HOST;
 				skb->mac_header = NET_SKB_PAD;
 				skb->dev = card->dev;
@@ -2568,10 +2568,10 @@ int inline qeth_l3_get_cast_type(struct qeth_card *card, struct sk_buff *skb)
 	rcu_read_unlock();
 
 	/* try something else */
-	if (skb->protocol == ETH_P_IPV6)
+	if (be16_to_cpu(skb->protocol) == ETH_P_IPV6)
 		return (skb_network_header(skb)[24] == 0xff) ?
 				RTN_MULTICAST : 0;
-	else if (skb->protocol == ETH_P_IP)
+	else if (be16_to_cpu(skb->protocol) == ETH_P_IP)
 		return ((skb_network_header(skb)[16] & 0xf0) == 0xe0) ?
 				RTN_MULTICAST : 0;
 	/* ... */
@@ -2726,7 +2726,7 @@ static void qeth_tso_fill_header(struct qeth_card *card,
 	hdr->ext.payload_len = (__u16)(skb->len - hdr->ext.dg_hdr_len -
 				       sizeof(struct qeth_hdr_tso));
 	tcph->check = 0;
-	if (skb->protocol == ETH_P_IPV6) {
+	if (be16_to_cpu(skb->protocol) == ETH_P_IPV6) {
 		ip6h->payload_len = 0;
 		tcph->check = ~csum_ipv6_magic(&ip6h->saddr, &ip6h->daddr,
 					       0, IPPROTO_TCP, 0);
@@ -2773,7 +2773,7 @@ static int qeth_l3_get_elements_no_tso(struct qeth_card *card,
 static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	int rc;
-	u16 *tag;
+	__be16 *tag;
 	struct qeth_hdr *hdr = NULL;
 	int hdr_elements = 0;
 	int elements;
@@ -2794,7 +2794,7 @@ static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (((card->info.type == QETH_CARD_TYPE_IQD) &&
 	     (((card->options.cq != QETH_CQ_ENABLED) && !ipv) ||
 	      ((card->options.cq == QETH_CQ_ENABLED) &&
-	       (skb->protocol != ETH_P_AF_IUCV)))) ||
+	       (be16_to_cpu(skb->protocol) != ETH_P_AF_IUCV)))) ||
 	    card->options.sniffer)
 			goto tx_drop;
 
@@ -2819,7 +2819,7 @@ static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if ((card->info.type == QETH_CARD_TYPE_IQD) &&
 	    !skb_is_nonlinear(skb)) {
 		new_skb = skb;
-		if (new_skb->protocol == ETH_P_AF_IUCV)
+		if (be16_to_cpu(new_skb->protocol) == ETH_P_AF_IUCV)
 			data_offset = 0;
 		else
 			data_offset = ETH_HLEN;
@@ -2850,9 +2850,9 @@ static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 				new_skb->data + 8, 4);
 			skb_copy_to_linear_data_offset(new_skb, 8,
 				new_skb->data + 12, 4);
-			tag = (u16 *)(new_skb->data + 12);
-			*tag = __constant_htons(ETH_P_8021Q);
-			*(tag + 1) = htons(skb_vlan_tag_get(new_skb));
+			tag = (__be16 *)(new_skb->data + 12);
+			*tag = cpu_to_be16(ETH_P_8021Q);
+			*(tag + 1) = cpu_to_be16(skb_vlan_tag_get(new_skb));
 		}
 	}
 
@@ -2890,7 +2890,7 @@ static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			qeth_l3_fill_header(card, hdr, new_skb, ipv,
 						cast_type);
 		} else {
-			if (new_skb->protocol == ETH_P_AF_IUCV)
+			if (be16_to_cpu(new_skb->protocol) == ETH_P_AF_IUCV)
 				qeth_l3_fill_af_iucv_hdr(card, hdr, new_skb);
 			else {
 				qeth_l3_fill_header(card, hdr, new_skb, ipv,
@@ -3468,8 +3468,8 @@ static int qeth_l3_ip_event(struct notifier_block *this,
 
 	addr = qeth_l3_get_addr_buffer(QETH_PROT_IPV4);
 	if (addr) {
-		addr->u.a4.addr = ifa->ifa_address;
-		addr->u.a4.mask = ifa->ifa_mask;
+		addr->u.a4.addr = be32_to_cpu(ifa->ifa_address);
+		addr->u.a4.mask = be32_to_cpu(ifa->ifa_mask);
 		addr->type = QETH_IP_TYPE_NORMAL;
 	} else
 		return NOTIFY_DONE;
diff --git a/drivers/s390/net/qeth_l3_sys.c b/drivers/s390/net/qeth_l3_sys.c
index 05e9471..ff29a4b 100644
--- a/drivers/s390/net/qeth_l3_sys.c
+++ b/drivers/s390/net/qeth_l3_sys.c
@@ -286,7 +286,7 @@ static ssize_t qeth_l3_dev_hsuid_store(struct device *dev,
 		if (!addr)
 			return -ENOMEM;
 
-		addr->u.a6.addr.s6_addr32[0] = 0xfe800000;
+		addr->u.a6.addr.s6_addr32[0] = cpu_to_be32(0xfe800000);
 		addr->u.a6.addr.s6_addr32[1] = 0x00000000;
 		for (i = 8; i < 16; i++)
 			addr->u.a6.addr.s6_addr[i] =
@@ -320,7 +320,7 @@ static ssize_t qeth_l3_dev_hsuid_store(struct device *dev,
 
 	addr = qeth_l3_get_addr_buffer(QETH_PROT_IPV6);
 	if (addr != NULL) {
-		addr->u.a6.addr.s6_addr32[0] = 0xfe800000;
+		addr->u.a6.addr.s6_addr32[0] = cpu_to_be32(0xfe800000);
 		addr->u.a6.addr.s6_addr32[1] = 0x00000000;
 		for (i = 8; i < 16; i++)
 			addr->u.a6.addr.s6_addr[i] = card->options.hsuid[i - 8];
-- 
2.10.2
