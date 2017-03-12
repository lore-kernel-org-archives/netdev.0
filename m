From: Luiz Augusto von Dentz <luiz.dentz@gmail.com>
Subject: [PATCH v7 6/6] 6lowpan: Fix IID format for Bluetooth
Date: Sun, 12 Mar 2017 10:19:38 +0200
Message-ID: <20170312081938.11700-7-luiz.dentz@gmail.com>
References: <20170312081938.11700-1-luiz.dentz@gmail.com>
Cc: patrik.flykt@linux.intel.com, aar@pengutronix.de,
        jukka.rissanen@linux.intel.com, linux-wpan@vger.kernel.org,
        netdev@vger.kernel.org
To: linux-bluetooth@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:34153 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933178AbdCLITv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 04:19:51 -0400
In-Reply-To: <20170312081938.11700-1-luiz.dentz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Luiz Augusto von Dentz <luiz.von.dentz@intel.com>

According to RFC 7668 U/L bit shall not be used:

https://wiki.tools.ietf.org/html/rfc7668#section-3.2.2 [Page 10]:

   In the figure, letter 'b' represents a bit from the
   Bluetooth device address, copied as is without any changes on any
   bit.  This means that no bit in the IID indicates whether the
   underlying Bluetooth device address is public or random.

   |0              1|1              3|3              4|4              6|
   |0              5|6              1|2              7|8              3|
   +----------------+----------------+----------------+----------------+
   |bbbbbbbbbbbbbbbb|bbbbbbbb11111111|11111110bbbbbbbb|bbbbbbbbbbbbbbbb|
   +----------------+----------------+----------------+----------------+

Because of this the code cannot figure out the address type from the IP
address anymore thus it makes no sense to use peer_lookup_ba as it needs
the peer address type.

Signed-off-by: Luiz Augusto von Dentz <luiz.von.dentz@intel.com>
Reviewed-by: Stefan Schmidt <stefan@osg.samsung.com>
Acked-by: Jukka Rissanen <jukka.rissanen@linux.intel.com>
---
 include/net/6lowpan.h   |  4 ---
 net/bluetooth/6lowpan.c | 79 ++++++++-----------------------------------------
 net/ipv6/addrconf.c     |  6 +++-
 3 files changed, 17 insertions(+), 72 deletions(-)

diff --git a/include/net/6lowpan.h b/include/net/6lowpan.h
index c5792cb..a713780 100644
--- a/include/net/6lowpan.h
+++ b/include/net/6lowpan.h
@@ -211,10 +211,6 @@ static inline void lowpan_iphc_uncompress_eui48_lladdr(struct in6_addr *ipaddr,
 	ipaddr->s6_addr[11] = 0xFF;
 	ipaddr->s6_addr[12] = 0xFE;
 	memcpy(&ipaddr->s6_addr[13], lladdr + 3, 3);
-	/* second bit-flip (Universe/Local)
-	 * is done according RFC2464
-	 */
-	ipaddr->s6_addr[8] ^= 0x02;
 }
 
 #ifdef DEBUG
diff --git a/net/bluetooth/6lowpan.c b/net/bluetooth/6lowpan.c
index 0b68cfc..ec89c55 100644
--- a/net/bluetooth/6lowpan.c
+++ b/net/bluetooth/6lowpan.c
@@ -398,37 +398,6 @@ static int chan_recv_cb(struct l2cap_chan *chan, struct sk_buff *skb)
 	return err;
 }
 
