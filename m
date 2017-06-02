From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 1/3] net: dsa: Pass dsa_port reference to ethtool setup/restore
Date: Fri,  2 Jun 2017 12:31:21 -0700
Message-ID: <20170602193123.23930-2-f.fainelli@gmail.com>
References: <20170602193123.23930-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        john@phrozen.org, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36396 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751150AbdFBTbe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 15:31:34 -0400
Received: by mail-wm0-f67.google.com with SMTP id k15so20481868wmh.3
        for <netdev@vger.kernel.org>; Fri, 02 Jun 2017 12:31:34 -0700 (PDT)
In-Reply-To: <20170602193123.23930-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We do not need to have a reference to a dsa_switch, instead we should
pass a reference to a CPU dsa_port, change that. This is a preliminary
change to better support multiple CPU ports.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa.c      | 6 ++++--
 net/dsa/dsa2.c     | 4 ++--
 net/dsa/dsa_priv.h | 4 ++--
 net/dsa/legacy.c   | 4 ++--
 4 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 402459e73f33..fdc448b30e56 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -112,8 +112,9 @@ const struct dsa_device_ops *dsa_resolve_tag_protocol(int tag_protocol)
 	return ops;
 }
 
-int dsa_cpu_port_ethtool_setup(struct dsa_switch *ds)
+int dsa_cpu_port_ethtool_setup(struct dsa_port *cpu_dp)
 {
+	struct dsa_switch *ds = cpu_dp->ds;
 	struct net_device *master;
 	struct ethtool_ops *cpu_ops;
 
@@ -136,8 +137,9 @@ int dsa_cpu_port_ethtool_setup(struct dsa_switch *ds)
 	return 0;
 }
 
-void dsa_cpu_port_ethtool_restore(struct dsa_switch *ds)
+void dsa_cpu_port_ethtool_restore(struct dsa_port *cpu_dp)
 {
+	struct dsa_switch *ds = cpu_dp->ds;
 	struct net_device *master;
 
 	master = ds->dst->master_netdev;
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 21b44a9828f6..7f9bf1456a65 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -444,7 +444,7 @@ static int dsa_dst_apply(struct dsa_switch_tree *dst)
 	}
 
 	if (dst->cpu_dp) {
-		err = dsa_cpu_port_ethtool_setup(dst->cpu_dp->ds);
+		err = dsa_cpu_port_ethtool_setup(dst->cpu_dp);
 		if (err)
 			return err;
 	}
@@ -485,7 +485,7 @@ static void dsa_dst_unapply(struct dsa_switch_tree *dst)
 	}
 
 	if (dst->cpu_dp)
-		dsa_cpu_port_ethtool_restore(dst->cpu_dp->ds);
+		dsa_cpu_port_ethtool_restore(dst->cpu_dp);
 
 	pr_info("DSA: tree %d unapplied\n", dst->tree);
 	dst->applied = false;
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index db2a7b9edfb8..66ee248796c8 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -103,8 +103,8 @@ int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct device *dev,
 		      struct dsa_port *dport, int port);
 void dsa_cpu_dsa_destroy(struct dsa_port *dport);
 const struct dsa_device_ops *dsa_resolve_tag_protocol(int tag_protocol);
-int dsa_cpu_port_ethtool_setup(struct dsa_switch *ds);
-void dsa_cpu_port_ethtool_restore(struct dsa_switch *ds);
+int dsa_cpu_port_ethtool_setup(struct dsa_port *cpu_dp);
+void dsa_cpu_port_ethtool_restore(struct dsa_port *cpu_dp);
 
 /* legacy.c */
 int dsa_legacy_register(void);
diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index d70a1a788d17..d534d8f4b9cf 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -205,7 +205,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 		netdev_err(dst->master_netdev, "[%d] : can't configure CPU and DSA ports\n",
 			   index);
 
-	ret = dsa_cpu_port_ethtool_setup(ds);
+	ret = dsa_cpu_port_ethtool_setup(ds->dst->cpu_dp);
 	if (ret)
 		return ret;
 
@@ -733,7 +733,7 @@ static void dsa_remove_dst(struct dsa_switch_tree *dst)
 			dsa_switch_destroy(ds);
 	}
 
-	dsa_cpu_port_ethtool_restore(dst->cpu_dp->ds);
+	dsa_cpu_port_ethtool_restore(dst->cpu_dp);
 
 	dev_put(dst->master_netdev);
 }
-- 
2.9.3
