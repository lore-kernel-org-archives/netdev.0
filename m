From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/3] net: wrap hard_header_parse
Date: Fri, 24 Aug 2007 13:43:12 -0700
Message-ID: <20070824204533.067473338@linux-foundation.org>
References: <20070824204310.388073598@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:36798 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752724AbXHXUsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 16:48:47 -0400
Content-Disposition: inline; filename=dev_header_parse.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wrap the hard_header_parse function to simplify next step
of header_ops conversion.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/include/linux/netdevice.h	2007-08-23 21:25:57.000000000 -0700
+++ b/include/linux/netdevice.h	2007-08-23 22:25:35.000000000 -0700
@@ -639,7 +639,7 @@ struct net_device
 	void			(*vlan_rx_kill_vid)(struct net_device *dev,
 						    unsigned short vid);
 
-	int			(*hard_header_parse)(struct sk_buff *skb,
+	int			(*hard_header_parse)(const struct sk_buff *skb,
 						     unsigned char *haddr);
 	int			(*neigh_setup)(struct net_device *dev, struct neigh_parms *);
 #ifdef CONFIG_NETPOLL
@@ -787,6 +787,16 @@ static inline int dev_hard_header(struct
 	return dev->hard_header(skb, dev, type, daddr, saddr, len);
 }
 
+static inline int dev_parse_header(const struct sk_buff *skb,
+				   unsigned char *haddr)
+{
+	const struct net_device *dev = skb->dev;
+
+	if (!dev->hard_header_parse)
+		return 0;
+	return dev->hard_header_parse(skb, haddr);
+}
+
 typedef int gifconf_func_t(struct net_device * dev, char __user * bufptr, int len);
 extern int		register_gifconf(unsigned int family, gifconf_func_t * gifconf);
 static inline int unregister_gifconf(unsigned int family)
--- a/net/netfilter/nfnetlink_log.c	2007-08-23 09:44:22.000000000 -0700
+++ b/net/netfilter/nfnetlink_log.c	2007-08-23 21:43:32.000000000 -0700
@@ -480,12 +480,13 @@ __build_packet_message(struct nfulnl_ins
 		NFA_PUT(inst->skb, NFULA_MARK, sizeof(tmp_uint), &tmp_uint);
 	}
 
-	if (indev && skb->dev && skb->dev->hard_header_parse) {
+	if (indev && skb->dev) {
 		struct nfulnl_msg_packet_hw phw;
-		int len = skb->dev->hard_header_parse((struct sk_buff *)skb,
-						    phw.hw_addr);
-		phw.hw_addrlen = htons(len);
-		NFA_PUT(inst->skb, NFULA_HWADDR, sizeof(phw), &phw);
+		int len = dev_parse_header(skb, phw.hw_addr);
+		if (len > 0) {
+			phw.hw_addrlen = htons(len);
+			NFA_PUT(inst->skb, NFULA_HWADDR, sizeof(phw), &phw);
+		}
 	}
 
 	if (skb->tstamp.tv64) {
--- a/net/netfilter/nfnetlink_queue.c	2007-08-23 09:44:22.000000000 -0700
+++ b/net/netfilter/nfnetlink_queue.c	2007-08-23 21:33:50.000000000 -0700
@@ -485,14 +485,13 @@ nfqnl_build_packet_message(struct nfqnl_
 		NFA_PUT(skb, NFQA_MARK, sizeof(u_int32_t), &tmp_uint);
 	}
 
-	if (indev && entskb->dev
-	    && entskb->dev->hard_header_parse) {
+	if (indev && entskb->dev) {
 		struct nfqnl_msg_packet_hw phw;
-
-		int len = entskb->dev->hard_header_parse(entskb,
-							   phw.hw_addr);
-		phw.hw_addrlen = htons(len);
-		NFA_PUT(skb, NFQA_HWADDR, sizeof(phw), &phw);
+		int len = dev_parse_header(entskb, phw.hw_addr);
+		if (len) {
+			phw.hw_addrlen = htons(len);
+			NFA_PUT(skb, NFQA_HWADDR, sizeof(phw), &phw);
+		}
 	}
 
 	if (entskb->tstamp.tv64) {
--- a/net/packet/af_packet.c	2007-08-23 21:25:57.000000000 -0700
+++ b/net/packet/af_packet.c	2007-08-23 22:25:19.000000000 -0700
@@ -512,10 +512,8 @@ static int packet_rcv(struct sk_buff *sk
 		sll->sll_ifindex = orig_dev->ifindex;
 	else
 		sll->sll_ifindex = dev->ifindex;
-	sll->sll_halen = 0;
 
-	if (dev->hard_header_parse)
-		sll->sll_halen = dev->hard_header_parse(skb, sll->sll_addr);
+	sll->sll_halen = dev_parse_header(skb, sll->sll_addr);
 
 	PACKET_SKB_CB(skb)->origlen = skb->len;
 
@@ -649,9 +647,7 @@ static int tpacket_rcv(struct sk_buff *s
 	h->tp_usec = tv.tv_usec;
 
 	sll = (struct sockaddr_ll*)((u8*)h + TPACKET_ALIGN(sizeof(*h)));
-	sll->sll_halen = 0;
-	if (dev->hard_header_parse)
-		sll->sll_halen = dev->hard_header_parse(skb, sll->sll_addr);
+	sll->sll_halen = dev_parse_header(skb, sll->sll_addr);
 	sll->sll_family = AF_PACKET;
 	sll->sll_hatype = dev->type;
 	sll->sll_protocol = skb->protocol;
--- a/net/ethernet/eth.c	2007-08-23 21:25:57.000000000 -0700
+++ b/net/ethernet/eth.c	2007-08-23 22:25:19.000000000 -0700
@@ -207,9 +207,9 @@ EXPORT_SYMBOL(eth_type_trans);
  * @skb: packet to extract header from
  * @haddr: destination buffer
  */
-static int eth_header_parse(struct sk_buff *skb, unsigned char *haddr)
+static int eth_header_parse(const struct sk_buff *skb, unsigned char *haddr)
 {
-	struct ethhdr *eth = eth_hdr(skb);
+	const struct ethhdr *eth = eth_hdr(skb);
 	memcpy(haddr, eth->h_source, ETH_ALEN);
 	return ETH_ALEN;
 }
--- a/net/mac80211/ieee80211.c	2007-08-23 21:25:57.000000000 -0700
+++ b/net/mac80211/ieee80211.c	2007-08-23 22:25:19.000000000 -0700
@@ -53,7 +53,7 @@ static struct net_device_stats *ieee8021
 	return &(sdata->stats);
 }
 
-static int header_parse_80211(struct sk_buff *skb, unsigned char *haddr)
+static int header_parse_80211(const struct sk_buff *skb, unsigned char *haddr)
 {
 	memcpy(haddr, skb_mac_header(skb) + 10, ETH_ALEN); /* addr2 */
 	return ETH_ALEN;
--- a/drivers/ieee1394/eth1394.c	2007-08-23 21:25:57.000000000 -0700
+++ b/drivers/ieee1394/eth1394.c	2007-08-23 22:25:19.000000000 -0700
@@ -162,7 +162,8 @@ static int ether1394_header(struct sk_bu
 			    unsigned short type, void *daddr, void *saddr,
 			    unsigned len);
 static int ether1394_rebuild_header(struct sk_buff *skb);
-static int ether1394_header_parse(struct sk_buff *skb, unsigned char *haddr);
+static int ether1394_header_parse(const struct sk_buff *skb,
+				  unsigned char *haddr);
 static int ether1394_header_cache(struct neighbour *neigh, struct hh_cache *hh);
 static void ether1394_header_cache_update(struct hh_cache *hh,
 					  struct net_device *dev,
@@ -752,11 +753,10 @@ static int ether1394_rebuild_header(stru
 	return 0;
 }
 
-static int ether1394_header_parse(struct sk_buff *skb, unsigned char *haddr)
+static int ether1394_header_parse(const struct sk_buff *skb,
+				  unsigned char *haddr)
 {
-	struct net_device *dev = skb->dev;
-
-	memcpy(haddr, dev->dev_addr, ETH1394_ALEN);
+	memcpy(haddr, skb->dev->dev_addr, ETH1394_ALEN);
 	return ETH1394_ALEN;
 }
 
--- a/drivers/net/wireless/airo.c	2007-08-23 09:44:10.000000000 -0700
+++ b/drivers/net/wireless/airo.c	2007-08-23 21:59:46.000000000 -0700
@@ -2481,7 +2481,7 @@ void stop_airo_card( struct net_device *
 
 EXPORT_SYMBOL(stop_airo_card);
 
-static int wll_header_parse(struct sk_buff *skb, unsigned char *haddr)
+static int wll_header_parse(const struct sk_buff *skb, unsigned char *haddr)
 {
 	memcpy(haddr, skb_mac_header(skb) + 10, ETH_ALEN);
 	return ETH_ALEN;
@@ -2698,11 +2698,6 @@ static int mpi_map_card(struct airo_info
 
 static void wifi_setup(struct net_device *dev)
 {
-	dev->hard_header        = NULL;
-	dev->rebuild_header     = NULL;
-	dev->hard_header_cache  = NULL;
-	dev->header_cache_update= NULL;
-
 	dev->hard_header_parse  = wll_header_parse;
 	dev->hard_start_xmit = &airo_start_xmit11;
 	dev->get_stats = &airo_get_stats;
--- a/drivers/s390/net/qeth_main.c	2007-08-23 09:44:10.000000000 -0700
+++ b/drivers/s390/net/qeth_main.c	2007-08-23 22:02:26.000000000 -0700
@@ -6488,10 +6488,10 @@ static struct ethtool_ops qeth_ethtool_o
 };
 
 static int
-qeth_hard_header_parse(struct sk_buff *skb, unsigned char *haddr)
+qeth_hard_header_parse(const struct sk_buff *skb, unsigned char *haddr)
 {
-	struct qeth_card *card;
-	struct ethhdr *eth;
+	const struct qeth_card *card;
+	const struct ethhdr *eth;
 
 	card = qeth_get_card_from_dev(skb->dev);
 	if (card->options.layer2)
--- a/net/ipv4/netfilter/ip_queue.c	2007-08-23 21:25:57.000000000 -0700
+++ b/net/ipv4/netfilter/ip_queue.c	2007-08-23 22:04:33.000000000 -0700
@@ -249,10 +249,8 @@ ipq_build_packet_message(struct ipq_queu
 
 	if (entry->info->indev && entry->skb->dev) {
 		pmsg->hw_type = entry->skb->dev->type;
-		if (entry->skb->dev->hard_header_parse)
-			pmsg->hw_addrlen =
-				entry->skb->dev->hard_header_parse(entry->skb,
-								   pmsg->hw_addr);
+		pmsg->hw_addrlen = dev_parse_header(entry->skb,
+						    pmsg->hw_addr);
 	}
 
 	if (data_len)
--- a/net/ipv6/netfilter/ip6_queue.c	2007-08-23 09:44:22.000000000 -0700
+++ b/net/ipv6/netfilter/ip6_queue.c	2007-08-23 22:06:24.000000000 -0700
@@ -247,10 +247,7 @@ ipq_build_packet_message(struct ipq_queu
 
 	if (entry->info->indev && entry->skb->dev) {
 		pmsg->hw_type = entry->skb->dev->type;
-		if (entry->skb->dev->hard_header_parse)
-			pmsg->hw_addrlen =
-				entry->skb->dev->hard_header_parse(entry->skb,
-								   pmsg->hw_addr);
+		pmsg->hw_addrlen = dev_parse_header(entry->skb, pmsg->hw_addr);
 	}
 
 	if (data_len)

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

