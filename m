From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 2/2] ethtool, mdio, mii: Specify MDIO information
 fields in struct ethtool_cmd
Date: Thu, 1 Mar 2012 00:26:22 +0000
Message-ID: <1330561582.5881.15.camel@bwh-desktop>
References: <1330561407.5881.13.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:14697 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753805Ab2CAA00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 19:26:26 -0500
In-Reply-To: <1330561407.5881.13.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add comments for ethtool_cmd::phy_address and
ethtool_cmd::mdio_support, and definitions of the flags currently
used in mdio_support.

In the mdio library, assert that its own flags continue to match those
in the ethtool interface.

In the mii library, use the ethtool flag definition and stop
including <linux/mdio.h>.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/mdio.c      |    3 +++
 drivers/net/mii.c       |    4 ++--
 include/linux/ethtool.h |   23 +++++++++++++++++++++--
 3 files changed, 26 insertions(+), 4 deletions(-)

diff --git a/drivers/net/mdio.c b/drivers/net/mdio.c
index 16fbb11..8403316 100644
--- a/drivers/net/mdio.c
+++ b/drivers/net/mdio.c
@@ -190,6 +190,9 @@ void mdio45_ethtool_gset_npage(const struct mdio_if_info *mdio,
 	int reg;
 	u32 speed;
 
+	BUILD_BUG_ON(MDIO_SUPPORTS_C22 != ETH_MDIO_SUPPORTS_C22);
+	BUILD_BUG_ON(MDIO_SUPPORTS_C45 != ETH_MDIO_SUPPORTS_C45);
+
 	ecmd->transceiver = XCVR_INTERNAL;
 	ecmd->phy_address = mdio->prtad;
 	ecmd->mdio_support =
diff --git a/drivers/net/mii.c b/drivers/net/mii.c
index c70c233..4a99c39 100644
--- a/drivers/net/mii.c
+++ b/drivers/net/mii.c
@@ -31,7 +31,7 @@
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/ethtool.h>
-#include <linux/mdio.h>
+#include <linux/mii.h>
 
 static u32 mii_get_an(struct mii_if_info *mii, u16 addr)
 {
@@ -74,7 +74,7 @@ int mii_ethtool_gset(struct mii_if_info *mii, struct ethtool_cmd *ecmd)
 
 	/* this isn't fully supported at higher layers */
 	ecmd->phy_address = mii->phy_id;
-	ecmd->mdio_support = MDIO_SUPPORTS_C22;
+	ecmd->mdio_support = ETH_MDIO_SUPPORTS_C22;
 
 	ecmd->advertising = ADVERTISED_TP | ADVERTISED_MII;
 
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index da5b2de..e1d9e0e 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -30,10 +30,15 @@ struct ethtool_cmd {
 				 * access it */
 	__u8	duplex;		/* Duplex, half or full */
 	__u8	port;		/* Which connector port */
-	__u8	phy_address;
+	__u8	phy_address;	/* MDIO PHY address (PRTAD for clause 45).
+				 * May be read-only or read-write
+				 * depending on the driver.
+				 */
 	__u8	transceiver;	/* Which transceiver to use */
 	__u8	autoneg;	/* Enable or disable autonegotiation */
-	__u8	mdio_support;
+	__u8	mdio_support;	/* MDIO protocols supported.  Read-only.
+				 * Not set by all drivers.
+				 */
 	__u32	maxtxpkt;	/* Tx pkts before generating tx int */
 	__u32	maxrxpkt;	/* Rx pkts before generating rx int */
 	__u16	speed_hi;       /* The forced speed (upper
@@ -59,6 +64,20 @@ static inline __u32 ethtool_cmd_speed(const struct ethtool_cmd *ep)
 	return (ep->speed_hi << 16) | ep->speed;
 }
 
+/* Device supports clause 22 register access to PHY or peripherals
+ * using the interface defined in <linux/mii.h>.  This should not be
+ * set if there are known to be no such peripherals present or if
+ * the driver only emulates clause 22 registers for compatibility.
+ */
+#define ETH_MDIO_SUPPORTS_C22	1
+
+/* Device supports clause 45 register access to PHY or peripherals
+ * using the interface defined in <linux/mii.h> and <linux/mdio.h>.
+ * This should not be set if there are known to be no such peripherals
+ * present.
+ */
+#define ETH_MDIO_SUPPORTS_C45	2
+
 #define ETHTOOL_FWVERS_LEN	32
 #define ETHTOOL_BUSINFO_LEN	32
 /* these strings are set to whatever the driver author decides... */
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
