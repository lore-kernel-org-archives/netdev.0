From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/6] net: dsa: mv88e6xxx: write MAC outside of ATU Get Next code
Date: Tue, 13 Oct 2015 11:42:59 -0400
Message-ID: <1444750983-14726-3-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1444750983-14726-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444750983-14726-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no need to write the MAC address before every Get Next
operation, since ATU MAC registers are not cleared between calls.

Move the _mv88e6xxx_atu_mac_write call outside of _mv88e6xxx_atu_getnext
so future code could call ATU Get Next multiple times and save a few
register access.
---
 drivers/net/dsa/mv88e6xxx.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 1edefe0..b4e97c1 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1751,7 +1751,6 @@ int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 }
 
 static int _mv88e6xxx_atu_getnext(struct dsa_switch *ds, u16 fid,
-				  const unsigned char *addr,
 				  struct mv88e6xxx_atu_entry *entry)
 {
 	struct mv88e6xxx_atu_entry next = { 0 };
@@ -1763,10 +1762,6 @@ static int _mv88e6xxx_atu_getnext(struct dsa_switch *ds, u16 fid,
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_atu_mac_write(ds, addr);
-	if (ret < 0)
-		return ret;
-
 	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_FID, fid);
 	if (ret < 0)
 		return ret;
@@ -1827,7 +1822,11 @@ int mv88e6xxx_port_fdb_getnext(struct dsa_switch *ds, int port,
 			fid = vtu.fid;
 		}
 
-		ret = _mv88e6xxx_atu_getnext(ds, fid, addr, &next);
+		ret = _mv88e6xxx_atu_mac_write(ds, addr);
+		if (ret < 0)
+			goto unlock;
+
+		ret = _mv88e6xxx_atu_getnext(ds, fid, &next);
 		if (ret < 0)
 			goto unlock;
 
-- 
2.6.1
