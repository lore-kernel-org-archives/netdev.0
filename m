From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] eth: docbook comments
Date: Tue, 15 Aug 2006 12:57:59 -0700
Message-ID: <20060815125759.590a4a44@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Randy.Dunlap" <rdunlap@xenotime.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:18053 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932779AbWHOT6B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 15:58:01 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add docbook style comments to ethernet support.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 net/ethernet/eth.c |   90 +++++++++++++++++++++++++++++++++++++----------------
 1 file changed, 64 insertions(+), 26 deletions(-)

--- net-2.6.19.orig/net/ethernet/eth.c
+++ net-2.6.19/net/ethernet/eth.c
@@ -64,23 +64,24 @@
 
 __setup("ether=", netdev_boot_setup);
 
-/*
- *	 Create the Ethernet MAC header for an arbitrary protocol layer 
+/**
+ * eth_header - create the Ethernet header
+ * @skb:	buffer to alter
+ * @dev:	source device
+ * @type:	Ethernet type field
+ * @daddr: destination address (NULL leave destination address)
+ * @saddr: source address (NULL use device source address)
+ * @len:   packet length (<= skb->len)
+ *
  *
- *	saddr=NULL	means use device source address
- *	daddr=NULL	means leave destination address (eg unresolved arp)
+ * Set the protocol type. For a packet of type ETH_P_802_3 we put the length
+ * in here instead. It is up to the 802.2 layer to carry protocol information.
  */
-
 int eth_header(struct sk_buff *skb, struct net_device *dev, unsigned short type,
 	   void *daddr, void *saddr, unsigned len)
 {
 	struct ethhdr *eth = (struct ethhdr *)skb_push(skb,ETH_HLEN);
 
-	/* 
-	 *	Set the protocol type. For a packet of type ETH_P_802_3 we put the length
-	 *	in here instead. It is up to the 802.2 layer to carry protocol information.
-	 */
-	
 	if(type!=ETH_P_802_3) 
 		eth->h_proto = htons(type);
 	else
@@ -113,16 +114,16 @@ int eth_header(struct sk_buff *skb, stru
 	return -ETH_HLEN;
 }
 
-
-/*
- *	Rebuild the Ethernet MAC header. This is called after an ARP
- *	(or in future other address resolution) has completed on this
- *	sk_buff. We now let ARP fill in the other fields.
+/**
+ * eth_rebuild_header- rebuild the Ethernet MAC header.
+ * @skb: socket buffer to update
  *
- *	This routine CANNOT use cached dst->neigh!
- *	Really, it is used only when dst->neigh is wrong.
+ * This is called after an ARP or IPV6 ndisc it's resolution on this
+ * sk_buff. We now let protocol (ARP) fill in the other fields.
+ *
+ * This routine CANNOT use cached dst->neigh!
+ * Really, it is used only when dst->neigh is wrong.
  */
-
 int eth_rebuild_header(struct sk_buff *skb)
 {
 	struct ethhdr *eth = (struct ethhdr *)skb->data;
@@ -147,12 +148,15 @@ int eth_rebuild_header(struct sk_buff *s
 }
 
 
-/*
- *	Determine the packet's protocol ID. The rule here is that we 
- *	assume 802.3 if the type field is short enough to be a length.
- *	This is normal practice and works for any 'now in use' protocol.
+/**
+ * eth_type_trans - determine the packet's protocol ID.
+ * @skb: received socket data
+ * @dev: receiving network device
+ *
+ * The rule here is that we
+ * assume 802.3 if the type field is short enough to be a length.
+ * This is normal practice and works for any 'now in use' protocol.
  */
- 
 __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ethhdr *eth;
@@ -202,6 +206,11 @@ __be16 eth_type_trans(struct sk_buff *sk
 	return htons(ETH_P_802_2);
 }
 
+/**
+ * eth_header_parse - extract hardware address from packet
+ * @skb: packet to extract header from
+ * @haddr: destination buffer
+ */
 static int eth_header_parse(struct sk_buff *skb, unsigned char *haddr)
 {
 	struct ethhdr *eth = eth_hdr(skb);
@@ -209,6 +218,12 @@ static int eth_header_parse(struct sk_bu
 	return ETH_ALEN;
 }
 
+/**
+ * eth_header_cache - fill cache entry from neighbour
+ * @neigh: source neighbour
+ * @hh: destination cache entry
+ * Create an Ethernet header template from the neighbour.
+ */
 int eth_header_cache(struct neighbour *neigh, struct hh_cache *hh)
 {
 	unsigned short type = hh->hh_type;
@@ -228,10 +243,14 @@ int eth_header_cache(struct neighbour *n
 	return 0;
 }
 
-/*
+/**
+ * eth_header_cache_update - update cache entry
+ * @hh: destination cache entry
+ * @dev: network device
+ * @haddr: new hardware address
+ *
  * Called by Address Resolution module to notify changes in address.
  */
-
 void eth_header_cache_update(struct hh_cache *hh, struct net_device *dev, unsigned char * haddr)
 {
 	memcpy(((u8*)hh->hh_data) + HH_DATA_OFF(sizeof(struct ethhdr)),
@@ -240,6 +259,15 @@ void eth_header_cache_update(struct hh_c
 
 EXPORT_SYMBOL(eth_type_trans);
 
+/**
+ * eth_mac_addr - set new Ethernet hardware address
+ * @dev: network device
+ * @p: socket address
+ * Change hardware address of device.
+ *
+ * This doesn't change hardware matching, so needs to be overridden
+ * for most real devices.
+ */
 static int eth_mac_addr(struct net_device *dev, void *p)
 {
 	struct sockaddr *addr=p;
@@ -249,6 +277,14 @@ static int eth_mac_addr(struct net_devic
 	return 0;
 }
 
+/**
+ * eth_change_mtu - set new MTU size
+ * @dev: network device
+ * @new_mtu: new Maximum Transfer Unit
+ *
+ * Allow changing MTU size. Needs to be overridden for devices
+ * supporting jumbo frames.
+ */
 static int eth_change_mtu(struct net_device *dev, int new_mtu)
 {
 	if (new_mtu < 68 || new_mtu > ETH_DATA_LEN)
@@ -257,8 +293,10 @@ static int eth_change_mtu(struct net_dev
 	return 0;
 }
 
-/*
- * Fill in the fields of the device structure with ethernet-generic values.
+/**
+ * ether_setup - setup Ethernet network device
+ * @dev: network device
+ * Fill in the fields of the device structure with Ethernet-generic values.
  */
 void ether_setup(struct net_device *dev)
 {
@@ -283,15 +321,15 @@ void ether_setup(struct net_device *dev)
 EXPORT_SYMBOL(ether_setup);
 
 /**
- * alloc_etherdev - Allocates and sets up an ethernet device
+ * alloc_etherdev - Allocates and sets up an Ethernet device
  * @sizeof_priv: Size of additional driver-private structure to be allocated
- *	for this ethernet device
+ *	for this Ethernet device
  *
- * Fill in the fields of the device structure with ethernet-generic
+ * Fill in the fields of the device structure with Ethernet-generic
  * values. Basically does everything except registering the device.
  *
  * Constructs a new net device, complete with a private data area of
- * size @sizeof_priv.  A 32-byte (not bit) alignment is enforced for
+ * size (sizeof_priv).  A 32-byte (not bit) alignment is enforced for
  * this private data area.
  */
 
