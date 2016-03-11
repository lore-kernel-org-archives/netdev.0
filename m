From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 2/5] dsa: slave: Don't reference NULL pointer during phy_disconnect
Date: Sat, 12 Mar 2016 00:01:37 +0100
Message-ID: <1457737300-23660-3-git-send-email-andrew@lunn.ch>
References: <1457737300-23660-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55187 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932683AbcCKXB5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2016 18:01:57 -0500
In-Reply-To: <1457737300-23660-1-git-send-email-andrew@lunn.ch>
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
index 27bf03d11670..49056d90b179 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -896,11 +896,15 @@ static void dsa_slave_adjust_link(struct net_device *dev)
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
2.7.0
