From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net] r8152: use cancel_delayed_work for runtime suspend
Date: Fri, 17 Oct 2014 09:42:02 +0200
Message-ID: <87zjcvgn1x.fsf@nemi.mork.no>
References: <1394712342-15778-64-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <nic_swsd@realtek.com>,
	<linux-kernel@vger.kernel.org>, <linux-usb@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-64-Taiwan-albertk@realtek.com> (Hayes Wang's
	message of "Fri, 17 Oct 2014 13:55:29 +0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> writes:

> It would cause dead lock for runtime suspend, when the workqueue
> is running and runtime suspend occurs before the workqueue wakes
> up the device. The rtl8152_suspend() waits the workqueue to finish
> because of calling cancel_delayed_work_sync(). The workqueue waits
> the suspend function to finish for waking up the device because of
> calling usb_autopm_get_interface().
>
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> ---
>  drivers/net/usb/r8152.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
> index 864159e..7d4e55a 100644
> --- a/drivers/net/usb/r8152.c
> +++ b/drivers/net/usb/r8152.c
> @@ -3200,12 +3200,13 @@ static int rtl8152_suspend(struct usb_interfa=
ce *intf, pm_message_t message)
>  	if (netif_running(tp->netdev)) {
>  		clear_bit(WORK_ENABLE, &tp->flags);
>  		usb_kill_urb(tp->intr_urb);
> -		cancel_delayed_work_sync(&tp->schedule);
>  		tasklet_disable(&tp->tl);
>  		if (test_bit(SELECTIVE_SUSPEND, &tp->flags)) {
> +			cancel_delayed_work(&tp->schedule);
>  			rtl_stop_rx(tp);
>  			rtl_runtime_suspend_enable(tp, true);
>  		} else {
> +			cancel_delayed_work_sync(&tp->schedule);
>  			tp->rtl_ops.down(tp);
>  		}
>  		tasklet_enable(&tp->tl);

This looks strange to me. The delayed work will cause an immediate
resume due to the usb_autopm_get_interface() it starts with.  Wouldn't
it be better to just prevent runtime suspending by returning -EBUSY if
there is any delayed work scheduled?


Bj=C3=B8rn
