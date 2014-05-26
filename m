From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next 5/8] net: cdc_ncm: drop ethtool coalesce support
Date: Mon, 26 May 2014 12:53:42 +0200
Message-ID: <1401101625-12342-6-git-send-email-bjorn@mork.no>
References: <1401101625-12342-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>,
	Lars Melin <larsm17-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Peter Stuge <peter-Y+HMSxxDrH8@public.gmane.org>,
	Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1401101625-12342-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The ethtool coalesce API is not applicable for this driver. Forcing
it to fit the NCM aggregation redefined the API in a driver specific
way, which is much worse than defining a clean new API. These ethtool
coalesce functions have therefore been replaced by a new sysfs API.

Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
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
