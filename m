From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 06/14] nfp: report link speed from NSP
Date: Tue,  4 Apr 2017 16:12:27 -0700
Message-ID: <20170404231235.32027-7-jakub.kicinski@netronome.com>
References: <20170404231235.32027-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:32932 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753511AbdDDXM7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 19:12:59 -0400
Received: by mail-pf0-f172.google.com with SMTP id s16so25016163pfs.0
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 16:12:58 -0700 (PDT)
In-Reply-To: <20170404231235.32027-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On the PF prefer the link speed value provided by the NSP.
Refresh port table if needed.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index d3cec0d4a978..0fdc14e7b576 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -49,6 +49,7 @@
 #include <linux/ethtool.h>
 
 #include "nfpcore/nfp.h"
+#include "nfpcore/nfp_nsp_eth.h"
 #include "nfp_net_ctrl.h"
 #include "nfp_net.h"
 
@@ -205,6 +206,16 @@ nfp_net_get_link_ksettings(struct net_device *netdev,
 	if (!netif_carrier_ok(netdev))
 		return 0;
 
+	/* Use link speed from ETH table if available, otherwise try the BAR */
+	if (nn->eth_port && nfp_net_link_changed_read_clear(nn))
+		nfp_net_refresh_port_config(nn);
+	/* Separate if - on FW error the port could've disappeared from table */
+	if (nn->eth_port) {
+		cmd->base.speed = nn->eth_port->speed;
+		cmd->base.duplex = DUPLEX_FULL;
+		return 0;
+	}
+
 	sts = nn_readl(nn, NFP_NET_CFG_STS);
 
 	ls = FIELD_GET(NFP_NET_CFG_STS_LINK_RATE, sts);
-- 
2.11.0
