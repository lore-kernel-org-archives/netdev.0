From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 3/4] net: dsa: setup master ethtool after dsa_ptr
Date: Tue, 19 Sep 2017 11:56:59 -0400
Message-ID: <20170919155700.14474-4-vivien.didelot@savoirfairelinux.com>
References: <20170919155700.14474-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:46196 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751343AbdISQAq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 12:00:46 -0400
In-Reply-To: <20170919155700.14474-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DSA overrides the master's ethtool ops so that we can inject its CPU
port's statistics. Because of that, we need to setup the ethtool ops
after the master's dsa_ptr pointer has been assigned, not before.

This patch setups the ethtool ops after dsa_ptr is assigned, and
restores them before it gets cleared.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa2.c   | 12 +++++++-----
 net/dsa/legacy.c | 10 +++-------
 2 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index bd19304f862f..032f8bc3e788 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -433,16 +433,17 @@ static int dsa_dst_apply(struct dsa_switch_tree *dst)
 			return err;
 	}
 
-	err = dsa_cpu_port_ethtool_setup(dst->cpu_dp);
-	if (err)
-		return err;
-
 	/* If we use a tagging format that doesn't have an ethertype
 	 * field, make sure that all packets from this point on get
 	 * sent to the tag format's receive function.
 	 */
 	wmb();
 	dst->cpu_dp->netdev->dsa_ptr = dst;
+
+	err = dsa_cpu_port_ethtool_setup(dst->cpu_dp);
+	if (err)
+		return err;
+
 	dst->applied = true;
 
 	return 0;
@@ -456,6 +457,8 @@ static void dsa_dst_unapply(struct dsa_switch_tree *dst)
 	if (!dst->applied)
 		return;
 
+	dsa_cpu_port_ethtool_restore(dst->cpu_dp);
+
 	dst->cpu_dp->netdev->dsa_ptr = NULL;
 
 	/* If we used a tagging format that doesn't have an ethertype
@@ -472,7 +475,6 @@ static void dsa_dst_unapply(struct dsa_switch_tree *dst)
 		dsa_ds_unapply(dst, ds);
 	}
 
-	dsa_cpu_port_ethtool_restore(dst->cpu_dp);
 	dst->cpu_dp = NULL;
 
 	pr_info("DSA: tree %d unapplied\n", dst->tree);
diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index 91e6f7981d39..163910699db7 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -206,10 +206,6 @@ static int dsa_switch_setup_one(struct dsa_switch *ds,
 		netdev_err(master, "[%d] : can't configure CPU and DSA ports\n",
 			   index);
 
-	ret = dsa_cpu_port_ethtool_setup(ds->dst->cpu_dp);
-	if (ret)
-		return ret;
-
 	return 0;
 }
 
@@ -606,7 +602,7 @@ static int dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
 	wmb();
 	dev->dsa_ptr = dst;
 
-	return 0;
+	return dsa_cpu_port_ethtool_setup(dst->cpu_dp);
 }
 
 static int dsa_probe(struct platform_device *pdev)
@@ -671,6 +667,8 @@ static void dsa_remove_dst(struct dsa_switch_tree *dst)
 {
 	int i;
 
+	dsa_cpu_port_ethtool_restore(dst->cpu_dp);
+
 	dst->cpu_dp->netdev->dsa_ptr = NULL;
 
 	/* If we used a tagging format that doesn't have an ethertype
@@ -686,8 +684,6 @@ static void dsa_remove_dst(struct dsa_switch_tree *dst)
 			dsa_switch_destroy(ds);
 	}
 
-	dsa_cpu_port_ethtool_restore(dst->cpu_dp);
-
 	dev_put(dst->cpu_dp->netdev);
 }
 
-- 
2.14.1
