From: Colin King <colin.king@canonical.com>
Subject: [PATCH][wireless-next] qtnfmac: check band before allocating cmd_skb to avoid resource leak
Date: Fri,  2 Jun 2017 16:40:45 +0100
Message-ID: <20170602154045.28948-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Igor Mitsyanko <imitsyanko@quantenna.com>,
        Avinash Patil <avinashp@quantenna.com>,
        Sergey Matyukevich <smatyukevich@quantenna.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Dmitrii Lebed <dlebed@quantenna.com>,
        Huizhao Wang <hwang@quantenna.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The current code allocates cmd_skb and then will leak this if band->band
is an illegal value. It is simpler to sanity check the band first before
allocating cmd_skb so that we don't have to free cmd_skb if an invalid
band occurs.

Detected by CoverityScan, CID#1437561 ("Resource Leak")

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/quantenna/qtnfmac/commands.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/quantenna/qtnfmac/commands.c b/drivers/net/wireless/quantenna/qtnfmac/commands.c
index f0a0cfa7d8a1..cce62f39edaf 100644
--- a/drivers/net/wireless/quantenna/qtnfmac/commands.c
+++ b/drivers/net/wireless/quantenna/qtnfmac/commands.c
@@ -1300,12 +1300,6 @@ int qtnf_cmd_get_mac_chan_info(struct qtnf_wmac *mac,
 	int ret = 0;
 	u8 qband;
 
-	cmd_skb = qtnf_cmd_alloc_new_cmdskb(mac->macid, 0,
-					    QLINK_CMD_CHANS_INFO_GET,
-					    sizeof(*cmd));
-	if (!cmd_skb)
-		return -ENOMEM;
-
 	switch (band->band) {
 	case NL80211_BAND_2GHZ:
 		qband = QLINK_BAND_2GHZ;
@@ -1320,6 +1314,12 @@ int qtnf_cmd_get_mac_chan_info(struct qtnf_wmac *mac,
 		return -EINVAL;
 	}
 
+	cmd_skb = qtnf_cmd_alloc_new_cmdskb(mac->macid, 0,
+					    QLINK_CMD_CHANS_INFO_GET,
+					    sizeof(*cmd));
+	if (!cmd_skb)
+		return -ENOMEM;
+
 	cmd = (struct qlink_cmd_chans_info_get *)cmd_skb->data;
 	cmd->band = qband;
 	ret = qtnf_cmd_send_with_reply(mac->bus, cmd_skb, &resp_skb, &res_code,
-- 
2.11.0
