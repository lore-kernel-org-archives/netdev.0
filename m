From: Insu Yun <wuninsu@gmail.com>
Subject: [PATCH v2] mwifiex: correctly handling kzalloc
Date: Wed, 30 Dec 2015 11:01:44 -0500
Message-ID: <1451491304-35251-1-git-send-email-wuninsu@gmail.com>
Cc: taesoo@gatech.edu, yeongjin.jang@gatech.edu, insu@gatech.edu,
	changwoo@gatech.edu, Insu Yun <wuninsu@gmail.com>
To: akarwar@marvell.com, nishants@marvell.com, kvalo@codeaurora.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since kzalloc can be failed in memory pressure,
it needs to be handled, otherwise NULL dereference could be happened

Signed-off-by: Insu Yun <wuninsu@gmail.com>
---
 drivers/net/wireless/mwifiex/sdio.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/wireless/mwifiex/sdio.c b/drivers/net/wireless/mwifiex/sdio.c
index 78a8474..a8af72d 100644
--- a/drivers/net/wireless/mwifiex/sdio.c
+++ b/drivers/net/wireless/mwifiex/sdio.c
@@ -2053,8 +2053,19 @@ static int mwifiex_init_sdio(struct mwifiex_adapter *adapter)
 	/* Allocate skb pointer buffers */
 	card->mpa_rx.skb_arr = kzalloc((sizeof(void *)) *
 				       card->mp_agg_pkt_limit, GFP_KERNEL);
+	if (!card->mpa_rx.skb_arr) {
+		kfree(card->mp_regs);
+		return -ENOMEM;
+	}
+
 	card->mpa_rx.len_arr = kzalloc(sizeof(*card->mpa_rx.len_arr) *
 				       card->mp_agg_pkt_limit, GFP_KERNEL);
+	if (!card->mpa_rx.len_arr) {
+		kfree(card->mp_regs);
+		kfree(card->mpa_rx.skb_arr);
+		return -ENOMEM;
+	}
+
 	ret = mwifiex_alloc_sdio_mpa_buffers(adapter,
 					     card->mp_tx_agg_buf_size,
 					     card->mp_rx_agg_buf_size);
-- 
1.9.1
