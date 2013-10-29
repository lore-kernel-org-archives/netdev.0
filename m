From: Leigh Brown <leigh@solinno.co.uk>
Subject: [PATCH v3 1/4] net: mvmdio: make orion_mdio_wait_ready consistent
Date: Tue, 29 Oct 2013 09:33:31 +0000
Message-ID: <c47088ae4c066fea9b012db513baffb0294011a9.1383038973.git.leigh@solinno.co.uk>
References: <cover.1383038973.git.leigh@solinno.co.uk>
Cc: Leigh Brown <leigh@solinno.co.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Jason Cooper <jason@lakedaemon.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from doppler.thel33t.co.uk ([193.110.88.198]:58152 "EHLO
	doppler.thel33t.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753888Ab3J2JeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 05:34:02 -0400
In-Reply-To: <cover.1383038973.git.leigh@solinno.co.uk>
In-Reply-To: <cover.1383038973.git.leigh@solinno.co.uk>
References: <cover.1382637156.git.leigh@solinno.co.uk> <cover.1383038973.git.leigh@solinno.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Amend orion_mdio_wait_ready so that the same timeout is used when
polling or using wait_event_timeout.  Set the timeout to 1ms.

Replace udelay with usleep_range to avoid a busy loop, and set the
polling interval range as 45us to 55us, so that the first sleep
will be enough in almost all cases.

Generate the same log message at timeout when polling or using
wait_event_timeout.

Signed-off-by: Leigh Brown <leigh@solinno.co.uk>
---
 drivers/net/ethernet/marvell/mvmdio.c | 52 ++++++++++++++++++++---------------
 1 file changed, 30 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index e2f6626..971a4c1 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -44,6 +44,15 @@
 #define  MVMDIO_ERR_INT_SMI_DONE	   0x00000010
 #define MVMDIO_ERR_INT_MASK		   0x0080
 
+/*
+ * SMI Timeout measurements:
+ * - Kirkwood 88F6281 (Globalscale Dreamplug): 45us to 95us (Interrupt)
+ * - Armada 370       (Globalscale Mirabox):   41us to 43us (Polled)
+ */
+#define MVMDIO_SMI_TIMEOUT		   1000 /* 1000us = 1ms */
+#define MVMDIO_SMI_POLL_INTERVAL_MIN	   45
+#define MVMDIO_SMI_POLL_INTERVAL_MAX	   55
+
 struct orion_mdio_dev {
 	struct mutex lock;
 	void __iomem *regs;
@@ -68,34 +77,33 @@ static int orion_mdio_smi_is_done(struct orion_mdio_dev *dev)
 static int orion_mdio_wait_ready(struct mii_bus *bus)
 {
 	struct orion_mdio_dev *dev = bus->priv;
-	int count;
+	unsigned long timeout = usecs_to_jiffies(MVMDIO_SMI_TIMEOUT);
+	unsigned long end = jiffies + timeout;
+	int timedout = 0;
 
-	if (dev->err_interrupt <= 0) {
-		count = 0;
-		while (1) {
-			if (orion_mdio_smi_is_done(dev))
-				break;
+	while (1) {
+	        if (orion_mdio_smi_is_done(dev))
+			return 0;
+	        else if (timedout)
+			break;
 
-			if (count > 100) {
-				dev_err(bus->parent,
-					"Timeout: SMI busy for too long\n");
-				return -ETIMEDOUT;
-			}
+	        if (dev->err_interrupt <= 0) {
+			usleep_range(MVMDIO_SMI_POLL_INTERVAL_MIN,
+				     MVMDIO_SMI_POLL_INTERVAL_MAX);
 
-			udelay(10);
-			count++;
-		}
-	} else {
-		if (!orion_mdio_smi_is_done(dev)) {
+			if (time_is_before_jiffies(end))
+				++timedout;
+	        } else {
 			wait_event_timeout(dev->smi_busy_wait,
-				orion_mdio_smi_is_done(dev),
-				msecs_to_jiffies(100));
-			if (!orion_mdio_smi_is_done(dev))
-				return -ETIMEDOUT;
-		}
+				           orion_mdio_smi_is_done(dev),
+				           timeout);
+
+			++timedout;
+	        }
 	}
 
-	return 0;
+	dev_err(bus->parent, "Timeout: SMI busy for too long\n");
+	return  -ETIMEDOUT;
 }
 
 static int orion_mdio_read(struct mii_bus *bus, int mii_id,
-- 
1.8.4.rc3
