From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 01/12] nfp: link basic ethtool ops to representors
Date: Fri, 18 Aug 2017 15:48:11 -0700
Message-ID: <20170818224822.8409-2-jakub.kicinski@netronome.com>
References: <20170818224822.8409-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:37815 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751060AbdHRWtZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 18:49:25 -0400
Received: by mail-pg0-f51.google.com with SMTP id y129so72460775pgy.4
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 15:49:24 -0700 (PDT)
In-Reply-To: <20170818224822.8409-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Start linking ethtool ops to representors.  Begin by adding
a separate ops structure and providing link state.  Next
patches will convert appropriate functions to only use nfp_port,
which will make them reusable on representors.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c | 4 ++++
 drivers/net/ethernet/netronome/nfp/nfp_net_repr.c    | 2 ++
 drivers/net/ethernet/netronome/nfp/nfp_port.h        | 1 +
 3 files changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index 6e31355c3567..3edc5d62ad5b 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -939,6 +939,10 @@ static const struct ethtool_ops nfp_net_ethtool_ops = {
 	.set_link_ksettings	= nfp_net_set_link_ksettings,
 };
 
+const struct ethtool_ops nfp_port_ethtool_ops = {
+	.get_link		= ethtool_op_get_link,
+};
+
 void nfp_net_set_ethtool_ops(struct net_device *netdev)
 {
 	netdev->ethtool_ops = &nfp_net_ethtool_ops;
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
index 47daad30756c..50f7cc057cc9 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
@@ -320,6 +320,8 @@ int nfp_repr_init(struct nfp_app *app, struct net_device *netdev,
 	repr->dst->u.port_info.lower_dev = pf_netdev;
 
 	netdev->netdev_ops = &nfp_repr_netdev_ops;
+	netdev->ethtool_ops = &nfp_port_ethtool_ops;
+
 	SWITCHDEV_SET_OPS(netdev, &nfp_port_switchdev_ops);
 
 	if (nfp_app_has_tc(app)) {
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_port.h b/drivers/net/ethernet/netronome/nfp/nfp_port.h
index c88e376dcf0f..784d82c2f32c 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.h
@@ -106,6 +106,7 @@ struct nfp_port {
 	struct list_head port_list;
 };
 
+extern const struct ethtool_ops nfp_port_ethtool_ops;
 extern const struct switchdev_ops nfp_port_switchdev_ops;
 
 int nfp_port_setup_tc(struct net_device *netdev, enum tc_setup_type type,
-- 
2.11.0
