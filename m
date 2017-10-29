From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] wimax/i2400m: Use common error handling code in
 i2400m_wake_tx_work()
Date: Sun, 29 Oct 2017 18:06:00 +0100
Message-ID: <62ad3417-8297-b763-ae49-bb8c097c2679@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: netdev@vger.kernel.org, linux-wimax@intel.com,
        Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 29 Oct 2017 18:00:17 +0100

Adjust jump targets so that a bit of exception handling can be better
reused at the end of this function.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/wimax/i2400m/netdev.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wimax/i2400m/netdev.c b/drivers/net/wimax/i2400m/netdev.c
index a654687b5fa2..e3acdd295f12 100644
--- a/drivers/net/wimax/i2400m/netdev.c
+++ b/drivers/net/wimax/i2400m/netdev.c
@@ -181,8 +181,7 @@ void i2400m_wake_tx_work(struct work_struct *ws)
 	if (result < 0) {
 		dev_err(dev, "WAKE&TX: device didn't get out of idle: "
 			"%d - resetting\n", result);
-		i2400m_reset(i2400m, I2400M_RT_BUS);
-		goto error;
+		goto reset_i2400m;
 	}
 	result = wait_event_timeout(i2400m->state_wq,
 				    i2400m->state != I2400M_SS_IDLE,
@@ -192,12 +191,11 @@ void i2400m_wake_tx_work(struct work_struct *ws)
 	if (result < 0) {
 		dev_err(dev, "WAKE&TX: error waiting for device to exit IDLE: "
 			"%d - resetting\n", result);
-		i2400m_reset(i2400m, I2400M_RT_BUS);
-		goto error;
+		goto reset_i2400m;
 	}
 	msleep(20);	/* device still needs some time or it drops it */
 	result = i2400m_tx(i2400m, skb->data, skb->len, I2400M_PT_DATA);
-error:
+wake_queue:
 	netif_wake_queue(net_dev);
 out_kfree:
 	kfree_skb(skb);	/* refcount transferred by _hard_start_xmit() */
@@ -205,6 +203,11 @@ void i2400m_wake_tx_work(struct work_struct *ws)
 	i2400m_put(i2400m);
 	d_fnend(3, dev, "(ws %p i2400m %p skb %p) = void [%d]\n",
 		ws, i2400m, skb, result);
+	return;
+
+reset_i2400m:
+	i2400m_reset(i2400m, I2400M_RT_BUS);
+	goto wake_queue;
 }
 
 
-- 
2.14.3
