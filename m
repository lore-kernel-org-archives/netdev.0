From: Stas Sergeev <stsp@list.ru>
Subject: [PATCH] mvneta: dont call mvneta_adjust_link() manually
Date: Wed, 01 Apr 2015 19:23:29 +0300
Message-ID: <551C1B81.1040706@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Linux kernel <linux-kernel@vger.kernel.org>,
	Stas Sergeev <stsp@users.sourceforge.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


mvneta_adjust_link() is a callback for of_phy_connect() and should
not be called directly. The result of calling it directly is as below:
---
 mvneta f1030000.ethernet eth1: Link is Up - Unsupported (update p
hy.c)/Half - flow control off
---

This is because initially the struct phy_device is created with
invalid parameters. phylib calls adjust_link() only when the parameters
are validated, but calling it by hands may happen too early.

CC: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
CC: netdev@vger.kernel.org
CC: linux-kernel@vger.kernel.org
CC: Florian Fainelli <f.fainelli@gmail.com>

Signed-off-by: Stas Sergeev <stsp@users.sourceforge.net>
---
 drivers/net/ethernet/marvell/mvneta.c |    7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 0e17fd0..ccb1433 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -2729,16 +2729,11 @@ static int mvneta_stop(struct net_device *dev)
 static int mvneta_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct mvneta_port *pp = netdev_priv(dev);
-	int ret;

 	if (!pp->phy_dev)
 		return -ENOTSUPP;

-	ret = phy_mii_ioctl(pp->phy_dev, ifr, cmd);
-	if (!ret)
-		mvneta_adjust_link(dev);
-
-	return ret;
+	return phy_mii_ioctl(pp->phy_dev, ifr, cmd);
 }

 /* Ethtool methods */
-- 
1.7.9.5
