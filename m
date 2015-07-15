From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH] net: dsa: mv88e6xxx: fix fid_mask when leaving bridge
Date: Wed, 15 Jul 2015 10:07:07 -0400
Message-ID: <1436969227-30006-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Guenter Roeck <linux@roeck-us.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The mv88e6xxx_priv_state structure contains an fid_mask, where 1 means
the FID is free to use, 0 means the FID is in use.

This patch fixes the bit clear in mv88e6xxx_leave_bridge() when
assigning a new FID to a port.

Example scenario: I have 7 ports, port 5 is CPU, port 6 is unused (no
PHY). After setting the ports 0, 1 and 2 in bridge br0, and ports 3 and
4 in bridge br1, I have the following fid_mask: 0b111110010110 (0xf96).

Indeed, br0 uses FID 0, and br1 uses FID 3.

After setting nomaster for port 0, I get the wrong fid_mask: 0b10 (0x2).

With this patch we correctly get 0b111110010100 (0xf94), meaning port 0
uses FID 1, br0 uses FID 0, and br1 uses FID 3.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index bb03c5f..e3ea40e 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1170,7 +1170,7 @@ int mv88e6xxx_leave_bridge(struct dsa_switch *ds, int port, u32 br_port_mask)
 
 	newfid = __ffs(ps->fid_mask);
 	ps->fid[port] = newfid;
-	ps->fid_mask &= (1 << newfid);
+	ps->fid_mask &= ~(1 << newfid);
 	ps->bridge_mask[fid] &= ~(1 << port);
 	ps->bridge_mask[newfid] = 1 << port;
 
-- 
2.4.5
