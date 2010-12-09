From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 1/2] ethtool: Report link-down while interface
 is down
Date: Thu, 09 Dec 2010 22:08:35 +0000
Message-ID: <1291932515.2647.32.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:25649 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757395Ab0LIWIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 17:08:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While an interface is down, many implementations of
ethtool_ops::get_link, including the default, ethtool_op_get_link(),
will report the last link state seen while the interface was up.  In
general the current physical link state is not available if the
interface is down.

Define ETHTOOL_GLINK to reflect whether the interface *and* any
physical port have a working link, and consistently return 0 when the
interface is down.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
David,

I know you weren't keen on this, but if you don't accept it then please
say what you think the proper semantics are.

Ben.

 include/linux/ethtool.h |    4 +++-
 net/core/ethtool.c      |   17 +++++++++++++++--
 2 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 6628a50..1908929 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -691,7 +691,9 @@ struct ethtool_ops {
 #define ETHTOOL_GMSGLVL		0x00000007 /* Get driver message level */
 #define ETHTOOL_SMSGLVL		0x00000008 /* Set driver msg level. */
 #define ETHTOOL_NWAY_RST	0x00000009 /* Restart autonegotiation. */
-#define ETHTOOL_GLINK		0x0000000a /* Get link status (ethtool_value) */
+/* Get link status for host, i.e. whether the interface *and* the
+ * physical port (if there is one) are up (ethtool_value). */
+#define ETHTOOL_GLINK		0x0000000a
 #define ETHTOOL_GEEPROM		0x0000000b /* Get EEPROM data */
 #define ETHTOOL_SEEPROM		0x0000000c /* Set EEPROM data. */
 #define ETHTOOL_GCOALESCE	0x0000000e /* Get coalesce config */
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index d5bc2881..1774178 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -891,6 +891,20 @@ static int ethtool_nway_reset(struct net_device *dev)
 	return dev->ethtool_ops->nway_reset(dev);
 }
 
+static int ethtool_get_link(struct net_device *dev, char __user *useraddr)
+{
+	struct ethtool_value edata = { .cmd = ETHTOOL_GLINK };
+
+	if (!dev->ethtool_ops->get_link)
+		return -EOPNOTSUPP;
+
+	edata.data = netif_running(dev) && dev->ethtool_ops->get_link(dev);
+
+	if (copy_to_user(useraddr, &edata, sizeof(edata)))
+		return -EFAULT;
+	return 0;
+}
+
 static int ethtool_get_eeprom(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_eeprom eeprom;
@@ -1530,8 +1544,7 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 		rc = ethtool_nway_reset(dev);
 		break;
 	case ETHTOOL_GLINK:
-		rc = ethtool_get_value(dev, useraddr, ethcmd,
-				       dev->ethtool_ops->get_link);
+		rc = ethtool_get_link(dev, useraddr);
 		break;
 	case ETHTOOL_GEEPROM:
 		rc = ethtool_get_eeprom(dev, useraddr);
-- 
1.7.3.2



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

