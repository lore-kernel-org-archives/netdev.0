From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 1/3] net: dsa: remove out label in dsa_switch_setup_one
Date: Tue,  3 Jan 2017 13:15:36 -0500
Message-ID: <20170103181538.2593-2-vivien.didelot@savoirfairelinux.com>
References: <20170103181538.2593-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, cphealy@gmail.com,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:45702 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965435AbdACSQE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 13:16:04 -0500
In-Reply-To: <20170103181538.2593-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The "out" label in dsa_switch_setup_one() is useless, thus remove it.
---
 net/dsa/dsa.c | 40 +++++++++++++---------------------------
 1 file changed, 13 insertions(+), 27 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 7899919cd9f0..89e66b623d73 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -329,8 +329,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 			if (dst->cpu_switch != -1) {
 				netdev_err(dst->master_netdev,
 					   "multiple cpu ports?!\n");
-				ret = -EINVAL;
-				goto out;
+				return -EINVAL;
 			}
 			dst->cpu_switch = index;
 			dst->cpu_port = i;
@@ -343,10 +342,8 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 		valid_name_found = true;
 	}
 
-	if (!valid_name_found && i == DSA_MAX_PORTS) {
-		ret = -EINVAL;
-		goto out;
-	}
+	if (!valid_name_found && i == DSA_MAX_PORTS)
+		return -EINVAL;
 
 	/* Make the built-in MII bus mask match the number of ports,
 	 * switch drivers can override this later
@@ -363,10 +360,8 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 
 		tag_protocol = ops->get_tag_protocol(ds);
 		dst->tag_ops = dsa_resolve_tag_protocol(tag_protocol);
-		if (IS_ERR(dst->tag_ops)) {
-			ret = PTR_ERR(dst->tag_ops);
-			goto out;
-		}
+		if (IS_ERR(dst->tag_ops))
+			return PTR_ERR(dst->tag_ops);
 
 		dst->rcv = dst->tag_ops->rcv;
 	}
@@ -378,25 +373,23 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 	 */
 	ret = ops->setup(ds);
 	if (ret < 0)
-		goto out;
+		return ret;
 
 	if (ops->set_addr) {
 		ret = ops->set_addr(ds, dst->master_netdev->dev_addr);
 		if (ret < 0)
-			goto out;
+			return ret;
 	}
 
 	if (!ds->slave_mii_bus && ops->phy_read) {
 		ds->slave_mii_bus = devm_mdiobus_alloc(parent);
-		if (!ds->slave_mii_bus) {
-			ret = -ENOMEM;
-			goto out;
-		}
+		if (!ds->slave_mii_bus)
+			return -ENOMEM;
 		dsa_slave_mii_bus_init(ds);
 
 		ret = mdiobus_register(ds->slave_mii_bus);
 		if (ret < 0)
-			goto out;
+			return ret;
 	}
 
 	/*
@@ -409,20 +402,16 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 			continue;
 
 		ret = dsa_slave_create(ds, parent, i, cd->port_names[i]);
-		if (ret < 0) {
+		if (ret < 0)
 			netdev_err(dst->master_netdev, "[%d]: can't create dsa slave device for port %d(%s): %d\n",
 				   index, i, cd->port_names[i], ret);
-			ret = 0;
-		}
 	}
 
 	/* Perform configuration of the CPU and DSA ports */
 	ret = dsa_cpu_dsa_setups(ds, parent);
-	if (ret < 0) {
+	if (ret < 0)
 		netdev_err(dst->master_netdev, "[%d] : can't configure CPU and DSA ports\n",
 			   index);
-		ret = 0;
-	}
 
 	ret = dsa_cpu_port_ethtool_setup(ds);
 	if (ret)
@@ -453,10 +442,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 	}
 #endif /* CONFIG_NET_DSA_HWMON */
 
-	return ret;
-
-out:
-	return ret;
+	return 0;
 }
 
 static struct dsa_switch *
-- 
2.11.0
