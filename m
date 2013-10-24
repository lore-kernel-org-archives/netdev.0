From: Leigh Brown <leigh@solinno.co.uk>
Subject: [PATCH RFC v2 3/4] net: mvmdio: slight optimisation of orion_mdio_write
Date: Thu, 24 Oct 2013 19:09:33 +0100
Message-ID: <6d044f3760cd506a325d5aab1199131ade96d632.1382637156.git.leigh@solinno.co.uk>
References: <cover.1382637156.git.leigh@solinno.co.uk>
Cc: Leigh Brown <leigh@solinno.co.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev@vger.kernel.org, sebastian.hesselbarth@gmail.com
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from doppler.thel33t.co.uk ([193.110.88.198]:51342 "EHLO
	doppler.thel33t.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755918Ab3JXSKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 14:10:10 -0400
In-Reply-To: <cover.1382637156.git.leigh@solinno.co.uk>
In-Reply-To: <cover.1382637156.git.leigh@solinno.co.uk>
References: <cover.1382199042.git.leigh@solinno.co.uk> <cover.1382637156.git.leigh@solinno.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make only a single call to mutex_unlock in orion_mdio_write.

Signed-off-by: Leigh Brown <leigh@solinno.co.uk>
---
 drivers/net/ethernet/marvell/mvmdio.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index f053475..13f4614 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -151,10 +151,8 @@ static int orion_mdio_write(struct mii_bus *bus, int mii_id,
 	mutex_lock(&dev->lock);
 
 	ret = orion_mdio_wait_ready(bus);
-	if (ret < 0) {
-		mutex_unlock(&dev->lock);
-		return ret;
-	}
+	if (ret != 0)
+		goto out;
 
 	writel(((mii_id << MVMDIO_SMI_PHY_ADDR_SHIFT) |
 		(regnum << MVMDIO_SMI_PHY_REG_SHIFT)  |
@@ -162,9 +160,9 @@ static int orion_mdio_write(struct mii_bus *bus, int mii_id,
 		(value << MVMDIO_SMI_DATA_SHIFT)),
 	       dev->regs);
 
+out:
 	mutex_unlock(&dev->lock);
-
-	return 0;
+	return ret;
 }
 
 static int orion_mdio_reset(struct mii_bus *bus)
-- 
1.7.10.4
