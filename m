From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2 1/2] r8152: adjust r8152_submit_rx
Date: Wed, 19 Nov 2014 17:02:47 +0300
Message-ID: <546CA307.7020407@cogentembedded.com>
References: <1394712342-15778-88-Taiwan-albertk@realtek.com> <1394712342-15778-95-Taiwan-albertk@realtek.com> <1394712342-15778-96-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nic_swsd@realtek.com, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-96-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 11/19/2014 8:20 AM, Hayes Wang wrote:

> The behavior of handling the returned status from r8152_submit_rx()
> is almost same, so let r8152_submit_rx() deal with the error
> directly. This could avoid the duplicate code.

> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> ---
>   drivers/net/usb/r8152.c | 41 +++++++++++++++++++++--------------------
>   1 file changed, 21 insertions(+), 20 deletions(-)
>
> diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
> index 0a30fd3..df0868b 100644
> --- a/drivers/net/usb/r8152.c
> +++ b/drivers/net/usb/r8152.c
[...]
> @@ -1806,11 +1789,29 @@ static void bottom_half(unsigned long data)
>   static
>   int r8152_submit_rx(struct r8152 *tp, struct rx_agg *agg, gfp_t mem_flags)
>   {
> +	int ret = 0;

    Initialization not needed.

> +
>   	usb_fill_bulk_urb(agg->urb, tp->udev, usb_rcvbulkpipe(tp->udev, 1),
>   			  agg->head, agg_buf_sz,
>   			  (usb_complete_t)read_bulk_callback, agg);
>
> -	return usb_submit_urb(agg->urb, mem_flags);
> +	ret = usb_submit_urb(agg->urb, mem_flags);
> +

    Empty line not needed here either.

> +	if (ret == -ENODEV) {
> +		set_bit(RTL8152_UNPLUG, &tp->flags);
> +		netif_device_detach(tp->netdev);
> +	} else if (ret) {
> +		struct urb *urb = agg->urb;
> +		unsigned long flags;
> +
> +		urb->actual_length = 0;
> +		spin_lock_irqsave(&tp->rx_lock, flags);
> +		list_add_tail(&agg->list, &tp->rx_done);
> +		spin_unlock_irqrestore(&tp->rx_lock, flags);
> +		tasklet_schedule(&tp->tl);
> +	}
> +
> +	return ret;
>   }
[...]

WBR, Sergei
