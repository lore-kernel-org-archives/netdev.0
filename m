From: <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH net-next]  benet: convert to 64 bit stats
Date: Tue, 28 Jun 2011 00:37:14 -0700
Message-ID: <3367B80B08154D42A3B2BC708B5D41F63F188EE930@EXMAIL.ad.emulex.com>
References: <4da4117c-a24a-4512-9b79-fbed126e03bc@exht1.ad.emulex.com>
	<20110627094337.5108b5f6@nehalam.ftrdhcpuser.net>
 <20110627114313.1d1b9680@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <shemminger@vyatta.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:4133 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755824Ab1F1Hhf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2011 03:37:35 -0400
In-Reply-To: <20110627114313.1d1b9680@nehalam.ftrdhcpuser.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Stephen Hemminger [mailto:shemminger@vyatta.com]
>Sent: Tuesday, June 28, 2011 12:13 AM
>To: David Miller
>Cc: Perla, Sathya; netdev@vger.kernel.org
>Subject: [PATCH net-next] benet: convert to 64 bit stats
>
>This changes how the benet driver does statistics:
>  * use 64 bit statistics interface (old api was only 32 bit on 32 bit
>platform)
>  * use u64_stats_sync to ensure atomic 64 bit on 32 bit SMP
>  * only update statistics when needed
>
>Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
>---
>
> drivers/net/benet/be.h      |    4 -
> drivers/net/benet/be_cmds.c |    1
> drivers/net/benet/be_main.c |  161 ++++++++++++++++++++++++----------------
>----
> 3 files changed, 93 insertions(+), 73 deletions(-)

Thanks for the patch!
be_ethtool.c:be_get_ethtool_stats() currently accesses old netdev->stats. This needs to be fixed.
I guess it would be OK to drop netdev stats from being reported via ethtool.
The routine also accesses per-ring rx_bytes/rx_pkts. I'm OK with dropping these too in ethtool for
the scope of this patch as the aggregates are reported in netdev stats.

Can you incorporate the following changes...

diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 30c1386..9a89caa 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -26,13 +26,9 @@ struct be_ethtool_stat {
 	int offset;
 };
 
-enum {NETSTAT, DRVSTAT_TX, DRVSTAT_RX, ERXSTAT,
-			DRVSTAT};
+enum {DRVSTAT_TX, DRVSTAT_RX, ERXSTAT, DRVSTAT};
 #define FIELDINFO(_struct, field) FIELD_SIZEOF(_struct, field), \
 					offsetof(_struct, field)
-#define NETSTAT_INFO(field) 	#field, NETSTAT,\
-					FIELDINFO(struct net_device_stats,\
-						field)
 #define DRVSTAT_TX_INFO(field)	#field, DRVSTAT_TX,\
 					FIELDINFO(struct be_tx_stats, field)
 #define DRVSTAT_RX_INFO(field)	#field, DRVSTAT_RX,\
@@ -44,14 +40,6 @@ enum {NETSTAT, DRVSTAT_TX, DRVSTAT_RX, ERXSTAT,
 						field)
 
 static const struct be_ethtool_stat et_stats[] = {
-	{NETSTAT_INFO(rx_packets)},
-	{NETSTAT_INFO(tx_packets)},
-	{NETSTAT_INFO(rx_bytes)},
-	{NETSTAT_INFO(tx_bytes)},
-	{NETSTAT_INFO(rx_errors)},
-	{NETSTAT_INFO(tx_errors)},
-	{NETSTAT_INFO(rx_dropped)},
-	{NETSTAT_INFO(tx_dropped)},
 	{DRVSTAT_INFO(be_tx_events)},
 	{DRVSTAT_INFO(rx_crc_errors)},
 	{DRVSTAT_INFO(rx_alignment_symbol_errors)},
@@ -94,8 +82,6 @@ static const struct be_ethtool_stat et_stats[] = {
 
 /* Stats related to multi RX queues */
 static const struct be_ethtool_stat et_rx_stats[] = {
-	{DRVSTAT_RX_INFO(rx_bytes)},
-	{DRVSTAT_RX_INFO(rx_pkts)},
 	{DRVSTAT_RX_INFO(rx_rate)},
 	{DRVSTAT_RX_INFO(rx_polls)},
 	{DRVSTAT_RX_INFO(rx_events)},
@@ -263,16 +249,7 @@ be_get_ethtool_stats(struct net_device *netdev,
 	int i, j, base;
 
 	for (i = 0; i < ETHTOOL_STATS_NUM; i++) {
-		switch (et_stats[i].type) {
-		case NETSTAT:
-			p = &netdev->stats;
-			break;
-		case DRVSTAT:
-			p = &adapter->drv_stats;
-			break;
-		}
-
-		p = (u8 *)p + et_stats[i].offset;
+		p = (u8 *)&adapter->drv_stats + et_stats[i].offset;
 		data[i] = (et_stats[i].size == sizeof(u64)) ?
 				*(u64 *)p: *(u32 *)p;
 	}
@@ -282,7 +259,7 @@ be_get_ethtool_stats(struct net_device *netdev,
 		for (i = 0; i < ETHTOOL_RXSTATS_NUM; i++) {
 			switch (et_rx_stats[i].type) {
 			case DRVSTAT_RX:
-				p = (u8 *)&rxo->stats + et_rx_stats[i].offset;
+				p = (u8 *)rx_stats(rxo) + et_rx_stats[i].offset;
 				break;
 			case ERXSTAT:
 				p = (u32 *)be_erx_stats_from_cmd(adapter) +
@@ -298,7 +275,7 @@ be_get_ethtool_stats(struct net_device *netdev,
 	base = ETHTOOL_STATS_NUM + adapter->num_rx_qs * ETHTOOL_RXSTATS_NUM;
 	for_all_tx_queues(adapter, txo, j) {
 		for (i = 0; i < ETHTOOL_TXSTATS_NUM; i++) {
-			p = (u8 *)&txo->stats + et_tx_stats[i].offset;
+			p = (u8 *)tx_stats(txo) + et_tx_stats[i].offset;
 			data[base + j * ETHTOOL_TXSTATS_NUM + i] =
 				(et_tx_stats[i].size == sizeof(u64)) ?
 					*(u64 *)p: *(u32 *)p;



