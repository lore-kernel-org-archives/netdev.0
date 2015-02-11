From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH net-next 1/3] r8152: separate USB_RX_EARLY_AGG
Date: Wed, 11 Feb 2015 16:52:20 +0300
Message-ID: <54DB5E94.6010101@cogentembedded.com>
References: <1394712342-15778-137-Taiwan-albertk@realtek.com> <1394712342-15778-138-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394712342-15778-138-Taiwan-albertk-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 2/11/2015 9:46 AM, Hayes Wang wrote:

> Separate USB_RX_EARLY_AGG into USB_RX_EARLY_TIMEOUT and USB_RX_EARLY_SIZE.

> Replace r8153_set_rx_agg() with r8153_set_rx_early_timeout() and
> r8153_set_rx_early_size().

> Set the default timeout value according to the USB speed.

> Signed-off-by: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
> ---
>   drivers/net/usb/r8152.c | 55 ++++++++++++++++++++++++++-----------------------
>   1 file changed, 29 insertions(+), 26 deletions(-)

> diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
> index 5980ac6..b043c7f 100644
> --- a/drivers/net/usb/r8152.c
> +++ b/drivers/net/usb/r8152.c
[...]
> @@ -2114,28 +2116,21 @@ static int rtl8152_enable(struct r8152 *tp)
>   	return rtl_enable(tp);
>   }
>
> -static void r8153_set_rx_agg(struct r8152 *tp)
> +static void r8153_set_rx_early_timeout(struct r8152 *tp)
>   {
> -	u8 speed;
> +	u32 ocp_data;
>
[...]
> +	ocp_data = tp->coalesce / 8;

    Why not do it in the initializer?

> +	ocp_write_word(tp, MCU_TYPE_USB, USB_RX_EARLY_TIMEOUT, ocp_data);
> +}
> +
> +static void r8153_set_rx_early_size(struct r8152 *tp)
> +{
> +	struct net_device *dev = tp->netdev;

    Not sure you actually need this variable.

> +	u32 ocp_data;
> +
> +	ocp_data = (agg_buf_sz - dev->mtu - VLAN_ETH_HLEN - VLAN_HLEN) / 4;

    Why not in initializer?

> +	ocp_write_word(tp, MCU_TYPE_USB, USB_RX_EARLY_SIZE, ocp_data);
>   }
[...]
> @@ -3911,6 +3907,13 @@ static int rtl8152_probe(struct usb_interface *intf,
>   	tp->mii.reg_num_mask = 0x1f;
>   	tp->mii.phy_id = R8152_PHY_ID;
>
> +	if (udev->speed == USB_SPEED_SUPER)
> +		tp->coalesce = COALESCE_SUPER;
> +	else if (udev->speed == USB_SPEED_HIGH)
> +		tp->coalesce = COALESCE_HIGH;
> +	else
> +		tp->coalesce = COALESCE_SLOW;

    This is asking to be a *switch* statement.

[...]

WBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
