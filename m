From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [2.6.31 02/21] wimax/i2400m: don't call netif_start_queue() in _tx_msg_sent()
Date: Thu, 11 Jun 2009 14:35:39 -0700
Message-ID: <fff1068559a2ae00a036b80c5df3c564fc6c6305.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:17677 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751567AbZFKVgh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 17:36:37 -0400
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported and fixed by Cindy H Kao.

When the device is stopped __i2400m_dev_stop() stops the network
queue.

However, when this is done in the middle of heavy network operation,
when the bus-specific subdriver is still wrapping up and it reports a
sent TX transaction with _tx_msg_sent() right after the device was
stopped, the queue was being started again, which was causing a stream
of oopsen and finally a panic.

In any case, said call has no place there. It's a left over from an
early implementation that was discarded later on.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/tx.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wimax/i2400m/tx.c b/drivers/net/wimax/i2400m/tx.c
index 613a88f..8ef724d 100644
--- a/drivers/net/wimax/i2400m/tx.c
+++ b/drivers/net/wimax/i2400m/tx.c
@@ -773,7 +773,6 @@ void i2400m_tx_msg_sent(struct i2400m *i2400m)
 	n = i2400m->tx_out / I2400M_TX_BUF_SIZE;
 	i2400m->tx_out %= I2400M_TX_BUF_SIZE;
 	i2400m->tx_in -= n * I2400M_TX_BUF_SIZE;
-	netif_start_queue(i2400m->wimax_dev.net_dev);
 	spin_unlock_irqrestore(&i2400m->tx_lock, flags);
 	d_fnend(3, dev, "(i2400m %p) = void\n", i2400m);
 }
-- 
1.6.2.3

