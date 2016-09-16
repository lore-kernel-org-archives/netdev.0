From: Colin King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH][V2] mwifiex: fix null pointer deference when adapter is null
Date: Fri, 16 Sep 2016 10:37:31 +0100
Message-ID: <20160916093731.23346-1-colin.king@canonical.com>
To: Amitkumar Karwar <akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Nishant Sarmukadam <nishants-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

If adapter is null the error exit path in mwifiex_shutdown_sw is
to down the semaphore sem and print some debug via mwifiex_dbg.
However, passing a NULL adapter to mwifiex_dbg causes a null
pointer deference when accessing adapter->dev.  This fix checks
for a null adapter at the start of the function and to exit
without the need to up the semaphore and we also skip the debug
to avoid the null pointer dereference.

Signed-off-by: Colin Ian King <colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
---
 drivers/net/wireless/marvell/mwifiex/main.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/main.c b/drivers/net/wireless/marvell/mwifiex/main.c
index 9b2e98c..2478ccd 100644
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
