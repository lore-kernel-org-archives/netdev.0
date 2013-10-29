From: Leigh Brown <leigh@solinno.co.uk>
Subject: [PATCH v3 3/4] net: mvmdio: slight optimisation of orion_mdio_write
Date: Tue, 29 Oct 2013 09:33:33 +0000
Message-ID: <892347afda1ebf28fe888cc8b5f97497971084fa.1383038974.git.leigh@solinno.co.uk>
References: <cover.1383038973.git.leigh@solinno.co.uk>
Cc: Leigh Brown <leigh@solinno.co.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Jason Cooper <jason@lakedaemon.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from doppler.thel33t.co.uk ([193.110.88.198]:58159 "EHLO
	doppler.thel33t.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753894Ab3J2JeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 05:34:02 -0400
In-Reply-To: <cover.1383038973.git.leigh@solinno.co.uk>
In-Reply-To: <cover.1383038973.git.leigh@solinno.co.uk>
References: <cover.1382637156.git.leigh@solinno.co.uk> <cover.1383038973.git.leigh@solinno.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make only a single call to mutex_unlock in orion_mdio_write.

Signed-off-by: Leigh Brown <leigh@solinno.co.uk>
---
 drivers/net/ethernet/marvell/mvmdio.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index e3898b3..0cfa0c8 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -150,10 +150,8 @@ static int orion_mdio_write(struct mii_bus *bus, int mii_id,
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
@@ -161,9 +159,9 @@ static int orion_mdio_write(struct mii_bus *bus, int mii_id,
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
1.8.4.rc3
