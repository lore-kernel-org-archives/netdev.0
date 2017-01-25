From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2 3/4] r8152: re-schedule napi for tx
Date: Wed, 25 Jan 2017 05:57:17 -0800
Message-ID: <1485352637.5145.4.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1394712342-15778-236-Taiwan-albertk@realtek.com>
         <1394712342-15778-242-Taiwan-albertk@realtek.com>
         <1394712342-15778-245-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-245-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-01-25 at 16:13 +0800, Hayes Wang wrote:
> Re-schedule napi after napi_complete() for tx, if it is necessay.
> 
> In r8152_poll(), if the tx is completed after tx_bottom() and before
> napi_complete(), the scheduling of napi would be lost. Then, no
> one handles the next tx until the next napi_schedule() is called.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> ---
>  drivers/net/usb/r8152.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
> index ec882be..45d168e 100644
> --- a/drivers/net/usb/r8152.c
> +++ b/drivers/net/usb/r8152.c
> @@ -1936,6 +1936,9 @@ static int r8152_poll(struct napi_struct *napi, int budget)
>  		napi_complete(napi);
>  		if (!list_empty(&tp->rx_done))
>  			napi_schedule(napi);
> +		else if (!skb_queue_empty(&tp->tx_queue) &&
> +			 !list_empty(&tp->tx_free))
> +			napi_schedule(&tp->napi);

Why using &tp->napi instead of napi here, as done 3 lines above ?
