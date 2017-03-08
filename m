From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: hyperv: use new api ethtool_{get|set}_link_ksettings
Date: Wed,  8 Mar 2017 23:41:04 +0100
Message-ID: <1489012864-30810-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, Philippe Reynes <tremyfr@gmail.com>,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com,
 davem@davemloft.net
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/hyperv/netvsc_drv.c |   39 +++++++++++++++++++++------------------
 1 files changed, 21 insertions(+), 18 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 617dd90..b12808a 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -789,18 +789,19 @@ static int netvsc_set_channels(struct net_device *net,
 	return ret;
 }
 
-static bool netvsc_validate_ethtool_ss_cmd(const struct ethtool_cmd *cmd)
+static bool
+netvsc_validate_ethtool_ss_cmd(const struct ethtool_link_ksettings *cmd)
 {
-	struct ethtool_cmd diff1 = *cmd;
-	struct ethtool_cmd diff2 = {};
+	struct ethtool_link_ksettings diff1 = *cmd;
+	struct ethtool_link_ksettings diff2 = {};
 
-	ethtool_cmd_speed_set(&diff1, 0);
-	diff1.duplex = 0;
+	diff1.base.speed = 0;
+	diff1.base.duplex = 0;
 	/* advertising and cmd are usually set */
-	diff1.advertising = 0;
-	diff1.cmd = 0;
+	ethtool_link_ksettings_zero_link_mode(&diff1, advertising);
+	diff1.base.cmd = 0;
 	/* We set port to PORT_OTHER */
-	diff2.port = PORT_OTHER;
+	diff2.base.port = PORT_OTHER;
 
 	return !memcmp(&diff1, &diff2, sizeof(diff1));
 }
@@ -813,30 +814,32 @@ static void netvsc_init_settings(struct net_device *dev)
 	ndc->duplex = DUPLEX_UNKNOWN;
 }
 
-static int netvsc_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int netvsc_get_link_ksettings(struct net_device *dev,
+				     struct ethtool_link_ksettings *cmd)
 {
 	struct net_device_context *ndc = netdev_priv(dev);
 
-	ethtool_cmd_speed_set(cmd, ndc->speed);
-	cmd->duplex = ndc->duplex;
-	cmd->port = PORT_OTHER;
+	cmd->base.speed = ndc->speed;
+	cmd->base.duplex = ndc->duplex;
+	cmd->base.port = PORT_OTHER;
 
 	return 0;
 }
 
-static int netvsc_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int netvsc_set_link_ksettings(struct net_device *dev,
+				     const struct ethtool_link_ksettings *cmd)
 {
 	struct net_device_context *ndc = netdev_priv(dev);
 	u32 speed;
 
-	speed = ethtool_cmd_speed(cmd);
+	speed = cmd->base.speed;
 	if (!ethtool_validate_speed(speed) ||
-	    !ethtool_validate_duplex(cmd->duplex) ||
+	    !ethtool_validate_duplex(cmd->base.duplex) ||
 	    !netvsc_validate_ethtool_ss_cmd(cmd))
 		return -EINVAL;
 
 	ndc->speed = speed;
-	ndc->duplex = cmd->duplex;
+	ndc->duplex = cmd->base.duplex;
 
 	return 0;
 }
@@ -1170,13 +1173,13 @@ static int netvsc_set_rxfh(struct net_device *dev, const u32 *indir,
 	.get_channels   = netvsc_get_channels,
 	.set_channels   = netvsc_set_channels,
 	.get_ts_info	= ethtool_op_get_ts_info,
-	.get_settings	= netvsc_get_settings,
-	.set_settings	= netvsc_set_settings,
 	.get_rxnfc	= netvsc_get_rxnfc,
 	.get_rxfh_key_size = netvsc_get_rxfh_key_size,
 	.get_rxfh_indir_size = netvsc_rss_indir_size,
 	.get_rxfh	= netvsc_get_rxfh,
 	.set_rxfh	= netvsc_set_rxfh,
+	.get_link_ksettings = netvsc_get_link_ksettings,
+	.set_link_ksettings = netvsc_set_link_ksettings,
 };
 
 static const struct net_device_ops device_ops = {
-- 
1.7.4.4
