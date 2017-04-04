From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 14/14] nfp: add support for .set_link_ksettings()
Date: Tue,  4 Apr 2017 16:12:35 -0700
Message-ID: <20170404231235.32027-15-jakub.kicinski@netronome.com>
References: <20170404231235.32027-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34649 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755291AbdDDXNF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 19:13:05 -0400
Received: by mail-pf0-f173.google.com with SMTP id 197so13822315pfv.1
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 16:13:04 -0700 (PDT)
In-Reply-To: <20170404231235.32027-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support setting link speed and autonegotiation through
set_link_ksettings() ethtool op.  If the port is reconfigured
in incompatible way and reboot is required the netdev will get
unregistered and not come back until user reboots the system.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   | 46 ++++++++++++++++++++++
 1 file changed, 46 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index 963d6dd97cec..3328041ec290 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -237,6 +237,51 @@ nfp_net_get_link_ksettings(struct net_device *netdev,
 	return 0;
 }
 
+static int
+nfp_net_set_link_ksettings(struct net_device *netdev,
+			   const struct ethtool_link_ksettings *cmd)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+	struct nfp_nsp *nsp;
+	int err;
+
+	if (!nn->eth_port)
+		return -EOPNOTSUPP;
+
+	if (netif_running(netdev)) {
+		nn_warn(nn, "Changing settings not allowed on an active interface. It may cause the port to be disabled until reboot.\n");
+		return -EBUSY;
+	}
+
+	nsp = nfp_eth_config_start(nn->cpp, nn->eth_port->index);
+	if (IS_ERR(nsp))
+		return PTR_ERR(nsp);
+
+	err = __nfp_eth_set_aneg(nsp, cmd->base.autoneg == AUTONEG_ENABLE ?
+				 NFP_ANEG_AUTO : NFP_ANEG_DISABLED);
+	if (err)
+		goto err_bad_set;
+	if (cmd->base.speed != SPEED_UNKNOWN) {
+		u32 speed = cmd->base.speed / nn->eth_port->lanes;
+
+		err = __nfp_eth_set_speed(nsp, speed);
+		if (err)
+			goto err_bad_set;
+	}
+
+	err = nfp_eth_config_commit_end(nsp);
+	if (err > 0)
+		return 0; /* no change */
+
+	nfp_net_refresh_port_config(nn);
+
+	return err;
+
+err_bad_set:
+	nfp_eth_config_cleanup_end(nsp);
+	return err;
+}
+
 static void nfp_net_get_ringparam(struct net_device *netdev,
 				  struct ethtool_ringparam *ring)
 {
@@ -879,6 +924,7 @@ static const struct ethtool_ops nfp_net_ethtool_ops = {
 	.get_channels		= nfp_net_get_channels,
 	.set_channels		= nfp_net_set_channels,
 	.get_link_ksettings	= nfp_net_get_link_ksettings,
+	.set_link_ksettings	= nfp_net_set_link_ksettings,
 };
 
 void nfp_net_set_ethtool_ops(struct net_device *netdev)
-- 
2.11.0
