From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH net 1/2] r8152: add pre_reset and post_reset
Date: Tue, 28 Jul 2015 10:52:42 +0200
Message-ID: <1438073562.11934.2.camel@suse.com>
References: <1394712342-15778-156-Taiwan-albertk@realtek.com>
	 <1394712342-15778-157-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-157-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-07-28 at 15:36 +0800, Hayes Wang wrote:
> Add rtl8152_pre_reset() and rtl8152_post_reset() which are used when
> calling usb_reset_device(). The two functions could reduce the time
> of reset when calling usb_reset_device() after probe().
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> ---
>  drivers/net/usb/r8152.c | 68 +++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 68 insertions(+)
> 
> diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
> index 144dc64..a6caa60 100644
> --- a/drivers/net/usb/r8152.c
> +++ b/drivers/net/usb/r8152.c
> @@ -3342,6 +3342,72 @@ static void r8153_init(struct r8152 *tp)
>  	r8153_u2p3en(tp, true);
>  }
>  
> +static int rtl8152_pre_reset(struct usb_interface *intf)
> +{
> +	struct r8152 *tp = usb_get_intfdata(intf);
> +	struct net_device *netdev;
> +	int ret;
> +
> +	if (intf->condition != USB_INTERFACE_BOUND || !tp)

If the interface weren't bound, you wouldn't be called.

> +		return 0;
> +
> +	netdev = tp->netdev;
> +	if (!netif_running(netdev))
> +		return 0;
> +
> +	ret = usb_autopm_get_interface(intf);
> +	if (ret < 0)
> +		return ret;

What sense does this make?

> +
> +	napi_disable(&tp->napi);
> +	clear_bit(WORK_ENABLE, &tp->flags);
> +	usb_kill_urb(tp->intr_urb);
> +	cancel_delayed_work_sync(&tp->schedule);
> +	if (netif_carrier_ok(netdev)) {
> +		netif_stop_queue(netdev);
> +		mutex_lock(&tp->control);
> +		tp->rtl_ops.disable(tp);
> +		mutex_unlock(&tp->control);
> +	}
> +
> +	usb_autopm_put_interface(intf);
> +
> +	return 0;
> +}
> +
> +static int rtl8152_post_reset(struct usb_interface *intf)
> +{
> +	struct r8152 *tp = usb_get_intfdata(intf);
> +	struct net_device *netdev;
> +	int ret;
> +
> +	if (intf->condition != USB_INTERFACE_BOUND || !tp)

Again unnecessary

> +		return 0;
> +
> +	netdev = tp->netdev;
> +	if (!netif_running(netdev))
> +		return 0;
> +
> +	ret = usb_autopm_get_interface(intf);

The device will be awake.

> +	if (ret < 0)
> +		return ret;
> +
> +	set_bit(WORK_ENABLE, &tp->flags);
> +	if (netif_carrier_ok(netdev)) {
> +		mutex_lock(&tp->control);
> +		tp->rtl_ops.enable(tp);
> +		rtl8152_set_rx_mode(netdev);
> +		mutex_unlock(&tp->control);
> +		netif_wake_queue(netdev);
> +	}
> +
> +	napi_enable(&tp->napi);
> +
> +	usb_autopm_put_interface(intf);
> +
> +	return ret;
> +}
> +

	HTH
		Oliver
