From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 4/6] mv643xx_eth: implement ->set_rx_mode()
Date: Tue, 18 Nov 2008 23:29:56 +0100
Message-ID: <20081118222947.GV5006@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:38081 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752368AbYKRW36 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2008 17:29:58 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, if multiple unicast addresses are programmed into a
mv643xx_eth interface, the core networking will resort to enabling
promiscuous mode on the interface, as mv643xx_eth does not implement
->set_rx_mode().

This patch switches mv643xx_eth over from ->set_multicast_list()
to ->set_rx_mode(), and implements support for secondary unicast
addresses.  The hardware can handle multiple unicast addresses as
long as their first 11 nibbles are the same (i.e. are of the form
xx:xx:xx:xx:xx:xy where the x part is the same for all addresses), so
if that is the case, we use that mode.  If it's not the case, we enable
unicast promiscuous mode in the hardware, which is slightly better than
enabling promiscuous mode for multicasts as well, which is what would
happen before.

While we are at it, change the programming sequence so that we
don't clear all filter bits first, so we don't lose all incoming
packets while the filter is being reprogrammed.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |  174 +++++++++++++++++++++++++++------------------
 1 files changed, 104 insertions(+), 70 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 3326587..9f3ee7d 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1448,11 +1448,8 @@ static const struct ethtool_ops mv643xx_eth_ethtool_ops_phyless = {
 /* address handling *********************************************************/
 static void uc_addr_get(struct mv643xx_eth_private *mp, unsigned char *addr)
 {
-	unsigned int mac_h;
-	unsigned int mac_l;
-
-	mac_h = rdlp(mp, MAC_ADDR_HIGH);
-	mac_l = rdlp(mp, MAC_ADDR_LOW);
+	unsigned int mac_h = rdlp(mp, MAC_ADDR_HIGH);
+	unsigned int mac_l = rdlp(mp, MAC_ADDR_LOW);
 
 	addr[0] = (mac_h >> 24) & 0xff;
 	addr[1] = (mac_h >> 16) & 0xff;
@@ -1462,57 +1459,71 @@ static void uc_addr_get(struct mv643xx_eth_private *mp, unsigned char *addr)
 	addr[5] = mac_l & 0xff;
 }
 
-static void init_mac_tables(struct mv643xx_eth_private *mp)
+static void uc_addr_set(struct mv643xx_eth_private *mp, unsigned char *addr)
 {
-	int i;
-
-	for (i = 0; i < 0x100; i += 4) {
-		wrl(mp, SPECIAL_MCAST_TABLE(mp->port_num) + i, 0);
-		wrl(mp, OTHER_MCAST_TABLE(mp->port_num) + i, 0);
-	}
-
-	for (i = 0; i < 0x10; i += 4)
-		wrl(mp, UNICAST_TABLE(mp->port_num) + i, 0);
+	wrlp(mp, MAC_ADDR_HIGH,
+		(addr[0] << 24) | (addr[1] << 16) | (addr[2] << 8) | addr[3]);
+	wrlp(mp, MAC_ADDR_LOW, (addr[4] << 8) | addr[5]);
 }
 
-static void set_filter_table_entry(struct mv643xx_eth_private *mp,
-				   int table, unsigned char entry)
+static u32 uc_addr_filter_mask(struct net_device *dev)
 {
-	unsigned int table_reg;
-
-	/* Set "accepts frame bit" at specified table entry */
-	table_reg = rdl(mp, table + (entry & 0xfc));
-	table_reg |= 0x01 << (8 * (entry & 3));
-	wrl(mp, table + (entry & 0xfc), table_reg);
-}
+	struct dev_addr_list *uc_ptr;
+	u32 nibbles;
 
-static void uc_addr_set(struct mv643xx_eth_private *mp, unsigned char *addr)
-{
-	unsigned int mac_h;
-	unsigned int mac_l;
-	int table;
+	if (dev->flags & IFF_PROMISC)
+		return 0;
 
-	mac_l = (addr[4] << 8) | addr[5];
-	mac_h = (addr[0] << 24) | (addr[1] << 16) | (addr[2] << 8) | addr[3];
+	nibbles = 1 << (dev->dev_addr[5] & 0x0f);
+	for (uc_ptr = dev->uc_list; uc_ptr != NULL; uc_ptr = uc_ptr->next) {
+		if (memcmp(dev->dev_addr, uc_ptr->da_addr, 5))
+			return 0;
+		if ((dev->dev_addr[5] ^ uc_ptr->da_addr[5]) & 0xf0)
+			return 0;
 
-	wrlp(mp, MAC_ADDR_LOW, mac_l);
-	wrlp(mp, MAC_ADDR_HIGH, mac_h);
+		nibbles |= 1 << (uc_ptr->da_addr[5] & 0x0f);
+	}
 
-	table = UNICAST_TABLE(mp->port_num);
-	set_filter_table_entry(mp, table, addr[5] & 0x0f);
+	return nibbles;
 }
 
-static int mv643xx_eth_set_mac_address(struct net_device *dev, void *addr)
+static void mv643xx_eth_program_unicast_filter(struct net_device *dev)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
+	u32 port_config;
+	u32 nibbles;
+	int i;
 
-	/* +2 is for the offset of the HW addr type */
-	memcpy(dev->dev_addr, addr + 2, 6);
-
-	init_mac_tables(mp);
 	uc_addr_set(mp, dev->dev_addr);
 
-	return 0;
+	port_config = rdlp(mp, PORT_CONFIG);
+	nibbles = uc_addr_filter_mask(dev);
+	if (!nibbles) {
+		port_config |= UNICAST_PROMISCUOUS_MODE;
+		wrlp(mp, PORT_CONFIG, port_config);
+		return;
+	}
+
+	for (i = 0; i < 16; i += 4) {
+		int off = UNICAST_TABLE(mp->port_num) + i;
+		u32 v;
+
+		v = 0;
+		if (nibbles & 1)
+			v |= 0x00000001;
+		if (nibbles & 2)
+			v |= 0x00000100;
+		if (nibbles & 4)
+			v |= 0x00010000;
+		if (nibbles & 8)
+			v |= 0x01000000;
+		nibbles >>= 4;
+
+		wrl(mp, off, v);
+	}
+
+	port_config &= ~UNICAST_PROMISCUOUS_MODE;
+	wrlp(mp, PORT_CONFIG, port_config);
 }
 
 static int addr_crc(unsigned char *addr)
