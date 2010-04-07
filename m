From: Manfred Rudigier <Manfred.Rudigier@omicron.at>
Subject: [RFC PATCH net-next 2/4] gianfar: Added timer feature for eTSEC
Date: Wed, 7 Apr 2010 11:46:24 +0200
Message-ID: <95DC1AA8EC908B48939B72CF375AA5E311A9F4E0@alice.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'linuxppc-dev@lists.ozlabs.org'" <linuxppc-dev@lists.ozlabs.org>
To: "'sandeep.kumar@freescale.com'" <sandeep.kumar@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.omicron.at ([212.183.10.25]:60232 "EHLO ns.omicron.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757799Ab0DGKYM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 06:24:12 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The timer clock module is an intrinsic feature of every eTSEC. It supports
hardware time stamping of all incoming and outgoing network packets. This
patch checks if the underlying hardware is an eTSEC and adds the
new FSL_GIANFAR_DEV_HAS_TIMER flag to the device flags. This flag is then
used in the SIOCSHWTSTAMP ioctl command to determine if HW time stamping
support is available.

Signed-off-by: Manfred Rudigier <manfred.rudigier@omicron.at>
---
 drivers/net/gianfar.c |   12 +++++++++++-
 drivers/net/gianfar.h |    3 +++
 2 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 309bab0..41e7726 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -743,7 +743,8 @@ static int gfar_of_init(struct of_device *ofdev, struct net_device **pdev)
 			FSL_GIANFAR_DEV_HAS_CSUM |
 			FSL_GIANFAR_DEV_HAS_VLAN |
 			FSL_GIANFAR_DEV_HAS_MAGIC_PACKET |
-			FSL_GIANFAR_DEV_HAS_EXTENDED_HASH;
+			FSL_GIANFAR_DEV_HAS_EXTENDED_HASH |
+			FSL_GIANFAR_DEV_HAS_TIMER;
 
 	ctype = of_get_property(np, "phy-connection-type", NULL);
 
@@ -777,6 +778,7 @@ static int gfar_hwtstamp_ioctl(struct net_device *netdev,
 			struct ifreq *ifr, int cmd)
 {
 	struct hwtstamp_config config;
+	struct gfar_private *priv = netdev_priv(netdev);
 
 	if (copy_from_user(&config, ifr->ifr_data, sizeof(config)))
 		return -EFAULT;
@@ -787,8 +789,12 @@ static int gfar_hwtstamp_ioctl(struct net_device *netdev,
 
 	switch (config.tx_type) {
 	case HWTSTAMP_TX_OFF:
+		priv->hwts_tx_en = 0;
 		break;
 	case HWTSTAMP_TX_ON:
+		if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_TIMER))
+			return -ERANGE;
+		priv->hwts_tx_en = 1;
 		return -ERANGE;
 	default:
 		return -ERANGE;
@@ -796,8 +802,12 @@ static int gfar_hwtstamp_ioctl(struct net_device *netdev,
 
 	switch (config.rx_filter) {
 	case HWTSTAMP_FILTER_NONE:
+		priv->hwts_rx_en = 0;
 		break;
 	default:
+		if (!(priv->device_flags & FSL_GIANFAR_DEV_HAS_TIMER))
+			return -ERANGE;
+		priv->hwts_rx_en = 1;
 		return -ERANGE;
 	}
 
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 17d25e7..380ea48 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -885,6 +885,7 @@ struct gfar {
 #define FSL_GIANFAR_DEV_HAS_MAGIC_PACKET	0x00000100
 #define FSL_GIANFAR_DEV_HAS_BD_STASHING		0x00000200
 #define FSL_GIANFAR_DEV_HAS_BUF_STASHING	0x00000400
+#define FSL_GIANFAR_DEV_HAS_TIMER		0x00000800
 
 #if (MAXGROUPS == 2)
 #define DEFAULT_MAPPING 	0xAA
@@ -1084,6 +1085,8 @@ struct gfar_private {
 		extended_hash:1,
 		bd_stash_en:1,
 		rx_filer_enable:1,
+		hwts_tx_en:1, /* HW time stamping enabled for TX packets */
+		hwts_rx_en:1, /* HW time stamping enabled for RX packets */
 		wol_en:1; /* Wake-on-LAN enabled */
 	unsigned short padding;
 
-- 
1.6.3.3
