From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for Aug 7
Date: Wed, 07 Aug 2013 16:36:21 -0700 (PDT)
Message-ID: <20130807.163621.84433966934449459.davem@davemloft.net>
References: <20130807.104713.1615549684239408926.davem@davemloft.net>
	<20130807183758.GB16263@orbit.nwl.cc>
	<20130807.162748.779496444843938176.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, johannes@sipsolutions.net,
	sedat.dilek@gmail.com, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, hannes@stressinduktion.org,
	linux-wireless@vger.kernel.org, linville@tuxdriver.com
To: phil@nwl.cc
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130807.162748.779496444843938176.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Wed, 07 Aug 2013 16:27:48 -0700 (PDT)

> Look, I'm going to fix this myself, because I'm pretty tired of
> waiting for the obvious fix.

Someone please test this:

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index c623861..afc02a6 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -29,6 +29,7 @@
 
 #ifdef __KERNEL__
 extern __be16		eth_type_trans(struct sk_buff *skb, struct net_device *dev);
+extern __be16		__eth_type_trans(struct sk_buff *skb, struct net_device *dev);
 extern const struct header_ops eth_header_ops;
 
 extern int eth_header(struct sk_buff *skb, struct net_device *dev,
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index be1f64d..35dc1be 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -146,6 +146,45 @@ int eth_rebuild_header(struct sk_buff *skb)
 EXPORT_SYMBOL(eth_rebuild_header);
 
 /**
+ * __eth_type_trans - only determine the packet's protocol ID.
+ * @skb: packet
+ * @dev: device
+ */
+__be16 __eth_type_trans(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ethhdr *eth = (struct ethhdr *) skb->data;
+
+	/*
+	 * Some variants of DSA tagging don't have an ethertype field
+	 * at all, so we check here whether one of those tagging
+	 * variants has been configured on the receiving interface,
+	 * and if so, set skb->protocol without looking at the packet.
+	 */
+	if (netdev_uses_dsa_tags(dev))
+		return htons(ETH_P_DSA);
+	if (netdev_uses_trailer_tags(dev))
+		return htons(ETH_P_TRAILER);
+
+	if (ntohs(eth->h_proto) >= ETH_P_802_3_MIN)
+		return eth->h_proto;
+
+	/*
+	 *      This is a magic hack to spot IPX packets. Older Novell breaks
+	 *      the protocol design and runs IPX over 802.3 without an 802.2 LLC
+	 *      layer. We look for FFFF which isn't a used 802.2 SSAP/DSAP. This
+	 *      won't work for fault tolerant netware but does for the rest.
+	 */
+	if (skb->len >= 2 && *(unsigned short *)(skb->data) == 0xFFFF)
+		return htons(ETH_P_802_3);
+
+	/*
+	 *      Real 802.2 LLC
+	 */
+	return htons(ETH_P_802_2);
+}
+EXPORT_SYMBOL(__eth_type_trans);
+
+/**
  * eth_type_trans - determine the packet's protocol ID.
  * @skb: received socket data
  * @dev: receiving network device
@@ -184,33 +223,7 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 			skb->pkt_type = PACKET_OTHERHOST;
 	}
 
-	/*
-	 * Some variants of DSA tagging don't have an ethertype field
-	 * at all, so we check here whether one of those tagging
-	 * variants has been configured on the receiving interface,
-	 * and if so, set skb->protocol without looking at the packet.
-	 */
-	if (netdev_uses_dsa_tags(dev))
-		return htons(ETH_P_DSA);
-	if (netdev_uses_trailer_tags(dev))
-		return htons(ETH_P_TRAILER);
-
-	if (ntohs(eth->h_proto) >= ETH_P_802_3_MIN)
-		return eth->h_proto;
-
-	/*
-	 *      This is a magic hack to spot IPX packets. Older Novell breaks
-	 *      the protocol design and runs IPX over 802.3 without an 802.2 LLC
-	 *      layer. We look for FFFF which isn't a used 802.2 SSAP/DSAP. This
-	 *      won't work for fault tolerant netware but does for the rest.
-	 */
-	if (skb->len >= 2 && *(unsigned short *)(skb->data) == 0xFFFF)
-		return htons(ETH_P_802_3);
-
-	/*
-	 *      Real 802.2 LLC
-	 */
-	return htons(ETH_P_802_2);
+	return __eth_type_trans(skb, dev);
 }
 EXPORT_SYMBOL(eth_type_trans);
 
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 0c0f6c9..ec8e1c3 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2003,7 +2003,7 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 			return err;
 
 		if (dev->type == ARPHRD_ETHER)
-			skb->protocol = eth_type_trans(skb, dev);
+			skb->protocol = __eth_type_trans(skb, dev);
 
 		data += dev->hard_header_len;
 		to_write -= dev->hard_header_len;
@@ -2332,13 +2332,13 @@ static int packet_snd(struct socket *sock,
 	sock_tx_timestamp(sk, &skb_shinfo(skb)->tx_flags);
 
 	if (dev->type == ARPHRD_ETHER) {
-		skb->protocol = eth_type_trans(skb, dev);
+		skb->protocol = __eth_type_trans(skb, dev);
 		if (skb->protocol == htons(ETH_P_8021Q))
 			reserve += VLAN_HLEN;
 	} else {
 		skb->protocol = proto;
-		skb->dev = dev;
 	}
+	skb->dev = dev;
 
 	if (!gso_type && (len > dev->mtu + reserve + extra_len)) {
 		err = -EMSGSIZE;
