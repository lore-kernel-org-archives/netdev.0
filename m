From: Leigh Brown <leigh@solinno.co.uk>
Subject: [PATCH RFC 1/4] net: mvmdio: make orion_mdio_wait_ready consistent
Date: Sat, 19 Oct 2013 17:23:51 +0100
Message-ID: <3acbec7a5077d1375777e26cd808b787eb677fb3.1382199042.git.leigh@solinno.co.uk>
References: <cover.1382199042.git.leigh@solinno.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 netdev@vger.kernel.org, Leigh Brown <leigh@solinno.co.uk>
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <cover.1382199042.git.leigh@solinno.co.uk>
In-Reply-To: <cover.1382199042.git.leigh@solinno.co.uk>
References: <cover.1382199042.git.leigh@solinno.co.uk>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Amend orion_mdio_wait_ready so that the same timeout is used when
polling or using wait_event_timeout.  Set the timeout to 10ms.

Generate the same log message at timeout when polling or using
wait_event_timeout.

Signed-off-by: Leigh Brown <leigh@solinno.co.uk>
---
 drivers/net/ethernet/marvell/mvmdio.c |   41 ++++++++++++++++++---------------
 1 file changed, 22 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index e2f6626..11e6415 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -44,6 +44,13 @@
 #define  MVMDIO_ERR_INT_SMI_DONE	   0x00000010
 #define MVMDIO_ERR_INT_MASK		   0x0080
 
+/* 
+ * Testing on a Dreamplug showed that the SMI interface took an average of 
+ * 3.2ms to respond, with a maximum time of 4.9ms.
+ */
+#define MVMDIO_SMI_TIMEOUT		   10000 /* 10000us = 10ms */
+#define MVMDIO_SMI_POLL_INTERVAL	   10
+
 struct orion_mdio_dev {
 	struct mutex lock;
 	void __iomem *regs;
@@ -70,32 +77,28 @@ static int orion_mdio_wait_ready(struct mii_bus *bus)
 	struct orion_mdio_dev *dev = bus->priv;
 	int count;
 
-	if (dev->err_interrupt <= 0) {
-		count = 0;
-		while (1) {
+	if (dev->err_interrupt <= 0)
+		for (count = MVMDIO_SMI_TIMEOUT / MVMDIO_SMI_POLL_INTERVAL;
+		     count > 0;
+		     --count) {
 			if (orion_mdio_smi_is_done(dev))
-				break;
-
-			if (count > 100) {
-				dev_err(bus->parent,
-					"Timeout: SMI busy for too long\n");
-				return -ETIMEDOUT;
-			}
+				return 0;
 
-			udelay(10);
-			count++;
+			udelay(MVMDIO_SMI_POLL_INTERVAL);
 		}
-	} else {
-		if (!orion_mdio_smi_is_done(dev)) {
+	else {
+		if (!orion_mdio_smi_is_done(dev))
 			wait_event_timeout(dev->smi_busy_wait,
 				orion_mdio_smi_is_done(dev),
-				msecs_to_jiffies(100));
-			if (!orion_mdio_smi_is_done(dev))
-				return -ETIMEDOUT;
-		}
+				usecs_to_jiffies(MVMDIO_SMI_TIMEOUT));
+
+		if (orion_mdio_smi_is_done(dev))
+			return 0;
 	}
 
-	return 0;
+	dev_err(bus->parent,
+		"Timeout: SMI busy for too long\n");
+	return -ETIMEDOUT;
 }
 
 static int orion_mdio_read(struct mii_bus *bus, int mii_id,
-- 
1.7.10.4
