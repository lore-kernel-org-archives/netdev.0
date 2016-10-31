From: Jes Sorensen <Jes.Sorensen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] rtl8xxxu: Fix for agressive power saving by rtl8723bu wireless IC
Date: Mon, 31 Oct 2016 17:25:12 -0400
Message-ID: <wrfj1sywrz2f.fsf@redhat.com>
References: <20161031183522.GA13315@cube>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: John Heenan <john-AMlJbUfTsso@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161031183522.GA13315@cube> (John Heenan's message of "Tue, 1
        Nov 2016 04:35:22 +1000")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

John Heenan <john-AMlJbUfTsso@public.gmane.org> writes:
> The rtl8723bu wireless IC shows evidence of a more agressive approach to
> power saving, powering down its RF side when there is no wireless
> interfacing but leaving USB interfacing intact. This makes the wireless
> IC more suitable for use in devices which need to keep their power use
> as low as practical, such as tablets and Surface Pro type devices.
>
> In effect this means that a full initialisation must be performed
> whenever a wireless interface is brought up. It also means that
> interpretations of power status from general wireless registers should
> not be relied on to influence an init sequence.
>
> The patch works by forcing a fuller initialisation and forcing it to
> occur more often in code paths (such as occurs during a low level
> authentication that initiates wireless interfacing).
>
> The initialisation sequence is now more consistent with code based
> directly on vendor code. For example while the vendor derived code
> interprets a register as indcating a particular powered state, it does
> not use this information to influence its init sequence.
>
> The rtl8723bu device has a unique USB VID and PID. This is taken
> advantage of for the patch to ensure only rtl8723bu devices are affected
> by this patch.
>
> With this patch wpa_supplicant reliably and consistently connects with
> an AP. Before a workaround such as executing rmmod and modprobe before
> each call to wpa_supplicant worked with some distributions.
>
> Signed-off-by: John Heenan <john-AMlJbUfTsso@public.gmane.org>
> ---
>  .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c  | 24 ++++++++++++++++++----
>  1 file changed, 20 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
> index 04141e5..f36e674 100644
> --- a/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
> +++ b/drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c
> @@ -79,6 +79,8 @@ MODULE_PARM_DESC(dma_agg_pages, "Set DMA aggregation pages (range 1-127, 0 to di
>  #define RTL8XXXU_TX_URB_LOW_WATER	25
>  #define RTL8XXXU_TX_URB_HIGH_WATER	32
>  
> +#define USB_PRODUCT_ID_RTL8723BU 0xb720
> +

Absolutely not! You have no guarantee that this is the only id used for
8723bu devices, and adding a #define for each is not going to happen.

>  static int rtl8xxxu_submit_rx_urb(struct rtl8xxxu_priv *priv,
>  				  struct rtl8xxxu_rx_urb *rx_urb);
>  
> @@ -3892,6 +3894,7 @@ static int rtl8xxxu_init_device(struct ieee80211_hw *hw)
>  	u8 val8;
>  	u16 val16;
>  	u32 val32;
> +  struct usb_device_descriptor *udesc = &priv->udev->descriptor;

Indentaiton
  
>  	/* Check if MAC is already powered on */
>  	val8 = rtl8xxxu_read8(priv, REG_CR);
> @@ -3900,7 +3903,9 @@ static int rtl8xxxu_init_device(struct ieee80211_hw *hw)
>  	 * Fix 92DU-VC S3 hang with the reason is that secondary mac is not
>  	 * initialized. First MAC returns 0xea, second MAC returns 0x00
>  	 */
> -	if (val8 == 0xea)
> +	if (val8 == 0xea
> +			|| (udesc->idVendor == USB_VENDOR_ID_REALTEK
> +			&&  udesc->idProduct == USB_PRODUCT_ID_RTL8723BU))
>  		macpower = false;
>  	else
>  		macpower = true;

Please respect proper kernel coding style!

> @@ -5776,9 +5781,17 @@ static int rtl8xxxu_start(struct ieee80211_hw *hw)
>  	struct rtl8xxxu_tx_urb *tx_urb;
>  	unsigned long flags;
>  	int ret, i;
> +	struct usb_device_descriptor *udesc = &priv->udev->descriptor;
>  
>  	ret = 0;
>  
> +	if(udesc->idVendor == USB_VENDOR_ID_REALTEK
> +			&& udesc->idProduct == USB_PRODUCT_ID_RTL8723BU) {
> +		ret = rtl8xxxu_init_device(hw);
> +		if (ret)
> +			goto error_out;
> +	}
> +

As mentioned previously, if this is to be changed here, it has to be
matched in the _stop section too. It also has to be investigated exactly
why this matters for 8723bu. It is possible this matters for other
devices, but we need to find out exactly what causes this not moving a
major block of init code around like this.

>  	init_usb_anchor(&priv->rx_anchor);
>  	init_usb_anchor(&priv->tx_anchor);
>  	init_usb_anchor(&priv->int_anchor);
> @@ -6080,9 +6093,12 @@ static int rtl8xxxu_probe(struct usb_interface *interface,
>  		goto exit;
>  	}
>  
> -	ret = rtl8xxxu_init_device(hw);
> -	if (ret)
> +	if(!(id->idVendor == USB_VENDOR_ID_REALTEK
> +			&& id->idProduct == USB_PRODUCT_ID_RTL8723BU)) {
> +		ret = rtl8xxxu_init_device(hw);
> +		if (ret)
>  		goto exit;
> +	}

Again, this coding style abuse will never go into this driver,

Jes
