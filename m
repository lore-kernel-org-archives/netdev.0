From: David Decotigny <decot@google.com>
Subject: [PATCH 2/2] net/dl2k: Don't reconfigure link @100Mbps when disabling autoneg @1Gbps
Date: Mon,  9 May 2011 17:19:08 -0700
Message-ID: <1304986748-15809-3-git-send-email-decot@google.com>
References: <1304986748-15809-1-git-send-email-decot@google.com>
Cc: David Decotigny <decot@google.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	netdev@vger.kernel.org,
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304986748-15809-1-git-send-email-decot@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The initial version of the driver used to force the link to 100Mbps
when auto-negociation was disabled on a 1Gbps link, ignoring the
requested link speed. Instead, this change refuses to change anything
when it is asked to configure the link speed at 1Gbps without
auto-negociation, but acts as requested in all the other cases.

IMPORTANT: Previously, the return value from mii_set_media() was
           ignored. This patch uses it for its own return value.

Tested: module compiling, NOT tested on real hardware.
Signed-off-by: David Decotigny <decot@google.com>
---
 drivers/net/dl2k.c |   19 ++++++-------------
 1 files changed, 6 insertions(+), 13 deletions(-)

diff --git a/drivers/net/dl2k.c b/drivers/net/dl2k.c
index c445457..1a4856b 100644
--- a/drivers/net/dl2k.c
+++ b/drivers/net/dl2k.c
@@ -1211,24 +1211,17 @@ static int rio_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	if (cmd->autoneg == AUTONEG_ENABLE) {
 		if (np->an_enable)
 			return 0;
-		else {
-			np->an_enable = 1;
-			mii_set_media(dev);
-			return 0;
-		}
+
+		np->an_enable = 1;
 	} else {
-		np->an_enable = 0;
-		if (np->speed == 1000) {
-			ethtool_cmd_speed_set(cmd, SPEED_100);
-			cmd->duplex = DUPLEX_FULL;
-			printk("Warning!! Can't disable Auto negotiation in 1000Mbps, change to Manual 100Mbps, Full duplex.\n");
-		}
 		switch (ethtool_cmd_speed(cmd)) {
 		case SPEED_10:
+			np->an_enable = 0;
 			np->speed = 10;
 			np->full_duplex = (cmd->duplex == DUPLEX_FULL);
 			break;
 		case SPEED_100:
+			np->an_enable = 0;
 			np->speed = 100;
 			np->full_duplex = (cmd->duplex == DUPLEX_FULL);
 			break;
@@ -1236,9 +1229,9 @@ static int rio_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		default:
 			return -EINVAL;
 		}
-		mii_set_media(dev);
 	}
-	return 0;
+
+	return mii_set_media(dev);
 }
 
 static u32 rio_get_link(struct net_device *dev)
-- 
1.7.3.1
