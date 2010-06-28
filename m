From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6 2/2] ethtool: Fix potential user buffer overflow
 for ETHTOOL_{G,S}RXFH
Date: Mon, 28 Jun 2010 19:45:58 +0100
Message-ID: <1277750759.2089.21.camel@achroite.uk.solarflarecom.com>
References: <1277750647.2089.19.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Santwona Behera <santwona.behera@sun.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:57298 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751735Ab0F1SqC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jun 2010 14:46:02 -0400
In-Reply-To: <1277750647.2089.19.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct ethtool_rxnfc was originally defined in 2.6.27 for the
ETHTOOL_{G,S}RXFH command with only the cmd, flow_type and data
fields.  It was then extended in 2.6.30 to support various additional
commands.  These commands should have been defined to use a new
structure, but it is too late to change that now.

Since user-space may still be using the old structure definition
for the ETHTOOL_{G,S}RXFH commands, and since they do not need the
additional fields, only copy the originally defined fields to and
from user-space.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
Cc: stable@kernel.org
---
 include/linux/ethtool.h |    2 ++
 net/core/ethtool.c      |   36 +++++++++++++++++++++++++++---------
 2 files changed, 29 insertions(+), 9 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 2c8af09..07f9808 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -379,6 +379,8 @@ struct ethtool_rxnfc {
 	__u32				flow_type;
 	/* The rx flow hash value or the rule DB size */
 	__u64				data;
+	/* The following fields are not valid and must not be used for
+	 * the ETHTOOL_{G,X}RXFH commands. */
 	struct ethtool_rx_flow_spec	fs;
 	__u32				rule_cnt;
 	__u32				rule_locs[0];
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index a3a7e9a..75e4ffe 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -318,23 +318,33 @@ out:
 }
 
 static noinline_for_stack int ethtool_set_rxnfc(struct net_device *dev,
-						void __user *useraddr)
+						u32 cmd, void __user *useraddr)
 {
-	struct ethtool_rxnfc cmd;
+	struct ethtool_rxnfc info;
+	size_t info_size = sizeof(info);
 
 	if (!dev->ethtool_ops->set_rxnfc)
 		return -EOPNOTSUPP;
 
-	if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
+	/* struct ethtool_rxnfc was originally defined for
+	 * ETHTOOL_{G,S}RXFH with only the cmd, flow_type and data
+	 * members.  User-space might still be using that
+	 * definition. */
+	if (cmd == ETHTOOL_SRXFH)
+		info_size = (offsetof(struct ethtool_rxnfc, data) +
+			     sizeof(info.data));
+
+	if (copy_from_user(&info, useraddr, info_size))
 		return -EFAULT;
 
-	return dev->ethtool_ops->set_rxnfc(dev, &cmd);
+	return dev->ethtool_ops->set_rxnfc(dev, &info);
 }
 
 static noinline_for_stack int ethtool_get_rxnfc(struct net_device *dev,
-						void __user *useraddr)
+						u32 cmd, void __user *useraddr)
 {
 	struct ethtool_rxnfc info;
+	size_t info_size = sizeof(info);
 	const struct ethtool_ops *ops = dev->ethtool_ops;
 	int ret;
 	void *rule_buf = NULL;
@@ -342,7 +352,15 @@ static noinline_for_stack int ethtool_get_rxnfc(struct net_device *dev,
 	if (!ops->get_rxnfc)
 		return -EOPNOTSUPP;
 
-	if (copy_from_user(&info, useraddr, sizeof(info)))
+	/* struct ethtool_rxnfc was originally defined for
+	 * ETHTOOL_{G,S}RXFH with only the cmd, flow_type and data
+	 * members.  User-space might still be using that
+	 * definition. */
+	if (cmd == ETHTOOL_GRXFH)
+		info_size = (offsetof(struct ethtool_rxnfc, data) +
+			     sizeof(info.data));
+
+	if (copy_from_user(&info, useraddr, info_size))
 		return -EFAULT;
 
 	if (info.cmd == ETHTOOL_GRXCLSRLALL) {
@@ -360,7 +378,7 @@ static noinline_for_stack int ethtool_get_rxnfc(struct net_device *dev,
 		goto err_out;
 
 	ret = -EFAULT;
-	if (copy_to_user(useraddr, &info, sizeof(info)))
+	if (copy_to_user(useraddr, &info, info_size))
 		goto err_out;
 
 	if (rule_buf) {
@@ -1517,12 +1535,12 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GRXCLSRLCNT:
 	case ETHTOOL_GRXCLSRULE:
 	case ETHTOOL_GRXCLSRLALL:
-		rc = ethtool_get_rxnfc(dev, useraddr);
+		rc = ethtool_get_rxnfc(dev, ethcmd, useraddr);
 		break;
 	case ETHTOOL_SRXFH:
 	case ETHTOOL_SRXCLSRLDEL:
 	case ETHTOOL_SRXCLSRLINS:
-		rc = ethtool_set_rxnfc(dev, useraddr);
+		rc = ethtool_set_rxnfc(dev, ethcmd, useraddr);
 		break;
 	case ETHTOOL_GGRO:
 		rc = ethtool_get_gro(dev, useraddr);
-- 
1.6.2.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

