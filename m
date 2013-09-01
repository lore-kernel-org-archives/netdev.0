From: Hin-Tak Leung <htl10@users.sourceforge.net>
Subject: Re: [PATCH] rtl8187: fix use after free on failure path in rtl8187_init_urbs()
Date: Sun, 1 Sep 2013 08:51:21 +0100 (BST)
Message-ID: <1378021881.73447.YahooMailBasic@web172302.mail.ir2.yahoo.com>
Reply-To: htl10@users.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ldv-project@linuxtesting.org
To: khoroshilov@ispras.ru, herton@canonical.com,
	larry.finger@lwfinger.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------------------------------
On Sat, Aug 31, 2013 22:18 BST Alexey Khoroshilov wrote:

>In case of __dev_alloc_skb() failure rtl8187_init_urbs()
>calls usb_free_urb(entry) where 'entry' can points to urb
>allocated at the previous iteration. That means refcnt will be
>decremented incorrectly and the urb can be used after memory
>deallocation.
>
>The patch fixes the issue and implements error handling of init_urbs
>in rtl8187_start().
>
>Found by Linux Driver Verification project (linuxtesting.org).
>
>Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
>---
> drivers/net/wireless/rtl818x/rtl8187/dev.c | 15 ++++++++++-----
> 1 file changed, 10 insertions(+), 5 deletions(-)
>
>diff --git a/drivers/net/wireless/rtl818x/rtl8187/dev.c b/drivers/net/=
wireless/rtl818x/rtl8187/dev.c
>index f49220e..e83d53c 100644
>--- a/drivers/net/wireless/rtl818x/rtl8187/dev.c
>+++ b/drivers/net/wireless/rtl818x/rtl8187/dev.c
>@@ -438,17 +438,16 @@ static int rtl8187_init_urbs(struct ieee80211_hw=
 *dev)
> =A0=A0=A0 =A0=A0=A0 skb_queue_tail(&priv->rx_queue, skb);
> =A0=A0=A0 =A0=A0=A0 usb_anchor_urb(entry, &priv->anchored);
> =A0=A0=A0 =A0=A0=A0 ret =3D usb_submit_urb(entry, GFP_KERNEL);
>+=A0=A0=A0 =A0=A0=A0 usb_free_urb(entry);
> =A0=A0=A0 =A0=A0=A0 if (ret) {
> =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 skb_unlink(skb, &priv->rx_queue);
> =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 usb_unanchor_urb(entry);
> =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 goto err;
> =A0=A0=A0 =A0=A0=A0 }
>-=A0=A0=A0 =A0=A0=A0 usb_free_urb(entry);
> =A0=A0=A0 }
> =A0=A0=A0 return ret;
>
> err:
>-=A0=A0=A0 usb_free_urb(entry);
> =A0=A0=A0 kfree_skb(skb);
> =A0=A0=A0 usb_kill_anchored_urbs(&priv->anchored);
> =A0=A0=A0 return ret;

This part looks wrong - you free_urb(entry) then unanchor_urb(entry).

>@@ -956,8 +955,12 @@ static int rtl8187_start(struct ieee80211_hw *dev=
)
> =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0 (RETRY_COUNT < 8=A0 /* sh=
ort retry limit */) |
> =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0 (RETRY_COUNT < 0=A0 /* lo=
ng retry limit */) |
> =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0 (7 < 21 /* MAX TX DMA */)=
);
>-=A0=A0=A0 =A0=A0=A0 rtl8187_init_urbs(dev);
>-=A0=A0=A0 =A0=A0=A0 rtl8187b_init_status_urb(dev);
>+=A0=A0=A0 =A0=A0=A0 ret =3D rtl8187_init_urbs(dev);
>+=A0=A0=A0 =A0=A0=A0 if (ret)
>+=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 goto rtl8187_start_exit;
>+=A0=A0=A0 =A0=A0=A0 ret =3D rtl8187b_init_status_urb(dev);
>+=A0=A0=A0 =A0=A0=A0 if (ret)
>+=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 usb_kill_anchored_urbs(&priv->anchored)=
;
> =A0=A0=A0 =A0=A0=A0 goto rtl8187_start_exit;
> =A0=A0=A0 }
>=20
>@@ -966,7 +969,9 @@ static int rtl8187_start(struct ieee80211_hw *dev)
> =A0=A0=A0 rtl818x_iowrite32(priv, &priv->map->MAR[0], ~0);
> =A0=A0=A0 rtl818x_iowrite32(priv, &priv->map->MAR[1], ~0);
>=20
>-=A0=A0=A0 rtl8187_init_urbs(dev);
>+=A0=A0=A0 ret =3D rtl8187_init_urbs(dev);
>+=A0=A0=A0 if (ret)
>+=A0=A0=A0 =A0=A0=A0 goto rtl8187_start_exit;
>=20
> =A0=A0=A0 reg =3D RTL818X_RX_CONF_ONLYERLPKT |
> =A0=A0=A0 =A0 =A0 =A0 RTL818X_RX_CONF_RX_AUTORESETPHY |
>--=20
>1.8.1.2
>
