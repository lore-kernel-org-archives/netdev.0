From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] can: ems_usb: Fix possible tx overflow
Date: Mon, 22 Feb 2016 15:11:26 +0300
Message-ID: <56CAFAEE.2020602@cogentembedded.com>
References: <1456068458-14271-1-git-send-email-mkl@pengutronix.de>
 <1456068458-14271-2-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de,
	Gerhard Uttenthaler <uttenthaler@ems-wuensche.com>,
	linux-stable <stable@vger.kernel.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>, netdev@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1456068458-14271-2-git-send-email-mkl@pengutronix.de>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 2/21/2016 6:27 PM, Marc Kleine-Budde wrote:

> From: Gerhard Uttenthaler <uttenthaler@ems-wuensche.com>
>
> This patch fixes the problem that more CAN messages could be sent to the
> interface as could be send on the CAN bus. This was more likely for slow baud
> rates. The sleeping _start_xmit was woken up in the _write_bulk_callback. Under
> heavy TX load this produced another bulk transfer without checking the
> free_slots variable and hence caused the overflow in the interface.
>
> Signed-off-by: Gerhard Uttenthaler <uttenthaler@ems-wuensche.com>
> Cc: linux-stable <stable@vger.kernel.org>
> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
> ---
>   drivers/net/can/usb/ems_usb.c | 14 ++++++++++----
>   1 file changed, 10 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/can/usb/ems_usb.c b/drivers/net/can/usb/ems_usb.c
> index fc5b75675cd8..eb7192fab593 100644
> --- a/drivers/net/can/usb/ems_usb.c
> +++ b/drivers/net/can/usb/ems_usb.c
> @@ -117,6 +117,9 @@ MODULE_LICENSE("GPL v2");
>    */
>   #define EMS_USB_ARM7_CLOCK 8000000
>
> +#define CPC_TX_QUEUE_TRIGGER_LOW	25
> +#define CPC_TX_QUEUE_TRIGGER_HIGH	35
> +
>   /*
>    * CAN-Message representation in a CPC_MSG. Message object type is
>    * CPC_MSG_TYPE_CAN_FRAME or CPC_MSG_TYPE_RTR_FRAME or
> @@ -278,6 +281,11 @@ static void ems_usb_read_interrupt_callback(struct urb *urb)
>   	switch (urb->status) {
>   	case 0:
>   		dev->free_slots = dev->intr_in_buffer[1];
> +		if(dev->free_slots > CPC_TX_QUEUE_TRIGGER_HIGH){
> +			if (netif_queue_stopped(netdev)){
> +				netif_wake_queue(netdev);
> +			}
> +		}

    Hm, did anyone run scripts/checkpatch.pl on this patch?

[...]

MBR, Sergei
