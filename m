From: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>
Subject: [PATCH 2/5] drivers/net/ethernet/dec/tulip: Use standard
 __set_bit_le() function
Date: Wed, 13 Jun 2012 13:03:04 +0900
Message-ID: <20120613130304.0186fa9d.yoshikawa.takuya@oss.ntt.co.jp>
References: <20120613130054.b5695621.yoshikawa.takuya@oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, grundler@parisc-linux.org,
	arnd@arndb.de, benh@kernel.crashing.org, avi@redhat.com,
	mtosatti@redhat.com, linux-net-drivers@solarflare.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, kvm@vger.kernel.org,
	takuya.yoshikawa@gmail.com
To: akpm@linux-foundation.org
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20120613130054.b5695621.yoshikawa.takuya@oss.ntt.co.jp>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>

To introduce generic set_bit_le() later, we remove our own definition
and use a proper non-atomic bitops function: __set_bit_le().

Signed-off-by: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>
Acked-by: Grant Grundler <grundler@parisc-linux.org>
---
 drivers/net/ethernet/dec/tulip/de2104x.c    |    7 ++-----
 drivers/net/ethernet/dec/tulip/tulip_core.c |    7 ++-----
 2 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/de2104x.c b/drivers/net/ethernet/dec/tulip/de2104x.c
index 61cc093..77335853 100644
--- a/drivers/net/ethernet/dec/tulip/de2104x.c
+++ b/drivers/net/ethernet/dec/tulip/de2104x.c
@@ -661,9 +661,6 @@ static netdev_tx_t de_start_xmit (struct sk_buff *skb,
    new frame, not around filling de->setup_frame.  This is non-deterministic
    when re-entered but still correct. */
 
-#undef set_bit_le
-#define set_bit_le(i,p) do { ((char *)(p))[(i)/8] |= (1<<((i)%8)); } while(0)
-
 static void build_setup_frame_hash(u16 *setup_frm, struct net_device *dev)
 {
 	struct de_private *de = netdev_priv(dev);
@@ -673,12 +670,12 @@ static void build_setup_frame_hash(u16 *setup_frm, struct net_device *dev)
 	u16 *eaddrs;
 
 	memset(hash_table, 0, sizeof(hash_table));
-	set_bit_le(255, hash_table); 			/* Broadcast entry */
+	__set_bit_le(255, hash_table);			/* Broadcast entry */
 	/* This should work on big-endian machines as well. */
 	netdev_for_each_mc_addr(ha, dev) {
 		int index = ether_crc_le(ETH_ALEN, ha->addr) & 0x1ff;
 
-		set_bit_le(index, hash_table);
+		__set_bit_le(index, hash_table);
 	}
 
 	for (i = 0; i < 32; i++) {
diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/net/ethernet/dec/tulip/tulip_core.c
index c4f37ac..885700a 100644
--- a/drivers/net/ethernet/dec/tulip/tulip_core.c
+++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
@@ -1010,9 +1010,6 @@ static int private_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
    new frame, not around filling tp->setup_frame.  This is non-deterministic
    when re-entered but still correct. */
 
-#undef set_bit_le
-#define set_bit_le(i,p) do { ((char *)(p))[(i)/8] |= (1<<((i)%8)); } while(0)
-
 static void build_setup_frame_hash(u16 *setup_frm, struct net_device *dev)
 {
 	struct tulip_private *tp = netdev_priv(dev);
@@ -1022,12 +1019,12 @@ static void build_setup_frame_hash(u16 *setup_frm, struct net_device *dev)
 	u16 *eaddrs;
 
 	memset(hash_table, 0, sizeof(hash_table));
-	set_bit_le(255, hash_table); 			/* Broadcast entry */
+	__set_bit_le(255, hash_table);			/* Broadcast entry */
 	/* This should work on big-endian machines as well. */
 	netdev_for_each_mc_addr(ha, dev) {
 		int index = ether_crc_le(ETH_ALEN, ha->addr) & 0x1ff;
 
-		set_bit_le(index, hash_table);
+		__set_bit_le(index, hash_table);
 	}
 	for (i = 0; i < 32; i++) {
 		*setup_frm++ = hash_table[i];
-- 
1.7.5.4