@@ -1533,24 +1544,22 @@ static int addr_crc(unsigned char *addr)
 	return crc;
 }
 
-static void mv643xx_eth_set_rx_mode(struct net_device *dev)
+static void mv643xx_eth_program_multicast_filter(struct net_device *dev)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
-	u32 port_config;
+	u32 *mc_spec;
+	u32 *mc_other;
 	struct dev_addr_list *addr;
 	int i;
 
-	port_config = rdlp(mp, PORT_CONFIG);
-	if (dev->flags & IFF_PROMISC)
-		port_config |= UNICAST_PROMISCUOUS_MODE;
-	else
-		port_config &= ~UNICAST_PROMISCUOUS_MODE;
-	wrlp(mp, PORT_CONFIG, port_config);
-
 	if (dev->flags & (IFF_PROMISC | IFF_ALLMULTI)) {
-		int port_num = mp->port_num;
-		u32 accept = 0x01010101;
+		int port_num;
+		u32 accept;
+		int i;
 
+oom:
+		port_num = mp->port_num;
+		accept = 0x01010101;
 		for (i = 0; i < 0x100; i += 4) {
 			wrl(mp, SPECIAL_MCAST_TABLE(port_num) + i, accept);
 			wrl(mp, OTHER_MCAST_TABLE(port_num) + i, accept);
@@ -1558,28 +1567,55 @@ static void mv643xx_eth_set_rx_mode(struct net_device *dev)
 		return;
 	}
 
-	for (i = 0; i < 0x100; i += 4) {
-		wrl(mp, SPECIAL_MCAST_TABLE(mp->port_num) + i, 0);
-		wrl(mp, OTHER_MCAST_TABLE(mp->port_num) + i, 0);
-	}
+	mc_spec = kmalloc(0x200, GFP_KERNEL);
+	if (mc_spec == NULL)
+		goto oom;
+	mc_other = mc_spec + (0x100 >> 2);
+
+	memset(mc_spec, 0, 0x100);
+	memset(mc_other, 0, 0x100);
 
 	for (addr = dev->mc_list; addr != NULL; addr = addr->next) {
 		u8 *a = addr->da_addr;
-		int table;
-
-		if (addr->da_addrlen != 6)
-			continue;
+		u32 *table;
+		int entry;
 
 		if (memcmp(a, "\x01\x00\x5e\x00\x00", 5) == 0) {
-			table = SPECIAL_MCAST_TABLE(mp->port_num);
-			set_filter_table_entry(mp, table, a[5]);
+			table = mc_spec;
+			entry = a[5];
 		} else {
-			int crc = addr_crc(a);
-
-			table = OTHER_MCAST_TABLE(mp->port_num);
-			set_filter_table_entry(mp, table, crc);
+			table = mc_other;
+			entry = addr_crc(a);
 		}
+
+		table[entry >> 2] |= 1 << (entry & 3);
 	}
+
+	for (i = 0; i < 0x100; i += 4) {
+		wrl(mp, SPECIAL_MCAST_TABLE(mp->port_num) + i, mc_spec[i >> 2]);
+		wrl(mp, OTHER_MCAST_TABLE(mp->port_num) + i, mc_other[i >> 2]);
+	}
+
+	kfree(mc_spec);
+}
+
+static void mv643xx_eth_set_rx_mode(struct net_device *dev)
+{
+	mv643xx_eth_program_unicast_filter(dev);
+	mv643xx_eth_program_multicast_filter(dev);
+}
+
+static int mv643xx_eth_set_mac_address(struct net_device *dev, void *addr)
+{
+	struct sockaddr *sa = addr;
+
+	memcpy(dev->dev_addr, sa->sa_data, ETH_ALEN);
+
+	netif_addr_lock_bh(dev);
+	mv643xx_eth_program_unicast_filter(dev);
+	netif_addr_unlock_bh(dev);
+
+	return 0;
 }
 
 
