From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC v2 26/32] net: dsa: Only setup platform switches, not device switches
Date: Sun, 28 Feb 2016 17:41:34 +0100
Message-ID: <1456677700-23027-27-git-send-email-andrew@lunn.ch>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44987 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759057AbcB1QnM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2016 11:43:12 -0500
In-Reply-To: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switches which are linux devices will register themselves with DSA.
Such switches already have a dsa_switch in the dsa_switch_tree, and
don't need to be probed using the old mechanism.

Similarly, it is the responsibility of the switch driver to free its
resources when it unregisters.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/dsa.c | 37 ++++++++++++++++++-------------------
 1 file changed, 18 insertions(+), 19 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index b9b10e050927..f3ffc937b152 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -830,19 +830,25 @@ static int dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
 			 struct device *parent)
 {
 	int i, ret;
-	unsigned configured = 0;
 	struct dsa_switch *ds;
+	struct dsa_chip_data *cd;
 	struct dsa_platform_data *pd = dst->pd;
 
 	dst->cpu_switch = -1;
 	dst->cpu_port = -1;
 
 	for (i = 0; i < pd->nr_chips; i++) {
-		ds = dsa_switch_setup(dst, i, parent, pd->chip[i].host_dev);
-		if (IS_ERR(ds)) {
-			netdev_err(dev, "[%d]: couldn't create dsa switch instance (error %ld)\n",
-				   i, PTR_ERR(ds));
-			continue;
+		cd = &pd->chip[i];
+		if (!cd->of_chip) {
+			ds = dsa_switch_setup(dst, i, parent,
+					      pd->chip[i].host_dev);
+			if (IS_ERR(ds)) {
+				netdev_err(dev, "[%d]: couldn't create dsa switch instance (error %ld)\n",
+					   i, PTR_ERR(ds));
+				return PTR_ERR(ds);
+			}
+
+			dst->ds[i] = ds;
 		}
 	}
 
@@ -851,19 +857,9 @@ static int dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
 		ret = dsa_switch_setup_one(ds, parent);
 		if (ret)
 			return ret;
-
-		dst->ds[i] = ds;
-
-		++configured;
 	}
 
 	/*
-	 * If no switch was found, exit cleanly
-	 */
-	if (!configured)
-		return -EPROBE_DEFER;
-
-	/*
 	 * If we use a tagging format that doesn't have an ethertype
 	 * field, make sure that all packets from this point on get
 	 * sent to the tag format's receive function.
@@ -878,6 +874,7 @@ static void dsa_finish_dst(struct dsa_switch_tree *dst, struct device *parent,
 			   struct dsa_platform_data *pd)
 {
 	struct net_device *dev = dst->master_netdev;
+	struct dsa_chip_data *cd;
 	struct dsa_switch *ds;
 	int i;
 
@@ -893,9 +890,11 @@ static void dsa_finish_dst(struct dsa_switch_tree *dst, struct device *parent,
 	}
 
 	for (i = 0; i < pd->nr_chips; i++) {
-		ds = dst->ds[i];
-
-		dsa_switch_finish(ds, parent);
+		cd = &pd->chip[i];
+		if (!cd->of_chip) {
+			ds = dst->ds[i];
+			dsa_switch_finish(ds, parent);
+		}
 		dst->ds[i] = NULL;
 	}
 }
-- 
2.7.0
