From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC 22/28] net: dsa: Setup the switches after all have been probed
Date: Wed, 23 Dec 2015 13:56:36 +0100
Message-ID: <1450875402-20740-23-git-send-email-andrew@lunn.ch>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, narmstrong@baylibre.com,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48751 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757177AbbLWM6O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 07:58:14 -0500
In-Reply-To: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some switches register themselves with DSA, which others are probed by
DSA itself. Move the setup call to after all switches have been
successfully probed.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/dsa.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 2c1f50561343..fbb8fc852a3b 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -382,7 +382,6 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 	struct dsa_chip_data *pd = dst->pd->chip + index;
 	struct dsa_switch_driver *drv;
 	struct dsa_switch *ds;
-	int ret;
 	char *name;
 
 	/*
@@ -412,10 +411,6 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 	ds->tag_protocol = drv->tag_protocol;
 	ds->master_dev = host_dev;
 
-	ret = dsa_switch_setup_one(ds, parent);
-	if (ret)
-		return ERR_PTR(ret);
-
 	return ds;
 }
 
@@ -827,22 +822,28 @@ static inline void dsa_of_remove(struct device *dev,
 static int dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
 			 struct device *parent)
 {
-	int i;
+	int i, ret;
 	unsigned configured = 0;
+	struct dsa_switch *ds;
 	struct dsa_platform_data *pd = dst->pd;
 
 	dst->cpu_switch = -1;
 	dst->cpu_port = -1;
 
 	for (i = 0; i < pd->nr_chips; i++) {
-		struct dsa_switch *ds;
-
 		ds = dsa_switch_setup(dst, i, parent, pd->chip[i].host_dev);
 		if (IS_ERR(ds)) {
 			netdev_err(dev, "[%d]: couldn't create dsa switch instance (error %ld)\n",
 				   i, PTR_ERR(ds));
 			continue;
 		}
+	}
+
+	for (i = 0; i < pd->nr_chips; i++) {
+		ds = dst->ds[i];
+		ret = dsa_switch_setup_one(ds, parent);
+		if (ret)
+			return ret;
 
 		dst->ds[i] = ds;
 
-- 
2.6.3