-static u8 get_addr_type_from_eui64(u8 byte)
-{
-	/* Is universal(0) or local(1) bit */
-	return ((byte & 0x02) ? BDADDR_LE_RANDOM : BDADDR_LE_PUBLIC);
-}
-
-static void copy_to_bdaddr(struct in6_addr *ip6_daddr, bdaddr_t *addr)
-{
-	u8 *eui64 = ip6_daddr->s6_addr + 8;
-
-	addr->b[0] = eui64[7];
-	addr->b[1] = eui64[6];
-	addr->b[2] = eui64[5];
-	addr->b[3] = eui64[2];
-	addr->b[4] = eui64[1];
-	addr->b[5] = eui64[0];
-}
-
-static void convert_dest_bdaddr(struct in6_addr *ip6_daddr,
-				bdaddr_t *addr, u8 *addr_type)
-{
-	copy_to_bdaddr(ip6_daddr, addr);
-
-	/* We need to toggle the U/L bit that we got from IPv6 address
-	 * so that we get the proper address and type of the BD address.
-	 */
-	addr->b[5] ^= 0x02;
-
-	*addr_type = get_addr_type_from_eui64(addr->b[5]);
-}
-
 static int setup_header(struct sk_buff *skb, struct net_device *netdev,
 			bdaddr_t *peer_addr, u8 *peer_addr_type)
 {
@@ -436,8 +405,7 @@ static int setup_header(struct sk_buff *skb, struct net_device *netdev,
 	struct ipv6hdr *hdr;
 	struct lowpan_btle_dev *dev;
 	struct lowpan_peer *peer;
-	bdaddr_t addr, *any = BDADDR_ANY;
-	u8 *daddr = any->b;
+	u8 *daddr;
 	int err, status = 0;
 
 	hdr = ipv6_hdr(skb);
@@ -448,34 +416,24 @@ static int setup_header(struct sk_buff *skb, struct net_device *netdev,
 
 	if (ipv6_addr_is_multicast(&ipv6_daddr)) {
 		lowpan_cb(skb)->chan = NULL;
+		daddr = NULL;
 	} else {
-		u8 addr_type;
+		BT_DBG("dest IP %pI6c", &ipv6_daddr);
 
-		/* Get destination BT device from skb.
-		 * If there is no such peer then discard the packet.
+		/* The packet might be sent to 6lowpan interface
+		 * because of routing (either via default route
+		 * or user set route) so get peer according to
+		 * the destination address.
 		 */
-		convert_dest_bdaddr(&ipv6_daddr, &addr, &addr_type);
-
-		BT_DBG("dest addr %pMR type %d IP %pI6c", &addr,
-		       addr_type, &ipv6_daddr);
-
-		peer = peer_lookup_ba(dev, &addr, addr_type);
+		peer = peer_lookup_dst(dev, &ipv6_daddr, skb);
 		if (!peer) {
-			/* The packet might be sent to 6lowpan interface
-			 * because of routing (either via default route
-			 * or user set route) so get peer according to
-			 * the destination address.
-			 */
-			peer = peer_lookup_dst(dev, &ipv6_daddr, skb);
-			if (!peer) {
-				BT_DBG("no such peer %pMR found", &addr);
-				return -ENOENT;
-			}
+			BT_DBG("no such peer");
+			return -ENOENT;
 		}
 
 		daddr = peer->lladdr;
-		*peer_addr = addr;
-		*peer_addr_type = addr_type;
+		peer_addr = &peer->chan->dst;
+		*peer_addr_type = peer->chan->dst_type;
 		lowpan_cb(skb)->chan = peer->chan;
 
 		status = 1;
@@ -717,14 +675,6 @@ static struct l2cap_chan *chan_create(void)
 	return chan;
 }
 
-static void set_ip_addr_bits(u8 addr_type, u8 *addr)
-{
-	if (addr_type == BDADDR_LE_PUBLIC)
-		*addr |= 0x02;
-	else
-		*addr &= ~0x02;
-}
-
 static struct l2cap_chan *add_peer_chan(struct l2cap_chan *chan,
 					struct lowpan_btle_dev *dev)
 {
@@ -741,11 +691,6 @@ static struct l2cap_chan *add_peer_chan(struct l2cap_chan *chan,
 
 	lowpan_iphc_uncompress_eui48_lladdr(&peer->peer_addr, peer->lladdr);
 
-	/* IPv6 address needs to have the U/L bit set properly so toggle
-	 * it back here.
-	 */
-	set_ip_addr_bits(chan->dst_type, (u8 *)&peer->peer_addr.s6_addr + 8);
-
 	spin_lock(&devices_lock);
 	INIT_LIST_HEAD(&peer->list);
 	peer_add(dev, peer);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 7756640..1f1aaaf6 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2056,7 +2056,11 @@ static int addrconf_ifid_6lowpan(u8 *eui, struct net_device *dev)
 {
 	switch (dev->addr_len) {
 	case ETH_ALEN:
-		return addrconf_ifid_eui48(eui, dev);
+		memcpy(eui, dev->dev_addr, 3);
+		eui[3] = 0xFF;
+		eui[4] = 0xFE;
+		memcpy(eui + 5, dev->dev_addr + 3, 3);
+		break;
 	case EUI64_ADDR_LEN:
 		memcpy(eui, dev->dev_addr, EUI64_ADDR_LEN);
 		eui[0] ^= 2;
-- 
2.9.3
