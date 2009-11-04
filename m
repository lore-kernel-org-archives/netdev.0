From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/5 05/12] wimax/i2400m: fix device getting stuck in IDLE mode
Date: Wed,  4 Nov 2009 13:40:10 -0800
Message-ID: <5ab5a7215a0cfd40572a9f09276ebcb071ee6fb7.1257370738.git.inaky@linux.intel.com>
References: <cover.1257370738.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:28864 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932795AbZKDVmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:19 -0500
In-Reply-To: <cover.1257370738.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370738.git.inaky@linux.intel.com>
References: <cover.1257370738.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The i2400m, when conected, will negotiate with the WiMAX basestation
to put the link in IDLE mode when it is not being used. Upon RX/TX
traffic, the link has to be restablished and that might require some
crypto handshakes and maybe a DHCP renew.

This process might take up to 20 (!) seconds and in some cases we were
seeing network watchdog warnings that weren't needed.

So the network watchdog timeout is updated to be slightly above that
20s threshold. As well, the driver itself will double check if the
device is stuck in IDLE mode -- if that happens, the device will be
reset (in this case the queue is also woken up to remove bogus--once
the device is reset--warnings).

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/netdev.c |   17 ++++++++++++++---
 1 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wimax/i2400m/netdev.c b/drivers/net/wimax/i2400m/netdev.c
index f67af42..599aa4e 100644
--- a/drivers/net/wimax/i2400m/netdev.c
+++ b/drivers/net/wimax/i2400m/netdev.c
@@ -89,7 +89,10 @@ enum {
 	 * The MTU is 1400 or less
 	 */
 	I2400M_MAX_MTU = 1400,
-	I2400M_TX_TIMEOUT = HZ,
+	/* 20 secs? yep, this is the maximum timeout that the device
+	 * might take to get out of IDLE / negotiate it with the base
+	 * station. We add 1sec for good measure. */
+	I2400M_TX_TIMEOUT = 21 * HZ,
 	I2400M_TX_QLEN = 5,
 };
 
@@ -151,6 +154,7 @@ void i2400m_wake_tx_work(struct work_struct *ws)
 {
 	int result;
 	struct i2400m *i2400m = container_of(ws, struct i2400m, wake_tx_ws);
+	struct net_device *net_dev = i2400m->wimax_dev.net_dev;
 	struct device *dev = i2400m_dev(i2400m);
 	struct sk_buff *skb = i2400m->wake_tx_skb;
 	unsigned long flags;
@@ -166,6 +170,11 @@ void i2400m_wake_tx_work(struct work_struct *ws)
 		dev_err(dev, "WAKE&TX: skb dissapeared!\n");
 		goto out_put;
 	}
+	/* If we have, somehow, lost the connection after this was
+	 * queued, don't do anything; this might be the device got
+	 * reset or just disconnected. */
+	if (unlikely(!netif_carrier_ok(net_dev)))
+		goto out_kfree;
 	result = i2400m_cmd_exit_idle(i2400m);
 	if (result == -EILSEQ)
 		result = 0;
@@ -176,7 +185,8 @@ void i2400m_wake_tx_work(struct work_struct *ws)
 		goto error;
 	}
 	result = wait_event_timeout(i2400m->state_wq,
-				    i2400m->state != I2400M_SS_IDLE, 5 * HZ);
+				    i2400m->state != I2400M_SS_IDLE,
+				    net_dev->watchdog_timeo - HZ/2);
 	if (result == 0)
 		result = -ETIMEDOUT;
 	if (result < 0) {
@@ -187,8 +197,9 @@ void i2400m_wake_tx_work(struct work_struct *ws)
 	}
 	msleep(20);	/* device still needs some time or it drops it */
 	result = i2400m_tx(i2400m, skb->data, skb->len, I2400M_PT_DATA);
-	netif_wake_queue(i2400m->wimax_dev.net_dev);
 error:
+	netif_wake_queue(net_dev);
+out_kfree:
 	kfree_skb(skb);	/* refcount transferred by _hard_start_xmit() */
 out_put:
 	i2400m_put(i2400m);
-- 
1.6.2.5

