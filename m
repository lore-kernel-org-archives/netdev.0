From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 2/3] r8169: use Giant Send
Date: Fri, 11 Jul 2014 16:25:57 +0800
Message-ID: <1394712342-15778-12-Taiwan-albertk@realtek.com>
References: <1394712342-15778-10-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<nic_swsd@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-10-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace large send with giant send for TSO for RTL8111C and later ICs.
The large send setting of the RTL8111DP is different from the other
chips. However, the giant send setting is the same for all the chips
which support it. Use the giant send to synchronize the settings.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 6b7e21a..e5a0bdb 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -626,6 +626,10 @@ enum rtl_tx_desc_bit_0 {
 
 /* 8102e, 8168c and beyond. */
 enum rtl_tx_desc_bit_1 {
+	/* First doubleword. */
+	TD1_GTSENV4	= (1 << 26),		/* Giant Send for IPv4 */
+#define GTTCPHO_SHIFT			18
+
 	/* Second doubleword. */
 #define TD1_MSS_SHIFT			18	/* MSS position (11 bits) */
 	TD1_IP_CS	= (1 << 29),		/* Calculate IP checksum */
@@ -5941,10 +5945,12 @@ static bool rtl8169_tso_csum_v1(struct rtl8169_private *tp,
 static bool rtl8169_tso_csum_v2(struct rtl8169_private *tp,
 				struct sk_buff *skb, u32 *opts)
 {
+	u32 transport_offset = (u32)skb_transport_offset(skb);
 	u32 mss = skb_shinfo(skb)->gso_size;
 
 	if (mss) {
-		opts[0] |= TD_LSO;
+		opts[0] |= TD1_GTSENV4;
+		opts[0] |= transport_offset << GTTCPHO_SHIFT;
 		opts[1] |= min(mss, TD_MSS_MAX) << TD1_MSS_SHIFT;
 	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		const struct iphdr *ip = ip_hdr(skb);
-- 
1.9.3
