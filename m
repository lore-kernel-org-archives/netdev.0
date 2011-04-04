From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next-2.6 11/12] cxgb3: implement set_phys_id
Date: Mon, 04 Apr 2011 11:43:51 -0700
Message-ID: <20110404184502.288358458@linuxplumber.net>
References: <20110404184340.604594357@linuxplumber.net>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:52837 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755187Ab1DDSvW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 14:51:22 -0400
Content-Disposition: inline; filename=chelsio-set-phys.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement new ethtool set_phys_id on Chelsio cxgb3 board.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/cxgb3/cxgb3_main.c	2011-04-04 11:05:44.658151093 -0700
+++ b/drivers/net/cxgb3/cxgb3_main.c	2011-04-04 11:08:37.060177688 -0700
@@ -1749,23 +1749,26 @@ static int restart_autoneg(struct net_de
 	return 0;
 }
 
-static int cxgb3_phys_id(struct net_device *dev, u32 data)
+static int set_phys_id(struct net_device *dev,
+		       enum ethtool_phys_id_state state)
 {
 	struct port_info *pi = netdev_priv(dev);
 	struct adapter *adapter = pi->adapter;
-	int i;
 
-	if (data == 0)
-		data = 2;
+	switch (state) {
+	case ETHTOOL_ID_ACTIVE:
+		return -EINVAL;
+
+	case ETHTOOL_ID_OFF:
+		t3_set_reg_field(adapter, A_T3DBG_GPIO_EN, F_GPIO0_OUT_VAL, 0);
+		break;
 
-	for (i = 0; i < data * 2; i++) {
+	case ETHTOOL_ID_ON:
+	case ETHTOOL_ID_INACTIVE:
 		t3_set_reg_field(adapter, A_T3DBG_GPIO_EN, F_GPIO0_OUT_VAL,
-				 (i & 1) ? F_GPIO0_OUT_VAL : 0);
-		if (msleep_interruptible(500))
-			break;
-	}
-	t3_set_reg_field(adapter, A_T3DBG_GPIO_EN, F_GPIO0_OUT_VAL,
 			 F_GPIO0_OUT_VAL);
+	}
+
 	return 0;
 }
 
@@ -2107,7 +2110,7 @@ static const struct ethtool_ops cxgb_eth
 	.set_sg = ethtool_op_set_sg,
 	.get_link = ethtool_op_get_link,
 	.get_strings = get_strings,
-	.phys_id = cxgb3_phys_id,
+	.set_phys_id = set_phys_id,
 	.nway_reset = restart_autoneg,
 	.get_sset_count = get_sset_count,
 	.get_ethtool_stats = get_stats,


