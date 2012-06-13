From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH v2 net-next v3 3/3] 6lowpan: remove excessive argument in pr_debug
Date: Wed, 13 Jun 2012 12:38:01 +0400
Message-ID: <1339576681-8916-1-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1339254789-10712-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: joe@perches.com, netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:64510 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751242Ab2FMIkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 04:40:51 -0400
Received: by bkcji2 with SMTP id ji2so244990bkc.19
        for <netdev@vger.kernel.org>; Wed, 13 Jun 2012 01:40:49 -0700 (PDT)
In-Reply-To: <1339254789-10712-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove excessive __func__ argument in pr_debug function and some
excessive debug messages.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/ieee802154/6lowpan.c |   94 ++++++++++++++++++----------------------------
 1 files changed, 37 insertions(+), 57 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index b45e229..ad0c226 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -240,8 +240,7 @@ lowpan_uncompress_addr(struct sk_buff *skb, struct in6_addr *ipaddr,
 		lowpan_uip_ds6_set_addr_iid(ipaddr, lladdr);
 	}
 
-	pr_debug("(%s): uncompressing %d + %d => ", __func__, prefcount,
-								postcount);
+	pr_debug("uncompressing %d + %d => ", prefcount, postcount);
 	lowpan_raw_dump_inline(NULL, NULL, ipaddr->s6_addr, 16);
 
 	return 0;
