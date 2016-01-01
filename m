From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] net-libertas: Better exception handling in
 if_spi_host_to_card_worker()
Date: Fri, 1 Jan 2016 22:33:38 +0100
Message-ID: <5686F0B2.5000000@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <566ABCD9.1060404@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 1 Jan 2016 22:27:20 +0100

This issue was detected by using the Coccinelle software.

Move the jump label directly before the desired log statement
so that the variable "err" will not be checked once more
after it was determined that a function call failed.
Use the identifier "report_failure" instead of the label "err".

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/wireless/marvell/libertas/if_spi.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/marvell/libertas/if_spi.c b/drivers/net/wireless/marvell/libertas/if_spi.c
index 82c0796..c9ae27e 100644
--- a/drivers/net/wireless/marvell/libertas/if_spi.c
+++ b/drivers/net/wireless/marvell/libertas/if_spi.c
@@ -880,18 +880,18 @@ static void if_spi_host_to_card_worker(struct work_struct *work)
 				&hiStatus);
 	if (err) {
 		netdev_err(priv->dev, "I/O error\n");
-		goto err;
+		goto report_failure;
 	}
 
 	if (hiStatus & IF_SPI_HIST_CMD_UPLOAD_RDY) {
 		err = if_spi_c2h_cmd(card);
 		if (err)
-			goto err;
+			goto report_failure;
 	}
 	if (hiStatus & IF_SPI_HIST_RX_UPLOAD_RDY) {
 		err = if_spi_c2h_data(card);
 		if (err)
-			goto err;
+			goto report_failure;
 	}
 
 	/*
@@ -940,9 +940,10 @@ static void if_spi_host_to_card_worker(struct work_struct *work)
 	if (hiStatus & IF_SPI_HIST_CARD_EVENT)
 		if_spi_e2h(card);
 
-err:
-	if (err)
+	if (err) {
+report_failure:
 		netdev_err(priv->dev, "%s: got error %d\n", __func__, err);
+	}
 
 	lbs_deb_leave(LBS_DEB_SPI);
 }
-- 
2.6.3

