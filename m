From: Andrew Lunn <andrew@lunn.ch>
Subject: [Patch v2 RFT net-next 7/9] dsa: mv88e6xxx: Don't poll forced interfaces for state changes
Date: Mon, 31 Aug 2015 15:56:52 +0200
Message-ID: <1441029414-20062-8-git-send-email-andrew@lunn.ch>
References: <1441029414-20062-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>, Stas Sergeev <stsp@list.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42602 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751924AbbHaOEd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Aug 2015 10:04:33 -0400
In-Reply-To: <1441029414-20062-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When polling for link status, don't consider ports which have a forced
link. Such ports don't monitor their phy or may not even have a phy.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Acked-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/mv88e6xxx.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 90dee97ae793..6f13f7206762 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -395,6 +395,7 @@ void mv88e6xxx_poll_link(struct dsa_switch *ds)
 	for (i = 0; i < DSA_MAX_PORTS; i++) {
 		struct net_device *dev;
 		int uninitialized_var(port_status);
+		int pcs_ctrl;
 		int link;
 		int speed;
 		int duplex;
@@ -404,6 +405,10 @@ void mv88e6xxx_poll_link(struct dsa_switch *ds)
 		if (dev == NULL)
 			continue;
 
+		pcs_ctrl = mv88e6xxx_reg_read(ds, REG_PORT(i), PORT_PCS_CTRL);
+		if (pcs_ctrl < 0 || pcs_ctrl & PORT_PCS_CTRL_FORCE_LINK)
+			continue;
+
 		link = 0;
 		if (dev->flags & IFF_UP) {
 			port_status = mv88e6xxx_reg_read(ds, REG_PORT(i),
-- 
2.5.0
