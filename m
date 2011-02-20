From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 1/6] be2net: add new counters to display via
 ethtool stats
Date: Sun, 20 Feb 2011 15:41:04 -0600
Message-ID: <20110220214104.GA13626@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:11619 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754981Ab1BTVlk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Feb 2011 16:41:40 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New counters:
	> jabber frame stats
	> red drop stats

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be_cmds.h    |   12 ++++++++++--
 drivers/net/benet/be_ethtool.c |   13 +++++++++++--
 2 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/drivers/net/benet/be_cmds.h b/drivers/net/benet/be_cmds.h
index 91c5d2b..331e954 100644
--- a/drivers/net/benet/be_cmds.h
+++ b/drivers/net/benet/be_cmds.h
@@ -619,7 +619,10 @@ struct be_rxf_stats {
 	u32 rx_drops_invalid_ring;	/* dword 145*/
 	u32 forwarded_packets;	/* dword 146*/
 	u32 rx_drops_mtu;	/* dword 147*/
-	u32 rsvd0[15];
+	u32 rsvd0[7];
+	u32 port0_jabber_events;
+	u32 port1_jabber_events;
+	u32 rsvd1[6];
 };
 
 struct be_erx_stats {
@@ -630,11 +633,16 @@ struct be_erx_stats {
 	u32 debug_pmem_pbuf_dealloc;       /* dword 47*/
 };
 
+struct be_pmem_stats {
+	u32 eth_red_drops;
+	u32 rsvd[4];
+};
+
 struct be_hw_stats {
 	struct be_rxf_stats rxf;
 	u32 rsvd[48];
 	struct be_erx_stats erx;
-	u32 rsvd1[6];
+	struct be_pmem_stats pmem;
 };
 
 struct be_cmd_req_get_stats {
diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 07b4ab9..82a9a27 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -26,7 +26,8 @@ struct be_ethtool_stat {
 	int offset;
 };
 
-enum {NETSTAT, PORTSTAT, MISCSTAT, DRVSTAT_TX, DRVSTAT_RX, ERXSTAT};
+enum {NETSTAT, PORTSTAT, MISCSTAT, DRVSTAT_TX, DRVSTAT_RX, ERXSTAT,
+			PMEMSTAT};
 #define FIELDINFO(_struct, field) FIELD_SIZEOF(_struct, field), \
 					offsetof(_struct, field)
 #define NETSTAT_INFO(field) 	#field, NETSTAT,\
@@ -43,6 +44,8 @@ enum {NETSTAT, PORTSTAT, MISCSTAT, DRVSTAT_TX, DRVSTAT_RX, ERXSTAT};
 						field)
 #define ERXSTAT_INFO(field) 	#field, ERXSTAT,\
 					FIELDINFO(struct be_erx_stats, field)
+#define PMEMSTAT_INFO(field) 	#field, PMEMSTAT,\
+					FIELDINFO(struct be_pmem_stats, field)
 
 static const struct be_ethtool_stat et_stats[] = {
 	{NETSTAT_INFO(rx_packets)},
@@ -99,7 +102,10 @@ static const struct be_ethtool_stat et_stats[] = {
 	{MISCSTAT_INFO(rx_drops_too_many_frags)},
 	{MISCSTAT_INFO(rx_drops_invalid_ring)},
 	{MISCSTAT_INFO(forwarded_packets)},
-	{MISCSTAT_INFO(rx_drops_mtu)}
+	{MISCSTAT_INFO(rx_drops_mtu)},
+	{MISCSTAT_INFO(port0_jabber_events)},
+	{MISCSTAT_INFO(port1_jabber_events)},
+	{PMEMSTAT_INFO(eth_red_drops)}
 };
 #define ETHTOOL_STATS_NUM ARRAY_SIZE(et_stats)
 
@@ -276,6 +282,9 @@ be_get_ethtool_stats(struct net_device *netdev,
 		case MISCSTAT:
 			p = &hw_stats->rxf;
 			break;
+		case PMEMSTAT:
+			p = &hw_stats->pmem;
+			break;
 		}
 
 		p = (u8 *)p + et_stats[i].offset;
-- 
1.7.1

