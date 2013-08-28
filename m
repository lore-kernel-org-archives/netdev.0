From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 04/16] sfc: Remove driver-local struct
 ethtool_string
Date: Wed, 28 Aug 2013 16:18:09 +0100
Message-ID: <1377703089.2264.26.camel@bwh-desktop.uk.level5networks.com>
References: <1377702837.2264.21.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17165 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753281Ab3H1PSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 11:18:12 -0400
In-Reply-To: <1377702837.2264.21.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's not really helpful to pretend ethtool string arrays are
structured.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ethtool.c | 37 +++++++++++++------------------------
 1 file changed, 13 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 55c3826..86b4391 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -19,10 +19,6 @@
 #include "filter.h"
 #include "nic.h"
 
-struct ethtool_string {
-	char name[ETH_GSTRING_LEN];
-};
-
 struct efx_ethtool_stat {
 	const char *name;
 	enum {
@@ -289,12 +285,11 @@ static void efx_ethtool_set_msglevel(struct net_device *net_dev, u32 msg_enable)
  *
  * Fill in an individual self-test entry.
  */
-static void efx_fill_test(unsigned int test_index,
-			  struct ethtool_string *strings, u64 *data,
+static void efx_fill_test(unsigned int test_index, u8 *strings, u64 *data,
 			  int *test, const char *unit_format, int unit_id,
 			  const char *test_format, const char *test_id)
 {
-	struct ethtool_string unit_str, test_str;
+	char unit_str[ETH_GSTRING_LEN], test_str[ETH_GSTRING_LEN];
 
 	/* Fill data value, if applicable */
 	if (data)
@@ -303,15 +298,14 @@ static void efx_fill_test(unsigned int test_index,
 	/* Fill string, if applicable */
 	if (strings) {
 		if (strchr(unit_format, '%'))
-			snprintf(unit_str.name, sizeof(unit_str.name),
+			snprintf(unit_str, sizeof(unit_str),
 				 unit_format, unit_id);
 		else
-			strcpy(unit_str.name, unit_format);
-		snprintf(test_str.name, sizeof(test_str.name),
-			 test_format, test_id);
-		snprintf(strings[test_index].name,
-			 sizeof(strings[test_index].name),
-			 "%-6s %-24s", unit_str.name, test_str.name);
+			strcpy(unit_str, unit_format);
+		snprintf(test_str, sizeof(test_str), test_format, test_id);
+		snprintf(strings + test_index * ETH_GSTRING_LEN,
+			 ETH_GSTRING_LEN,
+			 "%-6s %-24s", unit_str, test_str);
 	}
 }
 
@@ -334,7 +328,7 @@ static int efx_fill_loopback_test(struct efx_nic *efx,
 				  struct efx_loopback_self_tests *lb_tests,
 				  enum efx_loopback_mode mode,
 				  unsigned int test_index,
-				  struct ethtool_string *strings, u64 *data)
+				  u8 *strings, u64 *data)
 {
 	struct efx_channel *channel =
 		efx_get_channel(efx, efx->tx_channel_offset);
@@ -371,8 +365,7 @@ static int efx_fill_loopback_test(struct efx_nic *efx,
  */
 static int efx_ethtool_fill_self_tests(struct efx_nic *efx,
 				       struct efx_self_tests *tests,
-				       struct ethtool_string *strings,
-				       u64 *data)
+				       u8 *strings, u64 *data)
 {
 	struct efx_channel *channel;
 	unsigned int n = 0, i;
@@ -446,20 +439,16 @@ static void efx_ethtool_get_strings(struct net_device *net_dev,
 				    u32 string_set, u8 *strings)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
-	struct ethtool_string *ethtool_strings =
-		(struct ethtool_string *)strings;
 	int i;
 
 	switch (string_set) {
 	case ETH_SS_STATS:
 		for (i = 0; i < EFX_ETHTOOL_NUM_STATS; i++)
-			strlcpy(ethtool_strings[i].name,
-				efx_ethtool_stats[i].name,
-				sizeof(ethtool_strings[i].name));
+			strlcpy(strings + i * ETH_GSTRING_LEN,
+				efx_ethtool_stats[i].name, ETH_GSTRING_LEN);
 		break;
 	case ETH_SS_TEST:
-		efx_ethtool_fill_self_tests(efx, NULL,
-					    ethtool_strings, NULL);
+		efx_ethtool_fill_self_tests(efx, NULL, strings, NULL);
 		break;
 	default:
 		/* No other string sets */


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
