From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 1/4] qeth: Convert ethtool get_stats_count() ops to
	get_sset_count()
Date: Thu, 01 Oct 2009 22:24:32 +0100
Message-ID: <1254432272.2735.20.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ursula Braun <ursula.braun@de.ibm.com>,
	Frank Blaschka <frank.blaschka@de.ibm.com>,
	linux-s390@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:2485 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752004AbZJAVYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 17:24:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This string query operation was supposed to be replaced by the
generic get_sset_count() starting in 2007.  Convert qeth's
implementation.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
This is not even compile-tested because I don't have an s390 compiler.
But it's simple enough that I think I got it right...

Ben.

 drivers/s390/net/qeth_core.h      |    2 +-
 drivers/s390/net/qeth_core_main.c |   11 ++++++++---
 drivers/s390/net/qeth_l2_main.c   |    4 ++--
 drivers/s390/net/qeth_l3_main.c   |    2 +-
 4 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index 31a2b4e..e8f72d7 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -849,7 +849,7 @@ int qeth_do_send_packet_fast(struct qeth_card *, struct qeth_qdio_out_q *,
 			struct sk_buff *, struct qeth_hdr *, int, int, int);
 int qeth_do_send_packet(struct qeth_card *, struct qeth_qdio_out_q *,
 		    struct sk_buff *, struct qeth_hdr *, int);
-int qeth_core_get_stats_count(struct net_device *);
+int qeth_core_get_sset_count(struct net_device *, int);
 void qeth_core_get_ethtool_stats(struct net_device *,
 				struct ethtool_stats *, u64 *);
 void qeth_core_get_strings(struct net_device *, u32, u8 *);
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index c4a42d9..edee4dc 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -4305,11 +4305,16 @@ static struct {
 	{"tx csum"},
 };
 
-int qeth_core_get_stats_count(struct net_device *dev)
+int qeth_core_get_sset_count(struct net_device *dev, int stringset)
 {
-	return (sizeof(qeth_ethtool_stats_keys) / ETH_GSTRING_LEN);
+	switch (stringset) {
+	case ETH_SS_STATS:
+		return (sizeof(qeth_ethtool_stats_keys) / ETH_GSTRING_LEN);
+	default:
+		return -EINVAL;
+	}
 }
-EXPORT_SYMBOL_GPL(qeth_core_get_stats_count);
+EXPORT_SYMBOL_GPL(qeth_core_get_sset_count);
 
 void qeth_core_get_ethtool_stats(struct net_device *dev,
 		struct ethtool_stats *stats, u64 *data)
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index f4f3ca1..b61d5c7 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -866,7 +866,7 @@ static const struct ethtool_ops qeth_l2_ethtool_ops = {
 	.get_link = ethtool_op_get_link,
 	.get_strings = qeth_core_get_strings,
 	.get_ethtool_stats = qeth_core_get_ethtool_stats,
-	.get_stats_count = qeth_core_get_stats_count,
+	.get_sset_count = qeth_core_get_sset_count,
 	.get_drvinfo = qeth_core_get_drvinfo,
 	.get_settings = qeth_core_ethtool_get_settings,
 };
@@ -874,7 +874,7 @@ static const struct ethtool_ops qeth_l2_ethtool_ops = {
 static const struct ethtool_ops qeth_l2_osn_ops = {
 	.get_strings = qeth_core_get_strings,
 	.get_ethtool_stats = qeth_core_get_ethtool_stats,
-	.get_stats_count = qeth_core_get_stats_count,
+	.get_sset_count = qeth_core_get_sset_count,
 	.get_drvinfo = qeth_core_get_drvinfo,
 };
 
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 073b6d3..4ca28c1 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2957,7 +2957,7 @@ static const struct ethtool_ops qeth_l3_ethtool_ops = {
 	.set_tso     = qeth_l3_ethtool_set_tso,
 	.get_strings = qeth_core_get_strings,
 	.get_ethtool_stats = qeth_core_get_ethtool_stats,
-	.get_stats_count = qeth_core_get_stats_count,
+	.get_sset_count = qeth_core_get_sset_count,
 	.get_drvinfo = qeth_core_get_drvinfo,
 	.get_settings = qeth_core_ethtool_get_settings,
 };

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

