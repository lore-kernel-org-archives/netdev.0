From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: dsa: Fix legacy probing
Date: Fri, 16 Jun 2017 16:42:11 -0700
Message-ID: <20170616234211.20341-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, jcobham@questertangent.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35055 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751144AbdFPXmS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 19:42:18 -0400
Received: by mail-wr0-f194.google.com with SMTP id z45so7872151wrb.2
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 16:42:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After commit 6d3c8c0dd88a ("net: dsa: Remove master_netdev and
use dst->cpu_dp->netdev") and a29342e73911 ("net: dsa: Associate
slave network device with CPU port") we would be seeing NULL pointer
dereferences when accessing dst->cpu_dp->netdev too early. In the legacy
code, we actually know early in advance the master network device, so
pass it down to the relevant functions.

Fixes: 6d3c8c0dd88a ("net: dsa: Remove master_netdev and use dst->cpu_dp->netdev")
Fixes: a29342e73911 ("net: dsa: Associate slave network device with CPU port")
Reported-by: Jason Cobham <jcobham@questertangent.com>
Tested-by: Jason Cobham <jcobham@questertangent.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/legacy.c | 19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index e60906125375..1d7a3282f2a7 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -95,18 +95,16 @@ static int dsa_cpu_dsa_setups(struct dsa_switch *ds, struct device *dev)
 	return 0;
 }
 
-static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
+static int dsa_switch_setup_one(struct dsa_switch *ds, struct net_device *master,
+				struct device *parent)
 {
 	const struct dsa_switch_ops *ops = ds->ops;
 	struct dsa_switch_tree *dst = ds->dst;
 	struct dsa_chip_data *cd = ds->cd;
 	bool valid_name_found = false;
-	struct net_device *master;
 	int index = ds->index;
 	int i, ret;
 
-	master = dst->cpu_dp->netdev;
-
 	/*
 	 * Validate supplied switch configuration.
 	 */
@@ -124,12 +122,12 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 				return -EINVAL;
 			}
 			dst->cpu_dp = &ds->ports[i];
+			dst->cpu_dp->netdev = master;
 			ds->cpu_port_mask |= 1 << i;
 		} else if (!strcmp(name, "dsa")) {
 			ds->dsa_port_mask |= 1 << i;
 		} else {
 			ds->enabled_port_mask |= 1 << i;
-			ds->ports[i].cpu_dp = dst->cpu_dp;
 		}
 		valid_name_found = true;
 	}
@@ -193,6 +191,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 	 */
 	for (i = 0; i < ds->num_ports; i++) {
 		ds->ports[i].dn = cd->port_dn[i];
+		ds->ports[i].cpu_dp = dst->cpu_dp;
 
 		if (!(ds->enabled_port_mask & (1 << i)))
 			continue;
@@ -217,11 +216,10 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 }
 
 static struct dsa_switch *
-dsa_switch_setup(struct dsa_switch_tree *dst, int index,
-		 struct device *parent, struct device *host_dev)
+dsa_switch_setup(struct dsa_switch_tree *dst, struct net_device *master,
+		 int index, struct device *parent, struct device *host_dev)
 {
 	struct dsa_chip_data *cd = dst->pd->chip + index;
-	struct net_device *master = dst->cpu_dp->netdev;
 	const struct dsa_switch_ops *ops;
 	struct dsa_switch *ds;
 	int ret;
@@ -254,7 +252,7 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 	ds->ops = ops;
 	ds->priv = priv;
 
-	ret = dsa_switch_setup_one(ds, parent);
+	ret = dsa_switch_setup_one(ds, master, parent);
 	if (ret)
 		return ERR_PTR(ret);
 
@@ -580,12 +578,11 @@ static int dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
 	unsigned configured = 0;
 
 	dst->pd = pd;
-	dst->cpu_dp->netdev = dev;
 
 	for (i = 0; i < pd->nr_chips; i++) {
 		struct dsa_switch *ds;
 
-		ds = dsa_switch_setup(dst, i, parent, pd->chip[i].host_dev);
+		ds = dsa_switch_setup(dst, dev, i, parent, pd->chip[i].host_dev);
 		if (IS_ERR(ds)) {
 			netdev_err(dev, "[%d]: couldn't create dsa switch instance (error %ld)\n",
 				   i, PTR_ERR(ds));
-- 
2.9.3
