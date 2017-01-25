From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net 1/4] r8152: avoid start_xmit to call napi_schedule
 during autosuspend
Date: Tue, 24 Jan 2017 21:02:51 -0800
Message-ID: <20170124210251.202c383e@xeon-e3>
References: <1394712342-15778-236-Taiwan-albertk@realtek.com>
        <1394712342-15778-237-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <nic_swsd@realtek.com>,
        <linux-kernel@vger.kernel.org>, <linux-usb@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-237-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 25 Jan 2017 10:50:51 +0800
Hayes Wang <hayeswang@realtek.com> wrote:

> Adjust the setting of the flag of SELECTIVE_SUSPEND to prevent start_xmit()
> from calling napi_schedule() directly during runtime suspend.
> 
> After calling napi_disable() or clearing the flag of WORK_ENABLE,
> scheduling the napi is useless.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> ---
>  drivers/net/usb/r8152.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
> index e1466b4..27b0b44 100644
> --- a/drivers/net/usb/r8152.c
> +++ b/drivers/net/usb/r8152.c
> @@ -3585,10 +3585,13 @@ static int rtl8152_rumtime_suspend(struct r8152 *tp)
>  	struct net_device *netdev = tp->netdev;
>  	int ret = 0;
>  
> +	set_bit(SELECTIVE_SUSPEND, &tp->flags);
> +
>  	if (netif_running(netdev) && test_bit(WORK_ENABLE, &tp->flags)) {
>  		u32 rcr = 0;
>  
>  		if (delay_autosuspend(tp)) {
> +			clear_bit(SELECTIVE_SUSPEND, &tp->flags);
>  			ret = -EBUSY;
>  			goto out1;
>  		}
> @@ -3605,6 +3608,7 @@ static int rtl8152_rumtime_suspend(struct r8152 *tp)
>  			if (!(ocp_data & RXFIFO_EMPTY)) {
>  				rxdy_gated_en(tp, false);
>  				ocp_write_dword(tp, MCU_TYPE_PLA, PLA_RCR, rcr);
> +				clear_bit(SELECTIVE_SUSPEND, &tp->flags);
>  				ret = -EBUSY;

If you are going to start using bit operations then you may need smp_mb_before/after_atomic.
