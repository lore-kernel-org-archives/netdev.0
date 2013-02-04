From: Joe Perches <joe@perches.com>
Subject: [PATCH 6/8] wimax: Remove unnecessary alloc/OOM messages, alloc cleanups
Date: Sun,  3 Feb 2013 19:28:13 -0800
Message-ID: <77a7656d109fba0ad4f55e0adafe770d38d588c9.1359939013.git.joe@perches.com>
References: <cover.1359939012.git.joe@perches.com>
Cc: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>,
	linux-wimax@intel.com, wimax@linuxwimax.org,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:37948 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753872Ab3BDD3u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Feb 2013 22:29:50 -0500
In-Reply-To: <cover.1359939012.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

alloc failures already get standardized OOM
messages and a dump_stack.

Convert kzalloc's with multiplies to kcalloc.
Remove now unused size variables.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wimax/i2400m/rx.c        | 16 +++++-----------
 drivers/net/wimax/i2400m/usb-notif.c |  1 -
 2 files changed, 5 insertions(+), 12 deletions(-)

diff --git a/drivers/net/wimax/i2400m/rx.c b/drivers/net/wimax/i2400m/rx.c
index 37becfc..8077e6e 100644
--- a/drivers/net/wimax/i2400m/rx.c
+++ b/drivers/net/wimax/i2400m/rx.c
@@ -1351,24 +1351,18 @@ int i2400m_rx_setup(struct i2400m *i2400m)
 	i2400m->rx_reorder = i2400m_rx_reorder_disabled? 0 : 1;
 	if (i2400m->rx_reorder) {
 		unsigned itr;
-		size_t size;
 		struct i2400m_roq_log *rd;
 
 		result = -ENOMEM;
 
-		size = sizeof(i2400m->rx_roq[0]) * (I2400M_RO_CIN + 1);
-		i2400m->rx_roq = kzalloc(size, GFP_KERNEL);
-		if (i2400m->rx_roq == NULL) {
-			dev_err(dev, "RX: cannot allocate %zu bytes for "
-				"reorder queues\n", size);
+		i2400m->rx_roq = kcalloc(I2400M_RO_CIN + 1,
+					 sizeof(i2400m->rx_roq[0]), GFP_KERNEL);
+		if (i2400m->rx_roq == NULL)
 			goto error_roq_alloc;
-		}
 
-		size = sizeof(*i2400m->rx_roq[0].log) * (I2400M_RO_CIN + 1);
-		rd = kzalloc(size, GFP_KERNEL);
+		rd = kcalloc(I2400M_RO_CIN + 1, sizeof(*i2400m->rx_roq[0].log),
+			     GFP_KERNEL);
 		if (rd == NULL) {
-			dev_err(dev, "RX: cannot allocate %zu bytes for "
-				"reorder queues log areas\n", size);
 			result = -ENOMEM;
 			goto error_roq_log_alloc;
 		}
diff --git a/drivers/net/wimax/i2400m/usb-notif.c b/drivers/net/wimax/i2400m/usb-notif.c
index d44b545..fc1355d 100644
--- a/drivers/net/wimax/i2400m/usb-notif.c
+++ b/drivers/net/wimax/i2400m/usb-notif.c
@@ -199,7 +199,6 @@ int i2400mu_notification_setup(struct i2400mu *i2400mu)
 	d_fnstart(4, dev, "(i2400m %p)\n", i2400mu);
 	buf = kmalloc(I2400MU_MAX_NOTIFICATION_LEN, GFP_KERNEL | GFP_DMA);
 	if (buf == NULL) {
-		dev_err(dev, "notification: buffer allocation failed\n");
 		ret = -ENOMEM;
 		goto error_buf_alloc;
 	}
-- 
1.8.0.dirty
