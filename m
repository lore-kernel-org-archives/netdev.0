From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC 23/28] net: dsa: Only setup platform switches, not device switches
Date: Wed, 23 Dec 2015 13:56:37 +0100
Message-ID: <1450875402-20740-24-git-send-email-andrew@lunn.ch>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, narmstrong@baylibre.com,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48762 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752147AbbLWM6V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 07:58:21 -0500
In-Reply-To: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switches which are linux devices will register themselves with DSA.
Such switches already have a dsa_switch in the dsa_switch_tree, and
don't need to be probed using the old mechanism.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/dsa.c | 26 ++++++++++----------------
 1 file changed, 10 insertions(+), 16 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index fbb8fc852a3b..5e037772bb32 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -823,7 +823,6 @@ static int dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
 			 struct device *parent)
 {
 	int i, ret;
-	unsigned configured = 0;
 	struct dsa_switch *ds;
 	struct dsa_platform_data *pd = dst->pd;
 
@@ -831,11 +830,16 @@ static int dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
 	dst->cpu_port = -1;
 
 	for (i = 0; i < pd->nr_chips; i++) {
-		ds = dsa_switch_setup(dst, i, parent, pd->chip[i].host_dev);
-		if (IS_ERR(ds)) {
-			netdev_err(dev, "[%d]: couldn't create dsa switch instance (error %ld)\n",
-				   i, PTR_ERR(ds));
-			continue;
+		if (!dst->ds[i]) {
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
 
@@ -844,19 +848,9 @@ static int dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
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
-- 
2.6.3
