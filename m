From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/3] net: ethtool: export conversion function between u32 and link mode
Date: Fri, 15 Apr 2016 00:34:59 +0200
Message-ID: <1460673301-10599-2-git-send-email-tremyfr@gmail.com>
References: <1460673301-10599-1-git-send-email-tremyfr@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, decot@googlers.com, f.fainelli@gmail.com,
	fugang.duan@nxp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33755 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752508AbcDNWfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 18:35:12 -0400
In-Reply-To: <1460673301-10599-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function convert_legacy_u32_to_link_mode and
convert_link_mode_to_legacy_u32 may be used outside
of ethtool.c. We rename them to ethtool_convert_...
and export them, so we could use them in others
drivers and modules.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 include/linux/ethtool.h |    7 +++++++
 net/core/ethtool.c      |   21 ++++++++++++---------
 2 files changed, 19 insertions(+), 9 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index e2b7bf2..9ded8c6 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -150,6 +150,13 @@ extern int
 __ethtool_get_link_ksettings(struct net_device *dev,
 			     struct ethtool_link_ksettings *link_ksettings);
 
+void ethtool_convert_legacy_u32_to_link_mode(unsigned long *dst,
+					     u32 legacy_u32);
+
+/* return false if src had higher bits set. lower bits always updated. */
+bool ethtool_convert_link_mode_to_legacy_u32(u32 *legacy_u32,
+				     const unsigned long *src);
+
 /**
  * struct ethtool_ops - optional netdev operations
  * @get_settings: DEPRECATED, use %get_link_ksettings/%set_link_ksettings
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index f426c5a..81e3082 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -387,15 +387,17 @@ static int __ethtool_set_flags(struct net_device *dev, u32 data)
 	return 0;
 }
 
-static void convert_legacy_u32_to_link_mode(unsigned long *dst, u32 legacy_u32)
+void ethtool_convert_legacy_u32_to_link_mode(unsigned long *dst,
+					     u32 legacy_u32)
 {
 	bitmap_zero(dst, __ETHTOOL_LINK_MODE_MASK_NBITS);
 	dst[0] = legacy_u32;
 }
+EXPORT_SYMBOL(ethtool_convert_legacy_u32_to_link_mode);
 
 /* return false if src had higher bits set. lower bits always updated. */
-static bool convert_link_mode_to_legacy_u32(u32 *legacy_u32,
-					    const unsigned long *src)
+bool ethtool_convert_link_mode_to_legacy_u32(u32 *legacy_u32,
+					     const unsigned long *src)
 {
 	bool retval = true;
 
@@ -415,6 +417,7 @@ static bool convert_link_mode_to_legacy_u32(u32 *legacy_u32,
 	*legacy_u32 = src[0];
 	return retval;
 }
+EXPORT_SYMBOL(ethtool_convert_link_mode_to_legacy_u32);
 
 /* return false if legacy contained non-0 deprecated fields
  * transceiver/maxtxpkt/maxrxpkt. rest of ksettings always updated
@@ -437,13 +440,13 @@ convert_legacy_settings_to_link_ksettings(
 	    legacy_settings->maxrxpkt)
 		retval = false;
 
-	convert_legacy_u32_to_link_mode(
+	ethtool_convert_legacy_u32_to_link_mode(
 		link_ksettings->link_modes.supported,
 		legacy_settings->supported);
-	convert_legacy_u32_to_link_mode(
+	ethtool_convert_legacy_u32_to_link_mode(
 		link_ksettings->link_modes.advertising,
 		legacy_settings->advertising);
-	convert_legacy_u32_to_link_mode(
+	ethtool_convert_legacy_u32_to_link_mode(
 		link_ksettings->link_modes.lp_advertising,
 		legacy_settings->lp_advertising);
 	link_ksettings->base.speed
@@ -482,13 +485,13 @@ convert_link_ksettings_to_legacy_settings(
 	 * __u32	maxrxpkt;
 	 */
 
-	retval &= convert_link_mode_to_legacy_u32(
+	retval &= ethtool_convert_link_mode_to_legacy_u32(
 		&legacy_settings->supported,
 		link_ksettings->link_modes.supported);
-	retval &= convert_link_mode_to_legacy_u32(
+	retval &= ethtool_convert_link_mode_to_legacy_u32(
 		&legacy_settings->advertising,
 		link_ksettings->link_modes.advertising);
-	retval &= convert_link_mode_to_legacy_u32(
+	retval &= ethtool_convert_link_mode_to_legacy_u32(
 		&legacy_settings->lp_advertising,
 		link_ksettings->link_modes.lp_advertising);
 	ethtool_cmd_speed_set(legacy_settings, link_ksettings->base.speed);
-- 
1.7.4.4
