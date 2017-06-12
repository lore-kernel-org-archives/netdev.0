From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH net-next 1/2] r8152: split rtl8152_resume function
Date: Mon, 12 Jun 2017 14:33:26 +0200
Message-ID: <1497270806.15677.18.camel@suse.com>
References: <1394712342-15778-272-Taiwan-albertk@realtek.com>
         <1394712342-15778-273-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: nic_swsd@realtek.com, linux-kernel@vger.kernel.org,
        linux-usb@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-273-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Montag, den 12.06.2017, 16:21 +0800 schrieb Hayes Wang:
> Split rtl8152_resume() into rtl8152_runtime_resume() and
> rtl8152_system_resume().
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> ---
>  drivers/net/usb/r8152.c | 99 ++++++++++++++++++++++++++++++-------------------
>  1 file changed, 61 insertions(+), 38 deletions(-)
> 
> diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
> index 5a02053..3257955 100644
> --- a/drivers/net/usb/r8152.c
> +++ b/drivers/net/usb/r8152.c
> @@ -3686,6 +3686,61 @@ static bool delay_autosuspend(struct r8152 *tp)
>                 return false;
>  }
>  
> +static int rtl8152_runtime_resume(struct r8152 *tp)
> +{
> +       struct net_device *netdev = tp->netdev;
> +
> +       if (netif_running(netdev) && netdev->flags & IFF_UP) {
> +               struct napi_struct *napi = &tp->napi;
> +
> +               tp->rtl_ops.autosuspend_en(tp, false);
> +               napi_disable(napi);
> +               set_bit(WORK_ENABLE, &tp->flags);
> +
> +               if (netif_carrier_ok(netdev)) {
> +                       if (rtl8152_get_speed(tp) & LINK_STATUS) {
> +                               rtl_start_rx(tp);
> +                       } else {
> +                               netif_carrier_off(netdev);
> +                               tp->rtl_ops.disable(tp);
> +                               netif_info(tp, link, netdev, "linking down\n");
> +                       }
> +               }
> +
> +               napi_enable(napi);
> +               clear_bit(SELECTIVE_SUSPEND, &tp->flags);
> +               smp_mb__after_atomic();
> +
> +               if (!list_empty(&tp->rx_done))
> +                       napi_schedule(&tp->napi);
> +
> +               usb_submit_urb(tp->intr_urb, GFP_KERNEL);

If you ever built a device with included storage, this can deadlock,
as you may want to wake up a device for memory that is needed to wake
up a device. Use GFP_NOIO in resume() and reset_resume(), always.

	Regards
		Oliver
