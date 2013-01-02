From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] ath9k_htc: Fix skb leaks
Date: Tue,  1 Jan 2013 21:49:27 -0600
Message-ID: <1357098567-8558-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>,
	"Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>,
	Vasanthakumar Thiagarajan <vthiagar@qca.qualcomm.com>,
	Senthil Balasubramanian <senthilb@qca.qualcomm.com>,
	ath9k-devel@lists.ath9k.org, linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Running with kmemleak shows that this driver leaks every skb allocated in
routine htc_connect_service() whether the service connection succeeds or
fails.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org>
Cc: "Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>
Cc: Vasanthakumar Thiagarajan <vthiagar@qca.qualcomm.com>
Cc: Senthil Balasubramanian <senthilb@qca.qualcomm.com>
Cc: linux-wireless@vger.kernel.org
Cc: ath9k-devel@lists.ath9k.org
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/wireless/ath/ath9k/htc_hst.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath9k/htc_hst.c b/drivers/net/wireless/ath/ath9k/htc_hst.c
index 4a9570d..a304748 100644
--- a/drivers/net/wireless/ath/ath9k/htc_hst.c
+++ b/drivers/net/wireless/ath/ath9k/htc_hst.c
@@ -278,10 +278,12 @@ int htc_connect_service(struct htc_target *target,
 	if (!time_left) {
 		dev_err(target->dev, "Service connection timeout for: %d\n",
 			service_connreq->service_id);
-		return -ETIMEDOUT;
+		ret = -ETIMEDOUT;
+		goto err;
 	}
 
 	*conn_rsp_epid = target->conn_rsp_epid;
+	kfree_skb(skb);
 	return 0;
 err:
 	kfree_skb(skb);
-- 
1.7.10.4
