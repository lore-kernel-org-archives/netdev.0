From: =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
Subject: [PATCH] net: ethtool: remove error check for legacy setting transceiver type
Date: Fri, 20 Oct 2017 01:32:08 +0200
Message-ID: <20171019233208.15444-1-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-renesas-soc@vger.kernel.org,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Renjith R V <renjith.rv@quest-global.com>,
        =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
To: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 9cab88726929605 ("net: ethtool: Add back transceiver type")
restores the transceiver type to struct ethtool_link_settings and
convert_link_ksettings_to_legacy_settings() but forgets to remove the
error check for the same in convert_legacy_settings_to_link_ksettings().
This prevents older versions of ethtool to change link settings.

    # ethtool --version
    ethtool version 3.16

    # ethtool -s eth0 autoneg on speed 100 duplex full
    Cannot set new settings: Invalid argument
      not setting speed
      not setting duplex
      not setting autoneg

While newer versions of ethtool works.

    # ethtool --version
    ethtool version 4.10

    # ethtool -s eth0 autoneg on speed 100 duplex full
    [   57.703268] sh-eth ee700000.ethernet eth0: Link is Down
    [   59.618227] sh-eth ee700000.ethernet eth0: Link is Up - 100Mbps/Full - flow control rx/tx

Fixes: 19cab88726929605 ("net: ethtool: Add back transceiver type")
Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
---
 net/core/ethtool.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

Hi,

The commit 9cab88726929605 ("net: ethtool: Add back transceiver type") 
itself is not enough to trigger the error, the commit after it is also 
needed ceb628134a75564d ("net: phy: Keep reporting transceiver type").
This is because the later sets cmd->base.transceiver so that the type 
can be reported and the fault triggered. I hope however I did the 
correct thing with the Fixes tag.

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 3228411ada0fa77e..9a9a3d77e3274fc3 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -436,7 +436,7 @@ bool ethtool_convert_link_mode_to_legacy_u32(u32 *legacy_u32,
 EXPORT_SYMBOL(ethtool_convert_link_mode_to_legacy_u32);
 
 /* return false if legacy contained non-0 deprecated fields
- * transceiver/maxtxpkt/maxrxpkt. rest of ksettings always updated
+ * maxtxpkt/maxrxpkt. rest of ksettings always updated
  */
 static bool
 convert_legacy_settings_to_link_ksettings(
@@ -451,8 +451,7 @@ convert_legacy_settings_to_link_ksettings(
 	 * deprecated legacy fields, and they should not use
 	 * %ETHTOOL_GLINKSETTINGS/%ETHTOOL_SLINKSETTINGS
 	 */
-	if (legacy_settings->transceiver ||
-	    legacy_settings->maxtxpkt ||
+	if (legacy_settings->maxtxpkt ||
 	    legacy_settings->maxrxpkt)
 		retval = false;
 
-- 
2.14.2
