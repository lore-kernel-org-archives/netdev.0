From: Doug Berger <opendmb@gmail.com>
Subject: [PATCH v2 net 6/8] net: bcmgenet: Power up the internal PHY before probing the MII
Date: Thu,  9 Mar 2017 16:58:48 -0800
Message-ID: <20170310005850.10808-7-opendmb@gmail.com>
References: <20170310005850.10808-1-opendmb@gmail.com>
Cc: pgynther@google.com, jaedon.shin@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Doug Berger <opendmb@gmail.com>
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170310005850.10808-1-opendmb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When using the internal PHY it must be powered up when the MII is probed
or the PHY will not be detected.  Since the PHY is powered up at reset
this has not been a problem.  However, when the kernel is restarted with
kexec the PHY will likely be powered down when the kernel starts so it
will not be detected and the Ethernet link will not be established.

This commit explicitly powers up the internal PHY when the GENET driver
is probed to correct this behavior.

Fixes: 1c1008c793fa ("net: bcmgenet: add main driver file")
Signed-off-by: Doug Berger <opendmb@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 527cecaf12c1..f93098840775 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -3289,6 +3289,7 @@ static int bcmgenet_probe(struct platform_device *pdev)
 	const void *macaddr;
 	struct resource *r;
 	int err = -EIO;
+	const char *phy_mode_str;
 
 	/* Up to GENET_MAX_MQ_CNT + 1 TX queues and RX queues */
 	dev = alloc_etherdev_mqs(sizeof(*priv), GENET_MAX_MQ_CNT + 1,
@@ -3396,6 +3397,13 @@ static int bcmgenet_probe(struct platform_device *pdev)
 		priv->clk_eee = NULL;
 	}
 
+	/* If this is an internal GPHY, power it on now, before UniMAC is
+	 * brought out of reset as absolutely no UniMAC activity is allowed
+	 */
+	if (dn && !of_property_read_string(dn, "phy-mode", &phy_mode_str) &&
+	    !strcasecmp(phy_mode_str, "internal"))
+		bcmgenet_power_up(priv, GENET_POWER_PASSIVE);
+
 	err = reset_umac(priv);
 	if (err)
 		goto err_clk_disable;
-- 
2.11.1
