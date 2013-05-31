From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: Re: BQL-related tg3 transmit timeout on 5720 / Dell R720
Date: Thu, 30 May 2013 17:51:31 -0700
Message-ID: <51A7F413.5070702@broadcom.com>
References: <CAL1RGDW=SC3E9VvQXki0Gajj0xBqwHjBWM95k00J6zn1tF1mgg@mail.gmail.com>
 <51A7638A.5030108@broadcom.com>
 <CAG4TOxPy1mkY68sO=SttS78evL1dkFZ4ZNUUOnKPmUjifq-92Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary=------------040808090407090204050403
Cc: "Michael Chan" <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Roland Dreier" <roland@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1534 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750890Ab3EaAwH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 May 2013 20:52:07 -0400
In-Reply-To: <CAG4TOxPy1mkY68sO=SttS78evL1dkFZ4ZNUUOnKPmUjifq-92Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--------------040808090407090204050403
Content-Type: text/plain;
 charset=iso-8859-1;
 format=flowed
Content-Transfer-Encoding: 7bit


On 05/30/2013 09:19 AM, Roland Dreier wrote:
> On Thu, May 30, 2013 at 7:34 AM, Nithin Nayak Sujir <nsujir@broadcom.com> wrote:
>> Is the 5720 a NIC or a LOM? If it's a NIC would it be possible to try it on
>> a different system to see if the behaviour depends on the system at all?
>
> This is the LOM.  On the Dell it's a daughtercard but I don't think
> it's user-replaceable.
>
> In other words, sorry, I don't think I can try it on a different system.
>
>   - R.
>

Could you test the attached patch on top of net-next?

Nithin.


--------------040808090407090204050403
Content-Type: text/plain;
 name=0001-tg3-Add-read-dma-workaround-for-5720.patch
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename=0001-tg3-Add-read-dma-workaround-for-5720.patch

>From cdcf043fccebfe57ae6f1c04f9b15dbc8046ac69 Mon Sep 17 00:00:00 2001
From: Nithin Nayak Sujir <nsujir@broadcom.com>
Date: Thu, 30 May 2013 16:16:43 -0700
Subject: [PATCH] tg3: Add read dma workaround for 5720

Commit 091f0ea30074bc43f9250961b3247af713024bc6 "tg3: Add New 5719 Read
DMA workaround" added a workaround for TX DMA stall on the 5719. This
workaround needs to be applied to the 5720 as well.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 21 +++++++++++++++------
 drivers/net/ethernet/broadcom/tg3.h |  5 +++--
 2 files changed, 18 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index d7755d8..7e24137 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -9568,6 +9568,14 @@ static void tg3_rss_write_indir_tbl(struct tg3 *tp)
 	}
 }
 
+static inline u32 tg3_lso_rd_dma_workaround_bit(struct tg3 *tp)
+{
+	if (tg3_asic_rev(tp) == ASIC_REV_5719)
+		return TG3_LSO_RD_DMA_TX_LENGTH_WA_5719;
+	else
+		return TG3_LSO_RD_DMA_TX_LENGTH_WA_5720;
+}
+
 /* tp->lock is held. */
 static int tg3_reset_hw(struct tg3 *tp, bool reset_phy)
 {
@@ -10224,16 +10232,17 @@ static int tg3_reset_hw(struct tg3 *tp, bool reset_phy)
 	tw32_f(RDMAC_MODE, rdmac_mode);
 	udelay(40);
 
-	if (tg3_asic_rev(tp) == ASIC_REV_5719) {
+	if (tg3_asic_rev(tp) == ASIC_REV_5719 ||
+	    tg3_asic_rev(tp) == ASIC_REV_5720) {
 		for (i = 0; i < TG3_NUM_RDMA_CHANNELS; i++) {
 			if (tr32(TG3_RDMA_LENGTH + (i << 2)) > TG3_MAX_MTU(tp))
 				break;
 		}
 		if (i < TG3_NUM_RDMA_CHANNELS) {
 			val = tr32(TG3_LSO_RD_DMA_CRPTEN_CTRL);
-			val |= TG3_LSO_RD_DMA_TX_LENGTH_WA;
+			val |= tg3_lso_rd_dma_workaround_bit(tp);
 			tw32(TG3_LSO_RD_DMA_CRPTEN_CTRL, val);
-			tg3_flag_set(tp, 5719_RDMA_BUG);
+			tg3_flag_set(tp, 5719_5720_RDMA_BUG);
 		}
 	}
 
@@ -10597,15 +10606,15 @@ static void tg3_periodic_fetch_stats(struct tg3 *tp)
 	TG3_STAT_ADD32(&sp->tx_ucast_packets, MAC_TX_STATS_UCAST);
 	TG3_STAT_ADD32(&sp->tx_mcast_packets, MAC_TX_STATS_MCAST);
 	TG3_STAT_ADD32(&sp->tx_bcast_packets, MAC_TX_STATS_BCAST);
-	if (unlikely(tg3_flag(tp, 5719_RDMA_BUG) &&
+	if (unlikely(tg3_flag(tp, 5719_5720_RDMA_BUG) &&
 		     (sp->tx_ucast_packets.low + sp->tx_mcast_packets.low +
 		      sp->tx_bcast_packets.low) > TG3_NUM_RDMA_CHANNELS)) {
 		u32 val;
 
 		val = tr32(TG3_LSO_RD_DMA_CRPTEN_CTRL);
-		val &= ~TG3_LSO_RD_DMA_TX_LENGTH_WA;
+		val &= ~tg3_lso_rd_dma_workaround_bit(tp);
 		tw32(TG3_LSO_RD_DMA_CRPTEN_CTRL, val);
-		tg3_flag_clear(tp, 5719_RDMA_BUG);
+		tg3_flag_clear(tp, 5719_5720_RDMA_BUG);
 	}
 
 	TG3_STAT_ADD32(&sp->rx_octets, MAC_RX_STATS_OCTETS);
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 2530c20..cd63d11 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -1423,7 +1423,8 @@
 #define TG3_LSO_RD_DMA_CRPTEN_CTRL	0x00004910
 #define TG3_LSO_RD_DMA_CRPTEN_CTRL_BLEN_BD_4K	 0x00030000
 #define TG3_LSO_RD_DMA_CRPTEN_CTRL_BLEN_LSO_4K	 0x000c0000
-#define TG3_LSO_RD_DMA_TX_LENGTH_WA	 0x02000000
+#define TG3_LSO_RD_DMA_TX_LENGTH_WA_5719	 0x02000000
+#define TG3_LSO_RD_DMA_TX_LENGTH_WA_5720	 0x00200000
 /* 0x4914 --> 0x4be0 unused */
 
 #define TG3_NUM_RDMA_CHANNELS		4
@@ -3060,7 +3061,7 @@ enum TG3_FLAGS {
 	TG3_FLAG_APE_HAS_NCSI,
 	TG3_FLAG_TX_TSTAMP_EN,
 	TG3_FLAG_4K_FIFO_LIMIT,
-	TG3_FLAG_5719_RDMA_BUG,
+	TG3_FLAG_5719_5720_RDMA_BUG,
 	TG3_FLAG_RESET_TASK_PENDING,
 	TG3_FLAG_PTP_CAPABLE,
 	TG3_FLAG_5705_PLUS,
-- 
1.8.1.4


--------------040808090407090204050403--