@@ -1988,7 +2024,7 @@ static void port_start(struct mv643xx_eth_private *mp)
 	/*
 	 * Add configured unicast address to address filter table.
 	 */
-	uc_addr_set(mp, mp->dev->dev_addr);
+	mv643xx_eth_program_unicast_filter(mp->dev);
 
 	/*
 	 * Receive all unmatched unicast, TCP, UDP, BPDU and broadcast
@@ -2084,8 +2120,6 @@ static int mv643xx_eth_open(struct net_device *dev)
 		return -EAGAIN;
 	}
 
-	init_mac_tables(mp);
-
 	mv643xx_eth_recalc_skb_size(mp);
 
 	napi_enable(&mp->napi);
@@ -2667,7 +2701,7 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	dev->hard_start_xmit = mv643xx_eth_xmit;
 	dev->open = mv643xx_eth_open;
 	dev->stop = mv643xx_eth_stop;
-	dev->set_multicast_list = mv643xx_eth_set_rx_mode;
+	dev->set_rx_mode = mv643xx_eth_set_rx_mode;
 	dev->set_mac_address = mv643xx_eth_set_mac_address;
 	dev->do_ioctl = mv643xx_eth_ioctl;
 	dev->change_mtu = mv643xx_eth_change_mtu;
-- 
1.5.6.4
