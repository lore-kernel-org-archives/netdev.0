From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net] net: dsa: mv88e6060: fix switch MAC address
Date: Fri, 13 Oct 2017 13:39:22 -0400
Message-ID: <20171013173922.26536-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        David Laight <David.Laight@ACULAB.COM>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The 88E6060 Ethernet switch always transmits the multicast bit of the
switch MAC address as a zero. It re-uses the corresponding bit 8 of the
register "Switch MAC Address Register Bytes 0 & 1" for "DiffAddr".

If the "DiffAddr" bit is 0, then all ports transmit the same source
address. If it is set to 1, then bit 2:0 are used for the port number.

The mv88e6060 driver is currently wrongly shifting the MAC address byte
0 by 9. To fix this, shift it by 8 as usual and clear its bit 0.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6060.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index 621cdc46ad81..d64be2b83d3c 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -214,8 +214,14 @@ static int mv88e6060_setup(struct dsa_switch *ds)
 
 static int mv88e6060_set_addr(struct dsa_switch *ds, u8 *addr)
 {
-	/* Use the same MAC Address as FD Pause frames for all ports */
-	REG_WRITE(REG_GLOBAL, GLOBAL_MAC_01, (addr[0] << 9) | addr[1]);
+	u16 val = addr[0] << 8 | addr[1];
+
+	/* The multicast bit is always transmitted as a zero, so the switch uses
+	 * bit 8 for "DiffAddr", where 0 means all ports transmit the same SA.
+	 */
+	val &= 0xfeff;
+
+	REG_WRITE(REG_GLOBAL, GLOBAL_MAC_01, val);
 	REG_WRITE(REG_GLOBAL, GLOBAL_MAC_23, (addr[2] << 8) | addr[3]);
 	REG_WRITE(REG_GLOBAL, GLOBAL_MAC_45, (addr[4] << 8) | addr[5]);
 
-- 
2.14.2