@@ -252,13 +251,11 @@ lowpan_compress_udp_header(u8 **hc06_ptr, struct sk_buff *skb)
 {
 	struct udphdr *uh = udp_hdr(skb);
 
-	pr_debug("(%s): UDP header compression\n", __func__);
-
 	if (((uh->source & LOWPAN_NHC_UDP_4BIT_MASK) ==
 				LOWPAN_NHC_UDP_4BIT_PORT) &&
 	    ((uh->dest & LOWPAN_NHC_UDP_4BIT_MASK) ==
 				LOWPAN_NHC_UDP_4BIT_PORT)) {
-		pr_debug("(%s): both ports compression to 4 bits\n", __func__);
+		pr_debug("UDP header: both ports compression to 4 bits\n");
 		**hc06_ptr = LOWPAN_NHC_UDP_CS_P_11;
 		**(hc06_ptr + 1) = /* subtraction is faster */
 		   (u8)((uh->dest - LOWPAN_NHC_UDP_4BIT_PORT) +
@@ -266,20 +263,20 @@ lowpan_compress_udp_header(u8 **hc06_ptr, struct sk_buff *skb)
 		*hc06_ptr += 2;
 	} else if ((uh->dest & LOWPAN_NHC_UDP_8BIT_MASK) ==
 			LOWPAN_NHC_UDP_8BIT_PORT) {
-		pr_debug("(%s): remove 8 bits of dest\n", __func__);
+		pr_debug("UDP header: remove 8 bits of dest\n");
 		**hc06_ptr = LOWPAN_NHC_UDP_CS_P_01;
 		memcpy(*hc06_ptr + 1, &uh->source, 2);
 		**(hc06_ptr + 3) = (u8)(uh->dest - LOWPAN_NHC_UDP_8BIT_PORT);
 		*hc06_ptr += 4;
 	} else if ((uh->source & LOWPAN_NHC_UDP_8BIT_MASK) ==
 			LOWPAN_NHC_UDP_8BIT_PORT) {
-		pr_debug("(%s): remove 8 bits of source\n", __func__);
+		pr_debug("UDP header: remove 8 bits of source\n");
 		**hc06_ptr = LOWPAN_NHC_UDP_CS_P_10;
 		memcpy(*hc06_ptr + 1, &uh->dest, 2);
 		**(hc06_ptr + 3) = (u8)(uh->source - LOWPAN_NHC_UDP_8BIT_PORT);
 		*hc06_ptr += 4;
 	} else {
-		pr_debug("(%s): can't compress header\n", __func__);
+		pr_debug("UDP header: can't compress\n");
 		**hc06_ptr = LOWPAN_NHC_UDP_CS_P_00;
 		memcpy(*hc06_ptr + 1, &uh->source, 2);
 		memcpy(*hc06_ptr + 3, &uh->dest, 2);
@@ -323,7 +320,7 @@ lowpan_uncompress_udp_header(struct sk_buff *skb)
 		goto err;
 
 	if ((tmp & LOWPAN_NHC_UDP_MASK) == LOWPAN_NHC_UDP_ID) {
-		pr_debug("(%s): UDP header uncompression\n", __func__);
+		pr_debug("UDP header uncompression\n");
 		switch (tmp & LOWPAN_NHC_UDP_CS_P_11) {
 		case LOWPAN_NHC_UDP_CS_P_00:
 			memcpy(&uh->source, &skb->data[0], 2);
@@ -349,19 +346,19 @@ lowpan_uncompress_udp_header(struct sk_buff *skb)
 			skb_pull(skb, 1);
 			break;
 		default:
-			pr_debug("(%s) ERROR: unknown UDP format\n", __func__);
+			pr_debug("ERROR: unknown UDP format\n");
 			goto err;
 			break;
 		}
 
-		pr_debug("(%s): uncompressed UDP ports: src = %d, dst = %d\n",
-					__func__, uh->source, uh->dest);
+		pr_debug("uncompressed UDP ports: src = %d, dst = %d\n",
+			 uh->source, uh->dest);
 
 		/* copy checksum */
 		memcpy(&uh->check, &skb->data[0], 2);
 		skb_pull(skb, 2);
 	} else {
-		pr_debug("(%s): ERROR: unsupported NH format\n", __func__);
+		pr_debug("ERROR: unsupported NH format\n");
 		goto err;
 	}
 
@@ -394,10 +391,9 @@ static int lowpan_header_create(struct sk_buff *skb,
 	hdr = ipv6_hdr(skb);
 	hc06_ptr = head + 2;
 
-	pr_debug("(%s): IPv6 header dump:\n\tversion = %d\n\tlength  = %d\n"
-		 "\tnexthdr = 0x%02x\n\thop_lim = %d\n", __func__,
-		hdr->version, ntohs(hdr->payload_len), hdr->nexthdr,
-		hdr->hop_limit);
+	pr_debug("IPv6 header dump:\n\tversion = %d\n\tlength  = %d\n"
+		 "\tnexthdr = 0x%02x\n\thop_lim = %d\n", hdr->version,
+		 ntohs(hdr->payload_len), hdr->nexthdr, hdr->hop_limit);
 
 	lowpan_raw_dump_table(__func__, "raw skb network header dump",
 		skb_network_header(skb), sizeof(struct ipv6hdr));
@@ -498,23 +494,22 @@ static int lowpan_header_create(struct sk_buff *skb,
 
 	/* source address compression */
 	if (is_addr_unspecified(&hdr->saddr)) {
-		pr_debug("(%s): source address is unspecified, setting SAC\n",
-								__func__);
+		pr_debug("source address is unspecified, setting SAC\n");
 		iphc1 |= LOWPAN_IPHC_SAC;
 	/* TODO: context lookup */
 	} else if (is_addr_link_local(&hdr->saddr)) {
-		pr_debug("(%s): source address is link-local\n", __func__);
+		pr_debug("source address is link-local\n");
 		iphc1 |= lowpan_compress_addr_64(&hc06_ptr,
 				LOWPAN_IPHC_SAM_BIT, &hdr->saddr, saddr);
 	} else {
-		pr_debug("(%s): send the full source address\n", __func__);
+		pr_debug("send the full source address\n");
 		memcpy(hc06_ptr, &hdr->saddr.s6_addr16[0], 16);
 		hc06_ptr += 16;
 	}
 
 	/* destination address compression */
 	if (is_addr_mcast(&hdr->daddr)) {
-		pr_debug("(%s): destination address is multicast", __func__);
+		pr_debug("destination address is multicast: ");
 		iphc1 |= LOWPAN_IPHC_M;
 		if (lowpan_is_mcast_addr_compressable8(&hdr->daddr)) {
 			pr_debug("compressed to 1 octet\n");
@@ -543,14 +538,13 @@ static int lowpan_header_create(struct sk_buff *skb,
 			hc06_ptr += 16;
 		}
 	} else {
-		pr_debug("(%s): destination address is unicast: ", __func__);
 		/* TODO: context lookup */
 		if (is_addr_link_local(&hdr->daddr)) {
-			pr_debug("destination address is link-local\n");
+			pr_debug("dest address is unicast and link-local\n");
 			iphc1 |= lowpan_compress_addr_64(&hc06_ptr,
 				LOWPAN_IPHC_DAM_BIT, &hdr->daddr, daddr);
 		} else {
-			pr_debug("using full address\n");
+			pr_debug("dest address is unicast: using full one\n");
 			memcpy(hc06_ptr, &hdr->daddr.s6_addr16[0], 16);
 			hc06_ptr += 16;
 		}
@@ -642,8 +636,7 @@ static void lowpan_fragment_timer_expired(unsigned long entry_addr)
 {
 	struct lowpan_fragment *entry = (struct lowpan_fragment *)entry_addr;
 
-	pr_debug("%s: timer expired for frame with tag %d\n", __func__,
-								entry->tag);
+	pr_debug("timer expired for frame with tag %d\n", entry->tag);
 
 	spin_lock(&flist_lock);
 	list_del(&entry->list);
@@ -796,12 +789,11 @@ lowpan_process_data(struct sk_buff *skb)
 	_saddr = mac_cb(skb)->sa.hwaddr;
 	_daddr = mac_cb(skb)->da.hwaddr;
 
-	pr_debug("(%s): iphc0 = %02x, iphc1 = %02x\n", __func__, iphc0, iphc1);
+	pr_debug("iphc0 = %02x, iphc1 = %02x\n", iphc0, iphc1);
 
 	/* another if the CID flag is set */
 	if (iphc1 & LOWPAN_IPHC_CID) {
-		pr_debug("(%s): CID flag is set, increase header with one\n",
-								__func__);
+		pr_debug("CID flag is set, increase header with one\n");
 		if (lowpan_fetch_skb_u8(skb, &num_context))
 			goto drop;
 	}
@@ -866,8 +858,8 @@ lowpan_process_data(struct sk_buff *skb)
 		if (lowpan_fetch_skb_u8(skb, &(hdr.nexthdr)))
 			goto drop;
 
-		pr_debug("(%s): NH flag is set, next header is carried "
-			 "inline: %02x\n", __func__, hdr.nexthdr);
+		pr_debug("NH flag is set, next header carried inline: %02x\n",
+			 hdr.nexthdr);
 	}
 
 	/* Hop Limit */
@@ -882,7 +874,7 @@ lowpan_process_data(struct sk_buff *skb)
 	tmp = ((iphc1 & LOWPAN_IPHC_SAM) >> LOWPAN_IPHC_SAM_BIT) & 0x03;
 
 	/* Source address uncompression */
-	pr_debug("(%s): source address stateless compression\n", __func__);
+	pr_debug("source address stateless compression\n");
 	err = lowpan_uncompress_addr(skb, &hdr.saddr, lowpan_llprefix,
 				lowpan_unc_llconf[tmp], skb->data);
 	if (err)
@@ -894,14 +886,12 @@ lowpan_process_data(struct sk_buff *skb)
 	/* check for Multicast Compression */
 	if (iphc1 & LOWPAN_IPHC_M) {
 		if (iphc1 & LOWPAN_IPHC_DAC) {
-			pr_debug("(%s): destination address context-based "
-				 "multicast compression\n", __func__);
+			pr_debug("dest: context-based mcast compression\n");
 			/* TODO: implement this */
 		} else {
 			u8 prefix[] = {0xff, 0x02};
 
-			pr_debug("(%s): destination address non-context-based"
-				 " multicast compression\n", __func__);
+			pr_debug("dest: non context-based mcast compression\n");
 			if (0 < tmp && tmp < 3) {
 				if (lowpan_fetch_skb_u8(skb, &prefix[1]))
 					goto drop;
@@ -913,8 +903,7 @@ lowpan_process_data(struct sk_buff *skb)
 				goto drop;
 		}
 	} else {
-		pr_debug("(%s): destination address stateless compression\n",
-								__func__);
+		pr_debug("dest: stateless compression\n");
 		err = lowpan_uncompress_addr(skb, &hdr.daddr, lowpan_llprefix,
 				lowpan_unc_llconf[tmp], skb->data);
 		if (err)
@@ -929,11 +918,11 @@ lowpan_process_data(struct sk_buff *skb)
 	/* Not fragmented package */
 	hdr.payload_len = htons(skb->len);
 
-	pr_debug("(%s): skb headroom size = %d, data length = %d\n", __func__,
-						skb_headroom(skb), skb->len);
+	pr_debug("skb headroom size = %d, data length = %d\n",
+		 skb_headroom(skb), skb->len);
 
-	pr_debug("(%s): IPv6 header dump:\n\tversion = %d\n\tlength  = %d\n\t"
-		 "nexthdr = 0x%02x\n\thop_lim = %d\n", __func__, hdr.version,
+	pr_debug("IPv6 header dump:\n\tversion = %d\n\tlength  = %d\n\t"
+		 "nexthdr = 0x%02x\n\thop_lim = %d\n", hdr.version,
 		 ntohs(hdr.payload_len), hdr.nexthdr, hdr.hop_limit);
 
 	lowpan_raw_dump_table(__func__, "raw header dump", (u8 *)&hdr,
@@ -1035,11 +1024,11 @@ static netdev_tx_t lowpan_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	int err = -1;
 
-	pr_debug("(%s): package xmit\n", __func__);
+	pr_debug("package xmit\n");
 
 	skb->dev = lowpan_dev_info(dev)->real_dev;
 	if (skb->dev == NULL) {
-		pr_debug("(%s) ERROR: no real wpan device found\n", __func__);
+		pr_debug("ERROR: no real wpan device found\n");
 		goto error;
 	}
 
@@ -1048,14 +1037,13 @@ static netdev_tx_t lowpan_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto out;
 	}
 
-	pr_debug("(%s): frame is too big, fragmentation is needed\n",
-								__func__);
+	pr_debug("frame is too big, fragmentation is needed\n");
 	err = lowpan_skb_fragmentation(skb);
 error:
 	dev_kfree_skb(skb);
 out:
 	if (err < 0)
-		pr_debug("(%s): ERROR: xmit failed\n", __func__);
+		pr_debug("ERROR: xmit failed\n");
 
 	return (err < 0 ? NETDEV_TX_BUSY : NETDEV_TX_OK);
 }
@@ -1101,8 +1089,6 @@ static struct ieee802154_mlme_ops lowpan_mlme = {
 
 static void lowpan_setup(struct net_device *dev)
 {
-	pr_debug("(%s)\n", __func__);
-
 	dev->addr_len		= IEEE802154_ADDR_LEN;
 	memset(dev->broadcast, 0xff, IEEE802154_ADDR_LEN);
 	dev->type		= ARPHRD_IEEE802154;
@@ -1122,8 +1108,6 @@ static void lowpan_setup(struct net_device *dev)
 
 static int lowpan_validate(struct nlattr *tb[], struct nlattr *data[])
 {
-	pr_debug("(%s)\n", __func__);
-
 	if (tb[IFLA_ADDRESS]) {
 		if (nla_len(tb[IFLA_ADDRESS]) != IEEE802154_ADDR_LEN)
 			return -EINVAL;
@@ -1164,7 +1148,7 @@ static int lowpan_newlink(struct net *src_net, struct net_device *dev,
 	struct net_device *real_dev;
 	struct lowpan_dev_record *entry;
 
-	pr_debug("(%s)\n", __func__);
+	pr_debug("adding new link\n");
 
 	if (!tb[IFLA_LINK])
 		return -EINVAL;
@@ -1259,8 +1243,6 @@ static int __init lowpan_init_module(void)
 {
 	int err = 0;
 
-	pr_debug("(%s)\n", __func__);
-
 	err = lowpan_netlink_init();
 	if (err < 0)
 		goto out;
@@ -1272,8 +1254,6 @@ out:
 
 static void __exit lowpan_cleanup_module(void)
 {
-	pr_debug("(%s)\n", __func__);
-
 	lowpan_netlink_fini();
 
 	dev_remove_pack(&lowpan_packet_type);
-- 
1.7.2.3
