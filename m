From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 3/4] net: mv643xx_eth: use kzalloc
Date: Wed, 09 Sep 2015 16:25:27 -0700
Message-ID: <1441841127.17219.94.camel@perches.com>
References: <1441787886-7214-1-git-send-email-linux@rasmusvillemoes.dk>
	 <1441787886-7214-4-git-send-email-linux@rasmusvillemoes.dk>
	 <1441814431.17219.46.camel@perches.com> <87r3m74f2k.fsf@rasmusvillemoes.dk>
	 <1441824356.17219.69.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441824356.17219.69.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-09-09 at 11:45 -0700, Joe Perches wrote:
> On Wed, 2015-09-09 at 20:34 +0200, Rasmus Villemoes wrote:
> > mc_spec and mc_other are u32*, we allocate 0x200 = 512 bytes = 128
> > u32s, and pointer arithmetic makes mc_other point to the latter 64. Then
> > the memory is cleared 256 bytes at a time.
> > 
> > It's unusual and slightly obfuscated code, but I don't think it's
> > wrong. 

Perhaps this would make the code a bit clearer:

Use kcalloc, decimal sizes, decimal indexing,
and a promiscuous exit block using the same
style as the non-promiscuous multicast block.
---
  drivers/net/ethernet/marvell/mv643xx_eth.c | 46 ++++++++++++++----------------
 1 file changed, 22 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index d52639b..9230ed5 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -1845,32 +1845,19 @@ static void mv643xx_eth_program_multicast_filter(struct net_device *dev)
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
-	mc_spec = kmalloc(0x200, GFP_ATOMIC);
-	if (mc_spec == NULL)
-		goto oom;
-	mc_other = mc_spec + (0x100 >> 2);
-
-	memset(mc_spec, 0, 0x100);
-	memset(mc_other, 0, 0x100);
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
@@ -1883,12 +1870,23 @@ oom:
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
