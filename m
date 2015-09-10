From: Joe Perches <joe@perches.com>
Subject: [PATCH] mv643xx_eth: Neaten mv643xx_eth_program_multicast_filter
Date: Wed, 09 Sep 2015 17:40:56 -0700
Message-ID: <1441845656.17219.110.camel@perches.com>
References: <1441787886-7214-1-git-send-email-linux@rasmusvillemoes.dk>
	 <20150909.170620.88355755480464840.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux@rasmusvillemoes.dk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150909.170620.88355755480464840.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The code around the allocation and loops are a bit obfuscated.

Neaten it by using:

o kcalloc with decimal count and sizeof(u32)
o Decimal loop indexing and i++ not i += 4
o A promiscuous block using a similar style
  to the multicast block
o Remove unnecessary variables

Signed-off-by: Joe Perches <joe@perches.com>
---
Here's a neatening patch respun against Rasmus' patch
Might be useful.

 drivers/net/ethernet/marvell/mv643xx_eth.c | 43 +++++++++++++++---------------
 1 file changed, 22 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 960169e..c78ae18 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -1845,29 +1845,19 @@ static void mv643xx_eth_program_multicast_filter(struct net_device *dev)
 	struct netdev_hw_addr *ha;
 	int i;
 
-	if (dev->flags & (IFF_PROMISC | IFF_ALLMULTI)) {
-		int port_num;
-		u32 accept;
+	if (dev->flags & (IFF_PROMISC | IFF_ALLMULTI))
+		goto promiscuous;
 
-oom:
-		port_num = mp->port_num;
-		accept = 0x01010101;
-		for (i = 0; i < 0x100; i += 4) {
-			wrl(mp, SPECIAL_MCAST_TABLE(port_num) + i, accept);
-			wrl(mp, OTHER_MCAST_TABLE(port_num) + i, accept);
-		}
-		return;
-	}
-
-	mc_spec = kzalloc(0x200, GFP_ATOMIC);
-	if (mc_spec == NULL)
-		goto oom;
-	mc_other = mc_spec + (0x100 >> 2);
+	/* Allocate both mc_spec and mc_other tables */
+	mc_spec = kcalloc(128, sizeof(u32), GFP_ATOMIC);
+	if (!mc_spec)
+		goto promiscuous;
+	mc_other = &mc_spec[64];
 
 	netdev_for_each_mc_addr(ha, dev) {
 		u8 *a = ha->addr;
 		u32 *table;
-		int entry;
+		u8 entry;
 
 		if (memcmp(a, "\x01\x00\x5e\x00\x00", 5) == 0) {
 			table = mc_spec;
@@ -1880,12 +1870,23 @@ oom:
 		table[entry >> 2] |= 1 << (8 * (entry & 3));
 	}
 
-	for (i = 0; i < 0x100; i += 4) {
-		wrl(mp, SPECIAL_MCAST_TABLE(mp->port_num) + i, mc_spec[i >> 2]);
-		wrl(mp, OTHER_MCAST_TABLE(mp->port_num) + i, mc_other[i >> 2]);
+	for (i = 0; i < 64; i++) {
+		wrl(mp, SPECIAL_MCAST_TABLE(mp->port_num) + i * sizeof(u32),
+		    mc_spec[i]);
+		wrl(mp, OTHER_MCAST_TABLE(mp->port_num) + i * sizeof(u32),
+		    mc_other[i]);
 	}
 
 	kfree(mc_spec);
+	return;
+
+promiscuous:
+	for (i = 0; i < 64; i++) {
+		wrl(mp, SPECIAL_MCAST_TABLE(mp->port_num) + i * sizeof(u32),
+		    0x01010101u);
+		wrl(mp, OTHER_MCAST_TABLE(mp->port_num) + i * sizeof(u32),
+		    0x01010101u);
+	}
 }
 
 static void mv643xx_eth_set_rx_mode(struct net_device *dev)
