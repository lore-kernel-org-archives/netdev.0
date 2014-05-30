From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH v2 net-next 5/8] net: cdc_ncm: drop ethtool coalesce support
Date: Fri, 30 May 2014 09:31:07 +0200
Message-ID: <1401435070-26721-6-git-send-email-bjorn@mork.no>
References: <1401435070-26721-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-usb@vger.kernel.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Oliver Neukum <oliver@neukum.org>,
	Enrico Mioso <mrkiko.rs@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Lars Melin <larsm17@gmail.com>, Peter Stuge <peter@stuge.se>,
	Greg Suarez <gsuarez@smithmicro.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:51786 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932093AbaE3HdI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2014 03:33:08 -0400
In-Reply-To: <1401435070-26721-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool coalesce API is not applicable for this driver. Forcing
it to fit the NCM aggregation redefined the API in a driver specific
way, which is much worse than defining a clean new API. These ethtool
coalesce functions have therefore been replaced by a new sysfs API.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c | 48 ---------------------------------------=
--------
 1 file changed, 48 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 631741c8ff22..aaa440d892b8 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -127,54 +127,8 @@ static void cdc_ncm_get_strings(struct net_device =
__always_unused *netdev, u32 s
 	}
 }
=20
-static int cdc_ncm_get_coalesce(struct net_device *netdev,
-				struct ethtool_coalesce *ec)
-{
-	struct usbnet *dev =3D netdev_priv(netdev);
-	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
-
-	/* assuming maximum sized dgrams and ignoring NDPs */
-	ec->rx_max_coalesced_frames =3D ctx->rx_max / ctx->max_datagram_size;
-	ec->tx_max_coalesced_frames =3D ctx->tx_max / ctx->max_datagram_size;
-
-	/* the timer will fire CDC_NCM_TIMER_PENDING_CNT times in a row */
-	ec->tx_coalesce_usecs =3D ctx->timer_interval / (NSEC_PER_USEC / CDC_=
NCM_TIMER_PENDING_CNT);
-	return 0;
-}
-
 static void cdc_ncm_update_rxtx_max(struct usbnet *dev, u32 new_rx, u3=
2 new_tx);
=20
-static int cdc_ncm_set_coalesce(struct net_device *netdev,
-				struct ethtool_coalesce *ec)
-{
-	struct usbnet *dev =3D netdev_priv(netdev);
-	struct cdc_ncm_ctx *ctx =3D (struct cdc_ncm_ctx *)dev->data[0];
-	u32 new_rx_max =3D ctx->rx_max;
-	u32 new_tx_max =3D ctx->tx_max;
-
-	/* assuming maximum sized dgrams and a single NDP */
-	if (ec->rx_max_coalesced_frames)
-		new_rx_max =3D ec->rx_max_coalesced_frames * ctx->max_datagram_size;
-	if (ec->tx_max_coalesced_frames)
-		new_tx_max =3D ec->tx_max_coalesced_frames * ctx->max_datagram_size;
-
-	if (ec->tx_coalesce_usecs &&
-	    (ec->tx_coalesce_usecs < CDC_NCM_TIMER_INTERVAL_MIN * CDC_NCM_TIM=
ER_PENDING_CNT ||
-	     ec->tx_coalesce_usecs > CDC_NCM_TIMER_INTERVAL_MAX * CDC_NCM_TIM=
ER_PENDING_CNT))
-		return -EINVAL;
-
-	spin_lock_bh(&ctx->mtx);
-	ctx->timer_interval =3D ec->tx_coalesce_usecs * (NSEC_PER_USEC / CDC_=
NCM_TIMER_PENDING_CNT);
-	if (!ctx->timer_interval)
-		ctx->tx_timer_pending =3D 0;
-	spin_unlock_bh(&ctx->mtx);
-
-	/* inform device of new values */
-	if (new_rx_max !=3D ctx->rx_max || new_tx_max !=3D ctx->tx_max)
-		cdc_ncm_update_rxtx_max(dev, new_rx_max, new_tx_max);
-	return 0;
-}
-
 static const struct ethtool_ops cdc_ncm_ethtool_ops =3D {
 	.get_settings      =3D usbnet_get_settings,
 	.set_settings      =3D usbnet_set_settings,
@@ -187,8 +141,6 @@ static const struct ethtool_ops cdc_ncm_ethtool_ops=
 =3D {
 	.get_sset_count    =3D cdc_ncm_get_sset_count,
 	.get_strings       =3D cdc_ncm_get_strings,
 	.get_ethtool_stats =3D cdc_ncm_get_ethtool_stats,
-	.get_coalesce      =3D cdc_ncm_get_coalesce,
-	.set_coalesce      =3D cdc_ncm_set_coalesce,
 };
=20
 static u32 cdc_ncm_check_rx_max(struct usbnet *dev, u32 new_rx)
--=20
2.0.0.rc4
