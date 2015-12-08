From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 2/2] netcp: add more __le32 annotations
Date: Tue, 08 Dec 2015 16:32:59 +0100
Message-ID: <6435706.peaM34LhnV@wuerfel>
References: <1578620.t1ANcREMZ8@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Wingman Kwok <w-kwok2@ti.com>,
	Murali Karicheri <m-karicheri2@ti.com>,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1578620.t1ANcREMZ8@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The handling of epib and psdata remains a bit unclear in the driver,
as we access the same fields both as CPU-endian and through DMA
from the device.

Sparse warns about this:
ti/netcp_core.c:1147:21: warning: incorrect type in assignment (different base types)
ti/netcp_core.c:1147:21:    expected unsigned int [usertype] *[assigned] epib
ti/netcp_core.c:1147:21:    got restricted __le32 *<noident>

This uses __le32 types in a few places and uses __force where the code
looks fishy. The previous patch should really have produced the correct
behavior, but this second patch is needed to shut up the warnings about
it. Ideally it would be slightly rewritten to not need those casts,
but I don't dare do that without access to the hardware for proper
testing.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/ti/netcp.h      | 2 +-
 drivers/net/ethernet/ti/netcp_core.c | 9 +++++----
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp.h b/drivers/net/ethernet/ti/netcp.h
index bb1bb72121c0..17a26a429b71 100644
--- a/drivers/net/ethernet/ti/netcp.h
+++ b/drivers/net/ethernet/ti/netcp.h
@@ -113,7 +113,7 @@ struct netcp_intf {
 #define	NETCP_PSDATA_LEN		KNAV_DMA_NUM_PS_WORDS
 struct netcp_packet {
 	struct sk_buff		*skb;
-	u32			*epib;
+	__le32			*epib;
 	u32			*psdata;
 	unsigned int		psdata_len;
 	struct netcp_intf	*netcp;
diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index eb2585e777e1..92d08eb262c2 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -1145,8 +1145,8 @@ static int netcp_tx_submit_skb(struct netcp_intf *netcp,
 	p_info.ts_context = NULL;
 	p_info.txtstamp_complete = NULL;
 	p_info.epib = desc->epib;
-	p_info.psdata = desc->psdata;
-	memset(p_info.epib, 0, KNAV_DMA_NUM_EPIB_WORDS * sizeof(u32));
+	p_info.psdata = (u32 __force *)desc->psdata;
+	memset(p_info.epib, 0, KNAV_DMA_NUM_EPIB_WORDS * sizeof(__le32));
 
 	/* Find out where to inject the packet for transmission */
 	list_for_each_entry(tx_hook, &netcp->txhook_list_head, list) {
@@ -1170,11 +1170,12 @@ static int netcp_tx_submit_skb(struct netcp_intf *netcp,
 
 	/* update descriptor */
 	if (p_info.psdata_len) {
-		u32 *psdata = p_info.psdata;
+		/* psdata points to both native-endian and device-endian data */
+		__le32 *psdata = (void __force *)p_info.psdata;
 
 		memmove(p_info.psdata, p_info.psdata + p_info.psdata_len,
 			p_info.psdata_len);
-		set_words(psdata, p_info.psdata_len, psdata);
+		set_words(p_info.psdata, p_info.psdata_len, psdata);
 		tmp |= (p_info.psdata_len & KNAV_DMA_DESC_PSLEN_MASK) <<
 			KNAV_DMA_DESC_PSLEN_SHIFT;
 	}
-- 
2.1.0.rc2
