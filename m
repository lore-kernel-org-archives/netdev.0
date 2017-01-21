From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: dsa: Check return value of phy_connect_direct()
Date: Fri, 20 Jan 2017 16:05:05 -0800
Message-ID: <20170121000505.15135-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33296 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752114AbdAUAFO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 19:05:14 -0500
Received: by mail-pg0-f65.google.com with SMTP id 194so7991131pgd.0
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 16:05:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to check the return value of phy_connect_direct() in
dsa_slave_phy_connect() otherwise we may be continuing the
initialization of a slave network device with a PHY that already
attached somewhere else and which will soon be in error because the PHY
device is in error.

The conditions for such an error to occur are that we have a port of our
switch that is not disabled, and has the same port number as a PHY
address (say both 5) that can be probed using the DSA slave MII bus. We
end-up having this slave network device find a PHY at the same address
as our port number, and we try to attach to it.

A slave network (e.g: port 0) has already attached to our PHY device,
and we try to re-attach it with a different network device, but since we
ignore the error we would end-up initializating incorrect device
references by the time the slave network interface is opened.

The code has been (re)organized several times, making it hard to provide
an exact Fixes tag, this is a bugfix nonetheless.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/slave.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 68c9eea00518..ba1b6b9630d2 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1105,10 +1105,8 @@ static int dsa_slave_phy_connect(struct dsa_slave_priv *p,
 	/* Use already configured phy mode */
 	if (p->phy_interface == PHY_INTERFACE_MODE_NA)
 		p->phy_interface = p->phy->interface;
-	phy_connect_direct(slave_dev, p->phy, dsa_slave_adjust_link,
-			   p->phy_interface);
-
-	return 0;
+	return phy_connect_direct(slave_dev, p->phy, dsa_slave_adjust_link,
+				  p->phy_interface);
 }
 
 static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
-- 
2.11.0
