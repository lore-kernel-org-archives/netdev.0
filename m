From: Colin King <colin.king@canonical.com>
Subject: [PATCH] mwifiex: fix null pointer deference when adapter is null
Date: Thu, 15 Sep 2016 14:42:38 +0100
Message-ID: <20160915134238.5167-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Amitkumar Karwar <akarwar@marvell.com>,
        Nishant Sarmukadam <nishants@marvell.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

If adapter is null the error exit path in mwifiex_shutdown_sw is
to down the semaphore sem and print some debug via mwifiex_dbg.
However, passing a NULL adapter to mwifiex_dbg causes a null
pointer deference when accessing adapter->dev.  This fix checks
for a null adapter at the start of the function and to exit
without the need to up the semaphore and we also skip the debug
to avoid the null pointer dereference.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/marvell/mwifiex/main.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/main.c b/drivers/net/wireless/marvell/mwifiex/main.c
index 9b2e98c..7a4f8cc 100644
--- a/drivers/net/wireless/marvell/mwifiex/main.c
+++ b/drivers/net/wireless/marvell/mwifiex/main.c
@@ -1369,12 +1369,12 @@ mwifiex_shutdown_sw(struct mwifiex_adapter *adapter, struct semaphore *sem)
 	struct mwifiex_private *priv;
 	int i;
 
+	if (!adapter)
+		goto exit_return;
+
 	if (down_interruptible(sem))
 		goto exit_sem_err;
 
-	if (!adapter)
-		goto exit_remove;
-
 	priv = mwifiex_get_priv(adapter, MWIFIEX_BSS_ROLE_ANY);
 	mwifiex_deauthenticate(priv, NULL);
 
@@ -1434,6 +1434,7 @@ mwifiex_shutdown_sw(struct mwifiex_adapter *adapter, struct semaphore *sem)
 	up(sem);
 exit_sem_err:
 	mwifiex_dbg(adapter, INFO, "%s, successful\n", __func__);
+exit_return:
 	return 0;
 }
 
-- 
2.9.3
