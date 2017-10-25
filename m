From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC net-next 2/4] net: smsc911x: Properly manage PHY during suspend/resume
Date: Wed, 25 Oct 2017 16:21:22 -0700
Message-ID: <20171025232124.14120-3-f.fainelli@gmail.com>
References: <20171025232124.14120-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
        andrew@lunn.ch, opendmb@gmail.com,
        Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        slash.tmp@free.fr, david.daney@cavium.com, geert+renesas@glider.be
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:50795 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751943AbdJYXVm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 19:21:42 -0400
Received: by mail-qt0-f196.google.com with SMTP id d9so2168826qtd.7
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 16:21:42 -0700 (PDT)
In-Reply-To: <20171025232124.14120-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 2aa70f864955 ("net: smsc911x: Quieten netif during suspend")
addressed the network device parts of the suspend/resume process, but
this is not enough, we can also need to manage the PHY state machine
during suspend.

Because Geert indicated that we are going to cut the power to the block,
we need the hard synchronization that phy_stop_machine() guarantees,
conversely use phy_start_machine() to resume properly.

There appears to be a desire to enable Wake-on-LAN, which is obviously
dependent on the PHY not being suspend, so we don't suspend it. A future
patch should probably add proper support for turning on/off Wake-on-LAN
on a PHY activity/password etc. basis.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/smsc/smsc911x.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 012fb66eed8d..82f9a175073f 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -2598,6 +2598,11 @@ static int smsc911x_suspend(struct device *dev)
 	if (netif_running(ndev)) {
 		netif_stop_queue(ndev);
 		netif_device_detach(ndev);
+		phy_stop(ndev->phydev);
+		/* Use a hard synchronization here because we will cut the
+		 * power fo the block next
+		 */
+		phy_stop_machine(ndev->phydev);
 	}
 
 	/* enable wake on LAN, energy detection and the external PME
@@ -2638,6 +2643,8 @@ static int smsc911x_resume(struct device *dev)
 
 	if (netif_running(ndev)) {
 		netif_device_attach(ndev);
+		phy_start_machine(ndev->phydev);
+		phy_start(ndev->phydev);
 		netif_start_queue(ndev);
 	}
 
-- 
2.9.3
