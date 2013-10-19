From: Leigh Brown <leigh@solinno.co.uk>
Subject: [PATCH RFC 2/4] net: mvmdio: orion_mdio_ready: remove manual poll
Date: Sat, 19 Oct 2013 17:23:52 +0100
Message-ID: <900994d49c3f351aa52aadee096ef646d88a2d0e.1382199042.git.leigh@solinno.co.uk>
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

Replace manual poll of MVMDIO_SMI_READ_VALID with a call to
orion_mdio_wait_ready.  This ensures a consistent timeout
and avoids a busy loop where the hardware supports it.

Signed-off-by: Leigh Brown <leigh@solinno.co.uk>
---
 drivers/net/ethernet/marvell/mvmdio.c |   34 +++++++++++++--------------------
 1 file changed, 13 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index 11e6415..56185fb 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -105,43 +105,35 @@ static int orion_mdio_read(struct mii_bus *bus, int mii_id,
 			   int regnum)
 {
 	struct orion_mdio_dev *dev = bus->priv;
-	int count;
 	u32 val;
 	int ret;
 
 	mutex_lock(&dev->lock);
 
 	ret = orion_mdio_wait_ready(bus);
-	if (ret < 0) {
-		mutex_unlock(&dev->lock);
-		return ret;
-	}
+	if (ret < 0)
+		goto out;
 
 	writel(((mii_id << MVMDIO_SMI_PHY_ADDR_SHIFT) |
 		(regnum << MVMDIO_SMI_PHY_REG_SHIFT)  |
 		MVMDIO_SMI_READ_OPERATION),
 	       dev->regs);
 
-	/* Wait for the value to become available */
-	count = 0;
-	while (1) {
-		val = readl(dev->regs);
-		if (val & MVMDIO_SMI_READ_VALID)
-			break;
-
-		if (count > 100) {
-			dev_err(bus->parent, "Timeout when reading PHY\n");
-			mutex_unlock(&dev->lock);
-			return -ETIMEDOUT;
-		}
+	ret = orion_mdio_wait_ready(bus);
+	if (ret < 0)
+		goto out;
 
-		udelay(10);
-		count++;
+	val = readl(dev->regs);
+	if (!(val & MVMDIO_SMI_READ_VALID)) {
+		dev_err(bus->parent, "SMI bus read not valid\n");
+		ret = -ENODEV;
+		goto out;
 	}
 
+	ret = val & 0xFFFF;
+out:
 	mutex_unlock(&dev->lock);
-
-	return val & 0xFFFF;
+	return ret;
 }
 
 static int orion_mdio_write(struct mii_bus *bus, int mii_id,
-- 
1.7.10.4
