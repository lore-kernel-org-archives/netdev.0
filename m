From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 10/15] batman-adv: Fix gw_bandwidth calculation on 32 bit systems
Date: Tue, 25 Aug 2015 13:02:34 +0200
Message-ID: <1440500559-28368-11-git-send-email-antonio__23271.2270845242$1440501696$gmane$org@meshcoding.com>
References: <1440500559-28368-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:12477 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751087AbbHYLVY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2015 07:21:24 -0400
In-Reply-To: <1440500559-28368-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The TVLV for the gw_bandwidth stores everything as u32. But the
gw_bandwidth reads the signed long which limits the maximum value to
(2 ** 31 - 1) on systems with 4 byte long. Also the input value is always
converted from either Mibit/s or Kibit/s to 100Kibit/s. This reduces the
values even further when the user sets it via the default unit Kibit/s. It
may even cause an integer overflow and end up with a value the user never
intended.

Instead read the values as u64, check for possible overflows, do the unit
adjustments and then reduce the size to u32.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/gateway_common.c | 49 +++++++++++++++++++++++++++++++++++------
 1 file changed, 42 insertions(+), 7 deletions(-)

diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_common.c
index 6b930a6..0cb5e6b 100644
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -22,6 +22,7 @@
 #include <linux/errno.h>
 #include <linux/byteorder/generic.h>
 #include <linux/kernel.h>
+#include <linux/math64.h>
 #include <linux/netdevice.h>
 #include <linux/stddef.h>
 #include <linux/string.h>
@@ -44,7 +45,7 @@ static bool batadv_parse_gw_bandwidth(struct net_device *net_dev, char *buff,
 {
 	enum batadv_bandwidth_units bw_unit_type = BATADV_BW_UNIT_KBIT;
 	char *slash_ptr, *tmp_ptr;
-	long ldown, lup;
+	u64 ldown, lup;
 	int ret;
 
 	slash_ptr = strchr(buff, '/');
@@ -62,7 +63,7 @@ static bool batadv_parse_gw_bandwidth(struct net_device *net_dev, char *buff,
 			*tmp_ptr = '\0';
 	}
 
-	ret = kstrtol(buff, 10, &ldown);
+	ret = kstrtou64(buff, 10, &ldown);
 	if (ret) {
 		batadv_err(net_dev,
 			   "Download speed of gateway mode invalid: %s\n",
@@ -72,14 +73,31 @@ static bool batadv_parse_gw_bandwidth(struct net_device *net_dev, char *buff,
 
 	switch (bw_unit_type) {
 	case BATADV_BW_UNIT_MBIT:
-		*down = ldown * 10;
+		/* prevent overflow */
+		if (U64_MAX / 10 < ldown) {
+			batadv_err(net_dev,
+				   "Download speed of gateway mode too large: %s\n",
+				   buff);
+			return false;
+		}
+
+		ldown *= 10;
 		break;
 	case BATADV_BW_UNIT_KBIT:
 	default:
-		*down = ldown / 100;
+		ldown = div_u64(ldown, 100);
 		break;
 	}
 
+	if (U32_MAX < ldown) {
+		batadv_err(net_dev,
+			   "Download speed of gateway mode too large: %s\n",
+			   buff);
+		return false;
+	}
+
+	*down = ldown;
+
 	/* we also got some upload info */
 	if (slash_ptr) {
 		bw_unit_type = BATADV_BW_UNIT_KBIT;
@@ -95,7 +113,7 @@ static bool batadv_parse_gw_bandwidth(struct net_device *net_dev, char *buff,
 				*tmp_ptr = '\0';
 		}
 
-		ret = kstrtol(slash_ptr + 1, 10, &lup);
+		ret = kstrtou64(slash_ptr + 1, 10, &lup);
 		if (ret) {
 			batadv_err(net_dev,
 				   "Upload speed of gateway mode invalid: %s\n",
@@ -105,13 +123,30 @@ static bool batadv_parse_gw_bandwidth(struct net_device *net_dev, char *buff,
 
 		switch (bw_unit_type) {
 		case BATADV_BW_UNIT_MBIT:
-			*up = lup * 10;
+			/* prevent overflow */
+			if (U64_MAX / 10 < lup) {
+				batadv_err(net_dev,
+					   "Upload speed of gateway mode too large: %s\n",
+					   slash_ptr + 1);
+				return false;
+			}
+
+			lup *= 10;
 			break;
 		case BATADV_BW_UNIT_KBIT:
 		default:
-			*up = lup / 100;
+			lup = div_u64(lup, 100);
 			break;
 		}
+
+		if (U32_MAX < lup) {
+			batadv_err(net_dev,
+				   "Upload speed of gateway mode too large: %s\n",
+				   slash_ptr + 1);
+			return false;
+		}
+
+		*up = lup;
 	}
 
 	return true;
-- 
2.5.0
