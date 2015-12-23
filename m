From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC 27/28] dsa: slave: Don't reference NULL pointer during phy_disconnect
Date: Wed, 23 Dec 2015 13:56:41 +0100
Message-ID: <1450875402-20740-28-git-send-email-andrew@lunn.ch>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, narmstrong@baylibre.com,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48800 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757218AbbLWM6x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 07:58:53 -0500
In-Reply-To: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the phy is disconnected, the parent pointer to the netdev it was
attached to is set to NULL. The code then tries to suspend the phy,
but dsa_slave_fixed_link_update needs the parent pointer to determine
which switch the phy is connected to. So it dereferenced a NULL
pointer. Check for this condition.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/slave.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 1e9e9424a33d..b7f8a40e51d4 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -981,11 +981,15 @@ static void dsa_slave_adjust_link(struct net_device *dev)
 static int dsa_slave_fixed_link_update(struct net_device *dev,
 				       struct fixed_phy_status *status)
 {
-	struct dsa_slave_priv *p = netdev_priv(dev);
-	struct dsa_switch *ds = p->parent;
+	struct dsa_slave_priv *p;
+	struct dsa_switch *ds;
 
-	if (ds->drv->fixed_link_update)
-		ds->drv->fixed_link_update(ds, p->port, status);
+	if (dev) {
+		p = netdev_priv(dev);
+		ds = p->parent;
+		if (ds->drv->fixed_link_update)
+			ds->drv->fixed_link_update(ds, p->port, status);
+	}
 
 	return 0;
 }
-- 
2.6.3
