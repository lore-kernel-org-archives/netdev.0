From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net v2 1/5] net: dsa: fix fixed-link-phy device leaks
Date: Thu, 24 Nov 2016 19:21:27 +0100
Message-ID: <1480011691-13278-2-git-send-email-johan@kernel.org>
References: <1480011691-13278-1-git-send-email-johan@kernel.org>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Madalin Bucur <madalin.bucur@nxp.com>,
        Timur Tabi <timur@codeaurora.org>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Johan Hovold <johan@kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480011691-13278-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure to drop the reference taken by of_phy_find_device() when
registering and deregistering the fixed-link PHY-device.

Fixes: 39b0c705195e ("net: dsa: Allow configuration of CPU & DSA port
speeds/duplex")
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 net/dsa/dsa.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index a6902c1e2f28..cb0091b99592 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -233,6 +233,8 @@ int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct device *dev,
 		genphy_read_status(phydev);
 		if (ds->ops->adjust_link)
 			ds->ops->adjust_link(ds, port, phydev);
+
+		put_device(&phydev->mdio.dev);
 	}
 
 	return 0;
@@ -509,8 +511,9 @@ void dsa_cpu_dsa_destroy(struct device_node *port_dn)
 	if (of_phy_is_fixed_link(port_dn)) {
 		phydev = of_phy_find_device(port_dn);
 		if (phydev) {
-			phy_device_free(phydev);
 			fixed_phy_unregister(phydev);
+			put_device(&phydev->mdio.dev);
+			phy_device_free(phydev);
 		}
 	}
 }
-- 
2.7.3
