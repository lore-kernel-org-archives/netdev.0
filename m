From: Parav Pandit <parav.pandit@emulex.com>
Subject: [PATCHv1] net: added support for 40GbE link.
Date: Wed, 27 Jun 2012 19:26:12 +0530
Message-ID: <054018eb-a85c-4401-a010-7479aa38d2ef@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <bhutchings@solarflare.com>, Parav Pandit <parav.pandit@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:13959 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753538Ab2F0Juy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 05:50:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. removed code replication for tov calculation for 1G, 10G and
made is common for speed > 1G (1G, 10G, 40G, 100G).
2. defines values for #4 different 40G Phys (KR4, LF4, SR4, CR4)

Signed-off-by: Parav Pandit <parav.pandit@emulex.com>
---
 include/linux/ethtool.h |    8 ++++++++
 net/packet/af_packet.c  |   18 ++++++------------
 2 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 297370a..21eff41 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -1153,6 +1153,10 @@ struct ethtool_ops {
 #define SUPPORTED_10000baseR_FEC	(1 << 20)
 #define SUPPORTED_20000baseMLD2_Full	(1 << 21)
 #define SUPPORTED_20000baseKR2_Full	(1 << 22)
+#define SUPPORTED_40000baseKR4_Full	(1 << 23)
+#define SUPPORTED_40000baseCR4_Full	(1 << 24)
+#define SUPPORTED_40000baseSR4_Full	(1 << 25)
+#define SUPPORTED_40000baseLR4_Full	(1 << 26)
 
 /* Indicates what features are advertised by the interface. */
 #define ADVERTISED_10baseT_Half		(1 << 0)
@@ -1178,6 +1182,10 @@ struct ethtool_ops {
 #define ADVERTISED_10000baseR_FEC	(1 << 20)
 #define ADVERTISED_20000baseMLD2_Full	(1 << 21)
 #define ADVERTISED_20000baseKR2_Full	(1 << 22)
+#define ADVERTISED_40000baseKR4_Full	(1 << 23)
+#define ADVERTISED_40000baseCR4_Full	(1 << 24)
+#define ADVERTISED_40000baseSR4_Full	(1 << 25)
+#define ADVERTISED_40000baseLR4_Full	(1 << 26)
 
 /* The following are all involved in forcing a particular link
  * mode for the device for setting things.  When getting the
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 8a10d5b..ceaca7c 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -531,6 +531,7 @@ static int prb_calc_retire_blk_tmo(struct packet_sock *po,
 	unsigned int mbits = 0, msec = 0, div = 0, tmo = 0;
 	struct ethtool_cmd ecmd;
 	int err;
+	u32 speed;
 
 	rtnl_lock();
 	dev = __dev_get_by_index(sock_net(&po->sk), po->ifindex);
@@ -539,25 +540,18 @@ static int prb_calc_retire_blk_tmo(struct packet_sock *po,
 		return DEFAULT_PRB_RETIRE_TOV;
 	}
 	err = __ethtool_get_settings(dev, &ecmd);
+	speed = ethtool_cmd_speed(&ecmd);
 	rtnl_unlock();
 	if (!err) {
-		switch (ecmd.speed) {
-		case SPEED_10000:
-			msec = 1;
-			div = 10000/1000;
-			break;
-		case SPEED_1000:
-			msec = 1;
-			div = 1000/1000;
-			break;
 		/*
 		 * If the link speed is so slow you don't really
 		 * need to worry about perf anyways
 		 */
-		case SPEED_100:
-		case SPEED_10:
-		default:
+		if (speed < SPEED_1000 || speed == SPEED_UNKNOWN) {
 			return DEFAULT_PRB_RETIRE_TOV;
+		} else {
+			msec = 1;
+			div = speed / 1000;
 		}
 	}
 
-- 
1.6.0.2
