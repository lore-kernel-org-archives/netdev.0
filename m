From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/4 11/13] wimax/i2400m: fix oops in TX when tearing down the device
Date: Wed,  4 Nov 2009 13:40:06 -0800
Message-ID: <46c501473d0a6fa62435dfd65c6884e1fd63b327.1257370737.git.inaky@linux.intel.com>
References: <cover.1257370737.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga12.intel.com ([143.182.124.36]:45111 "EHLO
	azsmga102.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932746AbZKDVmN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:13 -0500
In-Reply-To: <cover.1257370737.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370737.git.inaky@linux.intel.com>
References: <cover.1257370737.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All the entry points into the TX module should check if the device has
been torn down. Otherwise, when the device resets or shuts down, there
are windows when a call to i2400m_tx*() will oops the system.

For that, make i2400m_tx_release() set i2400m->tx_buf to NULL under
the tx_lock. Then, any entry point [i2400m_tx(), _tx_msg_sent(),
_tx_msg_get()] will check for i2400m->tx_buf to be NULL and exit
gracefully.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/sdio-tx.c |    5 ++++-
 drivers/net/wimax/i2400m/tx.c      |   18 +++++++++++++++++-
 2 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wimax/i2400m/sdio-tx.c b/drivers/net/wimax/i2400m/sdio-tx.c
index 5105a5e..de66d06 100644
--- a/drivers/net/wimax/i2400m/sdio-tx.c
+++ b/drivers/net/wimax/i2400m/sdio-tx.c
@@ -149,5 +149,8 @@ int i2400ms_tx_setup(struct i2400ms *i2400ms)
 
 void i2400ms_tx_release(struct i2400ms *i2400ms)
 {
-	destroy_workqueue(i2400ms->tx_workqueue);
+	if (i2400ms->tx_workqueue) {
+		destroy_workqueue(i2400ms->tx_workqueue);
+		i2400ms->tx_workqueue = NULL;
+	}
 }
diff --git a/drivers/net/wimax/i2400m/tx.c b/drivers/net/wimax/i2400m/tx.c
index 8c20802..54480e8 100644
--- a/drivers/net/wimax/i2400m/tx.c
+++ b/drivers/net/wimax/i2400m/tx.c
@@ -642,6 +642,9 @@ int i2400m_tx(struct i2400m *i2400m, const void *buf, size_t buf_len,
 	 * current one is out of payload slots or we have a singleton,
 	 * close it and start a new one */
 	spin_lock_irqsave(&i2400m->tx_lock, flags);
+	result = -ESHUTDOWN;
+	if (i2400m->tx_buf == NULL)
+		goto error_tx_new;
 try_new:
 	if (unlikely(i2400m->tx_msg == NULL))
 		i2400m_tx_new(i2400m);
@@ -697,7 +700,10 @@ try_new:
 	}
 error_tx_new:
 	spin_unlock_irqrestore(&i2400m->tx_lock, flags);
-	i2400m->bus_tx_kick(i2400m);	/* always kick, might free up space */
+	/* kick in most cases, except when the TX subsys is down, as
+	 * it might free space */
+	if (likely(result != -ESHUTDOWN))
+		i2400m->bus_tx_kick(i2400m);
 	d_fnend(3, dev, "(i2400m %p skb %p [%zu bytes] pt %u) = %d\n",
 		i2400m, buf, buf_len, pl_type, result);
 	return result;
@@ -740,6 +746,9 @@ struct i2400m_msg_hdr *i2400m_tx_msg_get(struct i2400m *i2400m,
 
 	d_fnstart(3, dev, "(i2400m %p bus_size %p)\n", i2400m, bus_size);
 	spin_lock_irqsave(&i2400m->tx_lock, flags);
+	tx_msg_moved = NULL;
+	if (i2400m->tx_buf == NULL)
+		goto out_unlock;
 skip:
 	tx_msg_moved = NULL;
 	if (i2400m->tx_in == i2400m->tx_out) {	/* Empty FIFO? */
@@ -829,6 +838,8 @@ void i2400m_tx_msg_sent(struct i2400m *i2400m)
 
 	d_fnstart(3, dev, "(i2400m %p)\n", i2400m);
 	spin_lock_irqsave(&i2400m->tx_lock, flags);
+	if (i2400m->tx_buf == NULL)
+		goto out_unlock;
 	i2400m->tx_out += i2400m->tx_msg_size;
 	d_printf(2, dev, "TX: sent %zu b\n", (size_t) i2400m->tx_msg_size);
 	i2400m->tx_msg_size = 0;
@@ -837,6 +848,7 @@ void i2400m_tx_msg_sent(struct i2400m *i2400m)
 	n = i2400m->tx_out / I2400M_TX_BUF_SIZE;
 	i2400m->tx_out %= I2400M_TX_BUF_SIZE;
 	i2400m->tx_in -= n * I2400M_TX_BUF_SIZE;
+out_unlock:
 	spin_unlock_irqrestore(&i2400m->tx_lock, flags);
 	d_fnend(3, dev, "(i2400m %p) = void\n", i2400m);
 }
@@ -876,5 +888,9 @@ int i2400m_tx_setup(struct i2400m *i2400m)
  */
 void i2400m_tx_release(struct i2400m *i2400m)
 {
+	unsigned long flags;
+	spin_lock_irqsave(&i2400m->tx_lock, flags);
 	kfree(i2400m->tx_buf);
+	i2400m->tx_buf = NULL;
+	spin_unlock_irqrestore(&i2400m->tx_lock, flags);
 }
-- 
1.6.2.5

