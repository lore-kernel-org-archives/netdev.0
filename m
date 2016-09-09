From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH v2 3/3] net: fs_enet: make rx_copybreak value configurable
Date: Fri,  9 Sep 2016 14:26:25 +0200 (CEST)
Message-ID: <26d42fa7ad67a8d9779440779a429db3b078b392.1473422536.git.christophe.leroy@c-s.fr>
References: <cover.1473422536.git.christophe.leroy@c-s.fr>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        netdev@vger.kernel.org
To: Pantelis Antoniou <pantelis.antoniou@gmail.com>,
        Vitaly Bordug <vbordug@ru.mvista.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1473422536.git.christophe.leroy@c-s.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Measurement shows that on a MPC8xx running at 132MHz, the optimal
limit is 112:
* 114 bytes packets are processed in 147 TB ticks with higher copybreak
* 114 bytes packets are processed in 148 TB ticks with lower copybreak
* 128 bytes packets are processed in 154 TB ticks with higher copybreak
* 128 bytes packets are processed in 148 TB ticks with lower copybreak
* 238 bytes packets are processed in 172 TB ticks with higher copybreak
* 238 bytes packets are processed in 148 TB ticks with lower copybreak

However it might be different on other processors
and/or frequencies. So it is useful to make it configurable.

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
v2: ethtool parameter instead of module parameter

 .../net/ethernet/freescale/fs_enet/fs_enet-main.c  | 40 ++++++++++++++++++++++
 1 file changed, 40 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index f2a60cd..dc120c1 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -830,6 +830,44 @@ static void fs_set_msglevel(struct net_device *dev, u32 value)
 	fep->msg_enable = value;
 }
 
+static int fs_get_tunable(struct net_device *dev,
+			  const struct ethtool_tunable *tuna, void *data)
+{
+	struct fs_enet_private *fep = netdev_priv(dev);
+	struct fs_platform_info *fpi = fep->fpi;
+	int ret = 0;
+
+	switch (tuna->id) {
+	case ETHTOOL_RX_COPYBREAK:
+		*(u32 *)data = fpi->rx_copybreak;
+		break;
+	default:
+		ret = -EINVAL;
+		break;
+	}
+
+	return ret;
+}
+
+static int fs_set_tunable(struct net_device *dev,
+			  const struct ethtool_tunable *tuna, const void *data)
+{
+	struct fs_enet_private *fep = netdev_priv(dev);
+	struct fs_platform_info *fpi = fep->fpi;
+	int ret = 0;
+
+	switch (tuna->id) {
+	case ETHTOOL_RX_COPYBREAK:
+		fpi->rx_copybreak = *(u32 *)data;
+		break;
+	default:
+		ret = -EINVAL;
+		break;
+	}
+
+	return ret;
+}
+
 static const struct ethtool_ops fs_ethtool_ops = {
 	.get_drvinfo = fs_get_drvinfo,
 	.get_regs_len = fs_get_regs_len,
@@ -841,6 +879,8 @@ static const struct ethtool_ops fs_ethtool_ops = {
 	.get_ts_info = ethtool_op_get_ts_info,
 	.get_link_ksettings = phy_ethtool_get_link_ksettings,
 	.set_link_ksettings = phy_ethtool_set_link_ksettings,
+	.get_tunable = fs_get_tunable,
+	.set_tunable = fs_set_tunable,
 };
 
 static int fs_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
-- 
2.1.0
