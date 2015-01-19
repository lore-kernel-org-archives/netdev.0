From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 1/7] r8152: adjust rx_bottom
Date: Mon, 19 Jan 2015 00:03:42 -0800
Message-ID: <CAE4R7bAv26f-+DW-TmjspJxAb-3Add5sf563mnMUTGCyiqG3rQ@mail.gmail.com>
References: <1394712342-15778-118-Taiwan-albertk@realtek.com>
	<1394712342-15778-119-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-119-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 18, 2015 at 11:13 PM, Hayes Wang <hayeswang@realtek.com> wrote:
> If a error occurs when submitting rx, skip the remaining submissions
> and try to submit them again next time.
>
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> ---
>  drivers/net/usb/r8152.c | 15 +++++++++++++--
>  1 file changed, 13 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
> index 2e22442..78a8917 100644
> --- a/drivers/net/usb/r8152.c
> +++ b/drivers/net/usb/r8152.c
> @@ -1655,7 +1655,7 @@ static int rx_bottom(struct r8152 *tp, int budget)
>  {
>         unsigned long flags;
>         struct list_head *cursor, *next, rx_queue;
> -       int work_done = 0;
> +       int ret = 0, work_done = 0;
>
>         if (!skb_queue_empty(&tp->rx_queue)) {
>                 while (work_done < budget) {
> @@ -1746,7 +1746,18 @@ find_next_rx:
>                 }
>
>  submit:
> -               r8152_submit_rx(tp, agg, GFP_ATOMIC);
> +               if (!ret) {
> +                       ret = r8152_submit_rx(tp, agg, GFP_ATOMIC);
> +               } else {
> +                       urb->actual_length = 0;
> +                       list_add_tail(&agg->list, next);

Do you need a spin_lock_irqsave(&tp->rx_lock, flags) around this?

> +               }
> +       }
> +
> +       if (!list_empty(&rx_queue)) {
> +               spin_lock_irqsave(&tp->rx_lock, flags);
> +               list_splice_tail(&rx_queue, &tp->rx_done);
> +               spin_unlock_irqrestore(&tp->rx_lock, flags);
>         }
>
>  out1:
> --
> 2.1.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
