From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net] net: dsa: mv88e6xxx: fix port VLAN maps
Date: Thu, 28 Jan 2016 16:54:37 -0500
Message-ID: <1454018077-11222-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Kevin Smith <kevin.smith@elecsyscorp.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently the port based VLAN maps should be configured to allow every
port to egress frames on all other ports, except themselves.

The debugfs interface shows that they are misconfigured. For instance, a
7-port switch has the following content in the related register 0x06:

       GLOBAL GLOBAL2 SERDES   0    1    2    3    4    5    6
    ...
    6:  1fa4    1f0f       4   7f   7e   7d   7c   7b   7a   79
    ...

This means that port 3 is allowed to talk to port 2-6, but cannot talk
to ports 0 and 1. With this fix, port 3 can correctly talk to all ports
except 3 itself:

       GLOBAL GLOBAL2 SERDES   0    1    2    3    4    5    6
    ...
    6:  1fa4    1f0f       4   7e   7d   7b   77   6f   5f   3f
    ...

Fixes: ede8098d0fef ("net: dsa: mv88e6xxx: bridges do not need an FID")
Reported-by: Kevin Smith <kevin.smith@elecsyscorp.com>
Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index b03f746..d365007 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2153,7 +2153,8 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 	 * database, and allow every port to egress frames on all other ports.
 	 */
 	reg = BIT(ps->num_ports) - 1; /* all ports */
-	ret = _mv88e6xxx_port_vlan_map_set(ds, port, reg & ~port);
+	reg &= ~BIT(port); /* except itself */
+	ret = _mv88e6xxx_port_vlan_map_set(ds, port, reg);
 	if (ret)
 		goto abort;
 
-- 
2.7.0
